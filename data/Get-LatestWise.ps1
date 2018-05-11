
# Set-Alias posh-tee Write-Host
  $releases = 'http://www.wisecleaner.com/download.html'
  $url = 'https://downloads.wisecleaner.com/soft'
function Wiggins {
param(
	[string]$fileName,
	[string]$exactName,
	[string]$Title,
    [string]$place,
    [regex]$regex,
    [string]$breaker = ''
)
$null = .{
	$pos = $fileName.IndexOf(".")
	$URL = "$url/$fileName"
	$HTML = Invoke-WebRequest $releases -UseBasicParsing
	$newt = ( $HTML.links | Where { ($_.href -match $exactName )} ).outerHTML | select -Last 3
    $step = $newt[$place]
    posh-tee "place -$place-"
    posh-tee "step -$step-"
	$HTML.close; $ver = $step -match $regex; $version = $Matches[0]
    posh-tee "ver -$ver-"
    posh-tee "version -$version-"
		if ( ($fileName.Substring(0,$pos)) -ne 'wis' ) {
		$fileName = ($fileName.Substring(0,$pos)) + $breaker + ($version -replace('\.','')) + '.' +($fileName.Substring($pos+1))
		}
}
   	@{    
		# PackageName = $fileName.Substring(0,$pos)
		# Title       = $Title
		# fileType    = $fileName.Substring($pos+1)
		dwnld       = ( Alfie -ver "$version" -FN ($fileName.Substring(0,$pos)) ) 
		fileName    = $fileName
		Version     = $version
		url         = $url
    }
}

function Alfie {
param(
	[string]$ver,
	[string]$FN
)
	switch -w ( $FN ) {
	
		'wisecare*' {
			$base = "4.5.3"
		}
		
		'wjs' {
			$base = "1.3.9"
		}
	}
	
     if ( $ver -ge $base ) {
     $download=$true
     } else {
     $download=$false
     }
 posh-tee "wise -$FN- dwnld -$download-"
     return $download
}
# (Wiggins -fileName 'WJS.zip' -exactName 'JetSearch' -Title 'Wise JetSearch' -place '1' -regex '((\d+\.?){3})')

 # (Wiggins -fileName 'WiseCare365.zip' -exactName 'wise-care-365' -Title 'Wise Care 365' -place '0' -regex '(\d+\.\d+\.\d+)' -breaker '_')
 # (Wiggins -fileName 'WJS.zip' -exactName 'JetSearch' -Title 'Wise JetSearch' -place '1' -regex '((\d+\.?){3})')

	$AllWise365 = @{
	Url = ""
	filePath = ( findFilePath )
	fileName = (Wiggins -fileName 'WiseCare365.zip' -exactName 'wise-care-365' -Title 'Wise Care 365' -place '0' -regex '(\d+\.\d+\.\d+)' -breaker '_')
	}
	$AllWiseJet = @{
	Url = ""
	filePath = ( findFilePath )
	fileName = (Wiggins -fileName 'WJS.zip' -exactName 'JetSearch' -Title 'Wise JetSearch' -place '1' -regex '((\d+\.?){3})')
	}