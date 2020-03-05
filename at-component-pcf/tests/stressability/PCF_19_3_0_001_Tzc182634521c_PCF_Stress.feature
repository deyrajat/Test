################################################################################################
# Date: <13/02/2018> Version: <Initial version: 18.0.1> $1Create by <Sandeep Talukdar, santaluk>
################################################################################################
@PCF @Stress @Tzc182634521c @P2

Feature: PCF_19_3_0_001_Tzc182634521c_PCF_Stress

  Scenario: PCF Stress test - Two Iterations

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
      | PCF Servivce VM Stress test | Fail |
    #CICD Test report end

    Given I define the following constants:
      | name                    | value                    |
      | stepUpIndex             | 2                        |
      | stepDownIndex           | 2                        |

    When I execute using handler K8SMaster the SSH shell command "echo $(( {config.ClientCfgCount} - {Constant.stepUpIndex} + 1 )) "
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | StressCfgCount | 

    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    #CICD Test report end

    Given the arming of teardown steps are done

    ## Killing the Traffic so that the ToolAgent instances are created
    Given I execute the SSH command "pkill -f ToolAgent" at ToolAgentHost
    Given I execute the SSH command "pkill -f lattice" at ToolAgentHost
    Given I execute the SSH command "pkill -f cli" at ToolAgentHost

    Given I execute the SSH command "rm -rf ToolAgent.*" at ToolAgentHost
    Given I execute the SSH command "rm -rf core.*" at ToolAgentHost  
    When I execute the SSH command "rm -rf /tmp/taas/*" at ToolAgentHost

    #External PreRun File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}PreRun.feature

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.benchmark-interval} seconds

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #Get Benchmark values
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Benchmark.feature

    Given I loop {SSH.StressCfgCount} times

    When I update the {config.{config.tools.caliper.instance-arrayprefix}{Constant.stepUpIndex}} variable named COMMON_RATE to {config.{config.global.scenario.stress.toolagent-arrayprefix}{Constant.stepUpIndex}} in {config.global.scenario.stress.traffic-change-time} seconds interval with step value 10 at ToolAgent{Constant.stepUpIndex}  

    Then I increment Constant.stepUpIndex by 1

    And I end loop

    Then I wait for {config.scenario.exec-params.execution-duration} seconds

    When I execute the SSH command {config.sut.k8smaster.home.directory}/cpu_Load_Check.sh {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string                 | occurrence |
      | System is stressed     | present    |
      | System is not Stressed | absent     |
      
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
      | Found logs for Rule           | present    |
      #| Logs not found for Rule       | absent     |

    Given I loop {SSH.StressCfgCount} times

    When I update the {config.{config.tools.caliper.instance-arrayprefix}{Constant.stepDownIndex}} variable named COMMON_RATE to {config.{config.tools.caliper.callrate-arrayprefix}{Constant.stepDownIndex}} in {config.global.scenario.stress.traffic-change-time} seconds interval with step value 10 at ToolAgent{Constant.stepDownIndex}  

    Then I increment Constant.stepDownIndex by 1

    And I end loop

    Then I wait for {config.scenario.exec-params.cooloff-duration} seconds

    When I execute the SSH command {config.sut.k8smaster.home.directory}/cpu_Load_Check.sh {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string                 | occurrence |
      | System is stressed     | absent     |
      | System is not Stressed | present    |

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.benchmark-interval} seconds

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                |
      | (.*)      | event_end_epoch_time |

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time | 

    #Iteration1 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration1_Steps.feature

    #CICD report start#####################
    Given I define the following constants:
      | name        | value                                    |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | PCF Servivce VM Stress test | Pass |
    #CICD report end##################### 
