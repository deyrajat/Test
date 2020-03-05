#######################################################################################################################################
## Purpose and Usage: 
##   1. This Single feature file should be updated with all Validation for a partcular Scenario.
##   2. Feature Level Tag = @SVIAutomationValidations, @Scenario-Resiliency and DONT ADD any other tag at feature level without discussing with team.
##   3. @Since<releaseVersion>  e.g 18.1 signifies the product feature was incorporated in call models of automation in this version.
##   4. Scenario should have a clean descriptive Validation definition.
##   5. At each scenario level use the correct VMs/nodes/pods etc. e.g. @ProtoVM @ServiceVM, where the validation is performed.
#######################################################################################################################################

@SVIAutomationValidations @Scenario-Resiliency
Feature: [Scenario-Resiliency] All Resiliency scenarios

  ###################################### Section for ClearSession ############################################
  @Since2019.06 @ClearSession
  Scenario: Validate Removing some of the static sessions
    Given I print: Session with imsi prefix {config.Data.StaticSession.SUPI.Prefix} removed successfully.
    
  ###################################### Section for HTTPError ############################################
  @Since2019.08 @HTTPError
  Scenario: [HTTPError] Validation of HTTP Error message in call flow
    Given I print: Verify if Number of HTTP error messages should be greater than zero
  
  ###################################### Section for PROTO VM ############################################
  @Since2019.11 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @K8sNodeDrain
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM] Validation of Drained node Status.
    Given I print: Verify if Drained node is in SchedulingDisabled state.
    
  @Since2019.11 @ProtoVM @ServiceVM @SessionVM @K8sNodeDrain
  Scenario: [ProtoVM|ServiceVM|SessionVM] Validation of Pods on Drained node.
    Given I print: Verify if no pods are present on drained node.
    
  @Since2019.11 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @K8sNodeUncordon
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM] Validation of Uncordoned node Status.
    Given I print: Verify if Uncordoned node is not in SchedulingDisabled state.
    
  @Since2019.11 @ProtoVM @ServiceVM @SessionVM @K8sNodeUncordon
  Scenario: [ProtoVM|ServiceVM|SessionVM] Validation of Pods on Uncordoned node.
    Given I print: Verify if pods are present on Uncordoned node.
  
  ###################################### Section for LDAPProcess Restart ############################################
  @Since2019.07 @LDAPServerRestart
  Scenario: [LDAPServerRestart] Validation of ldap connections after killing ldap process
    Given I print: Verify if LDAP connection to the PCF should be removed.
    
  @Since2019.07 @LDAPServerRestart
  Scenario: [LDAPServerRestart] Validate ldap connections after killing ldap process
    Given I print: Verify if LDAP connection to the PCF should be removed.

  ###################################### Section for Node network restart ############################################
  @Since2019.05 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @ETCDVM
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM|ETCDVM] Validation of Node Physical interface restart
    Given I print: Verify if physical interface of the node is accessible after restart.
    
  ###################################### Section for Node poweroff/poweron ############################################
  @Since2019.05 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @ETCDVM
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM|ETCDVM] Validation of node Power off
    Given I print: Verify if node is no more accesible
    
  @Since2019.05 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @ETCDVM
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM|ETCDVM] Validation of node Power on
    Given I print: Verify that node is accesible again
    
  ###################################### Section for Node reboot ############################################
  @Since2019.11 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @ETCDVM
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM|ETCDVM] Validation of node reboot action.
    Given I print: Verify if Rebooted node is in Active state.
  
    ###################################### Section for Secondary NRF Failover ############################################
  @Since2019.06 @NRFFailover-Primary-to-Secondary
  Scenario: [SecondaryNRFFailover] Validate Primary NRF Connection is stopped 
    Given I print: Verify if PCF Connection to Primary NRF removed | Primary NRF is no more listening 
    
  @Since2019.06 @NRFFailover-Primary-to-Secondary
  Scenario: [SecondaryNRFFailover] Validate Secondary NRF Connection after stopping Primary NRF
    Given I print: Verify if Secondary NRF is listening | PCF Connection to Secondary NRF established
   
  @Since2019.06 @NRFFailover-Primary-to-Secondary
  Scenario: [SecondaryNRFFailover] Validate Primary NRF Connection is started 
    Given I print: Verify if Primary NRF is  listening | PCF Connection to Primary NRF re-established
    
  ###################################### Section for Tertiary NRF Failover ############################################
  @Since2019.06 @NRFFailover-Primary-to-Tertiary
  Scenario: [TertiaryNRFFailover] Validate Primary and Secondary NRF Connection being stopping 
    Given I print: Verify if PCF Connection to Primary NRF removed  | Primary and Secondary NRF is no more listening 
    
  @Since2019.06 @NRFFailover-Primary-to-Tertiary
  Scenario: [TertiaryNRFFailover] Validate Tertiary NRF Connection after stopping Primary and Secondary NRF
    Given I print: Verify if Tertiary NRF is listening  | PCF Connection to Tertiary NRF established
   
  @Since2019.06 @NRFFailover-Primary-to-Tertiary
  Scenario: [TertiaryNRFFailover] Validate Primary and Secondary NRF Connection being started 
    Given I print: Verify if Primary and Secondary NRF is listening | PCF Connection to Primary NRF re-established
    
  ###################################### Section for Pod delete ############################################
  @Since2019.05 @Policy_Engine_Pod @Pcf_Cps_Ldap_Ep @Pcf_Rest_Ep @Pcf_Diameter_Ep_Rx @Pcf_License_Manager @Pcf_CRD @Pcf_Ldap_Ep @Pcf_Cdl_Ep_Session
  Scenario: [PolicyEnginePod|PcfCpsLdapEp|PcfRestep|PcfDiameterEpRx|PcfLicenseManager|PcfCRD|PcfLdapEp|PcfCdlEpSession] Validate new Pod name after Delete
    Given I print: Current pod name is different from the previous one.
    
  @Since2019.05 @Pcf_Session @Pcf_Etcd @Pcf_Admin_DB @Pcf_Spr_Pod_Cont @Pcf_Cdl_Index_Session @Pcf_Kafka @Pcf_Zookeeper
  Scenario: [PcfSession|PcfEtcd|PcfAdminDB|PcfSprPodCont|PcfCdlIndexSession|PcfKafka|PcfZookeeper] Validate Pod status after Delete
    Given I print: Pod with the same name is Running
    
  @Since2019.05 @Pcf_Session @Pcf_Etcd @Pcf_Admin_DB @Pcf_Spr_Pod_Cont @Pcf_Cdl_Index_Session @Pcf_Kafka @Pcf_Zookeeper
  Scenario: [PcfSession|PcfEtcd|PcfAdminDB|PcfSprPodCont|PcfCdlIndexSession|PcfKafka|PcfZookeeper] Validate Pod creation time after Delete
    Given I print: Current pod creation time is more than the previous one.
    
  ###################################### Section for Pod restart  ############################################
  @Since2019.05 @AllPods
  Scenario: [Zookeeper|Kafka|Etcd|BulkStats|DBSessionConfig|DiameterEPRx|RSControllerSessionConfig|RSControllerS1|RestEP|LdapEP|SVN|RSControllerAdminConfig|RSControllerAdmin|RedisQueue|RedisKeystore|PatchServerInfrastructure|OpsCenter|NetworkQuery|Lbvip02|PolicyEngine|CRD|Session|SPR|Activemq|AdminDB|LicenseManager|DatastoreEPSession|DBAdmin|DBAdminConfig] Validate pod Restart count
    Given I print: Current pod Restart count greater than previous restart count
  
  ###################################### Section for VIP VM poweroff/poweron ############################################
  @Since2019.07 @N7VIP @N28VIP @RXVIP @NRFVIP
  Scenario: [N7VIP|N28VIP|RXVIP|NRFVIP] Validation of VIP host after shutting down the primary VIP port
    Given I print: Verify if VIP moves from Primary to Secondary Host
    
  @Since2019.07 @N7VIP @N28VIP @RXVIP @NRFVIP
  Scenario: [N7VIP|N28VIP|RXVIP|NRFVIP] Validation of VIP host after enabling VIP port on the primary host
    Given I print: Verify if VIP moves from Secondary to Primary Host
    
  ###################################### Section for Conslidated logging ############################################  
  @Since2020.02 @Consolidated_Logging
  Scenario: [ConsolidatedLogging] Validation of consolidated logging after Consolidated_Logging pod restart
  Given I print: Verify if the consolidated logging happens even after the pod restart

  @Since2020.02 @Consolidated_Logging @OAMVM
  Scenario: [ConsolidatedLogging|OAMVM] Validation of consolidated logging after OAM Node restart having Consolidated_Logging pod
  Given I print: Verify if the consolidated logging happens even after the OAM VM restart
  