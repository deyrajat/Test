####################################################################################################
# Date: <15/05/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Resiliency @Tzc182632868c @PCF_Resi_Cfg @P3 @CDET_CSCvr44608

Feature: PCF_19_3_0_059_Tzc182632868c_Ldap_Server_Restart

  Scenario: Ldap Server Restart 30 MINs- One Iterations

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
      | Ldap Server Restart - One Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  
    
    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    #CICD Test report start
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationComments.feature
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}ValidationCommentsForSystemKPIs.feature
    #CICD Test report end
    
    Given I define the following constants:
      | name             | value      |
      | ldapServerIndex  | 1          |
      | ldapPortIndex    | 1          |

    ### Start the LDAP process
    Given I loop {config.scenario.ldap.server.count} times 
    
	    Given I configure a SSH instance with following attributes:
	      |  string                   |  value                                  |
	      |  InstanceName             |  LDAPINSTANCE{Constant.ldapServerIndex} |                          
	      |  UserName                 |  {config.LDAPServer.SSH.UserName}       |
	      |  Password                 |  {config.LDAPServer.SSH.Password}       |
	      |  EndpointIpAddress        |  {config.sut.ldap.ipaddress{Constant.ldapServerIndex}.external}                 |
    
	    When I execute the SSH command echo $(( 10 + {Constant.ldapServerIndex} ))  at SITEHOST
	    Then I save the SSH response in the following variables:
	      | attribute | value             |
	      | (.*)      | channelindexvalue |
    
	    When I execute using handler LDAPINSTANCE{Constant.ldapServerIndex} on channel ch{SSH.channelindexvalue} the command {config.scenario.ldap.start.command}
	    
	    Given I delete SSH instance LDAPINSTANCE{Constant.ldapServerIndex}
	    
		  Then I increment Constant.ldapServerIndex by 1

	  And I end loop
	  
    Then I wait for {config.global.constant.onehundred.twenty} seconds

    Given the arming of teardown steps are done
    
    Given I define the following constants:
      | name             | value      |
      | ldapServerIndex  | 1          |
      | ldapPortIndex    | 1          |

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

    Given I loop {config.scenario.ldap.server.count} times 
        
	    ### Get the ldap process number 
	    When I execute the SSH command sshpass -p {config.LDAPServer.SSH.Password} ssh {config.LDAPServer.SSH.UserName}@{config.sut.ldap.ipaddress{Constant.ldapServerIndex}.external} {config.global.scenario.resiliency.ldap-process-command} at SITEHOST
	    Then I save the SSH response in the following variables:
	      | attribute      | value          |
	      | (.*)           | Processnumber  |
	
	    ### Kill Ldap process 
	    When I execute the SSH command sshpass -p {config.LDAPServer.SSH.Password} ssh {config.LDAPServer.SSH.UserName}@{config.sut.ldap.ipaddress{Constant.ldapServerIndex}.external} kill -9 {SSH.Processnumber} at SITEHOST
	    
		  Then I increment Constant.ldapServerIndex by 1

	  And I end loop
	  
    Then I wait for {config.global.constant.onehundred.eighty} seconds
    Then I wait for {config.global.constant.onehundred.fifty} seconds
    
    Given I define the following constants:
      | name             | value      |
      | ldapServerIndex  | 1          |
      | ldapPortIndex    | 1          |	    
    
    Given I loop {config.scenario.ldap.server.count} times
	    
	    Given I define the following constants:
	      | name             | value      |
	      | ldapPortIndex    | 1          |
	
	    ### confirm ldap process is killed
	    Given I loop {config.scenario.ldap.port.array-length} times 
	    
	      When I execute the SSH command sshpass -p {config.LDAPServer.SSH.Password} ssh {config.LDAPServer.SSH.UserName}@{config.sut.ldap.ipaddress{Constant.ldapServerIndex}.external} netstat -antlop | grep :{config.{config.scenario.ldap.port-arrayprefix}{Constant.ldapPortIndex}} at SITEHOST
		    Then I receive a SSH response and check the presence of following strings:
		        | string           | occurrence |
		        | LISTEN           | absent     |
		        | ESTABLISHED      | absent     |
		        
			  Then I increment Constant.ldapPortIndex by 1
	
		  And I end loop
		  
		  Then I increment Constant.ldapServerIndex by 1

	  And I end loop
	  
    Given I define the following constants:
      | name             | value      |
      | ldapServerIndex  | 1          |
      | ldapPortIndex    | 1          |

    ### Start the LDAP process
    Given I loop {config.scenario.ldap.server.count} times 
    
	    Given I configure a SSH instance with following attributes:
	      |  string                   |  value                                  |
	      |  InstanceName             |  LDAPINSTANCE{Constant.ldapServerIndex} |                          
	      |  UserName                 |  {config.LDAPServer.SSH.UserName}       |
	      |  Password                 |  {config.LDAPServer.SSH.Password}       |
	      |  EndpointIpAddress        |  {config.sut.ldap.ipaddress{Constant.ldapServerIndex}.external}                 |
    
	    When I execute the SSH command echo $(( 3 + {Constant.ldapServerIndex} ))  at SITEHOST
	    Then I save the SSH response in the following variables:
	      | attribute | value             |
	      | (.*)      | channelindexvalue |
    
	    When I execute using handler LDAPINSTANCE{Constant.ldapServerIndex} on channel ch{SSH.channelindexvalue} the command {config.scenario.ldap.start.command}
	    
	    Given I delete SSH instance LDAPINSTANCE{Constant.ldapServerIndex}
	    
		  Then I increment Constant.ldapServerIndex by 1

	  And I end loop
	  
    Then I wait for {config.global.constant.onehundred.eighty} seconds
    
    Given I loop {config.scenario.ldap.server.count} times
    
        Then I wait for {config.global.constant.onehundred.eighty} seconds
        
    And I end loop
    
    Given I define the following constants:
      | name             | value      |
      | ldapServerIndex  | 1          |
      | ldapPortIndex    | 1          |
    
    Given I loop {config.scenario.ldap.server.count} times 
    
	    Given I configure a SSH instance with following attributes:
	      |  string                   |  value                                  |
	      |  InstanceName             |  LDAPINSTANCE{Constant.ldapServerIndex} |                          
	      |  UserName                 |  {config.LDAPServer.SSH.UserName}       |
	      |  Password                 |  {config.LDAPServer.SSH.Password}       |
	      |  EndpointIpAddress        |  {config.sut.ldap.ipaddress{Constant.ldapServerIndex}.external}                 |
	    
	    Given I define the following constants:
	      | name             | value      |
	      | ldapPortIndex    | 1          |
	
	    ### confirm ldap process is started
	    Given I loop {config.scenario.ldap.port.array-length} times 
	    
	      When I execute the SSH command netstat -antlop | grep :{config.{config.scenario.ldap.port-arrayprefix}{Constant.ldapPortIndex}} at LDAPINSTANCE{Constant.ldapServerIndex}
		    Then I receive a SSH response and check the presence of following strings:
		        | string           | occurrence |
		        | LISTEN           | present    |
		        | ESTABLISHED      | present    |
		        
			  Then I increment Constant.ldapPortIndex by 1
	
		  And I end loop
		  
		  Given I delete SSH instance LDAPINSTANCE{Constant.ldapServerIndex}
		  
		  Then I increment Constant.ldapServerIndex by 1

	  And I end loop
	
    ####Capture End Time after ldap restart
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
      | name        | value                                 |
      | ACstatus    | {config.global.report.result.success} |
    Then I update report for table {Constant.testtype} with the following details:
      | Ldap Server Restart - One Iterations | Pass |
    #CICD report end#####################
