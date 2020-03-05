#################################################################################################
# Date: <05/02/2018> Version: <Initial version: 14.0> $1Create by <abote>
# Date: <26/06/2018> Version: <Enhancement for GR and HA Consolidation> Updated by <bhchauha>
#################################################################################################
##Capturing values during event to be used for comparison with benchmark values
@EventChecks

Feature: Event_ValueCapture_Checks

  Scenario: Check Errors and Timeouts during first Failover

    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}CommonFile.feature
    
    When I execute the SSH command echo $(( {SSH.grafana_stop_time} - {SSH.grafana_start_time} )) at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | SampleDuration |

    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command echo '&start={SSH.grafana_start_time}&end={SSH.grafana_stop_time}&step={config.Step_Duration}'
    Then I save the SSH response in the following variables:
      | attribute | value     |
      | (.*)      | TimeQuery |
      
    Given I expect the next test step to execute if '("{Constant.VMShutdown}" == "no")'

	  #### Wait before Data collection as per CDET CSCvq35477
	  Given I wait for {config.global.constant.sixty} seconds

      When I execute the SSH command echo Failed at SITEHOST
      Then I save the SSH response in the following variables:
         | attribute | value      |
         | (.*)      | TestStatus |
      When I execute the SSH command {config.global.command.opsCenter.system-deployed-status} at CLIPcfOPSCenter
      Then I receive a SSH response and check the presence of following strings:
         | string                         | occurrence  |
         | system status deployed true    | present     |

	  Given I loop 5 times

            ## Check status of the deployment.
            When I execute the SSH command {config.global.command.opsCenter.system-deployed-status} at CLIPcfOPSCenter
            Then I receive a SSH response and check the presence of following strings:
              | string                         | occurrence  |
              | system status deployed true    | present     |
            When I execute the SSH command {config.global.command.opsCenter.system-deployed-status} at CLIPcfOPSCenter
            Then I save the SSH response in the following variables:
              | attribute                             | value           |
              | (system status percent-ready\s+\S+)   | depPerReady     |
            When I execute using handler SITEHOST the SSH command "echo {SSH.depPerReady}"
            Then I save the SSH response in the following variables:
              | attribute             | value       |
              | {Regex}(\d+.\d+)      | depPerReady |

			Given I break loop if {SSH.depPerReady} >= {config.global.thresholds.system.status-ready-expectedpercentage}

			Given I wait for {config.global.constant.sixty} seconds

		And I end loop 
		
		#### Print the pods status 
		When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} at K8SMaster
		
		When I execute the SSH command {config.global.commands.k8s.pod-list-cee} at K8SMaster

	    ## Check status of the deployment.
	    When I execute the SSH command {config.global.command.opsCenter.system-deployed-status} at CLIPcfOPSCenter
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

	    ## Check status of the deployment.
	    When I execute the SSH command {config.global.command.opsCenter.system-deployed-status} at CLICeeOPSCenter
	    Then I receive a SSH response and check the presence of following strings:
          | string                         | occurrence  |
          | system status deployed true    | present     |
	    When I execute the SSH command {config.global.command.opsCenter.system-deployed-status} at CLICeeOPSCenter
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
	   	  
	Given I end the if 

    Given I expect the next test step to execute if ({config.scenario.start.traffic} > 0)
    
	    Given I print:========== Show the ports that are started ============
	    When I execute the SSH command netstat -antlop | grep {config.tools.toolagent.ipaddress1} at ToolAgentHost

    Given I end the if 

    Given I loop {Constant.loopCount} times

    ######## Obtain the Total TPS ###############
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Incoming_Messages_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value       |
      | (.*)      | IncomingReq |	 
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Outgoing_Messages_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value       |
      | (.*)      | OutGoingReq |
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Diameter_Requests_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value       |
      | (.*)      | DiameterReq |
      
    When I execute the SSH command echo $(({SSH.IncomingReq}+{SSH.OutGoingReq}+{SSH.DiameterReq})) at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                           |
      | (.*)      | TotalTPSChk{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_LDAP_Successful_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                  |
      | (.*)      | TotalLDAPTPSChk{Constant.channelIndex} |

    Given I print: *********************************************\n  Check Errors and Timeouts during Failover for site{Constant.channelIndex}  \n*********************************************
    Given I print: *********************************************\n  5XXX Errors Check  \n*********************************************

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.5XX_IncErrors_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | 5xxCntIncoming |
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.5XX_OutErrors_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | 5xxCntOutgoing |
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.5XXX_Diameter_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value           |
      | (.*)      | 5xxxCntDiameter |

    When I execute the SSH command echo $(({SSH.5xxCntIncoming}+{SSH.5xxCntOutgoing}+{SSH.5xxxCntDiameter})) at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                             |
      | (.*)      | 5xxxErrChk{Constant.channelIndex} |
	      
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.5xxxErrChk{Constant.channelIndex}} {SSH.eventTimeSec} " at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | Total5xxxChk{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSChk{Constant.channelIndex}} {SSH.TotalLDAPTPSChk{Constant.channelIndex}} {SSH.Total5xxxChk{Constant.channelIndex}} {SSH.eventTimeSec} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                            | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application.alloweddeviationpercent-event-error}) | present    |

    Given I print: *********************************************\n  3XXX Errors Check  \n*********************************************
    
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.3XX_IncErrors_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | 3xxCntIncoming |
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.3XX_OutErrors_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | 3xxCntOutgoing |
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.3XXX_Diameter_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value           |
      | (.*)      | 3xxxCntDiameter |
      
    When I execute the SSH command echo $(({SSH.3xxCntIncoming}+{SSH.3xxCntOutgoing}+{SSH.3xxxCntDiameter})) at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                             |
      | (.*)      | 3xxxErrChk{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.3xxxErrChk{Constant.channelIndex}} {SSH.eventTimeSec} " at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | Total3xxxChk{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSChk{Constant.channelIndex}} {SSH.TotalLDAPTPSChk{Constant.channelIndex}} {SSH.Total3xxxChk{Constant.channelIndex}} {SSH.eventTimeSec} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                            | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application.alloweddeviationpercent-event-error}) | present    |

    Given I print: *********************************************\n  4XXX Errors Check  \n*********************************************
    
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.4XX_IncErrors_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | 4xxCntIncoming |
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.4XX_OutErrors_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | 4xxCntOutgoing |
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.4XXX_Diameter_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value           |
      | (.*)      | 4xxxCntDiameter |
      
    When I execute the SSH command echo $(({SSH.4xxCntIncoming}+{SSH.4xxCntOutgoing}+{SSH.4xxxCntDiameter})) at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                             |
      | (.*)      | 4xxxErrChk{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.4xxxErrChk{Constant.channelIndex}} {SSH.eventTimeSec} " at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | Total4xxxChk{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSChk{Constant.channelIndex}} {SSH.TotalLDAPTPSChk{Constant.channelIndex}} {SSH.Total4xxxChk{Constant.channelIndex}} {SSH.eventTimeSec} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                            | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application.alloweddeviationpercent-event-error}) | present    |

    Given I print: *********************************************\n  Failed DB queries  \n*********************************************

    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Failed_DB_queries_count}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator}
    Then I save the SSH response in the following variables:
      | attribute | value                           |
      | (.*)      | DBErrAvg{Constant.channelIndex} |

    When I execute using handler SITEHOST the SSH shell command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.DBErrAvg{Constant.channelIndex}} {SSH.SampleDuration}"
    Then I save the SSH response in the following variables:
      | attribute | value                                |
      | (.*)      | TotalDBErrors{Constant.channelIndex} |

    When I execute using handler SITEHOST the SSH shell command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPS{Constant.channelIndex}} {SSH.TotalLDAPTPS{Constant.channelIndex}} {SSH.TotalDBErrors{Constant.channelIndex}} {SSH.SampleDuration} "
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                    | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    Given I print: *********************************************\n  Timeouts checks  \n*********************************************

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.TimeOut_IncErrors_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | TimeoutCntIncoming | 
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.TimeOut_OutErrors_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | TimeoutCntOutgoing | 
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.TimeOut_Daimeter_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | TimeoutCntDiameter |

    When I execute the SSH command echo $(({SSH.TimeoutCntIncoming}+{SSH.TimeoutCntOutgoing}+{SSH.TimeoutCntDiameter})) at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                |
      | (.*)      | TimeoutCntChk{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.TimeoutCntChk{Constant.channelIndex}} {SSH.eventTimeSec}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                     |
      | (.*)      | TotaltimeoutCntChk{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSChk{Constant.channelIndex}} {SSH.TotalLDAPTPSChk{Constant.channelIndex}} {SSH.TotaltimeoutCntChk{Constant.channelIndex}} {SSH.eventTimeSec} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                            | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application.alloweddeviationpercent-event-error}) | present    |

    Given I print: *********************************************\n  System and Application Error Checks  \n*********************************************

    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DiameterEndpointsResponseTime}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
    Then I save the SSH response in the following variables:
      | attribute | value        |
      | (.*)      | DiameterEPRT |

    Then I validate the following attributes:
      | attribute          | value                                                    |
      | {SSH.DiameterEPRT} | lessthanorequal({config.global.thresholds.application.responsetime-endpoint}) |

    Given I print: *********************************************\n| attribute  | value |  \n| 5xxxErrChk{Constant.channelIndex} | {SSH.5xxxErrChk{Constant.channelIndex}} |  \n| TotalTPSChk{Constant.channelIndex} | {SSH.TotalTPSChk{Constant.channelIndex}} |  \n| TotalLDAPTPSChk{Constant.channelIndex} | {SSH.TotalLDAPTPSChk{Constant.channelIndex}}	| \n| Total5xxxChk{Constant.channelIndex} | {SSH.Total5xxxChk{Constant.channelIndex}} |	\n| 3xxxErrChk{Constant.channelIndex} | {SSH.3xxxErrChk{Constant.channelIndex}} | \n| Total3xxxChk{Constant.channelIndex} | {SSH.Total3xxxChk{Constant.channelIndex}} |	\n| TimeoutCntChk{Constant.channelIndex} | {SSH.TimeoutCntChk{Constant.channelIndex}} |	\n| TotaltimeoutCntChk{Constant.channelIndex}    | {SSH.TotaltimeoutCntChk{Constant.channelIndex}} | \n*********************************************

    Then I increment Constant.channelIndex by 1
    And I end loop
    
    When I execute the SSH command echo Passed at SITEHOST
    Then I save the SSH response in the following variables:
       | attribute | value      |
       | (.*)      | TestStatus |
