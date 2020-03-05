####################################################################################################
# Date: <08/28/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Chaos @Tzc182980508c @P1

Feature: PCF_19_5_0_003_Tzc182980508c_N7_Chaos_test_High_Chaos

Scenario: N7_Chaos_test_High_Chaos- One Iterations

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
      | N7_Chaos_test_High_Chaos - One Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  

    ## Push Chaos Script into master node.
    Given the SFTP push of file "{Config.global.scenario.chaos.utilities-dir}setPodPriority.sh" to {config.global.remotepush.location.utilities} at K8SMaster is successful
    When I execute using handler K8SMaster the SSH shell command "sudo chmod +x {config.global.remotepush.location.utilities}setPodPriority.sh"

    ##GET IP Address of the N7 interface from CLI OPS CENTER
    When I execute the SSH command "kubectl get svc -n {config.sut.k8s.namespace.chaos} | grep 2024 | awk '{print $3}'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute |  value             |
      | (.*)      |  chaosopscenterip  |

    ### Get hostname of the VM associated with VIP
    Given I configure a SSH instance with following attributes:
      |  string                   |  value                                  |
      |  InstanceName             |  CHAOSINSTANCE                          |
      |  UserName                 |  {config.CliOPSCenter.SSH.UserName}   |
      |  Password                 |  {config.CliOPSCenter.SSH.Password}   |
      |  Port                     |  2024                                   |
      |  EndpointIpAddress        |  {SSH.chaosopscenterip}                 |
      |  Route                    |  K8SMaster-->CHAOSINSTANCE              |

    ##Teardown Steps
    Given the below steps are armed to be executed during teardown
    
    Given I execute the SSH command {config.global.command.opsCenter.chaos-end-test} at CHAOSINSTANCE

    Given I delete SSH instance CHAOSINSTANCE

    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature
    
    ### Check the pods that are not running
    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep -v Running at K8SMaster
    When I execute the SSH command {config.global.commands.k8s.pod-list-cee} | grep -v Running at K8SMaster

    ##### Describe the not running nodes 
    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep -v Running | grep -v NAME | awk '{print $1}' | xargs kubectl describe pod -n {config.sut.k8s.namespace.pcf} at K8SMaster
    When I execute the SSH command {config.global.commands.k8s.pod-list-cee} | grep -v Running | grep -v NAME | awk '{print $1}' | xargs kubectl describe pod -n {config.sut.k8s.namespace.cee} at K8SMaster
    
    #### Delete the pods that are not running 
    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep -v Running | grep -v NAME | awk '{print $1}' | xargs kubectl delete pod -n {config.sut.k8s.namespace.pcf} at K8SMaster
    When I execute the SSH command {config.global.commands.k8s.pod-list-cee} | grep -v Running | grep -v NAME | awk '{print $1}' | xargs kubectl delete pod -n {config.sut.k8s.namespace.cee} at K8SMaster

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    #CICD Test report end

    Given the arming of teardown steps are done

    When I execute the SSH command {config.global.remotepush.location.utilities}/setPodPriority.sh {config.sut.k8s.namespace.pcf} {config.sut.k8s.namespace.cee} high at K8SMaster

	  Given I loop 5 times

        ## Check status of the deployment.
        When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLIPcfOPSCenter
        Then I receive a SSH response and check the presence of following strings:
          | string                         | occurrence  |
          | system status deployed true    | present     |
        When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLIPcfOPSCenter
        Then I save the SSH response in the following variables:
          | attribute                             | value           |
          | (system status percent-ready\s+\S+)   | depPerReady     |
        When I execute using handler SITEHOST the SSH command "echo {SSH.depPerReady}"
        Then I save the SSH response in the following variables:
          | attribute             | value       |
          | {Regex}(\d+.\d+)      | depPerReady |

			  Given I break loop if {SSH.depPerReady} >= {config.global.thresholds.system.status-ready-expectedpercentage}

			  Given I wait for {config.global.constant.sixty} seconds

		And I end loop 

    #External PreRun File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}PreRun.feature

    #Get the current Pod Restart count
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | pod_res_cnt_time |

    Then I wait for {config.global.constant.sixty} seconds

    When I execute the SSH command echo '&start={SSH.pod_res_cnt_time}&end={SSH.pod_res_cnt_time}&step=1' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value     |
      | (.*)      | TimeQuery |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Pod_Restart_count}{SSH.TimeQuery}" {config.Grafana.Authorization1} {config.Value.Extrator} at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | presentRestartCnt |

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

    ### Start the chaos operation
    Given I execute the SSH command {config.global.scenario.chaos.command-start-high-priority} at CHAOSINSTANCE

    Then I wait for {config.global.constant.sixty} seconds

    When I execute the SSH command {config.global.command.opsCenter.chaos-system-status} at CHAOSINSTANCE
    Then I receive a SSH response and check the presence of following strings:
      | string                           | occurrence |
      | Is Chaos test running?  yes      | present    |
      | Is Chaos test running?  no       | absent     |

    #### Perform Chaos Status Check
    Given I execute the steps from {config.global.scenario.chaos.lib-dir}CheckChaosStatus.feature

    Then I wait for {config.scenario.exec-params.wait} seconds

    Given I execute the SSH command {config.global.command.opsCenter.chaos-end-test} at CHAOSINSTANCE

    Then I wait for {config.scenario.exec-params.wait} seconds

    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep -v Running at K8SMaster
    When I execute the SSH command {config.global.commands.k8s.pod-list-cee} | grep -v Running at K8SMaster

    When I execute the SSH command {config.global.command.opsCenter.chaos-system-status} at CHAOSINSTANCE

    When I execute the SSH command {config.global.command.opsCenter.chaos-system-status} at CHAOSINSTANCE
    Then I receive a SSH response and check the presence of following strings:
      | string                          | occurrence |
      | Is Chaos test running?  yes     | absent     |
      | Is Chaos test running?  no      | present    |
      | Is system ok? yes               | present    |

    #Get the current Pod Restart count and compare
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | pod_res_cnt_time |

    When I execute the SSH command echo '&start={SSH.pod_res_cnt_time}&end={SSH.pod_res_cnt_time}&step=1' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value     |
      | (.*)      | TimeQuery |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Pod_Restart_count}{SSH.TimeQuery}" {config.Grafana.Authorization1} {config.Value.Extrator} at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value         |
      | (.*)      | newRetCnt     |
    Then I validate the following attributes:
      | attribute             | value                         |
      | {SSH.presentRestartCnt}   | NOTEQUAL({SSH.newRetCnt}) |

    ####Capture End Time after Chaos
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

    #CICD report start#####################
    Given I define the following constants:
      | name        | value                                    |
      | ACstatus    | {config.Validation.Success.Result.Value} |
    Then I update report for table {Constant.testtype} with the following details:
      | N7_Chaos_test_High_Chaos - One Iterations | Pass |
    #CICD report end#####################
