#####################################################################################################
# Date: <13/11/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat>  #
#####################################################################################################
@PCF @P1 @Noisy_Scenario @Noisy_Memory @Tzc182980490c  

Feature: PCF_002_Tzc182980490c_Noisy_Memory_Session_VM

  Scenario: Noisy Memory Test On Session VM - Two Iterations
    
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
      | Noisy Memory Test On Session VM - Two Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  
    
  	## Push Noisy Script into master node.
    When I execute using handler K8SMaster the SSH shell command "mkdir -p {config.global.scenario.noisy.remotepush-location}"
    Given the SFTP push of file "{Config.global.scenario.noisy.utilities-dir}{config.global.scenario.noisy.mem-file}" to "{config.global.scenario.noisy.remotepush-location}" at K8SMaster is successful
    When I execute using handler K8SMaster the SSH shell command "sudo chmod +x {config.global.scenario.noisy.remotepush-location}{config.global.scenario.noisy.mem-file}"
    
    # Get Node name
   	When I execute the SSH command {config.global.commands.k8s.getsessionnodenames} | head -1 at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | NodeName |
      
    # Get Node IP  
    When I execute the SSH command {config.global.commands.k8s.node-list} | grep {SSH.NodeName}  | awk '{print $6}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | NodeIP   |
      
    ### Create Dynamic SSH Instance With the NODE
    Given I configure a SSH instance with following attributes:
      |  string             |  value                            |
      |  InstanceName       |  NoisyInstance                    |
      |  UserName           |  {config.K8SMaster.SSH.UserName}  |
      |  KeyFile            |  {config.sut.SMIDeployer.SSH-KeyFile}   |
      |  EndpointIpAddress  |  {SSH.NodeIP}                 	  |
      
    ## Upload Stress Script to the Node
   	When I execute using handler K8SMaster the SSH shell command "scp {config.global.scenario.noisy.remotepush-location}{config.global.scenario.noisy.mem-file} {SSH.NodeName}:"
    
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown
    
    ## Stop existing memory stress Process
		When I execute the SSH command "{config.global.scenario.noisy.command-stop-mem}" at NoisyInstance
	  
	  ### Delete Stressmemory file from the Node
	  When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} rm -f {config.global.scenario.noisy.mem-file}" at K8SMaster
	  
	  ### Delete Stressmemory file from the MASTER Node
		Then I execute using handler K8SMaster the SSH shell command  "rm -rf {config.global.scenario.noisy.remotepush-location}"
		
		Given I delete SSH instance NoisyInstance

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
      
   ################## Noisy Scenario Start ######################################
	  ## Required memory to reach the limit provided by user.
    When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} {config.global.scenario.noisy.mem-required-stress-mem}" at K8SMaster
    Then I save the SSH response in the following variables:
	      | attribute      | value    |
	      | (.*)           | meminfo  |  
	      
	  Given I define the following constants:
		  | name               | value                                                        |
		  | noisy_run_command  | {config.global.scenario.noisy.command-start-mem} {SSH.meminfo}M &              |   
    
    ## Capture stats and Start Noisy Scenario.        
    Given I execute the steps from {config.global.scenario.noisy.lib-dir}Capture_And_Start_Noisy_Scenario.feature
    
    ##### Loop Count for validation
   	When I execute the SSH command "echo {config.scenario.exec-params.iteration-time} {config.scenario.exec-params.validation-repeat-interval} | awk '{print  $1/$2}'" at K8SMaster	
		Then I save the SSH response in the following variables:
	      | attribute      | value          |
	      | (.*)           | loopCnt		    |
    Given I define the following constants:
		  | name   | value                    |
		  | index  | 1                        |
		  
    ### Validation in Loop
    Given I loop {SSH.loopCnt} times
    	Given I print: "Running Validation {Constant.index} itertion"
    	
    	Given I execute the steps from {config.global.scenario.noisy.lib-dir}Capture_Stats_Post_Noisy_Scenario_Run.feature
    	Given I execute the steps from {config.global.scenario.noisy.lib-dir}Noisy_Memory_validation.feature
    	
    	Given I wait for {config.scenario.exec-params.validation-repeat-interval} seconds
			Given I increment Constant.index by  1
    Given I end loop
		
    ### Check For Active Alarm of the User
    When I execute the SSH command {config.global.command.opsCenter.show-active-alert} at CLICeeOPSCenter
    Then I save the SSH response in the following variables:
      | attribute      | value       |
      | ([\s\S]*)      | activeAlert |   
      
    When I execute the SSH command "echo {SSH.activeAlert} | grep source | grep {SSH.NodeName} | wc -l" at SITEHOST 
	  Then I save the SSH response in the following variables:
		    | attribute | value          |
		    | (.*)      | alertCount     |
		Given I validate the following attributes:
	     	|   attribute                 | value             |
    	 	|  {SSH.alertCount}	          | GREATERTHAN(0)    |
    
    # Stop existing memory stress Process
		When I execute the SSH command "{config.global.scenario.noisy.command-stop-mem}" at NoisyInstance
    #
		################## Noisy Scenario End ######################################
		
		### Waiting for 10 mins to cool down
		Then I wait for {config.global.constant.sixhundred} seconds
		
		### Check For No Alarm for the Node
    When I execute the SSH command {config.global.command.opsCenter.show-active-alert} at CLICeeOPSCenter
    Then I save the SSH response in the following variables:
      | attribute      | value       |
      | ([\s\S]*)      | activeAlert |   
      
    When I execute the SSH command "echo {SSH.activeAlert} | grep source | grep {SSH.NodeName} | wc -l" at SITEHOST 
	  Then I save the SSH response in the following variables:
		    | attribute | value          |
		    | (.*)      | alertCount     |
		Given I validate the following attributes:
	     	|   attribute                 | value        		|
        |  {SSH.alertCount}	          | LESSTHAN(1)     |
        
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
    #Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}EventErrorCaptureAndChecks.feature
    
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
      | Noisy Memory Test On Session VM - Two Iterations | Pass |
    #CICD report end#####################