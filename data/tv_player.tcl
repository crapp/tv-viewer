#       tv_player.tcl
#       © Copyright 2007-2009 Christian Rapp <saedelaere@arcor.de>
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


proc tv_playerFullscreen {mw tv_cont tv_bg} {
	if {[wm attributes $mw -fullscreen] == 0} {
		if {[winfo exists .tv.file_play_bar] == 1} {
			if {[string trim [grid info .tv.file_play_bar]] != {}} {
				grid remove .tv.file_play_bar
				bind $tv_cont <Motion> {tv_playerCursorHide .tv.bg.w 0
										tv_playerCursorPlaybar %Y}
				bind $tv_bg <Motion> {tv_playerCursorHide .tv.bg 0
									  tv_playerCursorPlaybar %Y}
				.tv.file_play_bar.b_fullscreen configure -image $::icon_m(nofullscreen)
			} else {
				bind $tv_cont <Motion> {tv_playerCursorHide .tv.bg.w 0}
				bind $tv_bg <Motion> {tv_playerCursorHide .tv.bg 0}
			}
			bind $mw <ButtonPress-1> {.tv.bg.w configure -cursor arrow
									  .tv.bg configure -cursor arrow}
			set ::cursor($tv_cont) ""
			set ::cursor($tv_bg) ""
			tv_playerCursorHide $tv_cont 0
			tv_playerCursorHide $tv_bg 0
			wm attributes $mw -fullscreen 1
			after 500 {
				if {$::data(panscanAuto) == 1} {
					set ::data(panscanAuto) 0
					tv_playerPanscanAuto
				}
			}
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Going to full-screen mode."
			flush $::logf_tv_open_append
			return
		} else {
			bind $tv_cont <Motion> {tv_playerCursorHide .tv.bg.w 0
									tv_playerCursorSlist %X %Y}
			bind $tv_bg <Motion> {tv_playerCursorHide .tv.bg 0
								  tv_playerCursorSlist %X %Y}
			bind $mw <ButtonPress-1> {.tv.bg.w configure -cursor arrow
									  .tv.bg configure -cursor arrow}
			set ::cursor($tv_cont) ""
			set ::cursor($tv_bg) ""
			tv_playerCursorHide $tv_cont 0
			tv_playerCursorHide $tv_bg 0
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Going to full-screen mode."
			flush $::logf_tv_open_append
			wm attributes $mw -fullscreen 1
			after 500 {
				if {$::data(panscanAuto) == 1} {
					set ::data(panscanAuto) 0
					tv_playerPanscanAuto
				}
			}
		}
		if {[winfo exists .tv.slist] && [string trim [place info .tv.slist]] != {}} {
			.tv.slist.lb_station selection clear 0 end
			place forget .tv.slist
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Removing station list from video window."
			flush $::logf_tv_open_append
		}
		return
	} else {
		if {[winfo exists .tv.file_play_bar] == 1} {
			grid .tv.file_play_bar -in .tv -row 1 -column 0 -sticky ew
			bind .tv.file_play_bar  <Leave> {}
			.tv.file_play_bar.b_fullscreen configure -image $::icon_m(fullscreen)
		}
		if {[winfo exists .tv.slist] && [string trim [place info .tv.slist]] != {}} {
			.tv.slist.lb_station selection clear 0 end
			place forget .tv.slist
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Removing station list from video window."
			flush $::logf_tv_open_append
		}
		if {[winfo exists .tv.slist_lirc] && [string trim [place info .tv.slist_lirc]] != {}} {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Closing OSD station list for remote controls."
			flush $::logf_tv_open_append
			.tv.slist_lirc.lb_station selection clear 0 end
			focus .tv
			place forget .tv.slist_lirc
		}
		bind $tv_cont <Motion> {}
		bind $tv_bg <Motion> {}
		bind $mw <ButtonPress-1> {}
		set ::cursor($tv_cont) ""
		set ::cursor($tv_bg) ""
		tv_playerCursorHide $tv_bg 1
		tv_playerCursorHide $tv_cont 1
		$tv_cont configure -cursor arrow
		$tv_bg configure -cursor arrow
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Going to windowed mode."
		flush $::logf_tv_open_append
		wm attributes $mw -fullscreen 0
		after 500 {
			if {$::data(panscanAuto) == 1} {
				set ::data(panscanAuto) 0
				tv_playerPanscanAuto
			}
		}
	}
}

proc tv_playerCursorHide {w com} {
	if {[info exists ::option(cursor_id\($w\))] == 1} {
		foreach id [split $::option(cursor_id\($w\))] {
			after cancel $id
		}
		unset -nocomplain ::option(cursor_id\($w\))
	}
	if {$com == 1} return
	if {"$::cursor($w)" == "none"} {
		set ::cursor($w) ""
		$w configure -cursor arrow
	} else {
		lappend ::option(cursor_id\($w\)) [after 3000 "$w configure -cursor none; set ::cursor($w) none"]
	}
}

proc tv_playerCursorPlaybar {ypos} {
	if {[string trim [grid info .tv.file_play_bar]] == {}} {
		if {$ypos > [expr [winfo screenheight .] - 20]} {
			grid .tv.file_play_bar -in .tv -row 1 -column 0 -sticky ew
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Adding video player bar to grid window manager."
			flush $::logf_tv_open_append
		}
		return
	}
	if {[string trim [grid info .tv.file_play_bar]] != {}} {
		if {$ypos < [expr [winfo screenheight .] - 60]} {
			grid remove .tv.file_play_bar
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Removing video player bar from grid window manager."
			flush $::logf_tv_open_append
			.tv.bg configure -cursor arrow
			.tv.bg.w configure -cursor arrow
			tv_playerCursorHide .tv.bg 1
			tv_playerCursorHide .tv.bg.w 1
		}
		return
	}
}

proc tv_playerCursorSlist {xpos ypos} {
	if {[winfo exists .tv.slist]} {
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
			0 {$xpos < 40}
			3 {$xpos < 40}
			6 {$xpos < 40}
			2 {$xpos > [expr [winfo screenwidth .] - 40]}
			5 {$xpos > [expr [winfo screenwidth .] - 40]}
			8 {$xpos > [expr [winfo screenwidth .] - 40]}
			1 {$ypos > [expr [winfo screenheight .] - 40]}
			7 {$ypos < 40}
		}
		if {[string trim [place info .tv.slist]] == {}} {
			if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_mouse_w) 0] == 1} {
				set bias [lindex $::option(osd_mouse_w) 1]
				if $pos($bias) {
					place .tv.slist -in .tv {*}$alignment($bias)
					focus .tv.slist.lb_station
					.tv.slist.lb_station selection set [expr [lindex $::station(last) 2] - 1]
					.tv.slist.lb_station activate [expr [lindex $::station(last) 2] - 1]
					bind .tv.slist <Any-Leave> {
						set ::data(after_leave_slist_id) [after 1000 {
							.tv.slist.lb_station selection clear 0 end
							focus .tv
							place forget .tv.slist
							puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Removing station list from video window."
							flush $::logf_tv_open_append
							.tv.bg configure -cursor arrow
							.tv.bg.w configure -cursor arrow
							tv_playerCursorHide .tv.bg 1
							tv_playerCursorHide .tv.bg.w 1
							bind .tv.slist <Any-Leave> {}
						}]
						bind .tv.slist <Any-Enter> {
							catch {after cancel $::data(after_leave_slist_id)}
						}
					}
					puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Adding station list to video window with place window manager."
					flush $::logf_tv_open_append
				}
				return
			}
			if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_mouse_f) 0] == 1} {
				set bias [lindex $::option(osd_mouse_f) 1]
				if $pos($bias) {
					place .tv.slist -in .tv {*}$alignment($bias)
					focus .tv.slist.lb_station
					.tv.slist.lb_station selection set [expr [lindex $::station(last) 2] - 1]
					.tv.slist.lb_station activate [expr [lindex $::station(last) 2] - 1]
					bind .tv.slist <Any-Leave> {
							set ::data(after_leave_slist_id) [after 1000 {
							.tv.slist.lb_station selection clear 0 end
							focus .tv
							place forget .tv.slist
							puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Removing station list from video window."
							flush $::logf_tv_open_append
							.tv.bg configure -cursor arrow
							.tv.bg.w configure -cursor arrow
							tv_playerCursorHide .tv.bg 1
							tv_playerCursorHide .tv.bg.w 1
							bind .tv.slist <Any-Leave> {}
						}]
						bind .tv.slist <Any-Enter> {
							catch {after cancel $::data(after_leave_slist_id)}
						}
					}
					puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Adding station list to video window with place window manager."
					flush $::logf_tv_open_append
				}
				return
			}
		}
	}
}

proc tv_playerLircSlist {} {
	if {[wm attributes .tv -fullscreen] == 1} {
		if {[string trim [place info .tv.slist_lirc]] == {}} {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] OSD station list for remote controls started."
			flush $::logf_tv_open_append
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
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Closing OSD station list for remote controls."
			flush $::logf_tv_open_append
			set get_lb_index [expr [.tv.slist_lirc.lb_station curselection] + 1]
			main_stationStationNr .label_stations $get_lb_index
			.tv.slist_lirc.lb_station selection clear 0 end
			focus .tv
			place forget .tv.slist_lirc
		}
	}
}

