############################################################################################
# Date: <06/25/2018> Version: <Initial version: 19.4> $1Create by <Sandeep Talukdar, santaluk>
############################################################################################
##Static session for pcf done here 
@CallStartStatic

Feature: PCF_Static_Session_Calipers

Scenario: Load the Statis session at the start 

    Given I define the following constants:
	      | name                     | value                    |
	      | channelIndex             | 1                        |
	      | channelIndexExec         | 1                        |
	      
    Given I execute the SSH command "mkdir -m 755 -p {config.Calipers.static.Config.dir}" at SITEHOST
    
    #SFTP push of Static calipers files
    Given I loop {config.tools.caliper.static-client-cfg-count} times	    
    
    Given the SFTP push of file "{config.CalipersSourcePath}{config.{config.tools.caliper.staticsession-config-file-arrayprefix}{Constant.channelIndex}}" to "{config.Calipers.static.Config.dir}" at SITEHOST is successful 
    
        When I execute using handler SITEHOST the parameterized command {config.global.remotepush.sitehost-location.utilities}/AssignSubscriberInfo.sh with following arguments:
          | attribute | value                                                                                                          |
          | f         | {config.Calipers.static.Config.dir}{config.{config.tools.caliper.staticsession-config-file-arrayprefix}{Constant.channelIndex}}       |
          | S         | {config.tools.calipers.{config.{config.tools.caliper.static-subscriber-cm-arrayprefix}{Constant.channelIndex}}.SUPI}  |
          | G         | {config.tools.calipers.{config.{config.tools.caliper.static-subscriber-cm-arrayprefix}{Constant.channelIndex}}.GPSI}  |
          | P         | {config.tools.calipers.{config.{config.tools.caliper.static-subscriber-cm-arrayprefix}{Constant.channelIndex}}.PEI}   |
          | i         | {config.tools.calipers.{config.{config.tools.caliper.static-subscriber-cm-arrayprefix}{Constant.channelIndex}}.IPv4}  |
          | s         | {config.tools.calipers.{config.{config.tools.caliper.static-subscriber-cm-arrayprefix}{Constant.channelIndex}}.IPv6}  |
    
	When I execute using handler SITEHOST the parameterized command /root/AssignEndPointIpAddress.sh with following arguments:
	      | attribute | value                                       |
	      | f         | {config.Calipers.static.Config.dir}{config.{config.tools.caliper.staticsession-config-file-arrayprefix}{Constant.channelIndex}}  |
	      | c         | {config.{config.tools.caliper.staticsession-callrate-arrayprefix}{Constant.channelIndex}}                             	    |
	      | L         | {config.OriginHostIpAddress_4}                                                                    |
	      | G         | {config.sut.vm.proto.n7client-vipaddress}                                                         |
	      | R         | {config.sut.vm.proto.rxclient-vipaddress}                                                         |    
        
    Then I increment Constant.channelIndex by 1
    And I end loop 
    
    #Source Solution files   
    Given I loop {config.tools.caliper.static-client-cfg-count} times	 

    Given I setup a Calipers instance named {config.{config.tools.caliper.staticsession-instance-arrayprefix}{Constant.channelIndexExec}} using {config.Calipers.static.Config.dir}{config.{config.tools.caliper.staticsession-config-file-arrayprefix}{Constant.channelIndexExec}} at ToolAgentStatic
    Then I get the {config.{config.tools.caliper.staticsession-instance-arrayprefix}{Constant.channelIndexExec}}.configstatus from ToolAgentStatic and validate the following attributes:
      | attribute       | value                            |
      | Response.Status | Success                          |
      | Response.Info   | No errors in configuration file! |
    When I start {config.{config.tools.caliper.staticsession-instance-arrayprefix}{Constant.channelIndexExec}} call-model {config.{config.tools.caliper.staticsession-callmodel-name-arrayprefix}{Constant.channelIndexExec}} at ToolAgentStatic

    Given I wait for {config.global.constant.thirty} seconds

    Then I increment Constant.channelIndex by 1

    And I end loop
    
    Then I wait for {config.global.constant.sixhundred} seconds
    
    Given I execute the SSH command "pkill -f ToolAgent" at ToolAgentHost
    Given I execute the SSH command "pkill -f lattice" at ToolAgentHost
    Given I execute the SSH command "pkill -f cli" at ToolAgentHost    
    
    When I execute the SSH command {config.global.command.opsCenter.total-session-count} at CLIPcfOPSCenter
	  Then I save the SSH response in the following variables:
	  	| attribute       | value           |
	  	| (count\s+\d+)   | count_val	    |    
		
    When I execute using handler SITEHOST the SSH command "echo {SSH.count_val}"
    Then I receive a SSH response and check the presence of following strings:
      | string          | value                                    | occurrence |
      | {Regex}(\d+)  	| greaterthan({config.CPS.StaticSubCount}) | present    |
    
    Given I wait for {config.global.constant.ten} seconds      
    
    Given I execute the SSH command "cd {config.ToolAgentPath}; ./ToolAgent 9000 4 enable-file-logging > /dev/null 2>&1 & disown" at ToolAgentHost

    Given I wait for {config.global.constant.thirtyfive} seconds  
    