#!/usr/bin/env wish

#       record_scheduler.tcl
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

package require Tcl 8.5

wm withdraw .

set ::option(appname) tv-viewer_scheduler

#set processing_folder [file dirname [file normalize [info script]]]
if {[file type [info script]] == "link" } {
	set where_is [file dirname [file normalize [file readlink [info script]]]]
} else {
	set where_is [file dirname [file normalize [info script]]]
}
set where_is_home "$::env(HOME)/.tv-viewer"

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

set option(release_version) "0.8.1a1.8"

if {[file isdirectory $::where_is_home] == 0} {
	puts "
Fatal error. Could not detect config directory
$::where_is_home

Before running the scheduler you have to run the main application.
EXIT 1"
	exit 1
}

set status_lock [catch {exec ln -s "[pid]" "$::where_is_home/tmp/scheduler_lockfile.tmp"} resultat_lock]
if { $status_lock != 0 } {
	set linkread [file readlink "$::where_is_home/tmp/scheduler_lockfile.tmp"]
	catch {exec ps -eo "%p"} read_ps
	set status_greppid [catch {agrep -w "$read_ps" $linkread} resultat_greppid]
	if { $status_greppid != 0 } {
		catch {file delete "$::where_is_home/tmp/scheduler_lockfile.tmp"}
		catch {exec ln -s "[pid]" "$::where_is_home/tmp/scheduler_lockfile.tmp"}
	} else {
		puts "
An instance of the TV-Viewer Scheduler is already running."
		exit 1
	}
}
unset -nocomplain status_lock resultat_lock linkread status_greppid resultat_greppid

source $where_is/main_read_config.tcl
source $where_is/main_picqual_stream.tcl
source $where_is/main_newsreader.tcl
source $where_is/command_socket.tcl
source $where_is/agrep.tcl

main_readConfig

proc scheduler_log {} {
	if {$::option(log_files) == 1} {
		if {[file exists "$::where_is_home/log/scheduler.log"]} {
			if {[file size "$::where_is_home/log/scheduler.log"] > [expr $::option(log_size_scheduler) * 1000]} {
				catch {file delete "$::where_is_home/log/scheduler.log"}
				set logf_sched_open [open "$::where_is_home/log/scheduler.log" w]
				puts $logf_sched_open "
########################################################################
# Scheduler logfile. Release version $::option(release_version)
# Start new session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
#"
				close $logf_sched_open
				set ::logf_sched_open_append [open "$::where_is_home/log/scheduler.log" a]
			} else {
				set ::logf_sched_open_append [open "$::where_is_home/log/scheduler.log" a]
				puts $::logf_sched_open_append "
########################################################################
# Scheduler logfile. Release version $::option(release_version)
# Start new session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
#"
				flush $::logf_sched_open_append
			}
		} else {
			set logf_sched_open [open "$::where_is_home/log/scheduler.log" w]
			puts $logf_sched_open "
########################################################################
# Scheduler logfile. Release version $::option(release_version)
# Start new session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
#"
			close $logf_sched_open
			set ::logf_sched_open_append [open "$::where_is_home/log/scheduler.log" a]
		}
	} else {
		set ::logf_sched_open_append [open /dev/null a]
		fconfigure $::logf_sched_open_append -blocking no -buffering line
	}
	set ::logf_tv_open_append $::logf_sched_open_append
}

scheduler_log

proc scheduler_stations {} {
	if !{[file exists "$::where_is_home/config/stations_$::option(frequency_table).conf"]} {
		puts $::logf_sched_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] No valid stations_$::option(frequency_table).conf
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Please create one using the Station Editor.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Make sure you checked the configuration first!
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Scheduler EXIT 1"
		flush $::logf_sched_open_append
		exit 1
	} else {
		set file "$::where_is_home/config/stations_$::option(frequency_table).conf"
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
			set ::scheduler(max_stations) $i
			incr i
		}
		close $open_channel_file
		if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
			puts $::logf_sched_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] No valid stations_$::option(frequency_table).conf
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Please create one using the Station Editor.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Make sure you checked the configuration first!
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Scheduler EXIT 1"
			flush $::logf_sched_open_append
			exit 1
		}
	}
}

scheduler_stations

proc scheduler_exit {} {
	catch {file delete "$::where_is_home/tmp/scheduler_lockfile.tmp"}
	puts $::logf_sched_open_append "#
#
# Stop session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
########################################################################
"
	close $::logf_sched_open_append
	exit 0
}