proc tv_playerLircSlistMoveUp {} {
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

proc tv_playerLircSlistMoveDown {} {
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

proc tv_playerGetVidData {} {
	if {[info exists ::data(mplayer)]} {
		gets $::data(mplayer) line
		if {[eof $::data(mplayer)]} {
			puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] MPlayer reported end of file. Playback is stopped."
			flush $::logf_tv_open_append
			catch {close $::data(mplayer)}
			unset ::data(mplayer)
			place forget .tv.bg.w
			place .tv.l_image -relx 0.5 -rely 0.5 -anchor center
			bind .tv.bg.w <Configure> {}
			if {[winfo exists .station]} {
				.station.top_buttons.b_station_preview state !pressed
			} else {
				.top_buttons.button_starttv state !pressed
			}
			catch {tv_playerComputeFilePos cancel}
			tv_playerHeartbeatCmd cancel
			if {[winfo exists .tv.file_play_bar] == 1} {
				.tv.file_play_bar.b_play state !disabled
				.tv.file_play_bar.b_pause state disabled
				.tv.file_play_bar.b_play configure -command {tv_playerPlaybackFile .tv.bg .tv.bg.w 0 "$::tv(current_rec_file)"}
				bind .tv <<start>> {tv_playerPlaybackFile .tv.bg .tv.bg.w 0 "$::tv(current_rec_file)"}
			}
			if {[winfo exists .tray] == 1} {
				set status_recordlinkread [catch {file readlink "$::where_is_home/tmp/record_lockfile.tmp"} resultat_recordlinkread]
				if { $status_recordlinkread == 0 } {
					catch {exec ps -eo "%p"} read_ps
					set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
					if { $status_greppid_record != 0 } {
						settooltip .tray [mc "TV-Viewer idle"]
					}
				} else {
					settooltip .tray [mc "TV-Viewer idle"]
				}
			}
			if {$::tv(stayontop) == 2} {
				wm attributes .tv -topmost 0
			}
		} else {
			if {[string match "A:*V:*A-V:*" $line] != 1} {
				puts $::logf_mpl_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] $line"
				flush $::logf_mpl_open_append
			}
			if {[regexp {^VO:.*=> *([^ ]+)} $line => resolution] == 1} {
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] MPlayer reported video resolution $resolution."
				flush $::logf_tv_open_append
				foreach {resolx resoly} [split $resolution x] {
					set ::option(resolx) $resolx
					set ::option(resoly) $resoly
				}
				.tv.bg configure -width $::option(resolx) -height $::option(resoly)
				bind .tv.bg.w <Configure> {place %W -width [expr (%h * ($::option(resolx).0 / $::option(resoly).0))]}
			}
			if {[string match -nocase "ID_LENGTH=*" $line]} {
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] This is a recording, starting to calculate file size and position."
				flush $::logf_tv_open_append
				set status_timeslinkread [catch {file readlink "$::where_is_home/tmp/timeshift_lockfile.tmp"} resultat_timeslinkread]
				set status_recordlinkread [catch {file readlink "$::where_is_home/tmp/record_lockfile.tmp"} resultat_recordlinkread]
				if { $status_recordlinkread == 0 || $status_timeslinkread == 0 } {
					catch {exec ps -eo "%p"} read_ps
					set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
					set status_greppid_times [catch {agrep -w "$read_ps" $resultat_timeslinkread} resultat_greppid_times]
					if { $status_greppid_record == 0 || $status_greppid_times == 0 } {
						catch {tv_playerComputeFileSize cancel}
						set length [lindex [split $line "="] end]
						set length_int [expr int($length)]
						set seconds [expr [clock seconds] - $length_int]
						after 0 [list tv_playerComputeFileSize $seconds]
					} else {
						catch {tv_playerComputeFileSize cancel_rec}
						if {[info exists ::data(file_size)] == 0} {
							set length [lindex [split $line "="] end]
							set length_int [expr int($length)]
							set ::data(file_size) $length_int
						}
					}
				} else {
					catch {tv_playerComputeFileSize cancel_rec}
					if {[info exists ::data(file_size)] == 0} {
						set length [lindex [split $line "="] end]
						set length_int [expr int($length)]
						set ::data(file_size) $length_int
					}
				}
				set ::data(file_pos_calc) [clock seconds]
				after 10 [list tv_playerComputeFilePos $::data(file_pos_calc)]
			}
			if {[string match -nocase "Starting playback*" $line]} {
				tv_volume_control .bottom_buttons $::volume_scale
				set status_timeslinkread [catch {file readlink "$::where_is_home/tmp/timeshift_lockfile.tmp"} resultat_timeslinkread]
				set status_recordlinkread [catch {file readlink "$::where_is_home/tmp/record_lockfile.tmp"} resultat_recordlinkread]
				if { $status_recordlinkread == 0 || $status_timeslinkread == 0 } {
					catch {exec ps -eo "%p"} read_ps
					set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
					set status_greppid_times [catch {agrep -w "$read_ps" $resultat_timeslinkread} resultat_greppid_times]
					if { $status_greppid_record != 0 && $status_greppid_times != 0 } {
						bind . <<input_up>> "main_stationInput 1 1"
						bind . <<input_down>> "main_stationInput 1 -1"
						bind . <<teleview>> {tv_playerUi}
						bind .tv <<input_up>> "main_stationInput 1 1"
						bind .tv <<input_down>> "main_stationInput 1 -1"
						bind .tv <<teleview>> {tv_playerUi}
					}
				} else {
					bind . <<input_up>> "main_stationInput 1 1"
					bind . <<input_down>> "main_stationInput 1 -1"
					bind . <<teleview>> {tv_playerUi}
					bind .tv <<input_up>> "main_stationInput 1 1"
					bind .tv <<input_down>> "main_stationInput 1 -1"
					bind .tv <<teleview>> {tv_playerUi}
				}
			}
			if {[string match -nocase "ANS_TIME_POSITION*" $line]} {
				if {$::tv(getvid_seek) == 0} {
					tv_playerComputeFilePos cancel
					set pos [lindex [split $line \=] end]
					set ::data(file_pos_calc) [expr [clock seconds] - [expr round($pos)]]
					set ::data(file_pos) [expr round($pos)]
					after 10 [list tv_playerComputeFilePos 0]
					bind .tv <<forward_end>> {tv_playerInitiateSeek "tv_playerSeek 0 2"}
					bind .tv <<forward_10s>> {tv_playerInitiateSeek "tv_playerSeek 10 1"}
					bind .tv <<forward_1m>> {tv_playerInitiateSeek "tv_playerSeek 60 1"}
					bind .tv <<forward_10m>> {tv_playerInitiateSeek "tv_playerSeek 600 1"}
					bind .tv <<rewind_10s>> {tv_playerInitiateSeek "tv_playerSeekk 10 -1"}
					bind .tv <<rewind_1m>> {tv_playerInitiateSeek "tv_playerSeek 60 -1"}
					bind .tv <<rewind_10m>> {tv_playerInitiateSeek "tv_playerSeek 600 -1"}
					bind .tv <<rewind_start>> {tv_playerInitiateSeek "tv_playerSeek 0 -2"}
				} else {
					tv_playerComputeFilePos cancel
					set pos [lindex [split $line \=] end]
					set ::data(file_pos_calc) [expr [clock seconds] - [expr round($pos)]]
					set ::data(file_pos) [expr round($pos)]
					after 10 [list tv_playerComputeFilePos 0]
					tv_playerSeek $::tv(seek_secs) $::tv(seek_dir)
				}
			}
			set ::data(report) $line
		}
	} else {
		puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Tried to read channel ::data(mplayer).
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Pipe seems to be broken."
		flush $::logf_tv_open_append
	}
}

proc tv_playerMplayerRemote {command} {
	if {[info exists ::data(mplayer)] == 0} {return 1}
	if {[string trim $::data(mplayer)] != {}} {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Sending command $command to MPlayer remote channel."
		flush $::logf_tv_open_append
		catch {puts -nonewline $::data(mplayer) "$command \n"}
		flush $::data(mplayer)
		return 0
	} else {
		return 1
	}
}

proc tv_playerPanscan {w direct} {
	set status_tvplayback [tv_playerMplayerRemote alive]
	if {$status_tvplayback == 1} {return}
	if {$direct == 1} {
		if {$::data(panscan) == 100} return
		place $w -relheight [expr {[dict get [place info $w] -relheight] + 0.05}]
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Increasing zoom by 5%."
		flush $::logf_tv_open_append
		set ::data(panscan) [expr $::data(panscan) + 5]
		set ::data(panscanAuto) 0
		if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list tv_osd osd_group_w 1000 "Zoom $::data(panscan)"]
		}
		if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list tv_osd osd_group_f 1000 "Zoom $::data(panscan)"]
		}
	}
	if {$direct == -1} {
		if {$::data(panscan) == -50} return
		place $w -relheight [expr {[dict get [place info $w] -relheight] - 0.05}]
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Decreasing zoom by 5%."
		flush $::logf_tv_open_append
		set ::data(panscan) [expr $::data(panscan) - 5]
		set ::data(panscanAuto) 0
		if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list tv_osd osd_group_w 1000 "Zoom $::data(panscan)"]
		}
		if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list tv_osd osd_group_f 1000 "Zoom $::data(panscan)"]
		}
	}
	if {$direct == 0} {
		place $w -relheight 1 -relx 0.5 -rely 0.5
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting zoom to 100% and center video."
		flush $::logf_tv_open_append
		set ::data(panscan) 0
		set ::data(movevidX) 0
		set ::data(movevidY) 0
		set ::data(panscanAuto) 0
		if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list tv_osd osd_group_w 1000 [mc "Pan&Scan 4:3"]]
		}
		if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list tv_osd osd_group_f 1000 [mc "Pan&Scan 4:3"]]
		}
	}
}

