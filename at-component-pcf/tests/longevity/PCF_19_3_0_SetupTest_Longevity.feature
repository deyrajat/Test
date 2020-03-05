############################################################################################
# Date: <02/01/2016> Version: <Initial version: 18.5> $1Create by <Sandeep Talukdar, santaluk>
############################################################################################

@SetupTest_Longevity_PCF

Feature: PCF_19_3_0_SetupTest_Longevity

Scenario: Setup test to run Longevity TestSuite

    Given the connection to QNS is established for SSH,WSClient,ToolAgent successfully

    Given I execute the steps from {config.global.workspace.library.location-features-setuptest}PrintExecutionConfigurations.feature
    
    Given I execute the steps from {config.global.workspace.library.location-features-setuptest}StartupUtilityDependencyManager.feature
       
    Given I execute the steps from {config.global.workspace.library.location-features-setuptest}TrafficInitiator.feature

    #External PreRun File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}PreRun.feature

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}InitKPIStatusForSVReport.feature

    Then I update report for table preExecution with the following details:
      | Pre-Callmodel checks | Fail | {config.global.report.comment.swap.fail}  |

    #Checking swap memory
    When I execute using handler Installer the SSH shell command {config.Swap.Memory.Command}
    Then I receive a SSH response and check the presence of following strings:
      | string      | occurrence |
      | FAIL        | absent     |

    Then I update report for table preExecution with the following details:
      | Pre-Callmodel checks | Pass | All generic activities completed successfully. |
	Then I update report for table preExecution with the following details:
      | Pre-Callmodel checks | | APPEND({config.global.report.comment.swap.pass}) |
    #CICD Test report end