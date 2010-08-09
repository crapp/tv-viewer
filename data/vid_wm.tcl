#       vid_wm.tcl
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

proc vid_wmFullscreen {mw vid_bg vid_cont} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmFullscreen \033\[0m \{$mw\} \{$vid_cont\} \{$vid_bg\}"
	if {[wm attributes $mw -fullscreen] == 0} {
		grid remove .foptions_bar
		grid remove .seperatMenu
		grid remove .ftoolb_Top
		grid remove .fstations
		grid remove .ftoolb_ChanCtrl
		grid remove .ftoolb_Play
		grid remove .ftoolb_Disp
		bind $vid_cont <Motion> {
			vid_wmCursorHide .fvidBg.cont 0
			vid_wmCursorPlaybar %Y
			#~ vid_slistCursor %X %Y
		}
		bind $vid_bg <Motion> {
			vid_wmCursorHide .fvidBg 0
			vid_wmCursorPlaybar %Y
			#~ vid_slistCursor %X %Y
		}
		bind $mw <ButtonPress-1> {.fvidBg.cont configure -cursor arrow
								  .fvidBg configure -cursor arrow}
		set ::cursor($vid_cont) ""
		set ::cursor($vid_bg) ""
		vid_wmCursorHide $vid_cont 0
		vid_wmCursorHide $vid_bg 0
		wm attributes $mw -fullscreen 1
		if {$::data(panscanAuto) == 1} {
			set ::vid(id_panscanAuto) [after 500 {
				catch {after cancel $::vid(id_panscanAuto)}
				set ::data(panscanAuto) 0
				vid_wmPanscanAuto
			}]
		}
		log_writeOutTv 0 "Going to full-screen mode."
		#~ if {[winfo exists .tv.slist] && [string trim [place info .tv.slist]] != {}} {
			#~ .tv.slist.lb_station selection clear 0 end
			#~ place forget .tv.slist
			#~ log_writeOutTv 0 "Removing station list from video window."
		#~ }
	} else {
		#~ if {[winfo exists .tv.slist] && [string trim [place info .tv.slist]] != {}} {
			#~ .tv.slist.lb_station selection clear 0 end
			#~ place forget .tv.slist
			#~ log_writeOutTv 0 "Removing station list from video window."
		#~ }
		#~ if {[winfo exists .tv.slist_lirc] && [string trim [place info .tv.slist_lirc]] != {}} {
			#~ log_writeOutTv 0 "Closing OSD station list for remote controls."
			#~ .tv.slist_lirc.lb_station selection clear 0 end
			#~ focus .tv
			#~ place forget .tv.slist_lirc
		#~ }
		bind $vid_cont <Motion> {
			vid_wmCursorHide .fvidBg.cont 0
			#~ vid_wmCursorPlaybar %Y
			#~ vid_slistCursor %X %Y
		}
		bind $vid_bg <Motion> {
			vid_wmCursorHide .fvidBg 0
			#~ vid_wmCursorPlaybar %Y
			#~ vid_slistCursor %X %Y
		}
		#~ bind $mw <ButtonPress-1> {}
		#~ set ::cursor($vid_cont) ""
		#~ set ::cursor($vid_bg) ""
		#~ vid_wmCursorHide $vid_bg 1
		#~ vid_wmCursorHide $vid_cont 1
		#~ $vid_cont configure -cursor arrow
		#~ $vid_bg configure -cursor arrow
		if {$::main(compactMode) == 0} {
			grid .foptions_bar -in . -row 0 -column 0 \
			-sticky new \
			-columnspan 2
			grid .seperatMenu -in . -row 1 -column 0 \
			-sticky ew \
			-padx 2 \
			-columnspan 2
			grid .ftoolb_Top -in . -row 2 -column 0 \
			-columnspan 2 \
			-sticky ew
			grid .fstations -in . -row 3 -column 0 \
			-sticky nesw \
			-padx "0 2"
			grid .fvidBg -in . -row 3 -column 1 \
			-sticky nesw
			grid .ftoolb_ChanCtrl -in . -row 4 -column 0 \
			-sticky ew
			grid .ftoolb_Play -in . -row 4 -column 1 \
			-sticky ew
			grid .ftoolb_Disp -in . -row 5 -column 0 \
			-columnspan 2 \
			-sticky ew
		}
		log_writeOutTv 0 "Going to windowed mode."
		wm attributes $mw -fullscreen 0
		if {$::data(panscanAuto) == 1} {
			set ::vid(id_panscanAuto) [after 500 {
				catch {after cancel $::vid(id_panscanAuto)}
				set ::data(panscanAuto) 0
				vid_wmPanscanAuto
			}]
		}
	}
}

