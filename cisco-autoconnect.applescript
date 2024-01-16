set targetApp to "Cisco AnyConnect Secure Mobility Client"
set closeApp to "vpndownloader"

-- Set these variables: 
set vpnName to "xxx" -- copy from AnyConnect main window
set keyChainName to "xxx" -- Keychain Item Name

-- Quit Cisco application if it's already running (clean start for less user friction)
if application targetApp is running then
	ignoring application responses
		try
			tell application targetApp to quit
		end try
	end ignoring
	
	-- Wait until the app actually quits
	tell application "System Events"
		repeat while (application process targetApp exists)
			delay 0.1
		end repeat
	end tell
end if

-- (Re)start Cisco application
tell application targetApp
	activate
end tell

repeat until application targetApp is running
	delay 0.1
end repeat

tell application "System Events"
	-- Wait for login window to open (with 15s timeout)
	set counter to 0
	set waningCounter to 0
	set warningWindowName to "Security Warning"
	set windowName to "Cisco AnyConnect | " & vpnName
	set PSWD to ""
	
	repeat until (window 2 of process targetApp exists)
		delay 0.5
		set counter to counter + 1
		if (counter > 30) then error number -128
	end repeat
	
	delay 0.5
	
	tell process targetApp
		click button "Connect Anyway" of window 2
	end tell
	
	set counter to 0
	repeat until (window windowName of process targetApp exists)
		delay 0.5
		set counter to counter + 1
		if (counter > 30) then error number -128
	end repeat
	
	tell process targetApp
		click button "OK" of window windowName
	end tell
	
	set counter to 0
	repeat until (window windowName of process targetApp exists)
		delay 0.5
		set counter to counter + 1
		if (counter > 30) then error number -128
	end repeat

-- Get password from login/Passwords keychain, enter it to Cisco connect window and connect
	tell process targetApp
		set PSWD to do shell script "/usr/bin/security find-generic-password -wl " & quoted form of keyChainName
		set value of text field 1 of window windowName to PSWD as text
		click button "OK" of window windowName
	end tell
	
	delay 2
	
	set counter to 0
	repeat until (window 1 of process closeApp exists)
		delay 0.5
		set counter to counter + 1
		if (counter > 30) then error number -128
	end repeat
	
	tell process closeApp
		click button "Connect Anyway" of window 1
	end tell
end tell
