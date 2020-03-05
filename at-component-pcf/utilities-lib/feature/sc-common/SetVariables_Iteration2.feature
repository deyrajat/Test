############################################################################################
# Date: <06/07/2018> Version: <Initial version: 18.0> $1Create by <bhchauha>
############################################################################################
##Overwrite the Variables to handle implementation of common script for HA and GR

Feature: Iteration2_checks

  Scenario: Capturing KPI values for 2nd iteration stabilization period 
  
    Given I expect the next test step to execute if '("{Config.sut.setup.deployment.type}" == "PUPPETQNSHA")'
        Given I define the following constants:
          | name          | value |
          | varx          |  2    | 
    
    Given I expect the next test steps to execute otherwise
        Given I expect the next test step to execute if '("{Config.sut.setup.deployment.type}" == "PUPPETQNSGR" && {Constant.sitestobevalidated} == 2 && {Constant.channelIndex} == 1)'
        #Given I expect the next test step to execute if {Constant.sitestobevalidated}==2
        #Given I expect the next test step to execute if {Constant.channelIndex}==1
            Given I define the following constants:
              | name          | value |
  		      | varx          |  2    |
        Given I expect the next test steps to execute otherwise
            Given I expect the next test step to execute if '("{Config.sut.setup.deployment.type}" == "PUPPETQNSGR" && {Constant.sitestobevalidated} == 2 && {Constant.channelIndex} == 2)'
            #Given I expect the next test step to execute if {Constant.sitestobevalidated}==2
            #Given I expect the next test step to execute if {Constant.channelIndex}==2
                Given I define the following constants:
  		           | name          | value |
  		           | varx          |  1    |
            Given I end the if
        Given I end the if
    Given I end the if
   
  ### Initialize the setup 2 values
  When I execute the SSH command "echo 0" at SITEHOST
  Then I save the SSH response in the following variables:
      | attribute     | value     |
      | (.*) 			| TotalTPSOne{Constant.varx} |
      | (.*) 			| TotalLDAPTPSOne{Constant.varx} |
      | (.*) 			| TotalLDAPModifyTPSOne{Constant.varx} |
      | (.*) 			| TotalLDAPAddTPSOne{Constant.varx} |
      | (.*) 			| TotalPLFTPSOne{Constant.varx} |
      | (.*) 			| TotalNAPTPSOne{Constant.varx} |
      | (.*) 			| N7CreateTPSOne{Constant.varx} |
      | (.*) 			| N7UpdateTPSOne{Constant.varx} |
      | (.*) 			| N7DeleteTPSOne{Constant.varx} |
      | (.*)      | N28NotifyTPSOne{Constant.varx} |
      | (.*) 			| RxRARTPSOne{Constant.varx} |
      | (.*) 			| RxAARTPSOne{Constant.varx} |
      | (.*) 			| RxASRTPSOne{Constant.varx} |
      | (.*) 			| RxSTRTPSOne{Constant.varx} |
