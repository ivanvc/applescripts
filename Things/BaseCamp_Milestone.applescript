(*
Add Milestone from BaseCamp

http://github.com/ivanvc/applescripts/tree/master/Things
iv@nvald.es

With contribution of: 
idPro
http://culturedcode.com/things/wiki/index.php/User:Idpro

It will add a new To Do based on a Milestone sent from a Basecamp. It will try to find the Things project named as the Basecamp project, and the Things Area as the Basecamp company. If it finds the project, it will add the To Do, to that project. If not, it will try to find the Area (Company), and will add to it. If not, it will add the To Do to the Inbox.

NOTE: At the moment it is reading the html format of the email, it can be enhanced by reading the raw of the message, will update the script to do this later.
*)

using terms from application "Mail"
	-- Disable the following line to debug
	on perform mail action with messages newMessages
	tell application "Mail"
			-- Enable the following line to debug
			--set newMessages to selection
		repeat with theMessage in newMessages
			set theSource to source of theMessage
			set theArea to (do shell script "/bin/echo " & quoted form of theSource & " | /usr/bin/ruby -ne 'print $1 if $_[/^Company:\\s(.*)$/]' ")
			set theProject to (do shell script "/bin/echo " & quoted form of theSource & " | /usr/bin/ruby -ne 'print $1 if $_[/^Project:\\s(.*)$/]' ")
			set theToDo to (do shell script "/bin/echo " & quoted form of theSource & " | /usr/bin/ruby -ne 'print $1 if $_[/^\\s{2}(.*)/] && $1[0...3] != \"Due\" && $1[0] != 32'")
			set theDate to (do shell script "/bin/echo " & quoted form of theSource & " | /usr/bin/ruby -ne 'print $1 if $_[/^\\s{2}Due\\son\\s(.*)/]'")
			set theURL to (do shell script "/bin/echo " & quoted form of theSource & " | /usr/bin/ruby -ne 'puts $_ if $_[/http/]'")
			
			set theSender to (extract name from sender of theMessage)
			
			tell application "Things"
				set addedToProject to false
				set addedToArea to false
				set added to false
				
				try
					set newToDo to make new to do Â
						with properties {name:theToDo, notes:theURL & linefeed & "added by " & theSender & " (" & theArea & ")", due date:date theDate} Â
						at beginning of project theProject
					set tag names of newToDo to theProject & "," & theArea
					
					set addedToProject to true
				end try
				
				if not addedToProject then
					try
						set newToDo to make new to do Â
							with properties {name:theToDo, notes:theURL & linefeed & "added by " & theSender & " (" & theArea & ")", due date:date theDate} Â
							at beginning of area theArea
						set tag names of newToDo to theProject & "," & theArea
						
						set addedToArea to true
					end try
				end if
				
				if not addedToArea and not addedToProject then
					try
						set newToDo to make new to do Â
							with properties {name:theToDo, notes:theURL & linefeed & "added by " & theSender & " (" & theArea & ")", due date:date theDate}
						set tag names of newToDo to theProject & "," & theArea
						
						set added to true
					end try
				end if
				
				tell application "System Events"
					set frontApp to the name of the current application
				end tell
				
				if frontApp is not "Things" then
					try
						if added then
							show to do theProject & ": " & theToDo
						else if addedToArea or addedToProject then
							show to do theToDo
						end if
					end try
				end if
			end tell
			
			
			tell application "GrowlHelperApp"
				set the allNotificationsList to Â
					{"Added To Do", "Added Project"}
				set the enabledNotificationsList to Â
					{"Added To Do", "Added Project"}
				register as application Â
					"ThingsBaseCamp" all notifications allNotificationsList Â
					default notifications enabledNotificationsList Â
					icon of application "Things"
				
				if addedToArea then
					notify with name Â
						"Added To Do" title Â
						"New To Do" description Â
						"Added new To Do to Area " & theArea application name "ThingsBaseCamp"
				else if addedToProject then
					notify with name Â
						"Added To Do" title Â
						"New To Do" description Â
						"Added new To Do to Project " & theProject application name "ThingsBaseCamp"
				else if added then
					notify with name Â
						"Added To Do" title Â
						"New To Do" description Â
						"Added new To Do to Inbox" application name "ThingsBaseCamp"
				end if
			end tell
		end repeat
	end tell
	
	end perform mail action with messages
end using terms from