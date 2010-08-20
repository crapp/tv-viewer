#       record_add.tcl
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

proc record_applyTimeDate {tree lb w handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_applyTimeDate \033\[0m \{$tree\} \{$lb\} \{$w\} \{$handler\}"
	set thour [scan $::record(time_hour) %d]
	set tmin [scan $::record(time_min) %d]
	if {$::option(rec_hour_format) == 24} {
		if {$thour > 23 || $thour < 0} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Time format incorrect (%-hour clock)!" $::option(rec_hour_format)]
			log_writeOutTv 2 "Time format incorrect (24-hour clock)."
			return
		}
	} else {
		if {$thour > 12 || $thour < 1} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Time format incorrect (%-hour clock)!" $::option(rec_hour_format)]
			log_writeOutTv 2 "Time format incorrect (12-hour clock)."
			return
		}
	}
	if {$tmin > 59 || $tmin < 0} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Time format incorrect (min)!"]
		log_writeOutTv 2 "Time format incorrect (min)."
		return
	}
	set curr_date [clock scan [clock format [clock scan now] -format "%Y%m%d"]]
	set chos_date [clock scan [clock format [clock scan $::record(date)] -format "%Y%m%d"]]
	foreach diff [difftime $chos_date $curr_date] {
		if {$diff < 0} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Chosen date is in the past!"]
			log_writeOutTv 2 "Chosen date is in the past."
			return
		}
	}
	if {$curr_date == $chos_date} {
		if {$::option(rec_hour_format) == 12} {
			if {"$::record(rbAddEditHour)" == "pm"} {
				set thour [expr $thour + 12]
				if {$thour > 23} {
					set thour 12
				}
			}
		}
		set timeoff [expr {([clock scan $thour\:$tmin]-[clock seconds])*1000}]
		if {$timeoff < -500000} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Time is in the past!"]
			log_writeOutTv 2 "Time is in the past."
			return
		}
	}
	if {$::option(rec_hour_format) == 24} {
		log_writeOutTv 0 "Recording time $thour\:$tmin\, date $::record(date)."
	} else {
		log_writeOutTv 0 "Recording time $thour\:$tmin\ $::record(rbAddEditHour), date $::record(date)."
	}
	record_applyDuration $tree $lb $w $handler
}

proc record_applyDuration {tree lb w handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_applyDuration \033\[0m \{$tree\} \{$lb\} \{$w\} \{$handler\}"
	set dhour [scan $::record(duration_hour) %d]
	set dmin [scan $::record(duration_min) %d]
	set dsec [scan $::record(duration_sec) %d]
	if {$dhour < 0 || $dhour > 99} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Duration not specified correctly (hour)!"]
		log_writeOutTv 2 "Duration not specified correctly (hour)."
		return
	}
	if {$dmin < 0 || $dmin > 59} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Duration not specified correctly (min)!"]
		log_writeOutTv 2 "Duration not specified correctly (min)."
		return
	}
	if {$dsec < 0 || $dsec > 59} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Duration not specified correctly (sec)!"]
		log_writeOutTv 2 "Duration not specified correctly (sec)."
		return
	}
	set duration_calc [expr ($dhour * 3600) + ($dmin * 60) + $dsec]
	log_writeOutTv 0 "Duration $duration_calc seconds."
	record_applyResolution $tree $lb $duration_calc $w $handler
}

proc record_applyResolution {tree lb duration_calc w handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_applyResolution \033\[0m \{$tree\} \{$lb\} \{$duration_calc\} \{$w\} \{$handler\}"
	if {[string tolower $::option(video_standard)] == "ntsc" } {
		if {$::record(resolution_width) > 720 || $::record(resolution_width) < 0 || $::record(resolution_height) > 480 || $::record(resolution_height) < 0} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Resolution format incorrect!"]
			log_writeOutTv 2 "Resolution format incorrect."
			return
		}
	} else {
		if {$::record(resolution_width) > 720 || $::record(resolution_width) < 0 || $::record(resolution_height) > 576 || $::record(resolution_height) < 0} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Resolution format incorrect!"]
			log_writeOutTv 2 "Resolution format incorrect."
			return
		}
	}
	log_writeOutTv 0 "Resolution $::record(resolution_width)/$::record(resolution_height)."
	record_applyFile $tree $lb $duration_calc $w $handler
}

