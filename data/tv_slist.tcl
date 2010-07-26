#       tv_slist.tcl
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

proc tv_slistCursor {xpos ypos} {
	if {[winfo exists .tv.slist]} {
		if {[winfo exists .tv.file_play_bar] == 1 && $::option(rec_allow_sta_change) == 0} {
			return
		}
		array set alignment {
			0 {-anchor nw -x 10 -y 10}
			1 {-anchor n -relx 0.5 -y 10}
			2 {-anchor ne -relx 1.0 -x -10 -y 10}
			3 {-anchor w -rely 0.5 -x 10}
			5 {-anchor e -relx 1.0 -rely 0.5 -x -10}
			6 {-anchor sw -rely 1.0 -x 10 -y -10}
			7 {-anchor s -relx 0.5 -rely 1.0 -y -10}
			8 {-anchor se -relx 1.0 -rely 1.0 -x -10 -y -10}
		}
		array set pos {
			0 {$xpos < 40 && $ypos < 40}
			3 {$xpos < 40 && $ypos > [expr ([winfo screenheight .] / 2.0) - 40] && $ypos < [expr ([winfo screenheight .] / 2.0) + 40]}
			6 {$xpos < 40 && $ypos > [expr [winfo screenheight .] - 40]}
			2 {$xpos > [expr [winfo screenwidth .] - 40] && $ypos < 40}
			5 {$xpos > [expr [winfo screenwidth .] - 40] && $ypos > [expr ([winfo screenheight .] / 2.0) - 40] && $ypos < [expr ([winfo screenheight .] / 2.0) + 40]}
			8 {$xpos > [expr [winfo screenwidth .] - 40] && $ypos > [expr [winfo screenheight .] - 40]}
			1 {$ypos < 40 && $xpos > [expr ([winfo screenwidth .] / 2.0) - 40] && $xpos < [expr ([winfo screenwidth .] / 2.0) + 40]}
			7 {$ypos > [expr [winfo screenheight .] - 40] && $xpos > [expr ([winfo screenwidth .] / 2.0) - 40] && $xpos < [expr ([winfo screenwidth .] / 2.0) + 40]}
		}
		array set pos_win {
			0 {[winfo pointerx .tv] < [expr [winfo x .tv] + 40] && [winfo pointery .tv] < [expr [winfo y .tv] + 40]}
			3 {[winfo pointerx .tv] < [expr [winfo x .tv] + 40] && [winfo pointery .tv] < [expr (([winfo height .tv] / 2.0) + [winfo y .tv]) + 40] && [winfo pointery .tv] > [expr (([winfo height .tv] / 2.0) + [winfo y .tv]) - 40]}
			6 {[winfo pointerx .tv] < [expr [winfo x .tv] + 40] && [winfo pointery .tv] > [expr ([winfo height .tv] + [winfo y .tv]) - 40]}
			2 {[winfo pointerx .tv] > [expr ([winfo width .tv] + [winfo x .tv]) - 40] && [winfo pointery .tv] < [expr [winfo y .tv] + 40]}
			5 {[winfo pointerx .tv] > [expr ([winfo width .tv] + [winfo x .tv]) - 40] && [winfo pointery .tv] < [expr (([winfo height .tv] / 2.0) + [winfo y .tv]) + 40] && [winfo pointery .tv] > [expr (([winfo height .tv] / 2.0) + [winfo y .tv]) - 40]}
			8 {[winfo pointerx .tv] > [expr ([winfo width .tv] + [winfo x .tv]) - 40] && [winfo pointery .tv] > [expr ([winfo height .tv] + [winfo y .tv]) - 40]}
			1 {[winfo pointerx .tv] < [expr (([winfo width .tv] / 2.0) + [winfo x .tv]) + 40] && [winfo pointerx .tv] > [expr (([winfo width .tv] / 2.0) + [winfo x .tv]) - 40] && [winfo pointery .tv] < [expr [winfo y .tv] + 40]}
			7 {[winfo pointerx .tv] < [expr (([winfo width .tv] / 2.0) + [winfo x .tv]) + 40] && [winfo pointerx .tv] > [expr (([winfo width .tv] / 2.0) + [winfo x .tv]) - 40] && [winfo pointery .tv] > [expr ([winfo height .tv] + [winfo y .tv]) - 40]}
		}
		if {[string trim [place info .tv.slist]] == {}} {
			if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_mouse_w) 0] == 1} {
				set bias [lindex $::option(osd_mouse_w) 1]
				if $pos_win($bias) {
					puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_slistCursor ::osd_mouse_w:: \033\[0m \{$pos_win($bias)\}"
					place .tv.slist -in .tv {*}$alignment($bias)
					focus .tv.slist.lb_station
					.tv.slist.lb_station selection set [expr [lindex $::station(last) 2] - 1]
					.tv.slist.lb_station activate [expr [lindex $::station(last) 2] - 1]
					bind .tv.slist <Any-Leave> {
						set ::data(after_leave_slist_id) [after 1000 {
							.tv.slist.lb_station selection clear 0 end
							focus .tv
							place forget .tv.slist
							log_writeOutTv 0 "Removing station list from video window."
							.tv.bg configure -cursor arrow
							.tv.bg.w configure -cursor arrow
							tv_wmCursorHide .tv.bg 1
							tv_wmCursorHide .tv.bg.w 1
							bind .tv.slist <Any-Leave> {}
						}]
						bind .tv.slist <Any-Enter> {
							catch {after cancel $::data(after_leave_slist_id)}
						}
					}
					log_writeOutTv 0 "Adding station list to video window with place window manager."
				}
				return
			}
			if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_mouse_f) 0] == 1} {
				set bias [lindex $::option(osd_mouse_f) 1]
				if $pos($bias) {
					puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_slistCursor ::osd_mouse_f:: \033\[0m \{$pos_win($bias)\}"
					place .tv.slist -in .tv {*}$alignment($bias)
					focus .tv.slist.lb_station
					.tv.slist.lb_station selection set [expr [lindex $::station(last) 2] - 1]
					.tv.slist.lb_station activate [expr [lindex $::station(last) 2] - 1]
					bind .tv.slist <Any-Leave> {
							set ::data(after_leave_slist_id) [after 1000 {
							.tv.slist.lb_station selection clear 0 end
							focus .tv
							place forget .tv.slist
							log_writeOutTv 0 "Removing station list from video window."
							.tv.bg configure -cursor arrow
							.tv.bg.w configure -cursor arrow
							tv_wmCursorHide .tv.bg 1
							tv_wmCursorHide .tv.bg.w 1
							bind .tv.slist <Any-Leave> {}
						}]
						bind .tv.slist <Any-Enter> {
							catch {after cancel $::data(after_leave_slist_id)}
						}
					}
					log_writeOutTv 0 "Adding station list to video window with place window manager."
				}
				return
			}
		}
	}
}

