
on open_notifications()
	tell application "System Preferences"
		activate
		reveal pane id "com.apple.preference.notifications"
	end tell
end open_notifications