proc tv_playerPanscanAuto {} {
	set status_tvplayback [tv_playerMplayerRemote alive]
	if {$status_tvplayback == 1} {return}
	if {[wm attributes .tv -fullscreen] == 0} {
		if {$::data(panscanAuto) == 0} {
			place .tv.bg.w -relheight 1 -relx 0.5 -rely 0.5
			if {[winfo exists .tv.file_play_bar] == 0} {
				wm geometry .tv [winfo width .tv]x[expr int(ceil([winfo width .tv].0 / 1.777777778))]
			} else {
				set height [expr int(ceil([winfo width .tv].0 / 1.777777778))]
				set heightwp [expr $height + [winfo height .tv.file_play_bar]]
				wm geometry .tv [winfo width .tv]x$heightwp
			}
			set relheight [lindex [split [expr ([winfo reqwidth .tv.bg].0 / [winfo reqheight .tv.bg].0)] .] end]
			set panscan_multi [expr int(ceil(0.$relheight / 0.05))]
			set ::data(panscan) [expr ($panscan_multi * 5)]
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Auto zoom 16:9, changing geometry of tv window and realtive height of container frame."
			flush $::logf_tv_open_append
			if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
				after 0 [list tv_osd osd_group_w 1000 [mc "Pan&Scan 16:9"]]
			}
			if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
				after 0 [list tv_osd osd_group_f 1000 [mc "Pan&Scan 16:9"]]
			}
			set ::data(panscanAuto) 1
			place .tv.bg.w -relheight [expr [winfo reqwidth .tv.bg].0 / [winfo reqheight .tv.bg].0]
		} else {
			tv_playerPanscan .tv.bg.w 0
		}
	} else {
		if {$::data(panscanAuto) == 0} {
			if {[dict get [place info .tv.bg.w] -relheight] != 1} {
				set width_diff [expr [winfo width .tv.bg] - [winfo width .tv.bg.w]]
				set relheight [expr [dict get [place info .tv.bg.w] -relheight] + ($width_diff.0 / [winfo width .tv.bg.w].0)]
				if {$relheight == [dict get [place info .tv.bg.w] -relheight]} return
				place .tv.bg.w -relheight 1 -relx 0.5 -rely 0.5
				catch {after cancel $::data(panscanAuto_id)}
				set ::data(panscanAuto_id) [after 1000 {
				set width_diff [expr [winfo width .tv.bg] - [winfo width .tv.bg.w]]
				set relheight [expr [dict get [place info .tv.bg.w] -relheight] + ($width_diff.0 / [winfo width .tv.bg.w].0)]
				set panscan_multi [expr int(ceil(0.[lindex [split $relheight .] end] / 0.05))]
				set ::data(panscan) [expr ($panscan_multi * 5)]
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Auto zoom 16:9, changing realtive height of container frame."
				flush $::logf_tv_open_append
				if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
					after 0 [list tv_osd osd_group_w 1000 [mc "Pan&Scan 16:9"]]
				}
				if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
					after 0 [list tv_osd osd_group_f 1000 [mc "Pan&Scan 16:9"]]
				}
				set ::data(panscanAuto) 1
				place .tv.bg.w -relheight $relheight
				}]

			} else {
				set width_diff [expr [winfo width .tv.bg] - [winfo width .tv.bg.w]]
				set relheight [expr [dict get [place info .tv.bg.w] -relheight] + ($width_diff.0 / [winfo width .tv.bg.w].0)]
				set panscan_multi [expr int(ceil(0.[lindex [split $relheight .] end] / 0.05))]
				set ::data(panscan) [expr ($panscan_multi * 5)]
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Auto zoom 16:9, changing realtive height of container frame."
				flush $::logf_tv_open_append
				if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
					after 0 [list tv_osd osd_group_w 1000 [mc "Pan&Scan 16:9"]]
				}
				if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
					after 0 [list tv_osd osd_group_f 1000 [mc "Pan&Scan 16:9"]]
				}
				set ::data(panscanAuto) 1
				place .tv.bg.w -relheight $relheight
			}
		} else {
			tv_playerPanscan .tv.bg.w 0
		}
	}
}

proc tv_playerMoveVideo {dir} {
	if {$dir == 0} {
		if {$::data(movevidX) == 100} return
		place .tv.bg.w -relx [expr {[dict get [place info .tv.bg.w] -relx] + 0.005}]
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Moving video to the right by 0.5%."
		flush $::logf_tv_open_append
		set ::data(movevidX) [expr $::data(movevidX) + 1]
		if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list tv_osd osd_group_w 1000 [mc "Move x=%" $::data(movevidX)]]
		}
		if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list tv_osd osd_group_f 1000 [mc "Move x=%" $::data(movevidX)]]
		}
		return
	}
	if {$dir == 1} {
		if {$::data(movevidY) == 100} return
		place .tv.bg.w -rely [expr {[dict get [place info .tv.bg.w] -rely] + 0.005}]
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Moving video down by 0.5%."
		flush $::logf_tv_open_append
		set ::data(movevidY) [expr $::data(movevidY) + 1]
		if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list tv_osd osd_group_w 1000 [mc "Move y=%" $::data(movevidY)]]
		}
		if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list tv_osd osd_group_f 1000 [mc "Move y=%" $::data(movevidY)]]
		}
		return
	}
	if {$dir == 2} {
		if {$::data(movevidX) == -100} return
		place .tv.bg.w -relx [expr {[dict get [place info .tv.bg.w] -relx] - 0.005}]
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Moving video to the left by 0.5%."
		flush $::logf_tv_open_append
		set ::data(movevidX) [expr $::data(movevidX) - 1]
		if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list tv_osd osd_group_w 1000 [mc "Move x=%" $::data(movevidX)]]
		}
		if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list tv_osd osd_group_f 1000 [mc "Move x=%" $::data(movevidX)]]
		}
		return
	}
	if {$dir == 3} {
		if {$::data(movevidY) == -100} return
		place .tv.bg.w -rely [expr {[dict get [place info .tv.bg.w] -rely] - 0.005}]
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Moving video up by 0.5%."
		flush $::logf_tv_open_append
		set ::data(movevidY) [expr $::data(movevidY) - 1]
		if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list tv_osd osd_group_w 1000 [mc "Move y=%" $::data(movevidY)]]
		}
		if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list tv_osd osd_group_f 1000 [mc "Move y=%" $::data(movevidY)]]
		}
		return
	}
}

proc tv_playerStayonTop {com} {
	if {$com == 0} {
		wm attributes .tv -topmost 0
	}
	if {$com == 1} {
		wm attributes .tv -topmost 1
	}
	if {$com == 2} {
		set status [tv_playerMplayerRemote alive]
		if {$status != 1} {
			wm attributes .tv -topmost 1
		}
	}
}

proc tv_playerGivenSize {w size} {
	if {$size == 1} {
		wm geometry .tv {}
		$w configure -width $::option(resolx) -height $::option(resoly)
		place .tv.bg.w -width [expr ($::option(resoly) * ($::option(resolx).0 / $::option(resoly).0))]
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting TV window to standard size."
		flush $::logf_tv_open_append
		return
	} else {
		wm geometry .tv {}
		$w configure -width [expr round($::option(resolx) * $size)] -height [expr round($::option(resoly) * $size)]
		place .tv.bg.w -width [expr ($::option(resoly) * ($::option(resolx).0 / $::option(resoly).0))]
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting size of TV window to [expr $size * 100]."
		flush $::logf_tv_open_append
		return
	}
}

proc tv_volume_control {wfbottom value} {
	set status_tv_playback [tv_playerMplayerRemote alive]
	if {$status_tv_playback != 1} {
		if {"$value" != "mute"} {
			if {[$wfbottom.scale_volume instate disabled] == 1} {return}
			set value [expr int($value)]
			if {$value > 100} {
				set value 100
				return
			}
			if {$value < 0} {
				set value 0
				return
			}
			if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
				after 0 [list tv_osd osd_group_w 1000 "Volume $value"]
			}
			if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
				after 0 [list tv_osd osd_group_f 1000 "Volume $value"]
			}
			
			set ::volume_scale $value
			tv_playerMplayerRemote "volume [expr int($value)] 1"
		} else {
			if {[$wfbottom.scale_volume instate disabled] == 0} {
				set ::volume(mute_old_value) "$::volume_scale"
				set ::volume_scale 0
				$wfbottom.scale_volume state disabled
				$wfbottom.button_mute configure -image $::icon_m(volume-error)
				if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
					after 0 [list tv_osd osd_group_w 1000 [mc "Mute"]]
				}
				if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
					after 0 [list tv_osd osd_group_f 1000 [mc "Mute"]]
				}
				tv_playerMplayerRemote "volume 0 1"
			} else {
				set ::volume_scale "$::volume(mute_old_value)"
				$wfbottom.scale_volume state !disabled
				$wfbottom.button_mute configure -image $::icon_m(volume)
				if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
					after 0 [list tv_osd osd_group_w 1000 "Volume $::volume(mute_old_value)"]
				}
				if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
					after 0 [list tv_osd osd_group_f 1000 "Volume $::volume(mute_old_value)"]
				}
				tv_playerMplayerRemote "volume [expr int($::volume_scale)] 1"
			}
		}
	}
}

