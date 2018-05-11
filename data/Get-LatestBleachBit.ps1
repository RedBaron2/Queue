	
	. (Join-Path $scriptDir '.\tools\findFilePath.ps1')
	
 function Get-LatestBleachBit() {
 # Set-Alias posh-tee Write-Host
 $BleachBit = @{}
    $BleachBit.dwnld=$false;

    $releases = 'https://www.bleachbit.org/download/windows'
    $betas = 'https://download.bleachbit.org/beta/'
    $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing
    $filename = ($download_page.links | ? href -match '.zip$' | select -First 1 -expand href).Replace('/download/file/t?file=', '')
    $version = $filename -split '-' | select -First 1 -Skip 1

  try {
    # try figuring out if this is a beta release or a normal release.
    $test_page = (iwr -UseBasicParsing "https://bleachbit.org/news/bleachbit-$($version -replace '\.','')" -Method Head)
  }
  catch {}

  if (!$test_page) {
    # Until beta links works again we ignore beta releases
    $beta_page = iwr -UseBasicParsing "https://bleachbit.org/news/bleachbit-$($version -replace '\.','')-beta" -Method Head
  }

  if ($beta_page) {
    $filename = "beta/$version/$filename"
    $version = $version + "-beta"
  }

 posh-tee "BleachBit version -$version-"
 posh-tee "checksum $checksum // file $fileName"
  $BleachBit = @{
    # Version = $version
    dwnld = $true;
    fileName = $fileName
    url   = 'https://download.bleachbit.org/' + $filename
  }
 
     return $BleachBit
 }
 
 #( Get-LatestBleachBit )
 
	$AllBleachBit = @{
	Url = ( '' )
	fileName = ( Get-LatestBleachBit )
	filePath = ( findFilePath )
	}