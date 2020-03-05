#####################################################################################################
# Date: <24/10/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat>  #
#####################################################################################################
@PCF @P2 @Noisy_Scenario @Noisy_IO @Tzc182980503c @ThreadDump

Feature: PCF_008_Tzc182980503c_Threaddump_On_Service_VM

  Scenario: Run Threaddump On Service VM - One Iterations

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
      | Run Threaddump On Service VM - One Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  
    
    ##Get Policy Engine Pod Name
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never pcf-engine-{config.sut.k8s.namespace.pcf}-pcf-engine-app | awk ' FNR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | PodName  |
     
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown
    
    ## Remove THREADDUMP file.
    When I execute using handler K8SMaster the SSH shell command "rm -f {config.global.scenario.noisy.threaddump-file} 2> /dev/null"
    
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
            
    #Get PID of the JAVA Process  
    When I execute using handler K8SMaster the SSH shell command "kubectl exec --namespace={config.sut.k8s.namespace.pcf} {SSH.PodName} -- {config.global.scenario.noisy.command-top-java-pid}"
    Then I save the SSH response in the following variables:
      | attribute | value     |
      | (\d+)$      | Pid     |
   
   ## Remove THREADDUMP file if exists
   When I execute using handler K8SMaster the SSH shell command "rm -f {config.global.scenario.noisy.threaddump-file} 2> /dev/null"
     
    ### Start the THREADDUMP    
    When I execute using handler K8SMaster the SSH shell command "kubectl exec --namespace={config.sut.k8s.namespace.pcf} {SSH.PodName} -- {config.global.scenario.noisy.command-start-threaddump} {SSH.Pid} > {config.global.scenario.noisy.threaddump-file} 2>&1"
            
    Then I wait for {config.global.constant.onehundred.twenty} seconds
    
    When I execute using handler K8SMaster the SSH shell command "[ -s {config.global.scenario.noisy.threaddump-file} ] && echo 'File not empty' || echo 'File empty'"
    Then I receive a SSH response and check the presence of following strings:
      | string             | occurrence |
      |File not empty      | present    |
      |File empty          | absent     |   
            
   ## Remove THREADDUMP file
   When I execute using handler K8SMaster the SSH shell command "rm -f {config.global.scenario.noisy.threaddump-file} 2> /dev/null"
            
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

    ####Check Errors and Timeouts
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
      | name        | value                                 |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | Run Threaddump On Service VM - One Iterations | Pass |
    #CICD report end#####################