proc tv_playerPlayback {tv_bg tv_cont} {
	array set vopt {
		x11 {-vo x11}
		xv {-vo xv}
		xvmc {-vo xvmc:bobdeint -vc ffmpeg12mc}
		vdpau {-vo vdpau:deint=4 -vc ffmpeg12vdpau}
		gl {-vo gl}
		gl(fast) {-vo gl:yuv=2:force-pbo}
		{gl(fast ATI)} {-vo gl:yuv=2:force-pbo:ati-hack}
		gl(yuv) {-vo gl:yuv=3}
		gl2 {-vo gl2}
		gl2(yuv) {-vo gl2:yuv=3}
	}
	
	array set dopt {
		None {-vf }
		Lowpass5 {-vf pp=l5}
		Yadif {-vf yadif}
		Yadif(1) {-vf yadif=1}
		LinearBlend {-vf pp=lb}
		{Kernel deinterlacer} {-vf kerndeint=5}
	}
	
	array set aopt {
		oss {-ao oss}
		alsa {-ao alsa}
		pulse {-ao pulse}
		sdl {-ao sdl}
	}
	array set copt {
		0 {}
		512 {-cache 512}
		1024 {-cache 1024}
		2048 {-cache 2048}
		4096 {-cache 4096}
		8192 {-cache 8192}
		16384 {-cache 16384}
	}
	
	array set cbopt {
		dr(0) {-nodr}
		dr(1) {-dr}
		double(0) {-nodouble}
		double(1) {-double}
		slice(0) {-noslices}
		slice(1) {-slices}
		fd(0) {}
		fd(1) {-framedrop}
		hfd(0) {}
		hfd(1) {-hardframedrop}
		autoq(0) {}
		autoq(1) {,pp -autoq 1}
		autoq(2) {,pp -autoq 2}
		autoq(3) {,pp -autoq 3}
		autoq(4) {,pp -autoq 4}
		autoq(5) {,pp -autoq 5}
		autoq(6) {,pp -autoq 6}
		softvol(0) {}
		softvol(1) {-softvol}
	}
	puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Starting tv playback..."
	flush $::logf_tv_open_append
	
	bind . <<teleview>> {}
	bind .tv <<teleview>> {}
	
	lappend mcommand {*}[auto_execok mplayer] -quiet -slave
	
	if {[string match *adaptor* $::option(player_vo)] == 1} {
		lappend mcommand -vo xv:[lindex $::option(player_vo) 1]
	} else {
		lappend mcommand {*}$vopt($::option(player_vo))
	}
	lappend mcommand {*}$aopt($::option(player_audio))
	if {[string trim $cbopt(softvol\($::option(player_aud_softvol)\))] != {}} {
		lappend mcommand {*}$cbopt(softvol\($::option(player_aud_softvol)\))
	}
	
	if {[string trim $copt($::option(player_cache))] != {}} {
		lappend mcommand {*}$copt($::option(player_cache))
	}
	lappend mcommand {*}$cbopt(dr\($::option(player_dr)\))
	lappend mcommand {*}$cbopt(double\($::option(player_double)\))
	lappend mcommand {*}$cbopt(slice\($::option(player_slice)\))
	lappend mcommand {*}$cbopt(fd\($::option(player_fd)\))
	lappend mcommand {*}$cbopt(hfd\($::option(player_hfd)\))
	
	if {$::option(player_screens) == 1} {
		if {$::option(player_screens_value) == 0} {
			lappend mcommand -stop-xscreensaver
		} else {
			set ::data(heartbeat_id) [after 30000 tv_playerHeartbeatCmd 0]
		}
	}
	set winid [expr [winfo id $tv_cont]]
	#~ lappend mcommand -zoom -nokeepaspect -input conf=$::where_is/shortcuts/input.conf {*}{-monitorpixelaspect 1} {*}{-osdlevel 0} -nocorrect-pts {*}{-vf-add screenshot} {*}{-vid 0} {*}{-aid 0} {*}{-channels 2} {*}{-af scaletempo,equalizer=0:0:0:0:0:0:0:0:0:0}
	lappend mcommand -zoom -nokeepaspect -input conf="$::where_is/shortcuts/input.conf" {*}{-monitorpixelaspect 1} {*}{-osdlevel 0}
	
	lappend mcommand -channels [lindex $::option(player_audio_channels) 0]
	
	if {[string trim $::option(player_additional_commands)] != {}} {
		lappend mcommand {*}$::option(player_additional_commands)
	}
	if {[string trim $::option(player_add_af_commands)] != {}} {
		lappend mcommand -af $::option(player_add_af_commands)
	}
	if {"$::option(player_vo)" == "vdpau" || "$::option(player_vo)" == "xvmc"} {
		puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Chosen video output driver $::option(player_vo)
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] When using this video output driver, additional video filter options are not available."
		flush $::logf_tv_open_append
	} else {
		if {[string trim $dopt($::option(player_deint))] == {-vf}} {
			if {[string trim $::option(player_add_vf_commands)] != {}} {
				lappend mcommand {*}$dopt($::option(player_deint))screenshot,$::option(player_add_vf_commands)$cbopt(autoq\($::option(player_autoq)\))
			} else {
				lappend mcommand {*}$dopt($::option(player_deint))screenshot$cbopt(autoq\($::option(player_autoq)\))
			}
		} else {
			if {[string trim $cbopt(autoq\($::option(player_autoq)\))] != {}} {
				if {[string match *pp* "$dopt($::option(player_deint))"] == 1} {
					if {[string trim $::option(player_add_vf_commands)] != {}} {
						lappend mcommand {*}$dopt($::option(player_deint)),$::option(player_add_vf_commands),screenshot {*}[lrange $cbopt(autoq\($::option(player_autoq)\)) end-1 end]
					} else {
						lappend mcommand {*}$dopt($::option(player_deint)),screenshot {*}[lrange $cbopt(autoq\($::option(player_autoq)\)) end-1 end]
					}
				} else {
					if {[string trim $::option(player_add_vf_commands)] != {}} {
						#~ append mcommand ,$::option(player_add_vf_commands)
						lappend mcommand {*}$dopt($::option(player_deint)),screenshot,$::option(player_add_vf_commands)$cbopt(autoq\($::option(player_autoq)\))
					} else {
						lappend mcommand {*}$dopt($::option(player_deint)),screenshot$cbopt(autoq\($::option(player_autoq)\))
					}
				}
			} else {
				lappend mcommand {*}$dopt($::option(player_deint)),screenshot
				if {[string trim $::option(player_add_vf_commands)] != {}} {
					append mcommand ,$::option(player_add_vf_commands)
				}
			}
		}
	}
	
	lappend mcommand -wid $winid $::option(video_device)
	
	puts $::logf_mpl_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] If playback is not starting see MPlayer logfile for details.
# \[[clock format [clock scan now] -format {%H:%M:%S}]\] MPlayer command line:
# \[[clock format [clock scan now] -format {%H:%M:%S}]\] $mcommand"
	flush $::logf_tv_open_append
	
	place forget .tv.l_image
	place $tv_cont -relx 0.5 -rely 0.5 -anchor center -relheight 1
	bind $tv_cont <Configure> {place %W -width [expr (%h * ($::option(resolx).0 / $::option(resoly).0))]}
	
	if {[winfo exists .station]} {
		.station.top_buttons.b_station_preview state pressed
	} else {
		.top_buttons.button_starttv state pressed
	}
	
	if {[winfo exists .tray] == 1} {
		catch {settooltip .tray [mc "TV-Viewer playing - %" [lindex $::station(last) 0]]}
	}
	
	if {$::tv(stayontop) == 2} {
		wm attributes .tv -topmost 1
	}
	
	set ::data(mplayer) [open "|$mcommand" r+]
	fconfigure $::data(mplayer) -blocking 0 -buffering line
	fileevent $::data(mplayer) readable [list tv_playerGetVidData]
}

proc tv_playerPlaybackFile {tv_bg tv_cont handler file} {
	if {[file exists $file]} {
		array set vopt {
			x11 {-vo x11}
			xv {-vo xv}
			xvmc {-vo xvmc:bobdeint -vc ffmpeg12mc}
			vdpau {-vo vdpau:deint=4 -vc ffmpeg12vdpau}
			gl {-vo gl}
			gl(fast) {-vo gl:yuv=2:force-pbo}
			{gl(fast ATI)} {-vo gl:yuv=2:force-pbo:ati-hack}
			gl(yuv) {-vo gl:yuv=3}
			gl2 {-vo gl2}
			gl2(yuv) {-vo gl2:yuv=3}
		}
		
		array set dopt {
			None {-vf }
			Lowpass5 {-vf pp=l5}
			Yadif {-vf yadif}
			Yadif(1) {-vf yadif=1}
			LinearBlend {-vf pp=lb}
			{Kernel deinterlacer} {-vf kerndeint=5}
		}
		
		array set aopt {
			oss {-ao oss}
			alsa {-ao alsa}
			pulse {-ao pulse}
			sdl {-ao sdl}
		}
		array set copt {
			0 {}
			512 {-cache 512}
			1024 {-cache 1024}
			2048 {-cache 2048}
			4096 {-cache 4096}
			8192 {-cache 8192}
			16384 {-cache 16384}
		}
		
		array set cbopt {
			dr(0) {-nodr}
			dr(1) {-dr}
			double(0) {-nodouble}
			double(1) {-double}
			slice(0) {-noslices}
			slice(1) {-slices}
			fd(0) {}
			fd(1) {-framedrop}
			hfd(0) {}
			hfd(1) {-hardframedrop}
			autoq(0) {}
			autoq(1) {,pp -autoq 1}
			autoq(2) {,pp -autoq 2}
			autoq(3) {,pp -autoq 3}
			autoq(4) {,pp -autoq 4}
			autoq(5) {,pp -autoq 5}
			autoq(6) {,pp -autoq 6}
			softvol(0) {}
			softvol(1) {-softvol}
		}
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Starting playback of $file."
		flush $::logf_tv_open_append
		
		lappend mcommand {*}[auto_execok mplayer] -quiet -slave -identify
		
		if {[string match *adaptor* $::option(player_vo)] == 1} {
			lappend mcommand -vo xv:[lindex $::option(player_vo) 1]
		} else {
			lappend mcommand {*}$vopt($::option(player_vo))
		}
		lappend mcommand {*}$aopt($::option(player_audio))
		if {[string trim $cbopt(softvol\($::option(player_aud_softvol)\))] != {}} {
			lappend mcommand {*}$cbopt(softvol\($::option(player_aud_softvol)\))
		}
		if {[string trim $copt($::option(player_cache))] != {}} {
			lappend mcommand {*}$copt($::option(player_cache))
		}
		lappend mcommand {*}$cbopt(dr\($::option(player_dr)\))
		lappend mcommand {*}$cbopt(double\($::option(player_double)\))
		lappend mcommand {*}$cbopt(slice\($::option(player_slice)\))
		lappend mcommand {*}$cbopt(fd\($::option(player_fd)\))
		lappend mcommand {*}$cbopt(hfd\($::option(player_hfd)\))
		
		if {$::option(player_screens) == 1} {
			if {$::option(player_screens_value) == 0} {
				lappend mcommand -stop-xscreensaver
			} else {
				set ::data(heartbeat_id) [after 30000 tv_playerHeartbeatCmd 0]
			}
		}
		set winid [expr [winfo id $tv_cont]]
		#~ lappend mcommand -zoom -nokeepaspect -input conf=$::where_is/shortcuts/input.conf {*}{-monitorpixelaspect 1} {*}{-osdlevel 0} -nocorrect-pts {*}{-vf-add screenshot} {*}{-vid 0} {*}{-aid 0} {*}{-channels 2} {*}{-af scaletempo,equalizer=0:0:0:0:0:0:0:0:0:0}
		lappend mcommand -zoom -nokeepaspect -input conf="$::where_is/shortcuts/input.conf" {*}{-monitorpixelaspect 1} {*}{-osdlevel 0}
		
		lappend mcommand -channels [lindex $::option(player_audio_channels) 0]
		
		if {[string trim $::option(player_additional_commands)] != {}} {
			lappend mcommand {*}$::option(player_additional_commands)
		}
		if {[string trim $::option(player_add_af_commands)] != {}} {
			lappend mcommand -af $::option(player_add_af_commands)
		}
		if {"$::option(player_vo)" == "vdpau" || "$::option(player_vo)" == "xvmc"} {
			puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Chosen video output driver $::option(player_vo)
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] When using this video output driver, additional video filter options are not available."
			flush $::logf_tv_open_append
		} else {
			if {[string trim $dopt($::option(player_deint))] == {-vf}} {
				if {[string trim $::option(player_add_vf_commands)] != {}} {
					lappend mcommand {*}$dopt($::option(player_deint))screenshot,$::option(player_add_vf_commands)$cbopt(autoq\($::option(player_autoq)\))
				} else {
					lappend mcommand {*}$dopt($::option(player_deint))screenshot$cbopt(autoq\($::option(player_autoq)\))
				}
			} else {
				if {[string trim $cbopt(autoq\($::option(player_autoq)\))] != {}} {
					if {[string match *pp* "$dopt($::option(player_deint))"] == 1} {
						if {[string trim $::option(player_add_vf_commands)] != {}} {
							lappend mcommand {*}$dopt($::option(player_deint)),$::option(player_add_vf_commands),screenshot {*}[lrange $cbopt(autoq\($::option(player_autoq)\)) end-1 end]
						} else {
							lappend mcommand {*}$dopt($::option(player_deint)),screenshot {*}[lrange $cbopt(autoq\($::option(player_autoq)\)) end-1 end]
						}
					} else {
						if {[string trim $::option(player_add_vf_commands)] != {}} {
							#~ append mcommand ,$::option(player_add_vf_commands)
							lappend mcommand {*}$dopt($::option(player_deint)),screenshot,$::option(player_add_vf_commands)$cbopt(autoq\($::option(player_autoq)\))
						} else {
							lappend mcommand {*}$dopt($::option(player_deint)),screenshot$cbopt(autoq\($::option(player_autoq)\))
						}
					}
				} else {
					lappend mcommand {*}$dopt($::option(player_deint)),screenshot
					if {[string trim $::option(player_add_vf_commands)] != {}} {
						append mcommand ,$::option(player_add_vf_commands)
					}
				}
			}
		}
		
		lappend mcommand -wid $winid "$file"
		
		puts $::logf_mpl_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] If playback is not starting see MPlayer logfile for details.
