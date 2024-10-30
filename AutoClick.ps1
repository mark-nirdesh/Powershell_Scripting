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





# Adding C# code to PowerShell to use native mouse and keyboard functionalities
Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public static class MouseOperations {
        [DllImport("user32.dll", EntryPoint = "SetCursorPos")]
        public static extern bool SetCursorPosition(int X, int Y);

        [DllImport("user32.dll")]
        public static extern void mouse_event(int dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);

        public const int MOUSEEVENTF_LEFTDOWN = 0x02;
        public const int MOUSEEVENTF_LEFTUP = 0x04;

        public static void PerformClick(int x, int y) {
            SetCursorPosition(x, y);
            mouse_event(MOUSEEVENTF_LEFTDOWN | MOUSEEVENTF_LEFTUP, x, y, 0, 0);
        }
    }
"@ 

# Function to move the mouse to a position and click
function Click-AtPosition {
    param (
        [int]$x,
        [int]$y
    )
    [MouseOperations]::PerformClick($x, $y)
    Start-Sleep -Milliseconds 100
}

# Assuming the application is already running, use Alt+Tab to focus
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("%{TAB}")
Start-Sleep -Seconds 1

# Example positions for clicks - these need to be adjusted to your specific needs
# You may need to find these coordinates manually as described before
Click-AtPosition -x 1847 -y 79  # Example: Clicks at position x=500, y=300
 # Example: Next click position

# Additional actions can be scripted below using the Click-AtPosition function


