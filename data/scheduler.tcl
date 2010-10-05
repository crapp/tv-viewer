#!/usr/bin/env tclsh

#       scheduler.tcl
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

package require Tcl 8.5

set option(appname) tv-viewer_scheduler
set option(root) "[file dirname [file dirname [file normalize [file join [info script] bogus]]]]"
set option(home) "$::env(HOME)/.tv-viewer"

set root_test "/usr/bin/tv-viewer.tst"
set root_test_open [catch {open $root_test w}]
catch {close $root_test_open}
if {[file exists "/usr/bin/tv-viewer.tst"]} {
	file delete -force "/usr/bin/tv-viewer.tst"
	if { "$::tcl_platform(user)" == "root" } {
		puts "
You are running tv-viewer as root.
This is not recommended!"
		exit 1
	}
}

if {[file isdirectory "$::option(home)"] == 0} {
	puts "
Fatal error. Could not detect config directory
$::option(home)

Before running the scheduler you have to run the main application.
EXIT 1"
	exit 1
}

source $option(root)/release_version.tcl
source $option(root)/agrep.tcl
source $option(root)/monitor.tcl
source $option(root)/process_config.tcl
source $option(root)/main_picqual_stream.tcl
source $option(root)/difftime.tcl
source $option(root)/command_socket.tcl

set status_lock [catch {exec ln -s "[pid]" "$::option(home)/tmp/scheduler_lockfile.tmp"} resultat_lock]
if { $status_lock != 0 } {
	set linkread [file readlink "$::option(home)/tmp/scheduler_lockfile.tmp"]
	catch {exec ps -eo "%p"} read_ps
	set status_greppid [catch {agrep -w "$read_ps" $linkread} resultat_greppid]
	if { $status_greppid != 0 } {
		catch {file delete "$::option(home)/tmp/scheduler_lockfile.tmp"}
		catch {exec ln -s "[pid]" "$::option(home)/tmp/scheduler_lockfile.tmp"}
	} else {
		catch {exec ps -p $linkread -o args=} readarg
		set status_grepargLink [catch {agrep -m "$readarg" "tv-viewer_scheduler"} resultat_greparg]
		set status_grepargDirect [catch {agrep -m "$readarg" "scheduler.tcl"} resultat_greparg]
		if {$status_grepargLink != 0 && $status_grepargDirect != 0} {
			catch {file delete "$::option(home)/tmp/scheduler_lockfile.tmp"}
			catch {exec ln -s "[pid]" "$::option(home)/tmp/scheduler_lockfile.tmp"}
		} else {
			puts "
An instance of the TV-Viewer Scheduler is already running."
			exit 1
		}
	}
}
unset -nocomplain status_lock resultat_lock linkread status_greppid resultat_greppid

# Save the original one so we can chain to it
rename unknown scheduler_unknown

# Provide our own implementation
proc unknown args {
	if {"[lindex $args 0]" == "log_writeOutTv"} {
		set debug_lvl [lindex $args 1]
		set debug_msg [lindex $args 2]
		uplevel 1 [list scheduler_logWriteOut $debug_lvl $debug_msg]
		return
	}
	uplevel 1 [list scheduler_unknown {*}$args]
}

proc scheduler_log {} {
	if {$::option(log_files) == 1} {
		if {[file exists "$::option(home)/log/scheduler.log"]} {
			if {[file size "$::option(home)/log/scheduler.log"] > [expr $::option(log_size_scheduler) * 1000]} {
				catch {file delete "$::option(home)/log/scheduler.log"}
				set logf_sched_open [open "$::option(home)/log/scheduler.log" w]
				puts $logf_sched_open "
########################################################################
# Scheduler logfile. Release version [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]
# Start new session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
#"
				close $logf_sched_open
				set ::logf_sched_open_append [open "$::option(home)/log/scheduler.log" a]
			} else {
				set ::logf_sched_open_append [open "$::option(home)/log/scheduler.log" a]
				puts $::logf_sched_open_append "
########################################################################
# Scheduler logfile. Release version [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]
# Start new session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
#"
				flush $::logf_sched_open_append
			}
		} else {
			set logf_sched_open [open "$::option(home)/log/scheduler.log" w]
			puts $logf_sched_open "
########################################################################
# Scheduler logfile. Release version [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]
# Start new session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
#"
			close $logf_sched_open
			set ::logf_sched_open_append [open "$::option(home)/log/scheduler.log" a]
		}
	} else {
		set ::logf_sched_open_append [open /dev/null a]
	}
	set ::logf_tv_open_append $::logf_sched_open_append
	fconfigure $::logf_sched_open_append -blocking no -buffering line
}

