##########################################################################################
# Date: <01/02/2016> Version: <Initial version: 9.0> $1Create by <Suvajit Nandy, suvnandy>
##########################################################################################
##Custom Teardown steps written in this file

@UpdateSVResult

Feature: BuildValidation_Suite_Teardown

Scenario: Teardown steps for BuildValidation TestSuite
    
    Given I define the following constants:
      | name     | value               |
      | testkpi  | applicationLevelKpi |
      | testkpi2 | systemKpi           |
    	
    #CICD Test report start
    #Retrive the comment and overall status for the Diameter error percentage and set in report
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh DEP | awk '{print $1}'"
    Then I save the SSH response in the following variables:
      | attribute  | value         |
      | (.*)       | finalStatus   |
      
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh DEP | awk '{print $2}'"
    Then I save the SSH response in the following variables:
      | attribute  | value     |
      | (.*)       | comment   |
      
    Then I update report for table {Constant.testkpi} with the following details:
      | {config.global.report.label.dep} | {SSH.finalStatus} | {SSH.comment} |
      
    Given I expect the next test step to execute if '("{SSH.finalStatus}" == "Pass")'
    Then I update report for table {Constant.testkpi} with the following details:
      | {config.global.report.label.dep} | {SSH.finalStatus} | APPEND({config.global.report.comment.dep-pass} {config.global.thresholds.application-error-precentage}%) |
    Given I expect the next test steps to execute otherwise
    Then I update report for table {Constant.testkpi} with the following details:
      | {config.global.report.label.dep} | {SSH.finalStatus} | APPEND({config.global.report.comment.dep-fail} {config.global.thresholds.application-error-precentage}%) |
    Given I end the if
    
    #Retrive the comment and overall status for the Diameter timeout percentage and set in report
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh DTP | awk '{print $1}'"
    Then I save the SSH response in the following variables:
      | attribute  | value         |
      | (.*)       | finalStatus   |
      
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh DTP | awk '{print $2}'"
    Then I save the SSH response in the following variables:
      | attribute  | value     |
      | (.*)       | comment   |
      
    Then I update report for table {Constant.testkpi} with the following details:
      | {config.global.report.label.dtp} | {SSH.finalStatus} | {SSH.comment} |
      
    Given I expect the next test step to execute if '("{SSH.finalStatus}" == "Pass")'
    Then I update report for table {Constant.testkpi} with the following details:
      | {config.global.report.label.dtp} | {SSH.finalStatus} | APPEND({config.global.report.comment.dtp-pass} {config.global.thresholds.application-error-precentage}%) |
    Given I expect the next test steps to execute otherwise
    Then I update report for table {Constant.testkpi} with the following details:
      | {config.global.report.label.dtp} | {SSH.finalStatus} | APPEND({config.global.report.comment.dtp-fail} {config.global.thresholds.application-error-precentage}%) |
    Given I end the if
      
    #Retrive the comment and overall status for the Diameter Response Time and set in report
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh DRT | awk '{print $1}'"
    Then I save the SSH response in the following variables:
      | attribute  | value         |
      | (.*)       | finalStatus   |
      
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh DRT | awk '{print $2}'"
    Then I save the SSH response in the following variables:
      | attribute  | value     |
      | (.*)       | comment   |
      
    Then I update report for table {Constant.testkpi} with the following details:
      | {config.global.report.label.drt} | {SSH.finalStatus} | {SSH.comment} |
      
    Given I expect the next test step to execute if '("{SSH.finalStatus}" == "Pass")'
    Then I update report for table {Constant.testkpi} with the following details:
      | {config.global.report.label.drt} | {SSH.finalStatus} | APPEND({config.global.report.comment.drt-pass} {config.global.thresholds.application-error-precentage}%) |
    Given I expect the next test steps to execute otherwise
    Then I update report for table {Constant.testkpi} with the following details:
      | {config.global.report.label.drt} | {SSH.finalStatus} | APPEND({config.global.report.comment.drt-fail} {config.global.thresholds.application-error-precentage}%) |
    Given I end the if
      
    #Retrive the comment and overall status for the Additional Checks and set in report
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh AC | awk '{print $1}'"
    Then I save the SSH response in the following variables:
      | attribute  | value         |
      | (.*)       | finalStatus   |
      
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh AC | awk '{print $2}'"
    Then I save the SSH response in the following variables:
      | attribute  | value     |
      | (.*)       | comment   |
      
    Then I update report for table {Constant.testkpi} with the following details:
      | {config.global.report.label.additionalchecks} | {SSH.finalStatus} | {SSH.comment} |
      
    #Retrive the comment and overall status for the CPU and set in report
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh CPU | awk '{print $1}'"
    Then I save the SSH response in the following variables:
      | attribute  | value         |
      | (.*)       | finalStatus   |
      
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh CPU | awk '{print $2}'"
    Then I save the SSH response in the following variables:
      | attribute  | value     |
      | (.*)       | comment   |
      
    Then I update report for table {Constant.testkpi2} with the following details:
      | {config.global.report.label.cpuusage} | {SSH.finalStatus} | {SSH.comment} |
    
    Given I expect the next test step to execute if '("{SSH.finalStatus}" == "Pass")'
    Then I update report for table {Constant.testkpi2} with the following details:
      | {config.global.report.label.cpuusage} | {SSH.finalStatus} | APPEND({config.global.report.comment.cpusuage-pass} {config.global.thresholds.system.cpu-used}) |
    Given I expect the next test steps to execute otherwise
    Then I update report for table {Constant.testkpi2} with the following details:
      | {config.global.report.label.cpuusage} | {SSH.finalStatus} | APPEND({config.global.report.comment.cpusuage-fail} {config.global.thresholds.system.cpu-used}) |
    Given I end the if
      
    #Retrive the comment and overall status for the SWAP and set in report
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh SWAP | awk '{print $1}'"
    Then I save the SSH response in the following variables:
      | attribute  | value         |
      | (.*)       | finalStatus   |
      
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh SWAP | awk '{print $2}'"
    Then I save the SSH response in the following variables:
      | attribute  | value     |
      | (.*)       | comment   |
    
    Then I update report for table {Constant.testkpi2} with the following details:
      | {config.global.report.label.swap} | {SSH.finalStatus} | {SSH.comment} |
      
    Given I expect the next test step to execute if '("{SSH.finalStatus}" == "Pass")'
    Then I update report for table {Constant.testkpi2} with the following details:
      | {config.global.report.label.swap} | {SSH.finalStatus} | APPEND({config.global.report.comment.swap.pass}) |
    Given I expect the next test steps to execute otherwise
    Then I update report for table {Constant.testkpi2} with the following details:
      | {config.global.report.label.swap} | {SSH.finalStatus} | APPEND({config.global.report.comment.swap.fail} |
    Given I end the if
    #CICD Test report end
    
    #Retrive the comment and overall status for the VMDrops and set in report
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh VMDROPS | awk '{print $1}'"
    Then I save the SSH response in the following variables:
      | attribute  | value         |
      | (.*)       | finalStatus   |
    
    When I execute using handler SITEHOST the SSH shell command "/root/getFinalStatusForKPI.sh VMDROPS | awk '{print $2}'"
    Then I save the SSH response in the following variables:
      | attribute  | value     |
      | (.*)       | comment   |
      
    Then I update report for table {Constant.testkpi2} with the following details:
      | {config.global.report.label.vmdrops} | {SSH.finalStatus} | {SSH.comment} |
    
    Given I expect the next test step to execute if '("{SSH.finalStatus}" == "Pass")'
    Then I update report for table {Constant.testkpi2} with the following details:
      | {config.global.report.label.vmdrops} | {SSH.finalStatus} | APPEND({config.global.report.comment.vmdrops-pass}) |
    Given I expect the next test steps to execute otherwise
    Then I update report for table {Constant.testkpi2} with the following details:
      | {config.global.report.label.vmdrops} | {SSH.finalStatus} | APPEND({config.global.report.comment.vmdrops-fail} |
    Given I end the if
    #CICD Test report end