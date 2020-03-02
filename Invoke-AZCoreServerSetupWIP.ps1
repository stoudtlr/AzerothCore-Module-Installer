<#
Edit line 5 to show the location you want all files downloaded to.
Edit line 6 to show where you want the final server
#>
$BaseLocation = "D:\WOW_SERVERS-TEST\AzerothCore-WotLK"
$BuildFolder = "D:\WOW_SERVERS-TEST\Build-AzerothCore"

# DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING!!!

$AzerothCoreRepo = "https://github.com/azerothcore/azerothcore-wotlk.git"
$GitURL = "https://api.github.com/repos/git-for-windows/git/releases/latest"
$GitInstallFile = "$env:USERPROFILE\Downloads\$($GitVersion.name)"
$CmakeVersion = "https://github.com/Kitware/CMake/releases/download/v3.16.4/cmake-3.16.4-win64-x64.msi"
$CmakeFileName = $CmakeVersion.Split("/")[-1]
$CmakeInstallFile = "$env:USERPROFILE\Downloads\$CmakeFileName"
$VisualStudioURL = "https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community&rel=16#"
$VSFileName = "vs_community.exe"
$VSInstallFile = "$env:USERPROFILE\Downloads\$VSFileName"
$OpenSSLURL = "http://slproweb.com/download/Win64OpenSSL-1_1_1d.exe"
$OpenSSLFileName = $OpenSSLURL.Split("/")[-1]
$OpenSSLInstallFile = "$env:USERPROFILE\Downloads\$OpenSSLFileName"
$MySQLURL = "https://downloads.mysql.com/archives/get/p/25/file/mysql-installer-community-5.7.26.0.msi"
$MySQLFileName = $MySQLURL.Split("/")[-1]
$MySQLInstallFile = "$env:USERPROFILE\Downloads\$MySQLFileName"
$MySQLServerVersion = $MySQLFileName.Split("-")[-1] -Replace(".{6}$")

# Pre-requisite checks section
Write-Information -MessageData "Beginning pre-requisite checks and`ninstalling any missing but required software`n`n" -InformationAction Continue
# check for Git 64bit install
if (!(Test-Path -Path "C:\Program Files\Git\git-cmd.exe")) {
    Write-Information -MessageData "Git 64bit not found.  Downloading now" -InformationAction Continue
    $GitVersion = Invoke-RestMethod -Method Get -Uri $GitURL | ForEach-Object assets | Where-Object name -like "*64-bit.exe"
    Try {
        Invoke-WebRequest -Uri $GitVersion.browser_download_url -OutFile $GitInstallFile
    } Catch {
        Write-Error -Message "Failed to download $($GitVersion.name)" -InformationAction Stop
    }
    Write-Information -MessageData "Download finished. Now installing" -InformationAction Continue
    # create .inf file for git silent install
    $GitINF = "$env:USERPROFILE\Downloads\gitinstall.inf"
    New-Item -Path $GitINF -ItemType File -Force
    Add-Content -Path $GitINF -Value "[Setup]
        Lang=default
        Dir=C:\Program Files\Git
        Group=Git
        NoIcons=0
        SetupType=default
        Components=ext,ext\shellhere,ext\guihere,gitlfs,assoc,assoc_sh
        Tasks=
        EditorOption=Notepad++
        CustomEditorPath=
        PathOption=Cmd
        SSHOption=OpenSSH
        TortoiseOption=false
        CURLOption=OpenSSL
        CRLFOption=CRLFAlways
        BashTerminalOption=ConHost
        PerformanceTweaksFSCache=Enabled
        UseCredentialManager=Enabled
        EnableSymlinks=Disabled
        EnableBuiltinInteractiveAdd=Disabled"
    $GitArguments = "/VERYSILENT /NORESTART /LOADINF=""$GitINF"""
    Try {
        Start-Process -FilePath $GitInstallFile -ArgumentList $GitArguments -Wait
    } Catch {
        Write-Error -Message "Git Install failed" -ErrorAction Stop
    }
    Write-Information -MessageData "Git Install finished" -InformationAction Continue
    $RestartRequired = $true
}
Write-Information -MessageData "Git already installed. Continuing to next step." -InformationAction Continue

