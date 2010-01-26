#!/usr/bin/env tclsh

#       record_external.tcl
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

package require Tcl 8.5

set option(root) "[file dirname [file dirname [file dirname [file normalize [file join [info script] bogus]]]]]"
set option(home) "$::env(HOME)/.tv-viewer"
set option(appname) "tv-viewer_recext"

set option(release_version) {0.8.1.1 77 26.01.2010}

set main(debug_msg) [open /dev/null a]

source $option(root)/data/agrep.tcl
source $option(root)/data/main_read_config.tcl
source $option(root)/data/main_read_station_file.tcl
source $option(root)/data/log_viewer.tcl
source $option(root)/data/command_socket.tcl

main_readConfig

if {[file exists "$::option(home)/log/tvviewer.log"]} {
	if {$::option(log_files) == 1} {
		set logf_tv_open_append [open $::option(home)/log/tvviewer.log a]
		fconfigure $logf_tv_open_append -blocking no -buffering line
	} else {
		set logf_tv_open_append [open /dev/null a]
		fconfigure $logf_tv_open_append -blocking no -buffering line
	}
} else {
	set logf_tv_open_append [open /dev/null a]
	fconfigure $logf_tv_open_append -blocking no -buffering line
}

main_readStationFile
command_socket

proc record_externalExit {logw logc returnm returnc} {
	log_writeOutTv $logc "$logw"
	puts "$returnm"
	exit $returnc
}

array set start_options {duration 0 start_time 0 start_date 0 title 0 resolution 0 path 0 station_ext 0 delete 0}
foreach command_argument $argv {
	if {[string first = $command_argument] == -1 } {
		set i [string first - $command_argument]
		set key $command_argument
		set start_options($key) 1
	} else {
		set i [string first = $command_argument]
		set key [string range $command_argument 0 [expr {$i-1}]]
		set value [string range $command_argument [expr {$i+1}] end]
		set start_options($key) 1
		set start_values($key) $value
	}
}

if {[array size start_options] != 8} {
	record_externalExit "External record scheduler received unknown command $argv" 2 "Received unknown command $argv" 1
}

if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
	record_externalExit "External record scheduler, no valid stations list" 2 "No valid stations list." 1
}

proc record_externalDuration {} {
	if {$::start_options(duration)} {
		if {[info exists ::start_values(duration)] && [string is integer $::start_values(duration)]} {
			set seconds $::start_values(duration)
			set ::record(duration_hour) [expr $seconds / 3600]
			set ::record(duration_min) [expr ($seconds - ($::record(duration_hour) * 3600)) / 60]
			set ::record(duration_sec) [expr ($seconds - ($::record(duration_hour) * 3600) - ($::record(duration_min) * 60))]
			set exit_now 0
		} else {
			set exit_now 1
		}
	} else {
		set exit_now 1
	}
	if {$exit_now} {
		record_externalExit "External record scheduler: You need to specifiy an integer value for the duration." 2 "You need to specifiy an integer value for the duration." 1
	}
}

proc record_externalTime {} {
	if {$::start_options(start_time)} {
		if {[info exists ::start_values(start_time)]} {
			set status [catch {clock scan $::start_values(start_time) -format {%H:%M}} result]
			if {$status == 0} {
				set ::record(time_hour) [scan [clock format [clock scan $::start_values(start_time)] -format %H] %d]
				set ::record(time_min) [clock format [clock scan $::start_values(start_time)] -format %M]
				set exit_now 0
			} else {
				record_externalExit "External record scheduler: Time incorrect format." 2 "Time incorrect format, HH:MM (24 hours)." 1
			}
		} else {
			set exit_now 1
		}
	} else {
		set exit_now 1
	}
	if {$exit_now} {
		record_externalExit "External record scheduler: You need to specifiy a value for the start time." 2 "You need to specifiy a value for the start time." 1
	}
}

