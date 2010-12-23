#       status_feedb.tcl
#       © Copyright 2007-2010 Christian Rapp <christianrapp@users.sourceforge.net>
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

proc status_feedbWarn {handler msg} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: status_feedbWarn \033\[0m \{$handler\} \{$msg\}"
	#handler 1 - tvviewer log; 2 - mplayer log; 3 - scheduler log
	if {[winfo exists .topWarn] == 0} {
		set top [toplevel .topWarn]
		place [ttk::frame $top.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		set fMain [ttk::frame $top.f_warnMain]
		set fBut [ttk::frame $top.f_warnBut]
		ttk::label $fMain.l_warn -text "$msg" -compound left -image $::icon_b(dialog-warning)
		ttk::button $fBut.b_warnLog -text [mc "Show log"]
		ttk::button $fBut.b_warnOk -text [mc "OK"] -command "destroy $top; vid_wmCursor 1; ::tk::RestoreFocusGrab $top destroy"
		
		grid $fMain -in $top -row 0 -column 0 -sticky nesw
		grid $fBut -in $top -row 1 -column 0 -sticky ew -padx 3 -pady "0 3"
		
		grid $fMain.l_warn -in $fMain -row 0 -column 0 -sticky w -padx 8 -pady 8
		
		grid $fBut.b_warnLog -in $fBut -row 0 -column 0
		grid $fBut.b_warnOk -in $fBut -row 0 -column 1 -sticky e
		
		grid columnconfigure $top 0 -minsize 350
		grid columnconfigure $fBut 1 -weight 1
		
		wm iconphoto $top $::icon_b(dialog-warning)
		wm resizable $top 0 0
		wm transient $top .
		wm protocol $top WM_DELETE_WINDOW "destroy $top; vid_wmCursor 1; ::tk::RestoreFocusGrab $top destroy"
		wm title $top [mc "TV-Viewer Error"]
		
		array set btnCommand {
			1 "log_viewerUi 1"
			2 "log_viewerUi 2"
			3 "log_viewerUi 3"
		}
		
		$fBut.b_warnLog configure -command "$btnCommand($handler); destroy $top; vid_wmCursor 1; ::tk::RestoreFocusGrab $top destroy"
		
		vid_wmCursor 0
		::tk::SetFocusGrab $top
		
		tkwait visibility $top
		raise .
		raise $top
		focus $fBut.b_warnOk
		log_writeOutTv 0 "Creating error dialogue"
	} else {
		log_writeOutTv 1 "Can not open warning dialogue, because it already exists"
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
}
