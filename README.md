# Deployment of Automation Setup for Windows Networked PCs using Powershell

## Prepare and Securely Store Credentials = credentials.xml

- Create an XML credential file
    
    > Change YourPassword
    > Change YourUsername
    > Change Path to xml file
    
    ```powershell
    $username = "YourUsername"
    $password = ConvertTo-SecureString "YourPassword" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($username, $password)
    $cred | Export-CliXml -Path "C:\path\to\credentials.xml"
    ```
    
    > `This file stores your credentials securely and can only be decrypted by the same user on the same machine.`
    > 

## Create the Excel File for IP_address & MAC_address = NetworkDevices.csv

- Find the IP address and populate the ARP table
    
    Change lines 3,4 : ” $startRange = 1 $endRange = 254” range if you estimate the range and save time
    Change line 2 : ” $baseIP = “10.88.18.” for appropriate network.
    
    ```powershell
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
    ```powershell
    # Define the base IP and subnet
$baseIP = "10.88.18."
$startRange = 1
$endRange = 254

# Create a list of IP addresses
$ipList = for ($i = $startRange; $i -le $endRange; $i++) {
    "$baseIP$i"
}

# Use parallel processing to ping IPs
$ipList | ForEach-Object -Parallel {
    $currentIP = $_
    $pingResult = Test-Connection -ComputerName $currentIP -Count 1 -Quiet

    # Output the result
    if ($pingResult) {
        "$currentIP is reachable."
    } else {
        "$currentIP is not reachable."
    }
} -ThrottleLimit 50  # Adjust the throttle limit based on system resources

   ```
    > `This Script pings each IP once; you can modify the`-Count`parameter to increase the number of ping attempts.   The Script will not ping the network and broadcast addresses (`10.88.18.0`and`10.88.18.255) `which are typically not assigned to hosts.`
    > 
- Get the ARP table content and store it in an Excel file with “IP_address” and “MAC_address” columns
    
    > Change line 2 : Output file path
    > Change line 8 : the IPaddress for ARP scan
    
    ```powershell
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
                IP  = $matches[1]
                MACAddress = $matches[2]
            }
            $networkDevices += $device
        }
    }
    
    # Export the results to a CSV file
    $networkDevices | Export-Csv -Path $outputFile -NoTypeInformation
    
    Write-Host "IP and MAC addresses have been saved to $outputFile"
    ```
    
    > `This script uses `arp -a` command to retrieve the ARP table, which contains IP address-to-MAC address mappings store it into excel file at changed directory.`
    > 
    
   
    

## Installs necessary modules on the Host machine  = prerequisite.ps1

<aside>
💡

Run this script with ADMIN privileges.

</aside>

- SetupPrerequisite.ps1
    
    ```powershell
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
    
    ![success](https://github.com/user-attachments/assets/d2b76b7c-2583-4fac-8ec7-eae3a192de1d)

    
    This output should you get!
    

## Create the PreDeployment Script = PreDeployScript.ps1

- For installing Prerequisite on the desired IP address (always modify the file NetworkDevices.csv )
    
    > `It is easy to put all the files in one folder.`
    > Change line 4: path to `NetworkDevices.csv`
    > Change line 8: path to `prerequisite.ps1`
    > Change line 11: path to `credentials.xml`
    
    ```powershell
    # Import the ImportExcel module
    Import-Module ImportExcel
    
    # Path to the Excel file
    $excelFilePath = "C:\path\to\NetworkDevices.csv"
    
    # Path to the setup script
    $setupScriptPath = "C:\path\to\prerequisite.ps1"
    
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
    
    > `Script reads the IP addresses from the Excel file :` NetworkDevices.csv `, retrieves the stored` “IP_address” `, and executes` prerequisite.ps1 `on each remote machine.`
    > 

## Execute the Deployment

<aside>
💡Run the Deployment Script

- Open PowerShell as an administrator.
- Execute the deployment script:
</aside>

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
.\PreDeployScript.ps1
```

## Summary

- **Credentials**: Stored securely in `credentials.xml` for remote access.
- **Setup Script**: `prerequisite.ps1` installs necessary modules.
- **Deployment Script**: `PreDeployScript.ps1` automates the execution of `prerequisite.ps1` on each machine listed in the Excel file using the stored credentials on `credentials.xml`.
- **Execution**: Run the `DeployScript.ps1` to deploy the setup script across multiple machines, using IP addresses from the Excel file.