# \[[clock format [clock scan now] -format {%H:%M:%S}]\] MPlayer command line:
# \[[clock format [clock scan now] -format {%H:%M:%S}]\] $mcommand"
		flush $::logf_tv_open_append
		if {[winfo exists .tv.file_play_bar] == 0} {
			set tv_bar [ttk::frame .tv.file_play_bar] ; place [ttk::label $tv_bar.bg -style Toolbutton] -relwidth 1 -relheight 1
			ttk::button $tv_bar.b_play \
			-style Toolbutton \
			-image $::icon_m(playback-start) \
			-takefocus 0 \
			-command {event generate .tv <<start>>}
			ttk::button $tv_bar.b_pause \
			-style Toolbutton \
			-image $::icon_m(playback-pause) \
			-takefocus 0 \
			-command {event generate .tv <<pause>>}
			ttk::button $tv_bar.b_stop \
			-style Toolbutton \
			-image $::icon_m(playback-stop) \
			-takefocus 0 \
			-command {event generate .tv <<stop>>}
			ttk::separator $tv_bar.sep_1 \
			-orient vertical
			ttk::button $tv_bar.b_rewind_start \
			-style Toolbutton \
			-image $::icon_m(rewind-first) \
			-takefocus 0 \
			-command {event generate .tv <<rewind_start>>}
			ttk::button $tv_bar.b_rewind_small \
			-style Toolbutton \
			-image $::icon_m(rewind-small) \
			-takefocus 0 \
			-command {event generate .tv <<rewind_10s>>}
			ttk::menubutton $tv_bar.b_rew_choose \
			-style Toolbutton \
			-image $::icon_e(arrow-d) \
			-takefocus 0 \
			-menu $tv_bar.mbRewind
			ttk::button $tv_bar.b_forward_small \
			-style Toolbutton \
			-image $::icon_m(forward-small) \
			-takefocus 0 \
			-command {event generate .tv <<forward_10s>>}
			ttk::menubutton $tv_bar.b_forw_choose \
			-style Toolbutton \
			-image $::icon_e(arrow-d) \
			-takefocus 0 \
			-menu $tv_bar.mbForward
			ttk::button $tv_bar.b_forward_end \
			-style Toolbutton \
			-image $::icon_m(forward-last) \
			-takefocus 0 \
			-command {event generate .tv <<forward_end>>}
			ttk::separator $tv_bar.sep_2 \
			-orient vertical
			ttk::button $tv_bar.b_fullscreen \
			-style Toolbutton \
			-image $::icon_m(fullscreen) \
			-takefocus 0 \
			-command [list tv_playerFullscreen .tv $tv_cont $tv_bg]
			ttk::label $tv_bar.l_time \
			-width 20 \
			-anchor center \
			-textvariable choice(label_file_time)
			
			menu $tv_bar.mbRewind \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))
			menu $tv_bar.mbForward \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))
			
			$tv_bar.mbRewind add checkbutton \
			-label [mc "-10 seconds"] \
			-accelerator [mc "Left"] \
			-command [list tv_switch_seek $tv_bar -1 -10s tv(check_rew_10s)] \
			-variable tv(check_rew_10s)
			$tv_bar.mbRewind add checkbutton \
			-label [mc "-1 minute"] \
			-accelerator [mc "Shift+Left"] \
			-command [list tv_switch_seek $tv_bar -1 -1m tv(check_rew_1m)] \
			-variable tv(check_rew_1m)
			$tv_bar.mbRewind add checkbutton \
			-label [mc "-10 minutes"] \
			-accelerator [mc "Ctrl+Shift+Left"] \
			-command [list tv_switch_seek $tv_bar -1 -10m tv(check_rew_10m)] \
			-variable tv(check_rew_10m)
			$tv_bar.mbForward add checkbutton \
			-label [mc "+10 seconds"] \
			-accelerator [mc "Right"] \
			-command [list tv_switch_seek $tv_bar 1 +10s tv(check_fow_10s)] \
			-variable tv(check_fow_10s)
			$tv_bar.mbForward add checkbutton \
			-label [mc "+1 minute"] \
			-accelerator [mc "Shift+Right"] \
			-command [list tv_switch_seek $tv_bar 1 +1m tv(check_fow_1m)] \
			-variable tv(check_fow_1m)
			$tv_bar.mbForward add checkbutton \
			-label [mc "+10 minutes"] \
			-accelerator [mc "Ctrl+Shift+Right"] \
			-command [list tv_switch_seek $tv_bar 1 +10m tv(check_fow_10m)] \
			-variable tv(check_fow_10m)
			
			$tv_bar.l_time configure -background black -foreground white -relief sunken -borderwidth 2
			set ::choice(label_file_time) "00:00:00"
			
			grid $tv_bar -in .tv -row 1 -column 0 \
			-sticky ew
			grid $tv_bar.b_play -in $tv_bar -row 0 -column 0 \
			-pady 2 \
			-padx "2 0"
			grid $tv_bar.b_pause -in $tv_bar -row 0 -column 1 \
			-pady 2 \
			-padx "2 0"
			grid $tv_bar.b_stop -in $tv_bar -row 0 -column 2 \
			-pady 2 \
			-padx "2 0"
			grid $tv_bar.sep_1 -in $tv_bar -row 0 -column 3 \
			-sticky ns \
			-padx "2 0"
			grid $tv_bar.b_rewind_start -in $tv_bar -row 0 -column 4 \
			-pady 2 \
			-padx "2 0"
			grid $tv_bar.b_rew_choose -in $tv_bar -row 0 -column 5 \
			-sticky ns \
			-pady 2 \
			-padx "1 0"
			grid $tv_bar.b_rewind_small -in $tv_bar -row 0 -column 6 \
			-pady 2 \
			-padx "1 0"
			grid $tv_bar.b_forward_small -in $tv_bar -row 0 -column 7 \
			-pady 2 \
			-padx "1 0"
			grid $tv_bar.b_forw_choose -in $tv_bar -row 0 -column 8 \
			-sticky ns \
			-pady 2 \
			-padx "1 0"
			grid $tv_bar.b_forward_end -in $tv_bar -row 0 -column 9 \
			-pady 2 \
			-padx "1 0"
			grid $tv_bar.sep_2 -in $tv_bar -row 0 -column 10 \
			-sticky ns \
			-padx "2 0"
			grid $tv_bar.b_fullscreen -in $tv_bar -row 0 -column 11 \
			-pady 2 \
			-padx "2 0"
			grid $tv_bar.l_time -in $tv_bar -row 0 -column 12 \
			-sticky nse \
			-padx "0 2" \
			-pady 2
			
			grid columnconfigure $tv_bar 12 -weight 1
			
			set ::tv(check_fow_10s) 1
			set ::tv(check_rew_10s) 1
			.tv.file_play_bar.b_pause state disabled
			
			if {[wm attributes .tv -fullscreen] == 1} {
				grid remove .tv.file_play_bar
				bind $tv_cont <Motion> {tv_playerCursorHide .tv.bg.w 0
										tv_playerCursorPlaybar %Y}
				bind $tv_bg <Motion> {tv_playerCursorHide .tv.bg 0
									  tv_playerCursorPlaybar %Y}
			}
			if {$::option(tooltips_player) == 1} {
				settooltip $tv_bar.b_play [mc "Start playback."]
				settooltip $tv_bar.b_pause [mc "Pause playback."]
				settooltip $tv_bar.b_stop [mc "Stop playback."]
				settooltip $tv_bar.b_rewind_start [mc "Jump to the beginning."]
				settooltip $tv_bar.b_rewind_small [mc "Seek back."]
				settooltip $tv_bar.b_rew_choose [mc "Choose amount of seek back."]
				settooltip $tv_bar.b_forward_small [mc "Seek forward."]
				settooltip $tv_bar.b_forw_choose [mc "Choose amount of seek forward."]
				settooltip $tv_bar.b_forward_end [mc "Jump to the end."]
				settooltip $tv_bar.b_fullscreen [mc "Toggle fullscreen."]
				settooltip $tv_bar.l_time [mc "Current position / File length"]
			} else {
				settooltip $tv_bar.b_play {}
				settooltip $tv_bar.b_pause {}
				settooltip $tv_bar.b_stop {}
				settooltip $tv_bar.b_rewind_start {}
				settooltip $tv_bar.b_rewind_small {}
				settooltip $tv_bar.b_rew_choose {}
				settooltip $tv_bar.b_forward_small {}
				settooltip $tv_bar.b_forw_choose {}
				settooltip $tv_bar.b_forward_end {}
				settooltip $tv_bar.b_fullscreen {}
				settooltip $tv_bar.l_time {}
			}
			if {"$handler" == "timeshift"} {
				bind .tv <<start>> {}
				after 1500 [list tv_playerPlaybackFile $tv_bg $tv_cont $handler "$file"]
				return
			}
		} else {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Starting file playback."
			flush $::logf_tv_open_append
			.tv.file_play_bar.b_play configure -command [list tv_playerSeek 0 0]
			bind .tv <<forward_end>> {tv_playerInitiateSeek "tv_playerSeek 0 2"}
			bind .tv <<forward_10s>> {tv_playerInitiateSeek "tv_playerSeek 10 1"}
			bind .tv <<forward_1m>> {tv_playerInitiateSeek "tv_playerSeek 60 1"}
			bind .tv <<forward_10m>> {tv_playerInitiateSeek "tv_playerSeek 600 1"}
			bind .tv <<rewind_10s>> {tv_playerInitiateSeek "tv_playerSeek 10 -1"}
			bind .tv <<rewind_1m>> {tv_playerInitiateSeek "tv_playerSeek 60 -1"}
			bind .tv <<rewind_10m>> {tv_playerInitiateSeek "tv_playerSeek 600 -1"}
			bind .tv <<rewind_start>> {tv_playerInitiateSeek "tv_playerSeek 0 -2"}
			bind .tv <<start>> {}
			place forget .tv.l_image
			place $tv_cont -in .tv.bg -relx 0.5 -rely 0.5 -anchor center -relheight 1
			bind $tv_cont <Configure> {place %W -width [expr (%h * ($::option(resolx).0 / $::option(resoly).0))]}
			.tv.file_play_bar.b_pause state !disabled
			.tv.file_play_bar.b_play state disabled
			set ::data(key_first_press) 1
			if {$::tv(stayontop) == 2} {
				wm attributes .tv -topmost 1
			}
			set ::data(mplayer) [open "|$mcommand" r+]
			fconfigure $::data(mplayer) -blocking 0 -buffering line
			fileevent $::data(mplayer) readable [list tv_playerGetVidData]
		}
	} else {
		puts $::logf_mpl_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Could not locate file for file playback.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] $file"
		flush $::logf_tv_open_append
	}
}

