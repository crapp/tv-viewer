#       status_feedb.tcl
#       © Copyright 2007-2011 Christian Rapp <christianrapp@users.sourceforge.net>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.

# Provides Warning window, feedback messages in main window and changing Trayicon

proc status_feedbWarn {handler msg} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: status_feedbWarn \033\[0m \{$handler\} \{$msg\}"
	#handler 1 - tvviewer log; 2 - mplayer log; 3 - scheduler log
	if {[winfo exists .fvidBg.f_feedbwarn] == 0} {
		if {[winfo ismapped .] == 0} {
			system_trayToggle 0
		}
		set top [frame .fvidBg.f_feedbwarn -bg #696969 -padx 3 -pady 3]
		set fMain [ttk::frame $top.f_warnMain]
		set fBut [ttk::frame $top.f_warnBut]
		ttk::label $fMain.l_warnImg -image $::icon_b(dialog-warning)
		ttk::label $fMain.l_warn -text "$msg" -wraplength 350
		ttk::button $fBut.b_warnLog -text [mc "Show log"]
		ttk::button $fBut.b_warnOk -text [mc "OK"] -command "status_feedbWarnDel cancel; unset -nocomplain ::status_feedbWarnMessages; destroy $top; vid_wmCursor 1"
		
		grid $fMain -in $top -row 0 -column 0 -sticky nesw
		grid $fBut -in $top -row 1 -column 0 -sticky ew
		
		grid $fMain.l_warnImg -in $fMain -row 0 -column 0 -sticky nw -padx 8 -pady 8
		grid $fMain.l_warn -in $fMain -row 0 -column 1 -sticky w -padx "0 8" -pady 8
		
		grid $fBut.b_warnLog -in $fBut -row 0 -column 0 -padx 3 -pady 3
		grid $fBut.b_warnOk -in $fBut -row 0 -column 1 -sticky e -padx 3 -pady 3
		
		grid columnconfigure $top 0 -minsize 350
		grid columnconfigure $fBut 1 -weight 1
		grid rowconfigure $top 0 -weight 1
		
		place .fvidBg.f_feedbwarn -anchor s -relx 0.5 -rely 1.0 -y -2
		
		array set btnCommand {
			1 "log_viewerUi 1 1"
			2 "log_viewerUi 2 1"
			3 "log_viewerUi 3 1"
		}
		
		$fBut.b_warnLog configure -command "status_feedbWarnDel cancel; unset -nocomplain ::status_feedbWarnMessages; destroy $top; vid_wmCursor 1; $btnCommand($handler)"
		
		vid_wmCursor 0
		
		set ::status_feedbWarnMessages [dict create msg1 "$msg"]
		log_writeOutTv 0 "Creating error dialogue"
	} else {
		if {[dict size $::status_feedbWarnMessages] == 1} {
			dict set ::status_feedbWarnMessages msg2 "$msg"
		} else {
			dict set ::status_feedbWarnMessages msg1 "[dict get $::status_feedbWarnMessages msg2]"
			dict set ::status_feedbWarnMessages msg2 "$msg"
		}
		.fvidBg.f_feedbwarn.f_warnMain.l_warn configure -text "[dict get $::status_feedbWarnMessages msg1]

[dict get $::status_feedbWarnMessages msg2]"
	}
	status_feedbWarnDel "cancel"
	set ::status_feedbAfterID [after 10000 {status_feedbWarnDel .fvidBg.f_feedbwarn.f_warnMain.l_warn}]
	focus -force .fvidBg.f_feedbwarn.f_warnBut.b_warnOk
}

proc status_feedbWarnDel {labelw} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: status_feedbMsgs \033\[0m \{$labelw\}"
	# Removes messages after x secs from Warning Window. labelw = window path for label widget, if labelw == cancel stop after execution.
	if {"$labelw" == "cancel"} {
		catch {after cancel $::status_feedbAfterID}
		unset -nocomplain ::status_feedbAfterID
		return
	}
	if {[dict size $::status_feedbWarnMessages] == 1} {
		destroy .fvidBg.f_feedbwarn
		unset -nocomplain ::status_feedbAfterID ::status_feedbWarnMessages
		log_writeOutTv 1 "A message has been removed from error dialogue without user interaction"
	} else {
		dict set ::status_feedbWarnMessages msg1 "[dict get $::status_feedbWarnMessages msg2]"
		set ::status_feedbWarnMessages [dict remove $::status_feedbWarnMessages msg2]
		$labelw configure -text "[dict get $::status_feedbWarnMessages msg1]"
		log_writeOutTv 1 "A message has been removed from error dialogue without user interaction"
		focus -force .fvidBg.f_feedbwarn.f_warnBut.b_warnOk
	}
}

proc status_feedbMsgs {handler msg} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: status_feedbMsgs \033\[0m \{$handler\} \{$msg\}"
	# handler: 0 - TV; 1 - Record; 2 - Timeshift; 3 - File Playback; 4 - Check pbMode what icon is needed
	array set icon {
		0 $::icon_s(starttv)
		1 $::icon_s(record)
		2 $::icon_s(timeshift)
		3 $::icon_s(video)
	}
	set imgDone 0
	if {$handler == 0} {
		if {"[.ftoolb_Disp.fIcTxt.lDispIcon cget -image]" != "$::icon_s(starttv)"} {
			.ftoolb_Disp.fIcTxt.lDispIcon configure -image [subst $icon($handler)]
		}
		set imgDone 1
	}
	if {$handler == 4} {
		if {$::vid(pbMode)} {
			.ftoolb_Disp.fIcTxt.lDispIcon configure -image [subst $icon(3)]
		} else {
			.ftoolb_Disp.fIcTxt.lDispIcon configure -image [subst $icon(0)]
		}
		set imgDone 1
	}
	if {$imgDone == 0} {
		.ftoolb_Disp.fIcTxt.lDispIcon configure -image [subst $icon($handler)]
	}
	.ftoolb_Disp.fIcTxt.lDispText configure -text $msg
	if {$::main(compactMode)} {
		wm title . "TV-Viewer - $msg"
	}
	set doTray 1
	if {$handler == 4} {
		system_trayChangeIc 0
		set doTray 0
	}
	if {$handler == 0} {
		system_trayChangeIc 4
		set doTray 0
	}
	if {$doTray} {
		system_trayChangeIc $handler ;# call proc if doTray = 1
	}
}
