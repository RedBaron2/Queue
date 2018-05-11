	# Set-Alias posh-tee Write-Host
#	. (Join-Path $scriptDir '.\tools\findFilePath.ps1')
	
 function Get-LatestCrystalDiskInfo() {
 $CrystalDiskInfo = @{}
 Set-Alias posh-tee Write-Host
 $preURL = 'http://crystalmark.info'
 $chk_file = '${preURL}/en/download/'
 # History or Changelog
 $changelog = "$preURL/en/software/crystaldiskinfo/crystaldiskinfo-history/"
 # to get latest version number
 $ver_regex = '(\d+\.\d+\.\d+)\s(\[\d+\/\d+\/\d+\])'
 $CL_html = Invoke-WebRequest $changelog
 $version = $CL_html | foreach { $_ -match $ver_regex } | select -First 1
 $CL_vers = $Matches[1]
 $CL_html.close
 posh-tee "CL_vers -$CL_vers-"
 # convert CL_vers to have underscores instead of periods
 $version_with_underscores = $CL_vers -replace('\.','_')
 $fileName = "CrystalDiskInfo${version_with_underscores}.zip"
 # Download of portable version
 # $portable = "http://pumath.dl.osdn.jp/crystaldiskinfo/68126/$fileName"
 # $portable = "https://osdn.net/frs/redir.php?m=gigenet&f=crystaldiskinfo%2F68590%2F$fileName"
 $portable = "http://gigenet.dl.osdn.jp/crystaldiskinfo/69241/$fileName"
 posh-tee "portable -$portable-"
 posh-tee "CrystalDiskInfo version -$version-"
 posh-tee "checksum $checksum // file $fileName"
 
     if ( $fileName -ge "CrystalDiskInfo1_0_0.zip") {
     $CrystalDiskInfo.fileName = $fileName;
     $CrystalDiskInfo.dwnld = $true;
     $CrystalDiskInfo.url = $portable;
     } else {
     $CrystalDiskInfo.dwnld=$false;
     }
 posh-tee "CrystalDiskInfo dwnld -$dwnld-"
 #posh-tee "CrystalDiskInfo checksum -$checksum-"
     return $CrystalDiskInfo
 }
 
<#
    ( Get-LatestCrystalDiskInfo )
    Helper script from malwarebytes package. This will get the download url from the redirect
    ( Get-HttpResponseUri "http://crystalmark.info/redirect.php?product=CrystalDiskInfo" ).OriginalString 
    This method may be faster in the long run
#>
 
	$AllCrystalDiskInfo = @{
	Url = ( '' )
	fileName = ( Get-LatestCrystalDiskInfo )
	filePath = ( findFilePath )
	}