proc record_externalDate {} {
	if {$::start_options(start_date)} {
		if {[info exists ::start_values(start_date)]} {
			set status [catch {clock scan $::start_values(start_date) -format {%Y-%m-%d}} result]
			if {$status == 0} {
				set ::record(date) $::start_values(start_date)
				set exit_now 0
			} else {
				record_externalExit "External record scheduler: Date incorrect format." 2 "Date incorrect format, YYYY-MM-DD." 1
			}
		} else {
			set exit_now 1
		}
	} else {
		set exit_now 1
	}
	if {$exit_now} {
		record_externalExit "External record scheduler: Specify a start date" 2 "Specify a start date" 1
	}
}

proc record_externalResolution {} {
	set ::record(resolution_width) 720
	if {"$::option(video_standard)" == "NTSC"} {
		set ::record(resolution_height) 480
	} else {
		set ::record(resolution_height) 576
	}
}

proc record_externalStation {} {
	if {$::start_options(station_ext)} {
		if {[info exists ::start_values(station_ext)]} {
			if {[string trim [array get ::kanalid $::start_values(station_ext)]] != {}} {
				set ::record(lbcontent) $::kanalid($::start_values(station_ext))
				set exit_now 0
			} else {
				record_externalExit "External record scheduler: Specified station does not exist" 2 "Specified station does not exist." 1
			}
		} else {
			set exit_now 1
		}
	} else {
		set exit_now 1
	}
	if {$exit_now} {
		record_externalExit "External record scheduler: You need to provide a station" 2 "You need to provide a station." 1
	}
}

proc record_externalTitle {} {
	if {$::start_options(title)} {
		if {[info exists ::start_values(title)]} {
			set title [string map {{ } {_}} "$::start_values(title)"]
			set ::record(file) "$::option(rec_default_path)/$title.mpeg"
			set exit_now 0
		} else {
			set exit_now 1
		}
	} else {
		set exit_now 1
	}
	if {$exit_now} {
		record_externalExit "External record scheduler: Please provide the titel of the recording" 2 "Please provide the titel of the recording" 1
	}
}

