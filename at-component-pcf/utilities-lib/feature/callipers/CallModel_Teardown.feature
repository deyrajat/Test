##########################################################################################
# Date: <01/02/2016> Version: <Initial version: 9.0> $1Create by <Suvajit Nandy, suvnandy>
##########################################################################################

@RESILIENCY

Feature: CallModel_Teardown_Calipers

  Scenario: Teardown steps for Resiliency for Calipers based feature files

    #Stopping the ToolAgent Execution

    Given I execute the SSH command curl --request GET --url {config.ToolAgent1.EndpointAddress}/calipers/statistics  > /root/ToolAgent_Calipers_Stat.txt at ToolAgentHost

    Given I expect the next test step to execute if ({config.scenario.start.traffic} > 0)  

		Given I execute the SSH command "pkill -f ToolAgent" at ToolAgentHost
		Given I execute the SSH command "pkill -f lattice" at ToolAgentHost
		Given I execute the SSH command "pkill -f cli" at ToolAgentHost

		Given the SFTP pull of file /root/ToolAgent_Calipers_Stat.txt at ToolAgentHost to "log/" is successful

		Given I execute the SSH command rm -rf /root/ToolAgent_Calipers_Stat.txt at ToolAgentHost

    ## Now Delete all CDL session.    
    When I execute the SSH command {config.global.command.opsCenter.clear-all-sessions} at CLIPcfOPSCenter
    
    Then I wait for {config.sut.clear.session-action.wait-duration} seconds
    
    Given I loop {config.sut.clear.session-action.iterations} times
    
	    When I execute the SSH command {config.global.command.opsCenter.total-session-count} at CLIPcfOPSCenter
		  Then I save the SSH response in the following variables:
		  	| attribute       | value         |
		  	| (count\s+\d+)   | count_val	    |    
		  	
      When I execute using handler SITEHOST the SSH command "echo {SSH.count_val}"
      Then I save the SSH response in the following variables:
        | attribute             | value       |
        | {Regex}(\d+)          | count_val   |
			
 			Given I break loop if ({SSH.count_val} <= 0)

	  	Then I wait for {config.sut.clear.session-action.wait-duration} seconds

	  And I end loop 	    
    
    Then I wait for {config.sut.clear.session-action.wait-duration} seconds

    When I execute the SSH command {config.global.command.opsCenter.total-session-count} at CLIPcfOPSCenter
    Then I receive a SSH response and check the presence of following strings:
      | string      | occurrence  |
      | count 0     | present     |

	Given I end the if