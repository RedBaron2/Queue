<#

Script:         Norton Power Eraser (NPE)
Description:    This will check for the latest version of NPE and download it is the local version is not the latest.
Author:     RBZ
Changelog: 

Original Writeup
Version: 0.17.08.31

Version: 0.17.09.05c
Changes:
    Added helper script to make script cleaner
    Adjusted how this file is checked for newness (using the file size to compare)

Version: 0.18.01.27
Added test for file if else
Adjusted Invoke-WebRequest to UseBasicParsing

NOTES:
    Work on merging the KVRT/NPE scripts into one script

#>
	
	. (Join-Path $scriptDir '.\tools\findFilePath.ps1')	
	. (Join-Path $scriptDir '.\data\Get-NPE_helpers.ps1')
	 
# Set-Alias posh-tee Write-Host


$NPE = @{}
$NPE.url = 'https://security.symantec.com/nbrt/npe.aspx'
$NPE.fileName = "NPE.exe"
$NPE.filePath = findFilePath NPE
# $NPE.dwnld=$false;
function Get-NPE_url {
param(
    [string]$url
)

$re = 'npe.+exe'
$test = Invoke-WebRequest $url -UseBasicParsing
$toad = $test.links | Where-Object { $_.href -match $re } | select -First 1 -Expand href
$url = $NPE.url = $toad;
# $toad=$NPE.url = $url;
posh-tee " The toad -$toad-"
$test.close

$testy = Invoke-WebRequest -Method Head $url -UseBasicParsing
$web_fileSize = Format-FileSize( ($testy.Headers['Content-Length']) )
$NPE.Add = ( "web_size" , "$web_fileSize")
posh-tee "the web_filesize -$web_fileSize-"
$file = $NPE.filePath + "\" + $NPE.fileName
posh-tee "file -$file-"
if (Test-Path $file) {
$local_fileSize = Format-FileSize( (Get-Item $file).length );
} else {
$local_fileSize = Format-FileSize( "0.0" );
}
$NPE.Add = ( "local_size" , "$local_fileSize" )
posh-tee "the local_filesize -$local_fileSize-"
posh-tee "latest web -$web_fileSize- local -$local_fileSize-"
$testy.close;

$compares= @{
    fileName = $NPE.fileName
    local_version = $local_fileSize
    web_version = $web_fileSize
	dwnld = $NPE.dwnld
}
Comparison @compares

return $NPE

}

	$AllNPElatest = @{
	Url = ( '' )
	filePath = (  findFilePath NPE )
	fileName = ( Get-NPE_url( $NPE.url ) )
	}
