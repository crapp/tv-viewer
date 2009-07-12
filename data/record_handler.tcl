#       record_add.tcl
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

proc record_applyTimeDate {tree lb w handler} {
	set thour [scan $::record(time_hour) %d]
	set tmin [scan $::record(time_min) %d]
	if {$thour > 23 || $thour < 0} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Time format incorrect (hour)!"]
		puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Time format incorrect (hour)."
		flush $::logf_tv_open_append
		return
	}
	if {$tmin > 59 || $tmin < 0} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Time format incorrect (min)!"]
		puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Time format incorrect (min)."
		flush $::logf_tv_open_append
		return
	}
	set curr_date [clock scan [clock format [clock scan now] -format "%Y%m%d"]]
	set chos_date [clock scan [clock format [clock scan $::record(date)] -format "%Y%m%d"]]
	foreach diff [main_newsreaderDifftimes $chos_date $curr_date] {
		if {$diff < 0} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Chosen date is in the past!"]
			puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Chosen date is in the past."
			flush $::logf_tv_open_append
			return
		}
	}
	if {$curr_date == $chos_date} {
		set timeoff [expr {([clock scan $::record(time_hour)\:$::record(time_min)]-[clock seconds])*1000}]
		if {$timeoff < -500000} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Time is in the past!"]
			puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Time is in the past."
			flush $::logf_tv_open_append
			return
		}
	}
	puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Recording time $thour\:$tmin\, date $::record(date)."
	flush $::logf_tv_open_append
	record_applyDuration $tree $lb $w $handler
}

proc record_applyDuration {tree lb w handler} {
	set dhour [scan $::record(duration_hour) %d]
	set dmin [scan $::record(duration_min) %d]
	set dsec [scan $::record(duration_sec) %d]
	if {$dhour < 0 || $dhour > 99} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Duration not specified correctly (hour)!"]
		puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Duration not specified correctly (hour)."
		flush $::logf_tv_open_append
		return
	}
	if {$dmin < 0 || $dmin > 59} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Duration not specified correctly (min)!"]
		puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Duration not specified correctly (min)."
		flush $::logf_tv_open_append
		return
	}
	if {$dsec < 0 || $dsec > 59} {
		$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Duration not specified correctly (sec)!"]
		puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Duration not specified correctly (sec)."
		flush $::logf_tv_open_append
		return
	}
	set duration_calc [expr ($dhour * 3600) + ($dmin * 60) + $dsec]
	puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Duration $duration_calc seconds."
	flush $::logf_tv_open_append
	record_applyResolution $tree $lb $duration_calc $w $handler
}

proc record_applyResolution {tree lb duration_calc w handler} {
	if {[string tolower $::option(video_standard)] == "ntsc" } {
		if {$::record(resolution_width) > 720 || $::record(resolution_width) < 0 || $::record(resolution_height) > 480 || $::record(resolution_height) < 0} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Resolution format incorrect!"]
			puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Resolution format incorrect."
			flush $::logf_tv_open_append
			return
		}
	} else {
		if {$::record(resolution_width) > 720 || $::record(resolution_width) < 0 || $::record(resolution_height) > 576 || $::record(resolution_height) < 0} {
			$w.record_frame.l_warning configure -image $::icon_m(dialog-warning) -text [mc "Resolution format incorrect!"]
			puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Resolution format incorrect."
			flush $::logf_tv_open_append
			return
		}
	}
	puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Resolution $::record(resolution_width)/$::record(resolution_height)."
	flush $::logf_tv_open_append
	record_applyFile $tree $lb $duration_calc $w $handler
}

proc record_applyFile {tree lb duration_calc w handler} {
	if {[string trim [string length $::record(time_min)]] < 2} {
		set ::record(time_min) "0$::record(time_min)"
	}
	if {[info exists ::record(file)] != 1} {
		set lbindex [$lb curselection]
		set lbcontent [$lb get $lbindex]
		$w.record_frame.ent_file state !disabled
		set ::record(file) "[subst $::option(rec_default_path)]/[string map {{ } {}} [string map {{/} {}} $lbcontent]]\_$::record(date)\_$::record(time_hour)\:$::record(time_min).mpeg"
		$w.record_frame.ent_file state disabled
	} else {
		if {[string trim $::record(file)] == {}} {
			set lbindex [$lb curselection]
			set lbcontent [$lb get $lbindex]
			$w.record_frame.ent_file state !disabled
			set ::record(file) "[subst $::option(rec_default_path)]/[string map {{ } {}} [string map {{/} {}} $lbcontent]]\_$::record(date)\_$::record(time_hour)\:$::record(time_min).mpeg"
			$w.record_frame.ent_file state disabled
		}
	}
	puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Record file $::record(file)."
	flush $::logf_tv_open_append
	record_applyEndgame $tree $lb $duration_calc $w $handler
}

