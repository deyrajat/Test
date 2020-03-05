###############################################################################################
# Date: <15/12/2017> Version: <Initial version: 18.0> $1Create by <Soumil Chatterjee, soumicha>
# Date: <27/06/2018> Version: <Enhancement for GR and HA Consolidation> Updated by <bhchauha>
###############################################################################################
##Capturing benchmark data before event start which will later be used for validations
@RTCaptureAndCheck

Feature: RTCaptureAndCheck

  Scenario: Validate response time for diameter messages is within expected threshold

		
		Given I define the following constants:
	      | name               | value |
	      | channelIndex       | 1     |

	    ##Capturing avg Response Time for 1st benchmark duration
	    Given I print: ### Capturing avg Response Time for 1st benchmark duration ###
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_CCRI_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                           |
	      | (.*)      | N7CreateRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                             | value                                        |
	      | {SSH.N7CreateRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.N7CreateRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_CCRU_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                           |
	      | (.*)      | N7UpdateRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                             | value                                        |
	      | {SSH.N7UpdateRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.N7UpdateRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_CCRT_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                           |
	      | (.*)      | N7DeleteRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                             | value                                        |
	      | {SSH.N7DeleteRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.N7DeleteRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Gx_RAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                          |
	      | (.*)      | N28NotifyRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                            | value                                       |
	      | {SSH.N28NotifyRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.N28NotifyRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_RAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                          |
	      | (.*)      | RxRARRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                            | value                                       |
	      | {SSH.RxRARRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.RxRARRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_AAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                          |
	      | (.*)      | RxAARRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                            | value                                       |
	      | {SSH.RxAARRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.RxAARRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_ASR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                          |
	      | (.*)      | RxASRRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                            | value                                       |
	      | {SSH.RxASRRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.RxASRRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Rx_STR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                          |
	      | (.*)      | RxSTRRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                            | value                                       |
	      | {SSH.RxSTRRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.RxSTRRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Sy_SNR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                          |
	      | (.*)      | SySNRRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                            | value                                       |
	      | {SSH.SySNRRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.SySNRRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Sy_SLR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                          |
	      | (.*)      | SySLRRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                            | value                                       |
	      | {SSH.SySLRRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.SySLRRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Sy_STR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                          |
	      | (.*)      | SySTRRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                            | value                                       |
	      | {SSH.SySTRRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.SySTRRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Sh_UDR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                          |
	      | (.*)      | ShUDRRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                            | value                                       |
	      | {SSH.ShUDRRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.ShUDRRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Sd_RAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                          |
	      | (.*)      | SdRARRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                            | value                                       |
	      | {SSH.SdRARRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.SdRARRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Sd_TSR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                          |
	      | (.*)      | SdTSRRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                            | value                                       |
	      | {SSH.SdTSRRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.SdTSRRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Sd_CCRU_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                           |
	      | (.*)      | SdCCRURT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                             | value                                        |
	      | {SSH.SdCCRURT{Constant.channelIndex}} | LESSTHANOREQUAL({config.SdCCRURT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Sd_CCRT_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                           |
	      | (.*)      | SdCCRTRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                             | value                                        |
	      | {SSH.SdCCRTRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.SdCCRTRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Syp_AAR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                           |
	      | (.*)      | SypAARRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                             | value                                        |
	      | {SSH.SypAARRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.SypAARRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.Syp_STR_AvgResTime_Query}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                           |
	      | (.*)      | SypSTRRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                             | value                                        |
	      | {SSH.SypSTRRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.SypSTRRT_Threshold}) |
	
	    ##Capturing DB query average response time
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                            |
	      | (.*)      | MongoDBRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                              | value                                         |
	      | {SSH.MongoDBRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.MongoDBRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_imsiapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                    |
	      | (.*)      | DBdeleteimsiapnRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                                      | value                                                 |
	      | {SSH.DBdeleteimsiapnRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.DBdeleteimsiapnRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_ipv4}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                 |
	      | (.*)      | DBdeleteipv4RT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                                   | value                                              |
	      | {SSH.DBdeleteipv4RT{Constant.channelIndex}} | LESSTHANOREQUAL({config.DBdeleteipv4RT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_ipv6}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                 |
	      | (.*)      | DBdeleteipv6RT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                                   | value                                              |
	      | {SSH.DBdeleteipv6RT{Constant.channelIndex}} | LESSTHANOREQUAL({config.DBdeleteipv6RT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_msisdnapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                      |
	      | (.*)      | DBdeletemsisdnapnRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                                        | value                                                   |
	      | {SSH.DBdeletemsisdnapnRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.DBdeletemsisdnapnRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_delete_session}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                    |
	      | (.*)      | DBdeletesessionRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                                      | value                                                 |
	      | {SSH.DBdeletesessionRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.DBdeletesessionRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_imsiapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                   |
	      | (.*)      | DBstoreimsiapnRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                                     | value                                                |
	      | {SSH.DBstoreimsiapnRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.DBstoreimsiapnRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_ipv4}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                |
	      | (.*)      | DBstoreipv4RT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                                  | value                                             |
	      | {SSH.DBstoreipv4RT{Constant.channelIndex}} | LESSTHANOREQUAL({config.DBstoreipv4RT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_ipv6}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                |
	      | (.*)      | DBstoreipv6RT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                                  | value                                             |
	      | {SSH.DBstoreipv6RT{Constant.channelIndex}} | LESSTHANOREQUAL({config.DBstoreipv6RT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_msisdnapn}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                     |
	      | (.*)      | DBstoremsisdnapnRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                                       | value                                                  |
	      | {SSH.DBstoremsisdnapnRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.DBstoremsisdnapnRT_Threshold}) |
	
	    When I execute using handler {Constant.hostname_{Constant.channelIndex}} the SSH shell command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint{Constant.channelIndex}.EndpointAddress}{config.DB_Response_Time_store_session}{SSH.TimeQuery}" {config.Grafana.Authorization{Constant.channelIndex}} {config.Value.ExtratorDecimal}
	    Then I save the SSH response in the following variables:
	      | attribute | value                                   |
	      | (.*)      | DBstoresessionRT{Constant.channelIndex} |
	    Given I validate the following attributes:
	      | attribute                                     | value                                                |
	      | {SSH.DBstoresessionRT{Constant.channelIndex}} | LESSTHANOREQUAL({config.DBstoresessionRT_Threshold}) |
