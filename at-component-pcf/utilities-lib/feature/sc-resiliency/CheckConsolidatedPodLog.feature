####################################################################################################
# Date: <21/11/2019> Version: <Initial version: 19.5.0> Create by <Sandeep Talukdar, santaluk> #
####################################################################################################

@CheckConsolidatedPodLog

Feature: PCF_CheckConsolidatedPodLog

  Scenario: Check Consolidated Pod Log
  
    ### Delete the log file at the start    
    When I execute the SSH command rm -rf {config.sut.k8smaster.home.directory}/ConsolidatedPodLog.txt at K8SMaster
  
    ### Create the files to store the logs 
    When I execute the SSH command touch {config.sut.k8smaster.home.directory}/ConsolidatedPodLog.txt at K8SMaster
    
    When I execute the SSH command chmod 755 {config.sut.k8smaster.home.directory}/ConsolidatedPodLog.txt at K8SMaster
    
    Then I wait for {config.global.constant.threehundred} seconds
    
    ### Get the consolidated log pod name.
    When I execute the SSH command {config.global.commands.k8s.pod-list-pcf} | grep --color=never consolidated-logging | awk ' FNR == 1 {print $1}' at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value       |
      | (.*)           | LogPodName  |    
    
    When I execute the SSH command kubectl logs {SSH.LogPodName} -n {config.sut.k8s.namespace.pcf} --since={config.global.constant.twohundred.forty}s > {config.sut.k8smaster.home.directory}/ConsolidatedPodLog.txt at K8SMaster
    
    ### Check that the logs are generated
    When I execute the SSH command ls -l {config.sut.k8smaster.home.directory}/ConsolidatedPodLog.txt | awk '{print $5}' at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
      | string      | value          | occurrence |
      | {Regex}(.*) | greaterthan(0) | present    |  
      
    ### Delete the log file at the end    
    When I execute the SSH command rm -rf {config.sut.k8smaster.home.directory}/ConsolidatedPodLog.txt at K8SMaster
      