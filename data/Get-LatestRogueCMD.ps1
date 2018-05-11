	
	. (Join-Path $scriptDir '.\tools\findFilePath.ps1')
	
function Get-RKversion {
$web = @{};
$r = Invoke-WebRequest( 'http://www.adlice.com/download/roguekillercmd/' )
$data = $r.parsedhtml.getelementsbytagname("TR") #this part seems to work fine
$table = @()
forEach($datum in $data){
	if($datum.tagName -eq "tr"){
		$thisRow = @()
		$cells = $datum.children
		forEach($cell in $cells){
			if($cell.tagName -eq "td"){
				$thisRow += $cell.innerText
			}
		}
		$table += $thisRow
	}
}
$regex = '(\d(\.\d)*)';
foreach ( $chk in $table ) {
if ( $chk -match $regex ) {
$version = $chk
break;
}
}
$r.close
$web.Add( 'version', $version );
return $web
}

function Get-ChangeLogVersion() {
$vert = @{};
$RK_regex = '([\d]{0,4}[\.][\d]{0,4}[\.][\d]{0,4})';
$vers = ''
$source = "http://download.adlice.com/api/?action=download&app=roguekiller&type=changelog"
$destination = "$env:userprofile\desktop\RK_changelog.txt"

$test = Invoke-WebRequest $source -OutFile $destination
$i=0
Get-Content $destination | Foreach-Object { $i++; if ( $i -eq '10' ) { $version=($_) } }
$test.close
$v = $version -match $RK_regex
posh-tee "v -$v-"
$vers = $Matches[0] + ".0"
posh-tee "vers -$vers-"
$vert.Add( 'version', $vers )
del $destination
# posh-tee "needle has a space -$vers- matches -$Matches-"
# $needle = $vers -match $RK_regex
# posh-tee "needle after cleaning -$needle- matches -$Matches-"
# return $needle

return $vert
}

function CompareVersions {
param(
	# [string]$changelog,
	# [string]$website,
	[string]$ternary
)
$website = (Get-RKversion).version
$changelog = (Get-ChangeLogVersion).version
#$ternary = 32
	$site = 'http://www.adlice.com/download/roguekillercmd/'
	$test = Invoke-WebRequest $site
	$toad = ($test.Links | Where { ( $_.innerText -match 'Download' )} | select -Skip 2 -First 2 ).href
	$url = $toad[1]
#posh-tee "url -$url-"
	$file = @{$true="RogueKillerCMD.exe";$false="RogueKillerCMDX64.exe"}[ $ternary -eq "32" ]
#posh-tee "file -$file-"
	
$RK = @{};
posh-tee "start website -$website- changelog -$changelog-"
if ( $website -eq $changelog ) {
posh-tee "we match"
$needle = $changelog;
} else {
posh-tee "we do not match"
posh-tee "the website -$website- doesn't eq changelog -$changelog- making command decision to follow changelog -$changelog-"
$needle = $changelog;
}
posh-tee "Now to compare fileversion to the Internet version or needle -$needle-"
$pathtofile = (findFilePath rogue)
$fileA = $pathtofile + '\' + $file
posh-tee "pathtofile -$pathtofile- fileA -$fileA-"
if (!( Test-Path $fileA ) ) {
$rogue32 = "0.0.0";
# del $fileA;
} else {
$rogue32 = ( [System.Diagnostics.FileVersionInfo]::GetVersionInfo( $fileA ) ).ProductVersion;
}
posh-tee "rogue32 -$rogue32-"
if ( $needle -ne $rogue32 ){
posh-tee "$needle ne $rogue32 need to download file"
if (( Test-Path $fileA ) ) {
del $fileA;
posh-tee "$fileA has been removed before download of new file."
}
$RK.fileName = $file
$RK.dwnld=$true;
$RK.url = $url;
} else {
posh-tee "$needle eq $rogue32 don't need to download file"
$RK.fileName = $file
$RK.dwnld=$false;
$RK.url = $url;
}
 return $RK

}	
	$AllRogueKillerCMD32 = @{
	Url = ( '' )
	fileName = ( CompareVersions 32 )
	filePath = ( findFilePath rogueCMD )
	}	
	$AllRogueKillerCMD64 = @{
	Url = ( '' )
	fileName = ( CompareVersions 64 )
	filePath = ( findFilePath rogueCMD )
	}



