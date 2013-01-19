#       record_add.tcl
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

proc record_applyTimeDate {tree lb w handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_applyTimeDate \033\[0m \{$tree\} \{$lb\} \{$w\} \{$handler\}"
	set thour [scan $::record(time_hour) %d]
	set tmin [scan $::record(time_min) %d]
	if {$::option(rec_hour_format) == 24} {
		if {$thour > 23 || $thour < 0} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Time format incorrect (%-hour clock)!" $::option(rec_hour_format)]
			log_writeOut ::log(tvAppend) 1 "Time format incorrect (24-hour clock)."
			return
		}
	} else {
		if {$thour > 12 || $thour < 1} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Time format incorrect (%-hour clock)!" $::option(rec_hour_format)]
			log_writeOut ::log(tvAppend) 1 "Time format incorrect (12-hour clock)."
			return
		}
	}
	if {$tmin > 59 || $tmin < 0} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Time format incorrect (min)!"]
		log_writeOut ::log(tvAppend) 1 "Time format incorrect (min)."
		return
	}
	set curr_date [clock scan [clock format [clock scan now] -format "%Y%m%d"]]
	set chos_date [clock scan [clock format [clock scan $::record(date)] -format "%Y%m%d"]]
	foreach diff [difftime $chos_date $curr_date] {
		if {$diff < 0} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Chosen date is in the past!"]
			log_writeOut ::log(tvAppend) 1 "Chosen date is in the past."
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
			log_writeOut ::log(tvAppend) 1 "Time is in the past."
			return
		}
	}
	if {$::option(rec_hour_format) == 24} {
		log_writeOut ::log(tvAppend) 0 "Recording time $thour\:$tmin\, date $::record(date)."
		set recTimestamp [clock scan "$thour\:$tmin $::record(date)"]
	} else {
		log_writeOut ::log(tvAppend) 0 "Recording time $thour\:$tmin\ $::record(rbAddEditHour), date $::record(date)."
		set recTimestamp [clock scan "$thour\:$tmin $::record(rbAddEditHour) $::record(date)"]
	}
	record_applyDuration $tree $lb $w $handler $recTimestamp
}

proc record_applyDuration {tree lb w handler recTimestamp} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_applyDuration \033\[0m \{$tree\} \{$lb\} \{$w\} \{$handler\} \{$recTimestamp\}"
	set dhour [scan $::record(duration_hour) %d]
	set dmin [scan $::record(duration_min) %d]
	set dsec [scan $::record(duration_sec) %d]
	if {$dhour < 0 || $dhour > 99} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Duration not specified correctly (hour)!"]
		log_writeOut ::log(tvAppend) 1 "Duration not specified correctly (hour)."
		return
	}
	if {$dmin < 0 || $dmin > 59} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Duration not specified correctly (min)!"]
		log_writeOut ::log(tvAppend) 1 "Duration not specified correctly (min)."
		return
	}
	if {$dsec < 0 || $dsec > 59} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Duration not specified correctly (sec)!"]
		log_writeOut ::log(tvAppend) 1 "Duration not specified correctly (sec)."
		return
	}
	set duration_calc [expr ($dhour * 3600) + ($dmin * 60) + $dsec]
	set recEndStamp [expr $recTimestamp + $duration_calc]
	#Check for collisions
	set ts [clock seconds]
	puts "recTimestamp $recTimestamp"
	database eval {SELECT ID FROM RECORDINGS WHERE DATETIME > :ts AND :recTimestamp > DATETIME AND :recTimestamp <= DATETIME+DURATION} testrec {
		puts "Collision check 1: $testrec(ID)"
	}
	database eval {SELECT ID FROM RECORDINGS WHERE RUNNING = 1 AND :recTimestamp <= DATETIME+DURATION} testrec {
		puts "Collision check 2: $testrec(ID)"
	}
	database eval {SELECT ID FROM RECORDINGS WHERE DATETIME > :ts AND :recTimestamp < DATETIME AND :recEndStamp >= DATETIME} testrec {
		puts "Collision check 3: $testrec(ID)"
	}
	set collision 0
	if {"$handler" == "add"} {
		if {[database exists {SELECT ID FROM RECORDINGS WHERE DATETIME > :ts AND :recTimestamp > DATETIME AND :recTimestamp <= DATETIME+DURATION}] || [database exists {SELECT ID FROM RECORDINGS WHERE DATETIME > :ts AND :recTimestamp < DATETIME AND :recEndStamp >= DATETIME}]} {
			set collision 1
		}
		set status_record [monitor_partRunning 3]
		if {[lindex $status_record 0] == 1} {
			#running recording, now check if starttime is smaller/similar to endtime of recording already running
			if {[database exists {SELECT ID FROM RECORDINGS WHERE RUNNING = 1 AND :recTimestamp <= DATETIME+DURATION}]} {
				set collision 1
			}
		}
	} else {
		set jobID [lindex [$tree item [$tree selection] -values] 0]
		if {[database exists {SELECT ID FROM RECORDINGS WHERE DATETIME > :ts AND :recTimestamp > DATETIME AND :recTimestamp <= DATETIME+DURATION AND ID <> :jobID}] || [database exists {SELECT ID FROM RECORDINGS WHERE DATETIME > :ts AND :recTimestamp < DATETIME AND :recEndStamp >= DATETIME AND ID <> :jobID}]} {
			set collision 1
		}
		set status_record [monitor_partRunning 3]
		if {[lindex $status_record 0] == 1} {
			#running recording, now check if starttime is smaller/similar to endtime of recording already running
			if {[database exists {SELECT ID FROM RECORDINGS WHERE RUNNING = 1 AND :recTimestamp <= DATETIME+DURATION}]} {
				set collision 1
			}
		}
	}
	if {$collision} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Time collision detected. Check scheduled or running recordings."]
		log_writeOut ::log(tvAppend) 1 "Time collision detected. Check scheduled or running recordings."
		return
	}
	log_writeOut ::log(tvAppend) 0 "Duration $duration_calc seconds."
	record_applyResolution $tree $lb $duration_calc $w $handler $recTimestamp
}