# check for CMake 64bit install
if (!(Test-Path -Path "C:\Program Files\CMake\bin\cmake.exe")) {
    Write-Information -MessageData "CMake 64bit not found. Downloading now" -InformationAction Continue
    Try {
        Invoke-WebRequest -Uri $CmakeVersion -OutFile $CmakeInstallFile
    } Catch {
        Write-Error -Message "Failed to download $CmakeFileName" -InformationAction Stop
    }
    Write-Information -MessageData "Download finished. Now installing" -InformationAction Continue
    $CmakeArguments = "/i `"$CmakeInstallFile`" /norestart /quiet"
    Try {
        Start-Process msiexec.exe -ArgumentList $CmakeArguments -Wait
    } Catch {
        Write-Error -Message "CMake Install failed" -ErrorAction Stop
    }
    Write-Information -MessageData "CMake install finished" -InformationAction Continue
    $RestartRequired = $true
}
Write-Information -MessageData "CMake already installed. Continuing to next step." -InformationAction Continue

# check for Visual Studio
if (!(Test-Path -Path "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe")) {
    Write-Information -MessageData "Visual Studio not found. Downloading and installing now" -InformationAction Continue
    Try {
        Invoke-WebRequest -Uri $VisualStudioURL -OutFile "$VSInstallFile.txt"
    } Catch {
        Write-Error -Message "Failed to retrieve VS webpage" -ErrorAction Stop
    }
    $installerURL = Select-String -Path "$VSInstallFile.txt" -Pattern "vs_Community.exe"
    $installerURL = "https:" + ($installerURL -replace ".*:" -replace ".{1}$")
    Try {
        Invoke-WebRequest -Uri $installerURL -OutFile $VSInstallFile
    } Catch {
        Write-Error -Message "Failed to download Visual Studio" -ErrorAction Stop
    }
    $VSArguments = "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Workload.NativeDesktop;includeRecommended --quiet --norestart"
    Try {
        Start-Process -FilePath $VSInstallFile -ArgumentList $VSArguments -Wait
    } Catch {
        Write-Error -Message "Visual Studio install failed" -ErrorAction Stop
    }
    Write-Information -MessageData "Visual Studio install finished" -InformationAction Continue
    $RestartRequired = $true
}
Write-Information -MessageData "Visual Studio already installed. Continuing to next step." -InformationAction Continue

# check for OpenSSL 64bit
if (!(Test-Path -Path "C:\Program Files\OpenSSL-Win64\bin\openssl.exe")) {
    Write-Information -MessageData "OpenSSL not found. Downloading and installing now" -InformationAction Continue
    Try {
        Invoke-WebRequest -Uri $OpenSSLURL -OutFile $OpenSSLInstallFile
    } Catch {
        Write-Error -Message "Failed to download $OpenSSLFileName" -InformationAction Stop
    }
    Write-Information -MessageData "Download finished. Now installing" -InformationAction Continue
    $OpenSSLArguments = "/VERYSILENT"
    Try {
        Start-Process -FilePath $OpenSSLInstallFile -ArgumentList $OpenSSLArguments -Wait
    } Catch {
        Write-Error -Message "OpenSSL 64bit install failed" -ErrorAction Stop
    }
    Write-Information -MessageData "OpenSSL 64bit install finished" -InformationAction Continue
    $RestartRequired = $true
}
Write-Information -MessageData "OpenSSL already installed. Continuing to next step." -InformationAction Continue

# check for MySQL
if (!(Test-Path -Path "C:\Program Files\MySQL\MySQL Server 5.7\bin\mysqld.exe")) {
    Write-Information -MessageData "MySQL not found. Downloading and installing now" -InformationAction Continue
    Try {
        Invoke-WebRequest -Uri $MySQLURL -OutFile $MySQLInstallFile
    } Catch {
        Write-Error -Message "Failed to download $MySQLFileName" -InformationAction Stop
    }
    Write-Information -MessageData "Download finished. Running Community Installer" -InformationAction Continue
    $MySQLArguments = "/q /log c:\MySQLInstallerLog.txt /i `"$MySQLInstallFile`""
    
    Try {
        Start-Process msiexec.exe -ArgumentList $MySQLArguments -Wait
    } Catch {
        Write-Error -Message "MySQL Community Install failed" -ErrorAction Stop
    }
    Write-Information -MessageData "MySQL Community finished. Now installing MySQL Server" -InformationAction Continue
    
    $SQLInstaller = "C:\Program Files (x86)\MySQL\MySQL Installer for Windows\MySQLInstallerConsole.exe"
    $SQLArgs = "community install server;$MySQLServerVersion;x64 -silent"
    Try {
        Start-Process -FilePath $SQLInstaller -ArgumentList $SQLArgs -Wait
    } Catch {
        Write-Error -Message "MySQL Server install failed" -ErrorAction Stop
    }
    Write-Information -MessageData "MySQL Server Install finished" -InformationAction Continue

    # initialize mysql and start service
    Start-Process -FilePath "C:\Program Files\MySQL\MySQL Server 5.7\bin\mysqld.exe" -ArgumentList "--initialize-insecure"
    Start-Process -FilePath "C:\Program Files\MySQL\MySQL Server 5.7\bin\mysqld.exe" -ArgumentList "--install"
    Start-Service -Name MySQL
    $SQLService = Get-Service -Name MySQL
    if ($SQLService.Status -ne "running") {
        Write-Error -Message "was not able to start SQL service" -ErrorAction Stop
    }

    # Set password for root account
    Write-Information -MessageData "`n`n`nSQL default is BLANK root password`n`nProvide new password`n`n`n" -InformationAction Continue
    do {
        $NewSQLPassword = Read-Host "New Password"
        $ConfirmPassword = Read-Host "Confirm Password"
        if ($ConfirmPassword -ne $NewSQLPassword) {
            Write-Information -MessageData "Passwords do not match. Try again" -InformationAction Continue
        }
    } until ($ConfirmPassword -eq $NewSQLPassword)

    $sqlCMD = "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ConfirmPassword';"
    $SQLChangePWArgs = "-uroot --execute=`"$sqlCMD`""
    Start-Process -FilePath 'C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql.exe' -ArgumentList $SQLChangePWArgs -Wait -ErrorAction Stop
    Write-Information -MessageData "Root password set to: $ConfirmPassword" -InformationAction Continue
    $RestartRequired = $true
}
Write-Information -MessageData "MySQL already installed. Continuing to next step." -InformationAction Continue
$SQLService = Get-Service -Name MySQL
if ($SQLService.Status -ne "running") {
    Try {
        Start-Service -Name MySQL
    } Catch {
        Write-Error -Message "was not able to start SQL service" -ErrorAction Stop
    }
}

# Program installation finished.  Restart now if required.
if ($RestartRequired) {
    Write-Information -MessageData "`n`n`nOne or more applications have been installed`nand PATH variables modified`nyou MUST close and reopen Powershell to continue`nrerun script to continue`n`n`n" -InformationAction Stop
}

