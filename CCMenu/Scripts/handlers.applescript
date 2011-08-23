
-- would be great if Growl had anchors
--   anchors of pane "Growl"
--   reveal anchor "DNS" of pane id "com.apple.preference.network"

on open_growl()
	tell application "System Preferences"
        activate
		reveal pane id "com.growl.prefpanel"
	end tell
end open_growl

on open_growl_by_name()
	tell application "System Preferences"
        activate
		reveal pane "Growl"
	end tell
end open_growl_by_name
