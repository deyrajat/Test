###############################################################################################
# Date: <15/12/2017> Version: <Initial version: 18.0> $1Create by <Soumil Chatterjee, soumicha>
###############################################################################################
##Capturing benchmark data before event start which will later be used for validations

@BenchmarkCapture

Feature: InitKPIStatus for SV Report

Scenario: Initiliaze KPI status with default values

    Given the SFTP push of file "{config.global.workspace.library.location-scripts-sv-reports}/updateCheckComments.sh" to "/root/" at SITEHOST is successful
    Given I execute the SSH command "chmod 755 /root/updateCheckComments.sh" at SITEHOST
    
    Given the SFTP push of file "{config.global.workspace.library.location-scripts-sv-reports}/getFinalStatusForKPI.sh" to "/root/" at SITEHOST is successful
    Given I execute the SSH command "chmod 755 /root/getFinalStatusForKPI.sh" at SITEHOST
    
    When I execute using handler SITEHOST the SSH shell command "rm -f /tmp/execStatus.txt"
    
    #Application KPIs
    When I execute using handler SITEHOST the SSH shell command "/root/updateCheckComments.sh DRT"
    When I execute using handler SITEHOST the SSH shell command "/root/updateCheckComments.sh DEP"
    When I execute using handler SITEHOST the SSH shell command "/root/updateCheckComments.sh DTP"
    When I execute using handler SITEHOST the SSH shell command "/root/updateCheckComments.sh AC"
    
    #System KPIs
    When I execute using handler SITEHOST the SSH shell command "/root/updateCheckComments.sh CPU"
    When I execute using handler SITEHOST the SSH shell command "/root/updateCheckComments.sh SWAP"
    When I execute using handler SITEHOST the SSH shell command "/root/updateCheckComments.sh VMDROPS"