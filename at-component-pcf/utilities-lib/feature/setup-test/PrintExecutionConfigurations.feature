############################################################################################
# Date: <02/01/2016> Version: <Initial version: 18.5> $1Create by <Sandeep Talukdar, santaluk>
############################################################################################

@Setup_Execution_Configurations

Feature: Print_Execution_configurations

Scenario: Creates static sessions and start traffic for creating make-break sessions

    Given I print:====================== Automation Execution and Validation Parameters List Start  =========================
    #Given I print:1.  Solution.Scenario.loopCount = {config.Solution.Scenario.loopCount}
    Given I print:2.  global.thresholds.application.alloweddeviationpercent-tps = {config.global.thresholds.application.alloweddeviationpercent-tps}
    Given I print:3.  global.thresholds.application.alloweddeviationpercent-response-time = {config.global.thresholds.application.alloweddeviationpercent-response-time}
    Given I print:4.  scenario.thresholds.application.expected-tps = {config.scenario.thresholds.application.expected-tps}
    Given I print:5.  global.thresholds.application-error-precentage = {config.global.thresholds.application-error-precentage}
    Given I print:6. global.thresholds.application.alloweddeviationpercent-event-error = {config.global.thresholds.application.alloweddeviationpercent-event-error}
    #Given I print:7. CPS.CPU.Error.Threshold = {config.CPS.CPU.Error.Threshold}
    #Given I print:8. CPS.CPU.Error.Count = {config.CPS.CPU.Error.Count}
    Given I print:====================== Automation Execution and Validation Parameters List End  ===========================
