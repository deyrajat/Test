####################################################################################################
# Date: <06/06/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Resiliency @Tzc182637373c @P2  @NodeNetRestart @PcfResP2Set2 

Feature: PCF_19_3_0_042_Tzc182637373c_Restart_Network_Of_One_ETCD_VM

Scenario: Restart Network of One ETCD VM 30 MINs- One Iterations
  
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
      | Restart Network of One ETCD VM - One Iterations | Fail |
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
    
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    Given I delete SSH instance SMIDeployerOpsCenter
    
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
      
    ## GET IP of the ETCD node
    When I execute the SSH command "ping {SSH.NodeName} -c 1 | grep PING | cut -d' ' -f 3 | cut -d'(' -f 2 | cut -d')' -f 1" at K8SMaster
    Then I save the SSH response in the following variables:
		| attribute        | value             |
		| (.*)             | NodeIP            |
      
    ## GET Interface Name of the ETCD node
    When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} {SSH.NodeName} netstat -ie | grep -B1 {SSH.NodeIP} | head -n1 | awk -F':' '{print $1}'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value      |
      | (.*)           | NodeIntf   |        
      
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
      
		## Now reboot the ETCD node.  	  
  	When I execute using handler SITEHOST the parameterized command /root/action.sh {config.scenario.exec-params.sut.platform-type} {config.sut.blades.sshpassowrd} {config.sut.vm.sshpassword} 1 0 with following arguments:
      | attribute | value                             |
      | F         | vm_all_physical_port_restart                |
      | V         | {SSH.NodeName}                    |
      | R         | {SSH.NodeIntf}                    |
      | O         | {config.sut.ospd.ipaddress}      |
      | E         | {config.sut.esc.ipaddress}       |
      | P         | {config.sut.esc.sshpassowrd}     |
      | K         | /root/{SSH.smiKeyName}            |
      | U         | {config.sut.k8smaster.default.user}      |
    Then I receive a SSH response and check the presence of following strings:
      | string                | occurrence |
      | Interface Is UP       | present    |
      | Interface Is Down     | absent     |
    	
		Then I wait for {config.global.constant.twohundred.forty} seconds		
			
		## Check the ETCD node is up.	
		When I execute the SSH command ping -c 1 {SSH.NodeName} >/dev/null 2>&1; echo $?  at K8SMaster
		Then I receive a SSH response and check the presence of following strings:
      | string     | occurrence |
      |  0         | present    | 	
    	
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
      | Restart Network of One ETCD VM - One Iterations | Pass |
    #CICD report end#####################

    