proc record_applyResolution {tree lb duration_calc w handler recTimestamp} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_applyResolution \033\[0m \{$tree\} \{$lb\} \{$duration_calc\} \{$w\} \{$handler\} \{$recTimestamp\}"
	if {[string tolower $::option(video_standard)] == "ntsc" } {
		if {$::record(resolution_width) > 720 || $::record(resolution_width) < 0 || $::record(resolution_height) > 480 || $::record(resolution_height) < 0} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Resolution format incorrect!"]
			log_writeOut ::log(tvAppend) 1 "Resolution format incorrect."
			return
		}
	} else {
		if {$::record(resolution_width) > 720 || $::record(resolution_width) < 0 || $::record(resolution_height) > 576 || $::record(resolution_height) < 0} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Resolution format incorrect!"]
			log_writeOut ::log(tvAppend) 1 "Resolution format incorrect."
			return
		}
	}
	log_writeOut ::log(tvAppend) 0 "Resolution $::record(resolution_width)/$::record(resolution_height)."
	record_applyFile $tree $lb $duration_calc $w $handler $recTimestamp
}

proc record_applyFile {tree lb duration_calc w handler recTimestamp} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_applyFile \033\[0m \{$tree\} \{$lb\} \{$duration_calc\} \{$w\} \{$handler\} \{$recTimestamp\}"
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
	log_writeOut ::log(tvAppend) 0 "Record file $::record(file)."
	record_applyEndgame $tree $lb $duration_calc $w $handler $recTimestamp
}

