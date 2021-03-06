(* Modify the following line with your credentials
i.e. property my_login : "ivanvc:super_secret_password123"
*)
property my_login : "user:password"

(*
"Tweet it" modified again by 
Ivan V
http://github.com/ivanvc

I just wanted a way to tweet the current iTunes song without tweeting every song am listening. Also removed all the keychain access thing, keep it simple.

"Tweet it" modified from 
"Current Track to Twitter" for iTunes
written by Doug Adams
dougadams@mac.com
some routines based on those written by Coda Hale, <http://blog.codahale.com/2007/01/15/tweet-twitter-quicksilver/> 

v1.5 mar 21 2007
-- provides routine to retrieve Twitter account information previously stored with Keychain Access (see Read Me for details)

v1.0 mar 21 2007
-- initial release

Get more free AppleScripts and info on writing your own
at Doug's AppleScripts for iTunes
http://www.dougscripts.com/itunes/

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

Get a copy of the GNU General Public License by writing to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

or visit http://www.gnu.org/copyleft/gpl.html

*)

-- ==================================
-- You can change these if you like

property preface : "♫ " -- preceeds song info in your Twitter message

-- ==================================
-- do NOT alter these

property rating_star : "%26%239733%3B"
property half_star : "%26%23189%3B"

-- ==================================


if iTunes_is_active() then
	tell application "iTunes"
		if player state is playing then
			set cur_track to current track
			tell cur_track to set {nom, art, alb, rat} to {name, artist, album, rating}
			
			-- you could reconfigure this if you like
			set message to (preface & "\"" & nom & "\" by " & art & " from \"" & alb & "\" " & my make_stars(rat)) as string
			
			my send_to_twitter(my replace_chars(message, "&", "%26"), rat)
		end if
	end tell
end if

to send_to_twitter(message, rat)
	--  code based on Coda Hale's  <http://blog.codahale.com/2007/01/15/tweet-twitter-quicksilver/>
	set twitter_message to quoted form of ("status=" & message)
	set rez to do shell script "curl --user " & my_login & " --data-binary " & twitter_message & " http://twitter.com/statuses/update.json"
	log rez -- debugging purposes
end send_to_twitter


to make_stars(rat)
	set ratingstars to ""
	if (rat is not missing value) or (rat is not 0) then
		repeat (rat div 20) times
			set ratingstars to (ratingstars & rating_star) as string
		end repeat
		if rat mod 20 = 10 then set ratingstars to (ratingstars & half_star) as string
	end if
	return ratingstars
end make_stars


on iTunes_is_active()
	tell application "System Events" to return (name of processes contains "iTunes")
end iTunes_is_active


on replace_chars(txt, srch, repl)
	set AppleScript's text item delimiters to the srch
	set the item_list to every text item of txt
	set AppleScript's text item delimiters to the repl
	set txt to the item_list as string
	set AppleScript's text item delimiters to ""
	return txt
end replace_chars