#!/usr/bin/env tclsh

#       record_external.tcl
#       © Copyright 2007-2011 Christian Rapp <christianrapp@users.sourceforge.net>
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


########################################################################
# record_external.tcl is part of TV-Viewer.
# This script can be used to schedule recordings and/or delete them.
# Options:
# --start_time = Provide a start time in 12-hour or 24-hour format (HH:MM 24-hour clock, "HH:MM am/pm" 12-hour clock)*
# --start_date = Start date YYYY-MM-DD*
# --duration = Specify the duration of the recording in seconds*
# --repeat = repeat the recording (0 - never; 1 - daily; 2 - weekday; 3 - weekly)
# --repetitions = how often to repeat a recording
# --title = Title for the recording*
# --station_ext = Station to record. You need to provide the same as in TV-Viewer.*
# --path = Output path
# --resolution = Recording resolution.
# --delete = Delete already scheduled recording. You need to provide start_time, start_date and station_ex
# 
# *These options are mandatory to schedule a recording

set option(root) "[file dirname [file dirname [file dirname [file normalize [file join [info script] bogus]]]]]"
set option(home) "$::env(HOME)/.tv-viewer"
set option(appname) "tv-viewer_recext"

set main(debug_msg) [open /dev/null a]

source $option(root)/data/init.tcl

init_pkgReq "0"
init_source "$option(root)/data" "release_version.tcl agrep.tcl process_config.tcl process_station_file.tcl log_viewer.tcl command_socket.tcl monitor.tcl"

process_configRead

if {[file exists "$::option(home)/log/tvviewer.log"]} {
	if {$::option(log_files) == 1} {
		set log(tvAppend) [open $::option(home)/log/tvviewer.log a]
		fconfigure $log(tvAppend) -blocking no -buffering line
	} else {
		set log(tvAppend) [open /dev/null a]
		fconfigure $log(tvAppend) -blocking no -buffering line
	}
} else {
	set log(tvAppend) [open /dev/null a]
	fconfigure $log(tvAppend) -blocking no -buffering line
}

process_StationFile ::log(tvAppend)
command_socket

proc record_externalExit {logw logc returnm returnc} {
	log_writeOut ::log(tvAppend) $logc "$logw"
	puts "$returnm"
	exit $returnc
}

array set start_options {--duration 0 --start_time 0 --start_date 0 --repeat 0 --repetition 0 --title 0 --resolution 0 --path 0 --station_ext 0 --delete 0 --help 0}
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

