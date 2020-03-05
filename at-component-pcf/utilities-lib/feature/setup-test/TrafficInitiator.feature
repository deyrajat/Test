############################################################################################
# Date: <02/01/2016> Version: <Initial version: 18.5> $1Create by <Sandeep Talukdar, santaluk>
############################################################################################

@Setup_Traffic_Initiate

Feature: Traffic_Initiate

Scenario: Creates static sessions and start traffic for creating make-break sessions

     Given I expect the next test step to execute if ({config.scenario.start.traffic} > 0)    
        Given I execute the SSH command "pkill -f ToolAgent" at ToolAgentHost
        Given I execute the SSH command "pkill -f lattice" at ToolAgentHost
        Given I execute the SSH command "pkill -f cli" at ToolAgentHost

        Given I execute the SSH command "rm -rf ToolAgent.*" at ToolAgentHost
        Given I execute the SSH command "rm -rf core.*" at ToolAgentHost  
        When I execute the SSH command "rm -rf /tmp/taas/*" at ToolAgentHost

        Then I wait for {config.global.constant.ten} seconds

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

		    #Addtional PreRun Steps for specific Tools
		    Given I execute the steps from {config.global.workspace.library.location-features-calipers}ToolSidePreRun.feature
	
		    Given I expect the next test step to execute if ({config.ToolAgentStatic.Enable.StaticSessionCreation} > 0)    
			    #Create Static Sessions
			    Given I execute the steps from {config.global.workspace.library.location-features-calipers}Create_Static_Session.feature
		    Given I end the if
		    
    Given I end the if

    #External SetupTest File
    Given I execute the steps from {config.global.workspace.library.location-features-calipers}CallModel_SetupTest.feature

    #call Start
    Given I execute the steps from {config.global.workspace.library.location-features-calipers}CallModel_Execution.feature