proc tv_switch_seek {w direct handler seek_var} {
	array set seek_com {
		-10s {event generate .tv <<rewind_10s>>}
		-1m {event generate .tv <<rewind_1m>>}
		-10m {event generate .tv <<rewind_10m>>}
		+10s {event generate .tv <<forward_10s>>}
		+1m {event generate .tv <<forward_1m>>}
		+10m {event generate .tv <<forward_10m>>}
	}
	set seek_var_rew {::tv(check_rew_10s) ::tv(check_rew_1m) ::tv(check_rew_10m)}
	set seek_var_for {::tv(check_fow_10s) ::tv(check_fow_1m) ::tv(check_fow_10m)}
	if {$direct == -1} {
		$w.b_rewind_small configure -command "$seek_com($handler)"
		foreach var $seek_var_rew {
			set $var 0
		}
		set ::$seek_var 1
	} else {
		$w.b_forward_small configure -command "$seek_com($handler)"
		foreach var $seek_var_for {
			set $var 0
		}
		set ::$seek_var 1
	}
}

proc tv_playerComputeFileSize {seconds} {
	if {"$seconds" == "cancel"} {
		catch {after cancel $::data(file_sizeid)}
		unset -nocomplain ::data(file_size)
		return
	}
	if {"$seconds" == "cancel_rec"} {
		catch {after cancel $::data(file_sizeid)}
		#~ unset -nocomplain ::data(file_size)
		return
	}
	set ::data(file_size) [expr [clock seconds] - $seconds]
	set ::data(file_sizeid) [after 10 [list tv_playerComputeFileSize $seconds]]
}

proc tv_playerComputeFilePos {stop} {
	if {"$stop" == "cancel"} {
		catch {after cancel $::data(file_posid)}
		#~ unset 
		return
	}
	if {[winfo exists .tv.file_play_bar.b_pause]} {
		if {[.tv.file_play_bar.b_pause instate disabled] == 0} {
			set ::data(file_pos) [expr [clock seconds] - $::data(file_pos_calc)]
			set lhours [expr ($::data(file_pos)%86400)/3600]
			if {[string length $lhours] < 2} {
				set lhours "0$lhours"
			}
			set lmins [expr ($::data(file_pos)%3600)/60]
			if {[string length $lmins] < 2} {
				set lmins "0$lmins"
			}
			set lsecs [expr $::data(file_pos)%60]
			if {[string length $lsecs] < 2} {
				set lsecs "0$lsecs"
			}
			if {[info exists ::data(file_size)]} {
				set shours [expr ($::data(file_size)%86400)/3600]
				if {[string length $shours] < 2} {
					set shours "0$shours"
				}
				set smins [expr ($::data(file_size)%3600)/60]
				if {[string length $smins] < 2} {
					set smins "0$smins"
				}
				set ssecs [expr $::data(file_size)%60]
				if {[string length $ssecs] < 2} {
					set ssecs "0$ssecs"
				}
				set ::choice(label_file_time) "$lhours:$lmins:$lsecs / $shours:$smins:$ssecs"
			}  else {
				set ::choice(label_file_time) "$lhours:$lmins:$lsecs / 00:00:00"
			}
			set ::data(file_posid) [after 10 [list tv_playerComputeFilePos 0]]
		} else {
			set lhours [expr ($::data(file_pos)%86400)/3600]
			if {[string length $lhours] < 2} {
				set lhours "0$lhours"
			}
			set lmins [expr ($::data(file_pos)%3600)/60]
			if {[string length $lmins] < 2} {
				set lmins "0$lmins"
			}
			set lsecs [expr $::data(file_pos)%60]
			if {[string length $lsecs] < 2} {
				set lsecs "0$lsecs"
			}
			if {[info exists ::data(file_size)]} {
				set shours [expr ($::data(file_size)%86400)/3600]
				if {[string length $shours] < 2} {
					set shours "0$shours"
				}
				set smins [expr ($::data(file_size)%3600)/60]
				if {[string length $smins] < 2} {
					set smins "0$smins"
				}
				set ssecs [expr $::data(file_size)%60]
				if {[string length $ssecs] < 2} {
					set ssecs "0$ssecs"
				}
				set ::choice(label_file_time) "$lhours:$lmins:$lsecs / $shours:$smins:$ssecs"
			} else {
				set ::choice(label_file_time) "$lhours:$lmins:$lsecs / 00:00:00"
			}
			set ::data(file_posid) [after 10 [list tv_playerComputeFilePos 0]]
		}
	}
}

proc tv_syncing_file_pos {stop} {
	catch {after cancel $::data(sync_remoteid)}
	catch {after cancel $::data(sync_id)}
	set ::data(sync_remoteid) [after 500 {tv_playerMplayerRemote get_time_pos}]
	set ::data(sync_id) [after 1000 {
		if {[string match -nocase "ANS_TIME_POSITION*" $::data(report)]} {
			set pos [lindex [split $::data(report) \=] end]
			set ::data(file_pos_calc) [expr [clock seconds] - [expr int($pos)]]
		}
	}]
}

proc tv_playerInitiateSeek {seek_com} {
	bind .tv <<forward_10s>> {}
	bind .tv <<forward_1m>> {}
	bind .tv <<forward_10m>> {}
	bind .tv <<rewind_10s>> {}
	bind .tv <<rewind_1m>> {}
	bind .tv <<rewind_10m>> {}
	bind .tv <<forward_end>> {}
	bind .tv <<rewind_start>> {}
	set ::tv(seek_secs) [lindex $seek_com 1]
	set ::tv(seek_dir) [lindex $seek_com 2]
	set ::tv(getvid_seek) 1
	tv_playerMplayerRemote get_time_pos
}

proc tv_playerSeek {secs direct} {
	if {$direct == 1} {
		if {[expr ($::data(file_pos) + $secs)] < [expr ($::data(file_size) - 20)]} {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Seeking +$secs\s"
			flush $::logf_tv_open_append
			set seekpos [expr ($::data(file_pos) + $secs)]
			if {$seekpos < $::data(file_size)} {
				tv_playerMplayerRemote "seek $seekpos 2"
				after 650 {
					set ::tv(getvid_seek) 0
					tv_playerMplayerRemote get_time_pos
				}
			}
			return
		} else {
			set seekpos [expr ($::data(file_size) - 10)]
			tv_playerMplayerRemote "seek $seekpos 2"
			after 650 {
				set ::tv(getvid_seek) 0
				tv_playerMplayerRemote get_time_pos
			}
			return
		}
	}
	if {$direct == 2} {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Seeking to the end of actual recording."
		flush $::logf_tv_open_append
		set seekpos [expr ($::data(file_size) - 10)]
		tv_playerMplayerRemote "seek $seekpos 2"
		after 650 {
			set ::tv(getvid_seek) 0
			tv_playerMplayerRemote get_time_pos
		}
		return
	}
	if {$direct == -1} {
		if {[expr ($::data(file_pos) - $secs)] < 0} {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Seeking -$secs\s"
			flush $::logf_tv_open_append
			set seekpos 0
			tv_playerMplayerRemote "seek $seekpos 2"
			after 650 {
				set ::tv(getvid_seek) 0
				tv_playerMplayerRemote get_time_pos
			}
			return
		} else {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Seeking -$secs\s"
			flush $::logf_tv_open_append
			set seekpos [expr ($::data(file_pos) - $secs)]
			tv_playerMplayerRemote "seek $seekpos 2"
			after 650 {
				set ::tv(getvid_seek) 0
				tv_playerMplayerRemote get_time_pos
			}
			return
		}
	}
	if {$direct == -2} {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Seeking to the beginning of actual recording."
		flush $::logf_tv_open_append
		set seekpos 0
		tv_playerMplayerRemote "seek $seekpos 2"
		after 650 {
			set ::tv(getvid_seek) 0
			tv_playerMplayerRemote get_time_pos
		}
		return
	}
	if {$direct == 0} {
		if {[.tv.file_play_bar.b_pause instate disabled] == 0} {
			.tv.file_play_bar.b_pause state disabled
			.tv.file_play_bar.b_play state !disabled
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Pause playback."
			flush $::logf_tv_open_append
			bind .tv <<forward_10s>> {}
			bind .tv <<forward_1m>> {}
			bind .tv <<forward_10m>> {}
			bind .tv <<rewind_10s>> {}
			bind .tv <<rewind_1m>> {}
			bind .tv <<rewind_10m>> {}
			bind .tv <<forward_end>> {}
			bind .tv <<rewind_start>> {}
			tv_playerMplayerRemote pause
			return
		} else {
			.tv.file_play_bar.b_play state disabled
			.tv.file_play_bar.b_pause state !disabled
			set ::data(file_pos_calc) [expr [clock seconds] - $::data(file_pos)]
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Start playback."
			flush $::logf_tv_open_append
			bind .tv <<forward_end>> {tv_playerInitiateSeek "tv_playerSeek 0 2"}
			bind .tv <<forward_10s>> {tv_playerInitiateSeek "tv_playerSeek 10 1"}
			bind .tv <<forward_1m>> {tv_playerInitiateSeek "tv_playerSeek 60 1"}
			bind .tv <<forward_10m>> {tv_playerInitiateSeek "tv_playerSeek 600 1"}
			bind .tv <<rewind_10s>> {tv_playerInitiateSeek "tv_playerSeek 10 -1"}
			bind .tv <<rewind_1m>> {tv_playerInitiateSeek "tv_playerSeek 60 -1"}
			bind .tv <<rewind_10m>> {tv_playerInitiateSeek "tv_playerSeek 600 -1"}
			bind .tv <<rewind_start>> {tv_playerInitiateSeek "tv_playerSeekk 0 -2"}
			tv_playerMplayerRemote pause
			return
		}
	}
}

