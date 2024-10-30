# Deployment of Automation Setup for Windows Networked PCs using PowerShell

## Prepare and Securely Store Credentials in `credentials.xml`

- **Create an XML credential file**  
Replace the following placeholders:
    - `YourPassword`
    - `YourUsername`
    - Path to the XML file

```powershell
# Define UserID and Password
$userID = "YourUserID"
$password = "YourPassword"

# Use the credentials to log into the application or perform actions
# Example of using credentials to log into a hypothetical application

# Load assembly required to send keystrokes
Add-Type -AssemblyName System.Windows.Forms

# Simulate opening an application (replace with your actual application executable path)
Start-Process "C:\Path\To\Application.exe"

# Wait for the application to load
Start-Sleep -Seconds 5

# Send the UserID and Password, pressing Enter after each
[System.Windows.Forms.SendKeys]::SendWait("$UserID{ENTER}")
[System.Windows.Forms.SendKeys]::SendWait("$Password{ENTER}")

# Use Shift+Tab to navigate to the "More" button
[System.Windows.Forms.SendKeys]::SendWait("+{TAB}+{TAB}{ENTER}")

# Navigate to "Training Mode On/Off" button
[System.Windows.Forms.SendKeys]::SendWait("+{TAB}+{TAB}+{TAB}{ENTER}")

# Enter UserID and Password again if necessary
[System.Windows.Forms.SendKeys]::SendWait("$UserID{ENTER}")
[System.Windows.Forms.SendKeys]::SendWait("$Password{ENTER}")

# Continue with additional scripted actions
# Replace the placeholder actions with actual commands for further navigation and interaction
