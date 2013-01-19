#!/usr/bin/env tclsh

#       scheduler.tcl
#       © Copyright 2007-2013 Christian Rapp <christianrapp@users.sourceforge.net>
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

set option(appname) tv-viewer_scheduler
set option(root) "[file dirname [file dirname [file normalize [file join [info script] bogus]]]]"
set option(home) "$::env(HOME)/.tv-viewer"
set ::main(debug_msg) [open /dev/null a]
fconfigure $::main(debug_msg) -blocking no -buffering line

source $option(root)/init.tcl

init_pkgReq "0 4"
init_testRoot

if {[file isdirectory "$::option(home)"] == 0} {
	puts "
Fatal error. Could not detect config directory
$::option(home)

Before running the scheduler you have to run the main application.
EXIT 1"
	exit 1
}

# Save the original one so we can chain to it
rename unknown scheduler_unknown

# Provide our own implementation
proc unknown args {
	if {"[lindex $args 0]" == "log_writeOutTv"} {
		set debug_lvl [lindex $args 1]
		set debug_msg [lindex $args 2]
		uplevel 1 [list log_writeOut ::log(schedAppend) $debug_lvl $debug_msg]
		return
	}
	uplevel 1 [list scheduler_unknown {*}$args]
}

proc scheduler_exit {} {
	catch {file delete "$::option(home)/tmp/scheduler_lockfile.tmp"}
	set status_main [monitor_partRunning 1]
	if {[lindex $status_main 0]} {
		command_WritePipe 0 "tv-viewer_main record_wizardExecSchedulerCback 1"
	}
	set status_record [monitor_partRunning 3]
	if {[lindex $status_main 0] == 0 && [lindex $status_record 0] == 0} {
		command_WritePipe 1 "tv-viewer_notifyd notifydExit"
	}
	puts $::log(schedAppend) "#
#
# Stop session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
########################################################################
"
	close $::log(schedAppend)
	catch {close $::data(comsocketRead)}
	catch {close $::data(comsocketWrite)}
	catch {close $::data(comsocketWrite2)}
	set status [monitor_partRunning 1]
	if {[lindex $status 0] == 0} {
		catch {file delete -force "$::option(home)/tmp/ComSocketMain"}
		catch {file delete -force "$::option(home)/tmp/ComSocketSched"}
	}
	db_interfaceClose
	exit 0
}

proc scheduler_GetRecordings {} {
	#Connect to database and get all recordings newer than now
	#subtract 60 secs as record wizard rounds to full minute which may lay up to 60 seconds in the past. Very hacky
	set ts [expr [clock seconds] - 60]
	if {[database exists {SELECT 1 FROM RECORDINGS WHERE DATETIME > :ts}]} {
		database eval {SELECT ID, DATETIME FROM RECORDINGS WHERE DATETIME > :ts} recording {
			scheduler_at $recording(ID) $recording(DATETIME)
		}
	} else {
		log_writeOut ::log(schedAppend) 1 "No recordings in Database match Query. There is nothing to do, scheduler will be terminated."
		scheduler_exit
	}
}

proc scheduler_UpdateRecording {jobid} {
	#read row from db when Reruns > 1 and Rerun != 0
	database eval {SELECT STATION, DATETIME, OUTPUT, DURATION, RERUN, RERUNS, RESOLUTION FROM RECORDINGS WHERE ID = :jobid AND RERUNS > 0 AND RERUN <> 0} recording {
		switch $recording(RERUN) {
			1 {
				#daily repeat
				set datetime [expr $recording(DATETIME) + 86400]
			}
			2 {
				if {[clock format $recording(DATETIME) -format %u] == 5} {
					# on friday replace with next monday
					set datetime [expr $recording(DATETIME) + (86400 * 3)]
				} else {
					set datetime [expr $recording(DATETIME) + 86400]
				}
			}
			3 {
				set datetime [expr $recording(DATETIME) + (86400 * 7)]
			}
		}
		set dt [clock format $datetime -format {%Y%m%d_%H%M}]
		set output "[file dirname $recording(OUTPUT)]/[string map {{ } {}} [string map {{/} {}} $recording(STATION)]]\_$dt\.mpeg"
		set reruns [expr $recording(RERUNS) - 1]
		#database eval {UPDATE RECORDINGS SET DATETIME = :datetime, RERUNS = (RERUNS - 1), OUTPUT = :output WHERE ID = :jobid}
		database transaction {
			database eval {INSERT INTO RECORDINGS (STATION, DATETIME, DURATION, RERUN, RERUNS, RESOLUTION, OUTPUT) VALUES (:recording(STATION), :datetime, :recording(DURATION), :recording(RERUN), :reruns, :recording(RESOLUTION), :output)}
		}
		scheduler_at [database last_insert_rowid] $datetime
		set status_main [monitor_partRunning 1]
		if {[lindex $status_main 0]} {
			command_WritePipe 0 "tv-viewer_main record_linkerWizardReread"
		}
	}
	
	set ts [expr [clock seconds] - 2]
	scheduler_CheckPending $ts
}

