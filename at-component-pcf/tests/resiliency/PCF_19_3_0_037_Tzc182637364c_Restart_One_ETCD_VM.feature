####################################################################################################
# Date: <04/06/2019> Version: <Initial version: 19.3.0> Create by <Prosenjit Chatterjee, proschat> #
####################################################################################################
@PCF @Resiliency @Tzc182637364c @P1 @PcfResP1Set2 @VMRestart 

Feature: PCF_19_3_0_037_Tzc182637364c_Restart_One_ETCD_VM

Scenario: Restart One ETCD VM 30 MINs- One Iterations
  
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
      | Restart One ETCD VM - One Iterations | Fail |
    #CICD Test report end
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |  
    
    ##GET IP Address of the smiopscenter
    When I execute the SSH command k3s kubectl get svc -n smi -o wide | grep ^ops-center | awk '{print $3}' at SMIDeployer
    Then I save the SSH response in the following variables:
      | attribute |  value           |
      | (.*)      |  smiopscenterip  |

    ### Create the SSH instance for chaosopscenterip
    Given I configure a SSH instance with following attributes:
      |  string                   |  value                                |
      |  InstanceName             |  SMIDeployerOpsCenter                 |
      |  UserName                 |  {config.CliOPSCenter.SSH.UserName}   |
      |  Password                 |  {config.CliOPSCenter.SSH.Password}   |
      |  Port                     |  2024                                 |
      |  EndpointIpAddress        |  {SSH.smiopscenterip}                 |
      |  Route                    |  SMIDeployer-->SMIDeployerOpsCenter   |
    
    ## Get all nodes info from SMIDeployerOpsCenter.
    When I execute the SSH command "{config.global.command.opsCenter.show-running-config} clusters nodes" at SMIDeployerOpsCenter
    Then I save the SSH response in the following variables:
      | attribute        | value                  |
      | ([\s\S]*)        | runningConfigNodes     |

    ## Get Clustername
    When I execute the SSH command "echo "{SSH.runningConfigNodes}" | head -1 | awk '{print $NF}'" at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute        | value             |
      | (.*)             | clusterName       |
 
    ## Get ETCD node hostname from SMIDeployerOpsCenter
     When I execute the SSH command "echo "{SSH.runningConfigNodes}" | awk '$0~p{print a}{a=$0}' p="k8s node-type etcd" | awk ' FNR==1 {print $NF}'" at SITEHOST
     Then I save the SSH response in the following variables:
      | attribute        | value             |
      | (.*)             | depnodeHost       |

    ##GET name of the ETCD node
    When I execute the SSH command "echo "{SSH.clusterName}-{SSH.depnodeHost}""  at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute        | value             |
      | (.*)             | NodeName          |

    ##Teardown Steps
    Given the below steps are armed to be executed during teardown

    #####Bring up etcd vm
    When I execute using handler SITEHOST the parameterized command /root/action.sh {config.scenario.exec-params.sut.platform-type} {config.sut.blades.sshpassowrd} {config.sut.vm.sshpassword} 1 0 with following arguments:
      | attribute | value                        |
      | F         | vm_power_on                  |
      | V         | {SSH.NodeName}               |
      | O         | {config.sut.ospd.ipaddress}  |
      | E         | {config.sut.esc.ipaddress}   |
      | P         | {config.sut.esc.sshpassowrd} |
      | K         | /root/{SSH.smiKeyName}            |
      | U         | {config.sut.k8smaster.default.user}      |

    ##External Teardown File
    Given I execute the steps from {config.global.workspace.library.location-features-validations-common}Teardown.feature

    Given I delete SSH instance SMIDeployerOpsCenter
    
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

    Then I wait for {config.scenario.exec-params.benchmark-interval} seconds

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

    ## Now reboot the ETCD node.
    When I execute using handler SITEHOST the parameterized command /root/action.sh {config.scenario.exec-params.sut.platform-type} {config.sut.blades.sshpassowrd} {config.sut.vm.sshpassword} 1 0 with following arguments:
      | attribute | value                        |
      | F         | vm_power_off                 |
      | V         | {SSH.NodeName}               |
      | O         | {config.sut.ospd.ipaddress}  |
      | E         | {config.sut.esc.ipaddress}   |
      | P         | {config.sut.esc.sshpassowrd} |
      | K         | /root/{SSH.smiKeyName}            |
      | U         | {config.sut.k8smaster.default.user}      |
    Then I receive a SSH response and check the presence of following strings:
      | string                                  | occurrence |
      | VM in Shutdown state as expected        | present    |
      | VM is not in Shutdown state as expected | absent     |

    Then I wait for {config.global.constant.twohundred.forty} seconds		

    #####Bring back powered down oam vm
    When I execute using handler SITEHOST the parameterized command /root/action.sh {config.scenario.exec-params.sut.platform-type} {config.sut.blades.sshpassowrd} {config.sut.vm.sshpassword} 1 0 with following arguments:
      | attribute | value                             |
      | F         | vm_power_on                       |
      | V         | {SSH.NodeName}                    |
      | O         | {config.sut.ospd.ipaddress}      |
      | E         | {config.sut.esc.ipaddress}       |
      | P         | {config.sut.esc.sshpassowrd} |
      | K         | /root/{SSH.smiKeyName}            |
      | U         | {config.sut.k8smaster.default.user}      |
    Then I receive a SSH response and check the presence of following strings:
      | string                                | occurrence |
      | VM in Active state as expected        | present    |
      | VM is not in Active state as expected | absent     |

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
    
    Then I wait for {config.global.constant.ninety} seconds		
    
    ###Print the Kubectl pod status 
    When I execute the SSH command kubectl describe node {SSH.NodeName} at K8SMaster 
   
    When I execute the SSH command kubectl get nodes at K8SMaster
    Then I receive a SSH response and check the presence of following strings:
        | string      | occurrence |
        | NotReady    | absent     |

    When I execute the SSH command "date '+%s'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute | value              |
      | (.*)      | grafana_start_time |

    Then I wait for {config.scenario.exec-params.benchmark-interval} seconds

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
      | Restart One ETCD VM - One Iterations | Pass |
    #CICD report end#####################
