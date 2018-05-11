
# bof terminator
function terminator() {
param(
	[string]$nail
)
	if ( $diagnostics ) { sleep 5 }
posh-tee "we are starting the $nail Kill lines"
	# get $nail process
		$iexplore = ( Get-Process $nail -ErrorAction SilentlyContinue );
		posh-tee "set $iexplore to the process"
		if ($iexplore) {
		posh-tee "testing for process and it is true"
		  # try gracefully first
		  $iexplore.CloseMainWindow()
		  posh-tee "trying to close $nail nicely"
		  # kill after five seconds
		  Sleep 5
		  posh-tee "sleeping for 5 seconds before force close"
		  if (!$iexplore.HasExited) {
			$iexplore | Stop-Process -Force
			posh-tee "$nail is forced close"
		  } else {
			posh-tee "Using the Hammer to close $nail"
			Stop-Process -name iexplore -Force
			posh-tee "Hammer has fallen on $nail now"
			}
		}
		posh-tee "removing the $iexplore variable"
		Remove-Variable iexplore
		posh-tee "iexplore variable is removed"
posh-tee "we are ending the $nail Kill lines"
}
# eof terminator