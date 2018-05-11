<#
	Author: RBZ
	
	Version: 0.17.8.31
	Creation of script
	
	Version: 0.17.7.25
	Adjusted for better regex matching
	
	Version: 0.18.1.18
	Adjustments made to regex for Wise due to now combined stream
	
	Version: 0.18.5.9
	Added param of extract_dir to fix error of not getting file version from ddu
	
#>
function Extraction() {
param(
	[string]$archive,
	[string]$output_dir,
	[string]$output_file,
	[string]$extract_dir
)
if ( Test-Path "C:\Program Files\7-Zip\7z.exe" ) {
Set-Alias "7z" "C:\Program Files\7-Zip\7z.exe"
posh-tee "7 Zip is installed and set as alias 7z"
 }
    switch -w ( $output_file ) {

		'repair_windows.exe'	{
								$a = "Tweaking.com - Windows Repair\$output_file"
								# $regex_a = "\.0"
								# $regex_b = ""
								$regex_a = "(\.[0]\.)"
								$regex_b = ".$1"
								}
								
		'ccleaner*.exe'			{
								$a = $output_file
								$regex_a = "(\,\s)"
								$regex_b = "."
								$regex_c = "(\.00)"
								$regex_d = ""
								}
								
		'wisecare365.exe'					{
								$a = "Wise Care 365\$output_file"
								$regex_a = "[.](?=[^.]*$)(\d{3})"
								$regex_b = ""
								# $regex_c = "[.](?=[^.]*$)" # removed due to Wise combined "stream"
								$regex_c = ""
								$regex_d = ""
								}
								
		default					{
								$a = $output_file
								$regex_a = ""
								$regex_b = ""
								$regex_c = ""
								$regex_d = ""
								}
    }
    posh-tee "we are the $a"
posh-tee "Extraction running"
posh-tee "All the params are 7z -$svnzip_local- arch -$archive- outdir -$output_dir- outfile -$output_file-"
# This is for the deletion of $output_dir when we are finished for cleanup
$fso = New-Object -ComObject scripting.filesystemobject
# This will test to see if $output_dir does NOT exist
if ((!(test-path $output_dir)) -or ((test-path $output_dir))) {
	posh-tee "running cmd for 7zip"
	# 7zip extraction silent (no output) in cmd 
	cmd /c 7z x "$archive" -o"$output_dir" "$output_file" -r | out-null
	posh-tee "just ran 7zip"
	# checking for the fileVersion of $output_file
    # if ( $output_file -match "repair_windows.exe" ) {
    # $a = "Tweaking.com - Windows Repair\$output_file"
    # $regex_a = "\.0"
    # $regex_b = ""
    # } else {
    # $a = $output_file
    # $regex_a = "(\,\s)"
    # $regex_b = "."
    # $regex_c = "(\.00)"
    # $regex_d = ""
    # }
    posh-tee "get FileVersion from -$a-"
	# $fileVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo( "$output_dir\$a" ).FileVersion
	$fileVersion = (Get-Item "$output_dir$extract_dir\$a" ).VersionInfo.FileVersion
	posh-tee "found the file version of -$fileVersion-"
	# removal/cleanup of $output_dir
	posh-tee "cleanup of our mess"
    sleep 7
	$fso.DeleteFolder("$output_dir")
	posh-tee "The fileVersion -$fileVersion-"
 }
posh-tee "adjustment for compare"
# removes the '.0' from the $fileVersion that is not in the changelog version
$fileVersion = $fileVersion -replace($regex_a,$regex_b) # May need to adjust this for future usage of Extraction beyond tweaking
$fileVersion = $fileVersion -replace($regex_c,$regex_d) # May need to adjust this for future usage of Extraction beyond tweaking
posh-tee "fileVersion after adjustment -$fileVersion-"
posh-tee "return of fileVersion -$fileVersion-"
return $fileVersion
}