proc record_applyFile {tree lb duration_calc w handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_applyFile \033\[0m \{$tree\} \{$lb\} \{$duration_calc\} \{$w\} \{$handler\}"
	if {[string trim [string length $::record(time_min)]] < 2} {
		set ::record(time_min) "0$::record(time_min)"
	}
	if {[info exists ::record(file)] != 1} {
		set lbindex [$lb curselection]
		set lbcontent [$lb get $lbindex]
		set ::record(file) "[subst $::option(rec_default_path)]/[string map {{ } {}} [string map {{/} {}} $lbcontent]]\_$::record(date)\_$::record(time_hour)\:$::record(time_min).mpeg"
	} else {
		if {[string trim $::record(file)] == {}} {
			set lbindex [$lb curselection]
			set lbcontent [$lb get $lbindex]
			set ::record(file) "[subst $::option(rec_default_path)]/[string map {{ } {}} [string map {{/} {}} $lbcontent]]\_$::record(date)\_$::record(time_hour)\:$::record(time_min).mpeg"
		}
	}
	log_writeOutTv 0 "Record file $::record(file)."
	record_applyEndgame $tree $lb $duration_calc $w $handler
}

proc record_applyEndgame {tree lb duration_calc w handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_applyEndgame \033\[0m \{$tree\} \{$lb\} \{$duration_calc\} \{$w\} \{$handler\}"
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
	set lbindex [$lb curselection]
	set ::record(lbcontent) [$lb get $lbindex]
	if {"$handler" == "add"} {
		if {$::option(rec_hour_format) == 24} {
			$tree insert {} end -values [list $jobid "$::record(lbcontent)" $::record(time_hour)\:$::record(time_min) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) "$::record(file)"]
			log_writeOutTv 0 "Adding new recording:"
			log_writeOutTv 0 "$jobid $::record(lbcontent) $::record(time_hour)\:$::record(time_min) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) $::record(file)"
		} else {
			$tree insert {} end -values [list $jobid "$::record(lbcontent)" "$::record(time_hour)\:$::record(time_min) $::record(rbAddEditHour)" $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) "$::record(file)"]
			log_writeOutTv 0 "Adding new recording:"
			log_writeOutTv 0 "$jobid $::record(lbcontent) $::record(time_hour)\:$::record(time_min) $::record(rbAddEditHour) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) $::record(file)"
		}
		$tree selection set [lindex [$tree children {}] end]
		$tree see [$tree selection]
	} else {
		if {$::option(rec_hour_format) == 24} {
			$tree item [$tree selection] -values [list [lindex [$tree item [$tree selection] -values] 0] "$::record(lbcontent)" $::record(time_hour)\:$::record(time_min) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) "$::record(file)"]
			log_writeOutTv 0 "Edit recording:"
			log_writeOutTv 0 "[lindex [$tree item [$tree selection] -values] 0] $::record(lbcontent) $::record(time_hour)\:$::record(time_min) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) $::record(file)"
		} else {
			$tree item [$tree selection] -values [list [lindex [$tree item [$tree selection] -values] 0] "$::record(lbcontent)" "$::record(time_hour)\:$::record(time_min) $::record(rbAddEditHour)" $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) "$::record(file)"]
			log_writeOutTv 0 "Edit recording:"
			log_writeOutTv 0 "[lindex [$tree item [$tree selection] -values] 0] $::record(lbcontent) $::record(time_hour)\:$::record(time_min) $::record(rbAddEditHour) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) $::record(file)"
		}
		$tree see [$tree selection]
	}
	catch {file delete -force "$::option(home)/config/scheduled_recordings.conf"}
	set f_open [open "$::option(home)/config/scheduled_recordings.conf" a]
	foreach ritem [split [$tree children {}]] {
		puts $f_open "[lindex [$tree item $ritem -values] 0] \{[lindex [$tree item $ritem -values] 1]\} \{[lindex [$tree item $ritem -values] 2]\} [lindex [$tree item $ritem -values] 3] [lindex [$tree item $ritem -values] 4] [lindex [$tree item $ritem -values] 5] \{[lindex [$tree item $ritem -values] 6]\}"
	}
	close $f_open
	unset -nocomplain ::record(lbcontent) ::record(time_hour) ::record(time_min) ::record(date) ::record(duration_hour) ::record(duration_min) ::record(duration_sec) ::record(resolution_width) ::record(resolution_height) ::record(file)
	if {$start} {
		log_writeOutTv 0 "Writing new scheduled_recordings.conf and execute scheduler."
		catch {exec ""}
		catch {exec "$::option(root)/data/scheduler.tcl" &}
	} else {
		log_writeOutTv 0 "Writing new scheduled_recordings.conf"
		log_writeOutTv 0 "Reinitiating scheduler"
		set status [monitor_partRunning 2]
		if {[lindex $status 0] == 1} {
			command_WritePipe 0 "tv-viewer_scheduler scheduler_Init 1"
		}
	}
	log_writeOutTv 0 "Exiting 'add/edit recording'."
	grab release $w
	destroy $w
}