proc scheduler_logWriteOut {handler text} {
	set logformat "#"
	if {$handler == 0} {
		append logformat " \[[clock format [clock scan now] -format {%H:%M:%S}]\] DEBUG: "
	}
	if {$handler == 1} {
		append logformat " \[[clock format [clock scan now] -format {%H:%M:%S}]\] WARNING: "
	}
	if {$handler == 2} {
		append logformat " \[[clock format [clock scan now] -format {%H:%M:%S}]\] ERROR: "
	}
	puts $::logf_sched_open_append "$logformat $text"
	flush $::logf_sched_open_append
}

proc scheduler_stations {} {
	if !{[file exists "$::option(home)/config/stations_$::option(frequency_table).conf"]} {
		scheduler_logWriteOut 2 "No valid stations_$::option(frequency_table).conf"
		scheduler_logWriteOut 2 "Please create one using the Station Editor."
		scheduler_logWriteOut 2 "Make sure you checked the configuration first!"
		scheduler_logWriteOut 2 "Scheduler EXIT 1"
		exit 1
	} else {
		set file "$::option(home)/config/stations_$::option(frequency_table).conf"
		set open_channel_file [open $file r]
		catch {array unset ::kanalid}
		catch {array unset ::kanalcall}
		catch {array unset ::kanalinput}
		catch {array unset ::kanalext}
		set i 1
		while {[gets $open_channel_file line]!=-1} {
			if {[string match #* $line] || [string trim $line] == {} } continue
			if {[llength $line] < 4} {
				if {[llength $line] == 2} {
					lassign $line ::kanalid($i) ::kanalcall($i)
					set ::kanalinput($i) $::option(video_input)
					set ::kanalext($i) 0
				}
				if {[llength $line] == 3} {
					lassign $line ::kanalid($i) ::kanalcall($i) ::kanalinput($i)
					set ::kanalext($i) 0
				}
			} else {
				lassign $line ::kanalid($i) ::kanalcall($i) ::kanalinput($i) ::kanalext($i)
			}
			set ::scheduler(max_stations) $i
			incr i
		}
		close $open_channel_file
		if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
			scheduler_logWriteOut 2 "No valid stations_$::option(frequency_table).conf"
			scheduler_logWriteOut 2 "Please create one using the Station Editor."
			scheduler_logWriteOut 2 "Make sure you checked the configuration first!"
			scheduler_logWriteOut 2 "Scheduler EXIT 1"
			exit 1
		}
	}
}

proc scheduler_exit {} {
	catch {file delete "$::option(home)/tmp/scheduler_lockfile.tmp"}
	puts $::logf_sched_open_append "#
#
# Stop session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
########################################################################
"
	close $::logf_sched_open_append
	set status [monitor_partRunning 1]
	if {[lindex $status 0]} {
		command_WritePipe 0 "tv-viewer_main record_wizardExecSchedulerCback 1"
	}
	catch {close $::data(comsocketRead)}
	catch {close $::data(comsocketWrite)}
	set status [monitor_partRunning 1]
	if {[lindex $status 0] == 0} {
		catch {file delete -force "$::option(home)/tmp/ComSocketMain"}
		catch {file delete -force "$::option(home)/tmp/ComSocketSched"}
	}
	exit 0
}

proc scheduler_recordings {} {
	if {[file exists "$::option(home)/config/scheduled_recordings.conf"]} {
		set f_open [open "$::option(home)/config/scheduled_recordings.conf" r]
		set i 1
		while {[gets $f_open line]!=-1} {
			if {[string trim $line] == {} || [string match #* $line]} continue
			set ::scheduler(max_recordings) $i
			incr i
		}
		close $f_open
		set f_open [open "$::option(home)/config/scheduled_recordings.conf" r]
		set i 1
		while {[gets $f_open line]!=-1} {
			if {[string trim $line] == {} || [string match #* $line] == 1} continue
			set ::recjob($i) $line
			# 0 - JobID; 1 - Station; 2 - time; 3 - Date; 4 - Duration; 5 - Repeat; 6 - Repetitions; 7 - Resolution; 8 - File
			if {"[lindex $::recjob($i) 3]" == "[clock format [clock scan now] -format {%Y-%m-%d}]"} {
				scheduler_at [lindex $::recjob($i) 2] $i
			} else {
				set diffdate [string map {{-} {}} [lindex $::recjob($i) 3]]
				set delta [difftime [clock scan $diffdate] [clock scan [clock format [clock scan now] -format {%Y%m%d}]]]
				lassign $delta dy dm dd
				if {$dy < 0 || $dm < 0 || $dd < 0} {
					scheduler_logWriteOut 1 "Job $::recjob($i) expired."
					scheduler_logWriteOut 1 "Will be deleted."
					lappend deljobs $i
				}
			}
			incr i
		}
		if {[info exists deljobs]} {
			scheduler_delete $deljobs
		}
		if {[array exists ::recjob] == 0} {
			scheduler_logWriteOut 1 "No recordings in config file. Scheduler will be terminated."
			close $f_open
			scheduler_exit
			return
		}
		close $f_open
		set ::scheduler(loop_date) [clock format [clock scan now] -format {%Y%m%d}]
	} else {
		scheduler_logWriteOut 1 "No recordings in config file. Scheduler will be terminated."
		scheduler_exit
	}
}

proc scheduler_at {time jobid} {
	set dt [expr {([clock scan $time]-[clock seconds])*1000}]
	if { $dt >= -600000 } {
		lappend ::scheduler(at_id) [after $dt [list scheduler_rec_prestart $jobid]]
		scheduler_logWriteOut 0 "Job number [lindex $::recjob($jobid) 0] will be recorded today at $time"
	} else {
		scheduler_logWriteOut 1 "Job $::recjob($jobid) expired."
		scheduler_logWriteOut 1 "Will be deleted."
		scheduler_delete $jobid
	}
}

proc scheduler_delete {args} {
	catch {file delete "$::option(home)/config/scheduled_recordings.conf"}
	set f_open [open "$::option(home)/config/scheduled_recordings.conf" w+]
	lappend ::scheduler(delJobList) [join $args]
	set reInit 0
	for {set i 1} {$i <= $::scheduler(max_recordings)} {incr i} {
		if {[lsearch $::scheduler(delJobList) $i] != -1} {
			if {[lindex $::recjob($i) 5] == 1} {
				# daily repeat
				if {[lindex $::recjob($i) 6] == 0} {
					# no more repetitions
					continue
				} else {
					# replace start date
					set ::recjob($i) [lreplace $::recjob($i) 3 3 [clock format [expr [clock scan [lindex $::recjob($i) 3]] + 86400] -format {%Y-%m-%d}]]
					# replace repetitions
					set ::recjob($i) [lreplace $::recjob($i) 6 6 [expr [lindex $::recjob($i) 6] - 1]]
					# replace file name
					set ::recjob($i) [lreplace $::recjob($i) 8 8 [file dirname [lindex $::recjob($i) end]]/[string map {{ } {}} [string map {{/} {}} [lindex $::recjob($i) 1]]]\_[lindex $::recjob($i) 3]\_[string map {{am} {}} [string map {{pm} {}} [string map {{ } {}} [lindex $::recjob($i) 2]]]].mpeg]
					# delete number from list
					set ::scheduler(delJobList) [lreplace $::scheduler(delJobList) [lsearch $::scheduler(delJobList) $i] [lsearch $::scheduler(delJobList) $i]]
					set reInit 1
					puts $f_open "$::recjob($i)"
					continue
				}
			}
			if {[lindex $::recjob($i) 5] == 2} {
				# weekday repeat
				if {[lindex $::recjob($i) 6] == 0} {
					# no more repetitions
					continue
				} else {
					# replace start date
					if {[clock format [clock scan [lindex $::recjob($i) 3]] -format %u] == 5} {
						# on friday replace with next moday and reduce repetitions
						set ::recjob($i) [lreplace $::recjob($i) 3 3 [clock format [expr [clock scan [lindex $::recjob($i) 3]] + (86400 * 3)] -format {%Y-%m-%d}]]
						set ::recjob($i) [lreplace $::recjob($i) 6 6 [expr [lindex $::recjob($i) 6] - 1]]
					} else {
						set ::recjob($i) [lreplace $::recjob($i) 3 3 [clock format [expr [clock scan [lindex $::recjob($i) 3]] + 86400] -format {%Y-%m-%d}]]
					}
					# replace file name
					set ::recjob($i) [lreplace $::recjob($i) 8 8 [file dirname [lindex $::recjob($i) end]]/[string map {{ } {}} [string map {{/} {}} [lindex $::recjob($i) 1]]]\_[lindex $::recjob($i) 3]\_[string map {{am} {}} [string map {{pm} {}} [string map {{ } {}} [lindex $::recjob($i) 2]]]].mpeg]
					# delete number from list
					set ::scheduler(delJobList) [lreplace $::scheduler(delJobList) [lsearch $::scheduler(delJobList) $i] [lsearch $::scheduler(delJobList) $i]]
					set reInit 1
					puts $f_open "$::recjob($i)"
					continue
				}
			}
			if {[lindex $::recjob($i) 5] == 3} {
				# weekly repeat
				if {[lindex $::recjob($i) 6] == 0} {
					# no more repetitions
					continue
				} else {
					# replace start date
					set ::recjob($i) [lreplace $::recjob($i) 3 3 [clock format [expr [clock scan [lindex $::recjob($i) 3]] + (86400 * 7)] -format {%Y-%m-%d}]]
					# replace repetitions
					set ::recjob($i) [lreplace $::recjob($i) 6 6 [expr [lindex $::recjob($i) 6] - 1]]
					# file name
					set ::recjob($i) [lreplace $::recjob($i) 8 8 [file dirname [lindex $::recjob($i) end]]/[string map {{ } {}} [string map {{/} {}} [lindex $::recjob($i) 1]]]\_[lindex $::recjob($i) 3]\_[string map {{am} {}} [string map {{pm} {}} [string map {{ } {}} [lindex $::recjob($i) 2]]]].mpeg]
					# delete number from list
					set ::scheduler(delJobList) [lreplace $::scheduler(delJobList) [lsearch $::scheduler(delJobList) $i] [lsearch $::scheduler(delJobList) $i]]
					set reInit 1
					puts $f_open "$::recjob($i)"
					continue
				}
			}
			continue
		}
		puts $f_open "$::recjob($i)"
	}
	close $f_open
	set status_main [monitor_partRunning 1]
	if {[lindex $status_main 0]} {
		command_WritePipe 0 "tv-viewer_main record_linkerWizardReread"
	}
	if {$reInit == 1} {
		#scheduler_Init 1
	} else {
		if {[llength $::scheduler(delJobList)] == $::scheduler(max_recordings)} {
			scheduler_exit
		}
	}
}

proc scheduler_rec_prestart {jobid} {
	scheduler_logWriteOut 0 "Attempting to record job number [lindex $::recjob($jobid) 0]."
	set status_record [monitor_partRunning 3]
	if {[lindex $status_record 0] == 1} {
		scheduler_logWriteOut 2 "There is an active recording."
		scheduler_logWriteOut 2 "Can't record $::recjob($jobid)"
		set status [monitor_partRunning 1]
		if {[lindex $status 0]} {
			command_WritePipe 0 "tv-viewer_main record_linkerPrestartCancel record"
		}
		return
	}
	set status_time [monitor_partRunning 4]
	if {[lindex $status_time 0] == 1} {
		scheduler_logWriteOut 1 "Scheduler detected timeshift process."
		scheduler_logWriteOut 1 "Will stop timeshift!"
		command_WritePipe 0 "tv-viewer_main timeshift .ftoolb_Top.bTimeshift"
	}
	
	if {[file exists $::option(video_device)] == 0} {
		scheduler_logWriteOut 2 "Can not detect Video Device $::option(video_device)"
		scheduler_logWriteOut 2 "Have a look into the preferences and change it."
		return
	}
	set status_main [monitor_partRunning 1]
	if {[lindex $status_main 0]} {
		scheduler_logWriteOut 0 "Scheduler detected TV-Viewer is running, sending commands via socket."
		command_WritePipe 0 "tv-viewer_main record_linkerPrestart record"
	}
	if {$::option(forcevideo_standard) == 1} {
		main_pic_streamForceVideoStandard
	}
	set dimensions [string map {{/} { }} [lindex $::recjob($jobid) 7]]
	catch {exec v4l2-ctl --device=$::option(video_device) --set-fmt-video=width=[lindex $dimensions 0],height=[lindex $dimensions 1]}
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
	set match 0
	for {set i 1} {$i <= $::scheduler(max_stations)} {incr i} {
		if {"[lindex $::recjob($jobid) 1]" == "$::kanalid($i)"} {
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
		scheduler_logWriteOut 2 "Station \{[lindex $::recjob($jobid) 1]\} does not exist."
		scheduler_logWriteOut 2 "Can't record $::recjob($jobid)"
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
		scheduler_logWriteOut 2 "Waited 3 seconds to change video input to $::kanalinput($snumber)."
		scheduler_logWriteOut 2 "This didn't work, BAD."
		set status [monitor_partRunning 1]
		if {[lindex $status 0]} {
			command_WritePipe 0 "tv-viewer_main record_linkerPrestartCancel record"
		}
		return
	}
	catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
	set status_grep_input [catch {agrep -m "$read_vinput" video} resultat_grep_input]
	if {$status_grep_input == 0} {
		if {$::kanalinput($snumber) == [lindex $resultat_grep_input 3]} {
			if {$::kanalext($snumber) == 0} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$::kanalcall($snumber)}
			} else {
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
			set duration [string map {{:} { }} [lindex $::recjob($jobid) 4]]
			set duration_calc [expr ([scan [lindex $duration 0] %d] * 3600) + ([scan [lindex $duration 1] %d] * 60) + [scan [lindex $duration 2] %d]]
			set rec_pid [exec "$::option(root)/recorder.tcl" [lindex $::recjob($jobid) end] $::option(video_device) $duration_calc &]
			scheduler_logWriteOut 0 "Recorder has been executed for Job [lindex $::recjob($jobid) 0]."
			after 3000 [list scheduler_rec $jobid 0 $rec_pid $duration_calc]
		} else {
			catch {exec v4l2-ctl --device=$::option(video_device) --set-input=$::kanalinput($snumber)}
			scheduler_logWriteOut 0 "Trying to change video input to $::kanalinput($snumber)..."
			set ::scheduler(change_inputLoop_id) [after 100 [list scheduler_change_inputLoop [expr $secs + 100] $snumber $jobid]]
		}
	} else {
		scheduler_logWriteOut 2 "Can not change video input to $::kanalinput($snumber)."
		scheduler_logWriteOut 2 "$resultat_grep_input."
		set status [monitor_partRunning 1]
		if {[lindex $status 0]} {
			command_WritePipe 0 "tv-viewer_main record_linkerPrestartCancel record"
		}
		return
	}
}

proc scheduler_rec {jobid counter rec_pid duration_calc} {
	if {$counter == 10} {
		scheduler_logWriteOut 2 "Scheduler tried for 30 seconds to record $::recjob($jobid)"
		scheduler_logWriteOut 2 "This was unsuccessful."
		set status [monitor_partRunning 1]
		if {[lindex $status 0]} {
			command_WritePipe 0 "tv-viewer_main record_linkerPrestartCancel record"
		}
		return
	}
	if {[file exists "[lindex $::recjob($jobid) end]"]} {
		if {[file size "[lindex $::recjob($jobid) end]"] > 0} {
			scheduler_logWriteOut 0 "Recording of job $::recjob($jobid) started successfully."
			scheduler_logWriteOut 0 "Recorder process PID $rec_pid"
			catch {exec ln -s "$rec_pid" "$::option(home)/tmp/record_lockfile.tmp"}
			set f_open [open "$::option(home)/config/current_rec.conf" w]
			set endtime [expr $duration_calc + [clock scan now]]
			puts -nonewline $f_open "\{[lindex $::recjob($jobid) 1]\} [clock format [clock scan now] -format {%Y-%m-%d}] [clock format [clock scan now] -format {%H:%M:%S}] [clock format $endtime -format {%Y-%m-%d}] [clock format $endtime -format {%H:%M:%S}] $duration_calc \{[lindex $::recjob($jobid) end]\}"
			close $f_open
			after [expr $duration_calc * 1000] {catch {exec ""}}
			set status [monitor_partRunning 1]
			if {[lindex $status 0]} {
				command_WritePipe 0 "tv-viewer_main record_linkerRec record"
			}
			scheduler_delete $jobid
		} else {
			catch {exec kill $rec_pid}
			catch {exec ""}
			set rec_pid [exec "$::option(root)/recorder.tcl" [lindex $::recjob($jobid) end] $::option(video_device) $duration_calc &]
			incr counter
			after 3000 [list scheduler_rec $jobid $counter $rec_pid $duration_calc]
		}
	} else {
		catch {exec kill $rec_pid}
		catch {exec ""}
		scheduler_logWriteOut 2 "File [lindex $::recjob($jobid) end] doesn't exist."
		scheduler_logWriteOut 2 "Can't record $::recjob($jobid)"
		set status [monitor_partRunning 1]
		if {[lindex $status 0]} {
			command_WritePipe 0 "tv-viewer_main record_linkerPrestartCancel record"
		}
		return
	}
}

proc scheduler_zombie {} {
	catch {exec ""}
}

proc scheduler_main_loop {} {
	if {[info exists ::scheduler(loop_date)]} {
		if {[clock format [clock scan now] -format {%Y%m%d}] != $::scheduler(loop_date)} {
			if {[info exists ::scheduler(at_id)]} {
				foreach at $::scheduler(at_id) {
					catch {after cancel $at}
				}
				unset -nocomplain ::scheduler(at_id)
			}
			array unset ::recjob
			scheduler_recordings
		}
	} else {
		array unset ::recjob
		scheduler_recordings
	}
	after 20000 [list scheduler_main_loop]
}

proc scheduler_Init {handler} {
	if {$handler == 0} {
		process_configRead
		scheduler_log
		command_socket
		set status [monitor_partRunning 1]
		if {[lindex $status 0]} {
			command_WritePipe 0 "tv-viewer_main record_wizardExecSchedulerCback 0"
		}
		scheduler_stations
		scheduler_main_loop
	} else {
		process_configRead
		scheduler_stations
		scheduler_logWriteOut 1 "Scheduler has been reinitiated."
		set ::scheduler(loop_date) 0
		scheduler_main_loop
	}
}

scheduler_Init 0

vwait forever
