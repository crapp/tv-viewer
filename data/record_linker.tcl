#       record_linker.tcl
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

proc record_linkerPrestart {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_linkerPrestart \033\[0m \{$handler\}"
	#Prestart means deactivate everything that could interfere with a starting recording or timeshift.
	set ::record(handler) $handler
	if {"$handler" == "record"} {
		log_writeOutTv 0 "Scheduler initiated prestart sequence for recording."
	} else {
		log_writeOutTv 0 "Initiated prestart sequence for timeshift."
	}
	vid_fileComputePos cancel 
	vid_fileComputeSize cancel
	catch {vid_playbackStop 0 nopic}
	if {[winfo exists .fvidBg.l_bgImage]} {
		place forget .fvidBg.l_bgImage
	}
	if {[winfo exists .station]} {
		log_writeOutTv 1 "A recording or timeshift was started while the station editor is open."
		log_writeOutTv 1 "Will close it now, you will loose all your changes."
		if {[winfo exists .station.top_search]} {
			log_writeOutTv 2 "You are running a station search while a recording fired."
			log_writeOutTv 2 "The recording might be screwed up."
			station_search 0 cancel 0 0 0 0
			#FIXME Does station editor make a grab?
			grab release .station.top_search
			destroy .station.top_search
		}
		#~ if {$::option(systray_close) == 1} {
			#~ wm protocol . WM_DELETE_WINDOW {main_systemTrayTogglePre}
		#~ }
		grab release .station
		destroy .station
	}
	if {[winfo exists .config_wizard]} {
		log_writeOutTv 1 "A recording or timeshift was started while the configuration dialog is open."
		log_writeOutTv 1 "Will close it now, you will loose all your changes."
		#~ if {$::option(systray_close) == 1} {
			#~ wm protocol . WM_DELETE_WINDOW {main_systemTrayTogglePre}
		#~ }
		grab release .config_wizard
		destroy .config_wizard
	}
	if {[winfo exists .cm]} {
		colorm_exit .cm.f_vscale
	}
	if {$::main(running_recording) != 1} {
		if {[winfo exists .fvidBg.l_anigif] == 0} {
			set img_list [launch_splashAnigif "$::option(root)/icons/extras/BigBlackIceRoller.gif"]
			label .fvidBg.l_anigif -image [lindex $img_list 0] -borderwidth 0 -background #000000
			place .fvidBg.l_anigif -in .fvidBg -anchor center -relx 0.5 -rely 0.5
			set img_list_length [llength $img_list]
			after 0 [list launch_splashPlay $img_list $img_list_length 1 .fvidBg.l_anigif]
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
		.ftoolb_ChanCtrl.bChanDown state disabled
		.ftoolb_ChanCtrl.bChanUp state disabled
		.ftoolb_ChanCtrl.bChanJump state disabled
		.foptions_bar.mbNavigation.mNavigation entryconfigure 1 -state disabled
		.foptions_bar.mbNavigation.mNavigation entryconfigure 2 -state disabled
		.foptions_bar.mbNavigation.mNavigation entryconfigure 3 -state disabled
		.fvidBg.mContext.mNavigation entryconfigure 1 -state disabled
		.fvidBg.mContext.mNavigation entryconfigure 2 -state disabled
		.fvidBg.mContext.mNavigation entryconfigure 3 -state disabled
		if {[winfo exists .fstations] == 1} {
			main_frontendDisableTree .fstations.treeSlist 1
		}
		if {[winfo exists .tv.slist.lb_station] == 1} {
			.tv.slist.lb_station configure -state disabled
		}
		if {[winfo exists .tv.slist_lirc.lb_station] == 1} {
			.tv.slist_lirc.lb_station configure -state disabled
		}
	}
	event_recordStart $handler
	.ftoolb_Top.bTv state disabled
	.foptions_bar.mbTvviewer.mTvviewer entryconfigure 1 -state disabled
	.foptions_bar.mbTvviewer.mTvviewer entryconfigure 3 -state disabled
	.foptions_bar.mbHelp.mHelp entryconfigure 8 -state disabled
}

proc record_linkerPrestartCancel {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_linkerPrestartCancel \033\[0m \{$handler\}"
	#Undo everything that was done by record_linkerPrestart in case starting of timeshift / recording failed.
	if {"$handler" != "timeshift"} {
		log_writeOutTv 1 "Prestart sequence for recording has been canceled."
	} else {
		log_writeOutTv 1 "Prestart sequence for timeshift has been canceled."
	}
	if {[winfo exists .record_wizard]} {
		.record_wizard configure -cursor arrow
	}
	.ftoolb_Top.bTimeshift state !disabled
	.ftoolb_Top.bTimeshift state !pressed
	.ftoolb_Top.bTv state !disabled
	.ftoolb_ChanCtrl.bChanDown state !disabled
	.ftoolb_ChanCtrl.bChanUp state !disabled
	.ftoolb_ChanCtrl.bChanJump state !disabled
	.foptions_bar.mbNavigation.mNavigation entryconfigure 1 -state normal
	.foptions_bar.mbNavigation.mNavigation entryconfigure 2 -state normal
	.foptions_bar.mbNavigation.mNavigation entryconfigure 3 -state normal
	.fvidBg.mContext.mNavigation entryconfigure 1 -state normal
	.fvidBg.mContext.mNavigation entryconfigure 2 -state normal
	.fvidBg.mContext.mNavigation entryconfigure 3 -state normal
	.foptions_bar.mbTvviewer.mTvviewer entryconfigure 1 -state normal
	.foptions_bar.mbTvviewer.mTvviewer entryconfigure 3 -state normal
	.foptions_bar.mbHelp.mHelp entryconfigure 8 -state normal
	if {[winfo exists .fstations] == 1} {
		main_frontendDisableTree .fstations.treeSlist 0
	}
	if {[winfo exists .tv.slist.lb_station] == 1} {
		.tv.slist.lb_station configure -state normal
	}
	if {[winfo exists .tv.slist_lirc.lb_station] == 1} {
		.tv.slist_lirc.lb_station configure -state normal
	}
	event_recordStop
	if {[winfo exists .fvidBg.l_anigif]} {
		catch {launch_splashPlay cancel 0 0 0}
		catch {place forget .fvidBg.l_anigif}
		catch {destroy .fvidBg.l_anigif}
		place .fvidBg.l_bgImage -relx 0.5 -rely 0.5 -anchor center
	}
}

proc record_linkerRec {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_linkerRec \033\[0m \{$handler\}"
	#When starting of timeshift / recording was succesful, do the appropriate bindings, namings ...
	if {"$handler" != "timeshift"} {
		log_writeOutTv 0 "Scheduler initiated record sequence for main application."
	} else {
		log_writeOutTv 0 "Initiated timeshift sequence for main application."
	}
	bind . <<pause>> {vid_seek 0 0}
	if {"$handler" != "timeshift"} {
		bind . <<start>> {vid_Playback .fvidBg .fvidBg.cont record "$::vid(current_rec_file)"}
	} else {
		bind . <<start>> {vid_Playback .fvidBg .fvidBg.cont timeshift "$::vid(current_rec_file)"}
	}
	if {"$handler" != "timeshift"} {
		if {[file exists "$::option(home)/config/current_rec.conf"]} {
			set open_f [open "$::option(home)/config/current_rec.conf" r]
			while {[gets $open_f line]!=-1} {
				if {[string trim $line] == {}} continue
				lassign $line station sdate stime edate etime duration ::vid(current_rec_file)
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
		.ftoolb_Disp.lDispIcon configure -image $::icon_s(record)
		.ftoolb_Disp.lDispText configure -text [mc "Recording % - Started at %" [lindex $::station(last) 0] $stime]
	} else {
		.ftoolb_Disp.lDispIcon configure -image $::icon_s(record)
		.ftoolb_Disp.lDispText configure -text [mc "Timeshift %" [lindex $::station(last) 0]]
	}
	if {"$handler" != "timeshift"} {
		catch {vid_Playback .fvidBg .fvidBg.cont record "$::vid(current_rec_file)"}
	} else {
		catch {vid_Playback .fvidBg .fvidBg.cont timeshift "$::vid(current_rec_file)"}
	}
	if {[winfo exists .record_wizard]} {
		.record_wizard configure -cursor arrow
	}
	if {"$handler" != "timeshift"} {
		if {[winfo exists .record_wizard]} {
			.record_wizard configure -cursor arrow
			.record_wizard.status_frame.l_rec_current_info configure -text [mc "% -- ends % at %" $station $edate $etime]
			.record_wizard.status_frame.b_rec_current state !disabled
			record_linkerWizardReread
		}
		if {$::main(running_recording) == 1} {
			set timed [clock format [clock scan $edate] -format "%Y%m%d"]
			set timet [clock format [clock scan $etime] -format "%H%M%S"]
			set dt [expr {([clock scan $timed\T$timet]-[clock seconds])*1000}]
			set ::record(after_prestop_id) [after $dt {record_linkerPreStop record}]
		} else {
			set ::record(after_prestop_id) [after [expr {$duration * 1000}] {record_linkerPreStop record}]
		}
	}
}

proc record_linkerWizardReread {} {
	if {[winfo exists .record_wizard]} {
		foreach ritem [split [.record_wizard.tree_frame.tv_rec children {}]] {
			.record_wizard.tree_frame.tv_rec delete $ritem
		}
		if {[file exists "$::option(home)/config/scheduled_recordings.conf"]} {
			set f_open [open "$::option(home)/config/scheduled_recordings.conf" r]
			while {[gets $f_open line]!=-1} {
				if {[string trim $line] == {} || [string match #* $line]} continue
				.record_wizard.tree_frame.tv_rec insert {} end -values [list [lindex $line 0] [lindex $line 1] [lindex $line 2] [lindex $line 3] [lindex $line 4] [lindex $line 5] [lindex $line 6]]
			}
		}
	}
}

proc record_linkerStationMain {station number} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_linkerStationMain \033\[0m \{$station\} \{$number\}"
	#Main is running while scheduler started a recording. Now make sure to adapt the new station settings. Scheduler may have changed station. 
	log_writeOutTv 0 "Scheduler initiated station sequence for main application."
	set ::station(old) "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
	set ::station(last) "\{$station\} $::kanalcall($number) $number"
}

proc record_linkerPreStop {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_linkerPreStop \033\[0m \{$handler\}"
	#Recording / timeshift has been finished, set all widgets and functions to standard behaviour, so one can start tv playback again for example. 
	if {"$handler" != "timeshift"} {
		log_writeOutTv 0 "Prestop sequence for recording initiated."
		catch {after cancel $::record(after_prestop_id)}
		unset -nocomplain ::record(after_prestop_id)
		set status_record [monitor_partRunning 3]
		if {[lindex $status_record 0] == 1} {
			log_writeOutTv 0 "There is an active recording (PID [lindex $status_record 1])."
			catch {exec kill [lindex $status_record 1]}
			catch {file delete -force "$::option(home)/tmp/record_lockfile.tmp"}
			after 3000 {
				command_WritePipe 0 "tv-viewer_scheduler scheduler_zombie"
			}
		}
	} else {
		log_writeOutTv 0 "Prestop sequence for timeshift initiated."
	}
	.ftoolb_Top.bTimeshift state !disabled
	.ftoolb_Top.bTv state !disabled
	.ftoolb_ChanCtrl.bChanDown state !disabled
	.ftoolb_ChanCtrl.bChanUp state !disabled
	.ftoolb_ChanCtrl.bChanJump state !disabled
	.foptions_bar.mbNavigation.mNavigation entryconfigure 1 -state normal
	.foptions_bar.mbNavigation.mNavigation entryconfigure 2 -state normal
	.foptions_bar.mbNavigation.mNavigation entryconfigure 3 -state normal
	.fvidBg.mContext.mNavigation entryconfigure 1 -state normal
	.fvidBg.mContext.mNavigation entryconfigure 2 -state normal
	.fvidBg.mContext.mNavigation entryconfigure 3 -state normal
	.foptions_bar.mbTvviewer.mTvviewer entryconfigure 1 -state normal
	.foptions_bar.mbTvviewer.mTvviewer entryconfigure 3 -state normal
	.foptions_bar.mbHelp.mHelp entryconfigure 8 -state normal
	if {[winfo exists .fstations] == 1} {
		main_frontendDisableTree .fstations.treeSlist 0
	}
	if {[winfo exists .tv.slist.lb_station] == 1} {
		.tv.slist.lb_station configure -state normal
	}
	if {[winfo exists .tv.slist_lirc.lb_station] == 1} {
		.tv.slist_lirc.lb_station configure -state normal
	}
	event_recordStop
	if {[wm attributes . -fullscreen] == 1} {
		bind .fvidBg.cont <Motion> {vid_wmCursorHide .fvidBg.cont 0}
		bind .fvidBg <Motion> {vid_wmCursorHide .fvidBg 0}
	}
	if {"$handler" != "timeshift"} {
		if {[winfo exists .record_wizard] == 1} {
			.record_wizard.status_frame.l_rec_current_info configure -text "Idle"
			.record_wizard.status_frame.b_rec_current state disabled
		}
	} else {
		if {[file exists "$::option(timeshift_path)/timeshift.mpeg"]} {
			.ftoolb_Play.bSave state !disabled
			if {$::option(tooltips_player) == 1} {
				set file_size [expr round((([file size "$::option(timeshift_path)/timeshift.mpeg"] / 1024.0) / 1024.0))]
				if {$file_size > 1000} {
					set file_size [expr round($file_size / 1024)]
					set file_size "$file_size GB"
				} else {
					set file_size "$file_size MB"
				}
				settooltip .ftoolb_Play.bSave "Save timeshift video file
File size $file_size"
			}
		} else {
			log_writeOutTv 2 "Can not detect timeshift video file."
			log_writeOutTv 2 "Saving timeshift video file not possible"
		}
	}
	if {[winfo exists .fvidBg.l_anigif]} {
		catch {launch_splashPlay cancel 0 0 0}
		catch {place forget .fvidBg.l_anigif}
		catch {destroy .fvidBg.l_anigif}
	}
	vid_fileComputeSize cancel_rec
}
