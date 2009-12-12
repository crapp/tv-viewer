#       tv_wm.tcl
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

proc tv_wmFullscreen {mw tv_cont tv_bg} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_wmFullscreen \033\[0m \{$mw\} \{$tv_cont\} \{$tv_bg\}"
	if {[wm attributes $mw -fullscreen] == 0} {
		if {[winfo exists .tv.file_play_bar] == 1} {
			if {[string trim [grid info .tv.file_play_bar]] != {}} {
				grid remove .tv.file_play_bar
				bind $tv_cont <Motion> {
					tv_wmCursorHide .tv.bg.w 0
					tv_wmCursorPlaybar %Y
					tv_slistCursor %X %Y
				}
				bind $tv_bg <Motion> {
					tv_wmCursorHide .tv.bg 0
					tv_wmCursorPlaybar %Y
					tv_slistCursor %X %Y
				}
				.tv.file_play_bar.b_fullscreen configure -image $::icon_m(nofullscreen)
			} else {
				bind $tv_cont <Motion> {
					tv_wmCursorHide .tv.bg.w 0
					tv_slistCursor %X %Y
				}
				bind $tv_bg <Motion> {
					tv_wmCursorHide .tv.bg 0
					tv_slistCursor %X %Y
				}
			}
			bind $mw <ButtonPress-1> {.tv.bg.w configure -cursor arrow
									  .tv.bg configure -cursor arrow}
			set ::cursor($tv_cont) ""
			set ::cursor($tv_bg) ""
			tv_wmCursorHide $tv_cont 0
			tv_wmCursorHide $tv_bg 0
			wm attributes $mw -fullscreen 1
			set ::tv(id_panscanAuto) [after 500 {
				if {$::data(panscanAuto) == 1} {
					catch {after cancel $::tv(id_panscanAuto)}
					set ::data(panscanAuto) 0
					tv_wmPanscanAuto
				}
			}]
			log_writeOutTv 0 "Going to full-screen mode."
			return
		} else {
			bind $tv_cont <Motion> {
				tv_wmCursorHide .tv.bg.w 0
				tv_slistCursor %X %Y
			}
			bind $tv_bg <Motion> {
				tv_wmCursorHide .tv.bg 0
				tv_slistCursor %X %Y
			}
			bind $mw <ButtonPress-1> {
				.tv.bg.w configure -cursor arrow
				.tv.bg configure -cursor arrow
			}
			set ::cursor($tv_cont) ""
			set ::cursor($tv_bg) ""
			tv_wmCursorHide $tv_cont 0
			tv_wmCursorHide $tv_bg 0
			log_writeOutTv 0 "Going to full-screen mode."
			wm attributes $mw -fullscreen 1
			set ::tv(id_panscanAuto) [after 500 {
				if {$::data(panscanAuto) == 1} {
					catch {after cancel $::tv(id_panscanAuto)}
					set ::data(panscanAuto) 0
					tv_wmPanscanAuto
				}
			}]
		}
		if {[winfo exists .tv.slist] && [string trim [place info .tv.slist]] != {}} {
			.tv.slist.lb_station selection clear 0 end
			place forget .tv.slist
			log_writeOutTv 0 "Removing station list from video window."
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
			log_writeOutTv 0 "Removing station list from video window."
		}
		if {[winfo exists .tv.slist_lirc] && [string trim [place info .tv.slist_lirc]] != {}} {
			log_writeOutTv 0 "Closing OSD station list for remote controls."
			.tv.slist_lirc.lb_station selection clear 0 end
			focus .tv
			place forget .tv.slist_lirc
		}
		bind $tv_cont <Motion> {tv_slistCursor %X %Y}
		bind $tv_bg <Motion> {tv_slistCursor %X %Y}
		bind $mw <ButtonPress-1> {}
		set ::cursor($tv_cont) ""
		set ::cursor($tv_bg) ""
		tv_wmCursorHide $tv_bg 1
		tv_wmCursorHide $tv_cont 1
		$tv_cont configure -cursor arrow
		$tv_bg configure -cursor arrow
		log_writeOutTv 0 "Going to windowed mode."
		wm attributes $mw -fullscreen 0
		set ::tv(id_panscanAuto) [after 500 {
			if {$::data(panscanAuto) == 1} {
				catch {after cancel $::tv(id_panscanAuto)}
				set ::data(panscanAuto) 0
				tv_wmPanscanAuto
			}
		}]
	}
}

