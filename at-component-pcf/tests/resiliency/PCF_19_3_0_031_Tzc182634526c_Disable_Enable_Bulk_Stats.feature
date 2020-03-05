####################################################################################################
# Date: <24/05/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Resiliency @Tzc182634526c @PCF_Resi_Cfg @P2 @PcfResP2Set2


Feature: PCF_19_3_0_031_Tzc182634526c_Disable_Enable_Bulk_Stats

  Scenario: Disable Enable Bulk Stats 30 MINs- Single Iterations

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
      | Disable Enable Bulk Stats 30 MINs- Single Iterations | Fail |
    #CICD Test report end
    
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown
    
    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    ## Enable Bulk Status
    When I execute the SSH command "config ; bulk-stats enable true ; commit ; end" at CLICeeOPSCenter

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

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.cee} | grep --color=never bulk-stats | wc -l at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | BulStsPodCount  |

	 	## Proceed if bulk-stats pod exists.
 		Given I expect the next test step to execute if '("{SSH.BulStsPodCount}" > 0)'
 		
 		## Take bulk-stats pod name before disable the feature.
 		When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.cee} | grep --color=never bulk-stats | awk ' FNR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
    	| attribute | value              |
      | (.*)      | BulStsPodName |

   	When I execute the SSH command "{config.global.command.opsCenter.show-running-config} bulk-stats enable" at CLICeeOPSCenter
   	Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | bulk-stats enable true						| present    |

   	When I execute the SSH command "config ; bulk-stats enable false ; commit ; end" at CLICeeOPSCenter

    Then I wait for {config.global.constant.twohundred.forty} seconds

   	When I execute the SSH command "{config.global.command.opsCenter.show-running-config} bulk-stats enable" at CLICeeOPSCenter
   	Then I receive a SSH response and check the presence of following strings:
      | string                                                      | occurrence |
      | bulk-stats enable false																			| present    |

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.cee} | grep --color=never bulk-stats | wc -l at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
    	| String                                    | occurrence       |
    	| 0																					| present          |

    When I execute the SSH command "config ; bulk-stats enable true ; commit ; end" at CLICeeOPSCenter

    Then I wait for {config.global.constant.twohundred.forty} seconds

   	When I execute the SSH command "{config.global.command.opsCenter.show-running-config} bulk-stats enable" at CLICeeOPSCenter
   	Then I receive a SSH response and check the presence of following strings:
      | string                                                      | occurrence |
      | bulk-stats enable true																			| present    |
      
    ## Capture pod start time in EPOCH.
    When I execute the SSH command date -u --date="$(kubectl describe pod {SSH.BulStsPodName} -n {config.sut.k8s.namespace.cee} | grep "Start Time:" | awk '{$1="";$2="";print}')" +"%s" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                |
      | (.*)      | pod_start_time       |

     ## Check pod start time is after pod deletion time.
     Given I validate the following attributes:
	     |   attribute                 | value                           |
	     |  {SSH.time_before_pod_del}  | LESSTHAN({SSH.pod_start_time})  |

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

   Given I expect the next test step to execute otherwise

   	Given I print: "bulk-stats pod not present."

   Given I end the if

    #CICD report start#####################
    Given I define the following constants:
      | name        | value                                    |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | Disable Enable Bulk Stats 30 MINs- Single Iterations | Pass |
    #CICD report end#####################
