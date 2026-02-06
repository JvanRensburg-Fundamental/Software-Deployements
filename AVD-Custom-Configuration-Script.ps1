# ==========================================
#  AVD Custom Configuration Script
#  Runs as SYSTEM during host provisioning
# ==========================================

Start-Transcript -Path "C:\Temp\AVD-CustomConfig.log" -Force

Write-Output "Starting AVD custom configuration..."

# ------------------------------------------
# 1. Add Default Admin Users
# ------------------------------------------
$AdminUsers = @(
    "fund\ITInfrastructure",
    "fund\SQL_Service",
    "fund\ServerAdmin",
    "fund\Azure_Arc",
    "fund\FundDev"
)

foreach ($u in $AdminUsers) {
    try {
        Add-LocalGroupMember -Group "Administrators" -Member $u -ErrorAction Stop
        Write-Output "Added $u to Administrators"
    }
    catch {
        Write-Output "Failed to add $u: $_"
    }
}

# ------------------------------------------
# 2. Set Decimal Separators for All Profiles
# ------------------------------------------
Write-Output "Updating decimal settings for all user profiles..."

New-PSDrive -PSProvider Registry -Root HKEY_USERS -Name HKU -ErrorAction SilentlyContinue | Out-Null

$Profiles = Get-ChildItem -Path HKU:\ | Select-Object -ExpandProperty PSChildName | Where-Object {$_ -notlike "*_Classes"}

$TempKey = "HKU\TEMP"
$DefaultRegPath = "C:\Users\Default\NTUSER.DAT"

reg load $TempKey $DefaultRegPath | Out-Null

foreach ($p in $Profiles) {
    $RegPath = "HKU:\$p\Control Panel\International"
    try {
        New-ItemProperty -Path $RegPath -Name "sDecimal" -Value "." -PropertyType String -Force
        New-ItemProperty -Path $RegPath -Name "sMonDecimalSep" -Value "." -PropertyType String -Force
        Write-Output "Updated decimal settings for $p"
    }
    catch {
        Write-Output "Failed to update $p: $_"
    }
}

reg unload $TempKey | Out-Null

# ------------------------------------------
# 3. SQL Server 2025 DBA Configurations
# ------------------------------------------
Write-Output "Starting SQL DBA configuration..."

# Install dbatools
try {
    Install-Module dbatools -Force -Scope AllUsers -ErrorAction Stop
    Write-Output "dbatools installed successfully."
}
catch {
    Write-Output "Failed to install dbatools: $_"
}

# Allow insecure connections (required for localhost)
Set-DbatoolsInsecureConnection

# Create SQL logins
try {
    $securePassword = "fund" | ConvertTo-SecureString -AsPlainText -Force
    New-DbaLogin -SqlInstance Localhost -Login FundAdmin -SecurePassword $securePassword
    Add-DbaServerRoleMember -SqlInstance Localhost -ServerRole sysadmin -Login FundAdmin -Confirm:$false

    $securePassword2 = "Fund@m3nt@1" | ConvertTo-SecureString -AsPlainText -Force
    New-DbaLogin -SqlInstance Localhost -Login Fundnant -SecurePassword $securePassword2
    Add-DbaServerRoleMember -SqlInstance Localhost -ServerRole sysadmin -Login Fundnant -Confirm:$false

    Write-Output "SQL logins created successfully."
}
catch {
    Write-Output "SQL login creation failed: $_"
}

# Enable CLR
Invoke-DbaQuery -SqlInstance Localhost -Database Master -Query "sp_configure 'clr_enabled',1"
Invoke-DbaQuery -SqlInstance Localhost -Database Master -Query "RECONFIGURE"

# Create startup procedure for custom types
$ProcOptionQuery = @"
USE master
GO
CREATE PROCEDURE usp_CreateFundamentalTypesInTempDb_I
AS
EXEC ( 'USE tempdb;
IF NOT EXISTS( SELECT NULL FROM sys.types WHERE name = ''TFundamentalDecimal'')
BEGIN
    CREATE TYPE TFundamentalDecimal FROM numeric (26, 12) NULL;
    GRANT REFERENCES ON TYPE::dbo.TFundamentalDecimal TO PUBLIC;
END
IF NOT EXISTS( SELECT NULL FROM sys.types WHERE name = ''TFundamentalCurrency'')
BEGIN
    CREATE TYPE TFundamentalCurrency FROM numeric (18, 2) NULL;
    GRANT REFERENCES ON TYPE::dbo.TFundamentalCurrency TO PUBLIC;
END')
GO
EXEC sp_procoption 'usp_CreateFundamentalTypesInTempDb_I' , 'startup' , 'on'
GO
"@

Invoke-DbaQuery -SqlInstance Localhost -Database Master -Query $ProcOptionQuery

Restart-DbaService -ComputerName localhost

# ------------------------------------------
# 4. WSL Installation (AVD Warning)
# ------------------------------------------
Write-Output "Attempting WSL installation..."

try {
    wsl --install --no-distribution
    Write-Output "WSL base installed."
}
catch {
    Write-Output "WSL install failed: $_"
}

try {
    wsl --install -d Ubuntu
    Write-Output "Ubuntu installed."
}
catch {
    Write-Output "Ubuntu install failed: $_"
}

Write-Output "AVD custom configuration completed."
Stop-Transcript