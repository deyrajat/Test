#######################################################################################################################################
## Purpose and Usage: 
##   1. This Single feature file should be updated with all Validation for a partcular Scenario.
##   2. Feature Level Tag = @SVIAutomationValidations, @Scenario-Scale and DONT ADD any other tag at feature level without discussing with team.
##   3. @Since<releaseVersion>  e.g 18.1 signifies the product feature was incorporated in call models of automation in this version.
##   4. Scenario should have a clean descriptive Validation definition.
##   5. At each scenario level use the correct VMs/nodes/pods etc. e.g. @ProtoVM @ServiceVM, where the validation is performed.
#######################################################################################################################################

@SVIAutomationValidations @Scenario-Upgrade 
Feature: [Scenario-Upgrade] PCF Canary upgrade/downgrade scenario

  ###################################### Section for PCF Canary Downgrade [@CanaryDowngrade] ############################################
  @Since2020.01 @CanaryDowngrade @Pcfengine @PCFPb @RestEp @CanaryGPSI @CanaryDnn
  Scenario: [CanaryDowngrade|Pcfengine|PCFPb|RestEp|SessionDB|CanaryDowngradeGPSI|CanaryDowngradeDnn] Validate published pcf package name
    Given I print: The PCF Package should be present in the PCF publish location
    
  @Since2020.01 @CanaryDowngrade @Pcfengine @PCFPb @RestEp @CanaryGPSI @CanaryDnn
  Scenario: [CanaryDowngrade|Pcfengine|PCFPb|RestEp|SessionDB|CanaryDowngradeGPSI|CanaryDowngradeDnn] Validate helm repo configuration 
    Given I print: The helm repo configuration to contain the new PCF package name
    
  @Since2020.01 @CanaryDowngrade @Pcfengine @PCFPb @RestEp @CanaryGPSI @CanaryDnn
  Scenario: [CanaryDowngrade|Pcfengine|PCFPb|RestEp|SessionDB|CanaryDowngradeGPSI|CanaryDowngradeDnn] Validate canary engine configuration
    Given I print: The canary engine configuration to contain specific engine rule group name
    
  @Since2020.01 @CanaryDowngrade @Pcfengine @PCFPb @RestEp @CanaryGPSI @CanaryDnn
  Scenario: [CanaryDowngrade|Pcfengine|PCFPb|RestEp|SessionDB|CanaryDowngradeGPSI|CanaryDowngradeDnn] Validate PB Publish
    Given I print: Sucess message is obtained on PB publish
    
  @Since2020.01 @CanaryDowngrade @Pcfengine @PCFPb @RestEp @CanaryGPSI @CanaryDnn
  Scenario: [CanaryDowngrade|Pcfengine|PCFPb|RestEp|SessionDB|CanaryDowngradeGPSI|CanaryDowngradeDnn] Validate traffic Canary group rule for new engine group
    Given I print: New Canary engine group rule name is present in Canary group rule  
    
  ###################################### Section for PCF Canary Upgrade [@CanaryUpgrade] ############################################
    
  @Since2020.01 @CanaryUpgrade @Pcfengine @PCFPb @RestEp @CanaryGPSI @CanaryDnn
  Scenario: [CanaryDowngrade|Pcfengine|PCFPb|RestEp|SessionDB|CanaryDowngradeGPSI|CanaryDowngradeDnn] Validate traffic Canary group rule for defualt engine group 
    Given I print: Engine group rule name is present in Canary group rule  