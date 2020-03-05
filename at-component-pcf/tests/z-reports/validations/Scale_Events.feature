#######################################################################################################################################
## Purpose and Usage: 
##   1. This Single feature file should be updated with all Validation for a partcular Scenario.
##   2. Feature Level Tag = @SVIAutomationValidations, @Scenario-Scale and DONT ADD any other tag at feature level without discussing with team.
##   3. @Since<releaseVersion>  e.g 18.1 signifies the product feature was incorporated in call models of automation in this version.
##   4. Scenario should have a clean descriptive Validation definition.
##   5. At each scenario level use the correct VMs/nodes/pods etc. e.g. @ProtoVM @ServiceVM, where the validation is performed.
#######################################################################################################################################

@SVIAutomationValidations @Scenario-Scale 
Feature: [Scenario-Scale] Pod scale scenario

  ###################################### Section for Session Shards [@SessionShards] ############################################
  @Since2019.07 @SessionShards @Pcfengine @DBreplica @BalanceShards @SessionDB @RestEp @SessionSlot
  Scenario: [SessionShards|Pcfengine|DBreplica|BalanceShards|SessionDB|RestEp|SessionSlot] Validate pod scale down
    Given I print: The number of pods should be decreased
    
  @Since2019.07 @SessionShards @Pcfengine @DBreplica @BalanceShards @SessionDB @RestEp @SessionSlot
  Scenario: [SessionShards|Pcfengine|DBreplica|BalanceShards|SessionDB|RestEp|SessionSlot] Validate system status after scale down
    Given I print: The system be 100% deployed
    
  @Since2019.07 @SessionShards @Pcfengine @DBreplica @BalanceShards @SessionDB @RestEp @SessionSlot
  Scenario: [SessionShards|Pcfengine|DBreplica|BalanceShards|SessionDB|RestEp|SessionSlot] Validate pod scale up
    Given I print: The number of pods should be increased
    
  @Since2019.07 @SessionShards @Pcfengine @DBreplica @BalanceShards @SessionDB @RestEp @SessionSlot
  Scenario: [SessionShards|Pcfengine|DBreplica|BalanceShards|SessionDB|RestEp|SessionSlot] Validate system status after scale up
    Given I print: The system be 100% deployed