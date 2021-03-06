<# 
.SYNOPSIS 
Compresses and moves log files older than 5 days from specified folder to another.
.DESCRIPTION 
 If files older than 5 days are found in a given folder, the script will use NTFS compression and move them to archive folder.  
.NOTES
File Name  : compress-logs.ps1 
Author: Nikolay Petkov 
http://power-shell.com/ 
#>
$LogFolder=“C:\logs”
$Arcfolder="C:\logs\Archive”
$LastWrite=(get-date).AddDays(-5).ToString("MM/dd/yyyy")
If ($Logs = get-childitem $LogFolder | Where-Object {$_.LastWriteTime -le $LastWrite -and !($_.PSIsContainer)} | sort-object LastWriteTime)
{
foreach ($L in $Logs)
{
$FullName=$L.FullName
$WMIFileName= $FullName.Replace("\", "\\")
$WMIQuery = Get-WmiObject -Query “SELECT * FROM CIM_DataFile WHERE Name='$WMIFileName'“
If ($WMIQuery.Compress()) {Write-Host "$FullName compressed successfully."-ForegroundColor Green}
else {Write-Host "$FullName was not compressed." -ForegroundColor Red}
If (Move-Item $FullName $Arcfolder -PassThru) {Write-Host "$FullName moved to $Arcfolder." -ForegroundColor Green}
else {Write-Host "$FullName was not moved to $Arcfolder." -ForegroundColor Red}
}}
else {Write-Host "Found no log files older than 5 days." -ForegroundColor Green}