####################################################################################################
# Date: <15/05/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Resiliency @Tzc182952570c @PCF_Resi_CDL @P2 @PcfResP2Set2 

Feature: PCF_19_3_0_065_Tzc182952570c_cdl_index_session_pod

  Scenario: cdl_index_session_pod Pod Delete 30 MINs- Two Iterations

    Given the connection to QNS is established for SSH,WSClient,ToolAgent successfully
    
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
      | cdl_index_session_pod Delete - Two Iterations | Fail |
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

    When I execute the SSH command "date -u '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value               |
      | (.*)      | time_before_pod_del |

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

    ##Perform cdl_index_session_pod delete
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never cdl-index-session | awk ' FNR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | PodName  |

    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | PodResstartCount |

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

    ##Get End hour
    When I execute the SSH command date -d "+3 minutes" +%H | awk '{$0=int($0)}1' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value    |
      | (.*)      | EndHour  |

    When I execute the SSH command date -d "+3 minutes" +%M | awk '{$0=int($0)}1' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value       |
      | (.*)      | EndMinutes  |

    When I execute using handler K8SMaster the SSH shell command "kubectl delete pod {SSH.PodName} -n {config.sut.k8s.namespace.pcf}"

	  Then I wait for {config.global.constant.twohundred.forty} seconds

    ## Check deleted pod is Running
    When I execute the SSH command kubectl describe pod {SSH.PodName} -n {config.sut.k8s.namespace.pcf} | grep "Status:" | awk '{print $2}' at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string    | occurrence  |
      | Running   | present     |

    ## Capture pod start time in EPOCH.
    When I execute the SSH command date -u --date="$(kubectl describe pod {SSH.PodName} -n {config.sut.k8s.namespace.pcf} | grep "Start Time:" | awk '{$1="";$2="";print}')" +"%s" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | pod_start_time	   |

     ## Check pod start time is after pod deletion time.
     Given I validate the following attributes:
	     |   attribute                 | value                           |
	     |  {SSH.time_before_pod_del}	 | LESSTHAN({SSH.pod_start_time})  |
	  When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf}  | grep -v Running at K8SMaster

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

    #CICD report start#####################
    Given I define the following constants:
      | name        | value                                    |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | cdl_index_session_pod Delete - Two Iterations | Pass |
    #CICD report end#####################
