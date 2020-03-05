###############################################################################################
# Date: <15/12/2017> Version: <Initial version: 18.0> $1Create by <Soumil Chatterjee, soumicha>
# Date: <05/07/2018> Version: <Enhancement for GR and HA Consolidation> Updated by <bhchauha>
###############################################################################################
##Validations: Threshold checks done by comparing latest values with iteration 1 values
@Iteration2Checks

Feature: Iteration2_checks

  Scenario: Capturing KPI values for 2nd iteration stabilization period  

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
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}SetVariables_Iteration2.feature
    
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_N7Create_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | N7CreateTPSTwo{Constant.channelIndex} |

    #CCRITPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.N7CreateTPSOne1} {SSH.N7CreateTPSOne2} {SSH.N7CreateTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    #Total LDAPTPS capture
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_LDAP_Successful_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                  |
      | (.*)      | TotalLDAPTPSTwo{Constant.channelIndex} |

    #LDAP TPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.TotalLDAPTPSOne1} {SSH.TotalLDAPTPSOne2} {SSH.TotalLDAPTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
      
    Given I expect the next test step to execute if ({config.sut.ldap.validation.add-modify-tps-validation.enable} > 0)    
      
	    #LDAPTPS Modify capture
	    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_LDAP_Modify_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                  |
	      | (.*)      | TotalLDAPModifyTPSTwo{Constant.channelIndex} |
	
	    #LDAPTPS Modify check
	    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.TotalLDAPModifyTPSOne1} {SSH.TotalLDAPModifyTPSOne2} {SSH.TotalLDAPModifyTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
	    Then I receive a SSH response and check the presence of following strings:
	      | string                            | occurrence |
	      | Current Value is within threshold | present    |
	      
	    #LDAPTPS Add capture
	    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_LDAP_Add_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                  |
	      | (.*)      | TotalLDAPAddTPSTwo{Constant.channelIndex} |
	
	    #LDAPTPS Add check
	    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.TotalLDAPAddTPSOne1} {SSH.TotalLDAPAddTPSOne2} {SSH.TotalLDAPAddTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
	    Then I receive a SSH response and check the presence of following strings:
	      | string                            | occurrence |
	      | Current Value is within threshold | present    |
	      
	  Given I end the if 
	
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_PLF_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | TotalPLFTPSTwo{Constant.channelIndex} |

    #PLF TPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.TotalPLFTPSOne1} {SSH.TotalPLFTPSOne2} {SSH.TotalPLFTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_NAP_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                 |
      | (.*)      | TotalNAPTPSTwo{Constant.channelIndex} |

    #NAP TPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.TotalNAPTPSOne1} {SSH.TotalNAPTPSOne2} {SSH.TotalNAPTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
	
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_N7Update_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | N7UpdateTPSTwo{Constant.channelIndex} |

    #CCRUTPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.N7UpdateTPSOne1} {SSH.N7UpdateTPSOne2} {SSH.N7UpdateTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_N7Delete_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | N7DeleteTPSTwo{Constant.channelIndex} |

    #CCRTTPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.N7DeleteTPSOne1} {SSH.N7DeleteTPSOne2} {SSH.N7DeleteTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
      
    #Capturing Gx RAR TPS and check
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_N28Notify_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | N28NotifyTPSTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.N28NotifyTPSOne1} {SSH.N28NotifyTPSOne2} {SSH.N28NotifyTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
      
    #Capturing Rx RAR TPS and check
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_RxRAR_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | RxRARTPSTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.RxRARTPSOne1} {SSH.RxRARTPSOne2} {SSH.RxRARTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
      
    #Capturing Rx AAR TPS and check
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_RxAAR_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | RxAARTPSTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.RxAARTPSOne1} {SSH.RxAARTPSOne2} {SSH.RxAARTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    #Capturing Rx ASR TPS and check
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_RxASR_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | RxASRTPSTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.RxASRTPSOne1} {SSH.RxASRTPSOne2} {SSH.RxASRTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
      
    #Capturing Rx STR TPS and check
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Total_RxSTR_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.Extrator} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | RxSTRTPSTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.RxSTRTPSOne1} {SSH.RxSTRTPSOne2} {SSH.RxSTRTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
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
      | (.*)      | TotalTPSTwo{Constant.channelIndex} |

    #Total TPS check
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {SSH.TotalTPSOne1} {SSH.TotalTPSOne2} {SSH.TotalTPSTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
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
      | (.*)      | N7CreateRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.N7CreateRT{Constant.channelIndex}} {SSH.N7CreateRTTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_CCRU_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | N7UpdateRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.N7UpdateRT{Constant.channelIndex}} {SSH.N7UpdateRTTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_CCRT_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                              |
      | (.*)      | N7DeleteRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.N7DeleteRT{Constant.channelIndex}} {SSH.N7DeleteRTTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_RAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                             |
      | (.*)      | N28NotifyRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.N28NotifyRT{Constant.channelIndex}} {SSH.N28NotifyRTTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_RAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                             |
      | (.*)      | RxRARRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.RxRARRT{Constant.channelIndex}} {SSH.RxRARRTTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_AAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                             |
      | (.*)      | RxAARRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.RxAARRT{Constant.channelIndex}} {SSH.RxAARRTTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_ASR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                             |
      | (.*)      | RxASRRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.RxASRRT{Constant.channelIndex}} {SSH.RxASRRTTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_STR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                             |
      | (.*)      | RxSTRRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.RxSTRRT{Constant.channelIndex}} {SSH.RxSTRRTTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                               |
      | (.*)      | MongoDBRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.MongoDBRT{Constant.channelIndex}} {SSH.MongoDBRTTwo{Constant.channelIndex}} {config.global.thresholds.application.alloweddeviationpercent-response-time}" at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_imsiapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                       |
      | (.*)      | DBdeleteimsiapnRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBdeleteimsiapnRT{Constant.channelIndex}} {SSH.DBdeleteimsiapnRTTwo{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_ipv4}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                    |
      | (.*)      | DBdeleteipv4RTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBdeleteipv4RT{Constant.channelIndex}} {SSH.DBdeleteipv4RTTwo{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_ipv6}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                    |
      | (.*)      | DBdeleteipv6RTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBdeleteipv6RT{Constant.channelIndex}} {SSH.DBdeleteipv6RTTwo{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_msisdnapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                         |
      | (.*)      | DBdeletemsisdnapnRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBdeletemsisdnapnRT{Constant.channelIndex}} {SSH.DBdeletemsisdnapnRTTwo{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_session}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                       |
      | (.*)      | DBdeletesessionRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBdeletesessionRT{Constant.channelIndex}} {SSH.DBdeletesessionRTTwo{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_imsiapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                      |
      | (.*)      | DBstoreimsiapnRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBstoreimsiapnRT{Constant.channelIndex}} {SSH.DBstoreimsiapnRTTwo{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_ipv4}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                   |
      | (.*)      | DBstoreipv4RTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBstoreipv4RT{Constant.channelIndex}} {SSH.DBstoreipv4RTTwo{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
	  
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_ipv6}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                   |
      | (.*)      | DBstoreipv6RTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBstoreipv6RT{Constant.channelIndex}} {SSH.DBstoreipv6RTTwo{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_msisdnapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                        |
      | (.*)      | DBstoremsisdnapnRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBstoremsisdnapnRT{Constant.channelIndex}} {SSH.DBstoremsisdnapnRTTwo{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |
	  
    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_session}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal} at {Constant.hostname_{Constant.channelIndex}}
    Then I save the SSH response in the following variables:
      | attribute | value                                      |
      | (.*)      | DBstoresessionRTTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.location.utilities-compareresponsetime} {SSH.DBstoresessionRT{Constant.channelIndex}} {SSH.DBstoresessionRTTwo{Constant.channelIndex}} {config.global.thresholds.application.responsetime-db-alloweddeviationpercent}" at {Constant.hostname_{Constant.channelIndex}}
    Then I receive a SSH response and check the presence of following strings:
      | string                            | occurrence |
      | Current Value is within threshold | present    |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                                 |
      | DRTstatus | {config.global.report.result.success} |
    #CICD report end#####################
    
    ##Capture Avg 3xxx errors in Iteration2 duration
    Given I print: ###Capture Avg 3xxx errors in Iteration2 duration ###

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
      | (.*)      | 3xxxErrAvgTwo{Constant.channelIndex} |
    
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.3xxxErrAvgTwo{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                  |
      | (.*)      | Total3xxxErrorsTwo{Constant.channelIndex} |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                              |
      | DEPstatus | {config.global.report.result.fail} |
    #CICD report end#####################

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSTwo{Constant.channelIndex}} {SSH.TotalLDAPTPSTwo{Constant.channelIndex}} {SSH.Total3xxxErrorsTwo{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                    | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                                 |
      | DEPstatus | {config.global.report.result.success} |
    #CICD report end#####################

    ##Capture Avg 4xxx errors in Iteration2 duration
    Given I print: ###Capture Avg 4xxx errors in Iteration2 duration ###

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
      | (.*)      | 4xxxErrAvgTwo{Constant.channelIndex} |
    
    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.4xxxErrAvgTwo{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                  |
      | (.*)      | Total4xxxErrorsTwo{Constant.channelIndex} |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                              |
      | DEPstatus | {config.global.report.result.fail} |
    #CICD report end#####################

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSTwo{Constant.channelIndex}} {SSH.TotalLDAPTPSTwo{Constant.channelIndex}} {SSH.Total4xxxErrorsTwo{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                    | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                                 |
      | DEPstatus | {config.global.report.result.success} |
    #CICD report end#####################

    ##Capture Avg 5xxx errors in Iteration2 duration
    Given I print: ###Capture Avg 5xxx errors in Iteration2 duration ###

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
      | (.*)      | 5xxxErrAvgTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.4xxxErrAvgTwo{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                     |
      | (.*)      | Total5xxxErrorsTwo{Constant.channelIndex} |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                              |
      | DEPstatus | {config.global.report.result.fail} |
    #CICD report end#####################

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSTwo{Constant.channelIndex}} {SSH.TotalLDAPTPSTwo{Constant.channelIndex}} {SSH.Total5xxxErrorsTwo{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
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
      | attribute | value                              |
      | (.*)      | DBErrAvgTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.DBErrAvgTwo{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                |
      | (.*)      | TotalDBErrorsTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSTwo{Constant.channelIndex}} {SSH.TotalLDAPTPSTwo{Constant.channelIndex}} {SSH.TotalDBErrorsTwo{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                    | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    ##Capturing Timeouts in Iteration2 duration
    Given I print: ##Capturing Timeouts in Iteration2 duration ###

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
      | (.*)      | TimeoutCntTwo{Constant.channelIndex} |

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetAbsValue.sh {SSH.TimeoutCntTwo{Constant.channelIndex}} {SSH.SampleDuration}" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                                     |
      | (.*)      | TotaltimeoutCntTwo{Constant.channelIndex} |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                              |
      | DTPstatus | {config.global.report.result.fail} |
    #CICD report end#####################

    When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}GetTotalTPSThreshold.sh {SSH.TotalTPSTwo{Constant.channelIndex}} {SSH.TotalLDAPTPSTwo{Constant.channelIndex}} {SSH.TotaltimeoutCntTwo{Constant.channelIndex}} {SSH.SampleDuration} " at SITEHOST
    Then I receive a SSH response and check the presence of following strings:
      | string      | value                                    | occurrence |
      | {Regex}(.*) | lesserthan({config.global.thresholds.application-error-precentage}) | present    |

    #CICD report start#####################
    Given I define the following constants:
      | name      | value                                 |
      | DTPstatus | {config.global.report.result.success} |
    #CICD report end#####################
    
    Given I print: *****************************************************************************\n 	Bechmarking values of Site{Constant.channelIndex}	\n*****************************************************************************\n | attribute               | value	     		|      \n |  TotalTPSTwo{Constant.channelIndex}            |{SSH.TotalTPSTwo{Constant.channelIndex}}		|      \n |  TotalLDAPTPSTwo{Constant.channelIndex}        |{SSH.TotalLDAPTPSTwo{Constant.channelIndex}}	|      \n |  TotalPLFTPSTwo{Constant.channelIndex}        |{SSH.TotalPLFTPSTwo{Constant.channelIndex}}	|      \n|  TotalNAPTPSTwo{Constant.channelIndex}        |{SSH.TotalNAPTPSTwo{Constant.channelIndex}}	|      \n|  N7CreateTPSTwo{Constant.channelIndex}           |{SSH.N7CreateTPSTwo{Constant.channelIndex}}		|      \n |  N7UpdateTPSTwo{Constant.channelIndex}           |{SSH.N7UpdateTPSTwo{Constant.channelIndex}}		|      \n |  N7DeleteTPSTwo{Constant.channelIndex}           |{SSH.N7DeleteTPSTwo{Constant.channelIndex}}		|      \n |  N28NotifyTPSTwo{Constant.channelIndex}            |{SSH.N28NotifyTPSTwo{Constant.channelIndex}}		|      \n |  RxRARTPSTwo{Constant.channelIndex}            |{SSH.RxRARTPSTwo{Constant.channelIndex}}		|      \n|  RxAARTPSTwo{Constant.channelIndex}            |{SSH.RxAARTPSTwo{Constant.channelIndex}}		|      \n|  RxASRTPSTwo{Constant.channelIndex}            |{SSH.RxASRTPSTwo{Constant.channelIndex}}		|      \n|  RxSTRTPSTwo{Constant.channelIndex}            |{SSH.RxSTRTPSTwo{Constant.channelIndex}}		|      \n|  N7CreateRTTwo{Constant.channelIndex}            |{SSH.N7CreateRTTwo{Constant.channelIndex}}		|      \n|  N7UpdateRTTwo{Constant.channelIndex}            |{SSH.N7UpdateRTTwo{Constant.channelIndex}}		|      \n|  N7DeleteRTTwo{Constant.channelIndex}            |{SSH.N7DeleteRTTwo{Constant.channelIndex}}		|      \n|  N28NotifyRTTwo{Constant.channelIndex}             |{SSH.N28NotifyRTTwo{Constant.channelIndex}}		|      \n|  RxRARRTTwo{Constant.channelIndex}             |{SSH.RxRARRTTwo{Constant.channelIndex}}		|      \n|  RxAARRTTwo{Constant.channelIndex}             |{SSH.RxAARRTTwo{Constant.channelIndex}}		|      \n|  RxASRRTTwo{Constant.channelIndex}             |{SSH.RxASRRTTwo{Constant.channelIndex}}		|      \n|  RxSTRRTTwo{Constant.channelIndex}             |{SSH.RxSTRRTTwo{Constant.channelIndex}}		|      \n|  5xxxErrAvgTwo{Constant.channelIndex}          |{SSH.5xxxErrAvgTwo{Constant.channelIndex}}		|      \n|  Total5xxxErrorsTwo{Constant.channelIndex}     |{SSH.Total5xxxErrorsTwo{Constant.channelIndex}}	|      \n|  3xxxErrAvgTwo{Constant.channelIndex}          |{SSH.3xxxErrAvgTwo{Constant.channelIndex}}		|      \n|  Total3xxxErrorsTwo{Constant.channelIndex}     |{SSH.Total3xxxErrorsTwo{Constant.channelIndex}}	|      \n|  TimeoutCntTwo{Constant.channelIndex}          | {SSH.TimeoutCntTwo{Constant.channelIndex}}		|      \n|  TotaltimeoutCntTwo{Constant.channelIndex}     |{SSH.TotaltimeoutCntTwo{Constant.channelIndex}}	|      \n*****************************************************************************

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
