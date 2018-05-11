
param(
[Parameter(Position = 0)]
[string[]]$queue,
[bool]$chksum_chking,
[bool]$diagnostics,
[bool]$noDelFileonBad,
[bool]$writenewchksum
)

# Setting of All cookie key
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /t REG_DWORD /v 1A10 /f /d 0 | out-null

<#
	Previous Additions
	Added Download Progress

	Version: 0.17.04.22
	First Versioning of Script
	Added params and switches for easier programing

	Version: 0.17.04.25
	Updated Script to use unique files for the tools
	Added RogueKiller to Script as separate calls.
	Queue makes it easy to download both files in one call (ex: .\queue.ps1 rogue32,rogue64 )
	Optional is now 'rogue' for both versions

	Version: 0.17.04.26
	Added new check for log files
	Checks for existence if not then creates file

	Version: 0.17.05.02
	Added $noDelFileonBad for switch to delete bad files
	cleanup of old script blocks
	Added $version to logging

	Version: 0.17.05.04
	Added Log Limiting code
	Should limit simp_log to 300 lines

	Version: 0.17.05.10
	Adjusted RogueKiller detection of newer version file
	this will now delete the older file with logging

	Version: 0.17.05.11
	Added Newer Log Limiting Script
	Should Limit Log to max of 5 simp and 10 diag at 10kb
	Work on only running files needed to complete task -completed- today
	Work on condensing the diagnostic log -somewhat- logs only show for the processes asked not all like it used to show

	Version: 0.17.05.14
	Added Get-FileHash.ps1 to tools for second option of checking
	Added Get-FileHash.ps1 for output to $chksum_log upon first download (:crossed:)

	Version: 0.17.05.16
	Adjusted checksum checking to be its own little hashtable file
	
	Version: 0.17.05.17
	Re-adjusted the use of the checksum hateable verification
	All files use the hashtable, but Tron provides it's Owen checksum for verification ( working_on )
	Added IE terminating section of code
	
	Version: 0.17.05.22a
	Adjusted code in Rogues to always follow changelog version (command decision)
	Added new_chksum.ps1 file for adjusting for new Checksums
	
	Version: 0.17.05.29a
	Adjusted writenewchksum to be more automated
	Added more diagnostic lines for error log reporting
	Need to make function to work on testing checksum for newness
	
	Version: 0.17.05.31d
	Added code for the removal of tweaking file so latest can be downloadedBytes
	auto writenewchksum should adjusted checksum for the file
	
	Version: 0.17.06.01c
	Added Extraction for the re-download of tweaking everytime loop
	Created Extraction to check for the fileVersion of tweaking
	
	Version: 0.17.06.04d
	Adjusted Extraction for the triple checking of a fileVersion
	
	Version: 0.17.06.09d
	Added BleachBit portable to queue
	Adjusted new_chksum with check for appending chksum_log via filejack_mark
    
    Version: 0.17.06.13b
    Changed chksum_log to be a definative path

	Version: 0.17.06.21c
	Updated Extraction to have a switch handling of output_file
	Added WiseCare365 Extraction call
	Re-Adjusted Placement of IE reg keys mainly for ccleaner
    
	Version: 0.17.06.29b
	Added Wise Jet Search aka WiseJet to the list
    Adjusted version to wisejet fileName in Get-LatestWiseJet
	
    Version: 0.17.06.30b
    Adjusted version to tweaking fileName in Get-LatestTweaking
    Added default to Get-FileFromWeb fileName switch
    Adjusted new_chksum to add $Date to end of new writen checksums
	
	Version: 0.17.07.07b
	Adjusted with (new) switch the detection of $fn for Extraction checking no default set
	
	Version: 0.17.07.12c
	Updated the (new) switch to have a secondary check for execution
	
	Version: 0.17.07.25e
	Adjusted regex to match better for tweaking extraction version number
    
    Version: 0.17.07.27c
    Added the fetching of Display Driver Uninstaller aka DDU
    Adjusted Extraction to find fileVersion of DDU
	
	Version: 0.17.08.04b
	Added DDU Offically with some minor adjustments
	Adjusted Roguekiller into one data file
		
	Version: 0.17.08.31a
	Moved Extraction into its own file under tools
    
	Version: 0.17.09.05d
    Changed the Version variable for less duplication
    Added the fetching of Norton Power Eraser aka NPE
    NPE uses the file size to compare unlike the others
    NPE uses its own helper script as of right now
    
    Version: 0.17.12.14b
    Adjustments to CCLE for missing fileName
    Adjustments to default on final switch
    Added Search filters for both
