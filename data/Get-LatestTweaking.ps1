	
	. (Join-Path $scriptDir '.\tools\findFilePath.ps1')
	
 function Get-LatestTweaking() {
 $tweaking = @{}
 $HTML = Invoke-WebRequest 'http://www.tweaking.com/articles/pages/tweaking_com_windows_repair_change_log,1.html'
 $newt = ( $HTML.ParsedHtml.getElementsByTagName('div') | Where { $_.className -eq 'content'} ).innertext
 $HTML.close
 # $i=0
 # foreach ($toad in $newt) {
 # $i++
 # if ( $i -eq '8') { $log = ( $toad | Select -First 1 ) }
 # }
 # $vers = $log -split "`n"
 $version = $newt | where { $_ -match "(\d+\.?){3}" } | foreach { $matches[0] }
 posh-tee "A -$version- tweaking version"
 $vers=$verst = ( $version -replace('v',''))
 posh-tee "-$version- tweaking version"
 $file_version = $verst -replace('\.','') # modification as cya of versioning for download on 2017-06-30
     if ( $version -ge "3.9.17") {
     # move Extraction to this file
     # use Extraction to get current file Version
     # compare file to website
     $tweaking.fileName = "tweaking.com_windows_repair_aio_${file_version}.zip"
     $dwnld=$tweaking.dwnld=$true
     $tweaking.version = $verst
     # get newchecksum switch
     } else {
     $dwnld=$tweaking.dwnld=$false
     #break;
     }
 posh-tee "tweaking dwnld -$dwnld-"
 posh-tee "tweaking vers -$vers-"
     return $tweaking
 }
 
	$AllTweakingAIO = @{
	Url = "http://www.tweaking.com/files/setups/tweaking.com_windows_repair_aio.zip"
	filePath = ( findFilePath )
	fileName = ( Get-LatestTweaking )
	}