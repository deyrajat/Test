####################################################################################################
# Date: <09/01/2020> Version: <Initial version: 19.5.0> Create by <Sandeep Talukdar, santaluk> #
####################################################################################################

@CanaryConfiguration

Feature: PCF_Canary_Configuration

  Scenario: Configure Canary on the PCF
  
    ### Get the package name 
    When I execute the SSH command echo {config.global.scenario.downgrade.canary-offline-build} | rev |cut -d "." -f 2- | rev at SMIDeployer
    Then I save the SSH response in the following variables:
      | attribute | value            |
      | (.*)      | PCFPackageName   |
  
    When I execute the SSH command {config.global.scenario.engine.rule-canary-remove} at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.twenty} seconds
    
    When I execute the SSH command {config.global.scenario.canary.engine-delete-command} at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.twenty} seconds
    
    When I execute the SSH command {config.global.scenario.canary.repo-cmd-remove} at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.twenty} seconds
   
    When I execute the SSH command rm -rf /root/{SSH.PCFBuildName} at SMIDeployer
    
    ##### Disable SVN    
    When I execute the SSH command config ; {config.global.command.opsCenter.system-disable-svn} ; commit ; end at CLIPcfOPSCenter
    
    Then I wait for {config.global.constant.onehundred.eighty} seconds

    ## Enable subversion-ingress for SVN.
    When I execute the SSH command config ; {config.global.command.opsCenter.system-enable-svn} ; commit ; end at CLIPcfOPSCenter

    Then I wait for {config.global.constant.onehundred.eighty} seconds

    When I execute the SSH command kubectl get ing -n {config.sut.k8s.namespace.pcf} | grep svn | awk '{print $2}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value      |
      | (.*)      | svn_ep_url | 
      
    #### Download the Build in the SMI deployer
    
    When I execute the SSH command {config.global.scenario.build.list} at SMIDeployerOpsCenter
    
    When I execute the SSH command {config.global.scenario.build.delete} {SSH.PCFPackageName} at SMIDeployerOpsCenter
    
    Then I wait for {config.global.constant.onehundred.twenty} seconds
    
    When I execute the SSH command {config.global.scenario.build.download} {config.global.scenario.downgrade.canary-offline-build-URL}{config.global.scenario.downgrade.canary-offline-build} at SMIDeployerOpsCenter
    
    Then I wait for {config.global.constant.onehundred.eighty} seconds       
    
    ## check that the build is listed or not
    Given I loop 15 times
    
	    When I execute the SSH command {config.global.scenario.build.list} at SMIDeployerOpsCenter
	    Then I save the SSH response in the following variables:
	      | attribute      | value           |
	      | ([\s\S]*)      | BuildPresent    |
	      
	    When I execute the SSH command echo "{SSH.BuildPresent}" | grep {SSH.PCFPackageName} | wc -l at SITEHOST
	    Then I save the SSH response in the following variables:
	      | attribute | value           |
	      | (.*)      | IsBuildPresent  |
	      
        Given I break loop if {SSH.IsBuildPresent} >= 1

        Given I wait for {config.global.constant.sixty} seconds

	And I end loop 
	
	## check that the charts and registry are created or not.
	
	Given I loop 15 times
	
	    When I execute the SSH command {config.global.scenario.smi.pods-list} | grep {SSH.PCFPackageName} | wc -l at SMIDeployer
	    Then I save the SSH response in the following variables:
	      | attribute | value           |
	      | (.*)      | BuildUploaded   |
	      
        Given I break loop if {SSH.BuildUploaded} >= 2

        Given I wait for {config.global.constant.sixty} seconds

	And I end loop 
	    
	When I execute the SSH command {config.global.scenario.build.list} at SMIDeployerOpsCenter
	
	Given I loop 15 times
	
		When I execute the SSH command {config.global.scenario.canary.pod-status} at SMIDeployer
		Then I save the SSH response in the following variables:
	      | attribute | value           |
	      | (.*)      | SMIPodNotReady  |
	      
        Given I break loop if {SSH.SMIPodNotReady} <= 0

        Given I wait for {config.global.constant.sixty} seconds

	And I end loop 		
	
	### Add the helm repo for canary
    When I execute the SSH command {config.global.scenario.canary.repo-cmd}{SSH.PCFPackageName}/ ; commit ; end at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.ninety} seconds
    
    ### Show the helm repository
    When I execute the SSH command {config.global.scenario.helm.repo-show} at CLIPcfOPSCenter
    Then I receive a SSH response and check the presence of following strings:
      | string                  | occurrence  |
      | {SSH.PCFPackageName}    | present     |
      
    #### configure the new engine 
    When I execute the SSH command config ; {config.global.scenario.canary.engine-create-command} ; commit ; end at CLIPcfOPSCenter
    
    Given I wait for {config.global.constant.sixty} seconds
    Given I wait for {config.global.constant.sixty} seconds
        
    ### Show the engine configuration
    When I execute the SSH command {config.global.scenario.engine.config-show} at CLIPcfOPSCenter
    Then I receive a SSH response and check the presence of following strings:
      | string                                               | occurrence  |
      | {config.global.scenario.canary.engine-group-name}    | present     | 
      
    ### Check that the engines for new group are created 
    When I execute the SSH command kubectl get pod -n {config.sut.k8s.namespace.pcf} | grep --color=never engine at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string                                               | occurrence  |
      | {config.global.scenario.canary.engine-group-name}    | present     | 
      
    Given I wait for {config.global.constant.threehundred} seconds
  