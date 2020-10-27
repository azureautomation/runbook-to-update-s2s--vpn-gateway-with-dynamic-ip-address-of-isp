Runbook to update S2S  VPN Gateway with dynamic IP address of ISP
=================================================================

            

When you’re connecting a home (or perhaps even an office) lab to Azure with a site-2-site VPN you’ll probably have to deal with the fact that you have a dynamic IP assigned by your ISP. This means unless you update the VPN Gateway Address
 of your Azure local network in some automated way, your connection is down very often.


A fellow MVP of mine ([Christopher Keyaert](http://www.vnext.be/author/christopher/)) has written
[a PowerShell script](http://www.vnext.be/2013/12/01/windows-azure-s2s-vpn-with-dynamic-public-ip/) that a few years back that updated the VPN gateway address of your Azure local network via a scheduled task inside of his Windows RRAS VM. Any VM, either in Azure or in your lab will do. Good stuff! If you need inspiration for a script
 you have a link. But, I never liked the fact that keeping my Azure site-to-site VPN up and running was tied to a VM being on line in Azure or in my lab, which is also why I switched to a SonicWALL device. Since we have Azure Automation runbooks at our disposal
 I decided to automate the updating of the VPN gateway address to the dynamic IP address of my ISP using a runbook.


 

 

**Finding out your dynamic IP address from anywhere in the world**


For this to work you need a way to find out what your currently assigned dynamic IP is. For that I subscribe to a free service providing dynamic DNS updates. I use

https://www.changeip.com/. That means that by looking up the FQDN is find can out my current dynamic IP address form where ever I have internet access. As my SonicWALL supports dynamic DNS services providers I can configure it there, no need for an update
 client running in a VM or so.


**The runbook to update the VPN Gateway Address of your Azure local network
**


I will not deal with how to set up Azure Automation, just follow this [link](http://azure.microsoft.com/blog/2014/08/27/azure-automation-authenticating-to-azure-using-azure-active-directory/). I will share a little hurdle I needed to take. At least for me it was a hurdle. That hurdle was that the
*Set-AzureVNetConfig* cmdlet which we need has a mandatory parameter *-ConfigurationPath* which reads the configuration to set from an XML file (see

Azure Virtual Network Configuration Schema).


You cannot just use a file path in an Azure runbook to dump a file on c:\temp for example. Using an Azure file share seems overly complicated for this job. After pinging some fellow MVPs at
[Inovativ Belgium](http://www.inovativ.be/) who are deep into Azure automation on a daily basis,
[Stijn Callebaut](https://twitter.com/stijnca) gave me the tip to use
*[System.IO.Path]::GetTempFileName() *and that got my script working. Thank you Stijn !


So I now have a scheduled runbook that automatically updates my to the dynamic IP address my ISP renews every so often without needing to have a script running scheduled inside a VM. I don’t always need a VM running but I do need that VPN to be there
 for other use cases. This is as elegant of a solution that I could come up with.


I test the script before publishing & scheduling it by setting the VPN Gateway Address of my Azure local network to a wrong IP address in order to see whether the runbook changes it to the current one it got from my dynamic IP.





Now publish it and have it run x times a day … depending on how aggressive your ISP renews your IP address and how long your lab can sustain the Azure site-to-site VPN to be down. I do it hourly. Not a production ready solution, but neither is a dynamic
 IP and this is just my home lab! Now my VPN looks happy most of the time automatically





![Image](https://github.com/azureautomation/runbook-to-update-s2s--vpn-gateway-with-dynamic-ip-address-of-isp/raw/master/azurerunbookdynamicip.png)


[](http://blog.workinghardinit.work/wp-content/uploads/2015/03/image18.png)




        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
