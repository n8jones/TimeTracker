function Read-TimeTracker{
	Param(
		[string]$FilePath = $(Get-TimeTrackerFile)
	)
	$ret = @();
	$last = $NULL;
	foreach($line in $(Get-Content $FilePath)){
		$index = $line.IndexOf(' ');
		if($index -gt 1){
			$timestamp = $line.SubString(0, $index);
			$message = $line.SubString($index+1);
			$productive = !($line.EndsWith('*'));
			$entry= @{
				'Timestamp' = $([DateTime]::Parse($timestamp));
				'Message' = $message;
				'Productive' = $productive;
			};
			if(($last -ne $NULL) `
					-and ($last.Timestamp.Year -eq $entry.Timestamp.Year) `
					-and ($last.Timestamp.Month -eq $entry.Timestamp.Month) `
					-and ($last.Timestamp.Day -eq $entry.Timestamp.Day)){
				$entry.Time = $entry.Timestamp - $last.Timestamp;
			}
			else{
				$entry.Time = $(New-Timespan);
			}
			$ret += $entry;
			$last = $entry;
		}
	}
	return $ret;
}