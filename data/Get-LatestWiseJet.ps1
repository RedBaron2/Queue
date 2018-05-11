
	. (Join-Path $scriptDir '.\tools\findFilePath.ps1')
	
 function Get-LatestWiseJet() {
 $wisejet = @{}


 $HTML = Invoke-WebRequest 'http://www.wisecleaner.com/download.html'
 $newt = ( $HTML.ParsedHtml.getElementsByTagName('a') | Where { $_.className -eq 'product-name'} | select -first 15 | select -Last 1 ).innertext
 posh-tee $newt
 $HTML.close


 $wisejet.version=$version = $newt -replace('([A-Z]\w+\s+)|([\d+]{3}\s)','')
 posh-tee "wise365 version -$version-"
 $version = $version -replace('\.', '')
 
     if ( $version -ge "1.39") {
     $wisejet.fileName = "WJS${version}.zip"
     $wisejet.dwnld=$true
     # get newchecksum switch
     } else {
     $wisejet.dwnld=$false
     }
 posh-tee "wisejet dwnld -$dwnld-"
     return $wisejet
 }

	$AllWiseJet = @{
	Url = "http://downloads.wisecleaner.com/soft/WJS.zip"
	filePath = ( findFilePath )
	fileName = (Get-LatestWiseJet)
	}