###############################################################################################
# Date: <14/11/2019> Version: <Initial version: 19.3> Create by <Prosenjit Chatterjee, proschat>
###############################################################################################
@NoisyScenario

Feature: Noisy_Scenario_Start_And_Capture

Scenario: Steps to capture variable before starting Noisy Scenario and start
    
   	## Take Memory Usage before test.
   	When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} {config.global.command.system.mem-usage-percentage}" at K8SMaster
    Then I save the SSH response in the following variables:
	      | attribute      | value          |
	      | (.*)           | MemUsageBefore |
	  ## Take CPU Usage before test.    
   	When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} {config.global.command.system.cpu-usage-percentage}" at K8SMaster
    Then I save the SSH response in the following variables:
	      | attribute      | value          |
	      | (.*)           | CpuUsageBefore |
	  ## Take Disk Usage before test.    
   	When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} {config.global.command.system.disk-usage-percentage}" at K8SMaster
    Then I save the SSH response in the following variables:
	      | attribute      | value          |
	      | (.*)           | DskUsageBefore |
	      
	  When I execute the SSH command "date +%s" at K8SMaster
    Then I save the SSH response in the following variables:
	      | attribute      | value          |
	      | (.*)           | epochDate      |
   	
   	## Run Noisy Scenario 
   	When I execute using handler NoisyInstance on shell sh{SSH.epochDate} the command nohup {Constant.noisy_run_command}
   	
   	#Waiting for {config.scenario.exec-params.wait-before-validation} mins
   	When I execute the SSH command "echo {config.scenario.exec-params.wait-before-validation} {config.global.constant.sixty} | awk '{print  $1/$2}'" at K8SMaster	
		Then I save the SSH response in the following variables:
	      | attribute      | value          |
	      | (.*)           | loopCnt		    |
		Given I define the following constants:
		  | name   | value                    |
		  | index  | 1                        |
    Given I print: "****************Waiting for {config.scenario.exec-params.wait-before-validation} minutes before performing system checks*******************"
    Given I loop {SSH.loopCnt} times
    		Given I print: "Running iteration {Constant.index}"
    		
		    ## Print node status.
		    When I execute the SSH command "{config.global.commands.k8s.node-status-notReady}" at K8SMaster
		    Then I save the SSH response in the following variables:
		      | attribute | value              |
		      | (.*)      | nodestatus    	   |
    		
		    ## Take Name of the PODS which are not running.
		    When I execute the SSH command "{config.global.commands.k8s.not-running-pods}" at K8SMaster
		    Then I save the SSH response in the following variables:
		      | attribute   | value              |
		      | ([\s\S]*)   | podsNotRunning 	 |
		      
		   # Check If CEE Ops Center Stats. 	
		    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLICeeOPSCenter
		    Then I save the SSH response in the following variables:
		      | attribute                             | value           |
		      | (system status percent-ready\s+\S+)   | depPerReady     |
		    When I execute using handler SITEHOST the SSH command "echo {SSH.depPerReady}"
		    Then I save the SSH response in the following variables:
		      | attribute             | value      |
		      | {Regex}(\d+.\d+)      | depPercent |
		      
		   # Check If PCF Ops Center Stats. 	
		    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLIPcfOPSCenter
		    Then I save the SSH response in the following variables:
		      | attribute                             | value           |
		      | (system status percent-ready\s+\S+)   | depPerReady     |
		    When I execute using handler SITEHOST the SSH command "echo {SSH.depPerReady}"
		    Then I save the SSH response in the following variables:
		      | attribute             | value      |
		      | {Regex}(\d+.\d+)      | depPercent |
		      
	  		### Print Memory Usage
	  		When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} {config.global.command.system.mem-usage-percentage}" at K8SMaster
		    Then I save the SSH response in the following variables:
		      | attribute      | value          |
		      | (.*)           | MemUsage       |	      
		    ## Print CPU Usage.
		    When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} {config.global.command.system.cpu-usage-percentage}" at K8SMaster
		    Then I save the SSH response in the following variables:
		      | attribute      | value          |
		      | (.*)           | CpuUsage			  |
		    ## Print DISK Usage.
		    When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} {config.global.command.system.disk-usage-percentage}" at K8SMaster
		    Then I save the SSH response in the following variables:
		      | attribute      | value          |
		      | (.*)           | DskUsage       |
		      

			     
        Given I wait for {config.global.constant.sixty} seconds
        Given I increment Constant.index by 1
    And  I end loop
