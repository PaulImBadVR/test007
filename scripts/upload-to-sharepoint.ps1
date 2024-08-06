# Define variables
$siteUrl = $env:SHAREPOINT_SITE_URL
$username = $env:SHAREPOINT_USERNAME
$password = $env:SHAREPOINT_PASSWORD
$folderPath = "Shared Documents/YourFolder" # Change this to your SharePoint folder path
$artifactPath = "build" # The local path to your build artifacts

# Convert password to a secure string
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

# Connect to SharePoint
$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
$ctx.Credentials = $credential

# Upload files to SharePoint
function Upload-Files($folder, $localPath) {
    $files = Get-ChildItem -Path $localPath
    foreach ($file in $files) {
        $fileStream = [System.IO.File]::OpenRead($file.FullName)
        $fileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
        $fileCreationInfo.Overwrite = $true
        $fileCreationInfo.ContentStream = $fileStream
        $fileCreationInfo.URL = $folder.ServerRelativeUrl + "/" + $file.Name
        $uploadedFile = $folder.Files.Add($fileCreationInfo)
        $ctx.Load($uploadedFile)
        $ctx.ExecuteQuery()
        $fileStream.Close()
    }
}

# Get the target folder
$web = $ctx.Web
$ctx.Load($web)
$ctx.ExecuteQuery()

$folder = $web.GetFolderByServerRelativeUrl($folderPath)
$ctx.Load($folder)
$ctx.ExecuteQuery()

# Upload the artifacts
Upload-Files $folder $artifactPath
