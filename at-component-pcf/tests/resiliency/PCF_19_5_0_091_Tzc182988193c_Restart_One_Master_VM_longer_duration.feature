####################################################################################################
# Date: <04/06/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Resiliency @Tzc182988193c @P3 

Feature: PCF_19_5_0_091_Tzc182988193c_Restart_One_Master_VM_longer_duration

  Scenario: Restart_One_Master_VM_longer_duration
  
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
      | Restart_One_Master_VM_longer_duration | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  
    
    When I execute the SSH command "hostname" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | HostName |
      
    ### Fetch master which is not same as the master where we are running the action.sh  
    When I execute the SSH command {config.global.commands.k8s.getmasternodenames} | grep -v {SSH.HostName} | head -1 at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | NodeName |
    
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    #####Powered up master vm
    When I execute using handler SITEHOST the parameterized command /root/action.sh {config.scenario.exec-params.sut.platform-type} {config.sut.blades.sshpassowrd} {config.sut.vm.sshpassword} 1 0 with following arguments:
      | attribute | value                             |
      | F         | vm_power_on                       |
      | V         | {SSH.NodeName}                    |
      | O         | {config.sut.ospd.ipaddress}      |
      | E         | {config.sut.esc.ipaddress}       |
      | P         | {config.sut.esc.sshpassowrd} |
      | K         | /root/{SSH.smiKeyName}            |
      | U         | {config.sut.k8smaster.default.user}      |
    Then I receive a SSH response and check the presence of following strings:
      | string                                | occurrence |
      | VM in Active state as expected        | present    |
      | VM is not in Active state as expected | absent     |
    
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
      
    ##Perform Master node power down to trigger
    When I execute using handler SITEHOST the parameterized command /root/action.sh {config.scenario.exec-params.sut.platform-type} {config.sut.blades.sshpassowrd} {config.sut.vm.sshpassword} 1 0 with following arguments:
      | attribute | value                             |
      | F         | vm_power_off                      |
      | V         | {SSH.NodeName}                    |
      | O         | {config.sut.ospd.ipaddress}      |
      | E         | {config.sut.esc.ipaddress}       |
      | P         | {config.sut.esc.sshpassowrd} |
      | K         | /root/{SSH.smiKeyName}            |
      | U         | {config.sut.k8smaster.default.user}      |
    Then I receive a SSH response and check the presence of following strings:
      | string                                  | occurrence |
      | VM in Shutdown state as expected        | present    |
      | VM is not in Shutdown state as expected | absent     |
      
    Given I define the following constants:
      | name             | value        |
      | VMShutdown       | yes          |
      
    Given I loop {config.scenario.exec-params.vm.shutdown-iteration} times  
    
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
      
			Then I wait for {config.scenario.exec-params.vm.shutdown-duration} seconds		
			
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
			
		And I end loop 
			
    #####Powered up master vm
    When I execute using handler SITEHOST the parameterized command /root/action.sh {config.scenario.exec-params.sut.platform-type} {config.sut.blades.sshpassowrd} {config.sut.vm.sshpassword} 1 0 with following arguments:
      | attribute | value                             |
      | F         | vm_power_on                       |
      | V         | {SSH.NodeName}                    |
      | O         | {config.sut.ospd.ipaddress}      |
      | E         | {config.sut.esc.ipaddress}       |
      | P         | {config.sut.esc.sshpassowrd} |
      | K         | /root/{SSH.smiKeyName}            |
      | U         | {config.sut.k8smaster.default.user}      |
    Then I receive a SSH response and check the presence of following strings:
      | string                                | occurrence |
      | VM in Active state as expected        | present    |
      | VM is not in Active state as expected | absent     |
    	
    Then I wait for {config.global.constant.onehundred.twenty} seconds	
    
    Given I define the following constants:
      | name             | value        |
      | VMShutdown       | no           |	

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
      | Restart_One_Master_VM_longer_duration | Pass |
    #CICD report end#####################

    