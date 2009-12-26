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

proc tv_playerVolumeControl {wfbottom value} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_playerVolumeControl \033\[0m \{$wfbottom\} \{$value\}"
	set status_tv_playback [tv_callbackMplayerRemote alive]
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
			
			set ::main(volume_scale) $value
			tv_callbackMplayerRemote "volume [expr int($value)] 1"
		} else {
			if {[$wfbottom.scale_volume instate disabled] == 0} {
				set ::volume(mute_old_value) "$::main(volume_scale)"
				set ::main(volume_scale) 0
				$wfbottom.scale_volume state disabled
				$wfbottom.button_mute configure -image $::icon_m(volume-error)
				if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
					after 0 [list tv_osd osd_group_w 1000 [mc "Mute"]]
				}
				if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
					after 0 [list tv_osd osd_group_f 1000 [mc "Mute"]]
				}
				tv_callbackMplayerRemote "volume 0 1"
			} else {
				set ::main(volume_scale) "$::volume(mute_old_value)"
				$wfbottom.scale_volume state !disabled
				$wfbottom.button_mute configure -image $::icon_m(volume)
				if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
					after 0 [list tv_osd osd_group_w 1000 "Volume $::volume(mute_old_value)"]
				}
				if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
					after 0 [list tv_osd osd_group_f 1000 "Volume $::volume(mute_old_value)"]
				}
				tv_callbackMplayerRemote "volume [expr int($::main(volume_scale))] 1"
			}
		}
	}
}

