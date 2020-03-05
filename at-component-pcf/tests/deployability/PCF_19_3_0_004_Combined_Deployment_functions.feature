####################################################################################################
# Date: <31/05/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
################################################################################################
@PCF @Combine_Deployment @Dropped

Feature: PCF_19_3_0_004_Combined_Deployment_functions

  Scenario: Change Config In Ops Center 30 MINs- Two Iterations

    Given the connection to QNS is established for SSH,WSClient,ToolAgent successfully
    
    Given the SFTP push of file {config.global.workspace.library.location-scripts-templates}pcf_ops_configuration.xml to /root/ at SITEHOST is successful
    
    #CICD Test report start
    Given I define the following constants:
      | name     | value            |
      | testtype | aggravatorTests  |
      
    #CICD Test report start  
    Given I define the following constants:
      | name        | value                                         |
      | DEPstatus   | {config.global.report.result.ne} |
      | DRTstatus   | {config.global.report.result.ne} |
      | DTPstatus   | {config.global.report.result.ne} |
      | ACstatus    | {config.global.report.result.fail}      |
      | CPUstatus   | {config.global.report.result.ne} |
      | SWAPstatus  | {config.global.report.result.ne} |
      | VMDstatus   | {config.global.report.result.ne} |
      
    Then I update report for table {Constant.testtype} with the following details:
      | Change Config In Ops Center 30 MINs- Two Iterations | Fail |
    #CICD Test report end
    
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    #CICD Test report end
    
    # DISABLE subversion-ingress for SVN during teardown.               
    When I execute the SSH command "config ; {config.global.command.opsCenter.system-disable-svn}  ; commit ; end" at CLIPcfOPSCenter    

    Then I wait for {config.global.constant.onehundred.eighty} seconds

    Given the arming of teardown steps are done

    #External PreRun File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}PreRun.feature
    
    #External SetupTest File
    Given I execute the steps from {config.global.workspace.library.location-features-calipers}CallModel_SetupTest.feature
	
    #call Start
    Given I execute the steps from {config.global.workspace.library.location-features-calipers}CallModel_Execution.feature

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |
    
    Then I wait for {config.scenario.exec-params.benchmark-interval} seconds
	
	When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time | 

    #Get Benchmark values
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Benchmark.feature  
    
    When I execute the SSH command "date +%H:%M_%Y%m%d" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | event_start_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                  |
      | (.*)      | event_start_epoch_time |
      
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    When I send a REST Request as SysMode to Resource URI /api/candidate/ on endpoint PCFRestEndpoint using http method GET
    Then I receive a REST Response for SysMode and validate using following attributes:
        | attribute        | value |
        | {HTTPStatusCode} | 200   |
    And I save the REST Response for SysMode with the following attributes:
      | attribute                                                                                     | value   |
      | {XPath}/*[local-name()='data']/*[local-name()='system']/*[local-name()='mode']/text()         | sysmode |
      
    Given I expect the next test step to execute if '("{WSClient.sysmode}" == 'running')' 
    
    Given the SFTP pull of file /root/pcf_ops_configuration.xml at SITEHOST to "{config.global.workspace.library.location-scripts-templates}" is successful  
    
    Given the data message bundle is provided in /{config.global.workspace.library.location-scripts-templates}pcf_ops_configuration.xml
    
    ## Change Set-up in maintenance mode
      
    When I execute the SSH command "config ; {config.global.command.opsCenter.system-mode-maintenance} ; commit ; end" at CLIPcfOPSCenter 

    Then I wait for {config.global.constant.threehundred} seconds  
    Then I wait for {config.global.constant.threehundred} seconds  
    
	## Check if present status is maintenance
    When I send a REST Request as MainStat to Resource URI /api/candidate/ on endpoint PCFRestEndpoint using http method GET
    Then I receive a REST Response for MainStat and validate using following attributes:
      | attribute                                      | value          |
      | {HTTPStatusCode}                               | 200            |
      | {XPath}/*[local-name()='data']/*[local-name()='system']/*[local-name()='mode']/text() | maintenance |

    ## Check status of the deployment.
    When I send a REST Request as GetDeploymentStatus4 to Resource URI /api/operational/system/status on endpoint PCFRestEndpoint using http method GET
	Then I receive a REST Response for GetDeploymentStatus4 and validate using following attributes:
		| attribute        | value |
		| {HTTPStatusCode} | 200   |
	And I save the REST Response for GetDeploymentStatus4 with the following attributes:
      | attribute                                                                  | value      |
      | {XPath}/*[local-name()='status']/*[local-name()='percent-ready']/text()    | depPercent |  
   Then I validate the following attributes:
  	  | attribute             | value                                            |
   	  | {WSClient.depPercent} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) | 
   	  
    ####Capture End Time after Reboot
    When I execute the SSH command "date +%H:%M_%Y%m%d" at K8SMaster    
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | event_end_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                |
      | (.*)      | event_end_epoch_time |
      
	When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time | 

    ##Calculate exact duration of event in seconds
    When I execute the SSH command {config.global.remotepush.location.utilities-geteventduration} {SSH.event_start_epoch_time} {SSH.event_end_epoch_time} at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value        |
      | (.*)      | eventTimeSec |

    ####Check Errors and Timeouts during Reboot
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}EventErrorCaptureAndChecks.feature
    
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |
    
	Then I wait for {config.scenario.exec-params.benchmark-interval} seconds
	
	When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time | 

    #Iteration1 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration1_Steps.feature
    
    When I execute the SSH command "config ; {config.global.command.opsCenter.system-mode-running} ; commit ; end" at CLIPcfOPSCenter 
      
    Then I wait for {config.global.constant.threehundred} seconds  
    
    ## Check if present status is running
    When I send a REST Request as ModStat to Resource URI /api/candidate/ on endpoint PCFRestEndpoint using http method GET
    Then I receive a REST Response for ModStat and validate using following attributes:
      | attribute                                      | value          |
      | {HTTPStatusCode}                               | 200            |
      | {XPath}/*[local-name()='data']/*[local-name()='system']/*[local-name()='mode']/text() | {WSClient.sysmode} |

    ## Check status of the deployment.
    When I send a REST Request as GetDeploymentStatus5 to Resource URI /api/operational/system/status on endpoint PCFRestEndpoint using http method GET
	Then I receive a REST Response for GetDeploymentStatus5 and validate using following attributes:
		| attribute        | value |
		| {HTTPStatusCode} | 200   |
	And I save the REST Response for GetDeploymentStatus5 with the following attributes:
      | attribute                                                                  | value      |
      | {XPath}/*[local-name()='status']/*[local-name()='percent-ready']/text()    | depPercent |  
   Then I validate the following attributes:
  	  | attribute             | value                                            |
   	  | {WSClient.depPercent} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) | 

    ##################************************2nd Iteration***************************
    
    ## Enable subversion-ingress for SVN.     
    When I execute the SSH command "config ; {config.global.command.opsCenter.system-enable-svn} ; commit ; end" at CLIPcfOPSCenter

    Then I wait for {config.global.constant.onehundred.eighty} seconds
    
    When I execute the SSH command "kubectl get ing -n {config.sut.k8s.namespace.pcf} | grep svn | awk '{print $2}'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value      |
      | (.*)      | svn_ep_url | 
    
    When I execute the SSH command "date +%H:%M_%Y%m%d" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | event_start_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                  |
      | (.*)      | event_start_epoch_time |
      
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Given the SFTP push of file "{config.scenario.pb.file-path}{config.scenario.pb.file-name}" to /root/ at SITEHOST is successful

    When I execute using handler SITEHOST the SSH shell command ls  {config.scenario.pb.file-name}
    Then I save the SSH response in the following variables:
      | attribute | value        |
      | (.*)      | cpsFilename  |

    When I execute using handler SITEHOST on channel ch3 the command curl -k -m {config.global.constant.twohundred.forty} -u admin:{config.PCFRestEndpoint.Authentication.Password} -H Content-Type:application/octet-stream --data-binary "@{SSH.cpsFilename}" -X POST {config.global.scenario.deployability.pb-api-url}api/repository/actions/import?importUrl=http://{SSH.svn_ep_url}/repos/run&commitMessage=Importing... 
	Then I wait for {config.global.constant.sixty} seconds
    Then I receive a SSH response using handler SITEHOST on channel ch3 and check the presence of following strings:
        | string        | occurrence | 
        | success       | present    |     
    
    Then I wait for {config.global.constant.threehundred} seconds
    Then I wait for {config.global.constant.onehundred.twenty} seconds
    
    ####Capture End Time after Reboot
    When I execute the SSH command "date +%H:%M_%Y%m%d" at K8SMaster    
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | event_end_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                |
      | (.*)      | event_end_epoch_time |
      
	When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time | 

    ##Calculate exact duration of event in seconds
    When I execute the SSH command {config.global.remotepush.location.utilities-geteventduration} {SSH.event_start_epoch_time} {SSH.event_end_epoch_time} at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value        |
      | (.*)      | eventTimeSec |

    ####Check Errors and Timeouts during Reboot
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}EventErrorCaptureAndChecks.feature
    
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |    
      
    Then I wait for {config.scenario.exec-params.benchmark-interval} seconds
	
	When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time | 
      
    #Iteration1 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature    
    
    ##Change the variables
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}VariableChange.feature   
    
    When I execute the SSH command "date +%H:%M_%Y%m%d" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | event_start_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                  |
      | (.*)      | event_start_epoch_time |
      
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

	Given the SFTP push of file "{config.scenario.crd.file-path}{config.scenario.crd.file-name}" to /root/ at SITEHOST is successful

    When I execute using handler SITEHOST the SSH shell command ls  {config.scenario.crd.file-name}
    Then I save the SSH response in the following variables:
      | attribute | value        |
      | (.*)      | crdFileName  |

    When I execute using handler SITEHOST on channel ch4 the command curl -k -m {config.global.constant.twohundred.forty} -u admin:{config.PCFRestEndpoint.Authentication.Password} -H Content-Type:application/octet-stream --data-binary @{SSH.crdFileName} -X POST {config.global.scenario.deployability.pb-api-url}proxy/custrefdata/_import
    Then I wait for {config.global.constant.sixty} seconds
    Then I receive a SSH response using handler SITEHOST on channel ch4 and check the presence of following strings:
        | string    | occurrence | 
        | 200       | present    | 
    
    Then I wait for {config.global.constant.threehundred} seconds
    
    ## Make subversion disable
    When I execute the SSH command "config ; {config.global.command.opsCenter.system-disable-svn}  ; commit ; end" at CLIPcfOPSCenter
     
    Then I wait for {config.global.constant.onehundred.eighty} seconds
    
    Given I print:===================== Pod Status after pcf config =========================
    When I execute using handler K8SMaster the SSH shell command {config.global.commands.k8s.pod-list-pcf} | grep -v Running
    Given I print:===================== Pod Status after pcf config =========================    

    ####Capture End Time after Reboot
    When I execute the SSH command "date +%H:%M_%Y%m%d" at K8SMaster    
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | event_end_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                |
      | (.*)      | event_end_epoch_time |
      
	When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time | 

    ##Calculate exact duration of event in seconds
    When I execute the SSH command {config.global.remotepush.location.utilities-geteventduration} {SSH.event_start_epoch_time} {SSH.event_end_epoch_time} at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value        |
      | (.*)      | eventTimeSec |

    ####Check Errors and Timeouts during Reboot
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}EventErrorCaptureAndChecks.feature
    
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |
    
    Then I wait for {config.scenario.exec-params.benchmark-interval} seconds	
	
	When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time | 
      
    #Iteration1 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature     
      
    
   	Given I expect the next test step to execute otherwise

 		Given I print: "SYSTEM Status is not running."
 	
	Given I end the if



    #CICD report start#####################
    #Then I update report for table {Constant.testkpi} with the following details:
    #    | {config.global.report.label.additionalchecks} | Pass |
    Given I define the following constants:
      | name        | value                                    |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | Change Config In Ops Center 30 MINs- Two Iterations | Pass |
    #CICD report end#####################
