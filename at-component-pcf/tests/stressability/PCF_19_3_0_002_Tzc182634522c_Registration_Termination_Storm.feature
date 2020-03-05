################################################################################################
# Date: <13/02/2018> Version: <Initial version: 18.0.1> $1Create by <Sandeep Talukdar, santaluk>
################################################################################################
@PCF @Stress @Tzc182634522c @P2 

Feature: PCF_19_3_0_002_Tzc182634522c_Registration_Termination_Storm

  Scenario: PCF Registration Termination Storm - One Iterations

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
      | PCF Registration Termination Storm - One Iterations | Fail |
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

    ## Killing the Traffic so that the ToolAgent instances are created
    Given I execute the SSH command "pkill -f ToolAgent" at ToolAgentHost
    Given I execute the SSH command "pkill -f lattice" at ToolAgentHost
    Given I execute the SSH command "pkill -f cli" at ToolAgentHost

    Given I execute the SSH command "rm -rf ToolAgent.*" at ToolAgentHost
    Given I execute the SSH command "rm -rf core.*" at ToolAgentHost  
    When I execute the SSH command "rm -rf /tmp/taas/*" at ToolAgentHost

    #External PreRun File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}PreRun.feature

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.benchmark-interval} seconds

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #Get Benchmark values
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Benchmark.feature

    Given the SFTP push of file "{config.CalipersSourcePath}{config.tools.caliper.create-delete-burst-filename}" to "{config.Calipers.Config.dir}" at SITEHOST is successful

    When I execute using handler SITEHOST the parameterized command /root/AssignEndPointIpAddress.sh with following arguments:
      | attribute | value                                                                              |
      | f         | {config.Calipers.Config.dir}{config.tools.caliper.create-delete-burst-filename}    |
      | c         | {config.scenario.exec-params.createdelete.callrate-burst}                       	 |
      | L         | {config.tools.toolagent.ipaddress4}                                                |
      | G         | {config.sut.vm.proto.n7client-vipaddress}                                          |
      | R         | {config.sut.vm.proto.rxclient-vipaddress}                                          |
      | s         | {config.sut.nrf.server1.ipaddress}                                                 |
      | t         | {config.sut.nrf.server2.ipaddress}                                                 |
      | u         | {config.sut.nrf.server3.ipaddress}                                                 |

    Given I setup a Calipers instance named {config.tools.caliper.create-delete-burst-instance} using {config.Calipers.Config.dir}{config.tools.caliper.create-delete-burst-filename} at ToolAgentCDBurst1
    Then I get the {config.tools.caliper.create-delete-burst-instance}.configstatus from ToolAgentCDBurst1 and validate the following attributes:
      | attribute       | value                            |
      | Response.Status | Success                          |
      | Response.Info   | No errors in configuration file! |

    When I start {config.tools.caliper.create-delete-burst-instance} call-model {config.tools.caliper.create-delete-burst-callmodel} at ToolAgentCDBurst1

    Then I wait for {config.scenario.exec-params.execution-duration} seconds 

    When I execute the SSH command {config.sut.k8smaster.home.directory}/cpu_Load_Check.sh {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string                 | occurrence |
      | System is stressed     | present    |
      | System is not Stressed | absent     |

    When I stop the {config.tools.caliper.create-delete-burst-instance} call-model {config.tools.caliper.create-delete-burst-callmodel} at ToolAgentCDBurst1

    Then I wait for {config.scenario.exec-params.cooloff-duration} seconds  

    When I execute the SSH command {config.sut.k8smaster.home.directory}/cpu_Load_Check.sh {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string                 | occurrence |
      | System is stressed     | absent     |
      | System is not Stressed | present    |

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |
    
	Then I wait for {config.scenario.exec-params.benchmark-interval} seconds
	
	When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #Iteration1 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration1_Steps.feature


##### Second Iteration
###### Commented due to cdet CSCvp34557

#    When I execute using handler K8SMaster the SSH shell command "date +%s"
#    Then I save the SSH response in the following variables:
#      | attribute | value              |
#      | (.*)      | grafana_start_time |
      
 #   When I execute the SSH command "date +%H:%M_%Y%m%d" at K8SMaster
 #   Then I save the SSH response in the following variables:
#      | attribute | value            |
#      | (.*)      | event_start_time |

 #   When I execute the SSH command "date '+%s'" at K8SMaster
 #   Then I save the SSH response in the following variables:
 #     | attribute | value                  |
  #    | (.*)      | event_start_epoch_time |
      
 #   When I start {config.tools.caliper.create-delete-burst-instance} call-model {config.tools.caliper.create-delete-burst-callmodel} at ToolAgentCDBurst1

#    Then I wait for {config.global.constant.twohundred.forty} seconds
 #   Then I wait for {config.global.constant.twohundred.forty} seconds
 #   Then I wait for {config.global.constant.twohundred.forty} seconds
    
 #   When I stop the {config.tools.caliper.create-delete-burst-instance} call-model {config.tools.caliper.create-delete-burst-callmodel} at ToolAgentCDBurst1
    
#    When I execute the SSH command "date +%H:%M_%Y%m%d" at K8SMaster    
#    Then I save the SSH response in the following variables:
 #     | attribute | value          |
  #    | (.*)      | event_end_time |

 #   When I execute the SSH command "date '+%s'" at K8SMaster
#    Then I save the SSH response in the following variables:
 #     | attribute | value                |
 #     | (.*)      | event_end_epoch_time |
      
#	When I execute using handler K8SMaster the SSH shell command "date +%s"
  #  Then I save the SSH response in the following variables:
 #     | attribute | value             |
 #     | (.*)      | grafana_stop_time | 

    ##Calculate exact duration of event in seconds
 #   When I execute the SSH command {config.global.remotepush.location.utilities-geteventduration} {SSH.event_start_epoch_time} {SSH.event_end_epoch_time} at SITEHOST
 #   Then I save the SSH response in the following variables:
#      | attribute | value        |
  #    | (.*)      | eventTimeSec |

    ####Check Errors and Timeouts during Reboot
 #   Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}EventErrorCaptureAndChecks.feature
      
 #   When I execute using handler Installer the SSH shell command echo '&start={SSH.grafana_start_time}&end={SSH.grafana_stop_time}&step={config.Step_Duration}'
#    Then I save the SSH response in the following variables:
#      | attribute | value     |
#      | (.*)      | TimeQuery |
    
    #### CPU seconds for PCRF engine 
 #   When I execute using handler K8SMaster the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.CPU_Usage_Seconds}{SSH.TimeQuery}" {config.Grafana.Authorization} {config.Value.Extrator}
 #   Then I receive a SSH response and check the presence of following strings:
 #     | string      | value                                | occurrence |
#      | {Regex}(.*) | lesserthan({config.PCF.CPS.Seconds}) | present    |
      
 #   When I execute using handler K8SMaster the SSH shell command "date +%s"
 #   Then I save the SSH response in the following variables:
 #     | attribute | value              |
 #     | (.*)      | grafana_start_time |
    
#	Then I wait for {config.scenario.exec-params.benchmark-interval} seconds
	
#	When I execute using handler K8SMaster the SSH shell command "date +%s"
 #   Then I save the SSH response in the following variables:
#      | attribute | value             |
#      | (.*)      | grafana_stop_time | 
      
#    #Iteration2 Steps
 #   Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature
    

    #CICD report start#####################
    Given I define the following constants:
      | name        | value                                    |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | PCF Registration Termination Storm - One Iterations | Pass |
    #CICD report end##################### 
