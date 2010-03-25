(*
Add To Do from BaseCamp

http://github.com/ivanvc/applescripts/tree/master/Things
iv@nvald.es

With contribution of: 
idPro
http://culturedcode.com/things/wiki/index.php/User:Idpro

It will add a new To Do based on a To Do sent from a Basecamp. It will try to find the Things project named as the Basecamp project, and the Things Area as the Basecamp company. If it finds the project, it will add the To Do, to that project. If not, it will try to find the Area (Company), and will add to it. If not, it will add the To Do to the Inbox.
*)

using terms from application "Mail"
	on perform mail action with messages newMessages
		tell application "Mail"
			--	set newMessages to selection
			repeat with theMessage in newMessages
				set theContent to content of theMessage
				set theText to paragraphs of theContent
				set counter to 0
				set theSender to (extract name from sender of theMessage)
				repeat with theLine in theText
					if length of theLine is greater than 0 then
						if counter is 0 then
							set theArea to (do shell script "/bin/echo " & quoted form of theLine & " | sed s/Company:.//")
						else if counter is 1 then
							set theProject to (do shell script "/bin/echo " & quoted form of theLine & " | sed s/Project:// | sed 's/^[ [:cntrl:]]*//;s/[ [:cntrl:]]*$//'")
						else if counter is 8 then
							set theToDo to (do shell script "/bin/echo " & quoted form of theLine & " | sed s/^....//")
						else if counter is 12 then
							set theURL to theLine
						end if
					end if
					set counter to counter + 1
				end repeat
				
				tell application "Things"
					set addedToProject to false
					set addedToArea to false
					set added to false
					
					try
						set newToDo to make new to do ¬
							with properties {name:theToDo, notes:theURL & linefeed & "added by " & theSender & " (" & theArea & ")"} ¬
							at beginning of project theProject
						set tag names of newToDo to theProject & "," & theArea
						set addedToProject to true
					end try
					
					if not addedToProject then
						try
							set newToDo to make new to do ¬
								with properties {name:theToDo, notes:theURL & linefeed & "added by " & theSender & " (" & theArea & ")"} ¬
								at beginning of area theArea
							set tag names of newToDo to theProject & "," & theArea
							set addedToArea to true
						end try
					end if
					
					if not addedToArea and not addedToProject then
						try
							set newToDo to make new to do ¬
								with properties {name:theProject & ": " & theToDo, notes:theURL & linefeed & "added by " & theSender & " (" & theArea & ")"}
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
					set the allNotificationsList to ¬
						{"Added To Do", "Added Project"}
					set the enabledNotificationsList to ¬
						{"Added To Do", "Added Project"}
					register as application ¬
						"ThingsBaseCamp" all notifications allNotificationsList ¬
						default notifications enabledNotificationsList ¬
						icon of application "Things"
					
					if addedToArea then
						notify with name ¬
							"Added To Do" title ¬
							"New To Do" description ¬
							"Added new To Do to Area " & theArea application name "ThingsBaseCamp"
					else if addedToProject then
						notify with name ¬
							"Added To Do" title ¬
							"New To Do" description ¬
							"Added new To Do to Project " & theProject application name "ThingsBaseCamp"
					else if added then
						notify with name ¬
							"Added To Do" title ¬
							"New To Do" description ¬
							"Added new To Do to Inbox" application name "ThingsBaseCamp"
					end if
				end tell
			end repeat
		end tell
	end perform mail action with messages
end using terms from