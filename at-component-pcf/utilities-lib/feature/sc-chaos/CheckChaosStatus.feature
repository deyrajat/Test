####################################################################################################
# Date: <21/11/2019> Version: <Initial version: 19.5.0> Create by <Sandeep Talukdar, santaluk> #
####################################################################################################

@Chaos_Status

Feature: PCF_Chaos_Status

  Scenario: Check the status while chaos is running

    Given I loop {config.scenario.exec-params.iterations} times

         When I execute the SSH command "date '+%s'" at Installer
         Then I save the SSH response in the following variables:
           | attribute | value                |
           | (.*)      | chaos_tps_start_time |

         Then I wait for {config.scenario.exec-params.wait} seconds

         When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep -v Running at K8SMaster
         When I execute the SSH command {config.global.commands.k8s.pod-list-cee} | grep -v Running at K8SMaster

         When I execute the SSH command {config.global.command.opsCenter.chaos-system-status} at CHAOSINSTANCE

         When I execute the SSH command {config.global.command.opsCenter.chaos-system-status} at CHAOSINSTANCE
         Then I receive a SSH response and check the presence of following strings:
            | string                           | occurrence |
            | Is Chaos test running?  yes      | present    |
            | Is Chaos test running?  no       | absent     |

         When I execute the SSH command "date '+%s'" at Installer
         Then I save the SSH response in the following variables:
           | attribute | value               |
           | (.*)      | chaos_tps_stop_time |

         When I execute the SSH command echo '&start={SSH.chaos_tps_start_time}&end={SSH.chaos_tps_stop_time}&step={config.Step_Duration}' at Installer
         Then I save the SSH response in the following variables:
           | attribute | value     |
           | (.*)      | TimeQuery |

         When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Incoming_Messages_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization1} {config.Value.Extrator} at Installer
         Then I save the SSH response in the following variables:
           | attribute | value       |
           | (.*)      | IncomingReq |
         When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Outgoing_Messages_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization1} {config.Value.Extrator} at Installer
         Then I save the SSH response in the following variables:
           | attribute | value       |
           | (.*)      | OutGoingReq |
         When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Diameter_Requests_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization1} {config.Value.Extrator} at Installer
         Then I save the SSH response in the following variables:
           | attribute | value       |
           | (.*)      | DiameterReq |

         When I execute the SSH command echo $(({SSH.IncomingReq}+{SSH.OutGoingReq}+{SSH.DiameterReq})) at Installer
         Then I save the SSH response in the following variables:
           | attribute | value              |
           | (.*)      | TotalTPSChaosCheck |

         #Total TPS check
         When I execute the SSH command "{config.global.remotepush.sitehost-location.utilities}SiteFailoverTpsValidation.sh {config.scenario.thresholds.application.expected-tps} 0 {SSH.TotalTPSChaosCheck} {config.global.thresholds.application.alloweddeviationpercent-tps}" at SITEHOST
         Then I receive a SSH response and check the presence of following strings:
           | string                            | occurrence |
           | Current Value is within threshold | present    |

    And I end loop
