####################################################################################################
# Date: <08/29/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Resiliency @Tzc182890298c @P1 @CDET @PcfResP1Set3


Feature: PCF_19_3_0_055_Tzc182890298c_NRF_VIPs_restart_NIC_of_PROTO_VM

Scenario: NRF VIPs restart NIC of PROTO VM- One Iterations
  
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
      | NRF VIPs restart NIC of PROTO VM - One Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  
    
    ##GET IP Address of the NRF interface from CLI OPS CENTER  
    When I execute the SSH command {config.global.command.opsCenter.show-running-config} rest-endpoint interface nnrf ip at CLIPcfOPSCenter
    Then I save the SSH response in the following variables:
      | attribute      | value       |
      | ([\s\S]*)      | RestNRFIP   |
      
    When I execute the SSH command echo "{SSH.RestNRFIP}" | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}' at SITEHOST

 	  Then I save the SSH response in the following variables:
      | attribute |    value       |
      | (.*)      |    NRFVip      |
      
    ### Get hostname of the VM associated with VIP
    Given I configure a SSH instance with following attributes:
     |  string	           |	 value	                         |
     |  InstanceName       |  NRFVIPINSTANCE                   |
     |  UserName           |  {config.K8SMaster.SSH.UserName}  |
	   |  KeyFile            |  {config.sut.SMIDeployer.SSH-KeyFile}   |
	   |  EndpointIpAddress  |  {SSH.NRFVip}                     |
	   |  Route              |  K8SMaster-->NRFVIPINSTANCE       | 

    When I execute using handler NRFVIPINSTANCE the SSH command "hostname"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | nrfviphostname     |

    Given I delete SSH instance NRFVIPINSTANCE
    
    ## GET Interface Name of the node to OFF and ON
    When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.nrfviphostname} 'ip -o -4 addr show' | grep '{SSH.NRFVip}' | awk -F' ' '{print $2}'" at K8SMaster 
    Then I save the SSH response in the following variables:
      | attribute      | value            |
      | (.*)           | NodeIntftoRest   |
    
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown
    
    ## Enable the NRF Interface
    When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.nrfviphostname} sudo ifconfig {SSH.NodeIntftoRest} up" at K8SMaster

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
      
    ## Disable the NRF Interface
    When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.nrfviphostname} sudo ifconfig {SSH.NodeIntftoRest} down" at K8SMaster
    When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.nrfviphostname} cat /sys/class/net/{SSH.NodeIntftoRest}/operstate" at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string    | occurrence |
      | down      | present    |
      | up        | absent     |
      
	  Then I wait for {config.global.constant.sixty} seconds
	  
	  ### Get hostname of the VM associated with VIP
    Given I configure a SSH instance with following attributes:
     |  string	           |	 value	                         |
     |  InstanceName       |  NRFVIPINSTANCE                   |
     |  UserName           |  {config.K8SMaster.SSH.UserName}  |
	   |  KeyFile            |  {config.sut.SMIDeployer.SSH-KeyFile}   |
	   |  EndpointIpAddress  |  {SSH.NRFVip}                     |
	   |  Route              |  K8SMaster-->NRFVIPINSTANCE       | 

    When I execute using handler NRFVIPINSTANCE the SSH command "hostname"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | nrfviphostname2    |
    Then I validate the following attributes:
  	  | attribute             | value                             |
   	  | {SSH.nrfviphostname}  | NOTEQUAL({SSH.nrfviphostname2})   |	
    	
    Given I delete SSH instance NRFVIPINSTANCE
    
    ## Enable the NRF Interface
    When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.nrfviphostname} sudo ifconfig {SSH.NodeIntftoRest} up" at K8SMaster
    When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.nrfviphostname} cat /sys/class/net/{SSH.NodeIntftoRest}/operstate" at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string    | occurrence |
      | down      | absent     |
      | up        | present    |
      
    Then I wait for {config.global.constant.sixty} seconds
    
    ### Get hostname of the VM associated with VIP
    Given I configure a SSH instance with following attributes:
     |  string	           |	 value	                         |
     |  InstanceName       |  NRFVIPINSTANCE                   |
     |  UserName           |  {config.K8SMaster.SSH.UserName}  |
	   |  KeyFile            |  {config.sut.SMIDeployer.SSH-KeyFile}   |
	   |  EndpointIpAddress  |  {SSH.NRFVip}                     |
	   |  Route              |  K8SMaster-->NRFVIPINSTANCE       | 

    When I execute using handler NRFVIPINSTANCE the SSH command "hostname"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | nrfviphostname3    |
    Then I validate the following attributes:
  	  | attribute             | value                        |
   	  | {SSH.nrfviphostname}  | EQUAL({SSH.nrfviphostname3}) |	
    	
    Given I delete SSH instance NRFVIPINSTANCE		
    
    Then I wait for {config.global.constant.onehundred.eighty} seconds
    	
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
      | name        | value                                    |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | NRF VIPs restart NIC of PROTO VM - One Iterations | Pass |
    #CICD report end#####################

    