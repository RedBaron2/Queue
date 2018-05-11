<#

Script:         Norton Power Eraser (NPE) Helper
Description:    This will check for the latest version of NPE and download it if the local version is not the latest.
Author:     RBZ
Changelog: 

Version: 0.18.2.2
Changes:
Semver versioning
Added KVRT/NPE switch with array return
Added hashtable return of local, web, and dwnld

Version: 0.18.01.27
Changes: Added param of dwnld
Added pos/vars for check through filename
Added additional posh-tee diagnostics text


Original Writeup
Version: 0.17.09.05b

#>
function Get-FileVersion {
param(
    [string]$a
)

 if (( Test-Path $a )) {
$fileVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo( "$a" ).FileVersion
}

return @{
    fileVersion = $fileVersion;
    fileName = $a
    }
}

function Comparison  {
param(
    [string]$fileName,
    [string]$local_version,
    [string]$web_version,
	[string]$dwnld=$false
)
	$pos = $fileName.IndexOf(".")
	$vars = $fileName.Substring(0,$pos)
    if (( $local_version -ne $null ) -or ( $web_version -ne $null ) -or ( $fileName -ne $null ) -or ( $local_version -ne '' ) -or ( $web_version -ne '' ) -or ( $fileName -ne '' ) ) {
        if ( $local_version -eq $web_version ){
        posh-tee "#yellow#$fileName# -$local_version- is the same as the -$web_version-- dwnld -$dwnld-"
		$dwnld=$false;
        } else {
		posh-tee "#yellow#$fileName# -$local_version- does not equal the -$web_version- dwnld -$dwnld-"
		$dwnld=$true;
		}
    }
	posh-tee "#yellow#$fileName# download to be -$dwnld-"
	switch -w ( $vars ) {
		'kvrt' {
			$KVRT = @{
            dwnld = $dwnld
            web_size = $web_version
            local_size = $local_version
            }
			return $KVRT
		}
		'npe' {
			$NPE = @{
            dwnld = $dwnld
            web_size = $web_version
            local_size = $local_version
            }
			return $NPE
		}
	}
    
}


Function Format-FileSize() {
    Param ([int]$size)
    If     ($size -gt 1TB) {[string]::Format("{0:0.00} TB", $size / 1TB)}
    ElseIf ($size -gt 1GB) {[string]::Format("{0:0.00} GB", $size / 1GB)}
    ElseIf ($size -gt 1MB) {[string]::Format("{0:0.00} MB", $size / 1MB)}
    ElseIf ($size -gt 1KB) {[string]::Format("{0:0.00} kB", $size / 1KB)}
    ElseIf ($size -gt 0)   {[string]::Format("{0:0.00} B", $size)}
    Else                   {""}
}
