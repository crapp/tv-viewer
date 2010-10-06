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

proc status_feedbWarn {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: status_feedbWarn \033\[0m"
	
}

proc status_feedbMsgs {handler msg} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: status_feedbMsgs \033\[0m \{$handler\}"
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
