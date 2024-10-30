# Define UserID and Password
$userID = "YourUserID"
$password = "YourPassword"

# Use the credentials to log into the application or perform actions
# Example of using credentials to log into a hypothetical application

# Load assembly required to send keystrokes
Add-Type -AssemblyName System.Windows.Forms

# Simulate opening an application (replace with your actual application executable path)
Start-Process "C:\Windows\notepad.exe"

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




Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-MousePosition {
    $Point = [System.Windows.Forms.Cursor]::Position
    return "$($Point.X), $($Point.Y)"
}

while ($true) {
    $position = Get-MousePosition
    Write-Host "Mouse position: $position"
    Start-Sleep -Milliseconds 500
}
