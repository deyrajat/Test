######################################################################################################
# Date: <02/03/2020> Version: <Initial version: 20.0.1> $1Create by <Sandeep Talukdar, santaluk>
######################################################################################################
@PCF @Stress @Tzc183260873c @P2 

Feature: PCF_19_3_0_006_Tzc183260873c_3x_load_with_diameter_overload_settings

  Scenario: 3x_load_with_diameter_overload_settings - One Iterations

    Given the connection to QNS is established for SSH,WSClient,ToolAgent successfully
    
    #CICD Test report start
    Given I define the following constants:
      | name     | value            |
      | testtype | aggravatorTests  |
      
    #CICD Test report start  
    Given I define the following constants:
      | name        | value                            |
      | DEPstatus   | {config.global.report.result.ne} |
      | DRTstatus   | {config.global.report.result.ne} |
      | DTPstatus   | {config.global.report.result.ne} |
      | ACstatus    | {config.global.report.result.fail}      |
      | CPUstatus   | {config.global.report.result.ne} |
      | SWAPstatus  | {config.global.report.result.ne} |
      | VMDstatus   | {config.global.report.result.ne} |
      
    Then I update report for table {Constant.testtype} with the following details:
      | 3x_load_with_diameter_overload_settings - One Iterations | Fail |
    #CICD Test report end

    Given I define the following constants:
      | name         | value |
      | Index        | 1     |
      | FileIndex    | 1     |
      
    ## Killing the Traffic so that the ToolAgent instances are created
    Given I execute the SSH command "pkill -f ToolAgent" at ToolAgentHost
    Given I execute the SSH command "pkill -f lattice" at ToolAgentHost
    Given I execute the SSH command "pkill -f cli" at ToolAgentHost

    Given I execute the SSH command "rm -rf ToolAgent.*" at ToolAgentHost
    Given I execute the SSH command "rm -rf core.*" at ToolAgentHost  
    When I execute the SSH command "rm -rf /tmp/taas/*" at ToolAgentHost

    #External PreRun File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}PreRun.feature
    
    ##### Get the incoming Diameter Request TPS Dynamically
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                |
      | (.*)      | check_tps_start_time |

    Then I wait for {config.global.constant.seventyfive} seconds

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value               |
      | (.*)      | check_tps_stop_time |

    When I execute the SSH command echo '&start={SSH.check_tps_start_time}&end={SSH.check_tps_stop_time}&step={config.Step_Duration}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value     |
      | (.*)      | TimeQuery |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Diameter_inbound_Query}{SSH.TimeQuery}" {config.Grafana.Authorization1} {config.Value.Extrator} at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value               |
      | (.*)      | DiameterIncomingReq |
      
    Given I print: Diameter Incoming request TPS = {SSH.DiameterIncomingReq}    
      
    ####### Calculate Throttle Set and Reset Value 
    When I execute the SSH command echo $(( {SSH.DiameterIncomingReq} * 2 )) at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | setThrottleValue |
      
    When I execute the SSH command echo $(( {SSH.DiameterIncomingReq} * 20 )) at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | resetThrottleValue |

    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature

    ##Configure the Diameter Reset Overload in PCF ops center
    When I execute the SSH command {config.global.scenario.stress.command-diameter-overload} {SSH.resetThrottleValue} ; commit ; end  at CLIPcfOPSCenter
    Then I receive a SSH response and check the presence of following strings:
      | string               |     occurrence   |
      | Commit complete      |     present      |

    Then I wait for {config.global.constant.ninety} seconds

    When I execute using handler K8SMaster the SSH shell command {config.global.commands.k8s.pod-list-pcf} | grep rest | awk '{print $1}' | xargs kubectl delete pod -n {config.sut.k8s.namespace.pcf}

    Then I wait for {config.global.constant.onehundred.eighty} seconds
    
    Given I print: Display advance Tuning Configuration  in teardown
    
    When I execute the SSH command {config.global.command.opsCenter.show-running-config} advance-tuning at CLIPcfOPSCenter

    ## Check status of the deployment.
    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLIPcfOPSCenter
    Then I save the SSH response in the following variables:
      | attribute                             | value           |
      | (system status percent-ready\s+\S+)   | depPerReady     |
    When I execute using handler SITEHOST the SSH command "echo {SSH.depPerReady}"
    Then I save the SSH response in the following variables:
      | attribute             | value       |
      | {Regex}(\d+.\d+)      | depPerReady |
    Then I validate the following attributes:
      | attribute         | value                                            |
      | {SSH.depPerReady} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) |
    #CICD Test report end

    Given the arming of teardown steps are done
    
    #### Get the name of the rest-ep pod
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never rest-ep | awk ' FNR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | PodName  | 
      
    ##Configure the overload action
    When I execute the SSH command {config.global.scenario.stress.command-diameter-action} at CLIPcfOPSCenter    

    ##Configure the N7 Overload in PCF ops center
    When I execute the SSH command {config.global.scenario.stress.command-diameter-overload} {SSH.setThrottleValue} ; commit ; end  at CLIPcfOPSCenter
    Then I receive a SSH response and check the presence of following strings:
      | string               |     occurrence   |
      | Commit complete      |     present      |

    Then I wait for {config.global.constant.ninety} seconds

    When I execute using handler K8SMaster the SSH shell command {config.global.commands.k8s.pod-list-pcf} | grep rest | awk '{print $1}' | xargs kubectl delete pod -n {config.sut.k8s.namespace.pcf}

    Then I wait for {config.global.constant.onehundred.eighty} seconds

    When I execute the SSH command {config.global.command.opsCenter.show-running-config} advance-tuning at CLIPcfOPSCenter

    ## Check status of the deployment.
    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLIPcfOPSCenter
    Then I save the SSH response in the following variables:
      | attribute                             | value           |
      | (system status percent-ready\s+\S+)   | depPerReady     |
    When I execute using handler SITEHOST the SSH command "echo {SSH.depPerReady}"
    Then I save the SSH response in the following variables:
      | attribute             | value       |
      | {Regex}(\d+.\d+)      | depPerReady |
    Then I validate the following attributes:
      | attribute         | value                                            |
      | {SSH.depPerReady} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) |
      
    Given I print:Check new Rest ep pods are create
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never {SSH.PodName} at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
        | string           | occurrence |
        | {SSH.PodName}    | absent     |

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.benchmark-interval} seconds

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #Get Benchmark values
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Benchmark.feature
    
    When I execute using handler SITEHOST the SSH shell command echo $(( {SSH.DiameterIncomingReq} / 2 ))
    Then I save the SSH response in the following variables:
      | attribute | value        |
      | (.*)      | overloadRate | 
      
    #### Start PCF overload
    
    When I update the {config.Instance_3} variable named COMMON_RATE to {SSH.overloadRate} in {config.global.scenario.stress.traffic-change-time} seconds interval with step value 10 at ToolAgent3
    
    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.execution-duration} seconds
    Then I wait for {config.scenario.exec-params.execution-duration} seconds

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    When I execute the SSH command echo '&start={SSH.grafana_start_time}&end={SSH.grafana_stop_time}&step={config.Step_Duration}' at Installer
    Then I save the SSH response in the following variables:
      | attribute | value     |
      | (.*)      | TimeQuery |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Diameter_inbound_Query}{SSH.TimeQuery}" {config.Grafana.Authorization1} {config.Value.Extrator} at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value       |
      | (.*)      | IncomingReq |

    Given I print: Overload PCF Diameter Incoming request TPS = {SSH.IncomingReq}    
     
    ## Verify if Inbound_throttle in greater than zero.
    When I execute using handler Installer the SSH shell command "{config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Diameter_throttled_Query}{SSH.TimeQuery}" {config.Grafana.Authorization1} {Config.Value.Extrator}"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | inbound_throttle  |
    Then I validate the following attributes:
      | attribute               |  value                   |
      | {SSH.inbound_throttle}  |  GREATERTHANOREQUAL(1)   |

    Given I define the following constants:
      | name         | value |
      | FileIndex    | 1     |

    When I update the {config.Instance_3} variable named COMMON_RATE to {config.ClpRate_3} in {config.global.scenario.stress.traffic-change-time} seconds interval with step value 10 at ToolAgent3

    Then I wait for {config.scenario.exec-params.cooloff-duration} seconds

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.execution-duration} seconds

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    When I execute the SSH command echo '&start={SSH.grafana_start_time}&end={SSH.grafana_stop_time}&step={config.Step_Duration}' at Installer
    Then I save the SSH response in the following variables:
      | attribute | value     |
      | (.*)      | TimeQuery |
 
    ## Verify if Inbound_throttle in equal to zero.
    When I execute using handler Installer the SSH shell command "{config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Diameter_throttled_Query}{SSH.TimeQuery}" {config.Grafana.Authorization1} {Config.Value.Extrator}"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | inbound_throttle  |
    Then I validate the following attributes:
    | attribute               |  value      |
	  | {SSH.inbound_throttle}  |  EQUAL(0)   |

    When I execute the SSH command {config.sut.k8smaster.home.directory}/cpu_Load_Check.sh {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string                 | occurrence |
      | System is stressed     | absent     |
      | System is not Stressed | present    |

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.benchmark-interval} seconds

    When I execute using handler K8SMaster the SSH shell command "date +%s"
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #Iteration1 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration1_Steps.feature

    #CICD report start#####################
    Given I define the following constants:
      | name        | value                                 |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | 3x_load_with_diameter_overload_settings - One Iterations | Pass |
    #CICD report end##################### 
