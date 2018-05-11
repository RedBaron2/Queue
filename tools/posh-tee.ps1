
	. (Join-Path $scriptDir '.\tools\write-chost.ps1')
	
$goodMSG=" * We Are #green#GOOD# *"
$badMSG=" ! We Are #magenta#BAD# !"
$Date = (Get-Date -format "yyyy-MM-dd HH:mm:ss")
# $Time = ( Get-Date -Format g ) + " "
$Time = $Date + " "

$myDir = "${env:temp}\queue"

function posh-tee( $a ) {
$a = $Time + $a
if ( $Mychecksums ) { $a | Out-File -Append "$myDir\chksum.log" }
if ( $diagnostics ) { write-chost $a }
if ( ($a -match 'We Are #') -or ($a -match 'Version:') ) {
( $a | Out-File -Append $simp_log );
write-chost $a;
}
$a | Out-File -Append $diag_log
}

$me = ($MyInvocation.MyCommand.Name).log
if ( $me -eq $null ) { $me=(${env:computername}) }
# BOL Check for existence of log files
$diag_log = "$myDir\$me" + "_diag_log" + ".log"
	if (!(Test-Path $diag_log)) {
	posh-tee "We are testing for $diag_log now`r`n"
		New-Item -ItemType "file" -Force -Path $diag_log
	}
$simp_log = "$myDir\$me" + "_simp_log" + ".log"
	if (!(Test-Path $simp_log)) {
	posh-tee "We are testing for $simp_log now`r`n"
		New-Item -ItemType "file" -Force -Path $simp_log
	}
# EOL Check for existence of log files

#posh-tee -$me-