proc vid_wmCompact {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmCompact \033\[0m"
	if {$::main(compactMode)} {
		wm geometry . {}
		set width [winfo width .fvidBg]
		set height [winfo height .fvidBg]
		grid .foptions_bar -in . -row 0 -column 0 \
		-sticky new \
		-columnspan 2
		grid .seperatMenu -in . -row 1 -column 0 \
		-sticky ew \
		-padx 2 \
		-columnspan 2
		grid .ftoolb_Top -in . -row 2 -column 0 \
		-columnspan 2 \
		-sticky ew 
		grid .fstations -in . -row 3 -column 0 \
		-sticky nesw \
		-padx "0 2"
		grid .fvidBg -in . -row 3 -column 1 \
		-sticky nesw
		grid .ftoolb_ChanCtrl -in . -row 4 -column 0 \
		-sticky ew
		grid .ftoolb_Play -in . -row 4 -column 1 \
		-sticky ew
		grid .ftoolb_Disp -in . -row 5 -column 0 \
		-columnspan 2 \
		-sticky ew
		
		if {$width != 250} {
			set widthc [expr [winfo width .fstations] + $width + 2]
		} else {
			set widthc 250
		}
		set heightc [expr [winfo height .foptions_bar] + [winfo height .seperatMenu] + [winfo height .ftoolb_Top] + [winfo height .ftoolb_Play] + [winfo height .ftoolb_Disp] + $height]
		set heightmin [expr [winfo height .foptions_bar] + [winfo height .seperatMenu] + [winfo height .ftoolb_Top] + [winfo height .ftoolb_Play] + [winfo height .ftoolb_Disp] + 141]
		wm minsize . 250 $heightmin
		if {$widthc < 250 || $heightc < $heightmin} {
			wm geometry . 250x$heightc
		} else {
			wm geometry . $widthc\x$heightc
		}
		set ::main(compactMode) 0
	} else {
		wm geometry . {}
		set width [winfo width .fvidBg]
		set height [winfo height .fvidBg]
		grid remove .foptions_bar
		grid remove .seperatMenu
		grid remove .ftoolb_Top
		grid remove .fstations
		grid remove .ftoolb_ChanCtrl
		grid remove .ftoolb_Play
		grid remove .ftoolb_Disp
		
		wm minsize . 250 141
		if {$width < 250 || $height < 141} {
			wm geometry . 250x141
		} else {
			wm geometry . $width\x$height
		}
		set ::main(compactMode) 1
	}
}

proc vid_wmPanscan {w direct} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmPanscan \033\[0m \{$w\} \{$direct\}"
	set status_tvplayback [vid_callbackMplayerRemote alive]
	if {$status_tvplayback == 1} {return}
	if {$direct == 1} {
		if {$::data(panscan) == 100} return
		if {[string trim [place info $w]] == {}} return
		place $w -relheight [expr {[dict get [place info $w] -relheight] + 0.05}]
		log_writeOutTv 0 "Increasing zoom by 5%."
		set ::data(panscan) [expr $::data(panscan) + 5]
		set ::data(panscanAuto) 0
		if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list vid_osd osd_group_w 1000 "Zoom $::data(panscan)"]
		}
		if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list vid_osd osd_group_f 1000 "Zoom $::data(panscan)"]
		}
	}
	if {$direct == -1} {
		if {$::data(panscan) == -50} return
		if {[string trim [place info $w]] == {}} return
		place $w -relheight [expr {[dict get [place info $w] -relheight] - 0.05}]
		log_writeOutTv 0 "Decreasing zoom by 5%."
		set ::data(panscan) [expr $::data(panscan) - 5]
		set ::data(panscanAuto) 0
		if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list vid_osd osd_group_w 1000 "Zoom $::data(panscan)"]
		}
		if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list vid_osd osd_group_f 1000 "Zoom $::data(panscan)"]
		}
	}
	if {$direct == 0} {
		if {[string trim [place info $w]] == {}} return
		place $w -relheight 1
		log_writeOutTv 0 "Setting zoom to 100%"
		set ::data(panscan) 0
		set ::data(panscanAuto) 0
		if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [vid_osd osd_group_w 1000 "Pan&Scan 4:3"]
		}
		if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [vid_osd osd_group_f 1000 "Pan&Scan 4:3"]
		}
	}
}

