function Get-TimeTrackerFile {
	Param(
		[Switch]$pattern
	)
	$dir = $home + "\Google Drive\TimeTracker\";
	$prefix = "TT-Log-";
	$suffix = ".txt";
	if($pattern){
		return $dir + $prefix + "*" + $suffix;
	}
	else{
		return $dir + $prefix + $(Get-Date -Format "yyyy-MM") + $suffix;
	}
}