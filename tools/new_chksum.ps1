
	. (Join-Path $scriptDir '.\tools\posh-tee.ps1')
    
function new_chksum() {
param(
[string]$chksum_log,
[string]$filejack,
[string]$LocalPath,
[bool]$filejack_mark
)
posh-tee "log -$chksum_log- fj -$filejack- LP -$LocalPath-"
# (( Get-FileHash -Path $LocalPath ).SHA256)

if ( $filejack_mark ) {
posh-tee "-$filejack_mark- is set to true"
( '$my_chcksums.Add( "' + $filejack + '" , "' + (( Get-FileHash -Path $LocalPath ).SHA256) + '" ); #' + "Added on $Date" + '' | Out-File -encoding utf8 -Append $chksum_log )
posh-tee "new entry added to my_chcksums"
# $writenewchksum = $false;
} else {
( Get-Content $chksum_log ) | ForEach-Object {
posh-tee "getting content of -$chksum_log- now"
    if ( $_ -match $filejack ) {
    Write-Host "A - $_ -"
    posh-tee "A - $_ -"
    ( $_ -replace "([A-Fa-f0-9]{64})", (( Get-FileHash -Path $LocalPath ).SHA256) )
    Write-Host "B - $_ -"
    posh-tee "B - $_ -"
    } else {
    $_
    Write-Host "C - $_ -"
    posh-tee "C - $_ -"
    }
    Write-Host "D - $_ -"
    posh-tee "D - $_ -"
} | Set-Content $chksum_log
posh-tee "done replacing contents​ of $chksum_log now"
}
                   
}