proc vid_wmPanscanAuto {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmPanscanAuto \033\[0m"
	set status_tvplayback [vid_callbackMplayerRemote alive]
	if {$status_tvplayback == 1} {return}
	if {$::option(player_aspect) == 0} {
		log_writeOutTv 1 "Video aspect not managed bei TV-Viewer, zoom disabled!"
		return
	}
	if {[winfo ismapped .fvidBg.cont] == 0} {
		log_writeOutTv 1 "Video frame is not mapped."
		log_writeOutTv 1 "Auto Pan&Scan not possible."
		return
	}
	if {[wm attributes . -fullscreen] == 0} {
		if {$::data(panscanAuto) == 0} {
			set relativeX [dict get [place info .fvidBg.cont] -relx]
			set relativeY [dict get [place info .fvidBg.cont] -rely]
			set relheight [dict get [place info .fvidBg.cont] -relheight]
			place .fvidBg.cont -relheight 1 -relx $relativeX -rely $relativeY
			if {$::main(compactMode)} {
				set width [winfo width .]
				set height [expr int(ceil($width.0 / 1.777777778))]
				wm geometry . [winfo width .]x$height
			} else {
				set width [expr [winfo width .] - [winfo width .fstations]]
				set height [expr int(ceil($width.0 / 1.777777778))]
				set heightwp [expr $height + [winfo height .foptions_bar] + [winfo height .seperatMenu] + [winfo height .ftoolb_Top] + [winfo height .ftoolb_Play] + [winfo height .ftoolb_Disp]]
				wm geometry . [winfo width .]x$heightwp
			}
			set relheight [lindex [split [expr ([winfo reqwidth .fvidBg].0 / [winfo reqheight .fvidBg].0)] .] end]
			set relheight 3333333333333333
			set panscan_multi [expr int(ceil(0.$relheight / 0.05))]
			set ::data(panscan) [expr ($panscan_multi * 5)]
			log_writeOutTv 0 "Auto zoom 16:9, changing geometry of tv window and realtive height of container frame."
			if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
				after 0 [vid_osd osd_group_w 1000 "Pan&Scan 16:9"]
			}
			set ::data(panscanAuto) 1
			place .fvidBg.cont -relheight 1.3333333333333333
		} else {
			#FIXME needs more testing!! Deprecated??
			.fvidBg configure -height [expr int(ceil([winfo width .fvidBg].0 / 1.33333333333))]
			vid_wmPanscan .fvidBg.cont 0
		}
	} else {
		if {$::data(panscanAuto) == 0} {
			if {[dict get [place info .fvidBg.cont] -relheight] != 1} {
				set width_diff [expr [winfo width .fvidBg] - [winfo width .fvidBg.cont]]
				set relheight [expr [dict get [place info .fvidBg.cont] -relheight] + ($width_diff.0 / [winfo width .fvidBg.cont].0)]
				if {$relheight == [dict get [place info .fvidBg.cont] -relheight]} return
				set relativeX [dict get [place info .fvidBg.cont] -relx]
				set relativeY [dict get [place info .fvidBg.cont] -rely]
				place .fvidBg.cont -relheight 1 -relx $relativeX -rely $relativeY
				catch {after cancel $::data(panscanAuto_id)}
				set ::data(panscanAuto_id) [after 1000 {
				set width_diff [expr [winfo width .fvidBg] - [winfo width .fvidBg.cont]]
				set relheight [expr [dict get [place info .fvidBg.cont] -relheight] + ($width_diff.0 / [winfo width .fvidBg.cont].0)]
				set panscan_multi [expr int(ceil(0.[lindex [split $relheight .] end] / 0.05))]
				set ::data(panscan) [expr ($panscan_multi * 5)]
				log_writeOutTv 0 "Auto zoom 16:9, changing realtive height of container frame."
				if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
					after 0 [vid_osd osd_group_f 1000 "Pan&Scan 16:9"]
				}
				set ::data(panscanAuto) 1
				place .fvidBg.cont -relheight $relheight
				}]
			} else {
				set width_diff [expr [winfo width .fvidBg] - [winfo width .fvidBg.cont]]
				set relheight [expr [dict get [place info .fvidBg.cont] -relheight] + ($width_diff.0 / [winfo width .fvidBg.cont].0)]
				set panscan_multi [expr int(ceil(0.[lindex [split $relheight .] end] / 0.05))]
				set ::data(panscan) [expr ($panscan_multi * 5)]
				log_writeOutTv 0 "Auto zoom 16:9, changing realtive height of container frame."
				if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
					after 0 [vid_osd osd_group_w 1000 "Pan&Scan 16:9"]
				}
				if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
					after 0 [vid_osd osd_group_f 1000 "Pan&Scan 16:9"]
				}
				set ::data(panscanAuto) 1
				place .fvidBg.cont -relheight $relheight
			}
		} else {
			vid_wmPanscan .fvidBg.cont 0
		}
	}
}