#>
    $version = '0.18.01.05c'
<#
    Updated Wise group of portables for future proofing
	Adjusted queue to use the single file for Wise
	LatestWise uses similiar script to AU update
	First Update to queue for 2018
	
	To Do:
    Work on deletion of older versions of files (ex: ccsetup*/WJS*/tweaking.com_windows_repair_aio*)
    Work on version to wise365 fileName in Get-LatestWiseCare ( Then adjust config_ini code )
    Work on Extraction check for WiseJet
	Work on double check for Tron checksum
	Work on moving all IE terminating as own file ( file conner.ps1 aka terminator )
	Work on Checksum chk/log pulling Checksum for compare to determine newness ( done via Extraction function)
	Work on changing checksum in hashtable/file (done via new_chksum function)
	Work on Adding all checksum functions being on file (done via new_chksum function)

#>
# $version = '0.17.09.05a'
# $chksum_log = '.\tools\chksum.ps1'


# Import function(s) to load the required scripts for the Tools
$scriptDir = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
	# . (Join-Path $scriptDir '.\tools\posh-tee.ps1')
	# . (Join-Path $scriptDir '.\tools\findFilePath.ps1')
	# . (Join-Path $scriptDir '.\tools\Reset-Log.ps1')
	# . (Join-Path $scriptDir '.\tools\Get-FileHash.ps1')
	# . (Join-Path $scriptDir '.\tools\conner.ps1')
	# . (Join-Path $scriptDir '.\tools\Extraction.ps1')
# Changed this to be a Hashtable array instead of a file
	# . (Join-Path $scriptDir '.\tools\chksum.ps1')
	# . (Join-Path $scriptDir '.\tools\new_chksum.ps1')
    
Get-ChildItem -Path $scriptDir\tools -Filter *.ps1 |ForEach-Object {
    . $_.FullName
}
    
$chksum_log = (Join-Path $scriptDir '.\tools\chksum.ps1')



