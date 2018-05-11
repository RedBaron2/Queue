	
	. (Join-Path $scriptDir '.\tools\findFilePath.ps1')
	 
function Get-DDUVersion() {
param(
    [string]$file
)

    $scriptName = $MyInvocation.MyCommand.Name
    $shortName = $scriptName.Substring(4,3)
    $packageName = $scriptName -replace('Get-','')
    $packageName = $packageName -replace('Version','')
    $DDU = @{}
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
    posh-tee "Getting Vitals for $shortName"
    $timey = (Get-Vitals -package "$packageName")
    posh-tee "Vitals are stored in -$shortName-"
    $version = $timey.Version
    posh-tee "version is -$version-"
    posh-tee "URL is $timey.URL"
    $url = $timey.URL
    posh-tee "url is $DDU.url"
    } else {
    $releases = 'https://www.wagnardsoft.com/forums/viewforum.php?f=5&sid=103e37af8e874ed0b0c2966afa5edac4'
    $regex = '(\d+\.\d+\.\d+\.\d+)'
    [System.Net.ServicePointManager]::SecurityProtocol = 'Ssl3,Tls,Tls11,Tls12' #https://github.com/chocolatey/chocolatey-coreteampackages/issues/366
    $HTML =  (Invoke-WebRequest -UseBasicParsing -Uri $releases).Links | where {($_ -match $regex)} | select -First 1
    $DDUwebVersion=$version = $Matches[0];
    $DDU.version = $version;
    $url = "http://www.wagnardsoft.com/DDU/download/DDU%20v${version}.exe"
    $file = "DDU%20v${version}.exe"
    posh-tee "DDUwebVersion -$version- url -$url-" 
    }
    if ( $version -ge '17.0.6.9' ) {
        $DDU.fileName = "DDU v${version}.exe";
        $DDU.dwnld = $true;
        $DDU.url = $url;
    } else {
        $DDU.dwnld=$false;
    }
    posh-tee "DDU dwnld -$dwnld-"
    return $DDU
}
	$AllDisplayDriverUninnstaller = @{
	Url = ( '' )
	filePath = ( findFilePath )
	fileName = ( (Get-DDUVersion) )
	}