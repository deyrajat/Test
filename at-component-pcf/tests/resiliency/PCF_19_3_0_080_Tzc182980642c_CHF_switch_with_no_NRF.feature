####################################################################################################
# Date: <15/05/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Resiliency @Tzc182980642c @F3190 @P3

Feature: PCF_19_3_0_080_Tzc182980642c_CHF_switch_with_no_NRF

  Scenario: CHF_switch_with_no_NRF 30 MINs - One Iterations

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
      | CHF_switch_with_no_NRF 30 MINs - One Iterations | Fail |
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

    Given I define the following constants:
      | name            | value    |
      | nrfCfgAddIndex  | 2        |

    When I execute the SSH command echo $(( {config.tools.caliper.nrf.totalfile-count} - {config.tools.caliper.nrf.clientfile-count} ))  at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | additionNrfFiles |

    #SFTP push of nrf specific calipers files
    Given I loop {SSH.additionNrfFiles} times

	    Given the SFTP push of file "{config.CalipersSourcePath}{config.{config.tools.caliper.nrf-config-file-arrayprefix}{Constant.nrfCfgAddIndex}}" to "{config.Calipers.Config.dir}" at SITEHOST is successful
	
	    When I execute using handler SITEHOST the parameterized command /root/AssignEndPointIpAddress.sh with following arguments:
	      | attribute | value                                                                                     |
	      | f         | {config.Calipers.Config.dir}{config.{config.tools.caliper.nrf-config-file-arrayprefix}{Constant.nrfCfgAddIndex}}  |
	      | c         | {config.{config.tools.caliper.nrf-callrate-arrayprefix}{Constant.nrfCfgAddIndex}}                            |
	      | L         | {config.ToolAgentHost.SSH.EndpointIpAddress}                                              |
	      | G         | {config.sut.vm.proto.n7client-vipaddress}                                                 |
	      | N         | {config.sut.vm.proto.n28client-vipaddress}                                                |   
	      | R         | {config.sut.vm.proto.rxclient-vipaddress}                                                 |
	      | p         | {config.Nrf1RegPort}                                                                      |
	      | q         | {config.Nrf2RegPort}                                                                      |
	      | r         | {config.Nrf3RegPort}                                                                      |
	      | s         | {config.sut.nrf.server1.ipaddress}                                                        |
	      | t         | {config.sut.nrf.server2.ipaddress}                                                        |
	      | u         | {config.sut.nrf.server3.ipaddress}                                                        |
	      
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

    ### Check that all the Server ports for CHF are active    
    Given I define the following constants:
      | name            | value    |
      | nrfCfgStopIndex | 1        |    
      | nrfCfgIndex     | 1        |
      
    Given I loop {config.tools.caliper.nrf.totalfile-count} times
    
    When I execute the SSH command netstat -antlop | grep {config.sut.nrf.server{Constant.nrfCfgIndex}.ipaddress} | grep {config.{config.global.scenario.resiliency.caliper.nrf-dynamic-port-arrayprefix}{Constant.nrfCfgIndex}} at ToolAgentHost
    Then I receive a SSH response and check the presence of following strings:
        | string          | occurrence |
        | ESTABLISHED     | present    |
	        
      Then I increment Constant.nrfCfgIndex by 1

    And I end loop

    When I execute the SSH command netstat -antlop | grep {config.tools.toolagent.ipaddress1} | grep {config.global.scenario.resiliency.caliper.chf-local-port} at ToolAgentHost
    Then I receive a SSH response and check the presence of following strings:
        | string          | occurrence |
        | ESTABLISHED     | present    |
        
    Given I define the following constants:
      | name            | value    |
      | nrfCfgStopIndex | 1        | 

    ### Now Kill the NRF Nodes to remove the Subscribed CHF
    
    Given I expect the next test step to execute if ({config.sut.nrf.external.use-enable} < 1)

	    Given I loop {config.tools.caliper.nrf.totalfile-count} times
	
	       Given I delete the {config.{config.tools.caliper.nrf-instance-arrayprefix}{Constant.nrfCfgStopIndex}}.configuration at ToolAgent{Constant.nrfCfgStopIndex} 
	
	       Then I increment Constant.nrfCfgStopIndex by 1
	
	    And I end loop
	
	    Then I wait for {config.global.constant.ninety} seconds
	    
	  Given I end the if

    ### Check that all the Server ports for CHF are still active    
    Given I define the following constants:
      | name            | value    |
      | nrfCfgStopIndex | 1        |    
      
    Given I loop {config.tools.caliper.nrf.totalfile-count} times
    
    When I execute the SSH command netstat -antlop | grep {config.sut.nrf.server{Constant.nrfCfgStopIndex}.ipaddress} | grep {config.{config.global.scenario.resiliency.caliper.nrf-dynamic-port-arrayprefix}{Constant.nrfCfgStopIndex}} at ToolAgentHost
    Then I receive a SSH response and check the presence of following strings:
        | string          | occurrence |
        | ESTABLISHED     | present    |
	        
      Then I increment Constant.nrfCfgStopIndex by 1

    And I end loop

    When I execute the SSH command netstat -antlop | grep {config.tools.toolagent.ipaddress1} | grep {config.global.scenario.resiliency.caliper.chf-local-port} at ToolAgentHost
    Then I receive a SSH response and check the presence of following strings:
        | string          | occurrence |
        | ESTABLISHED     | present    |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                  |
      | (.*)      | event_start_epoch_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.global.scenario.resiliency.caliper.nrf-subscription-validity} seconds

    ### Check that the dynamic Server ports are present
    Given I define the following constants:
      | name            | value    |
      | nrfCfgStopIndex | 1        |    
      
    Given I loop {config.tools.caliper.nrf.totalfile-count} times
    
    When I execute the SSH command netstat -antlop | grep {config.sut.nrf.server{Constant.nrfCfgStopIndex}.ipaddress} | grep {config.{config.global.scenario.resiliency.caliper.nrf-dynamic-port-arrayprefix}{Constant.nrfCfgStopIndex}} at ToolAgentHost
    Then I receive a SSH response and check the presence of following strings:
        | string          | occurrence |
        | ESTABLISHED     | present     |
	        
      Then I increment Constant.nrfCfgStopIndex by 1

    And I end loop

    When I execute the SSH command netstat -antlop | grep {config.tools.toolagent.ipaddress1} | grep {config.global.scenario.resiliency.caliper.chf-local-port} at ToolAgentHost
    Then I receive a SSH response and check the presence of following strings:
        | string          | occurrence |
        | ESTABLISHED     | present    |

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
      | name        | value                                 |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | CHF_switch_with_no_NRF 30 MINs - One Iterations | Pass |
    #CICD report end#####################