function Get-FileFromWeb ( $Url, $filePath, $fileName ) {
	posh-tee "url -$Url- fp -$filePath- fn -$fileName-"
	if (( $Url -eq $null ) -or ( $Url -eq '' )) {
		$Url = $fileName.url
		posh-tee "B url -$Url- fp -$filePath- fn -$fileName-"
		# posh-tee "global:myURL $global:myURL "
	}
	# write-host "fileName keys"
	# $fileName | % {$_}
	$website_version = $fileName.version
	$try = $fileName.chksum;
	posh-tee "ng URL -$Url-"
	# posh-tee "A version -$global:version-"
	$fn = $fileName.fileName
	$dwnld = $fileName.dwnld
	$fileName = $fn
	$cached_chksum = ( $my_chcksums.$fn );
	posh-tee "A fileName -$fileName- dwnld -$dwnld-"
	posh-tee "try chksum -$try-"
        
	$LocalPath = $filePath + '\' + $fileName
	posh-tee "start $LocalPath"
	posh-tee "Get-FileFromWeb $LocalPath"
	#if ( $new_file_chksum -eq $file_chksum ) { Write-Host The checksums are valid } else { Write-Host The $file_chksum ne $new_file_chksum }

        # Extraction of file tweaking to get proper version and be definative of downloading
		if ($dwnld) {
		
		posh-tee "We have detected #green#$fn# has an #red#update#"
		posh-tee "website_version new -$website_version-"

			switch -w ($fn) {
					
				"tweaking*" {
					$extArgs = @{
						archive = "$LocalPath"
						output_dir = "${env:temp}\few"
						output_file = "Repair_Windows.exe"
					}
					$update = $true;		
				}
				
				"WiseCare*" {
					$extArgs = @{
						archive = "$LocalPath"
						output_dir = "${env:temp}\few"
						output_file = "WiseCare365.exe"
					}
					$update = $true;
				}
				
				"DDU*" {
					$extArgs = @{
						archive = "$LocalPath"
						output_dir = "${env:temp}\few"
						output_file = "Display Driver Uninstaller.exe"
					}
					$update = $true;
				}
				
				 default { $update = $false; }
			
			}
			
			if ($update) {
			$Extraction_version = ( Extraction @extArgs )
			posh-tee "website version -$website_version-"
			posh-tee "Extraction_version -$Extraction_version-"
				if (( Test-Path $LocalPath )) {
				posh-tee "Detected LocalPath -$LocalPath-"
					if ( $website_version -ne $Extraction_version ) {
					posh-tee "Versions do not equal `
					This will require the deletion of -$LocalPath-"
					del $LocalPath
					posh-tee "We have del -$LocalPath-"
					}
				}
			}
		}


	posh-tee "dwnld is $dwnld"
	#if ( $dwnld ) { $test=(RBZ-DownloadFile $Url $LocalPath); $file=$true } else { $file=$false; }

	if ( $dwnld ) { $rb_dwnld = (RBZ-DownloadFile $Url $LocalPath $dwnld); $test = $rb_dwnld.test; $file = $rb_dwnld.file; }
	if (( $test -eq $null) -or ( $test -eq "" )) { $test = $cached_chksum }
	posh-tee "test is $test"
	posh-tee "#blue#FNT# fn -$fileName- cache -$cached_chksum- test -$test-";

	posh-tee "file is $file"
	#$test = ( Get-FileHash $LocalPath ).hash


	switch -w ( $fileName ) {

        'WiseCare365.zip' {
            if (( $test -ne $null ) -or ( $test -ne "" )) {
            posh-tee "test -$test- dwnld -$dwnld- file -$file-"
            $chksum = @{$true=(( Get-FileHash -Path $LocalPath ).SHA256);$false=( $my_chcksums.Wise_Alt )}[( ($file) )]
            posh-tee "chksum -$chksum-"
            $test = @{$true=( $test );$false=(( Get-FileHash -Path $LocalPath ).SHA256)}[( ($file) )]
            posh-tee "$fileName NEW -$test-"
            if ( $file ) {
                $WC365_dir = "$filePath\Wise Care 365"
                New-Item -ItemType Directory -Force $WC365_dir
                $config_ini = "$WC365_dir\config.ini"
                $config_tray_ini = "$WC365_dir\config_tray.ini"
                $WiseCareConfig = "[General]`rUpdateMode=1`rBootStartup=0`rStartBooster=0`rTurboCheck=0`rCheckNews=0`rContextMenuFileShred=0"
                $WiseCareConfigTray = "[General]`rShowFloatWnd=0"
                $WiseCareConfig | Out-File $config_ini -Encoding ASCII
                $WiseCareConfigTray | Out-File $config_tray_ini -Encoding ASCII
                RemoveCRNL $config_ini
                RemoveCRNL $config_tray_ini
                $chocolatey_tools = "${env:programdata}\chocolatey\tools"
                if (-not (test-path "$chocolatey_tools\7z.exe")) {$err="$chocolatey_tools\7z.exe needed"}
                set-alias 7z "$chocolatey_tools\7z.exe"
                7z u $LocalPath $WC365_dir
                Remove-Item $WC365_dir -Force -Recurse
                posh-tee $err
                $newChkSums = @{
                filejack = "Wise_Alt"
                chksum_log = $chksum_log
                LocalPath = $LocalPath
                }
    #			$filejack = 'Wise_Alt' ;
    #			( '$my_chcksums.Add( "' + $filejack + '" , "' + (( Get-FileHash -Path $LocalPath ).SHA256) + '" );' | Out-File -Append $chksum_log )
                new_chksum @newChkSums
                }
        # $chksum = ($my_chcksums.$fileName);
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG; }
            }
        }

        'WJS*.zip' {
        $chksum = (( Get-FileHash -Path $LocalPath ).SHA256);
        # $chksum = ( $my_chcksums.$fileName );
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG }
        # Need to work on renaming file after download to ccleaner.zip
        posh-tee "$fileName NEW -$test-"
        }

        'BleachBit*.zip' {
        #$chksum = '9CD2C878938048D1128C92235498223BE73072AF3FF5E074165FB845C7546F48';
        $chksum = (( Get-FileHash -Path $LocalPath ).SHA256);
        # $chksum = ( $my_chcksums.$fileName );
        posh-tee "chksum -$chksum-"
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG; }
        # Need to work on renaming file after download to ccleaner.zip
        posh-tee "$fileName NEW -$test-"
        }

        'roguekillerCMD.exe' {
        #$chksum = '9CD2C878938048D1128C92235498223BE73072AF3FF5E074165FB845C7546F48';
        $chksum = (( Get-FileHash -Path $LocalPath ).SHA256);
        # $chksum = ( $my_chcksums.$fileName );
        posh-tee "chksum -$chksum-"
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG; }
        # Need to work on renaming file after download to ccleaner.zip
        posh-tee "$fileName NEW -$test-"
        }

        'roguekillerCMDX64.exe' {
        #$chksum = '9CD2C878938048D1128C92235498223BE73072AF3FF5E074165FB845C7546F48';
        $chksum = (( Get-FileHash -Path $LocalPath ).SHA256);
        # $chksum = ( $my_chcksums.$fileName );
        posh-tee "chksum -$chksum-"
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG; }
        # Need to work on renaming file after download to ccleaner.zip
        posh-tee "$fileName NEW -$test-"
        }


        'roguekiller.exe' {
        #$chksum = '9CD2C878938048D1128C92235498223BE73072AF3FF5E074165FB845C7546F48';
        $chksum = (( Get-FileHash -Path $LocalPath ).SHA256);
        # $chksum = ( $my_chcksums.$fileName );
        posh-tee "chksum -$chksum-"
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG; }
        # Need to work on renaming file after download to ccleaner.zip
        posh-tee "$fileName NEW -$test-"
        }

        'roguekillerX64.exe' {
        #$chksum = '9CD2C878938048D1128C92235498223BE73072AF3FF5E074165FB845C7546F48';
        $chksum = (( Get-FileHash -Path $LocalPath ).SHA256);
        # $chksum = ( $my_chcksums.$fileName );
        posh-tee "chksum -$chksum-"
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG; }
        # Need to work on renaming file after download to ccleaner.zip
        posh-tee "$fileName NEW -$test-"
        }

        'adwcleaner_*.exe' {
        #$chksum = '9CD2C878938048D1128C92235498223BE73072AF3FF5E074165FB845C7546F48';
        $chksum = (( Get-FileHash -Path $LocalPath ).SHA256);
        # $chksum = ( $my_chcksums.$fileName );
        posh-tee "chksum -$chksum-"
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG; }
        # Need to work on renaming file after download to ccleaner.zip
        posh-tee "$fileName NEW -$test-"
        }

        'Tron*.exe' {
        $chksum = $try;
        posh-tee "chksum -$chksum-"
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG }
        # Need to work on renaming file after download to ccleaner.zip
        posh-tee "$fileName NEW -$test-"
        }

        'ccsetup*.zip' {
        $chksum = (( Get-FileHash -Path $LocalPath ).SHA256);
        # $chksum = ( $my_chcksums.$fileName );
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG }
        # Need to work on renaming file after download to ccleaner.zip
        posh-tee "$fileName NEW -$test-"
        }

        'tweaking.com_windows_repair_aio*.zip' {
        $chksum = (( Get-FileHash -Path $LocalPath ).SHA256);
        # $chksum = ( $my_chcksums.$fileName );
        posh-tee "chksum -$chksum-"
        #$chksum = "A2C6101E3C03B253B9880CB582E2B98D187CFCDC455880F095D9757E894D8E56"
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG; }
        posh-tee "$fileName NEW -$test-"
        }
        
        'DDU*.exe' {
        $chksum = (( Get-FileHash -Path $LocalPath ).SHA256);
        # $chksum = ( $my_chcksums.$fileName );
        posh-tee "chksum -$chksum-"
        #$chksum = "A2C6101E3C03B253B9880CB582E2B98D187CFCDC455880F095D9757E894D8E56"
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG; }
        posh-tee "$fileName NEW -$test-"
        }
        
        'NPE*.exe' {
        $chksum = (( Get-FileHash -Path $LocalPath ).SHA256);
        # $chksum = ( $my_chcksums.$fileName );
        posh-tee "chksum -$chksum-"
        #$chksum = "A2C6101E3C03B253B9880CB582E2B98D187CFCDC455880F095D9757E894D8E56"
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG; }
        posh-tee "$fileName NEW -$test-"
        }
        
        'kvrt*.exe' {
        $chksum = (( Get-FileHash -Path $LocalPath ).SHA256);
        # $chksum = ( $my_chcksums.$fileName );
        posh-tee "chksum -$chksum-"
        #$chksum = "A2C6101E3C03B253B9880CB582E2B98D187CFCDC455880F095D9757E894D8E56"
        if ( $test -eq $chksum ) {$msg=$goodMSG } else {$msg=$badMSG; }
        posh-tee "$fileName NEW -$test-"
        }
        
        default {
            if (( $fileName -match "exe" ) -or ( $fileName -match "zip" )) {
                posh-tee "The $fileName has not been found at this time. `n`r We will be evaluating $fileName without a reference at this time.`n`r"
                $chksum = (( Get-FileHash -Path $LocalPath ).SHA256);
                # $chksum = ( $my_chcksums.$fileName );
                posh-tee "chksum -$chksum-"
                $msg='#magenta#Default#'
                #$chksum = "A2C6101E3C03B253B9880CB582E2B98D187CFCDC455880F095D9757E894D8E56"
                if ( $test -eq $chksum ) {$msg+=$goodMSG } else {$msg+=$badMSG; }
                posh-tee "$fileName NEW #magenta#default# -$test-"
            } else {
                posh-tee "fileName -$fileName- does not have a valid extension"
                $msg = "We are a Not Valid"
                $msg+=$badMSG
            }
        }
    
	}

	posh-tee "$fileName $msg"
	if (($msg -eq $badMSG) -and ($noDelFileonBad -ne $true)) { del $LocalPath; } else {}


}

