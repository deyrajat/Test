###############################################################################################
# Date: <15/12/2017> Version: <Initial version: 18.0> $1Create by <Soumil Chatterjee, soumicha>
# Date: <27/06/2018> Version: <Enhancement for GR and HA Consolidation> Updated by <bhchauha>
###############################################################################################
##Capturing benchmark data before event start which will later be used for validations

@BenchmarkCapture

Feature: Benchmark_Capture

  Scenario: Capture Benchmark Values
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}CommonFile.feature
    
    When I execute the SSH command echo $(( {SSH.grafana_stop_time} - {SSH.grafana_start_time} )) at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | SampleDuration |    

    When I execute the SSH command echo '&start={SSH.grafana_start_time}&end={SSH.grafana_stop_time}&step={config.Step_Duration}' at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value     |
      | (.*)      | TimeQuery |

    #### Wait before Data collection as per CDET CSCvq35477
    Given I wait for {config.global.constant.sixty} seconds

    When I execute the SSH command echo "Failed" at SITEHOST
    Then I save the SSH response in the following variables:
       | attribute | value      |
       | (.*)      | TestStatus |

    Given I loop {Constant.loopCount} times

    ##Capturing 1st Benchmark
    Given I print: ######################### Grafana fetching checks/Validation benchmark for site{Constant.channelIndex} #########################

    #Capturing Total LDAP TPS
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_LDAP_Successful_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | TotalLDAPTPS{Constant.channelIndex} |

    When I execute the SSH command echo {SSH.TotalLDAPTPS{Constant.channelIndex}} at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string      | value          | occurrence |
      | {Regex}(.*) | greaterthan(0) | present    |    

    Given I expect the next test step to execute if ({config.sut.ldap.validation.add-modify-tps-validation.enable} > 0)    
    
	    ### Capture LDAP Modify TPS
	    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_LDAP_Modify_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                     |
	      | (.*)      | TotalLDAPModifyTPS{Constant.channelIndex} |    
	    
	    ### Capture LDAP Add TPS
	    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_LDAP_Add_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                  |
	      | (.*)      | TotalLDAPAddTPS{Constant.channelIndex} | 
	      
	Given I end the if  
    
    #Capturing Total PLF TPS
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_PLF_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | TotalPLFTPS{Constant.channelIndex} |
      
    #Capturing Total NAP TPS
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_NAP_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | TotalNAPTPS{Constant.channelIndex} |    

    #Capturing N7Create TPS
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_N7Create_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                            |
      | (.*)      | N7CreateTPS{Constant.channelIndex} |

    #Capturing N7Update TPS
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_N7Update_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                            |
      | (.*)      | N7UpdateTPS{Constant.channelIndex} |

    #Capturing N7Delete TPS
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_N7Delete_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                            |
      | (.*)      | N7DeleteTPS{Constant.channelIndex} |

    #Capturing N28Notify TPS
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_N28Notify_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                           |
      | (.*)      | N28NotifyTPS{Constant.channelIndex} |

    #Capturing RxRAR TPS
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_RxRAR_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                           |
      | (.*)      | RxRARTPS{Constant.channelIndex} |

    #Capturing RxAAR TPS
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_RxAAR_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                           |
      | (.*)      | RxAARTPS{Constant.channelIndex} |

    #Capturing RxASR TPS
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_RxASR_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                           |
      | (.*)      | RxASRTPS{Constant.channelIndex} |

    #Capturing RxSTR TPS
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_RxSTR_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                           |
      | (.*)      | RxSTRTPS{Constant.channelIndex} |

    #Capturing Total TPS
    ## Get Grafana number of TPS Limit
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
      | (.*)      | TotalTPS{Constant.channelIndex} |

    ##Check Total TPS has reached minimum expected TPS
    Given I print: ### Check Total TPS has reached minimum expected TPS ###
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}CheckTotalTPS.sh {SSH.TotalTPS{Constant.channelIndex}} {SSH.TotalLDAPTPS{Constant.channelIndex}} {config.scenario.thresholds.application.expected-tps} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                             | occurrence |
      | Avg TPS matches expected TPS value | present    |
      | Avg TPS is less than expected TPS  | absent     |

    ##Capturing avg Response Time for 1st benchmark duration
    Given I print: ### Capturing avg Response Time for 1st benchmark duration ###

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_CCRI_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                           |
      | (.*)      | N7CreateRT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_CCRU_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                           |
      | (.*)      | N7UpdateRT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_CCRT_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                           |
      | (.*)      | N7DeleteRT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_RAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                          |
      | (.*)      | N28NotifyRT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_RAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                          |
      | (.*)      | RxRARRT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_AAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                          |
      | (.*)      | RxAARRT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_ASR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                          |
      | (.*)      | RxASRRT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_STR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                          |
      | (.*)      | RxSTRRT{Constant.channelIndex} |

    ##Capturing DB query average response time      
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                            |
      | (.*)      | MongoDBRT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_imsiapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                    |
      | (.*)      | DBdeleteimsiapnRT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_ipv4}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                 |
      | (.*)      | DBdeleteipv4RT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_ipv6}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                 |
      | (.*)      | DBdeleteipv6RT{Constant.channelIndex} |	  

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_msisdnapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                      |
      | (.*)      | DBdeletemsisdnapnRT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_session}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                    |
      | (.*)      | DBdeletesessionRT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_imsiapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                   |
      | (.*)      | DBstoreimsiapnRT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_ipv4}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                |
      | (.*)      | DBstoreipv4RT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_ipv6}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                |
      | (.*)      | DBstoreipv6RT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_msisdnapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                     |
      | (.*)      | DBstoremsisdnapnRT{Constant.channelIndex} |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_session}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                   |
      | (.*)      | DBstoresessionRT{Constant.channelIndex} |

    ##Get CCRI to Total TPS Ratio
    Given I print: ## Get CCRI to Total TPS Ratio ###

    Given I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}/getCCRIRatio.sh {SSH.TotalTPS{Constant.channelIndex}} {SSH.N7CreateTPS{Constant.channelIndex}} " at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | CCRITotRatio{Constant.channelIndex} |

    ##Capture Avg 3xxx errors in benchmark duration
    Given I print: ###Capture Avg 3xxx errors in benchmark duration ###

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
      | (.*)      | 3xxxErrAvg{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.3xxxErrAvg{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                  |
      | (.*)      | Total3xxxErrors{Constant.channelIndex} |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                              |
      | DEPstatus | {config.global.report.result.fail} |
    #CICD report end#####################

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPS{Constant.channelIndex}} {SSH.TotalLDAPTPS{Constant.channelIndex}} {SSH.Total3xxxErrors{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                                               | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                                 |
      | DEPstatus | {config.global.report.result.success} |
    #CICD report end#####################

    ##Capture Avg 4xxx errors in benchmark duration
    Given I print: ###Capture Avg 4xxx errors in benchmark duration ###

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
      | (.*)      | 4xxxErrAvg{Constant.channelIndex} |
 
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.4xxxErrAvg{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                  |
      | (.*)      | Total4xxxErrors{Constant.channelIndex} |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                              |
      | DEPstatus | {config.global.report.result.fail} |
    #CICD report end#####################

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPS{Constant.channelIndex}} {SSH.TotalLDAPTPS{Constant.channelIndex}} {SSH.Total4xxxErrors{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                                               | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                                 |
      | DEPstatus | {config.global.report.result.success} |
    #CICD report end#####################

    ##Capture Avg 5xxx errors in benchmark duration
    Given I print: ###Capture Avg 5xxx errors in benchmark duration ###

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
      | (.*)      | 5xxxErrAvg{Constant.channelIndex} |
 
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.5xxxErrAvg{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                  |
      | (.*)      | Total5xxxErrors{Constant.channelIndex} |

    #CICD report start#####################.
    Given I define the following constants:
      | name      | value                              |
      | DEPstatus | {config.global.report.result.fail} |
    #CICD report end#####################

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPS{Constant.channelIndex}} {SSH.TotalLDAPTPS{Constant.channelIndex}} {SSH.Total5xxxErrors{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                                               | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                                 |
      | DEPstatus | {config.global.report.result.success} |
    #CICD report end#####################

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Failed_DB_queries_count}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                           |
      | (.*)      | DBErrAvg{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.DBErrAvg{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                |
      | (.*)      | TotalDBErrors{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPS{Constant.channelIndex}} {SSH.TotalLDAPTPS{Constant.channelIndex}} {SSH.TotalDBErrors{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                                               | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    ##Capturing Timeouts in benchmark duration
    Given I print: ##Capturing Timeouts in benchmark duration ###

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
      | attribute | value                             |
      | (.*)      | TimeoutCnt{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.TimeoutCnt{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                  |
      | (.*)      | TotaltimeoutCnt{Constant.channelIndex} |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                              |
      | DTPstatus | {config.global.report.result.fail} |
    #CICD report end#####################

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPS{Constant.channelIndex}} {SSH.TotalLDAPTPS{Constant.channelIndex}} {SSH.TotaltimeoutCnt{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                                               | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                                 |
      | DTPstatus | {config.global.report.result.success} |
    #CICD report end#####################

    Given I print: *****************************************************************************\n 	Bechmarking values of Site{Constant.channelIndex}	\n*****************************************************************************\n | attribute               | value	     		|      \n |  TotalTPS{Constant.channelIndex}            |{SSH.TotalTPS{Constant.channelIndex}}		|      \n |  TotalLDAPTPS{Constant.channelIndex}        |{SSH.TotalLDAPTPS{Constant.channelIndex}}	|      \n |  TotalPLFTPS{Constant.channelIndex}        |{SSH.TotalPLFTPS{Constant.channelIndex}}	|      \n|  TotalNAPTPS{Constant.channelIndex}        |{SSH.TotalNAPTPS{Constant.channelIndex}}	|      \n|  N7CreateTPS{Constant.channelIndex}           |{SSH.N7CreateTPS{Constant.channelIndex}}		|      \n |  N7UpdateTPS{Constant.channelIndex}           |{SSH.N7UpdateTPS{Constant.channelIndex}}		|      \n |  N7DeleteTPS{Constant.channelIndex}           |{SSH.N7DeleteTPS{Constant.channelIndex}}		|      \n |  N28NotifyTPS{Constant.channelIndex}            |{SSH.N28NotifyTPS{Constant.channelIndex}}		|      \n |  RxRARTPS{Constant.channelIndex}            |{SSH.RxRARTPS{Constant.channelIndex}}		|      \n|  RxAARTPS{Constant.channelIndex}            |{SSH.RxAARTPS{Constant.channelIndex}}		|      \n|  RxASRTPS{Constant.channelIndex}            |{SSH.RxASRTPS{Constant.channelIndex}}		|      \n|  RxSTRTPS{Constant.channelIndex}            |{SSH.RxSTRTPS{Constant.channelIndex}}		|      \n|  N7CreateRT{Constant.channelIndex}            |{SSH.N7CreateRT{Constant.channelIndex}}		|      \n|  N7UpdateRT{Constant.channelIndex}            |{SSH.N7UpdateRT{Constant.channelIndex}}		|      \n|  N7DeleteRT{Constant.channelIndex}            |{SSH.N7DeleteRT{Constant.channelIndex}}		|      \n|  N28NotifyRT{Constant.channelIndex}             |{SSH.N28NotifyRT{Constant.channelIndex}}		|      \n|  RxRARRT{Constant.channelIndex}             |{SSH.RxRARRT{Constant.channelIndex}}		|      \n|  RxAARRT{Constant.channelIndex}             |{SSH.RxAARRT{Constant.channelIndex}}		|      \n|  RxASRRT{Constant.channelIndex}             |{SSH.RxASRRT{Constant.channelIndex}}		|      \n|  RxSTRRT{Constant.channelIndex}             |{SSH.RxSTRRT{Constant.channelIndex}}		|      \n|  5xxxErrAvg{Constant.channelIndex}          |{SSH.5xxxErrAvg{Constant.channelIndex}}		|      \n|  Total5xxxErrors{Constant.channelIndex}     |{SSH.Total5xxxErrors{Constant.channelIndex}}	|      \n|  3xxxErrAvg{Constant.channelIndex}          |{SSH.3xxxErrAvg{Constant.channelIndex}}		|      \n|  Total3xxxErrors{Constant.channelIndex}     |{SSH.Total3xxxErrors{Constant.channelIndex}}	|      \n|  TimeoutCnt{Constant.channelIndex}          | {SSH.TimeoutCnt{Constant.channelIndex}}		|      \n|  TotaltimeoutCnt{Constant.channelIndex}     |{SSH.TotaltimeoutCnt{Constant.channelIndex}}	|      \n*****************************************************************************

    Then I increment Constant.channelIndex by 1
    And I end loop
    
    When I execute the SSH command echo Passed at SITEHOST
    Then I save the SSH response in the following variables:
       | attribute | value      |
       | (.*)      | TestStatus |

    #CICD report start#####################
    #Performance
    Given I expect the next test step to execute if '("{Constant.testtype}" == "performance")'
    Then I update report for table {Constant.testtype} with the following details:
      | {config.global.report.label.tps} | Fail | {config.global.report.comment.tps} {SSH.TotalTPS1} |
    Given I end the if
    #CICD report end#####################

    #CICD report start#####################
    Given I expect the next test step to execute if '("{Constant.testtype}" == "performance")'
    Then I update report for table {Constant.testtype} with the following details:
      | {config.global.report.label.tps} | Pass |
    Given I end the if
    #CICD report end#####################
