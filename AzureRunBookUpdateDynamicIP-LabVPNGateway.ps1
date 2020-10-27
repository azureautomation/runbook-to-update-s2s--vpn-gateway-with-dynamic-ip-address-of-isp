<#	
	.NOTES
	 Created on:   	21/03/2015 18:28
	 Created by:   	Didier Van Hoye
	 Organization:  WorkingHardInIT
     Blogs: http://blog.workinghardinit.work & http:/workinghardinit.wordpress.com
	 Purpose:     	Azure Scheduled Runbook To Update
					Dynamic IP Address site-to-site VPN
#>

workflow updatedynipvpn
{
    <#
    Connect to my subscription. I have set up an automation account for this.
	See for more infor on how to do this.
    #>
	$Cred = Get-AutomationPSCredential -name "user@youraccount.onmicrosoft.com"
	Add-AzureAccount –Credential $Cred
	$AzureSubscriptionName = "Visual Studio Ultimate with MSDN" #change to your. I'm using my MSDN benefits in the lab.
	Write-Output "Connecting to subscription:  $AzureSubscriptionName"
	Select-AzureSubscription -SubscriptionName $AzureSubscriptionName
	
	inlinescript
	{	
    	<#
    	Grab the current dynamic IP address of my home lab via the FQDN
    	registered for this purpose with my free dynamic IP provider 
    	#>
		$DynDNS = "mydynamicdnsname.dynamic-dns.net" #change to yours
		#Get IP based on the Domain Name
		[string]$MyDynamicIP = ([System.Net.DNS]::GetHostAddresses($DynDNS)).IPAddressToString
		write-output "Your current dynamic local VPN IP is: $MyDynamicIP"
				
		#Read the current network configuration & dumpt it into an XML variable
		$XML = Get-AzureVNetConfig
		[xml]$ReadCurrentAzureVNetConfig = $XML.XMLConfiguration
		
		#the name of the local network I want to update. Very important if you have more than one.
		$MyLocalSoHoNetworkInAzure = "yourlocalnetworkname"
		
		#Get the IP addres of the VPN gateway for the specified local network
		[string]$MyAzureVPNGatewayIP = ($ReadCurrentAzureVNetConfig.DocumentElement.VirtualNetworkConfiguration.LocalNetworkSites.LocalNetworkSite | where { $_.name -eq $MyLocalSoHoNetworkInAzure }).VPNGatewayaddress
		write-output "Current Azure VPN Gateway Address IP for $MyLocalSoHoNetworkInAzure is :  $MyAzureVPNGatewayIP"
					
		#Check if you need to update your Azure VPN Gateway IP address
		if ($MyDynamicIP -ne $MyAzureVPNGatewayIP)
		{
			#You have a new dynamic IP address so you'll update the local network VPN gateway in Azure
			Write-Output "Updating your Local Network $MyLocalSoHoNetworkInAzure VPN Gateway Address ..."
			
			#Update the configuration in our XML variable
			($ReadCurrentAzureVNetConfig.DocumentElement.VirtualNetworkConfiguration.LocalNetworkSites.LocalNetworkSite | where { $_.name -eq $MyLocalSoHoNetworkInAzure }).VPNGatewayaddress = $MyDynamicIP
			
			<#
   			Create a temp file to pass the adjusted config to Set-AzureVNetConfig,
   			which require a file for the mandatory -ConfigurationPath parameter
			Thanks for the tip Stijn Callebaut!
    		#>
			$NewAzureVNetConfigFile = [System.IO.Path]::GetTempFileName()
			
			#Update the configuration file to the temp file ... we need this as we need to pass a file to Set-AzureVNetConfig
			$ReadCurrentAzureVNetConfig.Save("$NewAzureVNetConfigFile")
			
			#Update your virtual network settings
			$ReturnValue = Set-AzureVNetConfig -ConfigurationPath $NewAzureVNetConfigFile
			
			if ($ReturnValue.OperationStatus -eq "Succeeded")
			{
				Write-Output "SUCCESS! Your Local Network $MyLocalSoHoNetworkInAzure VPN Gateway Address was updated ."
				Write-Output "$MyLocalSoHoNetworkInAzure VPN Gateway Address was updated from $MyAzureVPNGatewayIP to $MyDynamicIP"
			}
			else
			{
				Write-Output "FAILURE! Your Local Network $MyLocalSoHoNetworkInAzure VPN Gateway Address was NOT updated."
			}
			
		}
		else
		{
			#You did not get a new dynamic IP yet, nothing to do
			Write-Output "Nothing to do! Your Local Network $MyLocalSoHoNetworkInAzure VPN Gateway Address is already up to date."
		}
	}
}

