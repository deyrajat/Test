###############################################################################################
# Date: <15/12/2017> Version: <Initial version: 18.0> $1Create by <Soumil Chatterjee, soumicha>
###############################################################################################
@CallStart

Feature: CallModel_Execution

  Scenario: Call models starts for PCF using calipers

    Given I define the following constants:
      | name             | value      |
      | channelIndex     | 1          |
      | nrfCfgIndex      | 1          |

    Given I expect the next test step to execute if ({config.scenario.start.traffic} > 0)

	    When I execute the SSH command {config.sut.k8smaster.home.directory}/checkMinionCPUAverage.sh {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} at K8SMaster
	    Then I receive a SSH response and check the presence of following strings:
	      | string               | occurrence |
	      | Load Average is more | absent     |
	      | Load Average is less | present    |

      	Given I expect the next test step to execute if ({config.sut.nrf.external.use-enable} < 1)
      
		    #Source NRF files
		    Given I loop {config.tools.caliper.nrf.file-count} times
	
			    Given I setup a Calipers instance named {config.{config.tools.caliper.nrf-instance-arrayprefix}{Constant.nrfCfgIndex}} using {config.Calipers.Config.dir}{config.{config.tools.caliper.nrf-config-file-arrayprefix}{Constant.nrfCfgIndex}} at ToolAgentNRF{Constant.nrfCfgIndex}
			    Then I get the {config.{config.tools.caliper.nrf-instance-arrayprefix}{Constant.nrfCfgIndex}}.configstatus from ToolAgentNRF{Constant.nrfCfgIndex} and validate the following attributes:
			      | attribute       | value                            |
			      | Response.Status | Success                          |
			      | Response.Info   | No errors in configuration file! |
		
			    Then I wait for {config.global.constant.onehundred.twenty} seconds
		
			    Then I increment Constant.nrfCfgIndex by 1
	
		    And I end loop
		    
	    Given I end the if

	    #Source Solution files   
	    Given I loop {config.ClientCfgCount} times

		    Given I setup a Calipers instance named {config.{config.tools.caliper.instance-arrayprefix}{Constant.channelIndex}} using {config.Calipers.Config.dir}{config.{config.tools.caliper.cfg-files-arrayprefix}{Constant.channelIndex}} at ToolAgent{Constant.channelIndex}
		    Then I get the {config.{config.tools.caliper.instance-arrayprefix}{Constant.channelIndex}}.configstatus from ToolAgent{Constant.channelIndex} and validate the following attributes:
		      | attribute       | value                            |
		      | Response.Status | Success                          |
		      | Response.Info   | No errors in configuration file! |
		    When I start {config.{config.tools.caliper.instance-arrayprefix}{Constant.channelIndex}} call-model {config.{config.tools.caliper.callmodel-arrayprefix}{Constant.channelIndex}} at ToolAgent{Constant.channelIndex}
	
		    Given I wait for {config.global.constant.thirty} seconds
		    
    	    ### Get the status of the process that were started/re-started
    
		    Given I execute the SSH command ps -ef | grep lattice | grep -v grep  at ToolAgentHost
		  
		    Given I execute the SSH command ps -ef | grep cli | grep -v grep  at ToolAgentHost
	
		    Then I increment Constant.channelIndex by 1

	    And I end loop

	    ### Added Additional wait for Call Model Stabilization
	    Then I wait for {config.global.constant.onehundred.fifty} seconds
	    
	    When I execute the SSH command ps -ef | grep lattice at ToolAgentHost
	    
	    Given I print:========== Show the ports that are started ============
	    When I execute the SSH command netstat -antlop | grep {config.tools.toolAgent.ipaddress.internal} at ToolAgentHost

	Given I end the if

    When I execute the SSH command "date +'%H:%M_%Y%m%d'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value           |
      | (.*)      | call_start_time |
      
    Given I print:========== Call Start time is {SSH.call_start_time} ===============

    Given I print:====================== PCF Engine Status  =========================

    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep pcf-engine-{config.sut.k8s.namespace.pcf}-pcf-engine-app at K8SMaster

    Given I print:====================== PCF Engine Status  =========================