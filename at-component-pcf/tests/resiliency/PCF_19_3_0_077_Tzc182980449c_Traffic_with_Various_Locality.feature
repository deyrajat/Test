####################################################################################################
# Date: <15/05/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Resiliency @Tzc182980449c @F3190 @P3

Feature: PCF_19_3_0_077_Tzc182980449c_Traffic_with_Various_Locality

  Scenario: NRF_Traffic_with_Various_Locality 30 MINs- Two Iterations

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
      | NRF_Traffic_with_Various_Locality - Two Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  

    Given I define the following constants:
      | name                | value         |
      | nrfCfgAddIndex      | 2             |
      | nrfCfgStopIndex     | 2             |

    When I execute the SSH command echo $(( {config.tools.caliper.nrf.totalfile-count} - {config.tools.caliper.nrf.clientfile-count} ))  at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | additionNrfFiles |

    ##Teardown Steps
    Given the below steps are armed to be executed during teardown
    
    ### Now Kill the Additional NRF Nodes 
    
    Given I expect the next test step to execute if ({config.sut.nrf.external.use-enable} < 1)

	    Given I loop {SSH.additionNrfFiles} times
	
	       Given I delete the {config.{config.tools.caliper.nrf-instance-arrayprefix}{Constant.nrfCfgStopIndex}.configuration at ToolAgent{Constant.nrfCfgStopIndex} 
	
	       Then I increment Constant.nrfCfgStopIndex by 1
	
	    And I end loop
	
	    Then I wait for {config.global.constant.ninety} seconds
	    
	  Given I end the if

    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    #CICD Test report end
    
    Given I expect the next test step to execute if ({config.scenario.start.traffic} > 0)
    
        Given I execute the SSH command "pkill -f ToolAgent" at ToolAgentHost
        Given I execute the SSH command "pkill -f lattice" at ToolAgentHost
        Given I execute the SSH command "pkill -f cli" at ToolAgentHost
        
    Given I end the if        

    Given the arming of teardown steps are done

    Given I expect the next test step to execute if ({config.scenario.start.traffic} > 0)

        Given I execute the SSH command "pkill -f ToolAgent" at ToolAgentHost
        Given I execute the SSH command "pkill -f lattice" at ToolAgentHost
        Given I execute the SSH command "pkill -f cli" at ToolAgentHost

        When I execute the SSH command "cdl clear sessions filter { key ImsiKey:imsi:1001100 condition starts-with }" at CLIPcfOPSCenter

        #External SetupTest File
        Given I execute the steps from {config.global.workspace.library.location-features-calipers}CallModel_SetupTest.feature

        #call Start
        Given I execute the steps from {config.global.workspace.library.location-features-calipers}CallModel_Execution.feature

    Given I end the if

    #External PreRun File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}PreRun.feature

    #SFTP push of nrf specific calipers files
    Given I loop {SSH.additionNrfFiles} times

    Given the SFTP push of file "{config.CalipersSourcePath}{config.{config.tools.caliper.nrf-config-file-arrayprefix}{Constant.nrfCfgAddIndex}}" to "{config.Calipers.Config.dir}" at SITEHOST is successful

    When I execute using handler SITEHOST the parameterized command /root/AssignEndPointIpAddress.sh with following arguments:
      | attribute | value                                                                                     |
      | f         | {config.Calipers.Config.dir}{config.{config.tools.caliper.nrf-config-file-arrayprefix}{Constant.nrfCfgAddIndex}}  |
      | c         | {config.{config.tools.caliper.nrf-callrate-arrayprefix}{Constant.nrfCfgAddIndex}}                            |
      | L         | {config.ToolAgentHost.SSH.EndpointIpAddress}                                              |
      | G         | {config.sut.vm.proto.n7client-vipaddress}                                                                         |
      | N         | {config.sut.vm.proto.n28client-vipaddress}                                                                        |
      | R         | {config.sut.vm.proto.rxclient-vipaddress}                                                                         |
      | p         | {config.Nrf1RegPort}                                                                      |
      | q         | {config.Nrf2RegPort}                                                                      |
      | r         | {config.Nrf3RegPort}                                                                      |
      | s         | {config.sut.nrf.server1.ipaddress}                                                               |
      | t         | {config.sut.nrf.server2.ipaddress}                                                             |
      | u         | {config.sut.nrf.server3.ipaddress}                                                              |

    Given I execute the SSH command "dos2unix {config.Calipers.Config.dir}*.cfg" at SITEHOST
    
    Given I expect the next test step to execute if ({config.sut.nrf.external.use-enable} < 1)

	    Given I setup a Calipers instance named {config.{config.tools.caliper.nrf-instance-arrayprefix}{Constant.nrfCfgAddIndex}} using {config.Calipers.Config.dir}{config.{config.tools.caliper.nrf-config-file-arrayprefix}{Constant.nrfCfgAddIndex}} at ToolAgentNRF{Constant.nrfCfgAddIndex}
	    Then I get the {config.{config.tools.caliper.nrf-instance-arrayprefix}{Constant.nrfCfgAddIndex}}.configstatus from ToolAgentNRF{Constant.nrfCfgAddIndex} and validate the following attributes:
	      | attribute       | value                            |
	      | Response.Status | Success                          |
	      | Response.Info   | No errors in configuration file! |
	
	    Then I wait for {config.global.constant.onehundred.twenty} seconds
    
    Given I end the if

    Then I increment Constant.nrfCfgAddIndex by 1
    And I end loop

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

    #### Change the locality value to Geo locality
    Given the SFTP push of file "{config.CalipersSourcePath}{config.scenario.exec-params.geolocation.config-fileName}" to "{config.Calipers.Config.dir}" at SITEHOST is successful

    When I execute using handler SITEHOST the parameterized command /root/AssignEndPointIpAddress.sh with following arguments:
        | attribute | value                                       |
        | f         | {config.Calipers.Config.dir}{config.scenario.exec-params.geolocation.config-fileName}   |
        | c         | {config.ClpRate_1}                                         |
        | L         | {config.tools.toolagent.ipaddress1}                        |
        | G         | {config.sut.vm.proto.n7client-vipaddress}                  |
        | N         | {config.sut.vm.proto.n28client-vipaddress}                 |
        | R         | {config.sut.vm.proto.rxclient-vipaddress}                  |
        | p         | {config.Nrf1RegPort}                                       |
        | q         | {config.Nrf2RegPort}                                       |
        | r         | {config.Nrf3RegPort}                                       |
        | b         | {config.BaseCall.EventBridge.Port_1}                       |
        | s         | {config.sut.nrf.server1.ipaddress}                                                               |
        | t         | {config.sut.nrf.server2.ipaddress}                                                             |
        | u         | {config.sut.nrf.server3.ipaddress}                                                              |

    Given I delete the {config.scenario.exec-params.geolocation.instance-to-remove}.configuration at ToolAgent1

    Given I setup a Calipers instance named {config.scenario.exec-params.geolocation.instance-to-start} using {config.Calipers.Config.dir}{config.scenario.exec-params.geolocation.config-fileName} at ToolAgent1
    Then I get the {config.scenario.exec-params.geolocation.instance-to-start}.configstatus from ToolAgent1 and validate the following attributes:
      | attribute       | value                            |
      | Response.Status | Success                          |
      | Response.Info   | No errors in configuration file! |
    When I start {config.scenario.exec-params.geolocation.instance-to-start} call-model {config.CM_1} at ToolAgent1
    
    Given I wait for {config.global.constant.thirty} seconds
    
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

    Given I wait for {config.global.constant.onehundred.eighty} seconds

    ####Capture End Time after NRF failover
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

    ####Check Errors and Timeouts during Location Change
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

    #### Change the locality value to Diff locality
    Given the SFTP push of file "{config.CalipersSourcePath}{config.scenario.exec-params.difflocation.config-fileName}" to "{config.Calipers.Config.dir}" at SITEHOST is successful

    When I execute using handler SITEHOST the parameterized command /root/AssignEndPointIpAddress.sh with following arguments:
        | attribute | value                                       |
        | f         | {config.Calipers.Config.dir}{config.scenario.exec-params.difflocation.config-fileName}  |
        | c         | {config.ClpRate_1}                                         |
        | L         | {config.tools.toolagent.ipaddress1}                        |
        | G         | {config.sut.vm.proto.n7client-vipaddress}                  |
        | N         | {config.sut.vm.proto.n28client-vipaddress}                 |
        | R         | {config.sut.vm.proto.rxclient-vipaddress}                  |
        | p         | {config.Nrf1RegPort}                                       |
        | q         | {config.Nrf2RegPort}                                       |
        | r         | {config.Nrf3RegPort}                                       |
        | b         | {config.BaseCall.EventBridge.Port_1}                       |
        | s         | {config.sut.nrf.server1.ipaddress}                                                               |
        | t         | {config.sut.nrf.server2.ipaddress}                                                             |
        | u         | {config.sut.nrf.server3.ipaddress}                                                              |

    Given I delete the {config.scenario.exec-params.difflocation.instance-to-remove}.configuration at ToolAgent1

    Given I setup a Calipers instance named {config.scenario.exec-params.difflocation.instance-to-start} using {config.Calipers.Config.dir}{config.Diffloc.Cfg.FileName} at ToolAgent1
    Then I get the {config.scenario.exec-params.difflocation.instance-to-start}.configstatus from ToolAgent1 and validate the following attributes:
      | attribute       | value                            |
      | Response.Status | Success                          |
      | Response.Info   | No errors in configuration file! |
    When I start {config.scenario.exec-params.difflocation.instance-to-start} call-model {config.CM_1} at ToolAgent1
    
    Given I wait for {config.global.constant.thirty} seconds
    
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

    Given I wait for {config.global.constant.onehundred.eighty} seconds

    ####Capture End Time after NRF Failback
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

    #Iteration2 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature

    #CICD report start#####################
    Given I define the following constants:
      | name        | value                                 |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | NRF_Traffic_with_Various_Locality - Two Iterations | Pass |
    #CICD report end#####################
