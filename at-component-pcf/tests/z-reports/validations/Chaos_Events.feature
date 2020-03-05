#######################################################################################################################################
## Purpose and Usage: 
##   1. This Single feature file should be updated with all Validation for chaos scenarios.
##   2. Feature Level Tag = @SVIAutomationValidations, @Scenario-Chaos and DONT ADD any other tag at feature level without discussing with team.
##   3. @Since<releaseVersion>  e.g 18.1 signifies the product feature was incorporated in call models of automation in this version.
##   4. Scenario should have a clean descriptive Validation definition.
##   5. At each scenario level use the correct VMs/nodes/pods etc. e.g. @ProtoVM @ServiceVM, where the validation is performed.
#######################################################################################################################################

@SVIAutomationValidations @Scenario-Chaos 
Feature: [Scenario-Chaos]Chaos scenarios

  ###################################### Section for Application Based  [@Application_Level_Chaos] ############################################   
  @Since2019.10 @Application_Level_Chaos @Randomaized_Pod_Chaos @High_Priority_Pod_Chaos @Medium_Priority_Pod_Chaos @Low_Priority_Pod_Chaos
  Scenario: [ApplicationBased|RandomaizedPods|HighPriorityPods|MediumPriorityPods|Low_Priority_Pods] Validate total TPS at regular intervals during chaos
    Given I print: Verify if the actual TPS is equal or greater than the expected TPS during chaos
  
  @Since2019.10 @Application_Level_Chaos @Randomaized_Pod_Chaos @High_Priority_Pod_Chaos @Medium_Priority_Pod_Chaos @Low_Priority_Pod_Chaos
  Scenario: [ApplicationBased|RandomaizedPods|HighPriorityPods|MediumPriorityPods|Low_Priority_Pods] Validate that system status after chaos event
    Given I print: Verify if The System should be in ready state