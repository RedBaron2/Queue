	
	. (Join-Path $scriptDir '.\tools\findFilePath.ps1')
	
 function Get-LatestTronScript() {
 $tronscript = @{}
 $preURL = 'https://bmrf.org/repos/tron/'
 $chk_file = 'sha256sums.txt'
 $myURL = $preURL + $chk_file
 $tron_file = "${env:temp}\wc365_tron.txt"
 $HTML = Invoke-WebRequest $myURL -OutFile $tron_file
 $newt = ( Get-Content $tron_file | Select-Object -last 1 )
 posh-tee $newt
 $tron_file | Remove-Item -Force
 $HTML.close
 $data = $newt -split( ',' )
 $fileName = $data[2]
 $ver = $fileName -replace( 'Tron v', '' );
 $vers = $ver -replace( '.exe', '' );
 $vers = $vers -replace( '\s', '' );
 $versy = ( $vers -replace( '[(][0-9]{4}\-[0-9]{2}\-[0-9]{2}[)]', '' ) );
 $checksum = $data[1].ToUpper();
 # $global:myURL = $preURL + $fileName;
 $version = $versy;
 posh-tee "tronscript version -$version-"
 posh-tee "checksum $checksum // file $fileName"
 
     if ( $fileName -ge "Tron v10.0.0 (2017-02-09).exe") {
     $tronscript.fileName = $fileName;
     $tronscript.dwnld = $true;
     $tronscript.url = $preURL + $fileName;
     $tronscript.chksum = $checksum;
     } else {
     $tronscript.dwnld=$false;
     }
 posh-tee "Tronscript dwnld -$dwnld-"
 posh-tee "Tronscript checksum -$checksum-"
     return $tronscript
 }
 
	$AllTronscript = @{
	Url = ( '' )
	fileName = ( Get-LatestTronScript )
	filePath = ( findFilePath Tron )
	}