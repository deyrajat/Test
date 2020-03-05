####################################################################################################
# Date: <31/05/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
################################################################################################
@PCF @Combine_Deployment_Longevity @Tzc182637381c @Tzc182637382c @Tzc182637383c

Feature: PCF_19_3_0_005_Combined_Deployment_Longevity
 
  @Tzc182637381c
  Scenario: Change Config In Ops Center 30 MINs- Two Iterations

    Given the connection to QNS is established for SSH,WSClient,ToolAgent successfully
    
    Given the SFTP push of file {config.global.workspace.library.location-scripts-templates}pcf_ops_configuration.xml to /root/ at SITEHOST is successful
    
    #CICD Test report start
    Given I define the following constants:
      | name     | value            |
      | testtype | aggravatorTests  |
      
    #CICD Test report start  
    Given I define the following constants:
      | name        | value                            |
      | DEPstatus   | {config.global.report.result.ne} |
      | DRTstatus   | {config.global.report.result.ne} |
      | DTPstatus   | {config.global.report.result.ne} |
      | ACstatus    | {config.global.report.result.fail}      |
      | CPUstatus   | {config.global.report.result.ne} |
      | SWAPstatus  | {config.global.report.result.ne} |
      | VMDstatus   | {config.global.report.result.ne} |
      
    Then I update report for table {Constant.testtype} with the following details:
      | Deployment Followed By Longevity | Fail |
    #CICD Test report end
    
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    #CICD Test report end
    
    # DISABLE subversion-ingress for SVN during teardown
    When I execute the SSH command "config ; {config.global.command.opsCenter.system-disable-svn}  ; commit ; end" at CLIPcfOPSCenter    

    Then I wait for {config.global.constant.onehundred.eighty} seconds

    Given the arming of teardown steps are done

    #External PreRun File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}PreRun.feature
    
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.benchmark-interval} seconds

	When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time | 

    #CICD report start#####################
    #Convert the wait time in mins
    When I execute the SSH command "echo `expr {config.scenario.exec-params.benchmark-interval} / 60`" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value               |
      | (.*)      | iterationWaitInMins |

    ##Get execution duration till this point for report
    Given I define the following constants:
      | name              | value                     |
      | longevityDuration | {SSH.iterationWaitInMins} |

    #Convert the wait time in mins

    Then I update report for table {Constant.testtype} with the following details:
      | Deployment Followed By Longevity | Fail | {Constant.longevityDuration} mins. |
    #CICD report end#####################

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

	#CICD report start#####################
    When I execute the SSH command "echo `expr {Constant.longevityDuration} + {SSH.iterationWaitInMins}`" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value         |
      | (.*)      | totalExecTime |

    ##Get execution duration till this point for report
    Given I define the following constants:
      | name              | value               |
      | longevityDuration | {SSH.totalExecTime} |

    Then I update report for table {Constant.testtype} with the following details:
      | Deployment Followed By Longevity | Fail | {Constant.longevityDuration} mins. |
    #CICD report end#####################

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

    When I execute using handler SITEHOST the SSH shell command ls {config.scenario.pb.file-name}
    Then I save the SSH response in the following variables:
      | attribute | value        |
      | (.*)      | cpsFilename  |

    When I execute using handler SITEHOST on channel ch3 the command curl -k -m {config.global.constant.twohundred.forty} -u admin:{config.PCFRestEndpoint.Authentication.Password} -H Content-Type:application/octet-stream --data-binary "@{SSH.cpsFilename}" -X POST {config.global.scenario.deployability.pb-api-url}api/repository/actions/import?importUrl=http://{SSH.svn_ep_url}/repos/run&commitMessage=Importing... 
	Then I wait for {config.global.constant.sixty} seconds
    Then I receive a SSH response using handler SITEHOST on channel ch3 and check the presence of following strings:
        | string        | occurrence |
        | success       | present    |

    Then I wait for {config.global.constant.threehundred} seconds

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

	#CICD report start#####################
    When I execute the SSH command "echo `expr {Constant.longevityDuration} + {SSH.iterationWaitInMins}`" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value         |
      | (.*)      | totalExecTime |

    ##Get execution duration till this point for report
    Given I define the following constants:
      | name              | value               |
      | longevityDuration | {SSH.totalExecTime} |

    Then I update report for table {Constant.testtype} with the following details:
      | Deployment Followed By Longevity | Fail | {Constant.longevityDuration} mins. |
    #CICD report end#####################

    #Iteration2 Steps
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

    When I execute using handler SITEHOST the SSH shell command ls {config.scenario.crd.file-name}
    Then I save the SSH response in the following variables:
      | attribute | value        |
      | (.*)      | crdFileName  |
      
    ### Get the timestap for Golden CRD export 
    When I execute the SSH command "date '+%s'" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | CRD_Export_Time    |
      
    When I execute using handler SITEHOST on channel ch4 the command curl -k -m {config.global.constant.twohundred.forty} -u admin:{config.PCFRestEndpoint.Authentication.Password} -H Content-Type:application/json -X GET {config.global.scenario.deployability.pb-api-url}proxy/custrefdata/_export?goldenCrdHost=svn&_={SSH.CRD_Export_Time}
    Then I wait for {config.global.constant.sixty} seconds
    Then I receive a SSH response using handler SITEHOST on channel ch4 and check the presence of following strings:
        | string    | occurrence | 
        | 200       | present    |     
        
    Then I wait for {config.global.constant.twenty} seconds

    When I execute using handler SITEHOST on channel ch5 the command curl -k -m {config.global.constant.twohundred.forty} -u admin:{config.PCFRestEndpoint.Authentication.Password} -H Content-Type:application/octet-stream --data-binary @{SSH.crdFileName} -X POST {config.global.scenario.deployability.pb-api-url}proxy/custrefdata/_import
    Then I wait for {config.global.constant.sixty} seconds
    Then I receive a SSH response using handler SITEHOST on channel ch5 and check the presence of following strings:
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

    #CICD report start#####################
    When I execute the SSH command "echo `expr {Constant.longevityDuration} + {SSH.iterationWaitInMins}`" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value         |
      | (.*)      | totalExecTime |

    ##Get execution duration till this point for report
    Given I define the following constants:
      | name              | value               |
      | longevityDuration | {SSH.totalExecTime} |

    Then I update report for table {Constant.testtype} with the following details:
      | Deployment Followed By Longevity | Fail | {Constant.longevityDuration} mins. |
    #CICD report end#####################

    #Iteration2 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature    

    When I execute the SSH command "echo `expr {config.scenario.exec-params.longevity-interval} / 60`" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value               |
      | (.*)      | iterationWaitInMins |

    ##Change the variables
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}VariableChange.feature  

	#Considering we need n number of iterations      
	Given I loop {config.scenario.exec-params.longevity-iteration} times

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.longevity-interval} seconds

	When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time | 

    #CICD report start#####################
    When I execute the SSH command "echo `expr {Constant.longevityDuration} + {SSH.iterationWaitInMins}`" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value         |
      | (.*)      | totalExecTime |

    ##Get execution duration till this point for report
    Given I define the following constants:
      | name              | value               |
      | longevityDuration | {SSH.totalExecTime} |

    Then I update report for table {Constant.testtype} with the following details:
      | Deployment Followed By Longevity | Fail | {Constant.longevityDuration} mins. |
    #CICD report end#####################

    ##Checking with last iteration values on 1hr interval
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature
    
    When I execute the SSH command  show running-config alerts at CLICeeOPSCenter
    Then I save the SSH response in the following variables:
      | attribute      | value     |
      | ([\s\S]*)      | CeeAlerts |
      
    When I execute the SSH command rm -rf {config.sut.k8smaster.home.directory}/alerts.txt at K8SMaster
      
    When I execute the SSH command echo -e '{SSH.CeeAlerts}' > {config.sut.k8smaster.home.directory}/alerts.txt at K8SMaster
      
    When I execute using handler K8SMaster the parameterized command {config.sut.k8smaster.home.directory}/PCF_compare_alert_config_with_log.sh with following arguments:
      | attribute | value                           |
      | n         | {config.sut.k8s.namespace.cee}  |
      | t         | {config.scenario.exec-params.execution-duration}s  |
      | a         | {config.sut.k8smaster.home.directory}/alerts.txt   |   
    Then I receive a SSH response and check the presence of following strings:
      | string                        | occurrence |
      | Found logs for Rule           | absent     |
      | Logs not found for Rule       | present    |

    ##Change the variables
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}VariableChange.feature

    And  I end loop

   	Given I expect the next test step to execute otherwise

        Given I print: "SYSTEM Status is not running."

    Given I end the if

	  #CICD report start#####################
	  Given I define the following constants:
	    | name        | value                                    |
	    | ACstatus    | {config.global.report.result.success} |
	  Then I update report for table {Constant.testtype} with the following details:
	    | Deployment Followed By Longevity | Pass | {Constant.longevityDuration} mins. |
	  #CICD report end#####################
    
  @Tzc182637382c 
  Scenario: Publish PB in PCF Setup
  
    Given I print: "Publish PB in PCF Setup "
    
  @Tzc182637383c    
  Scenario: Publish CRD in PCF Setup
  
    Given I print: "Publish CRD in PCF Setup"
    
