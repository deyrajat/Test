####################################################################################################
# Date: <16/05/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Resiliency @Tzc182637362c @PCF_Resi_Engine @P1 @CDET @PcfResP1Set1 @TB4Rerun

Feature: PCF_19_3_0_023_Tzc182637362c_Pcf_rest_ep_Pod_Restart

  Scenario: Pcf-rest-ep Pod Restart 30 MINs- Two Iterations

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
      | Pcf-rest-ep Pod Restart - Two Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  

    ## Count number of Resp-EP PODS.
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never ^pcf-rest-ep | wc -l at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | PodCount |

    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature
    
    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    #CICD Test report end

    Given the arming of teardown steps are done

    ##GET IP Address of the RX interface from CLI OPS CENTER 
    When I execute the SSH command {config.global.command.opsCenter.show-running-config} diameter group at CLIPcfOPSCenter
    Then I save the SSH response in the following variables:
      | attribute      | value         |
      | ([\s\S]*)      | diameterGroup |
      
    When I execute the SSH command echo "{SSH.diameterGroup}" | grep -m1 bind-ip  | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}' at SITEHOST
 	  Then I save the SSH response in the following variables:
      | attribute |    value       |
      | (.*)      |    RXVip       |

    ### Get hostname of the VM associated with VIP
    Given I configure a SSH instance with following attributes:
     |  string	           |	 value	                         |
     |  InstanceName       |  RXVipINSTANCE                    |
     |  UserName           |  {config.K8SMaster.SSH.UserName}  |
	   |  KeyFile            |  {config.sut.SMIDeployer.SSH-KeyFile}   |
	   |  EndpointIpAddress  |  {SSH.RXVip}                      |	   

    When I execute using handler RXVipINSTANCE the SSH command "hostname"
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | RXViphostname      |

    Given I delete SSH instance RXVipINSTANCE

    Given I execute the SSH command {config.global.commands.k8s.pod-list-pcf} -o wide | grep --color=never rest at K8SMaster

   	Given I expect the next test step to execute if ({SSH.PodCount} > 1)

    #External PreRun File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}PreRun.feature

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |
    
	Then I wait for {config.scenario.exec-params.benchmark-interval} seconds
	
	When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #Get Benchmark values
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Benchmark.feature  
    
    ##Perform Pcf-rest-ep Pod reboot  
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never ^pcf-rest-ep | awk ' FNR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | PodName  |
      
    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster  
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | PodResstartCount |

    When I execute the SSH command "date +%H:%M_%Y%m%d" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | event_start_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                  |
      | (.*)      | event_start_epoch_time |
      
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    #### Perform Pod Restart
    Given I execute the steps from {config.global.scenario.resiliency.lib-dir}RestartPod.feature

    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster  
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                               | occurrence |
      | {Regex}(.*) | greaterthan({SSH.PodResstartCount}) | present    |

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never ^pcf-rest-ep | awk ' FNR == 1 {print $1}' at K8SMaster

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf}  | grep -v Running at K8SMaster

    ####Capture End Time after Reboot
    When I execute the SSH command "date +%H:%M_%Y%m%d" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | event_end_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                |
      | (.*)      | event_end_epoch_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    ##Calculate exact duration of event in seconds
    When I execute the SSH command {config.global.remotepush.location.utilities-geteventduration} {SSH.event_start_epoch_time} {SSH.event_end_epoch_time} at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value        |
      | (.*)      | eventTimeSec |

    ####Check Errors and Timeouts during Reboot
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}EventErrorCaptureAndChecks.feature
    
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |
    
	Then I wait for {config.scenario.exec-params.benchmark-interval} seconds
	
	When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #Iteration1 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration1_Steps.feature

    ##################************************2nd Iteration***************************

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never ^pcf-rest-ep | awk ' FNR == 2 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | PodName  |

    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster  
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | PodResstartCount |

    When I execute the SSH command "date +%H:%M_%Y%m%d" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | event_start_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                  |
      | (.*)      | event_start_epoch_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    #### Perform Pod Restart
    Given I execute the steps from {config.global.scenario.resiliency.lib-dir}RestartPod.feature

    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster  
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                               | occurrence |
      | {Regex}(.*) | greaterthan({SSH.PodResstartCount}) | present    |
	
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never ^pcf-rest-ep | awk ' FNR == 2 {print $1}' at K8SMaster
	
	When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf}  | grep -v Running at K8SMaster
	
    ####Capture End Time after Reboot
    When I execute the SSH command "date +%H:%M_%Y%m%d" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | event_end_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                |
      | (.*)      | event_end_epoch_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    ##Calculate exact duration of event in seconds
    When I execute the SSH command {config.global.remotepush.location.utilities-geteventduration} {SSH.event_start_epoch_time} {SSH.event_end_epoch_time} at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value        |
      | (.*)      | eventTimeSec |

    ####Check Errors and Timeouts during Reboot
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}EventErrorCaptureAndChecks.feature

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |
    
	Then I wait for {config.scenario.exec-params.benchmark-interval} seconds
	
	When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #Iteration2 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature

    Given I expect the next test step to execute otherwise

   	Given I print: "Rest Endpoint Pod Count Not Greater Than One."

   	Given I end the if

    #CICD report start#####################
    Given I define the following constants:
      | name        | value                                    |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | Pcf-rest-ep Pod Restart - Two Iterations | Pass |
    #CICD report end#####################
