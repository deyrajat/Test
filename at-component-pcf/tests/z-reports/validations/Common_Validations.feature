#######################################################################################################################################
## Purpose and Usage: 
##   1. This Single feature file should be updated with all Validation for a partcular Scenario.
##   2. Feature Level Tag = @SVIAutomationValidations, @Common and DONT ADD any other tag at feature level without discussing with team.
##   3. @Since<releaseVersion>  e.g 18.1 signifies the product feature was incorporated in call models of automation in this version.
##   4. Scenario should have a clean descriptive Validation definition.
##   5. At each scenario level use the correct VMs/nodes/pods etc. e.g. @ProtoVM @ServiceVM, where the validation is performed.
#######################################################################################################################################

@SVIAutomationValidations @Common 
Feature: Common validations

  @Since2019.05
  Scenario: Validate Total TPS
    Given I print: Total TPS is more than {config.scenario.thresholds.application.expected-tps}
    
  @Since2019.05
  Scenario: Validate LDAP TPS
    Given I print:  LDAP TPS is greater than 0
  
  @Since2019.05
  Scenario: Validate N7 create TPS in Iteration
    Given I print: N7 create TPS is within {config.global.thresholds.application.alloweddeviationpercent.tps} percentage from Previous Iteration
    
  @Since2019.05
  Scenario: Validate N7 update TPS in Iteration
    Given I print: N7 update TPS is within {config.global.thresholds.application.alloweddeviationpercent.tps} percentage from Previous Iteration
  
  @Since2019.05
  Scenario: Validate N7 delete TPS in Iteration
    Given I print: N7 delete TPS is within {config.global.thresholds.application.alloweddeviationpercent.tps} percentage from Previous Iteration
    
  @Since2019.05
  Scenario: Validate Rx AAR TPS in Iteration
    Given I print: Rx AAR TPS is within {config.global.thresholds.application.alloweddeviationpercent.tps} percentage from Previous Iteration
  
  @Since2019.05
  Scenario: Validate Rx ASR TPS in Iteration
    Given I print: Rx ASR TPS is within {config.global.thresholds.application.alloweddeviationpercent.tps} percentage from Previous Iteration
  
  @Since2019.05  
  Scenario: Validate Rx STR TPS in Iteration
    Given I print: Rx STR TPS is within {config.global.thresholds.application.alloweddeviationpercent.tps} percentage from Previous Iteration
    
  @Since2019.05  
  Scenario: Validate Rx RAR TPS in Iteration
    Given I print: Rx RAR TPS is within {config.global.thresholds.application.alloweddeviationpercent.tps} percentage from Previous Iteration
  
  @Since2019.05
  Scenario: Validate N7 create Response Time in Iteration
    Given I print: N7 create Response Time is within {config.global.thresholds.application.alloweddeviationpercent.response-time} from Benchmark value
    
  @Since2019.05
  Scenario: Validate N7 update Response Time in Iteration
    Given I print: N7 update Response Time is within {config.global.thresholds.application.alloweddeviationpercent.response-time} from Benchmark value
  
  @Since2019.05
  Scenario: Validate N7 delete Response Time in Iteration
    Given I print: N7 delete Response Time is within {config.global.thresholds.application.alloweddeviationpercent.response-time} from Benchmark value
    
  @Since2019.05
  Scenario: Validate Rx AAR Response Time in Iteration
    Given I print: Rx AAR Response Time is within {config.global.thresholds.application.alloweddeviationpercent.response-time} from Benchmark value
  
  @Since2019.05
  Scenario: Validate Rx ASR Response Time in Iteration
    Given I print: Rx ASR Response Time is within {config.global.thresholds.application.alloweddeviationpercent.response-time} from Benchmark value
  
  @Since2019.05  
  Scenario: Validate Rx STR Response Time in Iteration
    Given I print: Rx STR Response Time is within {config.global.thresholds.application.alloweddeviationpercent.response-time} from Benchmark value
    
  @Since2019.05  
  Scenario: Validate Rx RAR Response Time in Iteration
    Given I print: Rx RAR Response Time is within {config.global.thresholds.application.alloweddeviationpercent.response-time} from Benchmark value
    
  @Since2019.05
  Scenario: Validate Total count for HTTP2/Diameter 3xxx error messages
    Given I print: Total error is less than {config.global.thresholds.application.error-precentage} percentage of the Total TPS ( N7 + Diameter + LDAP)

  @Since2019.05
  Scenario: Validate Total count for HTTP2/Diameter 4xxx error messages
    Given I print: Total error is less than {config.global.thresholds.application.error-precentage} percentage of the Total TPS ( N7 + Diameter + LDAP)
    
  @Since2019.05
  Scenario: Validate Total count for HTTP2/Diameter 5xxx error messages
    Given I print: Total error is less than {config.global.thresholds.application.error-precentage} percentage of the Total TPS ( N7 + Diameter + LDAP)
    
  @Since2019.05
  Scenario: Validate Total count for HTTP2/Diameter Timeout messages
    Given I print: Total Timeout is less than {config.global.thresholds.application.error-precentage} percentage of the Total TPS ( N7 + Diameter + LDAP)
  
  @Since2019.05
  Scenario: Validate CPU utilization
    Given I print: CPU utilization for all the nodes should be less than {config.global.thresholds.system.cpu.used}
  
  @Since2019.05
  Scenario: Validate Memory utilization
    Given I print: CPU utilization for all the nodes should be less than {config.global.thresholds.system.memory.used}
 
  @Since2019.05
  Scenario: Validate PCF Ops center deployment status
    Given I print: PCF Ops center deployment is greater than equal to {config.global.thresholds.system.status-ready.expectedpercentage} percentage
    
  @Since2019.05
  Scenario: Validate CEE Ops center deployment status
    Given I print: CEE Ops center deployment is greater than equal to {config.global.thresholds.system.status-ready.expectedpercentage} percentage
  
  @Since2019.05
  Scenario: Validate Load average for proto, service, session nodes
    Given I print: Load average values should be less than number of vCPUs
  
