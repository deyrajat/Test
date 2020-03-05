##########################################################################################
# Date: <01/02/2016> Version: <Initial version: 9.0> $1Create by <Suvajit Nandy, suvnandy>
##########################################################################################
##Custom Teardown steps written in this file

@RESILIENCY

Feature: Custom_Teardown

  Scenario: Generic Teardown steps for Resiliency
  
  	##### Get the make break subscriber prefix to delete.
    When I execute the SSH command /root/{config.global.command.Make-Break.Session-Remove} at  SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value                        |
      | (.*)      | MakeBreakSessionDeletePrefix |
  
  	### validation Apart from Grafana
  	Given I execute the steps from {config.global.workspace.library.location-features-validations-platform}Validations_PCF.feature  
  	
    Given I expect the next test step to execute if ({config.scenario.start.traffic} > 0)
    
      ##### Check and kill the Call flow if the test case has failed
	    Given I print:========== Show the ports that are started ============
	    When I execute the SSH command netstat -antlop | grep {config.tools.toolagent.ipaddress1} at ToolAgentHost
    
        Given I expect the next test step to execute if '("{SSH.TestStatus}" == "Failed")'

          Given I execute the SSH command "pkill -f ToolAgent" at ToolAgentHost
          Given I execute the SSH command "pkill -f lattice" at ToolAgentHost
          Given I execute the SSH command "pkill -f cli" at ToolAgentHost

				  #When I execute the SSH command {config.global.command.opsCenter.delete-makebreak-session} at CLIPcfOPSCenter
				  When I execute the SSH command {config.global.command.opsCenter.delete-makebreak-session-cmd}{SSH.MakeBreakSessionDeletePrefix} {config.global.command.opsCenter.delete-makebreak-session-filter} at CLIPcfOPSCenter
	  
        Given I end the if
    
    Given I end the if

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | log_end_epoch_time |

    When I execute the SSH command cat {config.sut.k8smaster.home.directory}/log_start_time.txt at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value                |
      | (.*)      | log_start_epoch_time |

    ##Calculate exact duration of logs in seconds
    When I execute the SSH command "{config.global.remotepush.location.utilities-geteventduration} {SSH.log_start_epoch_time} {SSH.log_end_epoch_time} " at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute | value      |
      | (.*)      | logTimeSec |

    When I execute the SSH command rm -rf {config.sut.k8smaster.home.directory}/log_start_time.txt at K8SMaster

    ## Check status of the deployment.
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

    Then I wait for {config.global.constant.ten} seconds

    Given I print:====================== PCF Engine Status  =========================  

    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep pcf-engine-{config.sut.k8s.namespace.pcf}-pcf-engine-app at K8SMaster

    Given I print:====================== PCF Engine Status  =========================  

    #### pcf and cnee ops logs
    When I execute using handler K8SMaster the SSH shell command rm -rf {config.sut.k8smaster.home.directory}/ops_logs*

    When I execute using handler K8SMaster the SSH shell command mkdir -m 755 -p {config.sut.k8smaster.home.directory}/ops_logs_{CurrentFeatureName}_{CurrentDateAndTime}

    When I execute using handler K8SMaster the SSH shell command ls | grep --color=never ops_logs
    Then I save the SSH response in the following variables:
      | attribute | value           |
      | (.*)      | OpsLogDirName   |

    ### Get ceeOpsCneter Name 
    When I execute the SSH command {config.global.commands.k8s.pod-list-cee} | grep --color=never ops-center-{config.sut.k8s.namespace.cee} | awk '{print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value         |
      | (.*)      | cneeOpsCenter |

    When I execute using handler K8SMaster the SSH shell command rm -rf {config.sut.k8smaster.home.directory}/ops-center-cnee-ops-center_log.txt

    When I execute using handler K8SMaster on shell sh3 the command kubectl logs -n {config.sut.k8s.namespace.cee} --since={SSH.logTimeSec}s -f {SSH.cneeOpsCenter} -c confd-api-bridge > {config.sut.k8smaster.home.directory}/ops-center-cnee-ops-center_log.txt

    Then I wait for {config.global.constant.ten} seconds

    When I execute using handler K8SMaster the SSH shell command mv {config.sut.k8smaster.home.directory}/ops-center-cnee-ops-center_log.txt {config.sut.k8smaster.home.directory}/{SSH.OpsLogDirName}/

    When I execute using handler K8SMaster the SSH shell command tar -zcvf {config.sut.k8smaster.home.directory}/{SSH.OpsLogDirName}.tar.gz {config.sut.k8smaster.home.directory}/{SSH.OpsLogDirName}/

    Given the SFTP pull of file {config.sut.k8smaster.home.directory}/{SSH.OpsLogDirName}.tar.gz at K8SMaster to "log/" is successful

    When I execute using handler K8SMaster the SSH shell command rm -rf {config.sut.k8smaster.home.directory}/ops_logs*

    #### Collect the ToolAgent Logs
    Given I expect the next test step to execute if ({config.scenario.start.traffic} > 0)  	    

	    When I execute using handler ToolAgentHost the SSH shell command mkdir -m 755 -p /tmp/taas/toolAgent_Logs

	    When I execute using handler ToolAgentHost the SSH shell command "cd /tmp/taas/ ; mv -f 2* /tmp/taas/toolAgent_Logs"

	    When I execute using handler ToolAgentHost the SSH shell command "cd /tmp/taas/ ; tar -zcvf toolAgent_logs_{CurrentFeatureName}_{CurrentDateAndTime}.tar.gz toolAgent_Logs"

	    When I execute using handler ToolAgentHost the SSH shell command "cd /tmp/taas/ ; ls --color=never *.tar.gz "
	    Then I save the SSH response in the following variables:
	      | attribute | value              |
	      | (.*)      | tooAgentFileName   |

	    Given the SFTP pull of file /tmp/taas/{SSH.tooAgentFileName} at ToolAgentHost to "log/" is successful

    Given I end the if

    ## TET LOG Push
    When I execute the SSH command "cat {config.global.remotepush.location.utilities-tet-upload-tetpull-path}tet_output_folder_name.txt" at LDAPServer
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | pcfStatsFileName_site1 |

    When I execute the SSH command "ps -ef | grep PCF_tet_pull_stats | wc -l " at LDAPServer
    Then I save the SSH response in the following variables:
      | attribute | value          |
      | (.*)      | pullProcessNum |

    Given I expect the next test step to execute if ({SSH.pullProcessNum} > 1)
    Given I print:"## Stopping TET instance ##"
    When I execute using handler LDAPServer the parameterized command /usr/bin/timeout 30 read -n 2 | yes 'y' | {config.global.remotepush.location.utilities-tet-upload-tetpull-path}PCF_tet_pull_stats.sh with following arguments:
      | attribute | value                                                      |
      | c         | {config.global.remotepush.location.utilities-tet-upload-tetpull-path}pcf_tet_pull_config_site1.txt      |
      | k         |                                                            |
      | o         | {config.global.remotepush.location.utilities-tet-tetpull-output}{SSH.pcfStatsFileName_site1}/      |
      | d         | {config.Core.SUTEndpointIpAddress.QPS1}                    |
      | x         | {config.sut.k8smaster.default.user}                                          |
      | p         | /root/{SSH.smiKeyName}                                                       |
      | m         | {config.sut.k8smaster.home.directory}{SSH.smiKeyName}                        |
    Given I end the if

    #Given I execute the SSH command "sed  -i '/^{SSH.pcfStatsFileName_site1}$/d' /root/tet/tet_output_folder_name.txt" at LDAPServer
    Given I execute the SSH command "rm -f  {config.global.remotepush.location.utilities-tet-upload-tetpull-path}tet_output_folder_name.txt" at LDAPServer
    Given I execute the SSH command "tar -czvf {config.global.remotepush.location.utilities-tet-tetpull-output}{SSH.pcfStatsFileName_site1}.tar.gz {config.global.remotepush.location.utilities-tet-tetpull-output}{SSH.pcfStatsFileName_site1}/" at LDAPServer
    Given the SFTP pull of file "{config.global.remotepush.location.utilities-tet-tetpull-output}{SSH.pcfStatsFileName_site1}.tar.gz" at LDAPServer to "log/" is successful
    Given I execute the SSH command "{config.global.commands.tet.replaceconfigfile}" at LDAPServer
    Given I execute the SSH command "rm -rf {config.global.remotepush.location.utilities-tet-tetpull-output}{SSH.pcfStatsFileName_site1}/" at LDAPServer
    Given I execute the SSH command "rm -rf {config.global.remotepush.location.utilities-tet-tetpull-output}{SSH.pcfStatsFileName_site1}.tar.gz" at LDAPServer

    ## Check status of the PCF deployment.
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
      
    ## Check status of the CEE deployment.
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

    Given I define the following constants:
      | name                | value        |
      | SetupReady          | yes          |

    Given I expect the next test step to execute if '("{Constant.SetupReady}" == "yes")'
	    
	    ### Collect the TAC logs  
	    When I execute the SSH command date -d @{SSH.log_start_epoch_time} +"%Y-%m-%d_%H:%M:%S" at SITEHOST
	    Then I save the SSH response in the following variables:
	      | attribute | value              |
	      | (.*)      | log_start_tac_time |
	      
	    When I execute the SSH command date -d @{SSH.log_end_epoch_time} +"%Y-%m-%d_%H:%M:%S" at SITEHOST
	    Then I save the SSH response in the following variables:
	      | attribute | value            |
	      | (.*)      | log_end_tac_time |   	      
	       
	    ### Start logs Generation
	    #When I execute the SSH command tac-debug-pkg create from {SSH.log_start_tac_time} to {SSH.log_end_tac_time} logs-filter { namespace {config.sut.k8s.namespace.pcf},{config.sut.k8s.namespace.cee} } at CLICeeOPSCenter
	    When I execute the SSH command tac-debug-pkg create from {SSH.log_start_tac_time} to {SSH.log_end_tac_time} at CLICeeOPSCenter
	    Then I save the SSH response in the following variables:
	      | attribute                    | value        |
	      | (tac-debug pkg ID :\s+\S+)   | tacpkgID     |
	      
	    When I execute using handler SITEHOST the SSH command echo {SSH.tacpkgID}
	    Then I save the SSH response in the following variables:
	      | attribute      | value        |
	      | {Regex}(\d+)   | tacpkgID     |
	      
	    #Calculate the number of Iteration
	    When I execute using handler SITEHOST the SSH command echo $(( ( {SSH.log_end_epoch_time} - {SSH.log_start_epoch_time} ) / {config.global.constant.twohundred.forty} ))
	    Then I save the SSH response in the following variables:
	      | attribute | value         |
	      | (.*)      | numIterations |
	      
	    Given I loop {SSH.numIterations} times  
	    
	      Then I wait for {config.global.constant.thirty} seconds
	       
	      When I execute the SSH command tac-debug-pkg status at CLICeeOPSCenter
		    Then I save the SSH response in the following variables:
		      | attribute      | value     |
		      | ([\s\S]*)      | tacStatus |
		      
		    When I execute using handler SITEHOST the SSH command echo '{SSH.tacStatus}' | grep "No active tac debug session" | wc -l
		    Then I save the SSH response in the following variables:
		      | attribute | value         |
		      | (.*)      | tacIsComplete |	    
		      
		    Given I break loop if {SSH.tacIsComplete} >= 1
		    
		  And I end loop 
		  
	    When I execute using handler SITEHOST the SSH command echo tac_output_{CurrentFeatureName}_{CurrentDateAndTime}
	    Then I save the SSH response in the following variables:
	      | attribute   | value      |
	      | (.*)        | tacDirName |	  
		  
			## Download the tac file
			Given I execute as WGET1 the command {config.global.command.TAC.File-Download}{SSH.tacpkgID}/ -P {SSH.tacDirName}
			
			Given I execute as TAR1 the command tar -zcvf {SSH.tacDirName}.tar.gz {SSH.tacDirName}
			
			Then I copy file {SSH.tacDirName}.tar.gz to file log/{SSH.tacDirName}.tar.gz
		  
			#### Delete the file
			Given I execute as RM1 the command rm -rf {SSH.tacDirName} {SSH.tacDirName}.tar.gz
			
			When I execute the SSH command tac-debug-pkg delete tac-id {SSH.tacpkgID} at CLICeeOPSCenter	 
  
    Given I end the if