# Downloading AzerothCore Repository
if (!(Test-Path -Path "$BaseLocation\.git\HEAD")) {
    Write-Information -MessageData "Creating Folder`nCloning AzerothCore Git Repo" -InformationAction Continue
    Try {
        New-Item -Path $BaseLocation -ItemType Directory
    } Catch {
        Write-Error -Message "Unable to create folder" -ErrorAction Stop
    }
    Write-Information -MessageData "Folder created`nCloning AzerothCore Git Repo" -InformationAction Continue
    Try {
        git clone $AzerothCoreRepo $BaseLocation --branch master
        if (-not $?) {
            throw "git error! failed to clone AzerothCore!"
        }
    } Catch {
        throw
    }
    Write-Information -MessageData "Clone successfull!" -InformationAction Continue
} else {
    Write-Information -MessageData "AzerothCore already exists`nUpdating repo now" -InformationAction Continue
    Try {
        Set-Location $BaseLocation
        git pull
        if (-not $?) {
            throw "git error! failed to update AzerothCore!"
        }
    } Catch {
        throw
    }
}

# Function to download modules

Function Get-AZModule {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$AZmodPath,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$AZmodURL
    )

    $AZmodname = ($AZmodURL -replace ".{4}$").Remove(0,31)
    if (Test-Path "$AZmodPath\.git\HEAD") {
        Write-Information -MessageData "$AZmodname already exists`nUpdating repo now" -InformationAction Continue
        try {
            Set-Location $AZmodPath
            git pull
            if (-not $?) {
                throw "git error! failed to update $AZmodname"
            }
        } Catch {
            throw
        }
    } else {
        Write-Information -MessageData "Module doesn't exist yet`nCloning $AZmodname repo" -InformationAction Continue
        Try {
            git clone $AZmodURL $AZmodPath
            if (-not $?) {
                throw "git error! failed to clone $AZmodname"
            }
        } Catch {
            throw
        }
    }
}

