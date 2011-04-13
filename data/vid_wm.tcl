#       vid_wm.tcl
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

proc vid_wmFullscreen {mw vid_bg vid_cont} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmFullscreen \033\[0m \{$mw\} \{$vid_cont\} \{$vid_bg\}"
	if {[wm attributes $mw -fullscreen] == 0} {
		grid remove .foptions_bar
		grid remove .seperatMenu
		grid remove .ftoolb_Top
		grid remove .fstations
		grid remove .ftoolb_Play
		grid remove .ftoolb_Disp
		
		.fvidBg configure -borderwidth 0
		
		bind $vid_cont <Motion> {
			vid_wmCursorHide .fvidBg.cont 0
			vid_wmCursorToolbar %X %Y
		}
		bind $vid_bg <Motion> {
			vid_wmCursorHide .fvidBg 0
			vid_wmCursorToolbar %X %Y
		}
		vid_wmStayonTop 0
		wm attributes $mw -fullscreen 1
		if {[string trim [focus -displayof .]] == {}} {
			log_writeOutTv 1 "Trying to request focus for main window"
			focus -force . ;#FIXME forcing focus may not work everytime, sometimes only the taskbar button is flashing
		}
		if {$::data(panscanAuto) == 1} {
			set ::vid(id_panscanAuto) [after 500 {
				catch {after cancel $::vid(id_panscanAuto)}
				set ::data(panscanAuto) 0
				event generate . <<wmZoomAuto>>
			}]
		}
		log_writeOutTv 0 "Going to full-screen mode."
	} else {
		if {[winfo exists .fvidBg.slist_lirc] && [string trim [place info .fvidBg.slist_lirc]] != {}} {
			log_writeOutTv 0 "Closing OSD station list for remote controls."
			.fvidBg.slist_lirc.lb_station selection clear 0 end
			focus .fvidBg
			destroy .fvidBg.slist_lirc
		}
		bind $vid_cont <Motion> {
			vid_wmCursorHide .fvidBg.cont 0
		}
		bind $vid_bg <Motion> {
			vid_wmCursorHide .fvidBg 0
		}
		if {$::main(compactMode) == 0} {
			grid .foptions_bar -in . -row 0 -column 0 -sticky new -columnspan 2
			grid .seperatMenu -in . -row 1 -column 0 -sticky ew -padx 2 -columnspan 2
			if {$::menu(cbViewMainToolbar)} {
				grid .ftoolb_Top -in . -row 2 -column 0 -columnspan 2 -sticky ew
			}
			if {$::menu(cbViewStationl)} {
				grid .fstations -in . -row 3 -column 0 -sticky nesw -padx "0 2"
			}
			if {$::menu(cbViewControlbar)} {
				grid .ftoolb_Play -in . -row 4 -column 0 -columnspan 2 -sticky ew
			}
			grid .fvidBg -in . -row 3 -column 1 -sticky nesw
			grid .ftoolb_Disp -in . -row 5 -column 0 -columnspan 2 -sticky ew -pady "2 0"
			
			.fvidBg configure -borderwidth 1
		}
		
		log_writeOutTv 0 "Going to windowed mode."
		wm attributes $mw -fullscreen 0
		vid_wmStayonTop $::vid(stayontop)
		if {$::data(panscanAuto) == 1} {
			set ::vid(id_panscanAuto) [after 500 {
				catch {after cancel $::vid(id_panscanAuto)}
				set ::data(panscanAuto) 0
				event generate . <<wmZoomAuto>>
			}]
		}
	}
}

