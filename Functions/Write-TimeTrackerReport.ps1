<#
.SYNOPSIS
	Writes the TimeTracker report to the screen.
.DESCRIPTION
	Writes a summary of the TimeTracker entries between the specified MinTime and MaxTime.
.LINK
	https://github.com/n8jones/TimeTracker
#>
function Write-TimeTrackerReport{
	[CmdletBinding()]
	Param(
		[Datetime]$minTime = (Get-Date -Hour 0 -Minute 0 -Second 0),
		[Datetime]$maxTime = (Get-Date -Hour 23 -Minute 59 -Second 59),
		[Switch]$ThisWeek,
		[Switch]$ThisMonth,
		[Switch]$LastWeek,
		[Switch]$LastMonth
	)
	if($ThisWeek){
		$sunday = [DateTime]::Today.Day - [DateTime]::Today.DayOfWeek;
		$minTime = (Get-Date -Day $sunday -Hour 0 -Minute 0 -Second 0);
		$maxTime = (Get-Date);
	}
	elseif($ThisMonth){
		$minTime = (Get-Date -Day 1 -Hour 0 -Minute 0 -Second 0);
		$maxTime = (Get-Date);
	}
	elseif($LastWeek){
		$minTime = [DateTime]::Today.AddDays(-7 - [DateTime]::Today.DayOfWeek);
		$maxTime = [DateTime]::Today.AddDays(-1 - [DateTime]::Today.DayOfWeek);
		$maxTime = (Get-Date -Year $maxTime.Year -Month $maxTime.Month -Day $maxTime.Day -Hour 23 -Minute 59 -Second 59);
	}
	elseif($LastMonth){
		$maxTime = [DateTime]::Today.AddDays(0 - [DateTime]::Today.Day);
		$minTime = $maxTime.AddDays(1 - $maxTime.Day);
		$maxTime = (Get-Date -Year $maxTime.Year -Month $maxTime.Month -Day $maxTime.Day -Hour 23 -Minute 59 -Second 59);
	}
	$entries = @();
	foreach($file in $(Get-ChildItem $(Get-TimeTrackerFile -Pattern))){
		$entries += $(Read-TimeTracker $file);
	}
	$productive = New-Timespan;
	$prodTimes = @{};
	$notProductive = New-Timespan;
	$npTimes = @{};
	$last = $null;
	$timeInTicks = [long]0;
	$timeInCount = [long]0;
	if($entries.Length -lt 1){
		Write-Host "No entries found.";
		return;
	}
	foreach($entry in $entries){
		if(($entry.Timestamp -lt $maxTime) -and ($entry.Timestamp -gt $minTime)){
			if($entry.Productive){
				$productive += $entry.Time;
				if($entry.Time.TotalSeconds -gt 0){
					$prodTimes[$entry.Message] += $entry.Time;
				}
			}
			else{
				$notProductive += $entry.Time;
				if($entry.Time.TotalSeconds -gt 0){
					$npTimes[$entry.Message] += $entry.Time;
				}
			}
			if((($last -eq $null) -or ($last.Timestamp.Day -ne $entry.Timestamp.Day)) -and (($entry.Timestamp.DayOfWeek -gt 0) -and ($entry.Timestamp.DayOfWeek -lt 6))){
				$timeInTicks += $entry.Timestamp.TimeOfDay.ticks;
				$timeInCount++;
			}
			$last = $entry;
		}
	}
	Write-Host "Report Dates: " ($minTime) "-" ($maxTime);
	Write-Host "Productive Time: " (Format-TimeTrackerTimeSpan($productive));
	foreach($time in ($prodTimes.GetEnumerator() | Sort-Object Value -Descending)){
		Write-Host "`t" ($time.Name.PadRight(50)) " " (Format-TimeTrackerTimeSpan($time.Value));
	}
	Write-Host "Not Productive Time: " (Format-TimeTrackerTimeSpan($notProductive));
	foreach($time in ($npTimes.GetEnumerator() | Sort-Object Value -Descending)){
		Write-Host "`t" ($time.Name.PadRight(50)) " " (Format-TimeTrackerTimeSpan($time.Value));
	}
	if($timeInCount -gt 0){
		Write-Host "Average Time In: " (Format-TimeTrackerTimeSpan([TimeSpan]::FromTicks($timeInTicks / $timeInCount)));
	}
	Write-Host "Time since last entry: " (Format-TimeTrackerTimeSpan((Get-Date) - $entries[-1].Timestamp));
}