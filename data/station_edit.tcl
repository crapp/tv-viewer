#       station_edit.tcl
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

proc station_editPreview {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_editPreview \033\[0m \{$w\}"
	log_writeOutTv 0 "Starting tv playback for preview stations."
	set status_tv_playback [tv_callbackMplayerRemote alive]
	if {$status_tv_playback != 1} {
		tv_playbackStop 0 pic
	} else {
		if {"[string trim [$w selection]]" == {}} {
			log_writeOutTv 1 "You need to select a channel to be previewed."
			return
		}
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
		if {$status_get_input == 0} {
			if {[lindex [$w item [lindex [$w selection] end] -values] 2] == [lindex $resultat_get_input 3]} {
				set freq [lindex [$w item [lindex [$w selection] end] -values] 1]
				catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$freq}
				.ftoolb_Disp.lDispText configure -text [mc "Now playing %" [lindex [$w item [lindex [$w selection] end] -values] 0]]
				tv_Playback .ftvBg .ftvBg.cont 0 0
			} else {
				tv_playbackStop 0 nopic
				chan_zapperInputLoop cancel 0 0 0 0 0
				set ::chan(change_inputLoop_id) [after 200 [list chan_zapperInputLoop 0 [lindex [$w item [lindex [$w selection] end] -values] 2] [lindex [$w item [lindex [$w selection] end] -values] 2] 0 1 0]]
				.ftoolb_Disp.lDispText configure -text [mc "Now playing %" [lindex [$w item [lindex [$w selection] end] -values] 0]]
			}
		} else {
			log_writeOutTv 2 "Can not read video inputs. Changing stations not possible."
		}
	}
}

proc station_editZap {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_editZap \033\[0m \{$w\}"
	set status_tv_playback [tv_callbackMplayerRemote alive]
	if {$status_tv_playback != 1} {
		log_writeOutTv 0 "Changing frequency to [lindex [$w item [lindex [$w selection] end] -values] 1]."
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
		if {$status_get_input == 0} {
			if {[lindex [$w item [lindex [$w selection] end] -values] 2] == [lindex $resultat_get_input 3]} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex [$w item [lindex [$w selection] end] -values] 1]}
				.ftoolb_Disp.lDispText configure -text [mc "Now playing %" [lindex [$w item [lindex [$w selection] end] -values] 0]]
				return
			} else {
				tv_playbackStop 0 nopic
				chan_zapperInputLoop cancel 0 0 0 0 0
				set ::chan(change_inputLoop_id) [after 200 [list chan_zapperInputLoop 0 [lindex [$w item [lindex [$w selection] end] -values] 2] [lindex [$w item [lindex [$w selection] end] -values] 1] 0 1 0]]
				.ftoolb_Disp.lDispText configure -text [mc "Now playing %" [lindex [$w item [lindex [$w selection] end] -values] 0]]
			}
		} else {
			log_writeOutTv 2 "Can not read video inputs. Changing stations not possible."
		}
	}
}