proc tv_wmPanscan {w direct} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_wmPanscan \033\[0m \{$w\} \{$direct\}"
	set status_tvplayback [tv_callbackMplayerRemote alive]
	if {$status_tvplayback == 1} {return}
	if {$direct == 1} {
		if {$::data(panscan) == 100} return
		if {[string trim [place info $w]] == {}} return
		place $w -relheight [expr {[dict get [place info $w] -relheight] + 0.05}]
		log_writeOutTv 0 "Increasing zoom by 5%."
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
		if {[string trim [place info $w]] == {}} return
		place $w -relheight [expr {[dict get [place info $w] -relheight] - 0.05}]
		log_writeOutTv 0 "Decreasing zoom by 5%."
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
		if {[string trim [place info $w]] == {}} return
		#~ place $w -relheight 1 -relx 0.5 -rely 0.5
		place $w -relheight 1
		log_writeOutTv 0 "Setting zoom to 100%"
		set ::data(panscan) 0
		set ::data(panscanAuto) 0
		if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list tv_osd osd_group_w 1000 [mc "Pan&Scan 4:3"]]
		}
		if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list tv_osd osd_group_f 1000 [mc "Pan&Scan 4:3"]]
		}
	}
}

proc tv_wmPanscanAuto {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_wmPanscanAuto \033\[0m"
	set status_tvplayback [tv_callbackMplayerRemote alive]
	if {$status_tvplayback == 1} {return}
	if {$::option(player_aspect) == 0} {
		log_writeOutTv 1 "Video aspect not managed bei TV-Viewer, zoom disabled!"
		return
	}
	if {[winfo ismapped .tv.bg.w] == 0} {
		log_writeOutTv 1 "Video player container frame is not mapped."
		log_writeOutTv 1 "Auto Pan&Scan not possible."
		return
	}
	if {[wm attributes .tv -fullscreen] == 0} {
		if {$::data(panscanAuto) == 0} {
			set relativeX [dict get [place info .tv.bg.w] -relx]
			set relativeY [dict get [place info .tv.bg.w] -rely]
			place .tv.bg.w -relheight 1 -relx $relativeX -rely $relativeY
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
			log_writeOutTv 0 "Auto zoom 16:9, changing geometry of tv window and realtive height of container frame."
			if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
				after 0 [list tv_osd osd_group_w 1000 [mc "Pan&Scan 16:9"]]
			}
			set ::data(panscanAuto) 1
			place .tv.bg.w -relheight [expr [winfo reqwidth .tv.bg].0 / [winfo reqheight .tv.bg].0]
		} else {
			tv_wmPanscan .tv.bg.w 0
		}
	} else {
		if {$::data(panscanAuto) == 0} {
			if {[dict get [place info .tv.bg.w] -relheight] != 1} {
				set width_diff [expr [winfo width .tv.bg] - [winfo width .tv.bg.w]]
				set relheight [expr [dict get [place info .tv.bg.w] -relheight] + ($width_diff.0 / [winfo width .tv.bg.w].0)]
				if {$relheight == [dict get [place info .tv.bg.w] -relheight]} return
				set relativeX [dict get [place info .tv.bg.w] -relx]
				set relativeY [dict get [place info .tv.bg.w] -rely]
				place .tv.bg.w -relheight 1 -relx $relativeX -rely $relativeY
				catch {after cancel $::data(panscanAuto_id)}
				set ::data(panscanAuto_id) [after 1000 {
				set width_diff [expr [winfo width .tv.bg] - [winfo width .tv.bg.w]]
				set relheight [expr [dict get [place info .tv.bg.w] -relheight] + ($width_diff.0 / [winfo width .tv.bg.w].0)]
				set panscan_multi [expr int(ceil(0.[lindex [split $relheight .] end] / 0.05))]
				set ::data(panscan) [expr ($panscan_multi * 5)]
				log_writeOutTv 0 "Auto zoom 16:9, changing realtive height of container frame."
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
				log_writeOutTv 0 "Auto zoom 16:9, changing realtive height of container frame."
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
			tv_wmPanscan .tv.bg.w 0
		}
	}
}

proc tv_wmMoveVideo {dir} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_wmMoveVideo \033\[0m \{$dir\}"
	if {$::option(player_aspect) == 0} {
		log_writeOutTv 1 "Video aspect not managed bei TV-Viewer, moving video disabled!"
		return
	}
	if {$dir == 0} {
		if {$::data(movevidX) == 100} return
		place .tv.bg.w -relx [expr {[dict get [place info .tv.bg.w] -relx] + 0.005}]
		log_writeOutTv 0 "Moving video to the right by 0.5%."
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
		log_writeOutTv 0 "Moving video down by 0.5%."
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
		log_writeOutTv 0 "Moving video to the left by 0.5%."
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
		log_writeOutTv 0 "Moving video up by 0.5%."
		set ::data(movevidY) [expr $::data(movevidY) - 1]
		if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list tv_osd osd_group_w 1000 [mc "Move y=%" $::data(movevidY)]]
		}
		if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list tv_osd osd_group_f 1000 [mc "Move y=%" $::data(movevidY)]]
		}
		return
	}
	if {$dir == 4} {
		place .tv.bg.w -relheight 1 -relx 0.5 -rely 0.5
		set ::data(movevidX) 0
		set ::data(movevidY) 0
		log_writeOutTv 0 "Centering video."
		set ::data(movevidY) [expr $::data(movevidY) - 1]
		if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list tv_osd osd_group_w 1000 [mc "Centering video"]]
		}
		if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list tv_osd osd_group_f 1000 [mc "Centering video" ]]
		}
		return
	}
}