proc tv_autorepeat_press {keycode serial seek_com} {
	if {$::data(key_first_press) == 1} {
		set ::data(key_first_press) 0
		if {"[lindex $seek_com 0]" == "tv_seek"} {
			set ::tv(seek_secs) [lindex $seek_com 1]
			set ::tv(seek_dir) [lindex $seek_com 2]
			set ::tv(getvid_seek) 1
			tv_playerMplayerRemote get_time_pos
		}
	}
	set ::data(key_serial) $serial
}

proc tv_autorepeat_release {keycode serial} {
	global delay
	after 10 "if {$serial != \$::data(key_serial)} {
	set ::data(key_first_press) 1
	}"
}

proc tv_playerHeartbeatCmd {com} {
	if {"$com" == "cancel"} {
		catch {after cancel $::data(heartbeat_id)}
		unset -nocomplain ::data(heartbeat_id)
		return
	}
	catch {exec sh -c "gnome-screensaver-command -p 2>/dev/null" &}
	catch {exec sh -c "xscreensaver-command -deactivate 2>/dev/null" &}
	tk inactive reset
	set ::data(heartbeat_id) [after 30000 tv_playerHeartbeatCmd 0]
}

proc tv_stop_playback {} {
	if {[info exists ::data(mplayer)] == 0} {return 1}
	if {[string trim $::data(mplayer)] != {}} {
		catch {puts -nonewline $::data(mplayer) "quit 0 \n"}
		flush $::data(mplayer)
	} else {
		return 1
	}
	if {[info exists ::option(cursor_id\(.tv.bg\))] == 1} {
		foreach id [split $::option(cursor_id\(.tv.bg\))] {
			after cancel $id
		}
		unset -nocomplain ::option(cursor_id\(.tv.bg\))
	}
	if {[info exists ::option(cursor_id\(.tv.bg.w\))] == 1} {
		foreach id [split $::option(cursor_id\(.tv.bg.w\))] {
			after cancel $id
		}
		unset -nocomplain ::option(cursor_id\(.tv.bg.w\))
	}
	place forget .tv.bg.w
	place .tv.l_image -relx 0.5 -rely 0.5 -anchor center
	bind .tv.bg.w <Configure> {}
	if {[winfo exists .station]} {
		.station.top_buttons.b_station_preview state !pressed
	} else {
		.top_buttons.button_starttv state !pressed
	}
	tv_playerHeartbeatCmd cancel
	if {[winfo exists .tray]} {
		settooltip .tray [mc "TV-Viewer idle"]
	}
	puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Stopping TV playback."
	flush $::logf_tv_open_append
}

proc tv_stop_playback_file {com} {
	if {$com == 0} {
		if {[info exists ::data(mplayer)] == 0} {return 1}
		if {[string trim $::data(mplayer)] != {}} {
			catch {puts -nonewline $::data(mplayer) "quit 0 \n"}
			flush $::data(mplayer)
		} else {
			return 1
		}
		if {[info exists ::option(cursor_id\(.tv.bg\))] == 1} {
			foreach id [split $::option(cursor_id\(.tv.bg\))] {
				after cancel $id
			}
			unset -nocomplain ::option(cursor_id\(.tv.bg\))
		}
		if {[info exists ::option(cursor_id\(.tv.bg.w\))] == 1} {
			foreach id [split $::option(cursor_id\(.tv.bg.w\))] {
				after cancel $id
			}
			unset -nocomplain ::option(cursor_id\(.tv.bg.w\))
		}
		place forget .tv.bg.w
		place .tv.l_image -relx 0.5 -rely 0.5 -anchor center
		bind .tv.bg.w <Configure> {}
		catch {
		tv_playerComputeFilePos cancel 
		tv_playerComputeFileSize cancel
		}
		tv_playerHeartbeatCmd cancel
		if {[winfo exists .tv.file_play_bar]} {
			destroy .tv.file_play_bar
		}
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Stopping file playback."
		flush $::logf_tv_open_append
	} else {
		if {[info exists ::data(mplayer)] == 0} {return 1}
		if {[string trim $::data(mplayer)] != {}} {
			catch {puts -nonewline $::data(mplayer) "quit 0 \n"}
			flush $::data(mplayer)
		} else {
			return 1
		}
		if {[info exists ::option(cursor_id\(.tv.bg\))] == 1} {
			foreach id [split $::option(cursor_id\(.tv.bg\))] {
				after cancel $id
			}
			unset -nocomplain ::option(cursor_id\(.tv.bg\))
		}
		if {[info exists ::option(cursor_id\(.tv.bg.w\))] == 1} {
			foreach id [split $::option(cursor_id\(.tv.bg.w\))] {
				after cancel $id
			}
			unset -nocomplain ::option(cursor_id\(.tv.bg.w\))
		}
		place forget .tv.bg.w
		place .tv.l_image -relx 0.5 -rely 0.5 -anchor center
		bind .tv.bg.w <Configure> {}
		tv_playerComputeFilePos cancel
		tv_playerHeartbeatCmd cancel
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Stopping file playback."
		flush $::logf_tv_open_append
		.tv.file_play_bar.b_play state !disabled
		.tv.file_play_bar.b_pause state disabled
		.tv.file_play_bar.b_play configure -command {tv_playerPlaybackFile .tv.bg .tv.bg.w 0 "$::tv(current_rec_file)"}
		bind .tv <<start>> {tv_playerPlaybackFile .tv.bg .tv.bg.w 0 "$::tv(current_rec_file)"}
	}
}