if {[array size start_options] != 11} {
	record_externalExit "External record scheduler received unknown option $argv" 2 "Received unknown option $argv
	
Usage: tv-viewer_recext \[OPTION...\]

  --help               show this help
 
 Schedule recording:
  --start_time=TIME    specify start time (HH:MM 24-hour clock, \"HH:MM am/pm\" 12-hour clock)
  --start_date=DATE    provide start date (YYYY-MM-DD)
  --duration=DURATION  duration of the recording in SECONDS
  --repeat=NUMBER      repeat the recording (0 - never; 1 - daily; 2 - weekday; 3 - weekly)
  --repetitions=COUNT  how often to repeat a recording
  --title=NAME         name/title for the recording
  --station_ext=NO     provide the station number as specified in TV-Viewer
 
 Additional options:
  --path=PATH          path where the recording should be stored
  --resolution=RESOL   resoltion in which the recording should be performed
   
 Delete recording:
  --delete             delete the recording with start_time, start_date and station_ext" 1
}

if {$::start_options(--help)} {
	puts "Usage: tv-viewer_recext \[OPTION...\]

  --help               show this help
 
 Schedule recording:
  --start_time=TIME    specify start time (HH:MM 24-hour clock, \"HH:MM am/pm\" 12-hour clock)
  --start_date=DATE    provide start date (YYYY-MM-DD)
  --duration=DURATION  duration of the recording in SECONDS
  --repeat=NUMBER      repeat the recording (0 - never; 1 - daily; 2 - weekday; 3 - weekly)
  --repetitions=COUNT  how often to repeat a recording
  --title=NAME         name/title for the recording
  --station_ext=NO     provide the station number as specified in TV-Viewer
 
 Additional options:
  --path=PATH          path where the recording should be stored
  --resolution=RESOL   resoltion in which the recording should be performed
   
 Delete recording:
  --delete             delete the recording with start_time, start_date and station_ext
"
	exit 0
}

if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
	record_externalExit "External record scheduler, no valid stations list" 2 "No valid stations list." 1
}

proc record_externalDuration {} {
	if {$::start_options(--duration)} {
		if {[info exists ::start_values(--duration)] && [string is integer $::start_values(--duration)]} {
			set seconds $::start_values(--duration)
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
	if {$::start_options(--start_time)} {
		if {[info exists ::start_values(--start_time)]} {
			#FIXME - This check is not very robust have to integrate timevalidate
			if {$::option(rec_hour_format) == 24} {
				set status [catch {clock scan $::start_values(--start_time) -format {%H:%M}} result]
			} else {
				set status [catch {clock scan $::start_values(--start_time) -format {%I:%M %P}} result]
			}
			if {$status == 0} {
				if {$::option(rec_hour_format) == 24} {
					set ::record(time_hour) [scan [clock format [clock scan $::start_values(--start_time)] -format %H] %d]
					set ::record(time_min) [clock format [clock scan $::start_values(--start_time)] -format %M]
					set ::record(time) "$::record(time_hour)\:$::record(time_min)"
					set exit_now 0
				} else {
					set ::record(time_hour) [scan [clock format [clock scan $::start_values(--start_time)] -format %I] %d]
					set ::record(time_min) [clock format [clock scan $::start_values(--start_time)] -format %M]
					set ::record(time) "$::record(time_hour)\:$::record(time_min) [clock format [clock scan $::start_values(--start_time)] -format %P]"
					set exit_now 0
				}
			} else {
				if {$::option(rec_hour_format) == 24} {
					record_externalExit "External record scheduler: Time incorrect format." 2 "Time incorrect format, HH:MM (24-hours clock)." 1
				} else {
					record_externalExit "External record scheduler: Time incorrect format." 2 "Time incorrect format, HH:MM am/pm (12-hours clock)." 1
				}
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
	if {$::start_options(--start_date)} {
		if {[info exists ::start_values(--start_date)]} {
			#FIXME - This check is not very robust have to integrate timevalidate
			set status [catch {clock scan $::start_values(--start_date) -format {%Y-%m-%d}} result]
			if {$status == 0} {
				set ::record(date) $::start_values(--start_date)
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

proc record_externalRepeat {} {
	if {$::start_options(--repeat) == 0} {
		set ::record(rbRepeat) 0
	} else {
		if {[info exists ::start_values(--repeat)]} {
			set ::record(rbRepeat) $::start_values(--repeat)
		} else {
			record_externalExit "External record scheduler: Specify a value for repeat" 2 "Specify a value for repeat" 1
		}
	}
	if {$::start_options(--repetition) == 0} {
		set ::record(sbRepeat) 1
	} else {
		if {[info exists ::start_values(--repetition)]} {
			set ::record(sbRepeat) $::start_values(--repetition)
		} else {
			set ::record(sbRepeat) 1
		}
	}
}

#~ proc timevalidate {format str} {
     #~ # Start with a simple check: If the string cannot be parsed against
     #~ # the specified format at all it's definitely wrong
     #~ if {[catch {clock scan $str -format $format} time]} {return 0}
#~ 
     #~ # Create a table for translating the supported clock format specifiers
     #~ # to scan format specifications
     #~ set map {%a %3s %A %s %b %3s %B %s %d %2d %D %2d/%2d/%4d
        #~ %e %2d %g %2d %G %4d %h %s %H %2d %I %2d %j %3d
        #~ %J %d %k %2d %l %2d %m %2d %M %2d %N %2d %p %2s
        #~ %P %2s %s %d %S %2d %t \t %T %2d:%2d:%2d %u %1d
        #~ %V %2d %w %1d %W %2d %y %2d %Y %2d %z %4d %Z %s
     #~ }
#~ 
     #~ # Build the scan format string out of the clock format string
     #~ set scanfmt [string map $map $format]
#~ 
     #~ # Recreate the time string from the seconds value
     #~ set tmp [clock format $time -format $format]
#~ 
     #~ # Scan both versions of the string representation
     #~ set list1 [scan $str $scanfmt]
     #~ set list2 [scan $tmp $scanfmt]
#~ 
     #~ # Compare all elements as numbers and strings
     #~ foreach n1 $list1 n2 $list2 {
        #~ if {$n1 != $n2 && ![string equal -nocase $n1 $n2]} {return 0}
     #~ }
#~ 
     #~ # Declare the time string valid since all elements matched
     #~ return 1
 #~ }
 #~ 
 #~ puts [timevalidate "%Y-%m-%d" $date]

proc record_externalResolution {} {
	set ::record(resolution_width) 720
	if {"$::option(video_standard)" == "NTSC"} {
		set ::record(resolution_height) 480
	} else {
		set ::record(resolution_height) 576
	}
}

proc record_externalStation {} {
	if {$::start_options(--station_ext)} {
		if {[info exists ::start_values(--station_ext)]} {
			if {[string trim [array get ::kanalid $::start_values(--station_ext)]] != {}} {
				set ::record(lbcontent) $::kanalid($::start_values(--station_ext))
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
	if {$::start_options(--title)} {
		if {[info exists ::start_values(--title)]} {
			set title [string map {{ } {_}} "$::start_values(--title)"]
			if {$::option(rec_hour_format) == 24} {
				set time [clock format [clock scan $::start_values(--start_time)] -format {%H-%M}]
			} else {
				set time [clock format [clock scan $::start_values(--start_time)] -format {%I-%M %P}]
			}
			set ::record(file) "$::option(rec_default_path)/$title\_$::start_values(--start_date)_${time}.mpeg"
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
	set status [monitor_partRunning 2]
	if {[lindex $status 0] == 1} {
		set start 0
	} else {
		set start 1
	}
	log_writeOut ::log(tvAppend) 0 "Adding new recording:"
	log_writeOut ::log(tvAppend) 0 "$jobid $::record(lbcontent) $::record(time) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(rbRepeat) $::record(sbRepeat) $::record(resolution_width)\/$::record(resolution_height) $::record(file)"
	if {[file exists "$::option(home)/config/scheduled_recordings.conf"]} {
		set fh [open "$::option(home)/config/scheduled_recordings.conf" r]
		while {[gets $fh line]!=-1} {
			if {[string trim $line] == {}} continue
			lappend recordings $line
		}
		close $fh
		set new_recording "$jobid \{$::record(lbcontent)\} \{$::record(time)\} $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(rbRepeat) $::record(sbRepeat) $::record(resolution_width)\/$::record(resolution_height) \{$::record(file)\}"
		lappend recordings $new_recording
		catch {file delete -force "$::option(home)/config/scheduled_recordings.conf"}
		set sched_rec [open "$::option(home)/config/scheduled_recordings.conf" w+]
		foreach rec $recordings {
			puts $sched_rec $rec
		}
		close $sched_rec
	} else {
		set sched_rec [open "$::option(home)/config/scheduled_recordings.conf" w+]
		set new_recording "$jobid \{$::record(lbcontent)\} \{$::record(time)\} $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(rbRepeat) $::record(sbRepeat) $::record(resolution_width)\/$::record(resolution_height) \{$::record(file)\}"
		puts $sched_rec $new_recording
		close $sched_rec
	}
	unset -nocomplain ::record(lbcontent) ::record(time_hour) ::record(time_min) ::record(time) ::record(date) ::record(sbRepeat) ::record(rbRepeat) ::record(duration_hour) ::record(duration_min) ::record(duration_sec) ::record(resolution_width) ::record(resolution_height) ::record(file)
	if {$start} {
		log_writeOut ::log(tvAppend) 0 "Writing new scheduled_recordings.conf and execute scheduler."
		catch {exec ""}
		if {$::option(tclkit) == 1} {
			catch {exec $::option(tclkit_path) $::option(root)/data/scheduler.tcl &}
		} else {
			catch {exec "$::option(root)/data/scheduler.tcl" &}
		}
	} else {
		log_writeOut ::log(tvAppend) 0 "Writing new scheduled_recordings.conf"
		log_writeOut ::log(tvAppend) 0 "Reinitiating scheduler"
		set status [monitor_partRunning 2]
		if {[lindex $status 0] == 1} {
			command_WritePipe 0 "tv-viewer_scheduler scheduler_Init 1"
		}
	}
}

proc record_externalDelete {} {
	set status [monitor_partRunning 2]
	if {[lindex $status 0] == 1} {
		set start 1
	} else {
		set start 0
	}
	if {[file exists "$::option(home)/config/scheduled_recordings.conf"]} {
		set sched_rec [open "$::option(home)/config/scheduled_recordings.conf" r]
		set recmatch 0
		while {[gets $sched_rec line]!=-1} {
			if {[string trim $line] == {} || [string match #* $line]} continue
			if {"[lindex $line 1] [lindex $line 2] [lindex $line 3]" == "$::record(lbcontent) $::record(time) $::record(date)"} {
				log_writeOut ::log(tvAppend) 0 "Deleting recording $::record(lbcontent) $::record(time) $::record(date)"
				set recmatch 1
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
	if {$start == 0} {
		log_writeOut ::log(tvAppend) 0 "Writing new scheduled_recordings.conf and execute scheduler."
		catch {exec ""}
		if {$::option(tclkit) == 1} {
			catch {exec $::option(tclkit_path) $::option(root)/data/scheduler.tcl &}
		} else {
			catch {exec "$::option(root)/data/scheduler.tcl" &}
		}
		return $recmatch
	} else {
		log_writeOut ::log(tvAppend) 0 "Writing new scheduled_recordings.conf"
		log_writeOut ::log(tvAppend) 0 "Reinitiating scheduler"
		set status [monitor_partRunning 2]
		if {[lindex $status 0] == 1} {
			command_WritePipe 0 "tv-viewer_scheduler scheduler_Init 1"
		}
		return $recmatch
	}
}

if {$start_options(--delete) == 0} {
	record_externalDuration
	record_externalTime
	record_externalDate
	record_externalRepeat
	record_externalResolution
	record_externalStation
	record_externalTitle
	set tree .record_wizard.tree_frame.cv.f.tv_rec 
	set lb .record_wizard.add_edit.listbox_frame.lb_stations 
	set w .record_wizard.add_edit
	set handler add
	record_externalAdd
	set status_main [monitor_partRunning 1]
	if {[lindex $status_main 0]} {
		command_WritePipe 1 "tv-viewer_main record_linkerWizardReread"
	}
	puts "Successfully scheduled recording:
[string map {{ } {_}} $::start_values(--title)] $start_values(--start_date) $start_values(--start_time)"
	flush stdout
	exit 0
} else {
	record_externalTime
	record_externalDate
	record_externalStation
	set recmatch [record_externalDelete]
	set status_main [monitor_partRunning 1]
	if {[lindex $status_main 0]} {
		command_WritePipe 1 "tv-viewer_main record_linkerWizardReread"
	}
	if {$recmatch} {
		puts "Successfully deleted recording:
$::kanalid($::start_values(--station_ext)) $start_values(--start_date) $start_values(--start_time)"
	} else {
		puts "Can not delete recording:
$::kanalid($::start_values(--station_ext)) $start_values(--start_date) $start_values(--start_time)
Not found in scheduled recordings file."
	}
	flush stdout
	exit 0
}
