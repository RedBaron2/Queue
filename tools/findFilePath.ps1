$DesktopPath = [Environment]::GetFolderPath("Desktop")

function findFilePath {
param(
    [string]$a
)
    switch -w ( $a ) {
        default {
	        switch -w ( ${env:computername} ) {
		        "Tech-PC" {
		        $filePath = "C:\Extras\Sandbox\Mv_Removers\apps\portables"
		        }
		        "Vemillion1-PC" {
		        $filePath = "$DesktopPath\rb_sandbox\Mv_Removers\apps\portables";
		        }
		        default {
		        $filePath = "$DesktopPath\PortableApps"
		        }
	        }
        }
        "ADW" {
	        switch -w ( ${env:computername} ) {
		        "Tech-PC" {
		        $filePath = 'C:\Extras\Sandbox\Mv_Removers\toolslib.net' ;
		        }
		        "Vemillion1-PC" {
		        $filePath = "$DesktopPath\rb_sandbox\Mv_Removers\toolslib.net";
		        }
		        default {
		        $filePath = "$DesktopPath\Mv_Removers\toolslib.net";
		        }
	        }
        }
        # Added 2017-09-05 for Norton Power Eraser location
        "NPE" {
	        switch -w ( ${env:computername} ) {
		        "Tech-PC" {
		        $filePath = 'C:\Extras\Sandbox\Mv_Removers\scan' ;
		        }
		        "Vemillion1-PC" {
		        $filePath = "$DesktopPath\rb_sandbox\Mv_Removers\scan";
		        }
		        default {
		        $filePath = "$DesktopPath\Mv_Removers\scan";
		        }
	        }
        }
        "rogueCMD" {
	        switch -w ( ${env:computername} ) {
		        "Tech-PC" {
		        $filePath = 'C:\Extras\Sandbox\Mv_Removers\rogues' ;
		        }
		        "Vemillion1-PC" {
		        $filePath = "$DesktopPath\rb_sandbox\Mv_Removers\rogues";
		        }
		        default {
		        $filePath = "$DesktopPath\Mv_Removers\rogues";
		        }
	        }
        }
        "rogue" {
	        switch -w ( ${env:computername} ) {
		        "Tech-PC" {
		        $filePath = 'C:\Extras\Sandbox\Mv_Removers\rogues' ;
		        }
				"Vemillion1-PC" {
				$filePath = "$DesktopPath\rb_sandbox\Mv_Removers\rogues"
				}
		        default {
		        $filePath = "$DesktopPath\Mv_Removers\rogues";
		        }
	        }
        }
        "tron" {
	        switch -w ( ${env:computername} ) {
		        "Tech-PC" {
		        $filePath = "C:\Extras\Sandbox\Tron"
		        }
				"Vemillion1-PC" {
				$filePath = "$DesktopPath\rb_sandbox\Tron"
				}
		        default {
		        $filePath = "$DesktopPath\tron"
		        }
	        }
        }
    }
	if (!(Test-Path $filePath) ) {
	posh-tee "We are testing for $filePath now"
		New-Item -ItemType "Directory" -Force -Path $filePath
	}
    return $filePath
}