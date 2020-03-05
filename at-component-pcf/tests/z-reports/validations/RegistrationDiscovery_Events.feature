#######################################################################################################################################
## Purpose and Usage: 
##   1. This Single feature file should be updated with all Validation for a partcular Scenario.
##   2. Feature Level Tag = @SVIAutomationValidations, @Scenario-CHFRegistrationDiscovery and DONT ADD any other tag at feature level without discussing with team.
##   3. @Since<releaseVersion>  e.g 18.1 signifies the product feature was incorporated in call models of automation in this version.
##   4. Scenario should have a clean descriptive Validation definition.
##   5. At each scenario level use the correct VMs/nodes/pods etc. e.g. @ProtoVM @ServiceVM, where the validation is performed.
#######################################################################################################################################

@SVIAutomationValidations @Scenario-CHFRegistrationDiscovery
Feature: [Scenario-RegistrationDiscovery] CHF Registration and Discovery

  ###################################### Section for registration Priority [@RegistrationPriority] ############################################
  @Since2019.09 @RegistrationPriority @RegistrationCapacity
  Scenario: [RegistrationPriority|RegistrationCapacity] Validation of change in priority values for nrf registration
    Given I print: Verify if Rest-ep pod recreated.

  ###################################### Section for Discovery Priority [@DiscoveryPriority] ############################################
  @Since2019.09 @DiscoveryPriority @DiscoveryCapacity
  Scenario: [DiscoveryPriority|DiscoveryCapacity] Validation of change in priority values for nrf Discovery
    Given I print: Verify if Rest-ep pod recreated.
    
  ###################################### Section for Locality Change [@LocalityChange] ############################################
  @Since2019.09 @LocalityChange
  Scenario: [LocalityChange] Validate change in locality values for nrf discovery/registration
    Given I print: Verify if CHF node selected on locality | Traffic not distruptive.
    
  ###################################### Section for NRF stop [@NRFstop] ############################################
  @Since2019.09 @NRFstop
  Scenario: [NRFstop] Validate CHF change on NRF stop
    Given I print: Verify if CHF node selected on locality | Traffic not distruptive   
       