function downloadFile($url, $targetFile)
{
	posh-tee “Downloading --$url--”
	$uri = New-Object “System.Uri” “$url”
	$request = [System.Net.HttpWebRequest]::Create($uri)
	$request.set_Timeout(15000) #15 second timeout
	$response = $request.GetResponse()
	$totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
	$responseStream = $response.GetResponseStream()
	$targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
	$buffer = new-object byte[] 10KB
	$count = $responseStream.Read($buffer,0,$buffer.length)
	$downloadedBytes = $count
	while ($count -gt 0)
	{
	[System.Console]::CursorLeft = 0
	[System.Console]::Write(“Downloaded {0}K of {1}K”, [System.Math]::Floor($downloadedBytes/1024), $totalLength)
	$targetStream.Write($buffer, 0, $count)
	$count = $responseStream.Read($buffer,0,$buffer.length)
	$downloadedBytes = $downloadedBytes + $count
	}
	posh-tee “`nFinished Download”
	$targetStream.Flush()
	$targetStream.Close()
	$targetStream.Dispose()
	$responseStream.Dispose()
}

function RBZ-DownloadFile( $Url, $LocalPath, $dwnld) {
	$dwnlds = @{}
	$filejack = $LocalPath -split '\\'
	$filejack=$filejack[-1]
	posh-tee "filejack -$filejack-"
	posh-tee "RBZ-DownloadFile $LocalPath of -$filejack- -$dwnld-";
	#pause
	$cached_chksum = ( $my_chcksums.$filejack );
	posh-tee "cached_chksum is -$cached_chksum-"
	if ((!( Test-Path $LocalPath )) -and ($dwnld))
	{
	posh-tee "$Time We are off to retrieve $filejack";
	posh-tee "Starting Download of -$filejack-";
	posh-tee "url -$Url- LP -$LocalPath- and dwnld -$dwnld-";
			if ( $filejack -match "rogue" ) {
			$ie = new-object -comobject InternetExplorer.Application
			$ie.visible = $false
			$ie.Navigate($Url)
			# $url = "http://download.adlice.com/RogueKiller/"
			$url = @{$true="http://download.adlice.com/RogueKiller/";$false="http://download.adlice.com/RogueKillerCMD/"}[ (( $filejack -eq "RogueKiller.exe" ) -or ( $filejack -eq "RogueKillerX64.exe" )) ]
			posh-tee "url is -$url- and filejack -$filejack-"
			# 32bit hash as of 11/13/2016 '34C97F4F503527DB1D08A914991BC53C4673C8694FC29FB24EFCE31FCF9D4161'
			#------------------------------
			#Wait for Download Dialog box to pop up
			posh-tee "sleep for 30 now"
			Sleep 35
			while($ie.Busy)
			{
			posh-tee "Sleep for 3 next"
			Sleep 3
			}
			#------------------------------
			posh-tee "Starting Download Fingers Crossed"
			$ActualDwnld_url = $url + $filejack
			downloadFile $ActualDwnld_url $LocalPath
			# $Wget = New-Object System.Net.WebClient
			# $Wget.DownloadFile( $Url, $LocalPath )
			# $Wget.close
			} else {
			downloadFile $Url $LocalPath
			}
		posh-tee "Finishing Download -$filejack-";
		# if ( $chksum_chking ){
			$newest_chksum = (( Get-FileHash -Path $LocalPath ).SHA256)
			if ( $cached_chksum -ne $newest_chksum ) {
				posh-tee "-$filejack- ne -$newest_chksum-";
				# write in space to  check for param variable value
                $filejack_mark = $false ;
                foreach ( $_ in $my_chcksums.keys ) {
                posh-tee "starting check for -$filejack- in -$my_chcksums-"
                    if ( $_ -eq $filejack ) {
                        posh-tee "-$filejack- does exist in -$my_chcksums-"
						$filejack_mark = $false ;
						break;
                    } else {
                        posh-tee "-$filejack- does not exist in -$my_chcksums- setting marker"
                        $filejack_mark = $true ;
                    }
                }
				$writenewchksum = $true;
                   # if ( $filejack_mark ) {
                   # posh-tee "-$filejack_mark- is set to true"
                   # ( '$my_chcksums.Add( "' + $filejack + '" , "' + (( Get-FileHash -Path $LocalPath ).SHA256) + '" );' | Out-File -Append $chksum_log )
                   # posh-tee "new entry added to my_chcksums"
                   # }
        $newChkSums = @{
        filejack = $filejack
        chksum_log = $chksum_log
        LocalPath = $LocalPath
        filejack_mark = $filejack_mark
        }
				posh-tee "Changed bool of -$writenewchksum-"
				if ( $writenewchksum ) {
#					( '$my_chcksums.Add( "' + $filejack + '" , "' + (( Get-FileHash -Path $LocalPath ).SHA256) + '" );' | Out-File -Append $chksum_log )
				posh-tee "Now to new_chksum for our checksum"
				new_chksum @newChkSums
				posh-tee "Back from new_chksum with -$cached_chksum-"
				}
			 } else {
				posh-tee "-$filejack- eq -$newest_chksum-";
				if ( $writenewchksum ) {
#					if ( $my_chcksums.containsKey( $filejack ) ) {
#						$my_chcksums.Remove( $filejack );
					# if ( $filejack -match "wise" ) { $filejack = 'Wise_Alt' }
#					( '$my_chcksums.Add( "' + $filejack + '" , "' + (( Get-FileHash -Path $LocalPath ).SHA256) + '" );' | Out-File -Append $chksum_log )
#					}
				posh-tee "else Now to new_chksum for our checksum"
				new_chksum @newChkSums
				posh-tee "else Back from new_chksum with -$cached_chksum-"
				}
			}
		# }
		$dwnlds.file = $true
		} else {
		posh-tee "no new file to download of -$filejack-";
		posh-tee "Aborting Download of -$filejack-";
		posh-tee "We have the latest version $filejack";
		$dwnlds.file = $false
		}
	# $dwnlds.test = ( Get-FileHash $LocalPath ).hash;
	posh-tee "Z fj -$filejack- nc -$newest_chksum-";
	# pause
	# $dwnlds.test = (( Get-FileHash -Path $LocalPath ).SHA256)
	$dwnlds.test = ( $cached_chksum );
	return $dwnlds
}

function RemoveCRNL( $a ) {
	$stream = [IO.File]::OpenWrite( $a )
	$stream.SetLength($stream.Length - 2)
	$stream.Close()
	$stream.Dispose()
}

foreach ( $_ in $queue ) {

	posh-tee "-Version: $version-`r"
	posh-tee "We are #Starting $_ Now"

		switch -w ( $_ ) {

		'wisejet' {
			. (Join-Path $scriptDir '.\data\Get-LatestWise.ps1')
			Get-FileFromWeb @AllWiseJet
		}
        
		'BBit' {
			. (Join-Path $scriptDir '.\data\Get-LatestBleachBit.ps1')
			Get-FileFromWeb @AllBleachBit
		}

		'tron' {
			. (Join-Path $scriptDir '.\data\Get-LatestTronScript.ps1')
			Get-FileFromWeb @AllTronscript
		}

		'rogueCMD' { # Combined cmd & gui into one file 17-08-03
			. (Join-Path $scriptDir '.\data\Get-LatestRogues.ps1')
			Get-FileFromWeb @AllRogueKillerCMD32
			Get-FileFromWeb @AllRogueKillerCMD64
		}

		'rogues' { # Updated to rogues and all roguekiller versions on 17-08-03
			. (Join-Path $scriptDir '.\data\Get-LatestRogues.ps1')
			Get-FileFromWeb @AllRogueKillerCMD32
			Get-FileFromWeb @AllRogueKillerCMD64
			Get-FileFromWeb @AllRogueKiller32
			Get-FileFromWeb @AllRogueKiller64
		}

		'rogue32' {
			. (Join-Path $scriptDir '.\data\Get-LatestRogues.ps1')
			Get-FileFromWeb @AllRogueKiller32
		}

		'rogue64' {
			. (Join-Path $scriptDir '.\data\Get-LatestRogues.ps1')
			Get-FileFromWeb @AllRogueKiller64
		}

		'tweaking' {
			. (Join-Path $scriptDir '.\data\Get-LatestTweaking.ps1')
			Get-FileFromWeb @AllTweakingAIO
		}

		'ADW' {
		. (Join-Path $scriptDir '.\data\Get-ADWVersion.ps1')
		Get-FileFromWeb @AllADWcleaner
		}

		'wise365' {
		. (Join-Path $scriptDir '.\data\Get-LatestWise.ps1')
		Get-FileFromWeb @AllWise365
		}

		'ccleaner' {
		. (Join-Path $scriptDir '.\data\Get-LatestCCLE.ps1')
		Get-FileFromWeb @AllCCleaner
		}

# still under development		
#		'crystal' {
#			. (Join-Path $scriptDir '.\data\Get-LatestCrystalDiskInfo.ps1')
#			Get-FileFromWeb @AllCrystalDiskInfo
#		}

		'ddu' { # Added this with tuning on 17-08-04
		. (Join-Path $scriptDir '.\data\Get-DDUVersion.ps1')
		Get-FileFromWeb @AllDisplayDriverUninnstaller
		}

		'npe' { # Added this with tuning on 17-09-05
		. (Join-Path $scriptDir '.\data\Get-NPEVersion.ps1')
		Get-FileFromWeb @AllNPElatest
		}

		'kvrt' { # Added this with tuning on 18-01-27
		. (Join-Path $scriptDir '.\data\Get-LatestKVRT.ps1')
		Get-FileFromWeb @AllKVRTlatest
		}

		default {
		. (Join-Path $scriptDir '.\data\Get-LatestTweaking.ps1')
		. (Join-Path $scriptDir '.\data\Get-LatestTronScript.ps1')
        # . (Join-Path $scriptDir '.\data\Get-LatestBleachBit.ps1')
		. (Join-Path $scriptDir '.\data\Get-LatestRogues.ps1')
		. (Join-Path $scriptDir '.\data\Get-ADWVersion.ps1')
		. (Join-Path $scriptDir '.\data\Get-LatestWise.ps1')
		. (Join-Path $scriptDir '.\data\Get-LatestCCLE.ps1')
		# . (Join-Path $scriptDir '.\data\Get-LatestRogueCMD.ps1')
        # . (Join-Path $scriptDir '.\data\Get-LatestWiseJet.ps1')
		. (Join-Path $scriptDir '.\data\Get-DDUVersion.ps1')
		. (Join-Path $scriptDir '.\data\Get-NPEVersion.ps1')
        # Get-ChildItem -Path $scriptDir\data -Filter *.ps1 |ForEach-Object {
        # . $_.FullName
        # }
        # changed order of getting tools 17-06-09
		Get-FileFromWeb @AllTweakingAIO
		Get-FileFromWeb @AllWise365
        # added in on 17-06-29
        Get-FileFromWeb @AllWiseJet
        # Get-FileFromWeb @AllBleachBit
		Get-FileFromWeb @AllADWcleaner
		Get-FileFromWeb @AllCCleaner
		Get-FileFromWeb @AllDisplayDriverUninnstaller
        # added NPE on 17-09-05
		Get-FileFromWeb @AllNPElatest
		Get-FileFromWeb @AllRogueKillerCMD32
		Get-FileFromWeb @AllRogueKiller32
		Get-FileFromWeb @AllRogueKillerCMD64
		Get-FileFromWeb @AllRogueKiller64
		Get-FileFromWeb @AllTronscript
		}
		}

	posh-tee "We are #Ending $_ Now`r`n"
	
terminator iexplore
# Removal of All cookie key
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1A10 /f | out-null

Reset-Log -fileName $simp_log -filesize 10kb -logcount 5
Reset-Log -fileName $diag_log -filesize 10kb -logcount 20
}




