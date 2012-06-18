#       record_linker.tcl
#       © Copyright 2007-2012 Christian Rapp <christianrapp@users.sourceforge.net>
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
		log_writeOut ::log(tvAppend) 0 "Scheduler initiated prestart sequence for recording."
	} else {
		log_writeOut ::log(tvAppend) 0 "Initiated prestart sequence for timeshift."
	}
	vid_fileComputePos cancel 
	vid_fileComputeSize cancel
	catch {vid_playbackStop 0 nopic}
	if {[winfo exists .fvidBg.l_bgImage]} {
		place forget .fvidBg.l_bgImage
	}
	if {[winfo exists .station]} {
		log_writeOut ::log(tvAppend) 1 "A recording or timeshift was started while the station editor is open."
		log_writeOut ::log(tvAppend) 1 "Will close it now, you will loose all your changes."
		if {[winfo exists .station.top_search]} {
			log_writeOut ::log(tvAppend) 2 "You are running a station search while a recording fired."
			log_writeOut ::log(tvAppend) 2 "The recording might be screwed up."
			if {$::option(log_warnDialogue)} {
				status_feedbWarn 1 2 [mc "Station search running while a recording fired"]
			}
			station_search 0 cancel 0 0 0 0
			grab release .station.top_search
			destroy .station.top_search
		}
		vid_wmCursor 1
		grab release .station
		destroy .station
	}
	if {[winfo exists .config_wizard]} {
		log_writeOut ::log(tvAppend) 1 "A recording or timeshift was started while the configuration dialog is open."
		log_writeOut ::log(tvAppend) 1 "Will close it now, you will loose all your changes."
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
			log_writeOut ::log(tvAppend) 1 "Animated gif already exists in parent."
			log_writeOut ::log(tvAppend) 1 "This should not happen!"
		}
	}
	if {[winfo exists .record_wizard]} {
		.record_wizard configure -cursor watch
	}
	if {$::option(rec_allow_sta_change) == 0} {
		log_writeOut ::log(tvAppend) 1 "Station change not allowed during recording."
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
		log_writeOut ::log(tvAppend) 1 "Prestart sequence for recording has been canceled."
	} else {
		log_writeOut ::log(tvAppend) 1 "Prestart sequence for timeshift has been canceled."
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
		log_writeOut ::log(tvAppend) 0 "Scheduler initiated record sequence for main application."
	} else {
		log_writeOut ::log(tvAppend) 0 "Initiated timeshift sequence for main application."
	}
	bind . <<pause>> {vid_seek 0 0}
	if {"$handler" != "timeshift"} {
		bind . <<start>> {vid_Playback .fvidBg .fvidBg.cont record "$::vid(current_rec_file)"}
	} else {
		bind . <<start>> {vid_Playback .fvidBg .fvidBg.cont timeshift "$::vid(current_rec_file)"}
	}
	if {"$handler" != "timeshift"} {
		set activeRec [db_interfaceGetActiveRec]
		if {"$activeRec" != ""} {
			set rec(ID) [lindex $activeRec 0]
			set rec(STATION) [lindex $activeRec 1]
			set rec(DATETIME) [lindex $activeRec 2]
			set rec(DURATION) [lindex $activeRec 3]
			set rec(RERUN) [lindex $activeRec 4]
			set rec(RERUNS) [lindex $activeRec 5]
			set rec(RESOLUTION) [lindex $activeRec 6]
			set rec(OUTPUT) [lindex $activeRec 7]
			set rec(RUNNING) [lindex $activeRec 8]
			set rec(TIMESTAMP) [lindex $activeRec 9]
			set ::vid(current_rec_file) $rec(OUTPUT)
		} else {
			log_writeOut ::log(tvAppend) 2 "Although there is an active recording no database entry is marked as running"
			log_writeOut ::log(tvAppend) 2 "You may want to report this incident."
			if {$::option(log_warnDialogue)} {
				status_feedbWarn 1 0 [mc "Database inconsistent"]
			}
		}
	}
	if {[winfo exists .tray]} {
		if {"$handler" != "timeshift"} {
			settooltip .tray [mc "Recording \"%\"

Started: %
Ends:    %" $rec(STATION) [clock format $rec(DATETIME) -format {%Y-%m-%d %H:%M:%S}] [clock format [expr $rec(DATETIME) + $rec(DURATION)] -format {%Y-%m-%d %H:%M:%S}]]
		} else {
			settooltip .tray [mc "Timeshift %" [lindex $::station(last) 0]]
		}
	}
	if {"$handler" != "timeshift"} {
		status_feedbMsgs 1 [mc "Recording % - Ends at % %" $rec(STATION) [clock format $rec(DATETIME) -format {%Y-%m-%d}] [clock format [expr $rec(DATETIME) + $rec(DURATION)] -format {%H:%M:%S}]]
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
			.record_wizard.status_frame.l_rec_current_station configure -text [mc "Station
%" $rec(STATION)]
			.record_wizard.status_frame.l_rec_current_start configure -text [mc "Started
at %" [clock format $rec(DATETIME) -format {%Y-%m-%d %H:%M:%S}]]
			.record_wizard.status_frame.l_rec_current_end configure -text [mc "Ends
at %" [clock format [expr $rec(DATETIME) + $rec(DURATION)] -format {%Y-%m-%d %H:%M:%S}]]
			.record_wizard.status_frame.lf_status.f_btn.b_rec_current state !disabled
			record_linkerWizardReread
		}
		if {$::main(running_recording) == 1} {
			set dt [expr {(($rec(DATETIME) + $rec(DURATION)) - [clock seconds]) * 1000}]
			set ::record(after_prestop_id) [after $dt {record_linkerPreStop record}]
		} else {
			set ::record(after_prestop_id) [after [expr {$rec(DURATION) * 1000}] {record_linkerPreStop record}]
		}
	}
}

proc record_linkerWizardReread {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_linkerWizardReread \033\[0m"
	if {[winfo exists .record_wizard]} {
		foreach ritem [split [.record_wizard.tree_frame.cv.f.tv_rec children {}]] {
			.record_wizard.tree_frame.cv.f.tv_rec delete $ritem
		}
		set ts [clock seconds]
		database eval {SELECT * FROM RECORDINGS WHERE DATETIME > :ts} recording {
			.record_wizard.tree_frame.cv.f.tv_rec insert {} end -values [list $recording(ID) $recording(STATION) [clock format $recording(DATETIME) -format {%H:%M}] [clock format $recording(DATETIME) -format {%Y-%m-%d}] [clock format $recording(DURATION) -format {%H:%M:%S} -timezone :UTC] $recording(RERUN) $recording(RERUNS) $recording(RESOLUTION) $recording(OUTPUT)]
		}
	}
}

proc record_linkerStationMain {station number} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_linkerStationMain \033\[0m \{$station\} \{$number\}"
	#Main is running while scheduler started a recording. Now make sure to adapt the new station settings. Scheduler may have changed station. 
	log_writeOut ::log(tvAppend) 0 "Scheduler initiated station sequence for main application."
	set ::station(old) "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
	set ::station(last) "\{$station\} $::kanalcall($number) $number"
}

proc record_linkerPreStop {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_linkerPreStop \033\[0m \{$handler\}"
	#Recording / timeshift has been finished, set all widgets and functions to standard behaviour, so one can start tv playback again for example. 
	if {"$handler" != "timeshift"} {
		log_writeOut ::log(tvAppend) 0 "Prestop sequence for recording initiated."
		catch {after cancel $::record(after_prestop_id)}
		unset -nocomplain ::record(after_prestop_id)
		set status_record [monitor_partRunning 3]
		if {[lindex $status_record 0] == 1} {
			log_writeOut ::log(tvAppend) 0 "There is an active recording (PID [lindex $status_record 1])."
			catch {exec kill [lindex $status_record 1]}
			catch {file delete -force "$::option(home)/tmp/record_lockfile.tmp"}
			after 3000 {
				command_WritePipe 0 "tv-viewer_scheduler scheduler_zombie"
			}
		}
	} else {
		log_writeOut ::log(tvAppend) 0 "Prestop sequence for timeshift initiated."
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
	set fileSplit [file split [file normalize $::vid(current_rec_file)]]
	set fileSplitReformatted "[lindex $fileSplit 0][lindex $fileSplit 1]/../[lindex $fileSplit end]"
	status_feedbMsgs 3 [mc "Playing file: %" $fileSplitReformatted]
	if {"$handler" != "timeshift"} {
		if {[winfo exists .record_wizard] == 1} {
			.record_wizard.status_frame.l_rec_current_station configure -text [mc "Idle"]
			.record_wizard.status_frame.l_rec_current_start configure -text ""
			.record_wizard.status_frame.l_rec_current_end configure -text ""
			.record_wizard.status_frame.lf_status.f_btn.b_rec_current state disabled
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
			log_writeOut ::log(tvAppend) 2 "Can not detect timeshift video file."
			log_writeOut ::log(tvAppend) 2 "Saving timeshift video file not possible"
			if {$::option(log_warnDialogue)} {
				status_feedbWarn 1 0 [mc "Missing file $::option(timeshift_path)/timeshift.mpeg"]
			}
		}
	}
	if {[winfo exists .fvidBg.l_anigif]} {
		catch {launch_splashPlay cancel 0 0 0}
		catch {place forget .fvidBg.l_anigif}
		catch {destroy .fvidBg.l_anigif}
	}
	vid_fileComputeSize cancel_rec
}
