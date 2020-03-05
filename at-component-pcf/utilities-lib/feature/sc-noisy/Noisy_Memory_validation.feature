###############################################################################################
# Date: <14/11/2019> Version: <Initial version: 19.3> Create by <Prosenjit Chatterjee, proschat>
###############################################################################################
@NoisyScenario

Feature: Noisy_Memory_validation

Scenario: Steps to Validate Noisy Memory Scenario

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

		## Verify if Memory usage increased and reached to user defined limit.
			Given I print: "********Verify if Memory usage increased and reached to user defined limit.*********"
	    Given I validate the following attributes:
	     	|   attribute                 | value                              |
    	 	|  {SSH.MemUsageAfter}	      | GREATERTHAN({SSH.MemUsageBefore})  |	 	
			When I execute the SSH command "echo {SSH.MemUsageAfter} {config.scenario.exec-params.mem.stress-percentage} | awk '{print ($1 - $2)}' | sed 's/-//g'" at K8SMaster	
			Then I save the SSH response in the following variables:
	      | attribute      | value          |
	      | (.*)           | MemUsageDev    |
	    Given I validate the following attributes:
	     	|   attribute                 | value                                                   |
    	 	|  {SSH.MemUsageDev}	        | LESSTHAN({config.global.scenario.noisy.thresholds-cpu-memory-dsk-deviation})       |
	      
	   ## Verify if CPU usage not increased.
	   
#	   Given I print: "********Verify if CPU usage not increased.*********"
#			When I execute the SSH command "echo {SSH.CpuUsageAfter} {SSH.CpuUsageBefore} | awk '{print ($1 - $2)}'| sed 's/-//g'" at K8SMaster	
#			Then I save the SSH response in the following variables:
#	      | attribute      | value          |
#	      | (.*)           | CpuUsageDev    |
#	    Given I validate the following attributes:
#	     	|   attribute                 | value                                                   |
    #	 	|  {SSH.CpuUsageDev}	        | LESSTHAN({config.global.scenario.noisy.thresholds-cpu-memory-dsk-deviation})       |   
    	 	
	   ## Verify if Disk usage not increased.
	   Given I print: "********Verify if Disk usage not increased.*********"
			When I execute the SSH command "echo {SSH.DskUsageAfter} - {SSH.DskUsageBefore} | bc | sed 's/-//g'" at SITEHOST	
			Then I save the SSH response in the following variables:
	      | attribute      | value          |
	      | (.*)           | DskUsageDev    |
	    Given I validate the following attributes:
	     	|   attribute                 | value                                                   |
    	 	|  {SSH.DskUsageDev}	        | LESSTHAN({config.global.scenario.noisy.thresholds-cpu-memory-dsk-deviation})       | 
	      