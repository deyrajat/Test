############################################################################################
# Date: <06/25/2018> Version: <Initial version: 18.0> $1Create by <Prasanna Singh, prasasin>
############################################################################################
##All required pre-requisite steps before the call-model starts are mentioned here:
@CallStart

Feature: Resiliency_SetupTest_Calipers

Scenario: Steps to prepare SUT before executing test scenarios

  Given I define the following constants:
    | name            | value        |
    | channelIndex    | 1            |
    | nrfCfgIndex     | 1            |

	Given I expect the next test step to execute if ({config.scenario.start.traffic} > 0)

     #Addtional PreRun Steps for specific Tools
     Given I execute the steps from {config.global.workspace.library.location-features-calipers}ToolSidePreRun.feature

     Given I execute the SSH command "mkdir {config.Calipers.Config.dir}" at SITEHOST

     #SFTP push of Solution specific calipers files
     Given I loop {config.CalipersFileCount} times

        Given the SFTP push of file "{config.CalipersSourcePath}{config.{config.tools.caliper.cfg-files-arrayprefix}{Constant.channelIndex}}" to "{config.Calipers.Config.dir}" at SITEHOST is successful
        
        When I execute using handler SITEHOST the parameterized command {config.global.remotepush.sitehost-location.utilities}/AssignSubscriberInfo.sh with following arguments:
          | attribute | value                                                                                                          |
          | f         | {config.Calipers.Config.dir}{config.{config.tools.caliper.cfg-files-arrayprefix}{Constant.channelIndex}}       |
          | S         | {config.tools.calipers.{config.{config.tools.caliper.subscriber-cm-arrayprefix}{Constant.channelIndex}}.SUPI}  |
          | G         | {config.tools.calipers.{config.{config.tools.caliper.subscriber-cm-arrayprefix}{Constant.channelIndex}}.GPSI}  |
          | P         | {config.tools.calipers.{config.{config.tools.caliper.subscriber-cm-arrayprefix}{Constant.channelIndex}}.PEI}   |
          | i         | {config.tools.calipers.{config.{config.tools.caliper.subscriber-cm-arrayprefix}{Constant.channelIndex}}.IPv4}  |
          | s         | {config.tools.calipers.{config.{config.tools.caliper.subscriber-cm-arrayprefix}{Constant.channelIndex}}.IPv6}  |
          | c         | {config.{config.tools.caliper.locality-arrayprefix}{Constant.channelIndex}}  |
       

        When I execute using handler SITEHOST the parameterized command /root/AssignEndPointIpAddress.sh with following arguments:
          | attribute | value                                       |
          | f         | {config.Calipers.Config.dir}{config.{config.tools.caliper.cfg-files-arrayprefix}{Constant.channelIndex}}    |
          | c         | {config.{config.tools.caliper.callrate-arrayprefix}{Constant.channelIndex}}                              |
          | L         | {config.{config.tools.caliper.origin-host-interface-arrayprefix}{Constant.channelIndex}}         |
          | G         | {config.sut.vm.proto.n7client-vipaddress}                                              |
          | N         | {config.sut.vm.proto.n28client-vipaddress}                                             |
          | R         | {config.sut.vm.proto.rxclient-vipaddress}                                              |
          | p         | {config.Nrf1RegPort}                                                                   |
          | q         | {config.Nrf2RegPort}                                                                   |
          | r         | {config.Nrf3RegPort}                                                                   |
          | b         | {config.{config.tools.caliper.event-bridge-port-arrayprefix}{Constant.channelIndex}}   |
          | s         | {config.sut.nrf.server1.ipaddress}                                                     |
          | t         | {config.sut.nrf.server2.ipaddress}                                                     |
          | u         | {config.sut.nrf.server3.ipaddress}                                                     |

        Then I increment Constant.channelIndex by 1
        
     And I end loop

     #SFTP push of nrf specific calipers files
     Given I loop {config.tools.caliper.nrf.file-count} times

       Given the SFTP push of file "{config.CalipersSourcePath}{config.{config.tools.caliper.nrf-config-file-arrayprefix}{Constant.nrfCfgIndex}}" to "{config.Calipers.Config.dir}" at SITEHOST is successful

       When I execute using handler SITEHOST the parameterized command /root/AssignEndPointIpAddress.sh with following arguments:
         | attribute | value                                       |
         | f         | {config.Calipers.Config.dir}{config.{config.tools.caliper.nrf-config-file-arrayprefix}{Constant.nrfCfgIndex}}  |
         | c         | {config.{config.tools.caliper.nrf-callrate-arrayprefix}{Constant.nrfCfgIndex}}                            |
         | L         | {config.ToolAgentHost.SSH.EndpointIpAddress}                                           |
         | p         | {config.Nrf1RegPort}                                                                   |
         | q         | {config.Nrf2RegPort}                                                                   |
         | r         | {config.Nrf3RegPort}                                                                   |
         | s         | {config.sut.nrf.server1.ipaddress}                                                     |
         | t         | {config.sut.nrf.server2.ipaddress}                                                   |
         | u         | {config.sut.nrf.server3.ipaddress}                                                    |

       Then I increment Constant.nrfCfgIndex by 1
       
     And I end loop

     Given I execute the SSH command "dos2unix {config.Calipers.Config.dir}*.cfg" at SITEHOST

   Given I expect the next test steps to execute otherwise

     Given I print: " Call flow setup / start not needed

   Given I end the if
