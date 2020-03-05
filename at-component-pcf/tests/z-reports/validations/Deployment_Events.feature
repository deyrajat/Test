#######################################################################################################################################
## Purpose and Usage: 
##   1. This Single feature file should be updated with all Validation for a partcular Scenario.
##   2. Feature Level Tag = @SVIAutomationValidations, @Scenario-Deployment and DONT ADD any other tag at feature level without discussing with team.
##   3. @Since<releaseVersion>  e.g 18.1 signifies the product feature was incorporated in call models of automation in this version.
##   4. Scenario should have a clean descriptive Validation definition.
##   5. At each scenario level use the correct VMs/nodes/pods etc. e.g. @ProtoVM @ServiceVM, where the validation is performed.
#######################################################################################################################################

@SVIAutomationValidations @Scenario-Deployment 
Feature: [Scenario-Deployment] Deployment scenarios

  ###################################### Section for Deployment Scenario [@Deployment] ############################################
  @Since2019.07 @SystemState
  Scenario: [Deployment] Validate system state before event
    Given I print: The system state should be set to "running"
    
  @Since2019.07 @SystemState
  Scenario: [Deployment] Validate system status after modification of configuration
    Given I print: The new system state should be set to "maintainence" and system status should be 100% deployed
    
  @Since2019.07 @SystemState
  Scenario: [Deployment] Validate system status after reverting configuration
    Given I print: The new state should be running and system status should be 100% deployed
    
  @Since2019.07 @PBPublish
  Scenario: [Deployment] Validate PB publish with Traffic
    Given I print: The PB publish should be successfull
    
  @Since2019.07 @CRDPublish
  Scenario: [Deployment] Validate CRD publish with Traffic
    Given I print: The CRD publish should be successfull
    