proc scheduler_CheckPending {timestamp} {
	log_writeOut ::log(schedAppend) 0 "Checking for pending jobs"
	if {![database exists {SELECT 1 FROM RECORDINGS WHERE DATETIME > :timestamp}]} {
		log_writeOut ::log(schedAppend) 1 "No more pending jobs. Scheduler will be terminated"
		scheduler_exit
	} else {
		set count [database eval {SELECT COUNT(ID) FROM RECORDINGS WHERE DATETIME > :timestamp}]
		log_writeOut ::log(schedAppend) 0 "There are $count Jobs left"
	}
}

proc scheduler_at {jobid datetime} {
	set dt [expr {($datetime - [clock seconds]) * 1000}]
	lappend ::scheduler(at_id) [after $dt [list scheduler_rec_prestart $jobid]]
	log_writeOut ::log(schedAppend) 0 "Job number $jobid will be recorded at [clock format $datetime -format {%Y-%m-%d %H:%M:%S}]"
}

proc scheduler_rec_prestart {jobid} {
	log_writeOut ::log(schedAppend) 0 "Attempting to record Job $jobid."
	set status_record [monitor_partRunning 3]
	if {[lindex $status_record 0] == 1} {
		log_writeOut ::log(schedAppend) 2 "There is an active recording."
		log_writeOut ::log(schedAppend) 2 "Can't record job $jobid"
		set status [monitor_partRunning 1]
		if {[lindex $status 0]} {
			command_WritePipe 0 "tv-viewer_main record_linkerPrestartCancel record"
		}
		return
	}
	set status_time [monitor_partRunning 4]
	if {[lindex $status_time 0] == 1} {
		log_writeOut ::log(schedAppend) 1 "Scheduler detected timeshift process."
		log_writeOut ::log(schedAppend) 1 "Will stop timeshift!"
		command_WritePipe 0 "tv-viewer_main timeshift .ftoolb_Top.bTimeshift"
	}
	
	if {[file exists $::option(video_device)] == 0} {
		log_writeOut ::log(schedAppend) 2 "Can not detect Video Device $::option(video_device)"
		log_writeOut ::log(schedAppend) 2 "Have a look into the preferences and change it."
		return
	}
	set status_main [monitor_partRunning 1]
	if {[lindex $status_main 0]} {
		log_writeOut ::log(schedAppend) 0 "Scheduler detected TV-Viewer is running, sending commands via socket."
		command_WritePipe 0 "tv-viewer_main record_linkerPrestart record"
	}
	stream_videoStandard 0
	database eval {SELECT STATION, RESOLUTION FROM RECORDINGS WHERE ID = :jobid} recording {
		set dimensions [string map {{/} { }} $recording(RESOLUTION)]
	}
	catch {exec v4l2-ctl --device=$::option(video_device) --set-fmt-video=width=[lindex $dimensions 0],height=[lindex $dimensions 1]}
	if {$::option(streambitrate) == 1} {
		stream_vbitrate
	}
	if {$::option(temporal_filter) == 1} {
		stream_temporal
	}
	stream_colormControls
	catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=mute=0}
	if {$::option(audio_v4l2) == 1} {
		stream_audioV4l2
	}
	set match 0
	for {set i 1} {$i <= $::station(max)} {incr i} {
		if {"$recording(STATION)" == "$::kanalid($i)"} {
			set ::scheduler(change_inputLoop_id) [after 100 [list scheduler_change_inputLoop 0 $i $jobid]]
			set match 1
			break
		}
	}
	if {$match == 0} {
		set status [monitor_partRunning 1]
		if {[lindex $status 0]} {
			command_WritePipe 0 "tv-viewer_main record_linkerPrestartCancel record"
		}
		log_writeOut ::log(schedAppend) 2 "Station \{$recording(STATION)\} does not exist."
		log_writeOut ::log(schedAppend) 2 "Can't record job $jobid"
		set ts [clock seconds]
		scheduler_CheckPending $ts
	}
}

