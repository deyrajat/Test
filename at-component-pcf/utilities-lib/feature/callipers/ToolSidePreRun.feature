############################################################################################
# Date: <05/12/2018> Version: <Initial version: 18.0> $1Create by <Prasanna Singh, prasasin>
############################################################################################
##All required pre-requisite steps before the call-model starts are mentioned here:
@ToolSidePreRun

Feature: Resiliency_PreRun

Scenario: Steps to prepare SUT before executing test scenario

    Given I execute the SSH command "pkill -f ToolAgent" at ToolAgentHost
    Given I execute the SSH command "pkill -f lattice" at ToolAgentHost
    Given I execute the SSH command "pkill -f cli" at ToolAgentHost

    Given I print:===================== Pod Status after pcf config =========================
    When I execute using handler K8SMaster the SSH shell command {config.global.commands.k8s.pod-list-pcf} | grep -v Running
    Given I print:===================== Pod Status after pcf config =========================   

    When I execute the SSH command rm -rf {config.ToolAgentPath} at ToolAgentHost  

    When I execute the SSH command mkdir -m 755 -p {config.ToolAgentPath} at ToolAgentHost    
    
    Then I execute the SSH command cp {config.Calipers.src.binary-path}ToolAgent {config.ToolAgentPath} at ToolAgentHost  

	##### Delete the callipers configuration and file and get the latest from repo
	
    When I execute the SSH command rm -rf {config.Calipers.tmp.binary-path} at ToolAgentHost  

    When I execute the SSH command mkdir -m 755 -p {config.Calipers.tmp.binary-path} at ToolAgentHost  
    
    Then I execute the SSH command cp {config.Calipers.src.binary-path}lattice {config.Calipers.tmp.binary-path} at ToolAgentHost  
    
    Then I execute the SSH command cp {config.Calipers.src.binary-path}cli {config.Calipers.tmp.binary-path} at ToolAgentHost  
    
    Given I wait for {config.global.constant.twenty} seconds  
    
    When I execute the SSH command chmod 755 {config.ToolAgentPath}/ToolAgent at ToolAgentHost  
    
    When I execute the SSH command chmod 755 {config.Calipers.tmp.binary-path}cli at ToolAgentHost  
    
    When I execute the SSH command chmod 755 {config.Calipers.tmp.binary-path}lattice at ToolAgentHost     
    
    Then I execute the SSH command cd {config.ToolAgentPath}; ./ToolAgent -v  at ToolAgentHost  
    
    Then I execute the SSH command cd {config.Calipers.tmp.binary-path} ;  ./cli -v  at ToolAgentHost  
    
    Then I execute the SSH command cd {config.Calipers.tmp.binary-path} ;  ./lattice -v at ToolAgentHost  
    
    Given I execute the SSH command "cd {config.ToolAgentPath}; ./ToolAgent 9000 4 enable-file-logging > /dev/null 2>&1 & disown" at ToolAgentHost

    Given I wait for {config.global.constant.thirtyfive} seconds  
    
	### Get the status of the process that were re-started
	Given I execute the SSH command ps -ef | grep ToolAgent | grep -v grep  at ToolAgentHost    

    Given I print:********** Additional PreRun steps are currently not required for Calipers **********