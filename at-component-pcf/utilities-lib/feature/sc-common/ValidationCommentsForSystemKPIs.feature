#Author: your.email@your.domain.com
#Keywords Summary :
#Feature: List of scenarios.
#Scenario: Business rule through list of steps with arguments.
#Given: Some precondition step
#When: Some key actions
#Then: To observe outcomes or validation
#And,But: To enumerate more Given,When,Then steps
#Scenario Outline: List of steps for data-driven as an Examples and <placeholder>
#Examples: Container for s table
#Background: List of steps run before each of the scenarios
#""" (Doc Strings)
#| (Data Tables)
#@ (Tags/Labels):To group Scenarios
#<> (placeholder)
#""
## (Comments)
#Sample Feature Definition Template
@tag
Feature: ValidateKPIComments
  Scenario: Update the pass or fail count for each KPI

    #System KPIs
    When I execute using handler SITEHOST the SSH shell command "/root/updateCheckComments.sh CPU {Constant.CPUstatus}"
    When I execute using handler SITEHOST the SSH shell command "/root/updateCheckComments.sh SWAP {Constant.SWAPstatus}"