proc scheduler_rec {jobid counter rec_pid} {
	if {$counter == 10} {
		log_writeOut ::log(schedAppend) 2 "Scheduler tried for 30 seconds to record Job $jobid"
		log_writeOut ::log(schedAppend) 2 "This was unsuccessful."
		set status [monitor_partRunning 1]
		if {[lindex $status 0]} {
			command_WritePipe 0 "tv-viewer_main record_linkerPrestartCancel record"
		}
		catch {exec ""}
		set ts [clock seconds]
		scheduler_CheckPending $ts
		return
	}
	
	database eval {SELECT OUTPUT, DURATION FROM RECORDINGS WHERE ID = :jobid} recording {
		#select recording with ID jobid
	}
	
	if {[file exists "$recording(OUTPUT)"]} {
		if {[file size "$recording(OUTPUT)"] > 0} {
			log_writeOut ::log(schedAppend) 0 "Recording of job $jobid started successfully."
			log_writeOut ::log(schedAppend) 0 "Recorder process PID $rec_pid"
			catch {exec ln -s "$rec_pid" "$::option(home)/tmp/record_lockfile.tmp"}
			database transaction {
				database eval {UPDATE RECORDINGS SET RUNNING = 0 WHERE RUNNING = 1}
				database eval {UPDATE RECORDINGS SET RUNNING = 1 WHERE ID = :jobid}
			}
			after [expr $recording(DURATION) * 1000] {catch {exec ""}}
			set status [monitor_partRunning 1]
			if {[lindex $status 0]} {
				command_WritePipe 0 "tv-viewer_main record_linkerRec record"
				command_WritePipe 1 "tv-viewer_notifyd notifydId"
				command_WritePipe 1 [list tv-viewer_notifyd notifydUi 1 $::option(notifyPos) $::option(notifyTime) 0 " " "Recording started" "Recording of job % started successfully" $jobid]
			} else {
				command_WritePipe 1 "tv-viewer_notifyd notifydId"
				command_WritePipe 1 [list tv-viewer_notifyd notifydUi 1 $::option(notifyPos) $::option(notifyTime) 1 "Start TV-Viewer" "Recording started" "Recording of job % started successfully" $jobid]
			}
			scheduler_UpdateRecording $jobid
		} else {
			catch {exec kill $rec_pid}
			catch {exec ""}
			if {$::option(tclkit) == 1} {
				set rec_pid [exec $::option(tclkit_path) $::option(root)/recorder.tcl $recording(OUTPUT) $::option(video_device) $recording(DURATION) $jobid &]
			} else {
				set rec_pid [exec "$::option(root)/recorder.tcl" $recording(OUTPUT) $::option(video_device) $recording(DURATION) $jobid &]
			}
			incr counter
			after 3000 [list scheduler_rec $jobid $counter $rec_pid]
		}
	} else {
		catch {exec kill $rec_pid}
		catch {exec ""}
		log_writeOut ::log(schedAppend) 2 "File $recording(OUTPUT) doesn't exist."
		log_writeOut ::log(schedAppend) 2 "Can't record job $jobid"
		set status [monitor_partRunning 1]
		if {[lindex $status 0]} {
			command_WritePipe 0 "tv-viewer_main record_linkerPrestartCancel record"
		}
		set ts [clock seconds]
		scheduler_CheckPending $ts
		return
	}
}

