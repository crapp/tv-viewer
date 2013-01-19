#       vid_slist.tcl
#       © Copyright 2007-2013 Christian Rapp <christianrapp@users.sourceforge.net>
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

proc vid_slistLirc {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_slistLirc \033\[0m"
	if {[wm attributes . -fullscreen] == 1} {
		if {[winfo exists .fvidBg.slist_lirc]} {
			if {[string trim [place info .fvidBg.slist_lirc]] == {}} {
				vid_slistLircPlace
			} else {
				log_writeOut ::log(tvAppend) 0 "Closing OSD station list for remote controls."
				if {"[.fvidBg.slist_lirc.lb_station cget -state]" == "disabled"} {
					if {$::option(rec_allow_sta_change) == 1} {
						set get_lb_index [expr [.fvidBg.slist_lirc.lb_station curselection] + 1]
						chan_zapperStationNr .fstations.treeSlist $get_lb_index
						.fvidBg.slist_lirc.lb_station selection clear 0 end
					} else {
						.fvidBg.slist_lirc.lb_station selection clear 0 end
					}
				} else {
					set get_lb_index [expr [.fvidBg.slist_lirc.lb_station curselection] + 1]
					chan_zapperStationNr .fstations.treeSlist $get_lb_index
					.fvidBg.slist_lirc.lb_station selection clear 0 end
				}
				focus .fvidBg
				destroy .fvidBg.slist_lirc
			}
		} else {
			if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
				log_writeOut ::log(tvAppend) 1 "No valid stations list, will not activate lirc station selector."
			} else {
				log_writeOut ::log(tvAppend) 0 "Creating stations list lirc."
				frame .fvidBg.slist_lirc -background #524ADE -padx 5 -pady 5
				listbox .fvidBg.slist_lirc.lb_station -exportselection false -takefocus 0
				grid .fvidBg.slist_lirc.lb_station -in .fvidBg.slist_lirc -row 0 -column 0 -sticky nesw
				for {set i 1} {$i <= $::station(max)} {incr i} {
					.fvidBg.slist_lirc.lb_station insert end "$::kanalid($i)"
				}
				vid_slistLircPlace
			}
		}
	}
}

proc vid_slistLircPlace {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_slistLircPlace \033\[0m"
	log_writeOut ::log(tvAppend) 0 "Placing OSD station list for remote controls in video frame."
	array set alignment {
		0 {-anchor nw -x 10 -y 10}
		1 {-anchor n -relx 0.5 -y 10}
		2 {-anchor ne -relx 1.0 -x -10 -y 10}
		3 {-anchor w -rely 0.5 -x 10}
		4 {-anchor center -relx 0.5 -rely 0.5}
		5 {-anchor e -relx 1.0 -rely 0.5 -x -10}
		6 {-anchor sw -rely 1.0 -x 10 -y -10}
		7 {-anchor s -relx 0.5 -rely 1.0 -y -10}
		8 {-anchor se -relx 1.0 -rely 1.0 -x -10 -y -10}
	}
	set font "[lindex $::option(osd_lirc) 1]"
	set style "[string tolower [lindex $::option(osd_lirc) 2]]"
	set size [lindex $::option(osd_lirc) 3]
	set bias [lindex $::option(osd_lirc) 4]
	set color [lindex $::option(osd_lirc) 5]
	if {"$style" == "regular"} {
		.fvidBg.slist_lirc.lb_station configure -font "{$font} $size" -foreground $color
	} else {
		.fvidBg.slist_lirc.lb_station configure -font "{$font} $size {$style}" -foreground $color
	}
	place .fvidBg.slist_lirc -in .fvidBg {*}$alignment($bias)
	.fvidBg.slist_lirc.lb_station selection set [expr [lindex $::station(last) 2] - 1]
	.fvidBg.slist_lirc.lb_station see [expr [lindex $::station(last) 2] - 1]
	.fvidBg.slist_lirc.lb_station activate [expr [lindex $::station(last) 2] - 1]
}

proc vid_slistLircMoveUp {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_slistLircMoveUp \033\[0m"
	if {[winfo exists .fvidBg.slist_lirc] && [string trim [place info .fvidBg.slist_lirc]] != {}} {
		if {[.fvidBg.slist_lirc.lb_station curselection] > 0} {
			set new_index [expr [.fvidBg.slist_lirc.lb_station curselection] - 1]
			.fvidBg.slist_lirc.lb_station selection clear 0 end
			.fvidBg.slist_lirc.lb_station selection set $new_index
			.fvidBg.slist_lirc.lb_station activate $new_index
			.fvidBg.slist_lirc.lb_station see $new_index
		} else {
			set new_index end
			.fvidBg.slist_lirc.lb_station selection clear 0 end
			.fvidBg.slist_lirc.lb_station selection set $new_index
			.fvidBg.slist_lirc.lb_station activate $new_index
			.fvidBg.slist_lirc.lb_station see $new_index
		}
	}
}

proc vid_slistLircMoveDown {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_slistLircMoveDown \033\[0m"
	if {[winfo exists .fvidBg.slist_lirc] && [string trim [place info .fvidBg.slist_lirc]] != {}} {
		if {[.fvidBg.slist_lirc.lb_station curselection] < [expr [.fvidBg.slist_lirc.lb_station index end] - 1]} {
			set new_index [expr [.fvidBg.slist_lirc.lb_station curselection] + 1]
			.fvidBg.slist_lirc.lb_station selection clear 0 end
			.fvidBg.slist_lirc.lb_station selection set $new_index
			.fvidBg.slist_lirc.lb_station activate $new_index
			.fvidBg.slist_lirc.lb_station see $new_index
		} else {
			set new_index 0
			.fvidBg.slist_lirc.lb_station selection clear 0 end
			.fvidBg.slist_lirc.lb_station selection set $new_index
			.fvidBg.slist_lirc.lb_station activate $new_index
			.fvidBg.slist_lirc.lb_station see $new_index
		}
	}
}
