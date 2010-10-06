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
		vid_wmCursor 1
		grab release .station
		destroy .station
	}
	if {[winfo exists .config_wizard]} {
		log_writeOutTv 1 "A recording or timeshift was started while the configuration dialog is open."
		log_writeOutTv 1 "Will close it now, you will loose all your changes."
		vid_wmCursor 1
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
		vid_pmhandlerButton {100 0} {{1 disabled} {2 disabled} {3 disabled}} {100 0}
		vid_pmhandlerMenuNav {{0 disabled} {1 disabled} {2 disabled}} {{0 disabled} {1 disabled} {2 disabled}} 
		vid_pmhandlerMenuTray {{11 disabled} {12 disabled} {13 disabled}}
		if {[winfo exists .fstations] == 1} {
			main_frontendDisableTree .fstations.treeSlist 1
		}
		if {[winfo exists .fvidBg.slist_lirc.lb_station] == 1} {
			.fvidBg.slist_lirc.lb_station configure -state disabled
		}
	}
	event_recordStart $handler
	vid_pmhandlerButton {{4 disabled} {5 disabled}} {100 0} {100 0}
	vid_pmhandlerMenuTv {{0 disabled} {2 disabled} {7 disabled} {8 disabled}} {{4 disabled} {6 disabled} {11 disabled} {12 disabled}}
	vid_pmhandlerMenuHelp {{7 disabled}} 
	vid_pmhandlerMenuTray {{2 disabled} {4 disabled} {8 disabled} {9 disabled}}
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
		.record_wizard configure -cursor left_ptr
	}
	vid_pmhandlerButton {{1 !disabled} {1 !pressed} {4 !disabled} {5 !disabled}} {{1 !disabled} {2 !disabled} {3 !disabled}} {100 0}
	vid_pmhandlerMenuTv {{0 normal} {2 normal} {4 normal} {7 normal} {8 normal}} {{4 normal} {6 normal} {8 normal} {11 normal} {12 normal}}
	vid_pmhandlerMenuNav {{0 normal} {1 normal} {2 normal}} {{0 normal} {1 normal} {2 normal}}
	vid_pmhandlerMenuHelp {{7 normal}}
	vid_pmhandlerMenuTray {{2 normal} {4 normal} {5 normal} {8 normal} {9 normal} {11 normal} {12 normal} {13 normal}}
	if {[winfo exists .fstations] == 1} {
		main_frontendDisableTree .fstations.treeSlist 0
	}
	if {[winfo exists .fvidBg.slist_lirc.lb_station] == 1} {
		.fvidBg.slist_lirc.lb_station configure -state normal
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
Started at %" $station $stime]
		} else {
			settooltip .tray [mc "Timeshift %" [lindex $::station(last) 0]]
		}
	}
	if {"$handler" != "timeshift"} {
		status_feedbMsgs 1 [mc "Recording % - Ends at % %" $station $edate $etime]
	} else {
		status_feedbMsgs 2 [mc "Timeshift %" [lindex $::station(last) 0]]
	}
	if {"$handler" != "timeshift"} {
		set ::vid(recStart) 0;# prevents auto fileplayback of recordings
		vid_Playback .fvidBg .fvidBg.cont record "$::vid(current_rec_file)"
	} else {
		vid_Playback .fvidBg .fvidBg.cont timeshift "$::vid(current_rec_file)"
	}
	if {[winfo exists .record_wizard]} {
		.record_wizard configure -cursor left_ptr
	}
	if {"$handler" != "timeshift"} {
		if {[winfo exists .record_wizard]} {
			.record_wizard configure -cursor left_ptr
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
		foreach ritem [split [.record_wizard.tree_frame.cv.f.tv_rec children {}]] {
			.record_wizard.tree_frame.cv.f.tv_rec delete $ritem
		}
		if {[file exists "$::option(home)/config/scheduled_recordings.conf"]} {
			set f_open [open "$::option(home)/config/scheduled_recordings.conf" r]
			while {[gets $f_open line]!=-1} {
				if {[string trim $line] == {} || [string match #* $line]} continue
				.record_wizard.tree_frame.cv.f.tv_rec insert {} end -values [list [lindex $line 0] [lindex $line 1] [lindex $line 2] [lindex $line 3] [lindex $line 4] [lindex $line 5] [lindex $line 6] [lindex $line 7] [lindex $line 8]]
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
	vid_pmhandlerButton {{1 !disabled} {4 !disabled} {5 !disabled}} {{1 !disabled} {2 !disabled} {3 !disabled}} {100 0}
	vid_pmhandlerMenuTv {{0 normal} {2 normal} {4 normal} {7 normal} {8 normal}} {{4 normal} {6 normal} {8 normal} {11 normal} {12 normal}}
	vid_pmhandlerMenuNav {{0 normal} {1 normal} {2 normal}} {{0 normal} {1 normal} {2 normal}}
	vid_pmhandlerMenuHelp {{7 normal}}
	vid_pmhandlerMenuTray {{2 normal} {4 normal} {5 normal} {8 normal} {9 normal} {11 normal} {12 normal} {13 normal}}
	if {[winfo exists .fstations] == 1} {
		main_frontendDisableTree .fstations.treeSlist 0
	}
	if {[winfo exists .fvidBg.slist_lirc.lb_station] == 1} {
		.fvidBg.slist_lirc.lb_station configure -state normal
	}
	event_recordStop
	status_feedbMsgs 3 [mc "Playing file: %" $::vid(current_rec_file)]
	if {"$handler" != "timeshift"} {
		if {[winfo exists .record_wizard] == 1} {
			.record_wizard.status_frame.l_rec_current_info configure -text "Idle"
			.record_wizard.status_frame.b_rec_current state disabled
		}
	} else {
		if {[file exists "$::option(timeshift_path)/timeshift.mpeg"]} {
			vid_pmhandlerButton {100 0} {100 0} {{10 !disabled}}
			if {$::option(tooltips_main) == 1} {
				set file_size [expr round((([file size "$::option(timeshift_path)/timeshift.mpeg"] / 1024.0) / 1024.0))]
				if {$file_size > 1000} {
					set file_size [expr round($file_size / 1024)]
					set file_size "$file_size GB"
				} else {
					set file_size "$file_size MB"
				}
				settooltip .ftoolb_Play.bSave [mc "Save timeshift video file
File size %" $file_size]
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
