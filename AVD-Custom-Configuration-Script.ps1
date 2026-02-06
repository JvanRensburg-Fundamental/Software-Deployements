### ADMIN POST DEPLOYMENT CONFIGURATIONS ###

# Adding Default Users.
$AdminUsers = @(
    "fund\ITInfrastructure",
    "fund\SQL_Service",
    "fund\ServerAdmin",
    "fund\Azure_Arc",
    "fund\FundDev"
)

foreach ($u in $AdminUsers) {
    Add-LocalGroupMember -Group "Administrators" -Member $u -ErrorAction SilentlyContinue
    Write-Output "Processed admin user: $u"
}

# Replace 
$User = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[1]

New-PSDrive -PSProvider Registry -Root HKEY_USERS -Name HKU -ErrorAction SilentlyContinue | Out-Null

$Profiles = Get-ChildItem -Path hku:\ | Select-Object -ExpandProperty PSChildName |Where-Object {$_ -NotLike "*_Classes"}
$TempKey= "HKU\TEMP"
$DefaultRegPath = "C:\Users\Default\NTUSER.DAT"

reg load $TempKey $DefaultRegPath | Out-Null

foreach ($User in $Profiles){
    $RegPath = "HKU:\$User\Control Panel\International"
    New-ItemProperty -Path $RegPath -Name "sDecimal" -Value "." -PropertyType String -Force -ErrorAction SilentlyContinue
    New-ItemProperty -Path $RegPath -Name "sMonDecimalSep" -Value "." -PropertyType String -Force -ErrorAction SilentlyContinue
    Write-Output "Updated decimal settings for $User"
}

reg unload $TempKey | Out-Null

### END ###


### SQL SERVER 2025 DBA CONFIGURATIONS ###

# Install DBA Tools PowerShell Module
Install-Module Dbatools -Force -Scope AllUsers -ErrorAction SilentlyContinue
Write-Output "dbatools module processed."

# Set DBA Tools Connection
Set-DbatoolsInsecureConnection

# Create SQL logins
$securePassword = "fund" | ConvertTo-SecureString -AsPlainText -Force
New-DbaLogin -SqlInstance Localhost -Login FundAdmin -SecurePassword $securePassword -ErrorAction SilentlyContinue
Add-DbaServerRoleMember -SqlInstance Localhost -ServerRole sysadmin -Login FundAdmin -Confirm:$false -ErrorAction SilentlyContinue

$securePassword2 = "Fund@m3nt@1" | ConvertTo-SecureString -AsPlainText -Force
New-DbaLogin -SqlInstance Localhost -Login Fundnant -SecurePassword $securePassword2 -ErrorAction SilentlyContinue
Add-DbaServerRoleMember -SqlInstance Localhost -ServerRole sysadmin -Login Fundnant -Confirm:$false -ErrorAction SilentlyContinue

# Enable CLR
Invoke-DbaQuery -SqlInstance Localhost -Database Master -Query "sp_configure 'clr_enabled',1" -ErrorAction SilentlyContinue
Invoke-DbaQuery -SqlInstance Localhost -Database Master -Query "RECONFIGURE" -ErrorAction SilentlyContinue

# Create startup procedure for custom types
$ProcOptionQuery = "USE master
go
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
go
EXEC sp_procoption 'usp_CreateFundamentalTypesInTempDb_I' , 'startup' , 'on'
Go"

Invoke-DbaQuery -SqlInstance Localhost -Database Master -Query $ProcOptionQuery -ErrorAction SilentlyContinue

Restart-DbaService -ComputerName localhost -ErrorAction SilentlyContinue


### WSL INSTALLATION ###

Write-Output "Installing WSL..."
wsl --install --no-distribution 2>$null

Write-Output "Installing Ubuntu..."
wsl --install -d Ubuntu 2>$null


## Create PSScript Directory for Config Files ##
    
$tempDir = "C:\Temp"
$configDir = "C:\PSScripts"
if (!(Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force }
if (!(Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir -Force }

    # Setting up DevExpress 23.1.4 installation
    $DEVersion = "25.2.3"
    $installerNetworkPath = "\\blue\Software\Paid For\Developer Express\DevExpress $($DEVersion)\DevExpressComponentsBundleSetup-$($DEVersion).exe"
    $installerLocalPath = "C:\TEMP\DevExpressComponentsBundleSetup-$($DEVersion).exe"
    $DEconfigPath = "C:\PSScripts\AVDDevExpress_Config.ini"
    
    # Copy DevExpress installer from network location to local machine
    Copy-Item -Path $installerNetworkPath -Destination $installerLocalPath -Force

    # Start the DevExpress installation process with the configuration file
    Start-Process -Wait -FilePath $installerLocalPath -ArgumentList "/quiet", "/acceptEula=1", "/installMode=registered", "/configFile=`"$DEconfigPath`"" -PassThru -NoNewWindow