proc record_applyEndgame {tree lb duration_calc w handler} {
	if {[file exist "$::where_is_home/config/scheduler.conf"]} {
		set open_f [open "$::where_is_home/config/scheduler.conf" r]
		set jobid [read $open_f]
		incr jobid
		close $open_f
		set f_open [open "$::where_is_home/config/scheduler.conf" w]
		puts -nonewline $f_open "$jobid"
		close $f_open
	} else {
		set jobid 1
		set f_open [open "$::where_is_home/config/scheduler.conf" w]
		puts -nonewline $f_open "$jobid"
		close $f_open
	}
	catch {exec ""}
	set status_schedlinkread [catch {file readlink "$::where_is_home/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
	if { $status_schedlinkread == 0 } {
		catch {exec ps -eo "%p"} read_ps
		set status_greppid_sched [catch {agrep -w "$read_ps" $resultat_schedlinkread} resultat_greppid_sched]
		if { $status_greppid_sched == 0 } {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Scheduler is running, will stop it."
			flush $::logf_tv_open_append
			puts $::data(comsocket) "tv-viewer_scheduler scheduler_exit"
			flush $::data(comsocket)
		}
	}
	set lbindex [$lb curselection]
	set lbcontent [$lb get $lbindex]
	if {"$handler" == "add"} {
		$tree insert {} end -values [list $jobid "$lbcontent" $::record(time_hour)\:$::record(time_min) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) "$::record(file)"]
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Adding new recording:
# \[[clock format [clock scan now] -format {%H:%M:%S}]\] $jobid $lbcontent $::record(time_hour)\:$::record(time_min) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) $::record(file)"
		flush $::logf_tv_open_append
	} else {
		$tree item [$tree selection] -values [list [lindex [$tree item [$tree selection] -values] 0] "$lbcontent" $::record(time_hour)\:$::record(time_min) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) "$::record(file)"]
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Edit recording:
# \[[clock format [clock scan now] -format {%H:%M:%S}]\] [lindex [$tree item [$tree selection] -values] 0] $lbcontent $::record(time_hour)\:$::record(time_min) $::record(date) $::record(duration_hour)\:$::record(duration_min)\:$::record(duration_sec) $::record(resolution_width)\/$::record(resolution_height) $::record(file)"
		flush $::logf_tv_open_append
	}
	catch {file delete -force "$::where_is_home/config/scheduled_recordings.conf"}
	set f_open [open "$::where_is_home/config/scheduled_recordings.conf" a]
	foreach ritem [split [$tree children {}]] {
		puts $f_open "[lindex [$tree item $ritem -values] 0] \{[lindex [$tree item $ritem -values] 1]\} [lindex [$tree item $ritem -values] 2] [lindex [$tree item $ritem -values] 3] [lindex [$tree item $ritem -values] 4] [lindex [$tree item $ritem -values] 5] \{[lindex [$tree item $ritem -values] 6]\}"
	}
	close $f_open
	puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Writing new scheduled_recordings.conf and execute scheduler."
	flush $::logf_tv_open_append
	catch {exec "$::where_is/data/record_scheduler.tcl" &}
	unset -nocomplain ::record(time_hour) ::record(time_min) ::record(date) ::record(duration_hour) ::record(duration_min) ::record(duration_sec) ::record(resolution_width) ::record(resolution_height) ::record(file)
	after 2000 {
		catch {
			catch {exec ""}
			set status_schedlinkread [catch {file readlink "$::where_is_home/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
			if { $status_schedlinkread == 0 } {
				catch {exec ps -eo "%p"} read_ps
				set status_greppid_sched [catch {agrep -w "$read_ps" $resultat_schedlinkread} resultat_greppid_sched]
				if { $status_greppid_sched == 0 } {
					.record_wizard.status_frame.l_rec_sched_info configure -text [mc "Running"]
					.record_wizard.status_frame.b_rec_sched configure -text [mc "Stop Scheduler"] -command [list record_wizardScheduler .record_wizard.status_frame.b_rec_sched .record_wizard.status_frame.l_rec_sched_info 0]
				} else {
					.record_wizard.status_frame.l_rec_sched_info configure -text [mc "Stopped"]
					.record_wizard.status_frame.b_rec_sched configure -text [mc "Start Scheduler"] -command [list record_wizardScheduler .record_wizard.status_frame.b_rec_sched .record_wizard.status_frame.l_rec_sched_info 1]
				}
			} else {
				.record_wizard.status_frame.l_rec_sched_info configure -text [mc "Stopped"]
				.record_wizard.status_frame.b_rec_sched configure -text [mc "Start Scheduler"] -command [list record_wizardScheduler .record_wizard.status_frame.b_rec_sched .record_wizard.status_frame.l_rec_sched_info 1]
			}
		}
	}
	puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Exiting 'add/edit recording'."
	flush $::logf_tv_open_append
	grab release $w
	destroy $w
}
