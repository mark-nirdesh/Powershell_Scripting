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

## Powershell script to restart multiple PCs at same time

- 
    
    > Change IPaddress
    
    ```powershell
                # Path to the file containing the list of IP addresses
                $ipFilePath = "C:\path\to\ip.txt"

                # Read the IP addresses from the file into a variable
                $computers = Get-Content $ipFilePath

                # Prompt for credentials to connect to the remote machines
                $credential = Get-Credential

                # Loop through each IP address and restart them
                foreach ($computer in $computers) {
                try {
                        # Print message to indicate restart is starting
                        Write-Host "Attempting to restart $computer..."

                        # Restart the computer using the IP address
                        Restart-Computer -ComputerName $computer -Force -Credential $credential -ErrorAction Stop

                        # Print success message
                        Write-Host "$computer has been successfully restarted."
                        }
            catch {
                # Print error message if restart fails
                Write-Host "Failed to restart $computer. Error: $_" -ForegroundColor Red
                }
                                            }

                    # Final message
                    Write-Host "All restart commands have been sent."

    ```
    
    > `This script will restart Computer1, Computer2, and Computer3 immediately (/r for restart, /t 0 to restart with no             delay).`
    > 
        
## Powershell script to Shutdown multiple PCs at the same time

- 
    
    > Change IPaddress
    
    ```powershell
                   # Path to the file containing the list of IP addresses
                    $ipFilePath = "C:\path\to\ip.txt"

                    # Read the IP addresses from the file into a variable
                    $computers = Get-Content $ipFilePath

                    # Prompt for credentials to connect to the remote machines
                    $credential = Get-Credential

                    # Loop through each IP address and shut them down
                    foreach ($computer in $computers) {
                    try {
                            # Print message to indicate shutdown is starting
                            Write-Host "Attempting to shut down $computer..."

                            # Shut down the computer using the IP address
                            Stop-Computer -ComputerName $computer -Force -Credential $credential -ErrorAction Stop

                            # Print success message
                            Write-Host "$computer has been successfully shut down."
                    }
                    catch {
                    # Print error message if shutdown fails
                    Write-Host "Failed to shut down $computer. Error: $_" -ForegroundColor Red
                    }
                    }

                    # Final message
                    Write-Host "All shutdown commands have been sent."


    ```
    
    > `This script will shutdown the PC mentioned in the IP.txt files  immediately.`
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
    
   
    ```powershell
               # Define the path to the IP addresses file
        $ipListFile = "C:\Users\Helheim\Desktop\ip_addresses.txt"

        # Read the IP addresses from the file
        $ipAddresses = Get-Content -Path $ipListFile

        # Define the username and password
        $username = ""
        $password = ""

        # Open RDP for each IP address
        foreach ($ip in $ipAddresses) {
        # Create a secure string for the password
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force

        # Create a credential object
        $credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)

        # Start RDP session
        mstsc /v:$ip
                                    }

    ```
     > `This script will start the RDP-GUI connection with Username and Password given..`
     >


## Make the static Static IP based on the Device Name = NetworkDevices.csv

- Copy and paste this Powershell script to each till and execute.
    
    Nothing to Change 
    
    ```powershell
       # Get the current computer's device name (hostname)
        $deviceName = (Get-ComputerInfo).CsName

        # Define the IP configuration based on the device name format "NLUK0XXXXT00Y"
        if ($deviceName -match "^NLUK0(\d{2})(\d{2})T00(\d)$") {
        $xx = $matches[1]  # Extract the first 2 digits for XX
        $yy = $matches[2]  # Extract the second 2 digits for YY
        $y = $matches[3]   # Extract the Y digit for the last octet

        # Construct the static IP based on the format 10.XX.YY.Y
        $staticIP = "10.$xx.$yy.$y"
        $subnetMask = "255.255.255.0"
        $defaultGateway = "10.$xx.$yy.100"  # Default gateway based on XX and YY, ending in .100
        $preferredDNS = "10.96.200.170"
        $alternateDNS = "10.80.205.18"

        # Get the Ethernet adapter (only the Ethernet interface, no Wi-Fi or virtual adapters)
        $ethernetAdapter = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like "*Ethernet*" -and $_.Status -eq "Up" } | Select-Object -First 1

        if ($ethernetAdapter) {
        $interfaceIndex = $ethernetAdapter.ifIndex

        # Check if the IP already exists on the interface
        $existingIP = Get-NetIPAddress -InterfaceIndex $interfaceIndex -AddressFamily IPv4 | Where-Object { $_.IPAddress -eq $staticIP }

        # Remove the existing IP address if it matches the static IP
        if ($existingIP) {
            Remove-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress $existingIP.IPAddress -Confirm:$false
            Write-Host "Removed existing IP address: $($existingIP.IPAddress)"
        }

        # Set the static IP address, subnet mask, and default gateway for the Ethernet adapter
        New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress $staticIP -PrefixLength 24 -DefaultGateway $defaultGateway

        # Set the preferred and alternate DNS servers
        Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses $preferredDNS, $alternateDNS

        Write-Host "Static IP configuration applied to Ethernet: $staticIP on device $deviceName"
        } else {
        Write-Host "No active Ethernet adapter found on $deviceName"
        }
        } else {
        Write-Host "Device name does not match the required format: NLUK0XXXXT00Y"
        }
    ```
    
    > `This Script will does the static IP of PC and it will disconnect from RDP.`
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
