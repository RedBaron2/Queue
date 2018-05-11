<#

Script:         Kasperksy Virus Removal Tool (KVRT)
Description:    This will check for the latest version of KVRT and download it is the local version is not the latest.
Author:     RBZ
Changelog: 

Original Writeup
Version: 0.17.09.05
Changes:
Original Copy from the finished NPE version
    
Version: 0.18.01.27
Changes:
Adjusted URL to development for KVRT
Added test for file if else

Version: 0.18.2.4-d
Changes:
Adjusted KVRT to be unified hashtable instead of separate lines
Adjusted to have hashtable Adds for size(s)

NOTES:
    Work on having size variables be defined all at once
    Work on merging the KVRT/NPE scripts into one script

#>
	
	. (Join-Path $scriptDir '.\tools\findFilePath.ps1')	
	. (Join-Path $scriptDir '.\data\Get-NPE_helpers.ps1')
	 
# Set-Alias posh-tee Write-Host

$KVRT = @{
url = 'http://devbuilds.kaspersky-labs.com/devbuilds/KVRT/latest/full/KVRT.exe'
fileName = "KVRT.exe"
filePath = findFilePath NPE
# dwnld=$false;
}
function Get-KVRT_url {
param(
    [string]$url
)

# $test = Invoke-WebRequest $url
# $newt = ( $test.ParsedHtml.getElementsByTagName('a') | Where { $_.className -eq 'offset-btn-npenbrt'} ).href;
# $toad = $newt | select -First 1
# $KVRT.url = $toad;
$toad=$KVRT.url = $url;
posh-tee " The toad -$toad-"
$test.close

$testy = Invoke-WebRequest -Method Head $url -UseBasicParsing
$web_fileSize = Format-FileSize( ($testy.Headers['Content-Length']) )
$KVRT.Add = ( "web_size" , "$web_fileSize")
posh-tee "the web_filesize -$web_fileSize-"
$file = $KVRT.filePath + "\" + $KVRT.fileName
posh-tee "file -$file-"
if (Test-Path $file) {
$local_fileSize = Format-FileSize( (Get-Item $file).length );
} else {
$local_fileSize = Format-FileSize( "0.0" );
}
$KVRT.Add = ( "local_size" , "$local_fileSize" )
posh-tee "the local_filesize -$local_fileSize-"
posh-tee "latest web -$web_fileSize- local -$local_fileSize-"
$testy.close;

$compares= @{
    fileName = $KVRT.fileName
    local_version = $local_fileSize
    web_version = $web_fileSize
	dwnld = $KVRT.dwnld
}
Comparison @compares

return $KVRT

}

	$AllKVRTlatest = @{
	Url = ( '' )
	filePath = (  findFilePath NPE )
	fileName = ( Get-KVRT_url( $KVRT.url ) )
	}
