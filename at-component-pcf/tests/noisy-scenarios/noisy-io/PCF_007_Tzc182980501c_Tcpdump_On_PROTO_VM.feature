#####################################################################################################
# Date: <24/10/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat>  #
#####################################################################################################
@PCF @P2 @Noisy_Scenario @Noisy_IO @Tzc182980501c 

Feature: PCF_007_Tzc182980501c_Tcpdump_On_PROTO_VM

  Scenario: Run TCPDUMP On Proto VM - One Iterations

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
      | Run TCPDUMP On Proto VM - One Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  
    
    # Get Node name
   	When I execute the SSH command {config.global.commands.k8s.getprotonodenames} | head -1 at K8SMaster
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
      |  EndpointIpAddress  |  {SSH.NodeIP}                     |
    
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown
    
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
            
   #Start the TCPDUMP  
  	#When I execute using handler K8SMaster on shell sh1 the command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} {SSH.NodeName} {config.global.scenario.noisy.command-start-tcpdump}"
    #When I execute using handler NoisyInstance the SSH shell command "{config.global.scenario.noisy.command-start-tcpdump}"
    When I execute using handler NoisyInstance on shell sh1 the command "{config.global.scenario.noisy.command-start-tcpdump}"
    
    Given I wait for {config.global.constant.ten} seconds
        
    Given I loop 99999 times
    
    When I execute using handler K8SMaster the SSH shell command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} ls -la {config.global.scenario.noisy.tcpdump-pcap-file-name} | awk '{print $5}'"
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | FileSize |
    
    ## If PCAP file size reaches desired file limit, exit from Loop.
    Given I break loop if {SSH.FileSize}  >= {config.global.scenario.noisy.tcpdump-pcap-file-size} * 1000000
                  
    Given I wait for {config.global.constant.ten} seconds
    
    Given I end loop
    
    ## Stop existing TCPDUMP Process
    #When I execute using handler NoisyInstance the SSH shell command "{config.global.scenario.noisy.command-stop-tcpdump}"
    When I execute using handler NoisyInstance on shell sh2 the command "{config.global.scenario.noisy.command-stop-tcpdump}"
    ## Delete PCAP Files from NODE.
    When I execute using handler K8SMaster on channel ch1 the command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} rm -f {config.global.scenario.noisy.tcpdump-pcap-file-name}*"
    
    Then I wait for {config.global.constant.threehundred} seconds
            
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
    #Then I update report for table {Constant.testkpi} with the following details:
    #    | {config.CTR.AdditionalChecks.Label} | Pass |
    Given I define the following constants:
      | name        | value                                    |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | Run TCPDUMP On Proto VM - One Iterations | Pass |
    #CICD report end#####################
