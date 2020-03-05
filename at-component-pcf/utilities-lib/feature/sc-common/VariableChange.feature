#################################################################################################
# Date: <15/12/2017> Version: <Initial version: 18.0> $1Create by <Sandeep Talukdar, santaluk>
# Date: <04/07/2018> Version: <Updated version: 18.3> $1Updatede by <bhchauha>
#################################################################################################
##Overwrite the Variables for iteration validation 

@ChangeVariable

Feature: Benchmark_Capture

Scenario: Capture Benchmark Values

Given I execute the steps from {config.global.workspace.library.location-features-validations-common}CommonFile.feature

Given I loop {Constant.loopCount} times

    ##Capturing 1st Benchmark

   	Given I define the following constants:
	      | name                                    | value                    |
	      | TotalTPS1{Constant.channelIndex}        | {SSH.TotalTPSTwo{Constant.channelIndex}}        |
   		  | TotalLDAPTPS1{Constant.channelIndex}     | {SSH.TotalLDAPTPSTwo{Constant.channelIndex}}    |	
   		  | N7CreateTPS1{Constant.channelIndex}       | {SSH.N7CreateTPSTwo{Constant.channelIndex}}       |
   		  | N7UpdateTPS1{Constant.channelIndex}       | {SSH.N7UpdateTPSTwo{Constant.channelIndex}}       |
   		  | N7DeleteTPS1{Constant.channelIndex}       | {SSH.N7DeleteTPSTwo{Constant.channelIndex}}       |
   		  
   		  
	When I execute the SSH command "echo {Constant.TotalTPS1{Constant.channelIndex}}" at SITEHOST
	Then I save the SSH response in the following variables:
	     | attribute | value           |
	     | (.*)      | TotalTPSOne{Constant.channelIndex}     |	
	    
	When I execute the SSH command "echo {Constant.TotalLDAPTPS1{Constant.channelIndex}}" at SITEHOST
	Then I save the SSH response in the following variables:
	     | attribute | value               |
	     | (.*)      | TotalLDAPTPSOne{Constant.channelIndex}     |	
	     
	When I execute the SSH command "echo {Constant.N7CreateTPS1{Constant.channelIndex}}" at SITEHOST
	Then I save the SSH response in the following variables:
	     | attribute | value            |
	     | (.*)      | N7CreateTPSOne  {Constant.channelIndex}   |	
	     
	When I execute the SSH command "echo {Constant.N7UpdateTPS1{Constant.channelIndex}}" at SITEHOST
	Then I save the SSH response in the following variables:
	     | attribute | value            |
	     | (.*)      | N7UpdateTPSOne{Constant.channelIndex}     |	
	     
	When I execute the SSH command "echo {Constant.N7DeleteTPS1{Constant.channelIndex}}" at SITEHOST
	Then I save the SSH response in the following variables:
	     | attribute | value            |
	     | (.*)      | N7DeleteTPSOne{Constant.channelIndex}     |
	     
	########## Additional TPS check Added by Sandeep Talukdar #################

   	Given I define the following constants:
	      | name                                   | value                   |
   		  | SySLRTPS1{Constant.channelIndex}       | {SSH.SySLRTPSTwo{Constant.channelIndex}}       |
   		  | SySNRTPS1{Constant.channelIndex}       | {SSH.SySNRTPSTwo{Constant.channelIndex}}       |
   		  | SySTRTPS1{Constant.channelIndex}       | {SSH.SySTRTPSTwo{Constant.channelIndex}}       |	
   		  | ShUDRTPS1{Constant.channelIndex}       | {SSH.ShUDRTPSTwo{Constant.channelIndex}}       |
   		  
	When I execute the SSH command "echo {Constant.SySLRTPS1{Constant.channelIndex}}" at SITEHOST
	Then I save the SSH response in the following variables:
	     | attribute | value           |
	     | (.*)      | SySLRTPSOne{Constant.channelIndex}     |	
	     
	When I execute the SSH command "echo {Constant.SySNRTPS1{Constant.channelIndex}}" at SITEHOST
	Then I save the SSH response in the following variables:
	     | attribute | value           |
	     | (.*)      | SySNRTPSOne{Constant.channelIndex}     |	
	     
	When I execute the SSH command "echo {Constant.SySTRTPS1{Constant.channelIndex}}" at SITEHOST
	Then I save the SSH response in the following variables:
	     | attribute | value           |
	     | (.*)      | SySTRTPSOne{Constant.channelIndex}     |	
	     
	When I execute the SSH command "echo {Constant.ShUDRTPS1{Constant.channelIndex}}" at SITEHOST
	Then I save the SSH response in the following variables:
	     | attribute | value           |
	     | (.*)      | ShUDRTPSOne{Constant.channelIndex}     |	
	
	
    ######### Additional TPS check Added by Sandeep Talukdar #################
    
    Given I define the following constants:
        | name                                    | value                                     |
        | GyCCRITPS1{Constant.channelIndex}       | {SSH.GyCCRITPSTwo{Constant.channelIndex}} |
   		| GyCCRUTPS1{Constant.channelIndex}       | {SSH.GyCCRUTPSTwo{Constant.channelIndex}} |
   		| GyCCRTTPS1{Constant.channelIndex}       | {SSH.GyCCRTTPSTwo{Constant.channelIndex}} |
   		| NpNRRTPS1{Constant.channelIndex}        | {SSH.NpNRRTPSTwo{Constant.channelIndex}}  |
   		
    When I execute the SSH command "echo {Constant.GyCCRITPS1{Constant.channelIndex}}" at SITEHOST
	Then I save the SSH response in the following variables:
	     | attribute | value            |
	     | (.*)      | GyCCRITPSOne  {Constant.channelIndex}   |	
	     
	When I execute the SSH command "echo {Constant.GyCCRUTPS1{Constant.channelIndex}}" at SITEHOST
	Then I save the SSH response in the following variables:
	     | attribute | value            |
	     | (.*)      | GyCCRUTPSOne{Constant.channelIndex}     |	
	     
	When I execute the SSH command "echo {Constant.GyCCRTTPS1{Constant.channelIndex}}" at SITEHOST
	Then I save the SSH response in the following variables:
	     | attribute | value            |
	     | (.*)      | GyCCRTTPSOne{Constant.channelIndex}     |
	     
	When I execute the SSH command "echo {Constant.NpNRRTPS1{Constant.channelIndex}}" at SITEHOST
	Then I save the SSH response in the following variables:
	     | attribute | value            |
	     | (.*)      | NpNRRTPSOne{Constant.channelIndex}     |
    
  Then I increment Constant.channelIndex by 1
  And I end loop