proc station_editSave {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_editSave \033\[0m \{$w\}"
	log_writeOutTv 0 "Writing stations to $::option(home)/config/stations_$::option(frequency_table).conf"
	catch {file delete "$::option(home)/config/stations_$::option(frequency_table).conf"}
	catch {file delete "$::option(home)/config/lastchannel.conf"}
	foreach sitem [split [$w children {}]] {
		if {[file exists "$::option(home)/config/stations_$::option(frequency_table).conf"] != 1} {
			set open_sfile_write [open "$::option(home)/config/stations_$::option(frequency_table).conf" w]
			if {"[$w item $sitem -tags]" == "disabled"} {
				puts -nonewline $open_sfile_write "\#\{[lindex [$w item $sitem -values] 0]\} [string trim [lindex [$w item $sitem -values] 1]] [lindex [$w item $sitem -values] 2]"
			} else {
				puts -nonewline $open_sfile_write "\{[lindex [$w item $sitem -values] 0]\} [string trim [lindex [$w item $sitem -values] 1]] [lindex [$w item $sitem -values] 2]"
			}
			close $open_sfile_write
		} else {
			set open_sfile_append [open "$::option(home)/config/stations_$::option(frequency_table).conf" a]
			if {"[$w item $sitem -tags]" == "disabled"} {
				puts -nonewline $open_sfile_append "
\#\{[lindex [$w item $sitem -values] 0]\} [string trim [lindex [$w item $sitem -values] 1]] [lindex [$w item $sitem -values] 2]"
			} else {
				puts -nonewline $open_sfile_append "
\{[lindex [$w item $sitem -values] 0]\} [string trim [lindex [$w item $sitem -values] 1]] [lindex [$w item $sitem -values] 2]"
			}
			close $open_sfile_append
		}
	}
	station_editExit save
}

proc station_editExit {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_editExit \033\[0m \{$handler\}"
	if {"$handler" == "save"} {
		catch {array unset ::kanalid}
		catch {array unset ::kanalcall}
		catch {array unset ::kanalinput}
		log_writeOutTv 0 "Rereading all stations and corresponding frequencies for main application."
		if !{[file exists "$::option(home)/config/stations_$::option(frequency_table).conf"]} {
			set status_tv_playback [tv_callbackMplayerRemote alive]
			if {$status_tv_playback != 1} {
				tv_playbackStop 0 nopic
			}
			log_writeOutTv 2 "No valid stations_$::option(frequency_table).conf"
			log_writeOutTv 2 "Please create one using the Station Editor."
			log_writeOutTv 2 "Make sure you checked the configuration first!"
		} else {
			set file "$::option(home)/config/stations_$::option(frequency_table).conf"
			set open_channel_file [open $file r]
			set i 1
			while {[gets $open_channel_file line]!=-1} {
				if {[string match #* $line] || [string trim $line] == {} } continue
				if {[llength $line] < 3} {
					lassign $line ::kanalid($i) ::kanalcall($i)
					set ::kanalinput($i) $::option(video_input)
				} else {
					lassign $line ::kanalid($i) ::kanalcall($i) ::kanalinput($i)
				}
				set ::station(max) $i
				incr i
			}
			close $open_channel_file
			if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
				log_writeOutTv 2 "No valid stations_$::option(frequency_table).conf"
				log_writeOutTv 2 "Please create one using the Station Editor."
				log_writeOutTv 2 "Make sure you checked the configuration first!"
			} else {
				log_writeOutTv 0 "Valid stations_$::option(frequency_table).conf found with $::station(max) stations."
				if {[file exists "$::option(home)/config/lastchannel.conf"]} {
					set last_channel_conf "$::option(home)/config/lastchannel.conf"
					set open_lastchannel [open $last_channel_conf r]
					set open_lastchannel_read [read $open_lastchannel]
					lassign $open_lastchannel_read kanal channel sendernummer
					set ::station(last) "\{$kanal\} $channel $sendernummer"
					set ::station(old) "\{$kanal\} $channel $sendernummer"
					catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $::station(last) 1]} resultat_v4l2ctl
					close $open_lastchannel
					after 1000 [list station_after_msg [lindex $::station(last) 2] $resultat_v4l2ctl]
				} else {
					set last_channel_conf "$::option(home)/config/lastchannel.conf"
					set fileId [open $last_channel_conf "w"]
					puts -nonewline $fileId "\{$::kanalid(1)\} $::kanalcall(1) 1"
					close $fileId
					set ::station(last) "\{$::kanalid(1)\} $::kanalcall(1) 1"
					set ::station(old) "\{$::kanalid(1)\} $::kanalcall(1) 1"
					catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $::station(last) 1]} resultat_v4l2ctl
					after 1000 [list station_after_msg [lindex $::station(last) 2] $resultat_v4l2ctl]
				}
			}
		}
		
		main_frontendChannelHandler sedit
		
		if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
			#~ log_writeOutTv 2 "Disabling widgets due to no valid stations file."
			#FIXME What to do with OSD Stationlists if no stations
			#~ if {[winfo exists .tv.slist]} {
				#~ log_writeOutTv 2 "No valid stations list, disabling station selector for video window."
				#~ destroy .tv.slist
			#~ }
			#~ if {[winfo exists .tv.slist_lirc]} {
				#~ log_writeOutTv 2 "No valid stations list, disabling lirc station selector for video window."
				#~ destroy .tv.slist_lirc
			#~ }
			
		} else {
			#~ set status_tv_playback [tv_callbackMplayerRemote alive]
			#~ if {$status_tv_playback != 1} {
				#~ .station.top_buttons.b_station_preview state pressed
			#~ }
			#FIXME What to do with OSD Stationlists if no stations
			#~ if {[winfo exists .tv.slist.lb_station] == 1 && [winfo exists .tv.slist_lirc.lb_station] == 1} {
				#~ .tv.slist.lb_station delete 0 end
				#~ .tv.slist_lirc.lb_station delete 0 end
				#~ for {set i 1} {$i <= $::station(max)} {incr i} {
					#~ if {$i < 10} {
						#~ .tv.slist.lb_station insert end " $i     $::kanalid($i)"
					#~ } else {
						#~ if {$i < 100} {
							#~ .tv.slist.lb_station insert end " $i   $::kanalid($i)"
						#~ } else {
							#~ .tv.slist.lb_station insert end " $i $::kanalid($i)"
						#~ }
					#~ }
					#~ .tv.slist_lirc.lb_station insert end "$::kanalid($i)"
				#~ }
			#~ }
		}
		log_writeOutTv 0 "Exiting station editor."
	} else {
		log_writeOutTv 0 "Exiting station editor without any changes."
	}
	
	grab release .station
	#FIXME Close to tray deactivated
	#~ if {$::option(systray_close) == 1} {
		#~ wm protocol . WM_DELETE_WINDOW {main_systemTrayTogglePre}
	#~ } else {
		#~ 
	#~ }
	wm protocol . WM_DELETE_WINDOW [list event generate . <<exit>>]
	destroy .station
}

