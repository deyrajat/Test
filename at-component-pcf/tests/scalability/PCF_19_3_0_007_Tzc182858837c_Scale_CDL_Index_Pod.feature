####################################################################################################
# Date: <22/05/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Scale @P3 @Tzc182858837c @Dropped

Feature: PCF_19_3_0_007_Tzc182858837c_Scale_CDL_Index_Pod

  Scenario: Scale CDL Index Pod 30 MINs- Two Iterations

    Given the connection to QNS is established for SSH,WSClient,ToolAgent successfully

    #CICD Test report start
    Given I define the following constants:
      | name     | value            |
      | testtype | aggravatorTests  |

    #CICD Test report start  
    Given I define the following constants:
      | name        | value                                         |
      | DEPstatus   | {config.global.report.result.ne} |
      | DRTstatus   | {config.global.report.result.ne} |
      | DTPstatus   | {config.global.report.result.ne} |
      | ACstatus    | {config.global.report.result.fail}      |
      | CPUstatus   | {config.global.report.result.ne} |
      | SWAPstatus  | {config.global.report.result.ne} |
      | VMDstatus   | {config.global.report.result.ne} |

    Then I update report for table {Constant.testtype} with the following details:
      | Scale CDL Index Pod 30 MINs- Two Iterations | Fail |
    #CICD Test report end

    ## Get number of pods.
   	When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never cdl-index-session | wc -l at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | IndexPodCount  |

	   When I execute the SSH command "sshpass -p {config.CLIPcfOPSCenter.SSH.Password} ssh -p {config.CLIPcfOPSCenter.SSH.Port} {config.CLIPcfOPSCenter.SSH.UserName}@{config.CLIPcfOPSCenter.SSH.EndpointIpAddress} {config.global.command.opsCenter.show-running-config} cdl datastore index map | grep 'index map'  | awk '{print $NF}'" at K8SMaster
	 	 Then I save the SSH response in the following variables:
	      | attribute | value           |
	      | (.*)      | sesDbSessMapCnt |

    ###  
    When I execute using handler K8SMaster the SSH shell command echo $(({SSH.sesDbSessMapCnt} - 1))
    Then I save the SSH response in the following variables:
      | attribute | value               |
      | (.*)      | incrsesDbSessMapCnt | 

    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    #CICD Test report end

		## Scale down.
    When I execute the SSH command "config ; cdl datastore session index map {SSH.sesDbSessMapCnt} ; commit ; end" at CLIPcfOPSCenter

    Then I wait for {config.global.constant.onehundred.eighty} seconds

    Given the arming of teardown steps are done

    Given I expect the next test step to execute if ({SSH.IndexPodCount} > 0)

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

    ## Scale up
    When I execute the SSH command "config ; cdl datastore session index map {SSH.incrsesDbSessMapCnt} ; commit ; end" at CLIPcfOPSCenter

    Then I wait for {config.global.constant.twohundred.forty} seconds

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never cdl-index-session at K8SMaster

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

   	## Check If current config value is same as increased vlue  
   	When I execute the SSH command "sshpass -p {config.CLIPcfOPSCenter.SSH.Password} ssh -p {config.CLIPcfOPSCenter.SSH.Port} {config.CLIPcfOPSCenter.SSH.UserName}@{config.CLIPcfOPSCenter.SSH.EndpointIpAddress} {config.global.command.opsCenter.show-running-config} cdl datastore index map | grep 'index map'  | awk '{print $NF}'" at K8SMaster
	 	Then I save the SSH response in the following variables:
	      | attribute | value            |
	      | (.*)      | cursesDbSessMapCnt |
	  Then I validate the following attributes:
  	  | attribute                | value                                  |
   	  | {SSH.cursesDbSessMapCnt} | EQUAL({SSH.incrsesDbSessMapCnt})       |

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

		## Scale down.
    When I execute the SSH command "config ; cdl datastore session index map {SSH.sesDbSessMapCnt} ; commit ; end" at CLIPcfOPSCenter

    Then I wait for {config.global.constant.twohundred.forty} seconds		

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never cdl-index-session at K8SMaster

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

   	## Check If current config value is same as decreased vlue  
   	When I execute the SSH command "sshpass -p {config.CLIPcfOPSCenter.SSH.Password} ssh -p {config.CLIPcfOPSCenter.SSH.Port} {config.CLIPcfOPSCenter.SSH.UserName}@{config.CLIPcfOPSCenter.SSH.EndpointIpAddress} {config.global.command.opsCenter.show-running-config} cdl datastore index map | grep 'index map'  | awk '{print $NF}'" at K8SMaster
	 	Then I save the SSH response in the following variables:
	      | attribute | value            |
	      | (.*)      | cursesDbSessMapCnt |
	  Then I validate the following attributes:
  	  | attribute              | value                               |
   	  | {SSH.cursesDbSessMapCnt} | EQUAL({SSH.sesDbSessMapCnt})      |

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

   	Given I print: "cdl-index-session pod not present."

   Given I end the if

    #CICD report start#####################
    Given I define the following constants:
      | name        | value                                 |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | Scale CDL Index Pod 30 MINs- Two Iterations | Pass |
    #CICD report end#####################
