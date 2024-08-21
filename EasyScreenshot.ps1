# Save this as EasyScreenshot.ps1 in C:\Windows\System32

# Define the output file path
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$outputFile = [System.IO.Path]::Combine($env:USERPROFILE, 'Pictures', "Screenshot_$timestamp.png")

# Take the screenshot
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

# Ensure the directory exists before saving
$directory = [System.IO.Path]::GetDirectoryName($outputFile)
if (-not (Test-Path -Path $directory)) {
    New-Item -ItemType Directory -Path $directory -Force
}

# Create the screenshot bitmap
$screenshot = New-Object Drawing.Bitmap $bounds.Width, $bounds.Height
$graphics = [Drawing.Graphics]::FromImage($screenshot)

try {
    $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.Size)
    
    # Workaround for GDI+ error: save to a MemoryStream first, then to a file
    $memoryStream = New-Object System.IO.MemoryStream
    $screenshot.Save($memoryStream, [System.Drawing.Imaging.ImageFormat]::Png)
    $memoryStream.WriteTo([System.IO.File]::OpenWrite($outputFile))
    
    # Notify the user
    [System.Windows.Forms.MessageBox]::Show("Screenshot saved to $outputFile")
} catch {
    [System.Windows.Forms.MessageBox]::Show("Failed to save screenshot: $_")
} finally {
    $graphics.Dispose()
    $screenshot.Dispose()
}
