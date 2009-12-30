#       record_scheduler_remote.tcl
#       © Copyright 2007-2010 Christian Rapp <saedelaere@arcor.de>
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

proc record_schedulerPrestart {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_schedulerPrestart \033\[0m \{$handler\}"
	if {"$handler" == "record"} {
		log_writeOutTv 0 "Scheduler initiated prestart sequence for recording."
	} else {
		log_writeOutTv 0 "Initiated prestart sequence for timeshift."
	}
	tv_fileComputePos cancel 
	tv_fileComputeSize cancel
	catch {tv_playbackStop 0 nopic}
	if {[winfo exists .tv.file_play_bar]} {
		destroy .tv.file_play_bar
	}
	if {[winfo exists .tv.l_image]} {
		place forget .tv.l_image
	}
	if {[winfo exists .station]} {
		log_writeOutTv 1 "A recording or timeshift was started while the station editor is open."
		log_writeOutTv 1 "Will close it now, you will loose all your changes."
		if {[winfo exists .station.top_search]} {
			log_writeOutTv 2 "You are running a station search while a recording fired."
			log_writeOutTv 2 "The recording might be screwed up."
			station_search 0 cancel 0 0 0 0
			grab release .station.top_search
			destroy .station.top_search
		}
		if {$::option(systray_mini) == 1} {
			bind . <Unmap> {
				if {[winfo ismapped .] == 0} {
					if {[winfo exists .tray] == 0} {
						main_systemTrayActivate 0
						set ::choice(cb_systray_main) 1
					}
					main_systemTrayMini unmap
				}
			}
		}
		grab release .station
		destroy .station
	}
	if {[winfo exists .config_wizard]} {
		log_writeOutTv 1 "A recording or timeshift was started while the configuration dialog is open."
		log_writeOutTv 1 "Will close it now, you will loose all your changes."
		if {$::option(systray_mini) == 1} {
			bind . <Unmap> {
				if {[winfo ismapped .] == 0} {
					if {[winfo exists .tray] == 0} {
						main_systemTrayActivate 0
						set ::choice(cb_systray_main) 1
					}
					main_systemTrayMini unmap
				}
			}
		}
		grab release .config_wizard
		destroy .config_wizard
	}
	if {[winfo exists .cm]} {
		colorm_exit .cm.f_vscale
	}
	if {$::main(running_recording) != 1} {
		if {[winfo exists .tv.l_anigif] == 0} {
			set img_list [launch_splashAnigif "$::where_is/icons/extras/BigBlackIceRoller.gif"]
			label .tv.l_anigif -image [lindex $img_list 0] -borderwidth 0 -background #000000
			place .tv.l_anigif -in .tv.bg -anchor center -relx 0.5 -rely 0.5
			set img_list_length [llength $img_list]
			after 0 [list launch_splashPlay $img_list $img_list_length 1 .tv.l_anigif]
		} else {
			log_writeOutTv 1 "Animated gif already exists in parent."
			log_writeOutTv 1 "This should not happen!"
		}
	}
	if {[winfo exists .record_wizard]} {
		.record_wizard configure -cursor watch
	}
	if {$::option(rec_allow_sta_change) == 0} {
		log_writeOutTv 1 "Station change not allowed during recording."
		.bottom_buttons.button_channelup state disabled
		.bottom_buttons.button_channeldown state disabled
		.bottom_buttons.button_channeljumpback state disabled
		if {[winfo exists .frame_slistbox] == 1} {
			.frame_slistbox.listbox_slist configure -state disabled
		}
		if {[winfo exists .tv.slist.lb_station] == 1} {
			.tv.slist.lb_station configure -state disabled
		}
		if {[winfo exists .tv.slist_lirc.lb_station] == 1} {
			.tv.slist_lirc.lb_station configure -state disabled
		}
	}
	event_recordStart $handler
	.top_buttons.button_starttv state disabled
	.options_bar.mOptions entryconfigure 1 -state disabled
	.options_bar.mOptions entryconfigure 3 -state disabled
	.options_bar.mHelp entryconfigure 8 -state disabled
}

proc record_scheduler_prestartCancel {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_scheduler_prestartCancel \033\[0m \{$handler\}"
	if {"$handler" != "timeshift"} {
		log_writeOutTv 1 "Prestart sequence for recording has been canceled."
		if {[winfo exists .record_wizard]} {
			.record_wizard configure -cursor arrow
		}
	} else {
		log_writeOutTv 1 "Prestart sequence for timeshift has been canceled."
	}
	. configure -cursor arrow; .tv configure -cursor arrow
	.top_buttons.button_timeshift state !disabled
	.top_buttons.button_timeshift state !pressed
	.top_buttons.button_epg state !disabled
	.top_buttons.button_starttv state !disabled
	.bottom_buttons.button_channelup state !disabled
	.bottom_buttons.button_channeldown state !disabled
	.bottom_buttons.button_channeljumpback state !disabled
	.options_bar.mOptions entryconfigure 1 -state normal
	.options_bar.mOptions entryconfigure 3 -state normal
	.options_bar.mHelp entryconfigure 8 -state normal
	if {[winfo exists .frame_slistbox] == 1} {
		.frame_slistbox.listbox_slist configure -state normal
	}
	if {[winfo exists .tv.slist.lb_station] == 1} {
		.tv.slist.lb_station configure -state normal
	}
	if {[winfo exists .tv.slist_lirc.lb_station] == 1} {
		.tv.slist_lirc.lb_station configure -state normal
	}
	event_recordStop
	if {[winfo exists .tv.l_anigif]} {
		catch {launch_splashPlay cancel 0 0 0}
		catch {place forget .tv.l_anigif}
		catch {destroy .tv.l_anigif}
		place .tv.l_image -relx 0.5 -rely 0.5 -anchor center
	}
}

proc record_schedulerRec {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_schedulerRec \033\[0m \{$handler\}"
	if {"$handler" != "timeshift"} {
		log_writeOutTv 0 "Scheduler initiated record sequence for main application."
	} else {
		log_writeOutTv 0 "Initiated timeshift sequence for main application."
	}
	bind .tv <<pause>> {tv_seek 0 0}
	if {"$handler" != "timeshift"} {
		bind .tv <<start>> {tv_Playback .tv.bg .tv.bg.w record "$::tv(current_rec_file)"}
	} else {
		bind .tv <<start>> {tv_Playback .tv.bg .tv.bg.w timeshift "$::tv(current_rec_file)"}
	}
	if {"$handler" != "timeshift"} {
		if {[file exists "$::option(where_is_home)/config/current_rec.conf"]} {
			set open_f [open "$::option(where_is_home)/config/current_rec.conf" r]
			while {[gets $open_f line]!=-1} {
				if {[string trim $line] == {}} continue
				lassign $line station sdate stime edate etime duration ::tv(current_rec_file)
			}
		} else {
			log_writeOutTv 2 "Fatal, could not detect current_rec.conf"
		}
	}
	if {[winfo exists .tray]} {
		if {"$handler" != "timeshift"} {
			settooltip .tray [mc "Currently recording %
Started at %" [lindex $::station(last) 0] $stime]
		} else {
			settooltip .tray [mc "Timeshift %" [lindex $::station(last) 0]]
		}
	}
	if {"$handler" != "timeshift"} {
		wm title .tv [mc "Recording % - Started at %" [lindex $::station(last) 0] $stime]
		wm iconphoto .tv $::icon_b(record)
	} else {
		wm title .tv [mc "Timeshift %" [lindex $::station(last) 0]]
		wm iconphoto .tv $::icon_b(timeshift)
	}
	if {"$handler" != "timeshift"} {
		catch {tv_Playback .tv.bg .tv.bg.w record "$::tv(current_rec_file)"}
	} else {
		catch {tv_Playback .tv.bg .tv.bg.w timeshift "$::tv(current_rec_file)"}
	}
	. configure -cursor arrow; .tv configure -cursor arrow
	if {"$handler" != "timeshift"} {
		if {[winfo exists .record_wizard]} {
			.record_wizard configure -cursor arrow
			.record_wizard.status_frame.l_rec_current_info configure -text [mc "% -- ends % at %" $station $edate $etime]
			.record_wizard.status_frame.b_rec_current state !disabled
			foreach ritem [split [.record_wizard.tree_frame.tv_rec children {}]] {
				.record_wizard.tree_frame.tv_rec delete $ritem
			}
			if {[file exists "$::option(where_is_home)/config/scheduled_recordings.conf"]} {
				set f_open [open "$::option(where_is_home)/config/scheduled_recordings.conf" r]
				while {[gets $f_open line]!=-1} {
					if {[string trim $line] == {} || [string match #* $line]} continue
					.record_wizard.tree_frame.tv_rec insert {} end -values [list [lindex $line 0] [lindex $line 1] [lindex $line 2] [lindex $line 3] [lindex $line 4] [lindex $line 5] [lindex $line 6]]
				}
			}
		}
		if {$::main(running_recording) == 1} {
			set timed [clock format [clock scan $edate] -format "%Y%m%d"]
			set timet [clock format [clock scan $etime] -format "%H%M%S"]
			set dt [expr {([clock scan $timed\T$timet]-[clock seconds])*1000}]
			set ::record(after_prestop_id) [after $dt {record_schedulerPreStop record}]
		} else {
			set ::record(after_prestop_id) [after [expr {$duration * 1000}] {record_schedulerPreStop record}]
		}
	}
}

proc record_schedulerStation {station number} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_schedulerStation \033\[0m \{$station\} \{$number\}"
	log_writeOutTv 0 "Scheduler initiated station sequence for main application."
	set ::station(old) "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
	set ::station(last) "\{$station\} $::kanalcall($number) $number"
	.label_stations configure -text "[lindex $::station(last) 0]"
}

proc record_schedulerPreStop {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_schedulerPreStop \033\[0m \{$handler\}"
	if {"$handler" != "timeshift"} {
		log_writeOutTv 0 "Prestop sequence for recording initiated."
		catch {after cancel $::record(after_prestop_id)}
		unset -nocomplain ::record(after_prestop_id)
		set status_recordlinkread [catch {file readlink "$::option(where_is_home)/tmp/record_lockfile.tmp"} resultat_recordlinkread]
		if { $status_recordlinkread == 0 } {
			catch {exec ps -eo "%p"} read_ps
			set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
			if { $status_greppid_record == 0 } {
				log_writeOutTv 0 "There is an active recording (PID $resultat_recordlinkread)."
				catch {exec kill $resultat_greppid_record}
				catch {file delete -force "$::option(where_is_home)/tmp/record_lockfile.tmp"}
				after 3000 {
					puts $::data(comsocket) "tv-viewer_scheduler scheduler_zombie"
				}
			}
		}
	} else {
		log_writeOutTv 0 "Prestop sequence for timeshift initiated."
	}
	.top_buttons.button_timeshift state !disabled
	.top_buttons.button_epg state !disabled
	.top_buttons.button_starttv state !disabled
	.bottom_buttons.button_channelup state !disabled
	.bottom_buttons.button_channeldown state !disabled
	.bottom_buttons.button_channeljumpback state !disabled
	.options_bar.mOptions entryconfigure 1 -state normal
	.options_bar.mOptions entryconfigure 3 -state normal
	.options_bar.mHelp entryconfigure 8 -state normal
	if {[winfo exists .frame_slistbox] == 1} {
		.frame_slistbox.listbox_slist configure -state normal
	}
	if {[winfo exists .tv.slist.lb_station] == 1} {
		.tv.slist.lb_station configure -state normal
	}
	if {[winfo exists .tv.slist_lirc.lb_station] == 1} {
		.tv.slist_lirc.lb_station configure -state normal
	}
	event_recordStop
	if {[wm attributes .tv -fullscreen] == 1} {
		bind .tv.bg.w <Motion> {tv_wmCursorHide .tv.bg.w 0}
		bind .tv.bg <Motion> {tv_wmCursorHide .tv.bg 0}
	}
	if {"$handler" != "timeshift"} {
		if {[winfo exists .record_wizard] == 1} {
			.record_wizard.status_frame.l_rec_current_info configure -text "Idle"
			.record_wizard.status_frame.b_rec_current state disabled
		}
	} else {
		if {[winfo exists .tv.file_play_bar.b_save]} {
			if {[file exists "$::option(where_is_home)/tmp/timeshift.mpeg"]} {
				.tv.file_play_bar.b_save state !disabled
				if {$::option(tooltips_player) == 1} {
					set file_size [expr round((([file size "$::option(where_is_home)/tmp/timeshift.mpeg"] / 1024.0) / 1024.0))]
					if {$file_size > 1000} {
						set file_size [expr round($file_size / 1024)]
						set file_size "$file_size GB"
					} else {
						set file_size "$file_size MB"
					}
					settooltip .tv.file_play_bar.b_save "Save timeshift video file
	File size $file_size"
				}
			} else {
				log_writeOutTv 2 "Can not detect timeshift video file."
				log_writeOutTv 2 "Saving timeshift video file not possible"
			}
		}
	}
	if {[winfo exists .tv.l_anigif]} {
		catch {launch_splashPlay cancel 0 0 0}
		catch {place forget .tv.l_anigif}
		catch {destroy .tv.l_anigif}
	}
	tv_fileComputeSize cancel_rec
}

proc record_schedulerRemote {com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_schedulerRemote \033\[0m \{$com\}"
	if {$com == 0} {
		if {[winfo exists .record_wizard]} {
			.record_wizard.status_frame.l_rec_sched_info configure -text [mc "Running"]
			.record_wizard.status_frame.b_rec_sched configure -text [mc "Stop Scheduler"] -command [list record_wizardScheduler .record_wizard.status_frame.b_rec_sched .record_wizard.status_frame.l_rec_sched_info 0]
		}
	}
	if {$com == 1} {
		if {[winfo exists .record_wizard]} {
			.record_wizard.status_frame.l_rec_sched_info configure -text [mc "Stopped"]
			.record_wizard.status_frame.b_rec_sched configure -text [mc "Start Scheduler"] -command [list record_wizardScheduler .record_wizard.status_frame.b_rec_sched .record_wizard.status_frame.l_rec_sched_info 1]
		}
	}
}