proc vid_wmMoveVideo {dir} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmMoveVideo \033\[0m \{$dir\}"
	if {$::option(player_aspect) == 0} {
		log_writeOutTv 1 "Video aspect not managed bei TV-Viewer, moving video disabled!"
		return
	}
	set status_tvplayback [vid_callbackMplayerRemote alive]
	if {$status_tvplayback == 1} {return}
	#FIXME Why check for ismapped? Deprecated?
	if {[winfo ismapped .fvidBg.cont] == 0} {
		log_writeOutTv 1 "Video frame is not mapped."
		log_writeOutTv 1 "Auto Pan&Scan not possible."
		return
	}
	if {$dir == 0} {
		if {$::data(movevidX) == 100} return
		place .fvidBg.cont -relx [expr {[dict get [place info .fvidBg.cont] -relx] + 0.005}]
		log_writeOutTv 0 "Moving video to the right by 0.5%."
		set ::data(movevidX) [expr $::data(movevidX) + 1]
		if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list vid_osd osd_group_w 1000 [mc "Move x=%" $::data(movevidX)]]
		}
		if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list vid_osd osd_group_f 1000 [mc "Move x=%" $::data(movevidX)]]
		}
		return
	}
	if {$dir == 1} {
		if {$::data(movevidY) == 100} return
		place .fvidBg.cont -rely [expr {[dict get [place info .fvidBg.cont] -rely] + 0.005}]
		log_writeOutTv 0 "Moving video down by 0.5%."
		set ::data(movevidY) [expr $::data(movevidY) + 1]
		if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list vid_osd osd_group_w 1000 [mc "Move y=%" $::data(movevidY)]]
		}
		if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list vid_osd osd_group_f 1000 [mc "Move y=%" $::data(movevidY)]]
		}
		return
	}
	if {$dir == 2} {
		if {$::data(movevidX) == -100} return
		place .fvidBg.cont -relx [expr {[dict get [place info .fvidBg.cont] -relx] - 0.005}]
		log_writeOutTv 0 "Moving video to the left by 0.5%."
		set ::data(movevidX) [expr $::data(movevidX) - 1]
		if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list vid_osd osd_group_w 1000 [mc "Move x=%" $::data(movevidX)]]
		}
		if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list vid_osd osd_group_f 1000 [mc "Move x=%" $::data(movevidX)]]
		}
		return
	}
	if {$dir == 3} {
		if {$::data(movevidY) == -100} return
		place .fvidBg.cont -rely [expr {[dict get [place info .fvidBg.cont] -rely] - 0.005}]
		log_writeOutTv 0 "Moving video up by 0.5%."
		set ::data(movevidY) [expr $::data(movevidY) - 1]
		if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list vid_osd osd_group_w 1000 [mc "Move y=%" $::data(movevidY)]]
		}
		if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list vid_osd osd_group_f 1000 [mc "Move y=%" $::data(movevidY)]]
		}
		return
	}
	if {$dir == 4} {
		place .fvidBg.cont -relx 0.5 -rely 0.5
		set ::data(movevidX) 0
		set ::data(movevidY) 0
		log_writeOutTv 0 "Centering video."
		set ::data(movevidY) [expr $::data(movevidY) - 1]
		if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list vid_osd osd_group_w 1000 [mc "Centering video"]]
		}
		if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list vid_osd osd_group_f 1000 [mc "Centering video" ]]
		}
		return
	}
}

