	
	. (Join-Path $scriptDir '.\tools\findFilePath.ps1')
	
$CCLE = @{}
function Get-LatesCCLE () {
param(
    [parameter(Mandatory=$true, Position=0)]
    [string]$url,
    [string]$tag,
    [int]$count
)

if (( $tag -eq '' ) -or ( $tag -eq $null )) { $tag = 'p'; }
posh-tee "tag is -$tag-"
if ( $url -match 'builds' ) {
  [System.Net.ServicePointManager]::SecurityProtocol = 'Ssl3,Tls,Tls11,Tls12' #https://github.com/chocolatey/chocolatey-coreteampackages/issues/366
}
 $HTML = Invoke-WebRequest $url
 #$newt = ( $HTML.AllElements | Where {$_.TagName -eq "p"} ).innertext
 $newt = ( $HTML.AllElements | Where {$_.TagName -eq $tag } ).innertext

 $HTML.close
 $news = @()
 $news = $newt -split "kb";$i=0;
    foreach ( $_ in $news ) {
      $i++;$_ = $_ -replace(" - ", "" );
        if ($i -eq $count) {
			#Write-Host [$i] [$_];
			posh-tee "CCLE.fileName [$_]"
			$CCLE.fileName=$_;
        };
    };
 # $CCLE.dwnld=$true
 return $CCLE
}


$newr_version = ((Get-LatesCCLE "https://www.piriform.com/ccleaner/version-history" -tag "h6" -count "1" ).filename ) -match "(\d+\.)?(\d+\.)?(\*|\d+)"
$website_version = $Matches[0]

# Adjustment of script on 17-06-06 to use Extraction for versioning differances
        if ( $website_version -ge '5.30.6063' ) {
        $chk_ccle = $true;
        # Extraction of file ccleaner to get proper version and be definative of needing to download
		$fnCCLE = ((Get-LatesCCLE "https://www.piriform.com/ccleaner/builds" -count "4" ).filename )
        # Catch to detect if build is released
        posh-tee "filename -$fnCCLE-"
        if ( $fnCCLE -NotMatch "zip" ) {
        posh-tee "We are going to break now`n`r This release is not yet available."
        $chk_ccle = $false; $CCLE.dwnld = $false;
        }
        if ( $chk_ccle ) {
		$fpCCLE = ( findFilePath )
        $LocalPath = ($fpCCLE+'\'+$fnCCLE)
		posh-tee "This is the Extraction LocalPath -$LocalPath-"
			$extArgs = @{
			archive = "$LocalPath"
			output_dir = "${env:temp}\few"
			output_file = "CCleaner.exe"
			}
		$Extraction_version = (( Extraction @extArgs ))
					posh-tee "website version -$website_version-"
					posh-tee "Extraction_version -$Extraction_version-"
        posh-tee "The website_version -$website_version-, and needs to be downloaded"
		posh-tee "We have detected #green#ccleaner# has an #red#update#"
		posh-tee "website_version new -$website_version-"
        if ($extArgs) { clear-variable -name extArgs }
        $CCLE.dwnld=$true;
        }
         }
 
 
	$AllCCleaner = @{
	Url = "https://www.piriform.com/ccleaner/download/portable/downloadfile"
	filePath = ( findFilePath )
    filename = (Get-LatesCCLE "https://www.piriform.com/ccleaner/builds" -count "4" )
	}
