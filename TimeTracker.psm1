$dir = $(split-path -parent $MyInvocation.MyCommand.Definition);
foreach($file in $(Get-ChildItem ($dir + "\Functions\*.ps1"))){
	.($file);
	Export-ModuleMember -Function $file.BaseName;
}
#.(".\Functions\Get-TimeTrackerFile.ps1")
#Export-ModuleMember -Function Get-TimeTrackerFile
