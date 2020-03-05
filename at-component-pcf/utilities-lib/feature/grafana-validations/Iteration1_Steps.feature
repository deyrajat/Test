###############################################################################################
# Date: <15/12/2017> Version: <Initial version: 18.0> $1Create by <Soumil Chatterjee, soumicha>
# Date: <05/07/2018> Version: <Enhancement for GR and HA Consolidation> Updated by <bhchauha>
###############################################################################################
##Validations: Threshold checks done by comparing values with benchmark ones
@Iteration1Checks

Feature: Iteration1_checks

  Scenario: Capturing KPI values for 1st iteration stabilization period

    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}CommonFile.feature
    
    When I execute the SSH command echo $(( {SSH.grafana_stop_time} - {SSH.grafana_start_time} )) at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | SampleDuration |

    When I execute the SSH command echo '&start={SSH.grafana_start_time}&end={SSH.grafana_stop_time}&step={config.Step_Duration}' at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value     |
      | (.*)      | TimeQuery |

    #CICD report start#####################
    #Performance
    Given I expect the next test step to execute if '("{Constant.testtype}" == "performance")'
    Then I update report for table {Constant.testtype} with the following details:
      | {config.global.report.label.tps} | Fail |
    Given I end the if
    #CICD report end#####################

    #### Wait before Data collection as per CDET CSCvq35477
    Given I wait for {config.global.constant.sixty} seconds

    When I execute the SSH command echo Failed at SITEHOST
    Then I save the SSH response in the following variables:
       | attribute | value      |
       | (.*)      | TestStatus |

    Given I loop {Constant.loopCount} times
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}SetVariables_Iteration1.feature
    
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_N7Create_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | N7CreateTPSOne{Constant.channelIndex} |

    #CCRITPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.N7CreateTPS1} {SSH.N7CreateTPS2} {SSH.N7CreateTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |    

    #Total LDAPTPS capture
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_LDAP_Successful_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                  |
      | (.*)      | TotalLDAPTPSOne{Constant.channelIndex} |

    #LDAP TPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.TotalLDAPTPS1} {SSH.TotalLDAPTPS2} {SSH.TotalLDAPTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
      
    Given I expect the next test step to execute if ({config.sut.ldap.validation.add-modify-tps-validation.enable} > 0)    
    
	    #LDAPTPS Modify capture
	    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_LDAP_Modify_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                  |
	      | (.*)      | TotalLDAPModifyTPSOne{Constant.channelIndex} |
	
	    #LDAPTPS Modify check
	    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.TotalLDAPModifyTPS1} {SSH.TotalLDAPModifyTPS2} {SSH.TotalLDAPModifyTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
	    Then I receive a SSH response and check the presence of following strings:
	      | string                            | occurrence |
	      | Current Value is within threshold | present    |
	      
	    #LDAPTPS Add capture
	    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_LDAP_Add_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                  |
	      | (.*)      | TotalLDAPAddTPSOne{Constant.channelIndex} |
	
	    #LDAPTPS Add check
	    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.TotalLDAPAddTPS1} {SSH.TotalLDAPAddTPS2} {SSH.TotalLDAPAddTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
	    Then I receive a SSH response and check the presence of following strings:
	      | string                            | occurrence |
	      | Current Value is within threshold | present    |
      
    Given I end the if 
    
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_PLF_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | TotalPLFTPSOne{Constant.channelIndex} |

    #PLF TPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.TotalPLFTPS1} {SSH.TotalPLFTPS2} {SSH.TotalPLFTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_NAP_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                 |
      | (.*)      | TotalNAPTPSOne{Constant.channelIndex} |

    #NAP TPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.TotalNAPTPS1} {SSH.TotalNAPTPS2} {SSH.TotalNAPTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_N7Update_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                 |
      | (.*)      | N7UpdateTPSOne{Constant.channelIndex} |

    #CCRUTPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.N7UpdateTPS1} {SSH.N7UpdateTPS2} {SSH.N7UpdateTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_N7Delete_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | N7DeleteTPSOne{Constant.channelIndex} |

    #CCRTTPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.N7DeleteTPS1} {SSH.N7DeleteTPS2} {SSH.N7DeleteTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
      
    #Capturing Gx RAR TPS and check
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_N28Notify_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | N28NotifyTPSOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.N28NotifyTPS1} {SSH.N28NotifyTPS2} {SSH.N28NotifyTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
      
    #Capturing Rx RAR TPS and check
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_RxRAR_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | RxRARTPSOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.RxRARTPS1} {SSH.RxRARTPS2} {SSH.RxRARTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
      
    #Capturing Rx AAR TPS and check
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_RxAAR_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | RxAARTPSOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.RxAARTPS1} {SSH.RxAARTPS2} {SSH.RxAARTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    #Capturing Rx ASR TPS and check
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_RxASR_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | RxASRTPSOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.RxASRTPS1} {SSH.RxASRTPS2} {SSH.RxASRTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
      
    #Capturing Rx STR TPS and check
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_RxSTR_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | RxSTRTPSOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.RxSTRTPS1} {SSH.RxSTRTPS2} {SSH.RxSTRTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
      
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
      | attribute | value                              |
      | (.*)      | TotalTPSOne{Constant.channelIndex} |

    #Total TPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.TotalTPS1} {SSH.TotalTPS2} {SSH.TotalTPSOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
      
    #CICD report start#####################
    Given I define the following constants:
      | name      | value                              |
      | DRTstatus | {config.global.report.result.fail} |
    #CICD report end#####################

    ####ResponseTimes
    Given I print: ********************************************************************\n		ResponseTimes		\n********************************************************************

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_CCRI_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | N7CreateRTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.N7CreateRT{Constant.channelIndex}} {SSH.N7CreateRTOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_CCRU_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | N7UpdateRTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.N7UpdateRT{Constant.channelIndex}} {SSH.N7UpdateRTOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_CCRT_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | N7DeleteRTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.N7DeleteRT{Constant.channelIndex}} {SSH.N7DeleteRTOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_RAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                             |
      | (.*)      | N28NotifyRTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.N28NotifyRT{Constant.channelIndex}} {SSH.N28NotifyRTOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_RAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                             |
      | (.*)      | RxRARRTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.RxRARRT{Constant.channelIndex}} {SSH.RxRARRTOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_AAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                             |
      | (.*)      | RxAARRTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.RxAARRT{Constant.channelIndex}} {SSH.RxAARRTOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_ASR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                             |
      | (.*)      | RxASRRTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.RxASRRT{Constant.channelIndex}} {SSH.RxASRRTOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_STR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                             |
      | (.*)      | RxSTRRTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.RxSTRRT{Constant.channelIndex}} {SSH.RxSTRRTOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | MongoDBRTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.MongoDBRT{Constant.channelIndex}} {SSH.MongoDBRTOne{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_imsiapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                       |
      | (.*)      | DBdeleteimsiapnRTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBdeleteimsiapnRT{Constant.channelIndex}} {SSH.DBdeleteimsiapnRTOne{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_ipv4}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                    |
      | (.*)      | DBdeleteipv4RTOne{Constant.channelIndex} |	  

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBdeleteipv4RT{Constant.channelIndex}} {SSH.DBdeleteipv4RTOne{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_ipv6}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                    |
      | (.*)      | DBdeleteipv6RTOne{Constant.channelIndex} |	  

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBdeleteipv6RT{Constant.channelIndex}} {SSH.DBdeleteipv6RTOne{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_msisdnapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                         |
      | (.*)      | DBdeletemsisdnapnRTOne{Constant.channelIndex} |	  

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBdeletemsisdnapnRT{Constant.channelIndex}} {SSH.DBdeletemsisdnapnRTOne{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_session}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                       |
      | (.*)      | DBdeletesessionRTOne{Constant.channelIndex} |	  

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBdeletesessionRT{Constant.channelIndex}} {SSH.DBdeletesessionRTOne{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_imsiapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                      |
      | (.*)      | DBstoreimsiapnRTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBstoreimsiapnRT{Constant.channelIndex}} {SSH.DBstoreimsiapnRTOne{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_ipv4}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                   |
      | (.*)      | DBstoreipv4RTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBstoreipv4RT{Constant.channelIndex}} {SSH.DBstoreipv4RTOne{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
	  
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_ipv6}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                   |
      | (.*)      | DBstoreipv6RTOne{Constant.channelIndex} |	  

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBstoreipv6RT{Constant.channelIndex}} {SSH.DBstoreipv6RTOne{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_msisdnapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                        |
      | (.*)      | DBstoremsisdnapnRTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBstoremsisdnapnRT{Constant.channelIndex}} {SSH.DBstoremsisdnapnRTOne{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
	  
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_session}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                      |
      | (.*)      | DBstoresessionRTOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBstoresessionRT{Constant.channelIndex}} {SSH.DBstoresessionRTOne{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                                 |
      | DRTstatus | {config.global.report.result.success} |
    #CICD report end#####################
    
    ##Capture Avg 3xxx errors in Iteration1 duration
    Given I print: ###Capture Avg 3xxx errors in Iteration1 duration ###
	    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.3XX_IncErrors_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
	    Then I save the SSH response in the following variables:
	      | attribute | value           |
	      | (.*)      | 3xxCntIncoming |
	    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.3XX_OutErrors_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
	    Then I save the SSH response in the following variables:
	      | attribute | value           |
	      | (.*)      | 3xxCntOutgoing |
	    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.3XXX_Diameter_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
	    Then I save the SSH response in the following variables:
	      | attribute | value           |
	      | (.*)      | 3xxxCntDiameter |
	      
	    When I execute the SSH command echo $(({SSH.3xxCntIncoming}+{SSH.3xxCntOutgoing}+{SSH.3xxxCntDiameter})) at {Constant.hostname_{Constant.channelIndex}}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                |
	      | (.*)      | 3xxxErrAvgOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.3xxxErrAvgOne{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                  |
      | (.*)      | Total3xxxErrorsOne{Constant.channelIndex} |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                              |
      | DEPstatus | {config.global.report.result.fail} |
    #CICD report end#####################

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSOne{Constant.channelIndex}} {SSH.TotalLDAPTPSOne{Constant.channelIndex}} {SSH.Total3xxxErrorsOne{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                    | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                                 |
      | DEPstatus | {config.global.report.result.success} |
    #CICD report end#####################

    ##Capture Avg 4xxx errors in Iteration1 duration
    Given I print: ###Capture Avg 4xxx errors in Iteration1 duration ###

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
	      | attribute | value                                |
	      | (.*)      | 4xxxErrAvgOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.4xxxErrAvgOne{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                  |
      | (.*)      | Total4xxxErrorsOne{Constant.channelIndex} |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                              |
      | DEPstatus | {config.global.report.result.fail} |
    #CICD report end#####################

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSOne{Constant.channelIndex}} {SSH.TotalLDAPTPSOne{Constant.channelIndex}} {SSH.Total4xxxErrorsOne{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                    | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                                 |
      | DEPstatus | {config.global.report.result.success} |
    #CICD report end#####################

    ##Capture Avg 5xxx errors in Iteration1 duration
    Given I print: ###Capture Avg 5xxx errors in Iteration1 duration ###

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
      | attribute | value                                |
      | (.*)      | 5xxxErrAvgOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.5xxxErrAvgOne{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                  |
      | (.*)      | Total5xxxErrorsOne{Constant.channelIndex} |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                              |
      | DEPstatus | {config.global.report.result.fail} |
    #CICD report end#####################

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSOne{Constant.channelIndex}} {SSH.TotalLDAPTPSOne{Constant.channelIndex}} {SSH.Total5xxxErrorsOne{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                    | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                                 |
      | DEPstatus | {config.global.report.result.success} |
    #CICD report end#####################

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Failed_DB_queries_count}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                           |
      | (.*)      | DBErrAvgOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.DBErrAvgOne{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                |
      | (.*)      | TotalDBErrorsOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSOne{Constant.channelIndex}} {SSH.TotalLDAPTPSOne{Constant.channelIndex}} {SSH.TotalDBErrorsOne{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                    | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    ##Capturing Timeouts in Iteration1 duration
    Given I print: ##Capturing Timeouts in Iteration1 duration ###

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
      | (.*)      | TimeoutCntOne{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.TimeoutCntOne{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                  |
      | (.*)      | TotaltimeoutCntOne{Constant.channelIndex} |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                              |
      | DTPstatus | {config.global.report.result.fail} |
    #CICD report end#####################

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSOne{Constant.channelIndex}} {SSH.TotalLDAPTPSOne{Constant.channelIndex}} {SSH.TotaltimeoutCntOne{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                    | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                                 |
      | DTPstatus | {config.global.report.result.success} |
    #CICD report end#####################
    
    Given I print: *****************************************************************************\n 	Bechmarking values of Site{Constant.channelIndex}	\n*****************************************************************************\n | attribute               | value	     		|      \n |  TotalTPSOne{Constant.channelIndex}            |{SSH.TotalTPSOne{Constant.channelIndex}}		|      \n |  TotalLDAPTPSOne{Constant.channelIndex}        |{SSH.TotalLDAPTPSOne{Constant.channelIndex}}	|      \n |  TotalPLFTPSOne{Constant.channelIndex}        |{SSH.TotalPLFTPSOne{Constant.channelIndex}}	|      \n|  TotalNAPTPSOne{Constant.channelIndex}        |{SSH.TotalNAPTPSOne{Constant.channelIndex}}	|      \n|  N7CreateTPSOne{Constant.channelIndex}           |{SSH.N7CreateTPSOne{Constant.channelIndex}}		|      \n |  N7UpdateTPSOne{Constant.channelIndex}           |{SSH.N7UpdateTPSOne{Constant.channelIndex}}		|      \n |  N7DeleteTPSOne{Constant.channelIndex}           |{SSH.N7DeleteTPSOne{Constant.channelIndex}}		|      \n |  N28NotifyTPSOne{Constant.channelIndex}            |{SSH.N28NotifyTPSOne{Constant.channelIndex}}		|      \n |  RxRARTPSOne{Constant.channelIndex}            |{SSH.RxRARTPSOne{Constant.channelIndex}}		|      \n|  RxAARTPSOne{Constant.channelIndex}            |{SSH.RxAARTPSOne{Constant.channelIndex}}		|      \n|  RxASRTPSOne{Constant.channelIndex}            |{SSH.RxASRTPSOne{Constant.channelIndex}}		|      \n|  RxSTRTPSOne{Constant.channelIndex}            |{SSH.RxSTRTPSOne{Constant.channelIndex}}		|      \n|  N7CreateRTOne{Constant.channelIndex}            |{SSH.N7CreateRTOne{Constant.channelIndex}}		|      \n|  N7UpdateRTOne{Constant.channelIndex}            |{SSH.N7UpdateRTOne{Constant.channelIndex}}		|      \n|  N7DeleteRTOne{Constant.channelIndex}            |{SSH.N7DeleteRTOne{Constant.channelIndex}}		|      \n|  N28NotifyRTOne{Constant.channelIndex}             |{SSH.N28NotifyRTOne{Constant.channelIndex}}		|      \n|  RxRARRTOne{Constant.channelIndex}             |{SSH.RxRARRTOne{Constant.channelIndex}}		|      \n|  RxAARRTOne{Constant.channelIndex}             |{SSH.RxAARRTOne{Constant.channelIndex}}		|      \n|  RxASRRTOne{Constant.channelIndex}             |{SSH.RxASRRTOne{Constant.channelIndex}}		|      \n|  RxSTRRTOne{Constant.channelIndex}             |{SSH.RxSTRRTOne{Constant.channelIndex}}		|      \n|  5xxxErrAvgOne{Constant.channelIndex}          |{SSH.5xxxErrAvgOne{Constant.channelIndex}}		|      \n|  Total5xxxErrorsOne{Constant.channelIndex}     |{SSH.Total5xxxErrorsOne{Constant.channelIndex}}	|      \n|  3xxxErrAvgOne{Constant.channelIndex}          |{SSH.3xxxErrAvgOne{Constant.channelIndex}}		|      \n|  Total3xxxErrorsOne{Constant.channelIndex}     |{SSH.Total3xxxErrorsOne{Constant.channelIndex}}	|      \n|  TimeoutCntOne{Constant.channelIndex}          | {SSH.TimeoutCntOne{Constant.channelIndex}}		|      \n|  TotaltimeoutCntOne{Constant.channelIndex}     |{SSH.TotaltimeoutCntOne{Constant.channelIndex}}	|      \n*****************************************************************************
    
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
      | {config.global.report.label.tps} | Pass |
    Given I end the if
    #CICD report end#####################
