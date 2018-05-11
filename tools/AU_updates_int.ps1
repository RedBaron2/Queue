

function Get-Vitals {

param(
    [string]$package
)
    if ( $package ) {

        $PoshDir = 'C:\Users\CCtech\Desktop\mv_removers\apps\packages\'

        $directory = "$PoshDir$package"

        Push-Location $directory

        . "$directory\update.ps1" | Out-Null
        if ( Test-Path $directory\update_helper.ps1 ) {
        . "$directory\update_helper.ps1" | Out-Null 
        }

        $time = @{}
        if (($diagnstics)) {
        $time.alpha = "start of $package"
        }

        $time.URL = $Latest.URL32
        if ( $Latest.URL64 ) {
        $time.URL64 = $Latest.URL64
        }
        $time.Version = $Latest.Version

        #global:au_GetLatest
        Push-Location $scriptDir

        if (($diagnstics)) {
       $time.omega = "end of $package"
        }
        return $time
    } else {
    break;
    }
}

 # Get-Vitals -package "chromium"
 # Get-Vitals -package "ddu"
 # Get-Vitals -package "ccleaner"
 # Get-Vitals -package "kvrt"

 <#
 Some notes on usagee of this function
 Getting the filename from the download URL is as such
    
 $teft = ( Get-Vitals -package "chromium" ).URL -split "\/"
 $resty = $teft[-1]
 Write-Host "-$resty-"
 #>