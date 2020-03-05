############################################################################################
# Date: <02/01/2016> Version: <Initial version: 18.5> $1Create by <Sandeep Talukdar, santaluk>
############################################################################################

@Setup_Dependency_Initializer

Feature: Dependency_Initializer_And_SUT_Health_Validator

Scenario: Configure dependencies required for automation and prevalidate SUT health

    Given I print: "Copy the smi deployer id rsa key to all the master."
    
    Given the SFTP push of file {config.sut.SMIDeployer.SSH-KeyFile} to /root/ at SITEHOST is successful
    
    When I execute the SSH command echo '{config.sut.SMIDeployer.SSH-KeyFile}' | awk -F'/' '{print $NF}' at SITEHOST
    Then I save the SSH response in the following variables:
      | attribute    | value      |
      | (.*)         | smiKeyName |       
      
    When I execute the SSH command chmod 600 /root/{SSH.smiKeyName} at SITEHOST
    
    Given the SFTP push of file {config.sut.SMIDeployer.SSH-KeyFile} to {config.sut.k8smaster.home.directory} at K8SMaster is successful
    
    Given I execute using handler K8SMaster the SSH shell command rm -rf {config.sut.k8smaster.home.directory}/about.sh
    Given the SFTP push of file {config.global.workspace.library.location-scripts}/cicd-report/about.sh to {config.sut.k8smaster.home.directory} at K8SMaster is successful
    Given I execute using handler K8SMaster the SSH shell command rm -rf {config.sut.k8smaster.home.directory}/GetPCFInstalledBuild.sh
    Given the SFTP push of file {config.global.workspace.library.location-scripts}/cicd-report/GetPCFInstalledBuild.sh to {config.sut.k8smaster.home.directory} at K8SMaster is successful
        
    Given I execute using handler K8SMaster the SSH shell command chmod 600 {config.sut.k8smaster.home.directory}{SSH.smiKeyName}
    Given I execute using handler SITEHOST the SSH shell command chmod 600 /root/{SSH.smiKeyName}
    
    Given I print: "Create required folder structures on corresponding nodes."
		### FOR TET
		Given I execute using handler LDAPServer the SSH shell command mkdir -m 755 -p {config.global.remotepush.location.utilities-tet-upload-tetpull-path}
		Given I execute using handler LDAPServer the SSH shell command mkdir -m 755 -p {config.global.remotepush.location.utilities-tet-tetpull-output} 
		
        Given I execute using handler K8SMaster the SSH shell command mkdir -m 755 -p {config.global.remotepush.location.utilities}
        
		Given I execute the SSH command rm -rf {config.global.remotepush.sitehost-location.utilities}/* at SITEHOST
		Given I execute the SSH command mkdir -m 755 {config.global.remotepush.sitehost-location.utilities} at SITEHOST

    Given I print: "FTP Application KPI check utilities."
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-validations}CheckTotalTPS.sh" to {config.global.remotepush.sitehost-location.utilities} at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-validations}CompareCPUTPSValues.sh" to {config.global.remotepush.sitehost-location.utilities} at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-validations}CompareKPIValues.sh" to {config.global.remotepush.sitehost-location.utilities} at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-validations}CompareResTimeValues.sh" to {config.global.remotepush.sitehost-location.utilities} at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-validations}GetAbsValue.sh" to {config.global.remotepush.sitehost-location.utilities} at SITEHOST is successful    
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-validations}GetTotalTPSThreshold.sh" to {config.global.remotepush.sitehost-location.utilities} at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-validations}SiteFailoverTpsValidation.sh" to {config.global.remotepush.sitehost-location.utilities} at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-validations}getCCRIRatio.sh" to {config.global.remotepush.sitehost-location.utilities} at SITEHOST is successful
    
    Given I print: "FTP K8S minion CPU check utilities."
    	Given I execute using handler K8SMaster the SSH shell command rm -rf {config.sut.k8smaster.home.directory}/validateK8sMinionCPUMemory.sh
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-validations}validateK8sMinionCPUMemory.sh" to {config.sut.k8smaster.home.directory} at K8SMaster is successful
        Given I execute using handler K8SMaster the SSH shell command rm -rf {config.sut.k8smaster.home.directory}/checkMinionCPUAverage.sh
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-capture}checkMinionCPUAverage.sh" to {config.sut.k8smaster.home.directory} at K8SMaster is successful
    
    Given I print: "FTP Utilities to trigger resilliency events."
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-sc-resiliency}test.setup" to /root/ at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-sc-resiliency}action.sh" to /root/ at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-sc-resiliency}functions_VM.sh" to /root/ at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-sc-resiliency}functions_OSP.sh" to /root/ at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-sc-resiliency}functions_ESC.sh" to /root/ at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-sc-resiliency}functions_CVIM.sh" to /root/ at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-sc-resiliency}functions_ESC_NONULTRA.sh" to /root/ at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-sc-resiliency}functions_ESC_UAME.sh" to /root/ at SITEHOST is successful
    
    Given I print: "FTP utilities to check SNMP traps."
        Given I execute using handler K8SMaster the SSH shell command rm -rf {config.sut.k8smaster.home.directory}/PCF_compare_alert_config_with_log.sh
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-validations}PCF_compare_alert_config_with_log.sh" to {config.sut.k8smaster.home.directory} at K8SMaster is successful   
    
    Given I print: "FTP utility calculate resiliency event duration."
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-validations}GetEventDuration.sh" to {config.global.remotepush.sitehost-location.utilities} at SITEHOST is successful
        
    Given I print: "FTP TET utilities"
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-tet}PCF_tet_pull_stats.sh" to {config.global.remotepush.location.utilities-tet-upload-tetpull-path} at LDAPServer is successful
        Given the SFTP push of file "{config.sut.workspace.location.utilities-tetconfigfile}" to {config.global.remotepush.location.utilities-tet-upload-tetpull-path} at LDAPServer is successful
        
    Given I print: "FTP generic utilities"
#        Given the SFTP push of file "{config.global.workspace.library.location-scripts-capture}getMemData.sh" to {config.global.remotepush.location.utilities} at K8SMaster is successful
        Given I execute using handler K8SMaster the SSH shell command rm -rf {config.sut.k8smaster.home.directory}/get_deploy_status.sh
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-sc-deploy}get_deploy_status.sh" to {config.sut.k8smaster.home.directory} at K8SMaster is successful
#        Given the SFTP push of file "{config.global.workspace.library.location-scripts-sc-deploy}setenv.rc" to {config.sut.k8smaster.home.directory} at K8SMaster is successful
#        Given the SFTP push of file "{config.global.workspace.library.location-scripts-sc-resiliency}/ssh_add_key_to_known_hosts.sh" to {config.sut.k8smaster.home.directory} at K8SMaster is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-sv-reports}about.sh" to "/root/" at SITEHOST is successful        

        Given the SFTP push of file "{config.global.workspace.library.location-scripts-calipers}AssignEndPointIpAddress.sh" to {config.global.remotepush.sitehost-location.utilities} at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-calipers}AssignSubscriberInfo.sh" to {config.global.remotepush.sitehost-location.utilities} at SITEHOST is successful
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-capture}getCDLFilterPrefix.sh" to {config.global.remotepush.sitehost-location.utilities} at SITEHOST is successful
        Given I execute using handler K8SMaster the SSH shell command rm -rf {config.sut.k8smaster.home.directory}/GetSystemDeploymentStatus.sh        
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-capture}GetSystemDeploymentStatus.sh" to {config.sut.k8smaster.home.directory} at K8SMaster is successful
        Given I execute using handler K8SMaster the SSH shell command rm -rf {config.sut.k8smaster.home.directory}/cpu_Load_Check.sh
        Given the SFTP push of file "{config.global.workspace.library.location-scripts-capture}cpu_Load_Check.sh" to {config.sut.k8smaster.home.directory} at K8SMaster is successful
  
    Given I print: "Making utilities executables"
        Given I execute using handler K8SMaster the SSH shell command "chmod +x {config.global.remotepush.location.utilities}*.sh"
        Given I execute using handler K8SMaster the SSH shell command "chmod +x {config.sut.k8smaster.home.directory}/*.sh"
        Given I execute using handler K8SMaster the SSH shell command "chmod 755 *.sh"
#        Given I execute using handler SMIDeployer the SSH shell command "chmod 755 *.sh"
        Given I execute using handler SITEHOST the SSH shell command "chmod 755 *.sh"

        Given I execute using handler SITEHOST the SSH shell command chmod 755 {config.global.remotepush.sitehost-location.utilities}*.sh
        ### For TET
        Given I execute the SSH command "chmod 755 {config.global.remotepush.location.utilities-tet-upload-tetpull-path}PCF_tet_pull_stats.sh" at LDAPServer
        Given I execute the SSH command "chmod 755 {config.global.remotepush.location.utilities-tet-upload-tetpull-path}pcf_tet_pull_config_site1.txt" at LDAPServer
    
    Given I print: "Converting utilities to dos2unix"
        
        ### For TET
        Given I execute the SSH command "dos2unix {config.global.remotepush.location.utilities-tet-upload-tetpull-path}PCF_tet_pull_stats.sh" at LDAPServer
        
    ################# Print the PCF and CEE version ################
    
    Given I execute the SSH command {config.sut.k8smaster.home.directory}/GetPCFInstalledBuild.sh at K8SMaster
    
    ################# Print the PCF and CEE version ################        
    
    ######################### Install sysstat in all VMs #########################
    Given I print: "Install sysstat in all VMs"
    Given I print: "    Get number of nodes from K8SMaster."
    When I execute the SSH command kubectl get no -o name | wc -l at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute      | value    |
      | (.*)           | NodeCnt  |

    Given I define the following constants:
      | name     | value |
      | Index    | 1     |

    Given I print: "    Add sysstat in each VM"
    
    Given I loop {SSH.NodeCnt} times
        When I execute the SSH command kubectl get no -o name | awk ' FNR == {Constant.Index} {print $1}' | cut -d '/' -f 2 at K8SMaster
        Then I save the SSH response in the following variables:
          | attribute      | value     |
          | (.*)           | NodeName  |

        When I execute the SSH command ssh {SSH.NodeName} "apt-get install -y sysstat" at K8SMaster

        Then I increment Constant.Index by 1
    Given I end loop 
    
    ######################### Installation of sysstat end. #########################

   
    ######################### Start - Check status of the deployment. #########################
    Given I print: "Check status of the PCF deployment."
    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLIPcfOPSCenter
    Then I receive a SSH response and check the presence of following strings:
      | string                         | occurrence  |
      | system status deployed true    | present     |
    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLIPcfOPSCenter
    Then I save the SSH response in the following variables:
      | attribute                             | value           |
      | (system status percent-ready\s+\S+)   | depPerReady     |
    When I execute using handler SITEHOST the SSH command "echo {SSH.depPerReady}"
    Then I save the SSH response in the following variables:
      | attribute             | value       |
      | {Regex}(\d+.\d+)      | depPerReady |
    Then I validate the following attributes:
      | attribute         | value                                            |
      | {SSH.depPerReady} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) |

    Given I print: "Check status of the CEE deployment."
    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLICeeOPSCenter
    Then I receive a SSH response and check the presence of following strings:
      | string                         | occurrence  |
      | system status deployed true    | present     |
    When I execute the SSH command "{config.global.command.opsCenter.system-deployed-status}" at CLICeeOPSCenter
    Then I save the SSH response in the following variables:
      | attribute                             | value           |
      | (system status percent-ready\s+\S+)   | depPerReady     |
    When I execute using handler SITEHOST the SSH command "echo {SSH.depPerReady}"
    Then I save the SSH response in the following variables:
      | attribute             | value       |
      | {Regex}(\d+.\d+)      | depPerReady |
    Then I validate the following attributes:
      | attribute         | value                                            |
      | {SSH.depPerReady} | GREATERTHANOREQUAL({config.global.thresholds.system.status-ready-expectedpercentage}) |
    ######################### End - Check status of the deployment. #########################

    ######################### Start - Enable Bulk Status #########################
    Given I print: "Enable Bulk Status"
    When I execute the SSH command {config.global.command.opsCenter.enable-bulk-stats} at CLICeeOPSCenter
    Then I wait for {config.global.constant.onehundred.twenty} seconds
    Given I print: "====================== Build info on {config.sut.k8s.namespace.pcf}  ========================="
    When I execute the SSH command helm list --sut.k8s.namespace.pcf {config.sut.k8s.namespace.pcf} at K8SMaster
    Given I print: "====================== Start Build info on {config.sut.k8s.namespace.cee}  ========================="
    When I execute the SSH command helm list --sut.k8s.namespace.pcf {config.sut.k8s.namespace.cee} at K8SMaster
    ######################### End -  Enable Bulk Status #########################