proc tv_slistLirc {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_slistLirc \033\[0m"
	if {[wm attributes .tv -fullscreen] == 1} {
		if {[string trim [place info .tv.slist_lirc]] == {}} {
			log_writeOutTv 0 "OSD station list for remote controls started."
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
				.tv.slist_lirc.lb_station configure -font "{$font} $size" -foreground $color
			} else {
				.tv.slist_lirc.lb_station configure -font "{$font} $size {$style}" -foreground $color
			}
			place .tv.slist_lirc -in .tv {*}$alignment($bias)
			.tv.slist_lirc.lb_station selection set [expr [lindex $::station(last) 2] - 1]
			.tv.slist_lirc.lb_station see [expr [lindex $::station(last) 2] - 1]
			.tv.slist_lirc.lb_station activate [expr [lindex $::station(last) 2] - 1]
		} else {
			log_writeOutTv 0 "Closing OSD station list for remote controls."
			if {"[.tv.slist_lirc.lb_station cget -state]" == "disabled"} {
				if {$::option(rec_allow_sta_change) == 1} {
					set get_lb_index [expr [.tv.slist_lirc.lb_station curselection] + 1]
					chan_zapperStationNr .fstations.treeSlist $get_lb_index
					.tv.slist_lirc.lb_station selection clear 0 end
				} else {
					.tv.slist_lirc.lb_station selection clear 0 end
				}
			} else {
				set get_lb_index [expr [.tv.slist_lirc.lb_station curselection] + 1]
				chan_zapperStationNr .fstations.treeSlist $get_lb_index
				.tv.slist_lirc.lb_station selection clear 0 end
			}
			focus .tv
			place forget .tv.slist_lirc
		}
	}
}

proc tv_slistLircMoveUp {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_slistLircMoveUp \033\[0m"
	if {[string trim [place info .tv.slist_lirc]] != {}} {
		if {[.tv.slist_lirc.lb_station curselection] > 0} {
			set new_index [expr [.tv.slist_lirc.lb_station curselection] - 1]
			.tv.slist_lirc.lb_station selection clear 0 end
			.tv.slist_lirc.lb_station selection set $new_index
			.tv.slist_lirc.lb_station activate $new_index
			.tv.slist_lirc.lb_station see $new_index
		} else {
			set new_index end
			.tv.slist_lirc.lb_station selection clear 0 end
			.tv.slist_lirc.lb_station selection set $new_index
			.tv.slist_lirc.lb_station activate $new_index
			.tv.slist_lirc.lb_station see $new_index
		}
	}
}

proc tv_slistLircMoveDown {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_slistLircMoveDown \033\[0m"
	if {[string trim [place info .tv.slist_lirc]] != {}} {
		if {[.tv.slist_lirc.lb_station curselection] < [expr [.tv.slist_lirc.lb_station index end] - 1]} {
			set new_index [expr [.tv.slist_lirc.lb_station curselection] + 1]
			.tv.slist_lirc.lb_station selection clear 0 end
			.tv.slist_lirc.lb_station selection set $new_index
			.tv.slist_lirc.lb_station activate $new_index
			.tv.slist_lirc.lb_station see $new_index
		} else {
			set new_index 0
			.tv.slist_lirc.lb_station selection clear 0 end
			.tv.slist_lirc.lb_station selection set $new_index
			.tv.slist_lirc.lb_station activate $new_index
			.tv.slist_lirc.lb_station see $new_index
		}
	}
}