proc station_editUi {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_editUi \033\[0m"
	if {[winfo exists .tray] == 1} {
		if {[winfo ismapped .] == 0} {
			log_writeOutTv 1 "User attempted to start station editor while main is docked."
			log_writeOutTv 1 "Will undock main."
			 main_systemTrayToggle
		}
	}
	
	if {[wm attributes . -fullscreen] == 1} {
		tv_wmFullscreen . .ftvBg.cont .ftvBg
	}
	
	# Setting up main Interface
	
	log_writeOutTv 0 "Starting Station Editor."
	
	if {[winfo exists .station] == 0 } {
		set w [toplevel .station]
		
		place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		
		set wfstation [ttk::frame $w.wfstation]
		
		set wfbottom [ttk::frame $w.bottom_buttons -style TLabelframe]
		
		set wftop [ttk::frame $w.top_buttons] ; place [ttk::label $wftop.bg -style Toolbutton] -relwidth 1 -relheight 1
		
		ttk::button $wftop.b_station_search \
		-text [mc "Station search"] \
		-style Toolbutton \
		-command [list station_searchUi $wfstation.tv_station]
		
		ttk::separator $wftop.sr_1 \
		-orient vertical
		
		ttk::button $wftop.b_station_add \
		-text [mc "Add"] \
		-style Toolbutton \
		-command [list station_itemAdd $wfstation.tv_station]
		
		ttk::button $wftop.b_station_delete \
		-text [mc "Delete"] \
		-style Toolbutton \
		-command [list station_itemDelete $wfstation.tv_station]
		
		ttk::button $wftop.b_station_activate \
		-text [mc "(De)Activate"] \
		-style Toolbutton \
		-command [list station_itemDeactivate $wfstation.tv_station]
		
		ttk::button $wftop.b_station_edit \
		-text [mc "Edit"] \
		-style Toolbutton \
		-command [list station_itemEdit $wfstation.tv_station]
		
		ttk::separator $wftop.sr_2 \
		-orient vertical
		
		ttk::button $wftop.b_station_up \
		-text [mc "Up"] \
		-style Toolbutton \
		-command [list station_itemMove $wfstation.tv_station -1]
		
		ttk::button $wftop.b_station_down \
		-text [mc "Down"] \
		-style Toolbutton \
		-command [list station_itemMove $wfstation.tv_station 1]
		
		ttk::separator $wftop.sr_3 \
		-orient vertical
		
		ttk::button $wftop.b_station_preview \
		-text [mc "Preview"] \
		-style Toolbutton \
		-command [list station_editPreview $wfstation.tv_station]
		
		ttk::treeview $wfstation.tv_station \
		-yscrollcommand [list $wfstation.sb_station set] \
		-columns {station frequency input} \
		-show headings
		
		ttk::scrollbar $wfstation.sb_station \
		-orient vertical \
		-command [list $wfstation.tv_station yview]
		
		ttk::button $wfbottom.b_save \
		-text [mc "Apply"] \
		-command [list station_editSave $wfstation.tv_station] \
		-compound left \
		-image $::icon_s(dialog-ok-apply)
		
		ttk::button $wfbottom.b_exit \
		-text [mc "Cancel"] \
		-command [list station_editExit cancel]\
		-compound left \
		-image $::icon_s(dialog-cancel)
		
		grid $wftop -in $w -row 0 -column 0 \
		-sticky ew
		grid $wfstation -in $w -row 1 -column 0 \
		-sticky nesw
		grid $wfbottom -in $w -row 2 -column 0 \
		-sticky ew \
		-padx 3 \
		-pady 3
		
		grid anchor $wfbottom e
		
		grid $wftop.b_station_search -in $wftop -row 0 -column 0 \
		-pady 4 \
		-padx 3
		grid $wftop.sr_1 -in $wftop -row 0 -column 1 \
		-sticky ns
		grid $wftop.b_station_add -in $wftop -row 0 -column 2 \
		-pady 2 \
		-padx 3
		grid $wftop.b_station_delete -in $wftop -row 0 -column 3 \
		-pady 2 \
		-padx "0 3"
		grid $wftop.b_station_activate -in $wftop -row 0 -column 5 \
		-pady 2 \
		-padx "0 3"
		grid $wftop.b_station_edit -in $wftop -row 0 -column 4 \
		-pady 2 \
		-padx "0 3"
		grid $wftop.sr_2 -in $wftop -row 0 -column 6 \
		-sticky ns
		grid $wftop.b_station_up -in $wftop -row 0 -column 7 \
		-pady 2 \
		-padx 3
		grid $wftop.b_station_down -in $wftop -row 0 -column 8 \
		-pady 2 \
		-padx "0 3"
		grid $wftop.sr_3 -in $wftop -row 0 -column 9 \
		-sticky ns
		grid $wftop.b_station_preview -in $wftop -row 0 -column 10 \
		-pady 2 \
		-padx 3
		
		
		grid $wfstation.tv_station -in $wfstation -row 0 -column 0 \
		-sticky nesw
		grid $wfstation.sb_station -in $wfstation -row 0 -column 1 \
		-sticky ns
		
		grid $wfbottom.b_save -in $wfbottom -row 0 -column 0 \
		-pady 7
		
		grid $wfbottom.b_exit -in $wfbottom -row 0 -column 1 \
		-padx 3
		
		grid columnconfigure .station 0 -weight 1
		grid columnconfigure $wfstation 0 -weight 1
		grid rowconfigure .station 1 -weight 1
		grid rowconfigure $wfstation 0 -weight 1
		
		autoscroll $wfstation.sb_station
		
		# Subprocs
		
		# Additional Code
		
		set font [ttk::style lookup [$wfstation.tv_station cget -style] -font]
		if {[string trim $font] == {}} {
			set font TkDefaultFont
			puts $::main(debug_msg) "\033\[0;1;33mDebug: station_editUi \033\[0;1;31m::font:: \033\[0m"
		}
		foreach col {station frequency input} name {"Station" "Frequency" "Video input"} {
			$wfstation.tv_station heading $col -text $name
		}
		$wfstation.tv_station heading station -text [mc "Station"]
		$wfstation.tv_station heading frequency -text [mc "Frequency"]
		$wfstation.tv_station heading input -text [mc "Video input"]
		$wfstation.tv_station column station -width [expr [font measure $font $name] + 380]
		$wfstation.tv_station column frequency -width [expr [font measure $font $name] + 20]
		$wfstation.tv_station column input -width [expr [font measure $font $name] + 60]
		$wfstation.tv_station tag configure disabled -foreground red
		if {[file exists "$::option(home)/config/stations_$::option(frequency_table).conf"]} {
			set file "$::option(home)/config/stations_$::option(frequency_table).conf"
			set open_channels_file [open $file r]
			set i 1
			while {[gets $open_channels_file line]!=-1} {
				if {[string trim $line] == {} } continue
					if {[string match #* $line]} {
						set mapped [string map {"#" {}} $line]
						if {[llength $mapped] < 3} {
							lassign $mapped kanal channel
							$wfstation.tv_station insert {} end -values [list "$kanal" [string trim $channel] $::option(video_input)] -tags disabled
						} else {
							lassign $mapped kanal channel input
							$wfstation.tv_station insert {} end -values [list "$kanal" [string trim $channel] $input] -tags disabled
						}
					} else {
						if {[llength $line] < 3} {
							lassign $line kanal channel
							$wfstation.tv_station insert {} end -values [list "$kanal" [string trim $channel] $::option(video_input)]
						} else {
							lassign $line kanal channel input
							$wfstation.tv_station insert {} end -values [list "$kanal" [string trim $channel] $input]
						}
					}
				incr i
			}
			close $open_channels_file
		}
		
		if {[string trim [auto_execok "ivtv-tune"]] == {} || [string trim [auto_execok "v4l2-ctl"]] == {}} {
			$wftop.b_station_search state disabled
			$wftop.b_station_preview state disabled
			log_writeOutTv 2 "Could not detect ivtv-tune or/and v4l2-ctl."
			log_writeOutTv 2 "Check the user guide about system requirements."
		}
		if {[string trim [auto_execok mplayer]] == {}} {
			$wftop.b_station_preview state disabled
			log_writeOutTv 2 "Could not detect MPlayer."
			log_writeOutTv 2 "Check the user guide about system requirements."
		}
		
		bind $wfstation.tv_station <B1-Motion> break
		bind $wfstation.tv_station <Motion> break
		bind $wfstation.tv_station <Double-ButtonPress-1> [list station_itemEdit $wfstation.tv_station]
		bind $wfstation.tv_station <<TreeviewSelect>> [list station_editZap $wfstation.tv_station]
		bind $w <Control-Key-x> [list station_editExit cancel]
		bind $w <Key-F1> [list info_helpHelp]
		
		wm title $w [mc "Station Editor"]
		wm protocol $w WM_DELETE_WINDOW [list station_editExit cancel]
		wm iconphoto $w $::icon_b(seditor)
		wm transient $w .
		if {$::option(tooltips) == 1} {
			if {$::option(tooltips_editor) == 1} {
				settooltip $wftop.b_station_search [mc "Perform an automatic station search.
This will delete all stations currently in the list!"]
				settooltip $wftop.b_station_add [mc "Add a new television station."]
				settooltip $wftop.b_station_delete [mc "Delete selected television station."]
				settooltip $wftop.b_station_activate [mc "(De)Activate selected station.
Deactivated stations will be marked red."]
				settooltip $wftop.b_station_edit [mc "Edit selected station."]
				settooltip $wftop.b_station_up [mc "Move selected item up."]
				settooltip $wftop.b_station_down [mc "Move selected item down."]
				settooltip $wftop.b_station_preview [mc "Preview for selected tv station."]
				settooltip $wfbottom.b_save [mc "Save station list and exit editor."]
				settooltip $wfbottom.b_exit [mc "Exit editor without any changes."]
			}
		}
		set status_tv_playback [tv_callbackMplayerRemote alive]
		if {$status_tv_playback != 1} {
			.station.top_buttons.b_station_preview state pressed
		}
		#~ if {$::option(systray_close) == 1} {
			#~ wm protocol . WM_DELETE_WINDOW {  }
		#~ }
		tkwait visibility $w
		grab $w
		wm minsize .station [winfo width .station] [winfo height .station]
	}
}
