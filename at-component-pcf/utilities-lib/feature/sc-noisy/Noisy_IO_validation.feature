###############################################################################################
# Date: <14/11/2019> Version: <Initial version: 19.3> Create by <Prosenjit Chatterjee, proschat>
###############################################################################################
@NoisyScenario

Feature: Noisy_IO_validation

Scenario: Steps to Validate Noisy IO Scenario

	    ## Verify if all node status are ready.
	    Given I print: "********Verify if all node status are ready.*********"
      Given I validate the following attributes:
	     	|   attribute                 | value       |
    	 	|  {SSH.nodesnotready}	      | EQUAL(0)    |
    	 	
    	## Verify If CEE Ops Center is running. 	
    	Given I print: "********Verify If CEE Ops Center is running.*********"
    	Then I validate the following attributes:
	  	  | attribute             | value                                            |
	   	  | {SSH.depPercentCee}   | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) |
	   	  
     	## Verify If PCF Ops Center is running. 	
    	Given I print: "********Verify If PCF Ops Center is running.*********"
    	Then I validate the following attributes:
	  	  | attribute             | value                                            |
	   	  | {SSH.depPercentPcf}   | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) |
	   	  
	   	

		## Verify if Memory usage not increased too much.
			Given I print: "********Verify if Memory usage not increased too much.*********"
#			When I execute the SSH command "echo {SSH.MemUsageAfter} {SSH.MemUsageBefore} | awk '{print ($1 - $2)}'| sed 's/-//g' " at K8SMaster
			When I execute the SSH command "echo {SSH.MemUsageAfter} - {SSH.MemUsageBefore} | bc | sed 's/-//g' " at SITEHOST	
			Then I save the SSH response in the following variables:
	      | attribute      | value          |
	      | (.*)           | MemUsageDev    |
	    Given I validate the following attributes:
	     	|   attribute                 | value                                                   													 |
    	 	|  {SSH.MemUsageDev}	        | LESSTHAN({config.global.scenario.noisy.thresholds-cpu-memory-dsk-deviation})       |
	      
	   ## Verify if CPU usage increased.
 #	   	Given I print: "********Verify if CPU usage increased.*********"
#			When I execute the SSH command "echo {SSH.CpuUsageAfter} {SSH.CpuUsageBefore} | awk '{print ($1 - $2)}' | sed 's/-//g'" at K8SMaster	
#			Then I save the SSH response in the following variables:
#	      | attribute      | value          |
#	      | (.*)           | CpuUsageDev    |
#	    Given I validate the following attributes:
#	     	|   attribute                 | value                                                   |
    #	 	|  {SSH.CpuUsageDev}	        | GREATERTHAN({config.global.scenario.noisy.thresholds-cpu-memory-dsk-deviation})    |   
#	    Given I validate the following attributes:
#	     	|   attribute                 | value                                                   |
    #	 	|  {SSH.CpuUsageAfter}	      | GREATERTHAN({SSH.CpuUsageBefore})    |  
    	 	
	   ## Verify if Disk usage increased.
	   Given I print: "********Verify if Disk usage increased.*********"
	   
     Given I validate the following attributes:
	     	|   attribute                 | value                                   |
    	 	|  {SSH.DskUsageAfter}	      | GREATERTHAN({SSH.DskUsageBefore})       | 
	      