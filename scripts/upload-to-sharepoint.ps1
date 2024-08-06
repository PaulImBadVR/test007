# Define variables
$siteUrl = $env:SHAREPOINT_SITE_URL
$username = $env:SHAREPOINT_USERNAME
$password = $env:SHAREPOINT_PASSWORD
$folderPath = "Shared Documents/YourFolder" # Change this to your SharePoint folder path
$artifactPath = "build" # The local path to your build artifacts

# Error handling
try {
    # Download the SharePoint Client Components SDK
    $clientComponentsUrl = "https://download.microsoft.com/download/0/4/6/046BCBA8-3B4E-4D5A-B6A3-5C0B246A4A18/SharePointClientComponents_x64.msi"
    $clientComponentsPath = "$env:TEMP/SharePointClientComponents_x64.msi"
    Invoke-WebRequest -Uri $clientComponentsUrl -OutFile $clientComponentsPath

    # Extract the assemblies from the MSI
    $msiexec = "C:\Windows\System32\msiexec.exe"
    Start-Process -FilePath $msiexec -ArgumentList "/a $clientComponentsPath /qb TARGETDIR=$env:TEMP/SharePointClientComponents" -Wait

    # Load the required assemblies
    $assemblyPath = "$env:TEMP/SharePointClientComponents/Program Files/Common Files/Microsoft Shared/Web Server Extensions/16/ISAPI"
    Add-Type -Path "$assemblyPath/Microsoft.SharePoint.Client.dll"
    Add-Type -Path "$assemblyPath/Microsoft.SharePoint.Client.Runtime.dll"

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
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
