# **<u>Deployment Automation Setup for Windows Networked PCs in Powershell</u>**
## Prepare and Securely Store Credentials
- Create a XML credential file 
	> 📌
	> Change YourPassword
	> Change YourUsername
	> Change Path to xml file

	```
	$username = "YourUsername"
	$password = ConvertTo-SecureString "YourPassword" -AsPlainText -Force
	$cred = New-Object System.Management.Automation.PSCredential ($username, $password)
	$cred | Export-CliXml -Path "C:\path\to\credentials.xml"
	```
	> This file stores your credentials securely and can only be decrypted by the same user on the same machine.
## Create the Excel File for IP_address & MAC_address
- Find the IP address and popolate the ARP table 
	- Change line 3,4 : " $startRange = 1 $endRange = 254
"  range if you estimate the range and save time
	Change line 2        : " $baseIP = "10.88.18." for appropriate network.
		```
		# Define the base IP and subnet
		$baseIP = "10.88.18."
		$startRange = 1
		$endRange = 254
		
		# Loop through all possible IPs in the subnet
		for ($i = $startRange; $i -le $endRange; $i++) {
		    $currentIP = "$baseIP$i"
		    # Test the connection (ping) and select only the StatusCode property
		    $pingResult = Test-Connection -ComputerName $currentIP -Count 1 -Quiet
		
		    # Check if the ping was successful
		    if ($pingResult) {
		        Write-Output "$currentIP is reachable."
		    } else {
		        Write-Output "$currentIP is not reachable."
		    }
		}

		```
		> This Script pings each IP once; you can modify the `-Count` parameter to increase the number of ping attempts.
		The Script will not ping the network and broadcast addresses (`10.88.18.0` and `10.88.18.255`), which are typically not assigned to hosts. 
- Get the ARP table content and store it in excel file with "IP_address" and "MAC_address" columns 
	> 📌
	> Change line 2 : Output file path 
	> Change line 8 : the IPaddress for ARP scan

	```
	# Output file path
	$outputFile = "C:\path\to\output\NetworkDevices.csv"

	# Initialize an empty array to store results
	$networkDevices = @()

	# Run the arp command and capture the output
	$arpTable = arp -a -N 10.88.18.__

	# Parse the output to extract IP and MAC addresses
	$arpTable | ForEach-Object {
	    if ($_ -match "(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+([a-fA-F0-9-]{17})") {
	        $device = [PSCustomObject]@{
	            IPAddress  = $matches[1]
	            MACAddress = $matches[2]
	        }
	        $networkDevices += $device
	    }
	}

	# Export the results to a CSV file
	$networkDevices | Export-Csv -Path $outputFile -NoTypeInformation

	Write-Host "IP and MAC addresses have been saved to $outputFile"
	```> This script uses `arp -a` command to retrieve the ARP table, which contains IP address-to-MAC address mappings store it into excel file at changed directory.
	```
	# Check if running as Administrator
	If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
	    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
	    exit
	}
	
	# Install ImportExcel module
	Write-Host "Installing ImportExcel module..."
	Install-Module -Name ImportExcel -Scope CurrentUser -Force -Confirm:$false -SkipPublisherCheck
	
	# Install Selenium module
	Write-Host "Installing Selenium module..."
	Install-Module -Name Selenium -Scope CurrentUser -Force -Confirm:$false -SkipPublisherCheck
	
	# Download Microsoft Edge WebDriver
	Write-Host "Downloading Microsoft Edge WebDriver..."
	$webDriverUrl = "https://msedgedriver.azureedge.net/114.0.1823.79/edgedriver_win64.zip"
	$outputPath = "C:\WebDriver"
	$outputFile = "$outputPath\edgedriver.zip"
	
	# Create directory for WebDriver if it doesn't exist
	if (-Not (Test-Path -Path $outputPath)) {
	    New-Item -ItemType Directory -Path $outputPath
	}
	
	Invoke-WebRequest -Uri $webDriverUrl -OutFile $outputFile
	Write-Host "Extracting WebDriver..."
	Expand-Archive -Path $outputFile -DestinationPath $outputPath -Force
	
	# Add WebDriver to system PATH
	$env:Path += ";$outputPath"
	[System.Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
	
	Write-Host "Setup completed successfully!"

	```## Install Prerequisite on HOST machine to deploy the script
- just run it with ADMIN privileges .
	```
	# Check if running as Administrator
	If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
	    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
	    exit
	}
	
	# Install ImportExcel module
	Write-Host "Installing ImportExcel module..."
	Install-Module -Name ImportExcel -Scope CurrentUser -Force -Confirm:$false -SkipPublisherCheck
	
	# Install Selenium module
	Write-Host "Installing Selenium module..."
	Install-Module -Name Selenium -Scope CurrentUser -Force -Confirm:$false -SkipPublisherCheck
	
	# Download Microsoft Edge WebDriver
	Write-Host "Downloading Microsoft Edge WebDriver..."
	$webDriverUrl = "https://msedgedriver.azureedge.net/114.0.1823.79/edgedriver_win64.zip"
	$outputPath = "C:\WebDriver"
	$outputFile = "$outputPath\edgedriver.zip"
	
	# Create directory for WebDriver if it doesn't exist
	if (-Not (Test-Path -Path $outputPath)) {
	    New-Item -ItemType Directory -Path $outputPath
	}
	
	Invoke-WebRequest -Uri $webDriverUrl -OutFile $outputFile
	Write-Host "Extracting WebDriver..."
	Expand-Archive -Path $outputFile -DestinationPath $outputPath -Force
	
	# Add WebDriver to system PATH
	$env:Path += ";$outputPath"
	[System.Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
	
	Write-Host "Setup completed successfully!"
	```
	![](https://beta.appflowy.cloud/api/file_storage/e7f64db9-313b-4f7c-abe7-f1f18b953afe/v1/blob/0c0551bf%2Dc8d8%2D46d1%2Da697%2D36e882d1f761/17526498387675011262.PNG)
	This output should you get!
## Create the Deployment Script
- For installing Prerequisite on desired IPaddress (always modify the file NetworkDevices.csv ) 
	> 📌
	> `It is easy if put all the files in one folder.`
	> Change line 4  : path to `NetworkDevices.csv`
	> Change line 8  : path to `prerequisite.ps1`
	> Change line 11: path to `credentials.xml`

	```
	# Import the ImportExcel module
	Import-Module ImportExcel
	
	# Path to the Excel file
	$excelFilePath = "C:\path\to\NetworkDevices.csv"
	
	# Path to the setup script
	$setupScriptPath = "C:\path\to\SetupAutomation.ps1"
	
	# Path to the credentials file
	$credFilePath = "C:\path\to\credentials.xml"
	
	# Import credentials
	$cred = Import-CliXml -Path $credFilePath
	
	# Read the IP addresses from the Excel file
	$ipAddresses = Import-Excel -Path $excelFilePath | Select-Object -ExpandProperty IP
	
	# Loop through each IP address and run the setup script
	foreach ($ip in $ipAddresses) {
	    Write-Host "Deploying to $ip..."
	
	    Invoke-Command -ComputerName $ip -Credential $cred -ScriptBlock {
	        param($setupScriptPath)
	
	        # Ensure the execution policy is set
	        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
	
	        # Execute the setup script
	        & $setupScriptPath
	    } -ArgumentList $setupScriptPath -ErrorAction Stop
	}
	
	Write-Host "Deployment completed on all machines."

	```
	> Script reads the IP addresses from the Excel file : `NetworkDevices.csv`  , retrieves the stored  "IP_address" , and executes `prerequisite.ps1` on each remote machine.
## Execute the Deployment

