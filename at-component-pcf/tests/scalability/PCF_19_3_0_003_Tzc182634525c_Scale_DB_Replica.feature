################################################################################################
# Date: <30/04/2019> Version: <Initial version: 19.3.0> Create by <Sandeep Talukdar, santaluk>
################################################################################################
@PCF @Scale @Tzc182634525c @P2 

Feature: PCF_19_3_0_003_Tzc182634525c_Scale_DB_Replica

  Scenario: Scale DB Replica 30 MINs- Two Iterations

    Given the connection to QNS is established for SSH,WSClient,ToolAgent successfully

    Given the SFTP push of file {config.global.workspace.library.location-scripts-templates}pcf_resiliency_config.xml to /root/ at SITEHOST is successful

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
      | Scale DB Replica 30 MINs- Two Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  

    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    #CICD Test report end

    When I execute the SSH command "config ; db global-settings db-replica {Constant.InitDbRepCnt} ; commit ; end" at CLIPcfOPSCenter  

    Then I wait for {config.global.constant.onehundred.eighty} seconds

    Given the arming of teardown steps are done

    #External PreRun File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}PreRun.feature

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

	Then I wait for {config.scenario.exec-params.small-benchmark-interval} seconds

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

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never db-admin-[0-9] | wc -l at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value           |
      | (.*)           | DbReplicaCount  |

   Given I expect the next test step to execute if ({SSH.DbReplicaCount} > 1)
   
    When I execute the SSH command {config.global.command.opsCenter.show-running-config} db global-settings at CLIPcfOPSCenter
    Then I save the SSH response in the following variables:
      | attribute          | value           |
      | (.)                | dBReplicaCnt    |         
    When I execute using handler SITEHOST the SSH command echo "{SSH.dBReplicaCnt}" | awk '{print $NF}'
    Then I save the SSH response in the following variables:
      | attribute         | value        |
      | {Regex}(\d+)      | dBReplicaCnt |

   Given I define the following constants:
      | name                | value                 |
      | InitDbRepCnt        | {SSH.dBReplicaCnt}    |

   Given I expect the next test step to execute otherwise

   Given I define the following constants:
      | name                | value   |
      | InitDbRepCnt        | 1       |

   Given I end the if

    When I execute using handler K8SMaster the SSH shell command echo $(({Constant.InitDbRepCnt} + 2))
    Then I save the SSH response in the following variables:
      | attribute | value               |
      | (.*)      | incrDataStoreRepCnt | 

    When I execute the SSH command "config ; db global-settings db-replica {SSH.incrDataStoreRepCnt} ; commit ; end" at CLIPcfOPSCenter

    Then I wait for {config.global.constant.twohundred.forty} seconds		
    
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never db-s at K8SMaster

    When I execute the SSH command {config.global.command.opsCenter.show-running-config} db global-settings at CLIPcfOPSCenter
    Then I save the SSH response in the following variables:
      | attribute          | value           |
      | (.)                | dBReplicaCnt    |         
    When I execute using handler SITEHOST the SSH command echo "{SSH.dBReplicaCnt}" | awk '{print $NF}'
    Then I save the SSH response in the following variables:
      | attribute         | value        |
      | {Regex}(\d+)      | dBReplicaCnt |
      
    Then I validate the following attributes:
  	  | attribute             | value                            |
   	  | {SSH.dBReplicaCnt}    | EQUAL({SSH.incrDataStoreRepCnt}) |

    ## Check status of the deployment.
    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLIPcfOPSCenter
		Then I save the SSH response in the following variables:
			| attribute                             | value           |
			| (system status percent-ready\s+\S+)   | depPerReady     |
    When I execute using handler SITEHOST the SSH command "echo {SSH.depPerReady}"
    Then I save the SSH response in the following variables:
      | attribute             | value       |
      | {Regex}(\d+.\d+)      | depPerReady |
    Then I validate the following attributes:
  	  | attribute         | value                                            |
   	  | {SSH.depPerReady} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) |

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

	  Then I wait for {config.scenario.exec-params.small-benchmark-interval} seconds

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

    When I execute the SSH command "config ; db global-settings db-replica {Constant.InitDbRepCnt} ; commit ; end" at CLIPcfOPSCenter  

    Then I wait for {config.global.constant.twohundred.forty} seconds		

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never db-s at K8SMaster

    When I execute the SSH command {config.global.command.opsCenter.show-running-config} db global-settings at CLIPcfOPSCenter
    Then I save the SSH response in the following variables:
      | attribute          | value           |
      | (.)                | dBReplicaCnt    |         
    When I execute using handler SITEHOST the SSH command echo "{SSH.dBReplicaCnt}" | awk '{print $NF}'
    Then I save the SSH response in the following variables:
      | attribute         | value        |
      | {Regex}(\d+)      | dBReplicaCnt |
    Then I validate the following attributes:
  	  | attribute             | value                          |
   	  | {SSH.dBReplicaCnt}    | EQUAL({Constant.InitDbRepCnt}) |
 
    ## Check status of the deployment.
    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLIPcfOPSCenter
		Then I save the SSH response in the following variables:
			| attribute                             | value           |
			| (system status percent-ready\s+\S+)   | depPerReady     |
    When I execute using handler SITEHOST the SSH command "echo {SSH.depPerReady}"
    Then I save the SSH response in the following variables:
      | attribute             | value       |
      | {Regex}(\d+.\d+)      | depPerReady |
    Then I validate the following attributes:
  	  | attribute         | value                                            |
   	  | {SSH.depPerReady} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) |

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

    Then I wait for {config.scenario.exec-params.small-benchmark-interval} seconds

	  When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time | 

    #Iteration2 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature

    ###############################Validations######################################    

    #CICD report start#####################
    Given I define the following constants:
      | name        | value                                 |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | Scale DB Replica 30 MINs- Two Iterations | Pass |
    #CICD report end#####################
