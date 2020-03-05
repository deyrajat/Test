############################################################################################
# Date: <02/01/2016> Version: <Initial version: 18.5> $1Create by <Sandeep Talukdar, santaluk>
############################################################################################

@SetupTest_Resiliency_PCF

Feature: PCF_19_3_0_SetupTest_Modular_Resiliency

Scenario: Setup test to run Resiliency TestSuite

    Given the connection to QNS is established for SSH,ToolAgent successfully
    
    Given I execute the steps from {config.global.workspace.library.location-features-setuptest}PrintExecutionConfigurations.feature
    
    Given I execute the steps from {config.global.workspace.library.location-features-setuptest}StartupUtilityDependencyManager.feature
       
    Given I execute the steps from {config.global.workspace.library.location-features-setuptest}TrafficInitiator.feature

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}InitKPIStatusForSVReport.feature

    Then I update report for table preExecution with the following details:
      | Pre-Callmodel checks | Fail | {config.global.report.comment.swap.fail}  |

    Then I update report for table preExecution with the following details:
      | Pre-Callmodel checks | Pass | All generic activities completed successfully. |
	Then I update report for table preExecution with the following details:
      | Pre-Callmodel checks | | APPEND({config.global.report.comment.swap.pass}) |
    #CICD Test report end