proc scheduler_recordings {} {
	if {[file exists "$::where_is_home/config/scheduled_recordings.conf"]} {
		set f_open [open "$::where_is_home/config/scheduled_recordings.conf" r]
		set i 1
		while {[gets $f_open line]!=-1} {
			if {[string trim $line] == {} || [string match #* $line]} continue
			set ::scheduler(max_recordings) $i
			incr i
		}
		close $f_open
		set f_open [open "$::where_is_home/config/scheduled_recordings.conf" r]
		set i 1
		while {[gets $f_open line]!=-1} {
			if {[string trim $line] == {} || [string match #* $line] == 1} continue
			set ::recjob($i) $line
			if {"[lindex $::recjob($i) 3]" == "[clock format [clock scan now] -format {%Y-%m-%d}]"} {
				scheduler_at [lindex $::recjob($i) 2] $i
			} else {
				set diffdate [string map {{-} {}} [lindex $::recjob($i) 3]]
				set delta [main_newsreaderDifftimes [clock scan $diffdate] [clock scan [clock format [clock scan now] -format {%Y%m%d}]]]
				lassign $delta dy dm dd
				if {$dy < 0 || $dm < 0 || $dd < 0} {
					puts $::logf_sched_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Job $i expired.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Will be deleted."
					flush $::logf_sched_open_append
					lappend deljobs $i
				}
			}
			incr i
		}
		if {[info exists deljobs]} {
			scheduler_delete [list $deljobs]
		}
		if {[array exists ::recjob] == 0} {
			puts $::logf_sched_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] No recordings in config file. Scheduler will be terminated."
			flush $::logf_sched_open_append
			close $f_open
			scheduler_exit
			return
		}
		close $f_open
		set ::scheduler(loop_date) [clock format [clock scan now] -format {%Y%m%d}]
	} else {
		puts $::logf_sched_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] No recordings in config file. Scheduler will be terminated."
		flush $::logf_sched_open_append
		scheduler_exit
	}
}

proc scheduler_at {time jobid} {
	set dt [expr {([clock scan $time]-[clock seconds])*1000}]
	if { $dt >= -600000 } {
		after $dt [list scheduler_rec_prestart $jobid]
		puts $::logf_sched_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Job number [lindex $::recjob($jobid) 0] will be recorded today at $time"
		flush $::logf_sched_open_append
	} else {
		puts $::logf_sched_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Job $::recjob($jobid) expired.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Will be deleted."
		flush $::logf_sched_open_append
		scheduler_delete [list $jobid]
	}
}

proc scheduler_delete {args} {
	file delete -force "$::where_is_home/config/scheduled_recordings.conf"
	set f_open [open "$::where_is_home/config/scheduled_recordings.conf" a]
	if {[llength $args] > 1} {
		foreach id $args {
			lappend ::recjob(delete) $id
		}
	} else {
		lappend ::recjob(delete) $args
	}
	for {set i 1} {$i <= $::scheduler(max_recordings)} {incr i} {
		if {[string match *$i* $::recjob(delete)]} continue
		puts $f_open "$::recjob($i)"
	}
	close $f_open
	if {[llength $::recjob(delete)] == $::scheduler(max_recordings)} {
		scheduler_exit
	}
}

proc scheduler_rec_prestart {jobid} {
	puts $::logf_sched_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Attempting to record job number $jobid."
	flush $::logf_sched_open_append
	set status_recordlinkread [catch {file readlink "$::where_is_home/tmp/record_lockfile.tmp"} resultat_recordlinkread]
	if { $status_recordlinkread == 0 } {
		catch {exec ps -eo "%p"} read_ps
		set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
		if { $status_greppid_record == 0 } {
			puts $::logf_sched_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] There is an active recording.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Can't record $::recjob($jobid)"
			flush $::logf_sched_open_append
			puts $::data(comsocket) "tv-viewer_main record_scheduler_prestartCancel record"
			flush $::data(comsocket)
			return
		}
	}
	set status_timeslinkread [catch {file readlink "$::where_is_home/tmp/timeshift_lockfile.tmp"} resultat_timeslinkread]
	if { $status_timeslinkread == 0 } {
		catch {exec ps -eo "%p"} read_ps
		set status_greppid_times [catch {agrep -w "$read_ps" $resultat_timeslinkread} resultat_greppid_times]
		if { $status_greppid_times == 0 } {
			puts $::data(comsocket) "tv-viewer_main timeshift .top_buttons.button_timeshift"
			flush $::data(comsocket)
		}
	}
	set status_linkread [catch {file readlink "$::where_is_home/tmp/lockfile.tmp"} resultat_linkread]
	if { $status_linkread == 0 } {
		catch {exec ps -eo "%p"} read_ps
		set status_greppid [catch {agrep -w "$read_ps" $resultat_linkread} resultat_greppid]
		if { $status_greppid == 0 } {
			puts $::logf_sched_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Scheduler detected TV-Viewer is running, sending commands via socket."
			flush $::logf_sched_open_append
			puts $::data(comsocket) "tv-viewer_main record_schedulerPrestart record"
			flush $::data(comsocket)
		}
	}
	if {$::option(forcevideo_standard) == 1} {
		main_pic_streamForceVideoStandard
	}
	set dimensions [string map {{/} { }} [lindex $::recjob($jobid) 5]]
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
	for {set i 1} {$i <= $::scheduler(max_stations)} {incr i} {
		if {"[lindex $::recjob($jobid) 1]" == "$::kanalid($i)"} {
			set ::scheduler(change_inputLoop_id) [after 100 [list scheduler_change_inputLoop 0 $i $jobid]]
			break
		}
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
		puts $::logf_sched_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Waited 3 seconds to change video input to $input.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] This didn't work, BAD."
		flush $::logf_sched_open_append
		return
	}
	catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
	set status_grep_input [catch {agrep -m "$read_vinput" video} resultat_grep_input]
	if {$status_grep_input == 0} {
		if {$::kanalinput($snumber) == [lindex $resultat_grep_input 3]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$::kanalcall($snumber)}
			puts $::data(comsocket) "tv-viewer_main record_schedulerStation {$::kanalid($snumber)} $snumber"
			flush $::data(comsocket)
			set last_channel_conf "$::where_is_home/config/lastchannel.conf"
			set last_channel_write [open $last_channel_conf w]
			puts -nonewline $last_channel_write "\{$::kanalid($snumber)\} $::kanalcall($snumber) $snumber"
			close $last_channel_write
			catch {file delete "$::where_is_home/tmp/record_lockfile.tmp"}
			set duration [string map {{:} { }} [lindex $::recjob($jobid) 4]]
			set duration_calc [expr ([scan [lindex $duration 0] %d] * 3600) + ([scan [lindex $duration 1] %d] * 60) + [scan [lindex $duration 2] %d]]
			set rec_pid [exec "$::where_is/recorder.tcl" [lindex $::recjob($jobid) end] $::option(video_device) $duration_calc &]
			puts $::logf_sched_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Recorder has been executed for Job [lindex $::recjob($jobid) 0]."
			flush $::logf_sched_open_append
			after 3000 [list scheduler_rec $jobid 0 $rec_pid $duration_calc]
		} else {
			catch {exec v4l2-ctl --device=$::option(video_device) --set-input=$::kanalinput($snumber)}
			puts $::logf_sched_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Changed video input to $input."
			flush $::logf_sched_open_append
			set ::scheduler(change_inputLoop_id) [after 100 [list scheduler_change_inputLoop [expr $secs + 100] $snumber $jobid]]
		}
	} else {
		puts $::logf_sched_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Can not change video input to $::kanalinput($snumber).
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] $resultat_grep_input."
		flush $::logf_sched_open_append
		return
	}
}