proc record_applyEndgame {tree lb duration_calc w handler recTimestamp} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_applyEndgame \033\[0m \{$tree\} \{$lb\} \{$duration_calc\} \{$w\} \{$handler\} \{$recTimestamp\}"
	
	set status [monitor_partRunning 2]
	if {[lindex $status 0] == 1} {
		set start 0
	} else {
		set start 1
	}
	set lbindex [$lb curselection]
	set ::record(lbcontent) [$lb get $lbindex]
	set recResolution $::record(resolution_width)\/$::record(resolution_height)
	
	if {"$handler" == "add"} {
		database transaction {
			database eval {INSERT INTO RECORDINGS (STATION, DATETIME, DURATION, RERUN, RERUNS, RESOLUTION, OUTPUT) VALUES (:::record(lbcontent), :recTimestamp, :duration_calc, :::record(rbRepeat), :::record(sbRepeat), :recResolution, :::record(file))}
		}
		set lastID [database last_insert_rowid]
		
		if {$::option(rec_hour_format) == 24} {
			log_writeOut ::log(tvAppend) 0 "Adding new recording:"
			log_writeOut ::log(tvAppend) 0 "$lastID $::record(lbcontent) $::record(time_hour)\:$::record(time_min) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(rbRepeat) $::record(sbRepeat) $::record(resolution_width)\/$::record(resolution_height) $::record(file)"
		} else {
			log_writeOut ::log(tvAppend) 0 "Adding new recording:"
			log_writeOut ::log(tvAppend) 0 "$lastID $::record(lbcontent) $::record(time_hour)\:$::record(time_min) $::record(rbAddEditHour) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(rbRepeat) $::record(sbRepeat) $::record(resolution_width)\/$::record(resolution_height) $::record(file)"
		}
		
		database eval {SELECT * FROM RECORDINGS WHERE ID = :lastID} newRec {
			$tree insert {} end -values [list $newRec(ID) $newRec(STATION) [clock format $newRec(DATETIME) -format {%H:%M}] [clock format $newRec(DATETIME) -format {%Y-%m-%d}] [clock format $newRec(DURATION) -format {%H:%M:%S} -timezone :UTC] $newRec(RERUN) $newRec(RERUNS) $newRec(RESOLUTION) $newRec(OUTPUT)]
		}
		
		$tree selection set [lindex [$tree children {}] end]
		$tree see [$tree selection]
	} else {
		set jobID [lindex [$tree item [$tree selection] -values] 0]
		database transaction {
			database eval {UPDATE RECORDINGS SET STATION = :::record(lbcontent), DATETIME = :recTimestamp, DURATION = :duration_calc, RERUN = :::record(rbRepeat), RERUNS = :::record(sbRepeat), RESOLUTION = :recResolution, OUTPUT = :::record(file) WHERE ID = :jobID}
		}
		
		if {$::option(rec_hour_format) == 24} {
			log_writeOut ::log(tvAppend) 0 "Edit recording:"
			log_writeOut ::log(tvAppend) 0 "$jobID $::record(lbcontent) $::record(time_hour)\:$::record(time_min) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(rbRepeat) $::record(sbRepeat) $::record(resolution_width)\/$::record(resolution_height) $::record(file)"
		} else {
			log_writeOut ::log(tvAppend) 0 "Edit recording:"
			log_writeOut ::log(tvAppend) 0 "$jobID $::record(lbcontent) $::record(time_hour)\:$::record(time_min) $::record(rbAddEditHour) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(rbRepeat) $::record(sbRepeat) $::record(resolution_width)\/$::record(resolution_height) $::record(file)"
		}
		
		database eval {SELECT * FROM RECORDINGS WHERE ID = :jobID} newRec {
			$tree item [$tree selection] -values [list $newRec(ID) $newRec(STATION) [clock format $newRec(DATETIME) -format {%H:%M}] [clock format $newRec(DATETIME) -format {%Y-%m-%d}] [clock format $newRec(DURATION) -format {%H:%M:%S} -timezone :UTC] $newRec(RERUN) $newRec(RERUNS) $newRec(RESOLUTION) $newRec(OUTPUT)]
		}
		$tree see [$tree selection]
	}
	
	unset -nocomplain ::record(lbcontent) ::record(time_hour) ::record(time_min) ::record(date) ::record(duration_hour) ::record(duration_min) ::record(duration_sec) ::record(rbRepeat) ::record(sbRepeat) ::record(resolution_width) ::record(resolution_height) ::record(file)
	if {$start} {
		log_writeOut ::log(tvAppend) 0 "Updating database and execute scheduler"
		catch {exec ""}
		if {$::option(tclkit) == 1} {
			catch {exec $::option(tclkit_path) $::option(root)/data/scheduler.tcl &}
		} else {
			catch {exec "$::option(root)/data/scheduler.tcl" &}
		}
	} else {
		log_writeOut ::log(tvAppend) 0 "Updating database and reinitiating scheduler"
		set status [monitor_partRunning 2]
		if {[lindex $status 0] == 1} {
			command_WritePipe 0 "tv-viewer_scheduler scheduler_Init 1"
		}
	}
	log_writeOut ::log(tvAppend) 0 "Exiting 'add/edit recording'."
	vid_wmCursor 1
	grab release $w
	destroy $w
}
