###############################################################################################
# Date: <14/11/2019> Version: <Initial version: 19.3> Create by <Prosenjit Chatterjee, proschat>
###############################################################################################
@NoisyScenario

Feature: Noisy_Scenario_Capture_Stats_Post_Run

Scenario: Steps to capture variable after starting Noisy Scenario

      ##List the pods in PCF and CEE 
      Given I print: "=============== Pod status iteration start ==============="
      
      When I execute the SSH command "{config.global.commands.k8s.pod-list-pcf}" at K8SMaster
      
      When I execute the SSH command "{config.global.commands.k8s.pod-list-cee}" at K8SMaster
      
      Given I print: "=============== Pod status iteration End   ==============="
       

	   	## Take CNode Stats after running noisy scenario
	    When I execute the SSH command "{config.global.commands.k8s.node-status-notReady}" at K8SMaster
	    Then I save the SSH response in the following variables:
	      | attribute | value              |
	      | (.*)      | nodesnotready  	   |
				    
	    ## Take Name of the PODS which are not running.
	    When I execute the SSH command "{config.global.commands.k8s.not-running-pods}" at K8SMaster
	    Then I save the SSH response in the following variables:
	      | attribute   | value              |
	      | ([\s\S]*)   | podsNotRunning     |
	     
	   	# Check CEE Ops Center Stats. 	
	    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLICeeOPSCenter
	    Then I save the SSH response in the following variables:
	      | attribute                             | value           |
	      | (system status percent-ready\s+\S+)   | depPerReady     |
	    When I execute using handler SITEHOST the SSH command "echo {SSH.depPerReady}"
	    Then I save the SSH response in the following variables:
	      | attribute             | value         |
	      | {Regex}(\d+.\d+)      | depPercentCee |
	      
	   	# Check CEE Ops Center Stats. 	
	    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLIPcfOPSCenter
	    Then I save the SSH response in the following variables:
	      | attribute                             | value           |
	      | (system status percent-ready\s+\S+)   | depPerReady     |
	    When I execute using handler SITEHOST the SSH command "echo {SSH.depPerReady}"
	    Then I save the SSH response in the following variables:
	      | attribute             | value         |
	      | {Regex}(\d+.\d+)      | depPercentPcf |
    
   		# Take Memory usage after running noisy scenario.
	    When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} {config.global.command.system.mem-usage-percentage}" at K8SMaster
	    Then I save the SSH response in the following variables:
	      | attribute      | value          |
	      | (.*)           | MemUsageAfter  |
	      
	    # Take CPU usage after running noisy scenario.  
        When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} {config.global.command.system.cpu-usage-percentage}" at K8SMaster
	    Then I save the SSH response in the following variables:
	      | attribute      | value          |
	      | (.*)           | CpuUsageAfter  |
	      
	    ## Take Disk usage after running noisy scenario. 
	    When I execute the SSH command "ssh -o StrictHostKeyChecking=no -i {config.sut.k8smaster.home.directory}{SSH.smiKeyName} {SSH.NodeName} {config.global.command.system.disk-usage-percentage}" at K8SMaster
	    Then I save the SSH response in the following variables:
	      | attribute      | value          |
	      | (.*)           | DskUsageAfter  |
