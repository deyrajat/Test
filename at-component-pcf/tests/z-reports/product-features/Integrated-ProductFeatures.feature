#######################################################################################################################################
## Purpose and Usage: 
##   1. Feature file should be updated with all Product Features categorized under a new Scenario.
##   2. Feature Level Tag = @ProductFeatureCoverage and DONT ADD any other tag at feature level without discussing with team.
##   3. Scenario should have a clean descriptive Product Feature definition along with Feature ID and short Description.
##   4. Given I print: grammar to be used with (|) pipe separated attributes that indicate what nature of configurations are needed
##   
##   For each scenario there should be three tags one from each of the category below (as Applicable ): 
##
##   Category 1] @AutomatedSince-<release>
##   Category 2] @InProductFeature-Since-<release>  e.g 2019.08 signifies the product feature was introduced in this version
#######################################################################################################################################

@ProductFeaturesCoverage 
Feature: [ DONE    ] Product Features integrated with automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.08
Scenario: F2362--N7 : 3GPP December 2018 spec compliance
Given I print: PB | CRD | SUT Config | Call Model | Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.08
Scenario: F3253--PCF FCS Qualification - SMF N7 Interface
Given I print: PB | CRD | SUT Config | Call Model | Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.08
Scenario: F3255--PCF FCS Qualification - LDAP and Sh Integration
Given I print: PB | SUT Config | Call Model | Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.08
Scenario: F3256--PCF FCS Qualification - Table Driven Rules
Given I print: PB | CRD | Call Model | Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.08
Scenario: F2546--Rx_TGPP : Converged Rx for 5G/4G
Given I print: PB | CRD | SUT Config | Call Model | Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.08
Scenario: F3252--PCF FCS Qualification - NRF Registration/De-registration
Given I print: SUT Config | Call Model | Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.08
Scenario: F2800--N7 : 4G/5G charging rules and Qos over N7 to SMF
Given I print: PB | CRD | Call Model | Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.09
Scenario: F3320--N28 : Phase 2 - Update requests towards CHF
Given I print: PB | CRD | Call Model | Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.09
Scenario: F1765 -- NRF : Subscription to notifications (eg UDR and CHF server NF-list changes) - 3GPP Dec18 based
Given I print: CRD | SUT Config | Call Model | Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.09
Scenario: F3793 --N28 : 3GPP December 2018 spec compliance
Given I print: PB | CRD | SUT Config | Call Model | Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.09
Scenario: F3219 -- Integration with CDL Layer
Given I print: SUT Config | Call Model | Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.09
Scenario: F3629 -- Rx Authorization
Given I print: PB | CRD | Call Model | Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.10
Scenario: F1163 -- PCF stats, KPIs and Alarms (4G PCRF equivalence, and new 5G stats)
Given I print: SUT Config | Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2019.10
Scenario: F3890 - Support for Multiple VIPs
Given I print: SUT Config | Automation

@InProductFeature-Since-2019.09 @AutomatedSince-2019.11
Scenario: F3190: NRF/CHF : Retries to query for node selection
Given I print: Call Model | Automation

@InProductFeature-Since-2019.09 @AutomatedSince-2019.11
Scenario: F3630: QOS Tiering (Flex SOC)
Given I print: PB | CRD | Call Model 

@InProductFeature-Since-2019.09 @AutomatedSince-2019.11
Scenario: F3113: Overload Control SBA
Given I print:  SUT Config | Call Model | Automation

@InProductFeature-Since-2019.09 @AutomatedSince-2019.12
Scenario: F3108: NRF Heart Beat
Given I print: SUT Config

@InProductFeature-Since-2019.09 @AutomatedSince-2019.12
Scenario: F2348_US46461_PCF_Support_for_Flexible_Qos_Actions
Given I print: PB | CRD

@InProductFeature-Since-2019.08 @AutomatedSince-2020.01
Scenario: F3747--PCF FCS Qualification - SMF N7 Interface - Canary upgrade
Given I print: SUT Config | Call Model | Automation

@InProductFeature-Since-2019.11 @AutomatedSince-2020.01
Scenario: F5182: PCF - Integration with Splunk for logging
Given I print: SUT Config | Automation

@InProductFeature-Since-2020.01 @AutomatedSince-2020.01
Scenario: F5184: PCF : Application Consolidated logging
Given I print: SUT Config | Automation

@InProductFeature-Since-2020.01 @AutomatedSince-2020.01
Scenario: F2850: PCF SRC Compliance
Given I print: PyATS Automation

@InProductFeature-Since-2019.08 @AutomatedSince-2020.01
Scenario: F2799--PCF_ST_F3254_F2799_N7 Support of SUPI and GPSI Attributes for Canary
Given I print: SUT Config | Call Model | Automation

@InProductFeature-Since-2020.01 @AutomatedSince-2020.02
Scenario: F3107: NRF : PCF Update requests
Given I print: Call Model

@InProductFeature-Since-2020.01 @AutomatedSince-2020.02
Scenario: F3401: Codecs support as specified in 3GPP TS 26.114
Given I print: PB | CRD | Call Model

@InProductFeature-Since-2020.01 @AutomatedSince-2020.02
Scenario: F4143: 3GPP June 2019 spec conformance : NRF Interface
Given I print: Call Model

@InProductFeature-Since-2020.01 @AutomatedSince-2020.02
Scenario: F4145: 3GPP June 2019 spec conformance : N28 Interface
Given I print: Call Model

@InProductFeature-Since-2020.01 @AutomatedSince-2020.02
Scenario: F4468: 3GPP June 2019 spec conformance : N7 Interface
Given I print: Call Model

@InProductFeature-Since-2019.10 @AutomatedSince-2020.02
Scenario: F4624: PCF to support the ability to send a N7 Notify to solicit a Notify Response with RAT type.
Given I print: PB | CRD | Call Model