# Winform to select modules

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$Form = New-Object System.Windows.Forms.Form
$Form.Size = New-Object System.Drawing.Size(600,270)
$Form.text ="Choose desired AzerothCore modules"
$Form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(420,200)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$Form.AcceptButton = $OKButton
$Form.Controls.Add($OKButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(500,200)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$Form.CancelButton = $cancelButton
$Form.Controls.Add($cancelButton)

# Start group boxes
$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.Location = New-Object System.Drawing.Size(20,20)
$groupBox.text = "Availabe Modules:"
$groupBox.size = New-Object System.Drawing.Size(540,175)
$Form.Controls.Add($groupBox)

# Create check boxes
$checklist = New-Object System.Windows.Forms.CheckedListBox
$checklist.Location = New-Object System.Drawing.Size(20,20)
$checklist.Size = New-Object System.Drawing.Size(500,150)
$checklist.CheckOnClick = $true
$checklist.MultiColumn = $true

# Get Available Modules
$uri = New-Object System.UriBuilder -ArgumentList 'https://api.github.com/search/repositories?q=topic%3Acore-module+fork%3Atrue+org%3Aazerothcore&type=Repositories&per_page=100'
$baseuri = $uri.uri
$acmods = Invoke-RestMethod -Method Get -Uri $baseuri
$acmodslist = $acmods.items | Select-Object -Property name, clone_url | Sort-Object Name

# Add modules to checkboxlist with any already present defaulted to checked
$CurrentModules = Get-ChildItem -Path "$BaseLocation\Modules" -Filter "mod*" | Select-Object -Property Name
$modnumber = 0
foreach ($acmod in $acmodslist) {
    if ($acmod.name -like "mod*") {
        $modsName = ($acmod.name).remove(0,4)
        $checklist.Items.Add($modsName) | Out-Null
        foreach ($CurrentModule in $CurrentModules) {
            if (($CurrentModule.Name).remove(0,4) -eq $modsName) {
                $checklist.SetItemChecked($modnumber,$true)
            }
        }
        $modnumber ++
    }
}

$groupBox.Controls.Add($checklist)

# OK is clicked
$OKButton.Add_Click({
    $Script:Cancel=$false
    $Form.Hide()
    foreach ($mod in $checklist.CheckedItems) {
        foreach ($acmod in $acmodslist) {
            if ($acmod.name -like "*$mod") {
                $modpath = "$BaseLocation\modules\" + $acmod.name
                Write-Progress -Activity "Downloading Modules" -Status $acmod.name
                Get-AZModule -AZmodPath $modpath -AZmodURL $acmod.clone_url
            }
        }
        if ($mod -eq "eluna-lua-engine") {
            Write-Progress -Activity "Downloading Modules" -Status "Installing LUA Engine"
            Get-AZModule -AZmodPath "$BaseLocation\modules\mod-eluna-lua-engine\LuaEngine" -AZmodURL "https://github.com/ElunaLuaEngine/Eluna.git"
        }
    }
    $Form.Close()
})

$cancelButton.Add_Click({
    $Script:Cancel=$true
    $Form.Close()
})

# Show Form
$Form.ShowDialog() | Out-Null

if ($Cancel -eq $true) {
    break
}

# Building the Server
Set-Location 'C:\Program Files\CMake\bin'
Write-Progress -Activity "Building Server" -Status "Compiling Source"
$BuildArgs = "-G `"Visual Studio 16 2019`" -A x64 -S $BaseLocation -B $BuildFolder"
Start-Process -FilePath 'C:\Program Files\CMake\bin\cmake.exe' -ArgumentList $BuildArgs -Wait
Write-Progress -Activity "Building Server" -Status "Final Build"
$FinalArgs = "--build $BuildFolder --config Release"
Start-Process -FilePath "C:\Program Files\CMake\bin\cmake.exe" -ArgumentList $FinalArgs -Wait

# Copying required files and making setting changes
Write-Progress -Activity "Copying all .conf.dist files"
$DistFiles = Get-ChildItem -Path "$BuildFolder\bin\Release" -Filter "*.dist"
foreach ($Dist in $DistFiles) {
    $Conf = $Dist -replace ".{5}$"
    Copy-Item -Path "$BuildFolder\bin\Release\$Dist" -Destination "$BuildFolder\bin\Release\$Conf"
}

# Copying server dependencies
Copy-Item -Path 'C:\Program Files\MySQL\MySQL Server 5.7\lib\libmysql.dll' -Destination "$BuildFolder\bin\Release"
