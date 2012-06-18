#       status_feedb.tcl
#       © Copyright 2007-2012 Christian Rapp <christianrapp@users.sourceforge.net>
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

proc status_feedbWarn {logfile msgIcon msg} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: status_feedbWarn \033\[0m \{$logfile\} \{$msg\}"
	#logfile 1 - tvviewer log; 2 - mplayer log; 3 - scheduler log
	if {[winfo exists .fvidBg.f_feedbwarn] == 0} {
		if {[winfo ismapped .] == 0} {
			system_trayToggle 0
		}
		set top [frame .fvidBg.f_feedbwarn -bg #696969 -padx 3 -pady 3]
		place [ttk::frame $top.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		set fMain [ttk::frame $top.f_warnMain]
		set fBut [ttk::frame $top.f_warnBut]
		text $fMain.txt -yscrollcommand [list $fMain.scrb set] -width 0 -height 0 -bd 0 -relief flat -highlightthickness 0 -insertwidth 0 -wrap word
		ttk::scrollbar $fMain.scrb -command [list $fMain.txt yview]
		ttk::button $fBut.b_warnLog -text [mc "Show log"]
		ttk::button $fBut.b_warnOk -text [mc "OK"] -command "place forget $top; vid_wmCursor 1"
		
		grid $fMain -in $top -row 0 -column 0 -sticky nesw
		grid $fBut -in $top -row 1 -column 0 -sticky ew
		
		grid $fMain.txt -in $fMain -row 0 -column 0 -sticky nesw -padx "8 0" -pady 8
		grid $fMain.scrb -in $fMain -row 0 -column 1 -sticky ns -pady 8
		grid $fBut.b_warnLog -in $fBut -row 0 -column 0 -padx 3 -pady 3
		grid $fBut.b_warnOk -in $fBut -row 0 -column 1 -sticky e -padx 3 -pady 3
		
		grid columnconfigure $top 0 -minsize 350
		grid columnconfigure $fMain 0 -weight 1 
		grid columnconfigure $fBut 1 -weight 1
		grid rowconfigure $top 0 -weight 1 -minsize 100
		grid rowconfigure $fMain 0 -weight 1
		
		array set btnCommand {
			1 "log_viewerUi 1 1"
			2 "log_viewerUi 2 1"
			3 "log_viewerUi 3 1"
		}
		
		array set icon {
			0 $::icon_s(dialog-error)
			1 $::icon_s(dialog-information)
			2 $::icon_s(dialog-warning)
		}
		
		$fMain.txt tag configure standardTextFirst -lmargin2 22
		$fMain.txt tag configure standardText -lmargin1 22 -lmargin2 22
		
		$fBut.b_warnLog configure -command "place forget $top; vid_wmCursor 1; $btnCommand($logfile)"
		
		vid_wmCursor 0
		
		$fMain.txt image create end -image [subst $icon($msgIcon)] -padx 3
		
		set i 0
		foreach line [split $msg \n] {
			if {$i > 0} {
				$fMain.txt insert end "\n"
				$fMain.txt insert end $line standardText
			} else {
				$fMain.txt insert end $line standardTextFirst
			}
			incr i
		}
		.fvidBg.f_feedbwarn.f_warnMain.txt insert end "\n"
		
		autoscroll $fMain.scrb
		
		log_writeOut ::log(tvAppend) 0 "Creating error dialogue"
	} else {
		array set icon {
			0 $::icon_s(dialog-error)
			1 $::icon_s(dialog-information)
			2 $::icon_s(dialog-warning)
		}
		
		.fvidBg.f_feedbwarn.f_warnMain.txt insert end "\n"
		.fvidBg.f_feedbwarn.f_warnMain.txt image create end -image [subst $icon($msgIcon)] -padx 3
		set i 0
		foreach line [split $msg \n] {
			if {$i > 0} {
				.fvidBg.f_feedbwarn.f_warnMain.txt insert end "\n"
				.fvidBg.f_feedbwarn.f_warnMain.txt insert end $line standardText
			} else {
				.fvidBg.f_feedbwarn.f_warnMain.txt insert end $line standardTextFirst
			}
			incr i
		}
		.fvidBg.f_feedbwarn.f_warnMain.txt insert end "\n"
	}
	if {[string trim [place info .fvidBg.f_feedbwarn]] == {}} {
		place .fvidBg.f_feedbwarn -anchor s -relx 0.5 -rely 1.0 -y -2
	}
	.fvidBg.f_feedbwarn.f_warnMain.txt see end
	focus -force .fvidBg.f_feedbwarn.f_warnBut.b_warnOk
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
