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

proc status_feedbWarn {handler msg} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: status_feedbWarn \033\[0m \{$handler\} \{$msg\}"
	#handler 1 - tvviewer log; 2 - mplayer log; 3 - scheduler log
	if {[winfo exists .topWarn] == 0} {
		if {[wm attributes . -fullscreen] == 1} {
			event generate . <<wmFull>>
		}
		if {[winfo ismapped .] == 0} {
			system_trayToggle 0
		}
		set top [toplevel .topWarn]
		place [ttk::frame $top.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		set fMain [ttk::frame $top.f_warnMain]
		set fBut [ttk::frame $top.f_warnBut]
		ttk::label $fMain.l_warnImg -image $::icon_b(dialog-warning)
		ttk::label $fMain.l_warn -text "$msg"
		ttk::button $fBut.b_warnLog -text [mc "Show log"]
		ttk::button $fBut.b_warnOk -text [mc "OK"] -command "::tk::RestoreFocusGrab $top $top destroy; vid_wmCursor 1"
		
		grid $fMain -in $top -row 0 -column 0 -sticky nesw
		grid $fBut -in $top -row 1 -column 0 -sticky ew -padx 3 -pady "0 3"
		
		grid $fMain.l_warnImg -in $fMain -row 0 -column 0 -sticky nw -padx 8 -pady 8
		grid $fMain.l_warn -in $fMain -row 0 -column 1 -sticky w -padx "0 8" -pady 8
		
		grid $fBut.b_warnLog -in $fBut -row 0 -column 0
		grid $fBut.b_warnOk -in $fBut -row 0 -column 1 -sticky e
		
		grid columnconfigure $top 0 -minsize 350
		grid columnconfigure $fBut 1 -weight 1
		grid rowconfigure $top 0 -weight 1
		
		wm withdraw $top
		wm iconphoto $top $::icon_b(dialog-warning)
		wm resizable $top 0 0
		wm transient $top .
		wm protocol $top WM_DELETE_WINDOW "::tk::RestoreFocusGrab $top $top destroy; vid_wmCursor 1"
		wm title $top [mc "TV-Viewer Error"]
		
		array set btnCommand {
			1 "log_viewerUi 1"
			2 "log_viewerUi 2"
			3 "log_viewerUi 3"
		}
		
		$fBut.b_warnLog configure -command "::tk::RestoreFocusGrab $top $top destroy; vid_wmCursor 1; $btnCommand($handler)"
		
		vid_wmCursor 0
		
		::tk::SetFocusGrab $top $top
		
		update idletasks
		raise .
		raise $top
		focus -force $fBut.b_warnOk
		if {[winfo ismapped .]} {
			set mainX [winfo x .]
			set mainY [winfo y .]
			set centreX [expr $mainX + ([winfo width .] / 2.0)]
			set centreY [expr $mainY + ([winfo height .] / 2.0)]
			set posX [expr int($centreX - ([winfo reqwidth $top] / 2.0))]
			set posY [expr int($centreY - ([winfo reqheight $top] / 2.0))]
			wm geometry $top [winfo reqwidth $top]\x[winfo reqheight $top]\+$posX\+$posY
			if {[winfo exists .splash] == 0} {
				wm deiconify $top
			}
		} else {
			if {[winfo exists .tray]} {
				::tk::PlaceWindow $top
			}
		}
		log_writeOutTv 0 "Creating error dialogue"
	} else {
		wm resizable .topWarn 1 1
		set oldMsg [.topWarn.f_warnMain.l_warn cget -text]
		.topWarn.f_warnMain.l_warn configure -text "$oldMsg

$msg"
		raise .
		raise .topWarn
		focus -force .topWarn.f_warnBut.b_warnOk
		set calcHeight [expr [winfo reqheight .topWarn.f_warnMain] + [winfo reqheight .topWarn.f_warnBut] +10]
		set mainX [winfo x .]
		set mainY [winfo y .]
		set centreX [expr $mainX + ([winfo width .] / 2.0)]
		set centreY [expr $mainY + ([winfo height .] / 2.0)]
		set posX [expr int($centreX - ([winfo reqwidth .topWarn] / 2.0))]
		set posY [expr int($centreY - ([winfo reqheight .topWarn] / 2.0))]
		wm geometry .topWarn [winfo reqwidth .topWarn]\x$calcHeight\+$posX\+$posY
		wm resizable .topWarn 0 0
	}
	wm attributes .topWarn -topmost 1
	after 1000 [list wm attributes .topWarn -topmost 0]
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