proc vid_wmCompact {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmCompact \033\[0m"
	if {[wm attributes . -fullscreen] == 1} {
		log_writeOutTv 1 "Can not switch compact mode while in full-screen"
		return
	}
	if {$::main(compactMode)} {
		wm geometry . {}
		set width [winfo width .fvidBg]
		set height [winfo height .fvidBg]
		grid .foptions_bar -in . -row 0 -column 0 -sticky new -columnspan 2
		grid .seperatMenu -in . -row 1 -column 0 -sticky ew -padx 2 -columnspan 2
		if {$::menu(cbViewMainToolbar)} {
			grid .ftoolb_Top -in . -row 2 -column 0 -columnspan 2 -sticky ew
		}
		if {$::menu(cbViewStationl)} {
			grid .fstations -in . -row 3 -column 0 -sticky nesw -padx "0 2"
		}
		if {$::menu(cbViewControlbar)} {
			grid .ftoolb_Play -in . -row 4 -column 0 -columnspan 2 -sticky ew
		}
		grid .fvidBg -in . -row 3 -column 1 -sticky nesw
		grid .ftoolb_Disp -in . -row 5 -column 0 -columnspan 2 -sticky ew -pady "2 0"
		
		.fvidBg configure -borderwidth 1
		
		if {$width != 250} {
			if {$::menu(cbViewStationl)} {
				set widthc [expr [winfo width .fstations] + $width + 2]
			} else {
				set widthc $width
			}
		} else {
			set widthc 250
		}
		if {$::menu(cbViewMainToolbar)} {
			set mainHeight [winfo height .ftoolb_Top]
		} else {
			set mainHeight 0
		}
		if {$::menu(cbViewControlbar)} {
			set controlbHeight [winfo height .ftoolb_Play]
		} else {
			set controlbHeight 0
		}
		set heightc [expr [winfo height .foptions_bar] + [winfo height .seperatMenu] + $mainHeight + $controlbHeight + [winfo height .ftoolb_Disp] + $height]
		set heightmin [expr [winfo height .foptions_bar] + [winfo height .seperatMenu] + $mainHeight + $controlbHeight + [winfo height .ftoolb_Disp] + 141]
		wm minsize . 250 $heightmin
		if {$widthc < 250 || $heightc < $heightmin} {
			wm geometry . 250x$heightc
		} else {
			wm geometry . $widthc\x$heightc
		}
		wm title . "TV-Viewer"
		log_writeOutTv 0 "Normal window mode"
		set ::main(compactMode) 0
	} else {
		wm geometry . {}
		set width [winfo width .fvidBg]
		set height [winfo height .fvidBg]
		grid remove .foptions_bar
		grid remove .seperatMenu
		grid remove .ftoolb_Top
		grid remove .fstations
		grid remove .ftoolb_Play
		grid remove .ftoolb_Disp
		
		.fvidBg configure -borderwidth 0
		
		wm minsize . 250 141
		if {$width < 250 || $height < 141} {
			wm geometry . 250x141
		} else {
			wm geometry . $width\x$height
		}
		wm title . "TV-Viewer - [.ftoolb_Disp.fIcTxt.lDispText cget -text]"
		log_writeOutTv 0 "Compact mode"
		set ::main(compactMode) 1
	}
	if {$::data(panscanAuto) == 1} {
		set ::data(panscanAuto) 0
		event generate . <<wmZoomAuto>>
	}
}

proc vid_wmViewToolb {bar} {
	#Show/hide toolbars
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmViewToolb \033\[0m \{$bar\}"
	array set bargrid {
		main {.ftoolb_Top -in . -row 2 -column 0 -columnspan 2 -sticky ew}
		station {.fstations -in . -row 3 -column 0 -sticky nesw -padx "0 2"}
		control {.ftoolb_Play -in . -row 4 -column 0 -columnspan 2 -sticky ew}
	}
	array set barrem {
		main .ftoolb_Top
		station .fstations
		control .ftoolb_Play
	}
	if {[wm attributes . -fullscreen]} {
		#Do nothing in fullscreen mode
		log_writeOutTv 1 "Can not show/hide toolbars in fullscreen mode"
		return
	}
	if {$::main(compactMode)} {
		#Do nothing now because we are in compact mode
		return
	}
	if {[string trim [grid info $barrem($bar)]] == {}} {
		if {"$bar" == "main"} {
			if {$::menu(cbViewMainToolbar) != 1} {
				set ::menu(cbViewMainToolbar) 1
			}
		}
		if {"$bar" == "station"} {
			if {$::menu(cbViewStationl) != 1} {
				set ::menu(cbViewStationl) 1
			}
			grid .fvidBg -in . -row 3 -column 1 -sticky nesw
		}
		if {"$bar" == "control"} {
			if {$::menu(cbViewControlbar) != 1} {
				set ::menu(cbViewControlbar) 1
			}
		}
		grid {*}$bargrid($bar)
		log_writeOutTv 0 "Grid manager added $bar"
	} else {
		grid remove $barrem($bar)
		if {"$bar" == "main"} {
			if {$::menu(cbViewMainToolbar) != 0} {
				set ::menu(cbViewMainToolbar) 0
			}
		}
		if {"$bar" == "station"} {
			if {$::menu(cbViewStationl) != 0} {
				set ::menu(cbViewStationl) 0
			}
			grid .fvidBg -in . -row 3 -column 0 -columnspan 2 -sticky nesw
		}
		if {"$bar" == "control"} {
			if {$::menu(cbViewControlbar) != 0} {
				set ::menu(cbViewControlbar) 0
			}
		}
		log_writeOutTv 0 "Grid manager removed $bar"
	}
	set ::mem(toolbMain) $::menu(cbViewMainToolbar)
	set ::mem(toolbStation) $::menu(cbViewStationl)
	set ::mem(toolbControl) $::menu(cbViewControlbar)
	if {$::data(panscanAuto) == 1} {
		set ::data(panscanAuto) 0
		event generate . <<wmZoomAuto>>
	}
}

proc vid_wmViewStatus {lbl} {
	#Show/hide elements of status bar (Icon + messages and playback time)
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmViewStatus \033\[0m \{$lbl\}"
	array set lblgrid {
		ltxt {.ftoolb_Disp.fIcTxt.lDispText -in .ftoolb_Disp.fIcTxt -row 0 -column 1 -sticky nsw -padx "0 2"}
		ltm {.ftoolb_Disp.lTime -in .ftoolb_Disp -row 0 -column 1  -sticky nse -padx 2}
	}
	array set lblrem {
		ltxt .ftoolb_Disp.fIcTxt.lDispText
		ltm .ftoolb_Disp.lTime
	}
	
	if {[string trim [grid info $lblrem($lbl)]] == {}} {
		grid {*}$lblgrid($lbl)
		log_writeOutTv 0 "Grid manager added $lbl"
	} else {
		grid remove $lblrem($lbl)
		log_writeOutTv 0 "Grid manager removed $lbl"
	}
	set ::mem(sbarStatus) $::menu(cbViewStatusm)
	set ::mem(sbarTime) $::menu(cbViewStatust)
}

proc vid_wmPanscan {w direct value} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmPanscan \033\[0m \{$w\} \{$direct\} \{$value\}"
	#direct 1 increase zoom by value; -1 decrease zoom by value; 0 reset zoom when pan&scan4:3; 2 reset zoom
	set status_tvplayback [vid_callbackMplayerRemote alive]
	if {$status_tvplayback == 1} {return}
	array set zoom {
		1 1
		2 5
	}
	array set zoomPlace {
		1 0.01
		2 0.05
	}
	if {[string trim [place info $w]] == {}} return
	if {$direct == 1} {
		if {$::data(panscan) == 100} return
		if {[expr $::data(panscan) + $zoom($value)] > 100} {
			set zoom($value) [expr (100 - $::data(panscan))]
			set zoomPlace($value) [expr $zoom($value) / 100]
		}
		place $w -relheight [expr {[dict get [place info $w] -relheight] + $zoomPlace($value)}]
		log_writeOutTv 0 "Increasing zoom by $zoom($value)%."
		set ::data(panscan) [expr $::data(panscan) + $zoom($value)]
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
		if {[expr $::data(panscan) - $zoom($value)] < -50} {
			set zoom($value) [expr (-50 - $::data(panscan)) * -1]
			set zoomPlace($value) [expr $zoom($value) / 100]
		}
		place $w -relheight [expr {[dict get [place info $w] -relheight] - $zoomPlace($value)}]
		log_writeOutTv 0 "Decreasing zoom by $zoom($value)%."
		set ::data(panscan) [expr $::data(panscan) - $zoom($value)]
		set ::data(panscanAuto) 0
		if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [list vid_osd osd_group_w 1000 "Zoom $::data(panscan)"]
		}
		if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [list vid_osd osd_group_f 1000 "Zoom $::data(panscan)"]
		}
	}
	if {$direct == 0} {
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
	if {$direct == 2} {
		place $w -relheight 1
		log_writeOutTv 0 "Setting zoom to 100%"
		set ::data(panscan) 0
		set ::data(panscanAuto) 0
		if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
			after 0 [vid_osd osd_group_w 1000 "Zoom $::data(panscan)"]
		}
		if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
			after 0 [vid_osd osd_group_f 1000 "Zoom $::data(panscan)"]
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
	if {[wm attributes . -fullscreen] == 0} {
		if {[string trim [place info .fvidBg.cont]] != {}} {
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
					if {$::menu(cbViewStationl)} {
						set width [expr [winfo width .] - [winfo width .fstations]]
					} else {
						set width [winfo width .]
					}
					set height [expr int(ceil($width.0 / 1.777777778))]
					if {$::menu(cbViewMainToolbar)} {
						set mainHeight [winfo height .ftoolb_Top]
					} else {
						set mainHeight 0
					}
					if {$::menu(cbViewControlbar)} {
						set controlbHeight [winfo height .ftoolb_Play]
					} else {
						set controlbHeight 0
					}
					set heightwp [expr $height + [winfo height .foptions_bar] + [winfo height .seperatMenu] + $mainHeight + $controlbHeight + [winfo height .ftoolb_Disp]]
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
				if {$::main(compactMode)} {
					set width [winfo width .]
					set height [expr int(ceil($width.0 / 1.3333333333333333))]
					wm geometry . [winfo width .]x$height
				} else {
					if {$::menu(cbViewStationl)} {
						set width [expr [winfo width .] - [winfo width .fstations]]
					} else {
						set width [winfo width .]
					}
					set height [expr int(ceil($width.0 / 1.3333333333333333))]
					if {$::menu(cbViewMainToolbar)} {
						set mainHeight [winfo height .ftoolb_Top]
					} else {
						set mainHeight 0
					}
					if {$::menu(cbViewControlbar)} {
						set controlbHeight [winfo height .ftoolb_Play]
					} else {
						set controlbHeight 0
					}
					set heightwp [expr $height + [winfo height .foptions_bar] + [winfo height .seperatMenu] + $mainHeight + $controlbHeight + [winfo height .ftoolb_Disp]]
					wm geometry . [winfo width .]x$heightwp
				}
				vid_wmPanscan .fvidBg.cont 0 1
			}
		}
	} else {
		if {$::data(panscanAuto) == 0} {
			if {[string trim [place info .fvidBg.cont]] != {}} {
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
			}
		} else {
			vid_wmPanscan .fvidBg.cont 0 1
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
	if {[string trim [place info .fvidBg.cont]] == {}} {
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

proc vid_wmCursor {com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmCursor \033\[0m \{$com\}"
	#Start/Stop hiding mouse cursor. com 0 stop hiding cursor - 1 hide cursor
	if {$com == 0} {
		bind .fvidBg.cont <Motion> {}
		bind .fvidBg <Motion> {}
		bind . <ButtonPress-1> {}
		vid_wmCursorHide .fvidBg.cont 1
		vid_wmCursorHide .fvidBg 1
		set ::cursor(.fvidBg.cont) ""
		set ::cursor(.fvidBg) ""
		if {[info exists ::cursor(old_.fvidBg)] && [info exists ::cursor(old_.fvidBg.cont)]} {
			.fvidBg configure -cursor $::cursor(old_.fvidBg)
			.fvidBg.cont configure -cursor $::cursor(old_.fvidBg.cont)
		}
	}
	if {$com == 1} {
		if {[wm attributes . -fullscreen] == 1} {
			bind .fvidBg.cont <Motion> {
				vid_wmCursorHide .fvidBg.cont 0
				vid_wmCursorToolbar %X %Y
			}
			bind .fvidBg <Motion> {
				vid_wmCursorHide .fvidBg 0
				vid_wmCursorToolbar %X %Y
			}
		} else {
			bind .fvidBg.cont <Motion> {
				vid_wmCursorHide .fvidBg.cont 0
			}
			bind .fvidBg <Motion> {
				vid_wmCursorHide .fvidBg 0
			}
		}
		bind . <ButtonPress-1> {.fvidBg.cont configure -cursor $::cursor(old_.fvidBg.cont); .fvidBg configure -cursor $::cursor(old_.fvidBg)}
		set ::cursor(.fvidBg.cont) left_ptr
		set ::cursor(.fvidBg) left_ptr
		vid_wmCursorHide .fvidBg.cont 0
		vid_wmCursorHide .fvidBg 0
	}
}

proc vid_wmCursorHide {w com} {
	if {[info exists ::option(cursor_id\($w\))] == 1} {
		foreach id $::option(cursor_id\($w\)) {
			catch {after cancel $id}
		}
		unset -nocomplain ::option(cursor_id\($w\))
	}
	if {$com == 1} return
	if {"$::cursor($w)" == "none"} {
		set ::cursor($w) left_ptr
		$w configure -cursor $::cursor(old_$w)
	} else {
		set ::cursor(old_$w) left_ptr
		lappend ::option(cursor_id\($w\)) [after 1500 "$w configure -cursor none; set ::cursor($w) none"]
	}
}

proc vid_wmCursorToolbar {xpos ypos} {
	#Show/hide toolbars (Top, Play) and Station List depending on cursor position.
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_wmCursorToolbar \033\[0m \{$xpos\} \{$ypos\}"
	if {[info exists ::vid(pbMode)] && $::vid(pbMode) == 0} {
		if {$::option(floatMain)} {
			if {[string trim [grid info .ftoolb_Top]] == {}} {
				if {$ypos < 20} {
					grid .ftoolb_Top -in . -row 2 -column 0 -columnspan 2 -sticky ew
					log_writeOutTv 0 "Adding main toolbar with grid window manager."
				}
			}
			if {[string trim [grid info .ftoolb_Top]] != {}} {
				if {$ypos > 80} {
					grid remove .ftoolb_Top
					log_writeOutTv 0 "Removing main toolbar with grid window manager."
				}
			}
		}
		if {$::option(floatStation)} {
			if {[string trim [grid info .fstations]] == {}} {
				if {$xpos < 20} {
					grid .fstations -in . -row 3 -column 0 -sticky nesw
					log_writeOutTv 0 "Adding station list with grid window manager."
				}
			}
			if {[string trim [grid info .fstations]] != {}} {
				if {$xpos > 80} {
					grid remove .fstations
					log_writeOutTv 0 "Removing station list with grid window manager."
				}
			}
		}
		if {$::option(floatPlay)} {
			if {[string trim [grid info .ftoolb_Play]] == {}} {
				if {$ypos > [expr [winfo screenheight .] - 20]} {
					grid .ftoolb_Play -in . -row 4 -column 0 -columnspan 2 -sticky ew
					grid .ftoolb_Disp -in . -row 5 -column 0 -columnspan 2 -sticky ew -pady "2 0"
					log_writeOutTv 0 "Adding bottom toolbar with grid window manager."
				}
			}
			if {[string trim [grid info .ftoolb_Play]] != {}} {
				if {$ypos < [expr [winfo screenheight .] - 80]} {
					grid remove .ftoolb_Play
					grid remove .ftoolb_Disp
					log_writeOutTv 0 "Removing bottom toolbar with grid window manager."
				}
			}
		}
	}
	if {[info exists ::vid(pbMode)] && $::vid(pbMode) == 1} {
		if {$::option(floatMain)} {
			if {[string trim [grid info .ftoolb_Top]] == {}} {
				if {$ypos < 20} {
					grid .ftoolb_Top -in . -row 2 -column 0 -columnspan 2 -sticky ew
					log_writeOutTv 0 "Adding main toolbar with grid window manager."
				}
			}
			if {[string trim [grid info .ftoolb_Top]] != {}} {
				if {$ypos > 80} {
					grid remove .ftoolb_Top
					log_writeOutTv 0 "Removing main toolbar with grid window manager."
				}
			}
		}
		if {[string trim [grid info .ftoolb_Play]] == {}} {
			if {$ypos > [expr [winfo screenheight .] - 20]} {
				grid .ftoolb_Play -in . -row 4 -column 0 -columnspan 2 -sticky ew
				grid .ftoolb_Disp -in . -row 5 -column 0 -columnspan 2 -sticky ew -pady "2 0"
				log_writeOutTv 0 "Adding bottom toolbar with grid window manager."
			}
			return
		}
		if {[string trim [grid info .ftoolb_Play]] != {}} {
			if {$ypos < [expr [winfo screenheight .] - 80]} {
				grid remove .ftoolb_Play
				grid remove .ftoolb_Disp
				log_writeOutTv 0 "Removing bottom toolbar with grid window manager."
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
