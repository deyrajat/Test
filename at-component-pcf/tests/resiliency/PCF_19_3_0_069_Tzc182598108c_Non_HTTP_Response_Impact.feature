################################################################################################
# Date: <13/02/2018> Version: <Initial version: 18.0.1> $1Create by <Sandeep Talukdar, santaluk>
################################################################################################
@PCF @Resiliency @Tzc182598108c @P2 @PcfResP2Set2

Feature: PCF_19_3_0_069_Tzc182598108c_Non_HTTP_Response_Impact

  Scenario: PCF Non HTTP Response Impact One Iterations

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
      | PCF Non HTTP Response Impact - One Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  
    
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

    Given I define the following constants:
      | name              | value      |
      | callStartIndex    | 1          |
      | callStopIndex     | 1          |

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

	  Then I wait for {config.scenario.exec-params.small-benchmark-interval} seconds

	  When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time | 

    #Get Benchmark values
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Benchmark.feature
    
    #Get the current Pod Restart count
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | pod_res_cnt_time |

    Then I wait for {config.global.constant.sixty} seconds

    When I execute the SSH command echo '&start={SSH.pod_res_cnt_time}&end={SSH.pod_res_cnt_time}&step=1' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value     |
      | (.*)      | TimeQuery |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Pod_Restart_count}{SSH.TimeQuery}" {config.Grafana.Authorization1} {config.Value.Extrator} at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | presentRestartCnt |

    Given I loop {config.tools.caliper.non-http-count} times

	    Given the SFTP push of file "{config.CalipersSourcePath}{config.{config.tools.caliper.nonhttp-config-file-arrayprefix}{Constant.callStartIndex}}" to "{config.Calipers.Config.dir}" at SITEHOST is successful
	
	    When I execute using handler SITEHOST the parameterized command /root/AssignEndPointIpAddress.sh with following arguments:
	      | attribute | value                                                    |
	      | f         | {config.Calipers.Config.dir}{config.{config.tools.caliper.nonhttp-config-file-arrayprefix}{Constant.callStartIndex}}    |
	      | c         | {config.{config.tools.caliper.nonhttp-callrate-arrayprefix}{Constant.callStartIndex}}                                |
	      | L         | {config.{config.tools.caliper.nonhttp-localIp-arrayprefix}{Constant.callStartIndex}}             |
        | G         | {config.sut.vm.proto.n7client-vipaddress}                                                                      |
        | N         | {config.sut.vm.proto.n28client-vipaddress}                                                                     |
        | R         | {config.sut.vm.proto.rxclient-vipaddress}                                                                      |
	      | p         | {config.Nrf1RegPort}                                     |
	      | q         | {config.Nrf2RegPort}                                     |
	      | r         | {config.Nrf3RegPort}                                     |
	      | b         | {config.{config.tools.caliper.non-http-event-bridge-port-arrayprefix}{Constant.callStartIndex}}                     |
        | s         | {config.sut.nrf.server1.ipaddress}                                                               |
        | t         | {config.sut.nrf.server2.ipaddress}                                                             |
        | u         | {config.sut.nrf.server3.ipaddress}                                                              |
	
	    Given I setup a Calipers instance named {config.{config.tools.caliper.nonhttp-instance-arrayprefix}{Constant.callStartIndex}} using {config.Calipers.Config.dir}{config.{config.tools.caliper.nonhttp-config-file-arrayprefix}{Constant.callStartIndex}} at ToolAgentNonHttp{Constant.callStartIndex}
	    Then I get the {config.{config.tools.caliper.nonhttp-instance-arrayprefix}{Constant.callStartIndex}}.configstatus from ToolAgentNonHttp{Constant.callStartIndex} and validate the following attributes:
	      | attribute       | value                            |
	      | Response.Status | Success                          |
	      | Response.Info   | No errors in configuration file! |
	
	    When I start {config.{config.tools.caliper.nonhttp-instance-arrayprefix}{Constant.callStartIndex}} call-model {config.NonHttp_cm_name} at ToolAgentNonHttp{Constant.callStartIndex}
	    
      Then I increment Constant.callStartIndex by 1
      
    And I end loop

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.small-benchmark-interval} seconds 

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    When I execute the SSH command echo '&start={SSH.grafana_start_time}&end={SSH.grafana_stop_time}&step={config.Step_Duration}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value     |
      | (.*)      | TimeQuery |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.NonHttp_OutErrors_Query}{SSH.TimeQuery}" {config.Grafana.Authorization1} {config.Value.Extrator} at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value        |
      | (.*)      | nonHTTPError |

    #### Check that the 400 messages are generated or not
    When I execute the SSH command echo {SSH.nonHTTPError} at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value          | occurrence |
      | {Regex}(.*) | greaterthan(0) | present    |
      
    Given I loop {config.tools.caliper.non-http-count} times

     When I stop the {config.{config.tools.caliper.nonhttp-instance-arrayprefix}{Constant.callStopIndex}} call-model {config.NonHttp_cm_name} at ToolAgentNonHttp{Constant.callStopIndex}

     Given I wait for {config.global.constant.sixty} seconds
     
      Then I increment Constant.callStopIndex by 1
      
    And I end loop     
    
    #Get the current Pod Restart count and compare
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | pod_res_cnt_time |

    When I execute the SSH command echo '&start={SSH.pod_res_cnt_time}&end={SSH.pod_res_cnt_time}&step=1' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value     |
      | (.*)      | TimeQuery |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Pod_Restart_count}{SSH.TimeQuery}" {config.Grafana.Authorization1} {config.Value.Extrator} at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value         |
      | (.*)      | newRetCnt     |
    Then I validate the following attributes:
      | attribute             | value                      |
      | {SSH.presentRestartCnt}   | EQUAL({SSH.newRetCnt}) |
      
    Then I wait for {config.global.constant.threehundred} seconds 
    
    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.small-benchmark-interval} seconds

    When I execute using handler K8SMaster the SSH shell command "date +%s"
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
      | PCF Non HTTP Response Impact - One Iterations | Pass |
    #CICD report end##################### 
