####################################################################################################
# Date: <21/11/2019> Version: <Initial version: 19.5.0> Create by <Sandeep Talukdar, santaluk> #
####################################################################################################

@Restart_Pod

Feature: PCF_Pod_Restart

  Scenario: Restart the specific pof

    ##GET IP Address of the N7 interface from CLI OPS CENTER
    When I execute the SSH command "{config.global.commands.k8s.svc-list} -n {config.sut.k8s.namespace.chaos} | grep 2024 | awk '{print $3}'" at K8SMaster
    Then I save the SSH response in the following variables:
      | attribute |  value             |
      | (.*)      |  chaosopscenterip  |

    ### Get hostname of the VM associated with VIP
    Given I configure a SSH instance with following attributes:
      |  string                   |  value                                  |
      |  InstanceName             |  CHAOSINSTANCE                          |
      |  UserName                 |  {config.CliOPSCenter.SSH.UserName}   |
      |  Password                 |  {config.CliOPSCenter.SSH.Password}   |
      |  Port                     |  2024                                   |
      |  EndpointIpAddress        |  {SSH.chaosopscenterip}                 |
      |  Route                    |  K8SMaster-->CHAOSINSTANCE              |

    Given I execute the SSH command chaos-test start target pod filter { names {SSH.PodName} sample 1 wait {config.global.constant.ninety} } at CHAOSINSTANCE

    When I execute the SSH command {config.global.command.opsCenter.chaos-system-status} at CHAOSINSTANCE
    Then I receive a SSH response and check the presence of following strings:
      | string                           | occurrence |
      | Is Chaos test running?  yes      | present    |
      | Is Chaos test running?  no       | absent     |

    Then I wait for {config.global.constant.onehundred.twenty} seconds
    
    Given I execute the SSH command {config.global.command.opsCenter.chaos-system-status} at CHAOSINSTANCE

    Given I execute the SSH command {config.global.command.opsCenter.chaos-end-test} at CHAOSINSTANCE

    Then I wait for {config.global.constant.ninety} seconds

    Given I execute the SSH command {config.global.command.opsCenter.chaos-system-status} at CHAOSINSTANCE

    When I execute the SSH command {config.global.command.opsCenter.chaos-system-status} at CHAOSINSTANCE
    Then I receive a SSH response and check the presence of following strings:
      | string                          | occurrence |
      | Is Chaos test running?  yes     | absent     |
      | Is Chaos test running?  no      | present    |
      | Is system ok? yes               | present    |

    Given I delete SSH instance CHAOSINSTANCE 