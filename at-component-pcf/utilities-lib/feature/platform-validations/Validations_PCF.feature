####################################################################################################
# Date: <23/10/2019> Version: <Initial version: 19.0> $1Create by <Prosenjit Chatterjee, proschat>
####################################################################################################
@PCFRESILIENCYVAL

Feature: Resiliency_Validations

Scenario: Validations for Resiliency apart from grafana


		## Define CPU Status to fail.
  	Given I define the following constants:
      | name         | value                                    |
      | CPUstatus    | {config.global.report.result.fail} |
    
    ## Define Memory Status to fail.
    Given I define the following constants:
      | name          | value                                    |
      | SWAPstatus    | {config.global.report.result.fail} |
    
    ## Verify MEMORY is under threshold.  
    When I execute the SSH command {config.sut.k8smaster.home.directory}/validateK8sMinionCPUMemory.sh usage_memory {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} {config.global.thresholds.system.memory-used} at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string                                                         | occurrence |
      | Memory is used > {config.global.thresholds.system.memory-used} | absent     |
      | Memory is used < {config.global.thresholds.system.memory-used} | present    |
      
    # Make Memory Status Pass if Above check pass.
    Given I define the following constants:
      | name         | value                                |
      | SWAPstatus   | {config.global.report.result.success}|  
    
    ## Verify CPU is under threshold.    
    When I execute the SSH command {config.sut.k8smaster.home.directory}/validateK8sMinionCPUMemory.sh usage_cpu {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} {config.global.thresholds.system.cpu-used} at K8SMaster
    Then I receive a SSH response and check the presence of following strings:  
      | string                                                      | occurrence |
      | CPU Used is > {config.global.thresholds.system.cpu-used}    | absent     |
      | CPU Used is < {config.global.thresholds.system.cpu-used}    | present    |
      
    # Make CPU Status Pass if Above check pass.
    Given I define the following constants:
      | name         | value                                    |
      | CPUstatus    | {config.global.report.result.success} |  