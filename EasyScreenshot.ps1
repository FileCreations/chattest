# Save this as EasyScreenshot.ps1 in C:\Windows\System32

# Define the output file path
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$outputFile = "$env:USERPROFILE\Pictures\Screenshot_$timestamp.png"

# Take the screenshot
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$screenshot = New-Object Drawing.Bitmap $bounds.Width, $bounds.Height
$graphics = [Drawing.Graphics]::FromImage($screenshot)
$graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.Size)
$screenshot.Save($outputFile, [System.Drawing.Imaging.ImageFormat]::Png)

# Notify the user
[System.Windows.Forms.MessageBox]::Show("Screenshot saved to $outputFile")
