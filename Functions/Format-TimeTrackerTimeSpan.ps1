function Format-TimeTrackerTimeSpan{
	[CmdletBinding()]
	Param(
		[TimeSpan]$time
	)
	$hours = $time.TotalHours;
	if($time.Minutes -gt 30){
		$hours = $hours-1;
	}
	return [string]::Format("{0:##00}:{1:00}", $hours, $time.Minutes);
}