proc scheduler_change_inputLoop {secs snumber jobid} {
	if {"$secs" == "cancel"} {
		if {[info exists ::scheduler(change_inputLoop_id)]} {
			foreach id [split $::scheduler(change_inputLoop_id)] {
				after cancel $id
			}
		}
		unset -nocomplain ::scheduler(change_inputLoop_id)
		return
	}
	if {$secs == 3000} {
		log_writeOut ::log(schedAppend) 2 "Waited 3 seconds to change video input to $::kanalinput($snumber)."
		log_writeOut ::log(schedAppend) 2 "This didn't work, BAD."
		set status [monitor_partRunning 1]
		if {[lindex $status 0]} {
			command_WritePipe 0 "tv-viewer_main record_linkerPrestartCancel record"
		}
		set ts [clock seconds]
		scheduler_CheckPending $ts
		return
	}
	catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
	set status_grep_input [catch {agrep -m "$read_vinput" video} resultat_grep_input]
	if {$status_grep_input == 0} {
		if {$::kanalinput($snumber) == [lindex $resultat_grep_input 3]} {
			if {$::kanalext($snumber) == 0} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$::kanalcall($snumber)}
			} else {
				if {$::kanalextfreq($snumber) != 0} {
					catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$::kanalextfreq($snumber)}
				}
				catch {exec {*}$::kanalext($snumber) &}
			}
			set status [monitor_partRunning 1]
			if {[lindex $status 0]} {
				command_WritePipe 0 "tv-viewer_main record_linkerStationMain {$::kanalid($snumber)} $snumber"
			}
			set last_channel_conf "$::option(home)/config/lastchannel.conf"
			set last_channel_write [open $last_channel_conf w]
			puts -nonewline $last_channel_write "\{$::kanalid($snumber)\} $::kanalcall($snumber) $snumber"
			close $last_channel_write
			catch {file delete "$::option(home)/tmp/record_lockfile.tmp"}
			database eval {SELECT OUTPUT, DURATION FROM RECORDINGS WHERE ID = :jobid} recording {
				#select recording with ID jobid
			}
			if {$::option(tclkit) == 1} {
				set rec_pid [exec $::option(tclkit_path) $::option(root)/recorder.tcl $recording(OUTPUT) $::option(video_device) $recording(DURATION) $jobid &]
			} else {
				set rec_pid [exec "$::option(root)/recorder.tcl" $recording(OUTPUT) $::option(video_device) $recording(DURATION) $jobid &]
			}
			log_writeOut ::log(schedAppend) 0 "Recorder has been executed for Job $jobid."
			after 3000 [list scheduler_rec $jobid 0 $rec_pid]
		} else {
			catch {exec v4l2-ctl --device=$::option(video_device) --set-input=$::kanalinput($snumber)}
			log_writeOut ::log(schedAppend) 0 "Trying to change video input to $::kanalinput($snumber)..."
			set ::scheduler(change_inputLoop_id) [after 100 [list scheduler_change_inputLoop [expr $secs + 100] $snumber $jobid]]
		}
	} else {
		log_writeOut ::log(schedAppend) 2 "Can not change video input to $::kanalinput($snumber)."
		log_writeOut ::log(schedAppend) 2 "$resultat_grep_input."
		set status [monitor_partRunning 1]
		if {[lindex $status 0]} {
			command_WritePipe 0 "tv-viewer_main record_linkerPrestartCancel record"
		}
		set ts [clock seconds]
		scheduler_CheckPending $ts
		return
	}
}

proc scheduler_zombie {} {
	catch {exec ""}
}

proc scheduler_main_loop {} {
	set ::scheduler(mainLoop_id) [after 20000 [list scheduler_main_loop]]
}

proc scheduler_Init {handler} {
	if {$handler == 0} {
		init_tclKit
		init_source "$::option(root)" "release_version.tcl agrep.tcl monitor.tcl process_config.tcl stream.tcl difftime.tcl command_socket.tcl log_viewer.tcl process_station_file.tcl db_interface.tcl"
		init_lock "scheduler_lockfile.tmp" "scheduler.tcl" "tv-viewer_scheduler"
		process_configRead
		log_viewerPrepareFileSocket scheduler.log ::log(schedAppend) log_size_scheduler
		command_socket
		set status [monitor_partRunning 1]
		if {[lindex $status 0]} {
			command_WritePipe 0 "tv-viewer_main record_wizardExecSchedulerCback 0"
		}
		if {$::option(notify)} {
			set status_notify [monitor_partRunning 5]
			if {[lindex $status_notify 0] == 0} {
				if {$::option(tclkit) == 1} {
					set ntfy_pid [exec $::option(tclkit_path) $::option(root)/notifyd.tcl &]
				} else {
					set ntfy_pid [exec $::option(root)/notifyd.tcl &]
				}
				log_writeOut ::log(schedAppend) 0 "notification daemon started, PID $ntfy_pid"
			}
		}
		process_StationFile ::log(schedAppend)
		db_interfaceInit
		scheduler_GetRecordings
		scheduler_main_loop
	} else {
		process_configRead
		process_StationFile ::log(schedAppend)
		log_writeOut ::log(schedAppend) 1 "Scheduler has been reinitiated."
		if {[info exists ::scheduler(at_id)]} {
			foreach at $::scheduler(at_id) {
				catch {after cancel $at}
			}
			unset -nocomplain ::scheduler(at_id)
		}
		if {[info exists ::scheduler(mainLoop_id)]} {
			foreach id $::scheduler(mainLoop_id) {
				catch {after cancel $id}
			}
			unset -nocomplain ::scheduler(mainLoop_id)
		}
		scheduler_GetRecordings
		scheduler_main_loop
	}
}

scheduler_Init 0

vwait forever
