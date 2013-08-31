function Add-TimeTracker{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True)]
		[string]$Message,
		[string]$FilePath = $(Get-TimeTrackerFile),
		[string]$Timestamp = $(Get-Date -Format s)
	)

	Write-Host "FilePath: " $FilePath;
	Write-Host "Timestamp: " $Timestamp;
	Write-Host "Message: " $Message;
	$dir = $(Split-Path -parent $FilePath);
	if(!$(Test-Path $dir)){
		New-Item -ItemType Directory -Force -Path $dir
	}
	$line = $Timestamp + " " + $Message;
	Add-Content -path $FilePath -value $line
}