proc record_externalAdd {} {
	if {[file exist "$::option(home)/config/scheduler.conf"]} {
		set open_f [open "$::option(home)/config/scheduler.conf" r]
		set jobid [read $open_f]
		incr jobid
		close $open_f
		set f_open [open "$::option(home)/config/scheduler.conf" w]
		puts -nonewline $f_open "$jobid"
		close $f_open
	} else {
		set jobid 1
		set f_open [open "$::option(home)/config/scheduler.conf" w]
		puts -nonewline $f_open "$jobid"
		close $f_open
	}
	set status_schedlinkread [catch {file readlink "$::option(home)/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
	if { $status_schedlinkread == 0 } {
		catch {exec ps -eo "%p"} read_ps
		set status_greppid_sched [catch {agrep -w "$read_ps" $resultat_schedlinkread} resultat_greppid_sched]
		if { $status_greppid_sched == 0 } {
			set start 0
		} else {
			set start 1
		}
	} else {
		set start 1
	}
	log_writeOutTv 0 "Adding new recording:"
	log_writeOutTv 0 "$jobid $::record(lbcontent) $::record(time_hour)\:$::record(time_min) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) $::record(file)"
	if {[file exists "$::option(home)/config/scheduled_recordings.conf"]} {
		set fh [open "$::option(home)/config/scheduled_recordings.conf" r]
		while {[gets $fh line]!=-1} {
			if {[string trim $line] == {}} continue
			lappend recordings $line
		}
		close $fh
		set new_recording "$jobid \{$::record(lbcontent)\} $::record(time_hour)\:$::record(time_min) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) \{$::record(file)\}"
		lappend recordings $new_recording
		catch {file delete -force "$::option(home)/config/scheduled_recordings.conf"}
		set sched_rec [open "$::option(home)/config/scheduled_recordings.conf" w+]
		foreach rec $recordings {
			puts $sched_rec $rec
		}
		close $sched_rec
	} else {
		set sched_rec [open "$::option(home)/config/scheduled_recordings.conf" w+]
		set new_recording "$jobid \{$::record(lbcontent)\} $::record(time_hour)\:$::record(time_min) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) \{$::record(file)\}"
		puts $sched_rec $new_recording
		close $sched_rec
	}
	unset -nocomplain ::record(lbcontent) ::record(time_hour) ::record(time_min) ::record(date) ::record(duration_hour) ::record(duration_min) ::record(duration_sec) ::record(resolution_width) ::record(resolution_height) ::record(file)
	if {$start} {
		log_writeOutTv 0 "Writing new scheduled_recordings.conf and execute scheduler."
		catch {exec ""}
		catch {exec "$::option(root)/data/scheduler.tcl" TEST &}
	} else {
		log_writeOutTv 0 "Writing new scheduled_recordings.conf"
		log_writeOutTv 0 "Reinitiating scheduler"
		command_WritePipe 0 "tv-viewer_scheduler scheduler_Init 1"
	}
}

proc record_externalDelete {} {
	set status_schedlinkread [catch {file readlink "$::option(home)/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
	if { $status_schedlinkread == 0 } {
		catch {exec ps -eo "%p"} read_ps
		set status_greppid_sched [catch {agrep -w "$read_ps" $resultat_schedlinkread} resultat_greppid_sched]
		if { $status_greppid_sched == 0 } {
			set start 0
		} else {
			set start 1
		}
	} else {
		set start 1
	}
	if {[file exists "$::option(home)/config/scheduled_recordings.conf"]} {
		set sched_rec [open "$::option(home)/config/scheduled_recordings.conf" r]
		while {[gets $sched_rec line]!=-1} {
			if {[string trim $line] == {} || [string match #* $line]} continue
			if {"[lindex $line 1] [lindex $line 2] [lindex $line 3]" == "$::record(lbcontent) $::record(time_hour):$::record(time_min) $::record(date)"} {
				log_writeOutTv 0 "Deleting recording $::record(lbcontent) $::record(time_hour):$::record(time_min) $::record(date)"
				continue
			}
			lappend recordings $line
		}
		close $sched_rec
		set sched_rec [open "$::option(home)/config/scheduled_recordings.conf" w+]
		if {[info exists recordings]} {
			foreach rec $recordings {
				puts $sched_rec $rec
			}
		}
		close $sched_rec
	} else {
		record_externalExit "Config file for scheduled recordings is missing" 2 "Config file for scheduled recordings is missing" 1
	}
	if {$start} {
		log_writeOutTv 0 "Writing new scheduled_recordings.conf and execute scheduler."
		catch {exec ""}
		catch {exec "$::option(root)/data/scheduler.tcl" &}
	} else {
		log_writeOutTv 0 "Writing new scheduled_recordings.conf"
		log_writeOutTv 0 "Reinitiating scheduler"
		command_WritePipe 0 "tv-viewer_scheduler scheduler_Init 1"
	}
}

if {$start_options(delete) == 0} {
	record_externalDuration
	record_externalTime
	record_externalDate
	record_externalResolution
	record_externalStation
	record_externalTitle
	set tree .record_wizard.tree_frame.tv_rec 
	set lb .record_wizard.add_edit.listbox_frame.lb_stations 
	set w .record_wizard.add_edit
	set handler add
	record_externalAdd
	command_WritePipe 1 "tv-viewer_main record_linkerWizardReread"
	puts "Successfully scheduled recording:
[string map {{ } {_}} $::start_values(title)] $start_values(start_date) $start_values(start_time)"
	flush stdout
	exit 0
} else {
	record_externalTime
	record_externalDate
	record_externalStation
	record_externalDelete
	command_WritePipe 1 "tv-viewer_main record_linkerWizardReread"
	puts "Successfully deleted recording:
$::kanalid($::start_values(station_ext)) $start_values(start_date) $start_values(start_time)"
	flush stdout
	exit 0
}