proc tv_playerUi {} {
	if {[winfo exists .tv] == 0} {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting up TV Player."
		flush $::logf_tv_open_append
		set mw [toplevel .tv -class "TV-Viewer"]
		.tv configure -background black
		set tv_bg [frame $mw.bg -background black -width $::option(resolx) -height $::option(resoly)]
		set tv_cont [frame $tv_bg.w -background "" -container yes]
		set tv_slist [frame .tv.slist -bg #004AFF -padx 5 -pady 5]
		set tv_slist_lirc [frame .tv.slist_lirc -bg #004AFF -padx 5 -pady 5]
		ttk::label $mw.l_image \
		-image $::icon_e(logo-tv-viewer08x-noload)
		
		listbox $tv_slist.lb_station \
		-yscrollcommand [list $tv_slist.sb_station set] \
		-exportselection false \
		-takefocus 0
		ttk::scrollbar $tv_slist.sb_station \
		-orient vertical \
		-command [list $tv_slist.lb_station yview]
		listbox $tv_slist_lirc.lb_station \
		-exportselection false \
		-takefocus 0 \
		-font "{$::option(osd_font)} 30"
		
		$mw.l_image configure -background #414141
		
		grid $tv_bg -in $mw -row 0 -column 0 \
		-sticky nesw
		
		grid $tv_slist.lb_station -in $tv_slist -row 0 -column 0 \
		-sticky nesw
		grid $tv_slist.sb_station -in $tv_slist -row 0 -column 1 \
		-sticky ns
		grid $tv_slist_lirc.lb_station -in $tv_slist_lirc -row 0 -column 0 \
		-sticky nesw
		grid rowconfigure $tv_slist 0 -weight 1
		grid columnconfigure $tv_slist 0 -weight 1
		grid rowconfigure $tv_slist_lirc 0 -weight 1
		grid columnconfigure $tv_slist_lirc 0 -weight 1
		
		autoscroll $tv_slist.sb_station
		
		grid rowconfigure $mw 0 -weight 1
		grid columnconfigure $mw 0 -weight 1
		place $mw.l_image -relx 0.5 -rely 0.5 -anchor center
		
		menu $mw.rightclickViewer \
		-tearoff 0 \
		-background $::option(theme_$::option(use_theme))
		menu $mw.rightclickViewer.panscan \
		-tearoff 0 \
		-background $::option(theme_$::option(use_theme))
		menu $mw.rightclickViewer.size \
		-tearoff 0 \
		-background $::option(theme_$::option(use_theme))
		menu $mw.rightclickViewer.ontop \
		-tearoff 0 \
		-background $::option(theme_$::option(use_theme))
		
		$mw.rightclickViewer add cascade \
		-label [mc "Pan&Scan"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-menu $mw.rightclickViewer.panscan
			$mw.rightclickViewer.panscan add command \
			-label [mc "Zoom +"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_playerPanscan $tv_cont 1] \
			-accelerator "E"
			$mw.rightclickViewer.panscan add command \
			-label [mc "Zoom -"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_playerPanscan $tv_cont -1] \
			-accelerator "W"
			$mw.rightclickViewer.panscan add command \
			-label [mc "Pan&Scan (16:9 / 4:3)"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command {tv_playerPanscanAuto} \
			-accelerator "Shift+W"
			$mw.rightclickViewer.panscan add separator
			$mw.rightclickViewer.panscan add command \
			-label [mc "Move up"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_playerMoveVideo 3] \
			-accelerator "Alt+Up"
			$mw.rightclickViewer.panscan add command \
			-label [mc "Move down"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_playerMoveVideo 1] \
			-accelerator "Alt+Down"
			$mw.rightclickViewer.panscan add command \
			-label [mc "Move left"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_playerMoveVideo 2] \
			-accelerator "Alt+Left"
			$mw.rightclickViewer.panscan add command \
			-label [mc "Move right"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_playerMoveVideo 0] \
			-accelerator "Alt+Right"
		$mw.rightclickViewer add cascade \
		-label [mc "Size"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-menu $mw.rightclickViewer.size
			$mw.rightclickViewer.size add command \
			-label "50%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_playerGivenSize .tv.bg 0.5]
			$mw.rightclickViewer.size add command \
			-label "75%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_playerGivenSize .tv.bg 0.75]
			$mw.rightclickViewer.size add command \
			-label "100%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_playerGivenSize .tv.bg 1.0] \
			-accelerator [mc "Ctrl+1"]
			$mw.rightclickViewer.size add command \
			-label "125%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_playerGivenSize .tv.bg 1.25]
			$mw.rightclickViewer.size add command \
			-label "150%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_playerGivenSize .tv.bg 1.5]
			$mw.rightclickViewer.size add command \
			-label "175%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_playerGivenSize .tv.bg 1.75]
			$mw.rightclickViewer.size add command \
			-label "200%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_playerGivenSize .tv.bg 2.0] \
			-accelerator [mc "Ctrl+2"]
		$mw.rightclickViewer add cascade \
		-label [mc "Stay on top"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-menu $mw.rightclickViewer.ontop
			$mw.rightclickViewer.ontop add radiobutton \
			-label [mc "Never"] \
			-variable tv(stayontop) \
			-value 0 \
			-command [list tv_playerStayonTop 0]
			$mw.rightclickViewer.ontop add radiobutton \
			-label [mc "Always"] \
			-variable tv(stayontop) \
			-value 1 \
			-command [list tv_playerStayonTop 1]
			$mw.rightclickViewer.ontop add radiobutton \
			-label [mc "While playback"] \
			-variable tv(stayontop) \
			-value 2 \
			-command [list tv_playerStayonTop 2]
		$mw.rightclickViewer add command \
		-label [mc "TV playback"] \
		-compound left \
		-image $::icon_s(starttv) \
		-command {event generate . <<teleview>>} \
		-accelerator "S"
		$mw.rightclickViewer add command \
		-label [mc "Exit"] \
		-compound left \
		-image $::icon_s(dialog-close) \
		-command main_frontendExitViewer \
		-accelerator [mc "Ctrl+X"]
		
		set ::tv(stayontop) 0
		set ::option(cursor_old) [$tv_cont cget -cursor]
		set ::data(panscan) 0
		set ::data(panscanAuto) 0
		set ::data(movevidX) 0
		set ::data(movevidY) 0
		
		bind $mw <Key-f> [list tv_playerFullscreen $mw $tv_cont $tv_bg]
		bind $tv_cont <Double-ButtonPress-1> [list tv_playerFullscreen $mw $tv_cont $tv_bg]
		bind $tv_bg <Double-ButtonPress-1> [list tv_playerFullscreen $mw $tv_cont $tv_bg]
		bind $mw <<teleview>> {tv_playerUi}
		bind $mw <<station_down>> [list main_stationChannelDown .label_stations]
		bind $mw <<station_up>> [list main_stationChannelUp .label_stations]
		bind $mw <<station_jump>> [list main_stationChannelJumper .label_stations]
		bind $mw <<station_key>> [list main_stationStationNrKeys %A]
		bind $mw <<record>> [list record_wizardUi]
		bind $mw <<timeshift>> [list timeshift .top_buttons.button_timeshift]
		bind $mw <<input_up>> [list main_stationInput 1 1]
		bind $mw <<input_down>> [list main_stationInput 1 -1]
		bind $mw <<volume_decr>> {tv_volume_control .bottom_buttons [expr $::volume_scale - 3]}
		bind $mw <<volume_incr>> {tv_volume_control .bottom_buttons [expr $::volume_scale + 3]}
		bind $mw <Key-m> [list tv_volume_control .bottom_buttons mute]
		bind $mw <Control-Key-1> [list tv_playerGivenSize $tv_bg 1]
		bind $mw <Control-Key-2> [list tv_playerGivenSize $tv_bg 2]
		bind $mw <Key-e> [list tv_playerPanscan $tv_cont 1]
		bind $mw <Key-w> [list tv_playerPanscan $tv_cont -1]
		bind $mw <Shift-Key-W> {tv_playerPanscanAuto}
		bind $mw <Alt-Key-Right> [list tv_playerMoveVideo 0]
		bind $mw <Alt-Key-Down> [list tv_playerMoveVideo 1]
		bind $mw <Alt-Key-Left> [list tv_playerMoveVideo 2]
		bind $mw <Alt-Key-Up> [list tv_playerMoveVideo 3]
		bind $mw <Mod4-Key-s> [list tv_playerMplayerRemote "screenshot 0"]
		bind $mw <Mod4-Key-s> [list tv_playerMplayerRemote "screenshot 0"]
		bind $mw <Control-Key-p> {tv_stop_playback ; config_wizardMainUi}
		bind $mw <Control-Key-m> {main_ui_colorm}
		bind $mw <Control-Key-e> {main_ui_seditor}
		bind $mw <Key-F1> [list info_helpHelp]
		bind $mw <Control-Key-x> {main_frontendExitViewer}
		bind $mw <ButtonPress-3> [list tk_popup $mw.rightclickViewer %X %Y]
		bind $mw <y> {font_chooserUi}
		
		if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
			puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] No valid stations list, will not activate station selector for video window."
			flush $::logf_tv_open_append
			destroy $tv_slist
			destroy $tv_slist_lirc
		} else {
			for {set i 1} {$i <= $::station(max)} {incr i} {
				if {$i < 10} {
					$tv_slist.lb_station insert end " $i     $::kanalid($i)"
					
				} else {
					if {$i < 100} {
						$tv_slist.lb_station insert end " $i   $::kanalid($i)"
						
					} else {
						$tv_slist.lb_station insert end " $i $::kanalid($i)"
						
					}
				}
				$tv_slist_lirc.lb_station insert end "$::kanalid($i)"
			}
			bind $tv_slist.lb_station <<ListboxSelect>> [list main_stationListboxStations $tv_slist.lb_station]
			bindtags .tv.slist_lirc.lb_station {.tv.slist_lirc.lb_station .tv all}
		}
		
		wm protocol $mw WM_DELETE_WINDOW main_frontendExitViewer
		wm iconphoto $mw $::icon_b(starttv)
		if {[info exists ::station(last)]} {
			wm title $mw "TV - [lindex $::station(last) 0]"
		} else {
			wm title $mw "TV - ..."
		}
		if {$::option(vidwindow_attach) == 1} {
			wm transient $mw .
		}
		tkwait visibility $mw
		if {$::option(vidwindow_full) == 1} {
			tv_playerFullscreen $mw $tv_cont $tv_bg
		}
	} else {
		set status [tv_playerMplayerRemote alive]
		if {$status != 1} {
			if {[winfo exists .tv.file_play_bar] == 1} {
				tv_stop_playback_file 0
				tv_playerComputeFilePos cancel
				tv_playerComputeFileSize cancel
				destroy .tv.file_play_bar
				bind .tv <<pause>> {}
				bind .tv <<start>> {}
				bind .tv <<stop>> {}
				bind .tv <<forward_10s>> {}
				bind .tv <<forward_1m>> {}
				bind .tv <<forward_10m>> {}
				bind .tv <<rewind_10s>> {}
				bind .tv <<rewind_1m>> {}
				bind .tv <<rewind_10m>> {}
				bind .tv <<forward_end>> {}
				bind .tv <<rewind_start>> {}
				if {$::main(running_recording) == 1} {
					if {$::option(forcevideo_standard) == 1} {
						main_pic_streamForceVideoStandard
					}
					main_pic_streamDimensions
					if {$::option(streambitrate) == 1} {
						main_pic_streamVbitrate
					}
					if {$::option(temporal_filter) == 1} {
						main_pic_streamPicqualTemporal
					}
					main_pic_streamColormControls
					catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=mute=0}
					if {$::option(audio_v4l2) == 1} {
						main_pic_streamAudioV4l2
					}
					set ::main(running_recording) 0
				}
				wm title .tv "TV - [lindex $::station(last) 0]"
				wm iconphoto .tv $::icon_b(starttv)
				set status [tv_playerMplayerRemote alive]
				if {$status != 1} {
					after 100 {tv_playerPlaybackLoop}
				} else {
					if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"]} {
						catch {file delete -force "[subst $::option(timeshift_path)/timeshift.mpeg]"}
					}
					tv_playback .tv.bg .tv.bg.w
				}
				proc tv_playerPlaybackLoop {} {
					set status [tv_playerMplayerRemote alive]
					if {$status != 1} {
						after 100 {tv_playerPlaybackLoop}
					} else {
						if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"]} {
							catch {file delete -force "[subst $::option(timeshift_path)/timeshift.mpeg]"}
						}
						tv_playerPlayback .tv.bg .tv.bg.w
					}
				}
			} else {
				tv_stop_playback
			}
		} else {
			if {[winfo exists .tv.file_play_bar] == 1} {
				tv_playerComputeFilePos cancel
				tv_playerComputeFileSize cancel
				destroy .tv.file_play_bar
				bind .tv <<pause>> {}
				bind .tv <<start>> {}
				bind .tv <<stop>> {}
				bind .tv <<forward_10s>> {}
				bind .tv <<forward_1m>> {}
				bind .tv <<forward_10m>> {}
				bind .tv <<rewind_10s>> {}
				bind .tv <<rewind_1m>> {}
				bind .tv <<rewind_10m>> {}
				bind .tv <<forward_end>> {}
				bind .tv <<rewind_start>> {}
				if {$::main(running_recording) == 1} {
					if {$::option(forcevideo_standard) == 1} {
						main_pic_streamForceVideoStandard
					}
					main_pic_streamDimensions
					if {$::option(streambitrate) == 1} {
						main_pic_streamVbitrate
					}
					if {$::option(temporal_filter) == 1} {
						main_pic_streamPicqualTemporal
					}
					main_pic_streamColormControls
					catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=mute=0}
					if {$::option(audio_v4l2) == 1} {
						main_pic_streamAudioV4l2
					}
					set ::main(running_recording) 0
				}
				if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"]} {
					catch {file delete -force "[subst $::option(timeshift_path)/timeshift.mpeg]"}
				}
				wm title .tv "TV - [lindex $::station(last) 0]"
				wm iconphoto .tv $::icon_b(starttv)
			}
			main_pic_streamDimensions
			tv_playerPlayback .tv.bg .tv.bg.w
		}
	}
}
