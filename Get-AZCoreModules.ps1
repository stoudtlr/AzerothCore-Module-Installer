$BaseLocation = "D:\WOW_SERVERS\azerothcore-wotlk"

# Git Function
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

# Begin WinForm Code

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$Form = New-Object System.Windows.Forms.Form
$Form.Size = New-Object System.Drawing.Size(700,380)
$Form.text ="Choose desired AzerothCore modules"
$Form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(520,310)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$Form.AcceptButton = $OKButton
$Form.Controls.Add($OKButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(600,310)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$Form.CancelButton = $cancelButton
$Form.Controls.Add($cancelButton)

# Start group boxes
$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.Location = New-Object System.Drawing.Size(20,20)
$groupBox.text = "Availabe Modules:"
$groupBox.size = New-Object System.Drawing.Size(660,275)
$Form.Controls.Add($groupBox)

# Create check boxes
$checklist = New-Object System.Windows.Forms.CheckedListBox
$checklist.Location = New-Object System.Drawing.Size(20,20)
$checklist.Size = New-Object System.Drawing.Size(620,250)
$checklist.CheckOnClick = $true
$checklist.MultiColumn = $true

# Get Mods and add to Checkboxes
$uri = New-Object System.UriBuilder -ArgumentList 'https://api.github.com/search/repositories?q=topic%3Acore-module+fork%3Atrue+org%3Aazerothcore&type=Repositories&per_page=100'
$baseuri = $uri.uri
$acmods = Invoke-RestMethod -Method Get -Uri $baseuri
$acmodslist = $acmods.items | Select-Object -Property name, clone_url | Sort-Object Name

foreach ($acmod in $acmodslist) {
    if ($acmod.name -like "mod*") {
        $modsName = ($acmod.name).remove(0,4)
        $checklist.Items.Add($modsName) | Out-Null
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