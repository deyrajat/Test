###########################################################################################
# Date: <08/01/2020> Version: <Initial version: 19.5.0> Create by <Sandeep Talukdar, santaluk>
###########################################################################################
@PCF @PCF_Canary @Tzc182637385c

Feature: PCF_19_5_0_006_Tzc182637385c_Canary_Upgrade_Downgrade_Dnn

 Scenario: PCF Canary_Upgrade_Downgrade_Dnn
 
    Given the connection to QNS is established for SSH,WSClient,ToolAgent successfully
    
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
      | PCF Canary_Upgrade_Downgrade_Dnn| Fail |
    #CICD Test report end
    
    ##GET IP Address of the smiopscenter
    When I execute the SSH command k3s kubectl get svc -n smi -o wide | grep ^ops-center | awk '{print $3}' at SMIDeployer
    Then I save the SSH response in the following variables:
      | attribute |  value           |
      | (.*)      |  smiopscenterip  |

    ### Create the SSH instance for chaosopscenterip
    Given I configure a SSH instance with following attributes:
      |  string                   |  value                                |
      |  InstanceName             |  SMIDeployerOpsCenter                 |
      |  UserName                 |  {config.CliOPSCenter.SSH.UserName}   |
      |  Password                 |  {config.CliOPSCenter.SSH.Password}   |
      |  Port                     |  2024                                 |
      |  EndpointIpAddress        |  {SSH.smiopscenterip}                 |
      |  Route                    |  SMIDeployer-->SMIDeployerOpsCenter   |
    
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown
    
    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature
    
    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    #CICD Test report end
    
    ## Transfer the full Traffic to old engine
    When I execute the SSH command {config.global.scenario.engine.default-rule-default} at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.twenty} seconds
    
    When I execute the SSH command {config.global.scenario.engine.rule-canary-remove} at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.twenty} seconds
    
    When I execute the SSH command {config.global.scenario.canary.engine-delete-command} at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.onehundred.twenty} seconds
    
    When I execute the SSH command {config.global.scenario.canary.repo-cmd-remove} at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.twenty} seconds
    
    ##### Disable SVN    
    When I execute the SSH command config ; {config.global.command.opsCenter.system-disable-svn} ; commit ; end at CLIPcfOPSCenter
    
    Then I wait for {config.global.constant.onehundred.eighty} seconds

    When I execute the SSH command {config.global.scenario.build.delete} {SSH.PCFPackageName} at SMIDeployerOpsCenter
    
    Then I wait for {config.global.constant.onehundred.twenty} seconds
    
    Given I delete SSH instance SMIDeployerOpsCenter

    Given the arming of teardown steps are done
    
    #External PreRun File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}PreRun.feature

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.small-benchmark-interval} seconds

    When I execute using handler K8SMaster the SSH shell command "date +%s"
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
    
    Given I execute the steps from {config.global.workspace.library.location-features-sc-upgrade}CanaryConfiguration.feature
    
    #### Publish the PB
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
    
    Given I wait for {config.global.constant.twenty} seconds
    
    #### configure the new test specific traffic rule 
    When I execute the SSH command config ; {config.global.scenario.engine.rule-name-dnn} ; commit ; end at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.ninety} seconds
    
    ### Show the traffic rule
    When I execute the SSH command {config.global.scenario.engine.rule-show} at CLIPcfOPSCenter
    When I execute the SSH command {config.global.scenario.engine.rule-show} at CLIPcfOPSCenter
    Then I receive a SSH response and check the presence of following strings:
      | string                                               | occurrence  |
      | {config.global.scenario.canary.engine-group-name}    | present     |      
    
    ## Transfer the full Traffic to new engine
    When I execute the SSH command {config.global.scenario.engine.default-rule-supi} at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.thirty} seconds
    
    When I execute the SSH command {config.global.scenario.engine.rule-canary-remove} at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.thirty} seconds
    Given I wait for {config.global.constant.ninety} seconds  
    
    When I execute the SSH command {config.global.scenario.engine.rule-show} at CLIPcfOPSCenter  
    
    ####Capture End Time after Canary Downgrade
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
     
    ####Check Errors and Timeouts during Canary Downgrade
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}EventErrorCaptureAndChecks.feature

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.small-benchmark-interval} seconds

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #Iteration1 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration1_Steps.feature
    
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
      
    #### Transfer some traffic to upgraded engine
    When I execute the SSH command config ; {config.global.scenario.engine.rule-name-default-dnn} ; commit ; end at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.ninety} seconds
    
    ### Show the traffic rule
    When I execute the SSH command {config.global.scenario.engine.rule-show} at CLIPcfOPSCenter
    When I execute the SSH command {config.global.scenario.engine.rule-show} at CLIPcfOPSCenter
    Then I receive a SSH response and check the presence of following strings:
      | string                   | occurrence  |
      | {config.Engine.Group}    | present     |    
    
    ## Transfer the full Traffic to old engine
    When I execute the SSH command {config.global.scenario.engine.default-rule-default} at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.thirty} seconds
    
    When I execute the SSH command {config.global.scenario.engine.rule-canary-remove} at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.thirty} seconds
    Given I wait for {config.global.constant.ninety} seconds 
    
    When I execute the SSH command {config.global.scenario.engine.rule-show} at CLIPcfOPSCenter

    ####Capture End Time after Canary Upgrade
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
   
    ####Check Errors and Timeouts during Canary Upgrade
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}EventErrorCaptureAndChecks.feature

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.small-benchmark-interval} seconds

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #Iteration2 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature
         
    #CICD report start#####################
    Given I define the following constants:
      | name        | value                                 |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | PCF Canary_Upgrade_Downgrade_Dnn             | Pass |
    #CICD report end#####################