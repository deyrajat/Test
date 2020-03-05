#######################################################################################################################################
## Purpose and Usage: 
##   1. This Single feature file should be updated with all Validation for a partcular Scenario.
##   2. Feature Level Tag = @SVIAutomationValidations, @Scenario-Stress and DONT ADD any other tag at feature level without discussing with team.
##   3. @Since<releaseVersion>  e.g 18.1 signifies the product feature was incorporated in call models of automation in this version.
##   4. Scenario should have a clean descriptive Validation definition.
##   5. At each scenario level use the correct VMs/nodes/pods etc. e.g. @ProtoVM @ServiceVM, where the validation is performed.
#######################################################################################################################################

@SVIAutomationValidations @Scenario-Stress 
Feature: [Scenario-Stress] Stress scenario

  ###################################### Section for Existing call model Stress [@CallStress] ############################################
  @Since2019.06 @CallStress
  Scenario: [CallStress] Validation of Stresing PCF by increasing existing call model TPS
    Given I print: Verify if 5 min load average is greater than the number of vCPUs for the service nodes.
    
  @Since2019.06 @CallStress
  Scenario: [CallStress] Validation of Stresing PCF by decreasing the existing call model TPS to original value
    Given I print: Verify if 5 min load average is lesser than the number of vCPUs for the service nodes.
 
  ###################################### Section for Registration Termination burst [@RTBurst] ############################################
  @Since2019.06 @RTBurst
  Scenario: [RTBurst] Validation of starting of Additition start huge numbers of N7 Create/Delete messages 
    Given I print: Verify if 5 min load average is greater than the number of vCPUs for the service nodes.
    
  @Since2019.06 @RTBurst
  Scenario: [RTBurst] Validation of stopping of Additition start huge numbers of N7 Create/Delete messages 
    Given I print: Verify if 5 min load average is lesser than the number of vCPUs for the service nodes.

  ###################################### Section for Traffic Throttling [@TrafficThrottle] ############################################
  @Since2019.09 @TrafficThrottle
  Scenario: [TrafficThrottle] Validation of starting more N7 incoming request then the configured overload value
    Given I print: Verify if inbound throttle value is greater than zero.
    
  @Since2019.09 @TrafficThrottle
  Scenario: [TrafficThrottle] Validation of stopping addiational N7 incoming request then the configured overload value
    Given I print: Verify if inbound throttle value is zero.

  ###################################### Section for Alert Duration Check [@AlertDuration] ############################################
  @Since2019.10 @AlertDuration
  Scenario: [AlertDuration] Validation of Stresing PCF by increasing existing call model TPS
    Given I print: Verify if 5 min load average is greater than the number of vCPUs for the service nodes.
    
  @Since2019.10 @AlertDuration
  Scenario: [AlertDuration] Validation of Alert generation after a given time
    Given I print: Verify if Specific alert is generated after the gicen time interval.
    
  @Since2019.10 @AlertDuration
  Scenario: [AlertDuration] Validation of Stresing PCF by decreasing the existing call model TPS to original value
    Given I print: Verify if 5 min load average is lesser than the number of vCPUs for the service nodes.
    
       