proc tv_wmStayonTop {com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_wmStayonTop \033\[0m \{$com\}"
	if {$com == 0} {
		wm attributes .tv -topmost 0
	}
	if {$com == 1} {
		wm attributes .tv -topmost 1
	}
	if {$com == 2} {
		set status [tv_callbackMplayerRemote alive]
		if {$status != 1} {
			wm attributes .tv -topmost 1
		}
	}
}

proc tv_wmGivenSize {w size} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_wmGivenSize \033\[0m \{$w\} \{$size\}"
	if {$size == 1} {
		wm geometry .tv {}
		$w configure -width $::option(resolx) -height $::option(resoly)
		place .tv.bg.w -width [expr ($::option(resoly) * ($::option(resolx).0 / $::option(resoly).0))]
		log_writeOutTv 0 "Setting TV window to standard size."
		return
	} else {
		wm geometry .tv {}
		$w configure -width [expr round($::option(resolx) * $size)] -height [expr round($::option(resoly) * $size)]
		place .tv.bg.w -width [expr ($::option(resoly) * ($::option(resolx).0 / $::option(resoly).0))]
		log_writeOutTv 0 "Setting size of TV window to [expr $size * 100]."
		return
	}
}

proc tv_wmCursorHide {w com} {
	if {[info exists ::option(cursor_id\($w\))] == 1} {
		foreach id [split $::option(cursor_id\($w\))] {
			#~ puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_wmCursorHide \033\[0;1;31m::cancel:: \033\[0m"
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

proc tv_wmCursorPlaybar {ypos} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_wmCursorPlaybar \033\[0m \{$ypos\}"
	if {[string trim [grid info .tv.file_play_bar]] == {}} {
		if {$ypos > [expr [winfo screenheight .] - 20]} {
			grid .tv.file_play_bar -in .tv -row 1 -column 0 -sticky ew
			log_writeOutTv 0 "Adding video player bar to grid window manager."
		}
		return
	}
	if {[string trim [grid info .tv.file_play_bar]] != {}} {
		if {$ypos < [expr [winfo screenheight .] - 60]} {
			grid remove .tv.file_play_bar
			log_writeOutTv 0 "Removing video player bar from grid window manager."
			.tv.bg configure -cursor arrow
			.tv.bg.w configure -cursor arrow
			tv_wmCursorHide .tv.bg 1
			tv_wmCursorHide .tv.bg.w 1
		}
		return
	}
}

proc tv_wmHeartbeatCmd {com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_wmHeartbeatCmd \033\[0m \{$com\}"
	if {"$com" == "cancel"} {
		catch {after cancel $::data(heartbeat_id)}
		unset -nocomplain ::data(heartbeat_id)
		catch {exec xdg-screensaver resume $::tv(screensaverId)}
		unset -nocomplain ::tv(screensaverId)
		return
	}
	#~ catch {exec sh -c "gnome-screensaver-command -p 2>/dev/null" &}
	#~ catch {exec sh -c "xscreensaver-command -deactivate 2>/dev/null" &}
	tk inactive reset
	set ::data(heartbeat_id) [after 50000 tv_wmHeartbeatCmd 0]
}

