################################################################################################
# Date: <30/04/2019> Version: <Initial version: 19.3.0> Create by <Sandeep Talukdar, santaluk>
################################################################################################
@PCF @Resiliency @Tzc182634516c @PCF_Resi_Engine @P2 @PcfResP2Set1 @TB6P2Rerun

Feature: PCF_19_3_0_002_Tzc182634516c_Policy_Engine_Pod_Delete

  Scenario: Policy Engine Pod Delete 30 MINs- One Iterations

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
      | Policy Engine Pod Delete - One Iterations | Fail |
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
    
    ##Perform Policy Builder Pod delete  
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never pcf-engine-{config.sut.k8s.namespace.pcf}-pcf-engine-app | awk ' FNR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | PodName  |
      
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
      
    When I execute using handler K8SMaster the SSH shell command "kubectl delete pod {SSH.PodName} -n {config.sut.k8s.namespace.pcf}"

	  Then I wait for {config.global.constant.twohundred.forty} seconds		
    
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never {SSH.PodName} at K8SMaster
	  Then I receive a SSH response and check the presence of following strings:
		  | string           | occurrence |
      | {SSH.PodName}    | absent     |
     
    ####Capture End Time after Delete
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
      | Policy Engine Pod Delete - One Iterations | Pass |
    #CICD report end#####################
