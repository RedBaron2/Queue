	
	. (Join-Path $scriptDir '.\tools\findFilePath.ps1')
	
 function Get-LatestWiseCare() {
 $wise = @{}


 $HTML = Invoke-WebRequest 'http://www.wisecleaner.com/download.html'
 $newt = ( $HTML.ParsedHtml.getElementsByTagName('a') | Where { $_.className -eq 'product-name'} | select -first 1 ).innertext
 posh-tee $newt
 $HTML.close


 $wise.version=$version = $newt -replace('([A-Z]\w+\s+)|([\d+]{3}\s)','')
 posh-tee "wise365 version -$version-"
 
     if ( $version -ge "4.53") {
     $wise.fileName = "WiseCare365.zip"
     $wise.dwnld=$true
     # get newchecksum switch
     } else {
     $wise.dwnld=$false
     }
 posh-tee "wise dwnld -$dwnld-"
     return $wise
 }
 
	$AllWise365 = @{
	Url = "http://downloads.wisecleaner.com/soft/WiseCare365.zip"
	filePath = ( findFilePath )
	fileName = (Get-LatestWiseCare)
	}