proc tv_playerUi {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_playerUi \033\[0m"
	if {[winfo exists .tv] == 0} {
		log_writeOutTv 0 "Setting up TV Player."
		set mw [toplevel .tv -class "TV-Viewer"]
		.tv configure -background black
		set tv_bg [frame $mw.bg -background black -width $::option(resolx) -height $::option(resoly)]
		set tv_cont [frame $tv_bg.w -background "" -container yes]
		set tv_slist [frame .tv.slist -bg #004AFF -padx 5 -pady 5]
		set tv_slist_lirc [frame .tv.slist_lirc -bg #004AFF -padx 5 -pady 5]
		if {[clock format [clock seconds] -format {%d%m}] == 2412} {
			ttk::label $mw.l_image \
			-image $::icon_e(logo-tv-viewer08x-noload_xmas)
		} else {
			ttk::label $mw.l_image \
			-image $::icon_e(logo-tv-viewer08x-noload)
		}
		
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
			-command [list tv_wmPanscan $tv_cont 1] \
			-accelerator "E"
			$mw.rightclickViewer.panscan add command \
			-label [mc "Zoom -"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_wmPanscan $tv_cont -1] \
			-accelerator "W"
			$mw.rightclickViewer.panscan add command \
			-label [mc "Pan&Scan (16:9 / 4:3)"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command {tv_wmPanscanAuto} \
			-accelerator "Shift+W"
			$mw.rightclickViewer.panscan add separator
			$mw.rightclickViewer.panscan add command \
			-label [mc "Move up"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_wmMoveVideo 3] \
			-accelerator "Alt+Up"
			$mw.rightclickViewer.panscan add command \
			-label [mc "Move down"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_wmMoveVideo 1] \
			-accelerator "Alt+Down"
			$mw.rightclickViewer.panscan add command \
			-label [mc "Move left"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_wmMoveVideo 2] \
			-accelerator "Alt+Left"
			$mw.rightclickViewer.panscan add command \
			-label [mc "Move right"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_wmMoveVideo 0] \
			-accelerator "Alt+Right"
			$mw.rightclickViewer.panscan add command \
			-label [mc "Center video"] \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_wmMoveVideo 4] \
			-accelerator "Alt+C"
		$mw.rightclickViewer add cascade \
		-label [mc "Size"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-menu $mw.rightclickViewer.size
			$mw.rightclickViewer.size add command \
			-label "50%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_wmGivenSize .tv.bg 0.5]
			$mw.rightclickViewer.size add command \
			-label "75%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_wmGivenSize .tv.bg 0.75]
			$mw.rightclickViewer.size add command \
			-label "100%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_wmGivenSize .tv.bg 1.0] \
			-accelerator [mc "Ctrl+1"]
			$mw.rightclickViewer.size add command \
			-label "125%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_wmGivenSize .tv.bg 1.25]
			$mw.rightclickViewer.size add command \
			-label "150%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_wmGivenSize .tv.bg 1.5]
			$mw.rightclickViewer.size add command \
			-label "175%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_wmGivenSize .tv.bg 1.75]
			$mw.rightclickViewer.size add command \
			-label "200%" \
			-compound left \
			-image $::icon_s(placeholder) \
			-command [list tv_wmGivenSize .tv.bg 2.0] \
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
			-command [list tv_wmStayonTop 0]
			$mw.rightclickViewer.ontop add radiobutton \
			-label [mc "Always"] \
			-variable tv(stayontop) \
			-value 1 \
			-command [list tv_wmStayonTop 1]
			$mw.rightclickViewer.ontop add radiobutton \
			-label [mc "While playback"] \
			-variable tv(stayontop) \
			-value 2 \
			-command [list tv_wmStayonTop 2]
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
		
		bind $mw <Key-f> [list tv_wmFullscreen $mw $tv_cont $tv_bg]
		bind $tv_cont <Double-ButtonPress-1> [list tv_wmFullscreen $mw $tv_cont $tv_bg]
		bind $tv_bg <Double-ButtonPress-1> [list tv_wmFullscreen $mw $tv_cont $tv_bg]
		bind $mw <<teleview>> {tv_playerRendering}
		bind $mw <<station_down>> [list main_stationChannelDown .label_stations]
		bind $mw <<station_up>> [list main_stationChannelUp .label_stations]
		bind $mw <<station_jump>> [list main_stationChannelJumper .label_stations]
		bind $mw <<station_key>> [list main_stationStationNrKeys %A]
		bind $mw <<record>> [list record_wizardUi]
		bind $mw <<timeshift>> [list timeshift .top_buttons.button_timeshift]
		bind $mw <<input_up>> [list main_stationInput 1 1]
		bind $mw <<input_down>> [list main_stationInput 1 -1]
		bind $mw <<volume_decr>> {tv_playerVolumeControl .bottom_buttons [expr $::main(volume_scale) - 3]}
		bind $mw <<volume_incr>> {tv_playerVolumeControl .bottom_buttons [expr $::main(volume_scale) + 3]}
		bind $mw <Key-m> [list tv_playerVolumeControl .bottom_buttons mute]
		bind $mw <Control-Key-1> [list tv_wmGivenSize $tv_bg 1]
		bind $mw <Control-Key-2> [list tv_wmGivenSize $tv_bg 2]
		bind $mw <Key-e> [list tv_wmPanscan $tv_cont 1]
		bind $mw <Key-w> [list tv_wmPanscan $tv_cont -1]
		bind $mw <Shift-Key-W> {tv_wmPanscanAuto}
		bind $mw <Alt-Key-Right> [list tv_wmMoveVideo 0]
		bind $mw <Alt-Key-Down> [list tv_wmMoveVideo 1]
		bind $mw <Alt-Key-Left> [list tv_wmMoveVideo 2]
		bind $mw <Alt-Key-Up> [list tv_wmMoveVideo 3]
		bind $mw <Alt-Key-c> [list tv_wmMoveVideo 4]
		bind $mw <Mod4-Key-s> [list tv_callbackMplayerRemote "screenshot 0"]
		bind $mw <Control-Key-p> {config_wizardMainUi}
		bind $mw <Control-Key-m> {colorm_mainUi}
		bind $mw <Control-Key-e> {station_editUi}
		bind $mw <Key-F1> [list info_helpHelp]
		bind $mw <Control-Key-x> {main_frontendExitViewer}
		bind $mw <ButtonPress-3> [list tk_popup $mw.rightclickViewer %X %Y]
		bind $mw <Alt-Key-y> {tv_playerInfoVars}
		
		if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
			log_writeOutTv 1 "No valid stations list, will not activate station selector for video window."
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
			bind $tv_cont <Motion> {tv_slistCursor %X %Y}
			bind $tv_bg <Motion> {tv_slistCursor %X %Y}
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
			tv_wmFullscreen $mw $tv_cont $tv_bg
		}
	}
}

proc tv_playerInfoVars {} {
	set varfile [open "$::env(HOME)/varfile" w+]
	foreach var [info globals] {
		if {[array exists ::$var]} {
			puts $varfile "FOUND ARRAY $var:"
			flush $varfile
			foreach {key elem} [array get ::$var] {
				puts $varfile "key: $key
element: $elem
"
				flush $varfile
			}
		} else {
			puts $varfile "
$var: [set ::$var]"
			flush $varfile
		}
	}
	close $varfile
}

proc tv_playerRendering {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_playerRendering \033\[0m"
	set status [tv_callbackMplayerRemote alive]
	if {$status != 1} {
		if {[winfo exists .tv.file_play_bar] == 1} {
			tv_playbackStop 0 nopic
			tv_fileComputePos cancel
			tv_fileComputeSize cancel
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
			set status [tv_callbackMplayerRemote alive]
			if {$status != 1} {
				after 100 {tv_playerLoop}
			} else {
				if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"]} {
					catch {file delete -force "[subst $::option(timeshift_path)/timeshift.mpeg]"}
				}
				tv_playback .tv.bg .tv.bg.w
			}
		} else {
			tv_playbackStop 0 pic
		}
	} else {
		if {[winfo exists .tv.file_play_bar] == 1} {
			tv_fileComputePos cancel
			tv_fileComputeSize cancel
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
		tv_Playback .tv.bg .tv.bg.w 0 0
	}
}

proc tv_playerLoop {} {
	set status [tv_callbackMplayerRemote alive]
	if {$status != 1} {
		after 100 {tv_playerLoop}
	} else {
		if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"]} {
			catch {file delete -force "[subst $::option(timeshift_path)/timeshift.mpeg]"}
		}
		puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_playerLoop \033\[0;1;31m::complete:: \033\[0m"
		tv_Playback .tv.bg .tv.bg.w 0 0
	}
}

# Deprecated code that stays here in case it will be needed again

#~ proc tv_autorepeat_press {keycode serial seek_com} {
	#~ if {$::data(key_first_press) == 1} {
		#~ set ::data(key_first_press) 0
		#~ if {"[lindex $seek_com 0]" == "tv_seek"} {
			#~ set ::tv(seek_secs) [lindex $seek_com 1]
			#~ set ::tv(seek_dir) [lindex $seek_com 2]
			#~ set ::tv(getvid_seek) 1
			#~ tv_callbackMplayerRemote get_time_pos
		#~ }
	#~ }
	#~ set ::data(key_serial) $serial
#~ }
#~ 
#~ proc tv_autorepeat_release {keycode serial} {
	#~ global delay
	#~ after 10 "if {$serial != \$::data(key_serial)} {
	#~ set ::data(key_first_press) 1
	#~ }"
#~ }
#~ 
#~ proc tv_syncing_file_pos {stop} {
	#~ catch {after cancel $::data(sync_remoteid)}
	#~ catch {after cancel $::data(sync_id)}
	#~ set ::data(sync_remoteid) [after 500 {tv_callbackMplayerRemote get_time_pos}]
	#~ set ::data(sync_id) [after 1000 {
		#~ if {[string match -nocase "ANS_TIME_POSITION*" $::data(report)]} {
			#~ set pos [lindex [split $::data(report) \=] end]
			#~ set ::data(file_pos_calc) [expr [clock seconds] - [expr int($pos)]]
		#~ }
	#~ }]
#~ }
