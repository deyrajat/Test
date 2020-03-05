###############################################################################################
# Date: <22/10/2018> Version: <Initial version: 18.5> $1Create by <abhijit bote, abote>
###############################################################################################
@static_testing

Feature: GR_Static_CallModel_Execution
    Scenario: Static Call models starts for Solution2 using calipers in GR

    Given I print: "****************************************** \n Creating static sessions   \n******************************************"
    Given I define the following constants:
              | name                     | value                    |
              | channelIndex             | 1                        |
              
    Given I expect the next test step to execute if '("{config.Call.Started.Using}" == "dstest")'
        When I execute the SSH command "/home/devsol/{config.Nodeglobal.remotepush.location.utilities.performevent.Name} -i {config.DsNode.SSH.EndpointIpAddress} -f {config.Callmodel.Def.Static.Dst.Path} -N "hss ocs cscf pcef tdf spr pcrf mme" -a "delete" " at DsNode

        When I execute the SSH command "sh /home/devsol/dsNodeStatusCheck.sh -I {config.DsNode.SSH.EndpointIpAddress} -F {config.Callmodel.Def.Static.Dst.Path} -S 5 -C 5" at DsNode
        Then I receive a SSH response and check the presence of following strings:
                | string                        | occurrence |
                | No nodes is created           | present |

        Given I wait for {config.global.constant.sixty} seconds

        When I execute the SSH command "dsClient -c "source {config.Callmodel.Def.Static.Dst.Path}""  at DsNode
        Given I wait for {config.global.constant.onehundred.twenty} seconds

        When I execute the SSH command " sh /home/devsol/dsNodeStatusCheck.sh -I {config.DsNode.SSH.EndpointIpAddress} -F {config.Callmodel.Def.Static.Dst.Path}" at DsNode
        Then I receive a SSH response and check the presence of following strings:
                | string                                        | occurrence |
                | All nodes are in the ready state              | present |

        Given I wait for {config.global.constant.sixty} seconds

        When I execute the SSH command "sh /root/tet_run_call_model.sh -d "{config.DsNode.SSH.EndpointIpAddress} {config.DsNode.SSH.EndpointIpAddress}" -l "{config.Static_Call_model_Rampup_script_input}" -t {config.Traffic_Rampingup_interval}" at DsNode
        Then I receive a SSH response and check the presence of following strings:
          | string                                                                                                                        | occurrence |
          | call model at MAX CCR-I rate of {config.CPS.Total.Static.CCRI.PerDomain.TPS}, Total rate = {config.CPS.Total.Static.CCRI.TPS} | present    |
    	
    Given I expect the next test steps to execute otherwise
		Given I expect the next test step to execute if '("{config.Call.Started.Using}" == "calipers")'
	        Given I expect the next test step to execute if ({config.Clear.sprFlag} > 0)
		        Given I execute the steps from {config.global.workspace.library.location-features-validations-common}{config.Call.Started.Using}Files/PCRF/ToolSidePreRun.feature
		        Given I loop {config.Static_ServerCfgCount} times
		            Given I setup a Calipers instance named {config.{config.tools.caliper.staticsession-instance-arrayprefix}{Constant.channelIndex}} using {config.Calipers.static.Config.dir}{config.{config.tools.caliper.staticsession-config-file-arrayprefix}{Constant.channelIndex}} at ToolAgent{Constant.channelIndex}
		            Then I get the {config.{config.tools.caliper.staticsession-instance-arrayprefix}{Constant.channelIndex}}.configstatus from ToolAgent{Constant.channelIndex} and validate the following attributes:
		              | attribute       | value                            |
		              | Response.Status | Success                          |
		              | Response.Info   | No errors in configuration file! |
		            Given I wait for {config.global.constant.fifteen} seconds
		            Then I increment Constant.channelIndex by 1
		        And I end loop
		        Given I loop {config.tools.caliper.static-client-cfg-count} times
		            Given I setup a Calipers instance named {config.{config.tools.caliper.staticsession-instance-arrayprefix}{Constant.channelIndex}} using {config.Calipers.static.Config.dir}{config.{config.tools.caliper.staticsession-config-file-arrayprefix}{Constant.channelIndex}} at ToolAgent{Constant.channelIndex}
		            Then I get the {config.{config.tools.caliper.staticsession-instance-arrayprefix}{Constant.channelIndex}}.configstatus from ToolAgent{Constant.channelIndex} and validate the following attributes:
		              | attribute       | value                            |
		              | Response.Status | Success                          |
		              | Response.Info   | No errors in configuration file! |
		            When I start {config.{config.tools.caliper.staticsession-instance-arrayprefix}{Constant.channelIndex}} call-model {config.{config.tools.caliper.staticsession-callmodel-name-arrayprefix}{Constant.channelIndex}} at ToolAgent{Constant.channelIndex}
		            Given I wait for {config.global.constant.fifteen} seconds
		            Then I increment Constant.channelIndex by 1
		        And I end loop
		    Given I expect the next test steps to execute otherwise
			    Given I expect the next test step to execute if ({config.Clear.sprFlag} == 0)
				    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}{config.Call.Started.Using}Files/PCRF/ToolSidePreRun.feature
			        Given I loop {config.tools.caliper.static-client-cfg-count} times
			            Given I setup a Calipers instance named {config.{config.tools.caliper.staticsession-instance-arrayprefix}{Constant.channelIndex}} using {config.Calipers.static.Config.dir}{config.{config.tools.caliper.staticsession-config-file-arrayprefix}{Constant.channelIndex}} at ToolAgent{Constant.channelIndex}
			            Then I get the {config.{config.tools.caliper.staticsession-instance-arrayprefix}{Constant.channelIndex}}.configstatus from ToolAgent{Constant.channelIndex} and validate the following attributes:
			              | attribute       | value                            |
			              | Response.Status | Success                          |
			              | Response.Info   | No errors in configuration file! |
			            When I start {config.{config.tools.caliper.staticsession-instance-arrayprefix}{Constant.channelIndex}} call-model {config.{config.tools.caliper.staticsession-callmodel-name-arrayprefix}{Constant.channelIndex}} at ToolAgent{Constant.channelIndex}
			            Given I wait for {config.global.constant.fifteen} seconds
			            Then I increment Constant.channelIndex by 1
			        And I end loop
			    Given I end the if
		    Given I end the if
		Given I end the if
    Given I end the if

    Then I wait for {config.global.constant.sixhundred} seconds
    
	Given I expect the next test step to execute if '("{config.Call.Started.Using}" == "calipers")'
        Given I execute the SSH command "pkill -f ToolAgent" at DsNode
        Given I execute the SSH command "pkill -f lattice" at DsNode
        Given I execute the SSH command "pkill -f cli" at DsNode	
    Given I end the if