####################################################################################################
# Date: <05/06/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Resiliency @Tzc182637375c @P2 @NodeNetRestart @PcfResP2Set2 

Feature: PCF_19_3_0_039_Tzc182637375c_Restart_Network_Of_One_PROTO_VM

Scenario: Restart Network Of One PROTO VM 30 MINs- One Iterations
  
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
      | Restart Network Of One PROTO VM - One Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  

    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    When I execute using handler K8SMaster the SSH shell command {config.global.commands.k8s.pod-list-pcf} -o wide | grep {sut.k8s.label.vm.proto} | awk '{print $1}' | xargs kubectl delete pod -n {config.sut.k8s.namespace.pcf}

    #### Wait before Data collection
    Given I wait for {config.global.constant.sixty} seconds

    Given I loop 5 times

        ## Check status of the deployment.
        When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLIPcfOPSCenter
        Then I save the SSH response in the following variables:
            | attribute                             | value           |
            | (system status percent-ready\s+\S+)   | depPerReady     |
        When I execute using handler SITEHOST the SSH command "echo {SSH.depPerReady}"
        Then I save the SSH response in the following variables:
            | attribute             | value       |
            | {Regex}(\d+.\d+)      | depPerReady |
        Then I validate the following attributes:
            | attribute         | value                                            |
            | {SSH.depPerReady} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) |

    Given I break loop if {SSH.depPerReady} >= {config.global.thresholds.system.status-ready-expectedpercentage}

        Given I wait for {config.global.constant.sixty} seconds

    And I end loop

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
    
    ##GET name of the RX node.  
    #When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} -o wide | grep diameter-ep-rx | awk  'FNR == 1 {print $7}' at K8SMaster
    #Then I save the SSH response in the following variables:
      #| attribute      | value           |
      #| (.*)           | RxNodename 	   |  
    
 		##GET name of the PROTO node.  
    When I execute the SSH command {config.global.commands.k8s.getprotonodenames} | head -1 at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | NodeName |
      
    ## GET IP of the PROTO node
    When I execute the SSH command kubectl get nodes -o wide | grep {SSH.NodeName} | awk '{print $6}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | NodeIP   |
      
    ## GET Interface Name of the PROTO node
    When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} | awk -F'/' '{print $NF}') {SSH.NodeName} netstat -ie | grep -B1 {SSH.NodeIP} | head -n1 | awk -F':' '{print $1}'" at K8SMaster
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
      
		## Now restart the network of PROTO node.  	  
  	When I execute using handler SITEHOST the parameterized command /root/action.sh {config.scenario.exec-params.sut.platform-type} {config.sut.blades.sshpassowrd} {config.sut.vm.sshpassword} 1 0 with following arguments:
      | attribute | value                             |
      | F         | vm_all_physical_port_restart      |
      | V         | {SSH.NodeName}                    |
      | R         | {SSH.NodeIntf}                    |
      | O         | {config.sut.ospd.ipaddress}      |
      | E         | {config.sut.esc.ipaddress}       |
      | P         | {config.sut.esc.sshpassowrd} |
      | K         | /root/{SSH.smiKeyName}            |
      | U         | {config.sut.k8smaster.default.user}      |
    Then I receive a SSH response and check the presence of following strings:
      | string                | occurrence |
      | Interface Is UP       | present    |
      | Interface Is Down     | absent     |
    	
		Then I wait for {config.global.constant.twohundred.forty} seconds		
			
		## Check the PROTO node is up.	
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
      | Restart Network Of One PROTO VM - One Iterations | Pass |
    #CICD report end#####################

    