proc vid_wmStayonTop {com} {
	#Here we use the topmost attribute for toplevels so the video window may stay on top
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmStayonTop \033\[0m \{$com\}"
	if {$com == 0} {
		wm attributes . -topmost 0
	}
	if {$com == 1} {
		wm attributes . -topmost 1
	}
	if {$com == 2} {
		set status [vid_callbackMplayerRemote alive]
		if {$status != 1} {
			wm attributes . -topmost 1
		} else {
			if {[wm attributes . -topmost] == 1} {
				wm attributes . -topmost 0
			}
		}
	}
}

proc vid_wmGivenSize {w size} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmGivenSize \033\[0m \{$w\} \{$size\}"
	if {$size == 1} {
		wm geometry . {}
		$w configure -width $::option(resolx) -height $::option(resoly)
		place .fvidBg.cont -width [expr ($::option(resoly) * ($::option(resolx).0 / $::option(resoly).0))]
		log_writeOutTv 0 "Setting video frame to standard size."
		return
	} else {
		wm geometry . {}
		$w configure -width [expr round($::option(resolx) * $size)] -height [expr round($::option(resoly) * $size)]
		set status [vid_callbackMplayerRemote alive]
		if {$status != 1} {
			place .fvidBg.cont -width [expr ($::option(resoly) * ($::option(resolx).0 / $::option(resoly).0))]
		}
		log_writeOutTv 0 "Setting size of application to [expr $size * 100]."
		return
	}
}

proc vid_wmCursorHide {w com} {
	if {[info exists ::option(cursor_id\($w\))] == 1} {
		foreach id [split $::option(cursor_id\($w\))] {
			catch {after cancel $id}
		}
		unset -nocomplain ::option(cursor_id\($w\))
	}
	if {$com == 1} return
	if {"$::cursor($w)" == "none"} {
		set ::cursor($w) ""
		$w configure -cursor arrow
	} else {
		lappend ::option(cursor_id\($w\)) [after 1500 "$w configure -cursor none; set ::cursor($w) none"]
	}
}

proc vid_wmCursorPlaybar {ypos} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmCursorPlaybar \033\[0m \{$ypos\}"
	if {[info exists ::vid(pbMode)] && $::vid(pbMode) == 0} {
		#FIXME TV Playback mode show controls nevertheless?!
	}
	if {[info exists ::vid(pbMode)] && $::vid(pbMode) == 1} {
		if {[string trim [grid info .ftoolb_Play]] == {}} {
			if {$ypos > [expr [winfo screenheight .] - 20]} {
				grid .ftoolb_Play -in . -row 4 -column 1 \
				-sticky ew
				grid .ftoolb_Disp -in . -row 5 -column 0 \
				-columnspan 2 \
				-sticky ew
				log_writeOutTv 0 "Adding bottom toolbar with grid window manager."
			}
			return
		}
		if {[string trim [grid info .ftoolb_Play]] != {}} {
			if {$ypos < [expr [winfo screenheight .] - 80]} {
				grid remove .ftoolb_Play
				grid remove .ftoolb_Disp
				log_writeOutTv 0 "Removing bottom toolbar with grid window manager."
				.fvidBg configure -cursor arrow
				.fvidBg.cont configure -cursor arrow
				vid_wmCursorHide .fvidBg 1
				vid_wmCursorHide .fvidBg.cont 1
			}
			return
		}
	}
}

proc vid_wmHeartbeatCmd {com} {
	#Additional function to suppress screensaver
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmHeartbeatCmd \033\[0m \{$com\}"
	if {"$com" == "cancel"} {
		catch {after cancel $::data(heartbeat_id)}
		unset -nocomplain ::data(heartbeat_id)
		catch {exec xdg-screensaver resume $::vid(screensaverId)}
		unset -nocomplain ::vid(screensaverId)
		return
	}
	tk inactive reset
	set ::data(heartbeat_id) [after 50000 vid_wmHeartbeatCmd 0]
}
