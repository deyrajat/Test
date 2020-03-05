#############################################################################################
# Date: <17/02/2018> Version: <Initial version: 18.5.2> $1Create by <Sandeep Talukdar, santaluk>
#############################################################################################

@PCF @BV @Longevity @Tzc182862946c @Tzc182637398c @Tzc182637399c @Tzc182979284c 

Feature: PCF_19_3_0_Tzc182862946c_Tzc182637398c_Tzc182637399c_Tzc182979284c_Longevity_Modular

  @Tzc182979284c
  Scenario: Build Validation for Longevity Scenario for PCF

    Given the connection to QNS is established for SSH,WSClient,ToolAgent successfully

    Given I define the following constants:
      | name     | value               |
      | testtype | performance         |

    #CICD Test report start
    Given I define the following constants:
      | name        | value                            |
      | DEPstatus   | {config.global.report.result.ne} |
      | DRTstatus   | {config.global.report.result.ne} |
      | DTPstatus   | {config.global.report.result.ne} |
      | ACstatus    | {config.global.report.result.fail}      |
      #| CPUstatus   | {config.global.report.result.ne} |
      #| SWAPstatus  | {config.global.report.result.ne} |
      | VMDstatus   | {config.global.report.result.ne} |
    #CICD Test report end

    Given the below steps are armed to be executed during teardown

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    #CICD Test report end

    Given the arming of teardown steps are done

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.longevity-interval} seconds

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #CICD report start#####################
    #Convert the wait time in mins
    When I execute the SSH command "echo `expr {config.scenario.exec-params.longevity-interval} / 60`" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value               |
      | (.*)      | iterationWaitInMins |
    
    ##Get execution duration till this point for report
    Given I define the following constants:
      | name              | value                     |
      | longevityDuration | {SSH.iterationWaitInMins} |
      
    #Convert the wait time in mins
      
    Then I update report for table {Constant.testtype} with the following details:
      | Duration | Fail | {Constant.longevityDuration} mins. |
    #CICD report end#####################

    #Get Benchmark values
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Benchmark.feature

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.longevity-interval} seconds

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #CICD report start#####################
    When I execute the SSH command "echo `expr {Constant.longevityDuration} + {SSH.iterationWaitInMins}`" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value         |
      | (.*)      | totalExecTime |

    ##Get execution duration till this point for report
    Given I define the following constants:
      | name              | value               |
      | longevityDuration | {SSH.totalExecTime} |

    Then I update report for table {Constant.testtype} with the following details:
      | Duration | Fail | {Constant.longevityDuration} mins. |
    #CICD report end#####################

    #Comparing with Benchmark values
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration1_Steps.feature

    #Considering we need n+1 number of iterations
    Given I loop {config.scenario.exec-params.longevity-iteration} times

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.longevity-interval} seconds

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #CICD report start#####################
    When I execute the SSH command "echo `expr {Constant.longevityDuration} + {SSH.iterationWaitInMins}`" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value         |
      | (.*)      | totalExecTime |

    ##Get execution duration till this point for report
    Given I define the following constants:
      | name              | value               |
      | longevityDuration | {SSH.totalExecTime} |

    Then I update report for table {Constant.testtype} with the following details:
      | Duration | Fail | {Constant.longevityDuration} mins. |
    #CICD report end#####################

    ##Checking with last iteration values on 1hr interval
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature

    ##Change the variables
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}VariableChange.feature

    And  I end loop

    When I execute the SSH command "date +%d-%m-%Y-%H-%M" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | execution_end_time |

    #CICD report start#####################
    Then I update report for table {Constant.testtype} with the following details:
      | Duration | Pass | {Constant.longevityDuration} mins. |

    Given I define the following constants:
      | name        | value                                 |
      | ACstatus    | {config.global.report.result.success} |
    #CICD report end#####################
    
  @Tzc182637398c
  Scenario: Run PCF Longevity for 24hrs
  
    Given I print: "Run PCF Longevity for 24hrs"
    
  @Tzc182637399c    
  Scenario: Run PCF Longevity for 48hrs
  
    Given I print: "Run PCF Longevity for 48hrs"
    
  @Tzc182979284c 
  Scenario: Run PCF Feature longevity
      
    Given I print: "Feature Longevity for PCF with Call Model changes"