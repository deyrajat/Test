##########################################################################################
# Date: <01/02/2016> Version: <Initial version: 9.0> $1Create by <Suvajit Nandy, suvnandy>
##########################################################################################
##Custom Teardown steps written in this file

@PCF_LongevityTeardown

Feature: ST_Suite_Teardown

Scenario: Teardown steps for BuildValidation TestSuite

    Given the connection to QNS is established for SSH,WSClient,ToolAgent successfully

    #Given I define the following constants:
    #  | name     | value        |
    #  | testkpi  | applicationLevelKpi |

    #CICD Test report start  
    #Given I define the following constants:
      #| name        | value                                         |
      #| CPUstatus   | {config.global.report.result.ne} |
      #| SWAPstatus  | {config.global.report.result.ne} |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName | 

    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}UpdateReportResult.feature

    Given the arming of teardown steps are done
    
    ##External Teardown File

    #Call-Model Teardown steps
    Given I execute the steps from {config.global.workspace.library.location-features-calipers}CallModel_Teardown.feature

    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    When I execute the SSH command {config.sut.k8smaster.home.directory}/checkMinionCPUAverage.sh {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string               | occurrence |
#      | Load Average is more | absent     |
      | Load Average is less | present    |

    ## Verify MEMORY is under threshold.  
    When I execute the SSH command {config.sut.k8smaster.home.directory}/validateK8sMinionCPUMemory.sh usage_memory {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} {config.global.thresholds.system.memory-used} at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string                                                         | occurrence |
      | Memory is used > {config.global.thresholds.system.memory-used} | absent     |
      | Memory is used < {config.global.thresholds.system.memory-used} | present    |
    ## Verify CPU is under threshold.    
    When I execute the SSH command {config.sut.k8smaster.home.directory}/validateK8sMinionCPUMemory.sh usage_cpu {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} {config.global.thresholds.system.cpu-used} at K8SMaster
    Then I receive a SSH response and check the presence of following strings:  
      | string                                                      | occurrence |
      | CPU Used is > {config.global.thresholds.system.cpu-used}    | absent     |
      | CPU Used is < {config.global.thresholds.system.cpu-used}    | present    |
      
   	### REMOVE tet folder
    Given I execute the SSH command "rm -rf {config.global.remotepush.location.utilities-tet-upload-tetpull-path}" at LDAPServer
    Given I execute the SSH command "rm -rf {config.global.remotepush.location.utilities-tet-tetpull-output}" at LDAPServer