#######################################################################################################################################
## Purpose and Usage: 
##   1. Feature file should be updated with all Product Features categorized under a new Scenario.
##   2. Feature Level Tag = @ProductFeatureCoverage and DONT ADD any other tag at feature level without discussing with team.
##   3. Scenario should have a clean descriptive Product Feature definition along with Feature ID and short Description.
##   4. Given I print: grammar to be used with (|) pipe separated attributes that indicate what nature of configurations are needed
##   
##   For each scenario there should be three tags one from each of the category below (ass Applicable ): 
##
##   Category 1] @InProductFeature-Since-<release>  e.g 2019.08 signifies the product feature was introduced in this version
##   Category 2] @Automation-NotPossible or @Automation-Pending
##   Category 3] @ProduceFeatureAutomation-Partial  signifies the product feature partially integated in automation
#######################################################################################################################################

##WARNING: DO NOT REMOVE THE TAG @DONOTREPORT. IT IS USED TO IGNORE THE TAGGED FEATURE FILE FROM AUTOMATED REPORTING
@ProductFeaturesCoverage @DONOTREPORT
Feature: [ PENDING ] Product Features not integrated with automation

@InProductFeature-Since-2019.08 @NA
Scenario: F3743 -- PCF to PCRF interaction for VoLTE calls [F2552]
Given I print: PCF Features is Deprecated

@InProductFeature-Since-2019.08 @NA
Scenario: F1749 -- PCF_ST_F3253_F1749_PCF N7 use of OpenTracing
Given I print: PCF Features is De-Commited

@InProductFeature-Since-2019.08 @NA
Scenario: F3748 -- PCF FCS Qualification - Sh Integration (EC2 feature)
Given I print: PCF Features is De-Commited

@InProductFeature-Since-2019.08 @NA
Scenario: F2804 -- Integration with SMF/UPF for VoNR use cases
Given I print: PCF Features is Deprecated

@InProductFeature-Since-2019.09 @NA
Scenario: F4349 -- GR Support for Canary Upgrade
Given I print: PCF Features is Deprecated

@InProductFeature-Since-2019.08 @Automation-Pending
Scenario: F2551 -- N28 : NAP Notifications support (REST API Based)
Given I print: Can be tested on TB4 only

@InProductFeature-Since-2019.08 @Automation-Pending
Scenario: F2548 -- PLF query support
Given I print: Can be tested on TB4 only

@InProductFeature-Since-2019.09 @Automation-Pending
Scenario: F1169 -- PCF to support 2 endpoint for GR CDL
Given I print: GR Setup needed to test/automate the feature 

@Pending @Apr_Discovery @Automation-Pending @FC_Ready_For_CE_2020-03-19 
Scenario: F1771 -- [CPS PCF] N36: Phase-1 Query AM and SM policy data
Given I print: Feature under Development

@Pending @Mar_Discovery @Automation-Pending @FC_Ready_For_CE_2020-02-27
Scenario: F4128 -- [CPS PCF] MWC: PCF cluster write to BSF via SBA Nbsf API
Given I print: Feature under Development

@Pending @Apr_Discovery @Automation-Pending @FC_Ready_For_CE_2020-03-12
Scenario: F5227 -- [CPS PCF] N15 : Access and Mobility  Policies
Given I print: Feature under Development

@Pending @Mar_Discovery @Automation-Pending @FC_Ready_For_CE_2020-02-20
Scenario: F5577 -- [CPS PCF] Operation CLI - Phase 2
Given I print: Feature under Development

@Pending @Apr_Discovery @Automation-Pending @FC_Ready_For_CE_2020-03-19
Scenario: F5708 -- [CPS PCF] Static Smart licensing integration
Given I print: Feature under Development

@Pending @Apr_Discovery @Automation-Pending @FC_Ready_For_CE_2020-03-16
Scenario: F5739 -- [CPS PCF] Performance Tuninng
Given I print: Feature under Development

@Pending @Apr_Discovery @Automation-Pending @FC_Ready_For_CE_2020-03-15
Scenario: F5759 -- [CPS PCF] PCF in-service upgrade - SVI
Given I print: Feature under Development

################## Partial Integrated Section : use tag @ProduceFeatureAutomation-Partial for every scenario ########

@InProductFeature-Since-2019.08 @ProduceFeatureAutomation-Partial
Scenario: F2550 -- Support for Notifications from NAP (REST API Based) - PCF to requery the USD/LDAP server
Given I print: SUT Config | Call Model