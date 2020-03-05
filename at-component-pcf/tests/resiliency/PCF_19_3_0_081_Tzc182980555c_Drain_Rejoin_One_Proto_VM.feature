####################################################################################################
# Date: <08/23/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Resiliency @Tzc182980555c @P1 @PcfResP1Set2 

Feature: PCF_19_3_0_081_Tzc182980555c_Drain_Rejoin_One_Proto_VM

Scenario: Drain_Rejoin_One_Proto_VM - One Iterations

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
      | Drain_Rejoin_One_Proto_VM - One Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  

    ##GET name of the node.
    When I execute the SSH command {config.global.commands.k8s.getprotonodenames} | head -1 at K8SMaster
    
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | NodeName |
      
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    When I execute the SSH command "kubectl uncordon {SSH.NodeName}" at K8SMaster

    Then I wait for {config.global.constant.ninety} seconds

    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    #CICD Test report end

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

    ##Drain the proto VM
    When I execute the SSH command "kubectl drain {SSH.NodeName} --ignore-daemonsets --delete-local-data" at K8SMaster

    Then I wait for {config.global.constant.ninety} seconds

    When I execute the SSH command "kubectl get nodes | grep {SSH.NodeName}" at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string              | occurrence |
      | SchedulingDisabled  | present    |

    When I execute the SSH command "{config.global.commands.k8s.pod-list-pcf} -o wide | grep {SSH.NodeName} | grep -v network | wc -l" at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string      | value         | occurrence |
      | {Regex}(.*) | lesserthan(1) | present    |

    Then I wait for {config.global.constant.onehundred.twenty} seconds

    ##Restart the K8s Node 
    When I execute the SSH command "kubectl uncordon {SSH.NodeName}" at K8SMaster

    Then I wait for {config.global.constant.ninety} seconds

    When I execute the SSH command "kubectl get nodes | grep {SSH.NodeName}" at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string              | occurrence |
      | SchedulingDisabled  | absent     |

    When I execute the SSH command "{config.global.commands.k8s.pod-list-pcf} -o wide | grep {SSH.NodeName} | wc -l" at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string      | value          | occurrence |
      | {Regex}(.*) | greaterthan(0) | present    |

    Then I wait for {config.global.constant.onehundred.twenty} seconds

    ####Capture End Time
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
      | name        | value                                 |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | Drain_Rejoin_One_Proto_VM - One Iterations | Pass |
    #CICD report end#####################
