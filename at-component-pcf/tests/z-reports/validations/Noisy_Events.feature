#######################################################################################################################################
## Purpose and Usage: 
##   1. This Single feature file should be updated with all Validation for a partcular Scenario.
##   2. Feature Level Tag = @SVIAutomationValidations, @Scenario-Noisy and DONT ADD any other tag at feature level without discussing with team.
##   3. @Since<releaseVersion>  e.g 18.1 signifies the product feature was incorporated in call models of automation in this version.
##   4. Scenario should have a clean descriptive Validation definition.
##   5. At each scenario level use the correct VMs/nodes/pods etc. e.g. @ProtoVM @ServiceVM, where the validation is performed.
#######################################################################################################################################

@SVIAutomationValidations @Scenario-Noisy 
Feature: [Scenario-Noisy] All Noisy scenarios

  ###################################### Section for Noisy CPU, IO, Memory ###################################
  @Since2019.11 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @ETCDVM @NoisyCPU @NoisyIO @NoisyMemory
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM|ETCDVM] Validation of Memory Usage in the VM.
    Given I print: Verify if Memory usage not increased in the VM.
    
  @Since2019.11 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @ETCDVM @NoisyCPU @NoisyMemory
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM|ETCDVM] Validation of CPU Usage in the VM.
    Given I print: Verify if CPU usage increased in the VM.
    
  @Since2019.11 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @ETCDVM @NoisyCPU @NoisyIO @NoisyMemory
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM|ETCDVM] Validation of DISK Usage in the VM.
    Given I print: Verify if DISK usage not increased in the VM.
	
  @Since2019.11 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @ETCDVM @NoisyCPU @NoisyIO @NoisyMemory
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM|ETCDVM] Validation of all node status.
    Given I print: Verify if all nodes are in READY state.
	
  @Since2019.11 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @ETCDVM @NoisyCPU @NoisyIO @NoisyMemory
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM|ETCDVM] Validation of CEE Ops Center status.
    Given I print: Verify if CEE Ops Center is 100% Deployed.

  @Since2019.11 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @ETCDVM @NoisyCPU @NoisyMemory
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM|ETCDVM] Validation of Alert.
    Given I print: Verify if Alert is generated for the VM.
    
  ###################################### Section for Noisy IO only ############################################
  @Since2019.11 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @ETCDVM @NoisyIO
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM|ETCDVM] Validation of PCF Ops Center status.
    Given I print: Verify if PCF Ops Center is 100% Deployed.
    
  @Since2019.11 @ProtoVM @NoisyIO @TCPDump
  Scenario: [ProtoVM] Validation of TCPDump of Proto VM.
    Given I print: Validation of TCPDump of Proto VM.
    
  @Since2020.01 @ProtoVM @ServiceVM @NoisyIO @ThreadDump
  Scenario: [ProtoVM|ServiceVM] Validation of ThreadDump of Proto and Service VM.
    Given I print: Validation of ThreadDump of Proto and Service VM.
    
  
  ###################################### Section for Noisy memory only #########################################
  @Since2019.11 @ProtoVM @ServiceVM @SessionVM @OAMVM @MasterVM @ETCDVM @NoisyMemory
  Scenario: [ProtoVM|ServiceVM|SessionVM|OAMVM|MasterVM|ETCDVM] Validation of Memory Increase in the VM upto user-defined percentage.
    Given I print: Verify if Memory usage increased in the VM upto user-defined percentage.