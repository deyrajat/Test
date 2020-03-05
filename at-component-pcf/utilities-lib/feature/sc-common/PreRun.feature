###############################################################################################
# Date: <23/04/2019> Version: <Initial version: 19.3> Create by <Sandeep Talukdar, santaluk>
###############################################################################################
##All pre-requisite steps before call model start are mentioned here
@PreRun

Feature: Resiliency_PreRun

Scenario: Steps to prepare SUT before executing test scenario

    Given I print:====================== PCF Build info Start =========================

    Given I execute the SSH command helm list --namespace {config.sut.k8s.namespace.pcf} at K8SMaster

    Given I execute the SSH command helm list --namespace {config.sut.k8s.namespace.cee} at K8SMaster

    Given I print:====================== PCF Build info End   ========================= 

    Given I execute the SSH command "killall PCF_tet_pull_stats.sh" at LDAPServer
    Given I execute the SSH command "killall PCF_stats" at LDAPServer

    Given I define the following constants:
      | name                | value        |
      | SetupReady          | no           |
      | VMShutdown          | no           |
      
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |   

    ## Check status of the pcf deployment.
    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLIPcfOPSCenter
    Then I receive a SSH response and check the presence of following strings:
        | string                         | occurrence  |
        | system status deployed true    | present     |
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

    ## Check status of the cee deployment.
    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLICeeOPSCenter
    Then I receive a SSH response and check the presence of following strings:
        | string                         | occurrence  |
        | system status deployed true    | present     |
    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLICeeOPSCenter
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
      
  	##### Get the make break subscriber prefix to delete.
    When I execute the SSH command /root/{config.global.command.Make-Break.Session-Remove} at  SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                        |
      | (.*)      | MakeBreakSessionDeletePrefix |
      
    ### Check the status of the other namespaces
    When I execute the SSH command {config.sut.k8smaster.home.directory}/GetSystemDeploymentStatus.sh at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string                       | occurrence |
      | Setup is 100% deployed       | present    |
      | Setup is not 100% deployed   | absent     |      

    Given I define the following constants:
      | name            | value        |
      | SetupReady      | yes          |

    Given I expect the next test step to execute if ({config.scenario.start.traffic} > 0)

      Given I execute the SSH command "rm -rf ToolAgent.*" at ToolAgentHost
      Given I execute the SSH command "rm -rf core.*" at ToolAgentHost  

      ### Obtain the currently executing TPS values
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

	    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Incoming_Messages_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization1} {config.Value.Extrator} at SITEHOST
	    Then I save the SSH response in the following variables:
	      | attribute | value       |
	      | (.*)      | IncomingReq |
	    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Outgoing_Messages_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization1} {config.Value.Extrator} at SITEHOST
	    Then I save the SSH response in the following variables:
	      | attribute | value       |
	      | (.*)      | OutGoingReq |
	    When I execute the SSH command {config.global.commands.curl.options} "{config.GrafanaRestEndPoint1.EndpointAddress}{config.Diameter_Requests_TPS_Query}{SSH.TimeQuery}" {config.Grafana.Authorization1} {config.Value.Extrator} at SITEHOST
	    Then I save the SSH response in the following variables:
	      | attribute | value       |
	      | (.*)      | DiameterReq |

	    When I execute the SSH command echo $(({SSH.IncomingReq}+{SSH.OutGoingReq}+{SSH.DiameterReq})) at SITEHOST
	    Then I save the SSH response in the following variables:
	      | attribute | value              |
	      | (.*)      | TotalTPSStartCheck |

      ### Restart the call flow if the expected TPS is not achived
	    Given I expect the next test step to execute if ({SSH.TotalTPSStartCheck} < {config.scenario.thresholds.application.expected-tps})

			  ## Killing the Traffic so that the ToolAgent instances are re-created
			  Given I execute the SSH command "pkill -f ToolAgent" at ToolAgentHost
			  Given I execute the SSH command "pkill -f lattice" at ToolAgentHost
			  Given I execute the SSH command "pkill -f cli" at ToolAgentHost
			
			  Given I execute the SSH command "rm -rf ToolAgent.*" at ToolAgentHost
			  Given I execute the SSH command "rm -rf core.*" at ToolAgentHost  
			  When I execute the SSH command "rm -rf /tmp/taas/*" at ToolAgentHost
			  
			  ### Get the status of the process that were killed
			  Given I execute the SSH command ps -ef | grep ToolAgent | grep -v grep  at ToolAgentHost
			  
			  Given I execute the SSH command ps -ef | grep lattice | grep -v grep  at ToolAgentHost
			  
			  Given I execute the SSH command ps -ef | grep cli | grep -v grep  at ToolAgentHost
			  
		      		  	
			  #When I execute the SSH command {config.global.command.opsCenter.delete-makebreak-session} at CLIPcfOPSCenter
			  When I execute the SSH command {config.global.command.opsCenter.delete-makebreak-session-cmd}{SSH.MakeBreakSessionDeletePrefix} {config.global.command.opsCenter.delete-makebreak-session-filter} at CLIPcfOPSCenter

		    #External SetupTest File
		    Given I execute the steps from {config.global.workspace.library.location-features-calipers}CallModel_SetupTest.feature
			
		    #call Start
		    Given I execute the steps from {config.global.workspace.library.location-features-calipers}CallModel_Execution.feature

	    Given I end the if

    Given I end the if

    ### Print the status of the PCF pods
    When I execute using handler K8SMaster the SSH shell command {config.global.commands.k8s.pod-list-pcf}  | grep Evicted | awk '{print $1}' | xargs kubectl delete pod -n {config.sut.k8s.namespace.pcf}

    ### Print the status of the PCF pods
    When I execute using handler K8SMaster the SSH shell command kubectl get pods -n pats | grep Evicted | awk '{print $1}' | xargs kubectl delete pod -n pats

    ### Check the load average for the PCF nodes
    When I execute the SSH command {config.sut.k8smaster.home.directory}/checkMinionCPUAverage.sh {config.sut.k8smaster.home.directory}/{SSH.smiKeyName} at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string               | occurrence |
      | Load Average is more | absent     |
      | Load Average is less | present    |

    When I execute using handler K8SMaster the SSH shell command {config.global.commands.k8s.pod-list-pcf} | grep --color=never pcf-engine-{config.sut.k8s.namespace.pcf}-pcf-engine-app   

    #Clean up the bulk stats 
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.cee} | grep --color=never bulk | grep Running | awk 'NR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value           |
      | (.*)      | bulkStatPodName |

    Then I execute the SSH command kubectl delete pod {SSH.bulkStatPodName} -n {config.sut.k8s.namespace.pcf} | grep bulk at K8SMaster

    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.cee} | grep --color=never bulk | grep Running | awk 'NR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value           |
      | (.*)      | bulkStatPodName |

    Given I define the following constants:
      | name                 | value        |
      | channelIndex         | 1            |

    ##Blade detail configuration
    Given I print:"## Configuring Blade details by populating information from test.setup ##"
    Given I loop {config.sut.blades.count} times
    When I execute using handler SITEHOST the SSH shell command echo 'BLADE0{Constant.channelIndex}={config.{config.sut.blades.ipprefix}{Constant.channelIndex}}' >> /root/test.setup
    Then I increment Constant.channelIndex by 1
    And I end loop
 
    #Capturing call execution start time
    When I execute the SSH command "date +%d-%m-%Y-%H-%M" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                |
      | (.*)      | execution_start_time |

    When I execute the SSH command echo "PCF_stats_{CurrentFeatureName}_{CurrentDateAndTime}" at LDAPServer
    Then I save the SSH response in the following variables:
      | attribute | value                  |
      | (.*)      | pcfStatsFileName_site1 |

  	### For TEt
    When I execute the SSH command echo {SSH.pcfStatsFileName_site1} >> {config.global.remotepush.location.utilities-tet-upload-tetpull-path}tet_output_folder_name.txt at LDAPServer

    #tet tool start capturing
    Given I print:"## Starting TET tool capture ##"
    When I execute using handler LDAPServer on channel ch2 the parameterized command {config.global.remotepush.location.utilities-tet-upload-tetpull-path}PCF_tet_pull_stats.sh with following arguments:
      | attribute | value                                                                        |
      | c         | {config.global.remotepush.location.utilities-tet-upload-tetpull-path}pcf_tet_pull_config_site1.txt                        |
      | o         | {config.global.remotepush.location.utilities-tet-tetpull-output}{SSH.pcfStatsFileName_site1}/                        |
      | d         | {config.Core.SUTEndpointIpAddress.QPS1}                                      |
      | s         | 1,2,3,4,5                                                                    |
      | x         | {config.sut.k8smaster.default.user}                                          |
      | p         | /root/{SSH.smiKeyName}                                                       |
      | m         | {config.sut.k8smaster.home.directory}{SSH.smiKeyName}                        |

    Then I wait for {config.global.constant.twenty} seconds

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                |
      | (.*)      | log_start_epoch_time |

    ### Obtain the log start timer
    When I execute the SSH command echo {SSH.log_start_epoch_time} > {config.sut.k8smaster.home.directory}/log_start_time.txt at K8SMaster

    When I execute the SSH command chmod 755 {config.sut.k8smaster.home.directory}/log_start_time.txt at K8SMaster
