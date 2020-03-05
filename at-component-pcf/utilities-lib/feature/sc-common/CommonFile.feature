#################################################################################################
# Date: <03/07/2018> Version: <Initial version: 18.0> $1Created by <bhchauha>
#################################################################################################

Feature: Define_ExecutionDetails

Scenario: Set Value of loopcount and Installer Instance

Given I expect the next test step to execute if '("{Config.sut.setup.deployment.type}" == "PUPPETQNSHA")'

    Given I define the following constants:
      | name          | value       |
      | hostname_1    | Installer   |
      | loopCount     | 1           |
      | channelIndex  | 1	        |

Given I expect the next test steps to execute otherwise
    Given I expect the next test step to execute if '("{Config.sut.setup.deployment.type}" == "PUPPETQNSGR" && {Constant.sitestobevalidated} == 2)'
	    #Given I expect the next test step to execute if ({Constant.sitestobevalidated} == 2)
	
	    Given I define the following constants:
	      | name          | value       |
	      | hostname_1    | Site1_CM1   |
	      | hostname_2    | Site2_CM1   |
	      | loopCount     | 2           |
	      | channelIndex  | 1           |
            
    Given I expect the next test steps to execute otherwise
    
        Given I expect the next test step to execute if '("{Config.sut.setup.deployment.type}" == "PUPPETQNSGR" && {Constant.sitestobevalidated} == 1 && "{Constant.triggeredSite}" == "site1")'
	        #Given I expect the next test step to execute if '({Constant.sitestobevalidated} == 1)'
	        #Given I expect the next test step to execute if '("{Constant.triggeredSite}" == "site1")'
	        Given I define the following constants:
	          | name          | value        |
	          | hostname_2    | Site2_CM1    |
	          | loopCount     | 1            |
	          | channelIndex  | 2	         |

        Given I expect the next test steps to execute otherwise
            Given I expect the next test step to execute if '("{Config.sut.setup.deployment.type}" == "PUPPETQNSGR" && {Constant.sitestobevalidated} == 1 && "{Constant.triggeredSite}" == "site2")'
                #Given I expect the next test step to execute if '({Constant.sitestobevalidated} == 1)'
                #Given I expect the next test step to execute if '("{Constant.triggeredSite}" == "site2")'
                Given I define the following constants:
                  | name          | value        |
                  | hostname_1    | Site1_CM1    |
                  | loopCount     | 1            |
                  | channelIndex  | 1            |
            
            Given I end the if
        
        Given I end the if
    
    Given I end the if
     
Given I end the if