proc scheduler_rec {jobid counter rec_pid duration_calc} {
	if {$counter == 10} {
		puts $::logf_sched_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Scheduler tried for 30 seconds to record $::recjob($jobid)
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] This was unsuccessful."
		flush $::logf_sched_open_append
		puts $::data(comsocket) "tv-viewer_main record_scheduler_prestartCancel record"
		flush $::data(comsocket)
		return
	}
	if {[file exists "[lindex $::recjob($jobid) end]"]} {
		if {[file size "[lindex $::recjob($jobid) end]"] > 0} {
			puts $::logf_sched_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Recording of job $::recjob($jobid) started successfully."
			flush $::logf_sched_open_append
			catch {exec ln -s "$rec_pid" "$::where_is_home/tmp/record_lockfile.tmp"}
			set f_open [open "$::where_is_home/config/current_rec.conf" w]
			set endtime [expr $duration_calc + [clock scan now]]
			puts -nonewline $f_open "\{[lindex $::recjob($jobid) 1]\} [clock format [clock scan now] -format {%Y-%m-%d}] [clock format [clock scan now] -format {%H:%M:%S}] [clock format $endtime -format {%Y-%m-%d}] [clock format $endtime -format {%H:%M:%S}] $duration_calc \{[lindex $::recjob($jobid) end]\}"
			close $f_open
			after [expr $duration_calc * 1000] {catch {exec ""}}
			puts $::data(comsocket) "tv-viewer_main record_schedulerRec record"
			flush $::data(comsocket)
			scheduler_delete [list $jobid]
		} else {
			catch {exec kill $rec_pid}
			catch {exec ""}
			set rec_pid [exec "$::where_is/recorder.tcl" [lindex $::recjob($jobid) end] $::option(video_device) $duration_calc &]
			incr counter
			after 3000 [list scheduler_rec $jobid $counter $rec_pid $duration_calc]
		}
	} else {
		catch {exec kill $rec_pid}
		catch {exec ""}
		puts $::logf_sched_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] File [lindex $::recjob($jobid) end] doesn't exist.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Can't record $::recjob($jobid)"
		flush $::logf_sched_open_append
		puts $::data(comsocket) "tv-viewer_main record_scheduler_prestartCancel record"
		flush $::data(comsocket)
	}
}

proc scheduler_zombie {} {
	catch {exec ""}
}

proc scheduler_main_loop {} {
	if {[info exists ::scheduler(loop_date)]} {
		if {[clock format [clock scan now] -format {%Y%m%d}] != $::scheduler(loop_date)} {
			array unset ::recjob
			scheduler_recordings
		}
	} else {
		array unset ::recjob
		scheduler_recordings
	}
	after 20000 [list scheduler_main_loop]
}

command_socket
scheduler_main_loop
