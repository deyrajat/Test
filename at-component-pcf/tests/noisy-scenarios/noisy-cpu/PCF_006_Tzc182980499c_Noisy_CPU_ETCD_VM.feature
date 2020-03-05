#####################################################################################################
# Date: <05/11/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat>  #
#####################################################################################################
@PCF @P2 @Noisy_Scenario @Noisy_CPU @Tzc182980499c

Feature: PCF_006_Tzc182980499c_Noisy_CPU_ETCD_VM

  Scenario: Noisy CPU Test On ETCD VM - Two Iterations

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
      | Noisy CPU Test On ETCD VM - Two Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  
      
    ##GET IP Address of the smiopscenter
    When I execute the SSH command k3s kubectl get svc -n smi -o wide | grep ^ops-center | awk '{print $3}' at SMIDeployer
    Then I save the SSH response in the following variables:
      | attribute |  value           |
      | (.*)      |  smiopscenterip  |

    ### Create the SSH instance for chaosopscenterip
    Given I configure a SSH instance with following attributes:
      |  string                   |  value                                |
      |  InstanceName             |  SMIDeployerOpsCenter                 |
      |  UserName                 |  {config.CliOPSCenter.SSH.UserName}   |
      |  Password                 |  {config.CliOPSCenter.SSH.Password}   |
      |  Port                     |  2024                                 |
      |  EndpointIpAddress        |  {SSH.smiopscenterip}                 |
      |  Route                    |  SMIDeployer-->SMIDeployerOpsCenter   |
    
    ## Push Noisy Script into master node.
    When I execute using handler K8SMaster the SSH shell command "mkdir -p {config.global.scenario.noisy.remotepush-location}"
    Given the SFTP push of file "{Config.global.scenario.noisy.utilities-dir}noisy_cpu_sim.sh" to "{config.global.scenario.noisy.remotepush-location}" at K8SMaster is successful
    When I execute using handler K8SMaster the SSH shell command "sudo chmod +x {config.global.scenario.noisy.remotepush-location}noisy_cpu_sim.sh"
    
		## Get all nodes info from SMIDeployerOpsCenter.
	  When I execute the SSH command "{config.global.command.opsCenter.show-running-config} clusters nodes" at SMIDeployerOpsCenter
		Then I save the SSH response in the following variables:
			| attribute        | value                  |
			| ([\s\S]*)        | runningConfigNodes     |
		
		## Get Clustername	
	  When I execute the SSH command "echo "{SSH.runningConfigNodes}" | head -1 | awk '{print $NF}'" at SITEHOST
	  Then I save the SSH response in the following variables:
			| attribute        | value             |
			| (.*)             | clusterName       |
	
		## Get ETCD node hostname from SMIDeployerOpsCenter
		When I execute the SSH command "echo "{SSH.runningConfigNodes}" | awk '$0~p{print a}{a=$0}' p="k8s node-type etcd" | awk ' FNR==1 {print $NF}'" at SITEHOST
	  Then I save the SSH response in the following variables:
			| attribute        | value             |
			| (.*)             | depnodeHost       |
			
	 	# #GET name of the ETCD node
	  When I execute the SSH command "echo "{SSH.clusterName}-{SSH.depnodeHost}""  at SITEHOST
	  Then I save the SSH response in the following variables:
			| attribute        | value             |
			| (.*)             | NodeName          |
    
    ## Get Number of CPUS in the VM
    When I execute using handler K8SMaster the SSH shell command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} sudo nproc"
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | VCPUs    |
      
   	# Get Node IP  
    When I execute the SSH command "echo "{SSH.runningConfigNodes}" |  awk '/{SSH.depnodeHost}/{nr[NR+2];}; NR in nr' | awk '{print $NF}'"  at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | NodeIP   |
      
    ### Create Dynamic SSH Instance With the NODE
    Given I configure a SSH instance with following attributes:
      |  string             |  value                            |
      |  InstanceName       |  NoisyInstance                    |
      |  UserName           |  {config.K8SMaster.SSH.UserName}  |
      |  KeyFile            |  {config.sut.SMIDeployer.SSH-KeyFile}   |
      |  EndpointIpAddress  |  {SSH.NodeIP}                 	|
      
      
    ## Upload Stress Script to the Node
   	When I execute using handler K8SMaster the SSH shell command "scp {config.global.scenario.noisy.remotepush-location}noisy_cpu_sim.sh {SSH.NodeName}:"
    
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown
    
    #Stop the noisy CPU scenario
    When I execute using handler NoisyInstance the SSH shell command "{Config.global.scenario.noisy.command-stop-cpu}"
    
    Given I delete SSH instance SMIDeployerOpsCenter
    
    ### Delete file from the Node
	  When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} {SSH.NodeName} rm -f noisy_cpu_sim.sh" at K8SMaster

    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature
    
    Given I delete SSH instance CHAOSINSTANCE

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
 
  	Given I define the following constants:
		  | name               | value                                                                            |
		  | noisy_run_command  | {config.global.scenario.noisy.command-start-cpu} {SSH.VCPUs} &             | 
            
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
    	Given I execute the steps from {config.global.scenario.noisy.lib-dir}Noisy_CPU_validation.feature
    	
    	Given I wait for {config.scenario.exec-params.validation-repeat-interval} seconds
			Given I increment Constant.index by  1
    Given I end loop
    
    ### Check For Active Alarm of the User
    When I execute the SSH command {config.global.command.opsCenter.show-active-alert} at CLICeeOPSCenter
    Then I save the SSH response in the following variables:
      | attribute      | value       |
      | ([\s\S]*)      | activeAlert |   
      
    When I execute the SSH command echo "{SSH.activeAlert}" | grep source | grep {SSH.NodeName} | wc -l at SITEHOST 
	  Then I save the SSH response in the following variables:
		    | attribute | value          |
		    | (.*)      | alertCount     |
		Given I validate the following attributes:
	     	|   attribute                 | value             |
    	 	|  {SSH.alertCount}	          | GREATERTHAN(0)    |       		
	
		#Stop the noisy CPU scenario
    When I execute using handler NoisyInstance the SSH shell command "{Config.global.scenario.noisy.command-stop-cpu}"
 		################## Noisy Scenario End ######################################
		
		### Waiting for 10 mins to cool down
		Then I wait for {config.global.constant.sixhundred} seconds

		
		### Check For No Alarm for the Node
    When I execute the SSH command {config.global.command.opsCenter.show-active-alert} at CLICeeOPSCenter
    Then I save the SSH response in the following variables:
      | attribute      | value       |
      | ([\s\S]*)      | activeAlert |   
      
    When I execute the SSH command echo "{SSH.activeAlert}" | grep source | grep {SSH.NodeName} | wc -l at SITEHOST 
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
      | Noisy CPU Test On ETCD VM - Two Iterations | Pass |
    #CICD report end#####################
