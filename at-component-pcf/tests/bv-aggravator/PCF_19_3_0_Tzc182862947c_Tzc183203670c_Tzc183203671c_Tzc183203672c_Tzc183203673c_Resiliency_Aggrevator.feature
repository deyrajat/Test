################################################################################################
# Date: <13/02/2018> Version: <Initial version: 18.0.1> Create by <Sandeep Talukdar, santaluk>
################################################################################################
@BV @PCF @ResilencyAggravator @Tzc182862947c @Tzc183203670c @Tzc183203671c @Tzc183203672c @Tzc183203673c

Feature: PCF_19_3_0_Tzc182862947c_Tzc183203670c_Tzc183203671c_Tzc183203672c_Tzc183203673c_Resiliency_Aggrevator

  @Tzc182862947c
  Scenario: BV_Aggravator_engine_pod_restart

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
      | PCF Various Resiliency Aggrevator | Fail |
    #CICD Test report end

    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    #CICD Test report end

    Given the arming of teardown steps are done

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
    
    Given I print:====================== PCF Restart Engine pod Start  =========================

    ##Perform Policy Engine Pod reboot  
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never pcf-engine-{config.sut.k8s.namespace.pcf}-pcf-engine-app | awk ' FNR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | PodName  |

    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster  
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | PodResstartCount |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                  |
      | (.*)      | event_start_epoch_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    ##Get End hour
    When I execute the SSH command date -d "+3 minutes" +%H | awk '{$0=int($0)}1' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value    |
      | (.*)      | EndHour  |

    When I execute the SSH command date -d "+3 minutes" +%M | awk '{$0=int($0)}1' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value       |
      | (.*)      | EndMinutes  |

    ##Perform Pod Restart
		Given I execute the steps from {config.global.scenario.resiliency.lib-dir}RestartPod.feature

    Then I wait for {config.global.constant.threehundred} seconds

    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster  
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                               | occurrence |
      | {Regex}(.*) | greaterthan({SSH.PodResstartCount}) | present    |

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never policy-builder | awk '{print $1}' at K8SMaster

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf}  | grep -v Running at K8SMaster

    ####Capture End Time after Reboot
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


    ## Check status of the deployment.
    When I send a REST Request as GetDeploymentStatus4 to Resource URI /api/operational/system/status on endpoint PCFRestEndpoint using http method GET
	Then I receive a REST Response for GetDeploymentStatus4 and validate using following attributes:
		| attribute        | value |
		| {HTTPStatusCode} | 200   |
	And I save the REST Response for GetDeploymentStatus4 with the following attributes:
      | attribute                                                                  | value      |
      | {XPath}/*[local-name()='status']/*[local-name()='percent-ready']/text()    | depPercent |  
   Then I validate the following attributes:
  	  | attribute             | value                                            |
   	  | {WSClient.depPercent} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) | 
   	  
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
    
    Given I print:====================== PCF Restart Engine pod End  =========================
    
    Given I print:====================== PCF Delete RestEndpoint pod Start  =========================

    ##Perform Pcf-rest-ep Pod reboot  
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never ^pcf-rest-ep | awk ' FNR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | PodName  |

    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster  
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | PodResstartCount |    

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                  |
      | (.*)      | event_start_epoch_time |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    ##Get End hour
    When I execute the SSH command date -d "+3 minutes" +%H | awk '{$0=int($0)}1' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value    |
      | (.*)      | EndHour  |

    When I execute the SSH command date -d "+3 minutes" +%M | awk '{$0=int($0)}1' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value       |
      | (.*)      | EndMinutes  |


    When I execute using handler K8SMaster the SSH shell command "kubectl delete pod {SSH.PodName} -n {config.sut.k8s.namespace.pcf}"

	  Then I wait for {config.global.constant.twohundred.forty} seconds		
    
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never {SSH.PodName} at K8SMaster
	  Then I receive a SSH response and check the presence of following strings:
			| string           | occurrence |
		  | {SSH.PodName}    | absent     |

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never ^pcf-rest-ep | awk ' FNR == 1 {print $1}' at K8SMaster

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf}  | grep -v Running at K8SMaster

    ####Capture End Time after Reboot
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
    
    
    ## Check status of the deployment.
    When I send a REST Request as GetDeploymentStatus5 to Resource URI /api/operational/system/status on endpoint PCFRestEndpoint using http method GET
	  Then I receive a REST Response for GetDeploymentStatus5 and validate using following attributes:
			| attribute        | value |
			| {HTTPStatusCode} | 200   |
	 And I save the REST Response for GetDeploymentStatus5 with the following attributes:
      | attribute                                                                  | value      |
      | {XPath}/*[local-name()='status']/*[local-name()='percent-ready']/text()    | depPercent |  
   Then I validate the following attributes:
  	  | attribute             | value                                            |
   	  | {WSClient.depPercent} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) | 
   	  
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
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature
    
    Given I print:====================== PCF Delete RestEndpoint pod End  =========================

    ##Change the variables
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}VariableChange.feature
    
    Given I print:====================== PCF Restart CDL Session pod Start  =========================

    ##Perform cdl session Pod reboot  
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never cdl-slot-session-c | awk ' FNR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | PodName  |

    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster  
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | PodResstartCount |     

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                  |
      | (.*)      | event_start_epoch_time |
      
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |
      
    ##Get End hour
    When I execute the SSH command date -d "+3 minutes" +%H | awk '{$0=int($0)}1' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value    |
      | (.*)      | EndHour  |
      
    When I execute the SSH command date -d "+3 minutes" +%M | awk '{$0=int($0)}1' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value       |
      | (.*)      | EndMinutes  |
      
    ##Perform Pod Restart
    Given I execute the steps from {config.global.scenario.resiliency.lib-dir}RestartPod.feature

	  Then I wait for {config.global.constant.threehundred} seconds
    
    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster  
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                               | occurrence |
      | {Regex}(.*) | greaterthan({SSH.PodResstartCount}) | present    |
     
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never {SSH.PodName} at K8SMaster
	
	  When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep -v Running at K8SMaster
	
    ####Capture End Time after Reboot
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
    
    
    ## Check status of the deployment.
    When I send a REST Request as GetDeploymentStatus6 to Resource URI /api/operational/system/status on endpoint PCFRestEndpoint using http method GET
	  Then I receive a REST Response for GetDeploymentStatus6 and validate using following attributes:
		  | attribute        | value |
	  	| {HTTPStatusCode} | 200   |
	  And I save the REST Response for GetDeploymentStatus6 with the following attributes:
      | attribute                                                                  | value      |
      | {XPath}/*[local-name()='status']/*[local-name()='percent-ready']/text()    | depPercent |  
    Then I validate the following attributes:
  	  | attribute             | value                                            |
   	  | {WSClient.depPercent} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) | 
   	  
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
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature
    
    Given I print:====================== PCF Restart CDL Session pod End  =========================
    
    ##Change the variables
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}VariableChange.feature
 
    Given I print:====================== PCF Restart CRD pod Start  =========================

    ##Perform CRD Pod reboot  
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never {config.global.command.get.crd-pod} | awk ' FNR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | PodName  |
      
    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster  
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | PodResstartCount |     

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                  |
      | (.*)      | event_start_epoch_time |
      
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |
      
    ##Get End hour
    When I execute the SSH command date -d "+3 minutes" +%H | awk '{$0=int($0)}1' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value    |
      | (.*)      | EndHour  |
      
    When I execute the SSH command date -d "+3 minutes" +%M | awk '{$0=int($0)}1' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value       |
      | (.*)      | EndMinutes  |
      
    ##Perform Pod Restart
    Given I execute the steps from {config.global.scenario.resiliency.lib-dir}RestartPod.feature

	  Then I wait for {config.global.constant.threehundred} seconds
    
    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster  
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                               | occurrence |
      | {Regex}(.*) | greaterthan({SSH.PodResstartCount}) | present    |
     
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never {SSH.PodName} at K8SMaster
	
	  When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf}  | grep -v Running at K8SMaster
	
    ####Capture End Time after Reboot
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
    
    
    ## Check status of the deployment.
    When I send a REST Request as GetDeploymentStatus7 to Resource URI /api/operational/system/status on endpoint PCFRestEndpoint using http method GET
	  Then I receive a REST Response for GetDeploymentStatus7 and validate using following attributes:
		  | attribute        | value |
	  	| {HTTPStatusCode} | 200   |
	  And I save the REST Response for GetDeploymentStatus7 with the following attributes:
      | attribute                                                                  | value      |
      | {XPath}/*[local-name()='status']/*[local-name()='percent-ready']/text()    | depPercent |  
    Then I validate the following attributes:
  	  | attribute             | value                                            |
   	  | {WSClient.depPercent} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) | 
   	  
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
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature
    
    Given I print:====================== PCF Restart CRD pod End  =========================
    
    ##Change the variables
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}VariableChange.feature
    
    Given I print:====================== PCF Restart LDAP-ep pod Start  =========================

    ##Perform Ldap-pcf-cps-ldap-ep Pod reboot  
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never ^ldap-{config.sut.k8s.namespace.pcf}-cps-ldap-ep | awk ' FNR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | PodName  |
      
    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster  
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | PodResstartCount |     

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                  |
      | (.*)      | event_start_epoch_time |
      
    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |
      
    ##Get End hour
    When I execute the SSH command date -d "+3 minutes" +%H | awk '{$0=int($0)}1' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value    |
      | (.*)      | EndHour  |
      
    When I execute the SSH command date -d "+3 minutes" +%M | awk '{$0=int($0)}1' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value       |
      | (.*)      | EndMinutes  |
      
    ##Perform Pod Restart
    Given I execute the steps from {config.global.scenario.resiliency.lib-dir}RestartPod.feature
    
		Then I wait for {config.global.constant.threehundred} seconds
    
    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never {SSH.PodName} | awk ' FNR == 1 {print $4}' at K8SMaster  
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                               | occurrence |
      | {Regex}(.*) | greaterthan({SSH.PodResstartCount}) | present    |
    
   
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never ^ldap-{config.sut.k8s.namespace.pcf}-cps-ldap-ep | awk ' FNR == 1 {print $1}' at K8SMaster
	
	  When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf}  | grep -v Running at K8SMaster
	
    ####Capture End Time after Reboot
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
    
    
    ## Check status of the deployment.
    When I send a REST Request as GetDeploymentStatus8 to Resource URI /api/operational/system/status on endpoint PCFRestEndpoint using http method GET
	  Then I receive a REST Response for GetDeploymentStatus8 and validate using following attributes:
	  	| attribute        | value |
	  	| {HTTPStatusCode} | 200   |
	  And I save the REST Response for GetDeploymentStatus8 with the following attributes:
      | attribute                                                                  | value      |
      | {XPath}/*[local-name()='status']/*[local-name()='percent-ready']/text()    | depPercent |  
    Then I validate the following attributes:
  	  | attribute             | value                                            |
   	  | {WSClient.depPercent} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) | 
   	  
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
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration2_Steps.feature
    
    Given I print:====================== PCF Restart LDAP-ep pod End  =========================
    
    #CICD report start#####################
    Given I define the following constants:
      | name        | value                                 |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | PCF Various Resiliency Aggrevator | Pass |
    #CICD report end#####################
    
  @Tzc183203670c 
  Scenario: BV_Aggravator_restep_pod_delete
  
    Given I print: "BV_Aggravator_restep_pod_delete"
    
  @Tzc183203671c 
  Scenario: BV_Aggravator_cdlSession_pod_restart
  
    Given I print: "BV_Aggravator_cdlSession_pod_restart"
    
  @Tzc183203672c 
  Scenario: BV_Aggravator_crd_pod_restart
  
    Given I print: "BV_Aggravator_crd_pod_restart"
    
  @Tzc183203673c 
  Scenario: BV_Aggravator_ldapep_pod_restart
  
    Given I print: "BV_Aggravator_ldapep_pod_restart"
    