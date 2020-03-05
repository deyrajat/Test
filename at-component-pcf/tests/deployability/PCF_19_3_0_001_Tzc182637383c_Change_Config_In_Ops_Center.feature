####################################################################################################
# Date: <31/05/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
################################################################################################
@PCF @Deployment @Tzc182637383c @Dropped

Feature: PCF_19_3_0_001_Tzc182637383c_Change_Config_In_Ops_Center

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
      | attribute                                      																								| value   |
      | {XPath}/*[local-name()='data']/*[local-name()='system']/*[local-name()='mode']/text()         | sysmode |
      
    Given I expect the next test step to execute if '("{WSClient.sysmode}" == 'running')' 
    
    Given the SFTP pull of file /root/pcf_ops_configuration.xml at SITEHOST to "{config.global.workspace.library.location-scripts-templates}" is successful  
    
    Given the data message bundle is provided in /{config.global.workspace.library.location-scripts-templates}pcf_ops_configuration.xml
    
    When I send a REST Request as MaintPatch to Resource URI /api/candidate/ on endpoint PCFRestEndpoint using http method PATCH using message reference MAINTENANCE_SETUP with the following attributes:
       | attribute                    | value                           |
       | {HEADER}Content-Type         | application/vnd.yang.data+json  |
       | {HEADER}Accept               | application/vnd.yang.data+json  |
    Then I receive a REST Response for MaintPatch and validate using following attributes:
      | attribute               | value          |
      | {HTTPStatusCode}        | 204            |

    When I send a REST Request as MaintPost to Resource URI /api/candidate/_commit on endpoint PCFRestEndpoint using http method POST with the following attributes:
       | attribute                    | value                           |
       | {HEADER}Content-Type         | application/vnd.yang.data+json  |
       | {HEADER}Accept               | application/vnd.yang.data+json  |
    Then I receive a REST Response for MaintPost and validate using following attributes:
      | attribute                | value              |
      | {HTTPStatusCode}         | 204                |

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

    ##################************************2nd Iteration***************************
    
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

    When I send a REST Request as DeployPatch to Resource URI /api/candidate/ on endpoint PCFRestEndpoint using http method PATCH using message reference DEPLOY_SETUP with the following attributes:
       | attribute                    | value                           |
       | {HEADER}Content-Type         | application/vnd.yang.data+json  |
       | {HEADER}Accept               | application/vnd.yang.data+json  |
    Then I receive a REST Response for DeployPatch and validate using following attributes:
      | attribute               | value          |
      | {HTTPStatusCode}        | 204            |

    When I send a REST Request as DeployPost to Resource URI /api/candidate/_commit on endpoint PCFRestEndpoint using http method POST with the following attributes:
       | attribute                    | value                           |
       | {HEADER}Content-Type         | application/vnd.yang.data+json  |
       | {HEADER}Accept               | application/vnd.yang.data+json  |
    Then I receive a REST Response for DeployPost and validate using following attributes:
      | attribute                | value              |
      | {HTTPStatusCode}         | 204                |
      
    Then I wait for {config.global.constant.twohundred.forty} seconds		
    Then I wait for {config.global.constant.onehundred.eighty} seconds		
    
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

    #Iteration2 Steps
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
