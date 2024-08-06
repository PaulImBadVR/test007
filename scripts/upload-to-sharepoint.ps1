# Define variables
$siteUrl = $env:SHAREPOINT_SITE_URL
$username = $env:SHAREPOINT_USERNAME
$password = $env:SHAREPOINT_PASSWORD
$folderPath = "GameCIDump" # Change this to your SharePoint folder path
$artifactPath = "build" # The local path to your build artifacts

# Error handling
try {
    # Print out variables for debugging
    Write-Output "SharePoint Site URL: $siteUrl"
    Write-Output "Folder Path: $folderPath"
    Write-Output "Artifact Path: $artifactPath"

    Write-Output "Download the SharePoint Client Components SDK"
    # Download the SharePoint Client Components SDK
    $clientComponentsUrl = "https://download.microsoft.com/download/0/4/6/046BCBA8-3B4E-4D5A-B6A3-5C0B246A4A18/SharePointClientComponents_x64.msi"
    $clientComponentsPath = "$env:TEMP/SharePointClientComponents_x64.msi"
    Invoke-WebRequest -Uri $clientComponentsUrl -OutFile $clientComponentsPath

    Write-Output "Extract the assemblies from the MSI"
    # Extract the assemblies from the MSI
    $msiexec = "/usr/bin/msiexec"
    Start-Process -FilePath $msiexec -ArgumentList "/a $clientComponentsPath /qb TARGETDIR=$env:TEMP/SharePointClientComponents" -Wait

    Write-Output "Load the required assemblies"
    # Load the required assemblies
    $assemblyPath = "$env:TEMP/SharePointClientComponents/Program Files/Common Files/Microsoft Shared/Web Server Extensions/16/ISAPI"
    Add-Type -Path "$assemblyPath/Microsoft.SharePoint.Client.dll"
    Add-Type -Path "$assemblyPath/Microsoft.SharePoint.Client.Runtime.dll"

    Write-Output "Convert password to a secure string"
    # Convert password to a secure string
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

    Write-Output "Connect to SharePoint"
    # Connect to SharePoint
    $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
    $ctx.Credentials = $credential

    Write-Output "Get the target folder"
    # Get the target folder
    $web = $ctx.Web
    $ctx.Load($web)
    $ctx.ExecuteQuery()

    $folder = $web.GetFolderByServerRelativeUrl($folderPath)
    $ctx.Load($folder)
    $ctx.ExecuteQuery()
    
    Write-Output $ctx
    
    Write-Output "Check if folder exists, if not create it"
    # Check if folder exists, if not create it
    if (-not ($folder.Exists)) {
        Write-Output "Folder does not exist. Creating folder..."
        $newFolder = $web.Folders.Add($folderPath)
        $ctx.Load($newFolder)
        $ctx.ExecuteQuery()
    }

    Write-Output "Upload files to SharePoint"
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

    # Upload the artifacts
    Upload-Files $folder $artifactPath
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
