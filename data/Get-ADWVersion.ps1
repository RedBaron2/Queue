	
	. (Join-Path $scriptDir '.\tools\findFilePath.ps1')
	 
function Get-ADWVersion( $bits ) {
    $scriptName = $MyInvocation.MyCommand.Name
    $shortName = $scriptName.Substring(4,3)
    $packageName = $scriptName -replace('Get-','')
    $packageName = $packageName -replace('Version','cleaner')
    $adw_regex = '\D+\.(\d+\.)\D*';
 $ADW = @{}
    posh-tee "starting check for Get-Vitals"
    $think = ( [bool](Get-Command -Name "Get-Vitals" -ErrorAction SilentlyContinue) )
    <#
    function Check-Command($cmdname)
    {
        return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
    }
    #>
    posh-tee "Think is -$think-"
  if ($think){
    posh-tee "Getting Vitals for -$shortName-"
    $timey = (Get-Vitals -package "$packageName")
    # posh-tee "Vitals are stored in -$DDU-"
    $n2=$actual_version = $timey.Version
    posh-tee "version is -$actual_version-"
    # posh-tee "URL is $timey.URL"
    $toad = $timey.URL
    posh-tee "url is $toad"
    } else {
 [System.Net.ServicePointManager]::SecurityProtocol = 'Ssl3,Tls,Tls11,Tls12'
 $tempDir = ( get-content env:temp );
 $preUrl = 'https://toolslib.net'
 $test = Invoke-WebRequest "${preUrl}/downloads/finish/1/"
 $newt = ( $test.ParsedHtml.getElementsByTagName('p') | Where { $_.className -eq 'text-muted text-wrap'} ).innertext;
 $toad = ($test.Links | Where { $_.innerHTML -eq 'Click here!'} ).href;
 posh-tee "A The toad -$toad-"
 # Check to see if toad has https  added on 17-08-10
 if (!( $toad -match 'https://')) {
 $toad = $preUrl + $toad
 posh-tee "B The new toad -$toad-"
 }
 $checksum = ( $newt -split 'SHA-256 checksum : ' )
 $newest = ( $test.ParsedHtml.getElementsByTagName('div') | Where { $_.className -eq 'page-header'} ).innertext;
 $test.close;
 $actual_version=$n2= $newest -replace('([A-Z])\w+|([a-z])\w+|([()])|\s+','');
 # $reg_digit = '([\d]{1}\.[\d]{3})';
 # $n1 = $newest -replace '&period;','.'
 # $n2 = $n1 -replace '\D+(\d+.)\D*','$1'
 # posh-tee "n1 -$n1- n2 -$n2-"
 # $n2 = $n2 -replace '\) ',''
 $actual_version = $n2 -replace( $adw_regex,'$1')
 # $actual_version = $n2 -replace( '\.','')
 }
 posh-tee "actual_version -$actual_version- n2 -$n2-"
 $file = ( $bits + '\' + "adwcleaner_$actual_version.exe" )
	# if (!(Test-Path $file)) {
	# posh-tee "We are testing for $file now`r`n"
		# New-Item -ItemType "file" -Force -Path $file
	# }
 if (( Test-Path $file )) {
 $adw_version = ( [System.Diagnostics.FileVersionInfo]::GetVersionInfo( $file ) ).FileVersion
 $adw_version = $adw_version -replace( $adw_regex,'$1')
 }
 posh-tee "ADWcleaner version -$adw_version- actual_version -$actual_version-"
 
 # if ( $actual_version -ge "6040" ) {
 if ( $adw_version -ge $actual_version ) {
 $ADW.fileName = "adwcleaner_$actual_version.exe";
 $ADW.dwnld = $true;
 $ADW.url = $toad;
 } else {
 $ADW.dwnld=$false;
 }
 posh-tee "ADWcleaner dwnld -$dwnld-"
 return $ADW
}

	$AllADWcleaner = @{
	Url = ( '' )
	filePath = ( findFilePath ADW )
	fileName = ( Get-ADWVersion( findFilePath ADW ) )
	}