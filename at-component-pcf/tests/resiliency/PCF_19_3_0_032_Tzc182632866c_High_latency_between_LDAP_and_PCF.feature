####################################################################################################
# Date: <29/05/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Resiliency @Tzc182632866c @PCF_Resi_Engine @P2 @PcfResP2Set2 

Feature: PCF_19_3_0_032_Tzc182632866c_High_latency_between_LDAP_and_PCF


  Scenario: High network latency between LDAP and PCF 30 MINs- Two Iterations

		Given I define the following constants:
			| name         | value |
			| Index 			 | 1     |

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
      | High network latency between LDAP and PCF - Two Iterations | Fail |
    #CICD Test report end
    
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown
    
    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    #CICD Test report end

    Given the arming of teardown steps are done

    #External PreRun File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}PreRun.feature

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |
    
	Then I wait for {config.scenario.exec-params.small-benchmark-interval} seconds
		
	When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
	      | attribute | value             |
	      | (.*)      | grafana_stop_time |

    #Get Benchmark values
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Benchmark.feature
    
 	##GET number of interfaces from LDAP Server.  
    When I execute the SSH command lshw -class network | grep -A 1 "bus info" | grep name | awk -F': ' '{print $2}' | wc -l at LDAPServer
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | IntfCnt  |
      
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
      
	## Add netem rule in each interface of LDAP server
  	Given I loop {SSH.IntfCnt} times
  	  
    	When I execute the SSH command tc qdisc add dev $(lshw -class network | grep -A 1 "bus info" | grep name | awk -F': ' 'NR=={Constant.Index} {print $2}') root netem delay {config.Network.Latency}ms at LDAPServer
    	Then I increment Constant.Index by 1
    	
    Given I end loop 

	Then I wait for {config.global.constant.twohundred.forty} seconds
	Then I wait for {config.global.constant.twohundred.forty} seconds		
		
	When I execute the SSH command tc qdisc show at LDAPServer
		
	Given I define the following constants:
		| name         | value |
		| Index 	   | 1     |
		
    ## Remove netem rules from interface.
    Given I loop {SSH.IntfCnt} times  
    	When I execute the SSH command tc qdisc del dev $(lshw -class network | grep -A 1 "bus info" | grep name | awk -F': ' 'NR=={Constant.Index} {print $2}') root netem at LDAPServer
    	Then I increment Constant.Index by 1
    Given I end loop      
   
    When I execute the SSH command tc qdisc show at LDAPServer
    
    ####Capture End Time
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

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |
    
	Then I wait for {config.scenario.exec-params.small-benchmark-interval} seconds
	
	When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value             |
      | (.*)      | grafana_stop_time |

    #Iteration1 Steps
    Given I execute the steps from {config.global.workspace.library.location-features-validations-grafana}Iteration1_Steps.feature

    #CICD report start#####################
    Given I define the following constants:
      | name        | value                                    |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | High network latency between LDAP and PCF - Two Iterations | Pass |
    #CICD report end#####################

