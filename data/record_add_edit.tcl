#       record_add_edit.tcl
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

proc record_add_edit {tree com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_edit \033\[0m \{$tree\} \{$com\}"
	if {$com == 1} {
		if {[string trim [$tree selection]] == {}} {
			log_writeOutTv 1 "No recording selected to edit."
			return
		}
		if {[llength [$tree selection]] > 1} {
			log_writeOutTv 1 "Can not edit more than one recording at a time."
			return
		}
	}
	log_writeOutTv 0 "Building record add/edit dialogue."
	set w [toplevel .record_wizard.add_edit] ; place [ttk::label .record_wizard.add_edit.bg -style Toolbutton] -relwidth 1 -relheight 1
	set lbf [ttk::frame $w.listbox_frame]
	set recf [ttk::frame $w.record_frame]
	set bf [ttk::frame $w.button_frame -style TLabelframe]
	
	listbox $lbf.lb_stations \
	-yscrollcommand [list $lbf.scrollbar_stations set] \
	-exportselection false \
	-takefocus 0 \
	-width 0
	ttk::scrollbar $lbf.scrollbar_stations \
	-orient vertical \
	-command [list $lbf.lb_stations yview]
	
	ttk::labelframe $recf.lf_rec_values \
	-text [mc "Record options"]
	ttk::label $recf.l_time \
	-text [mc "Time:"]
	
	proc record_add_editTimeHourValidate {value widget} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editTimeHourValidate \033\[0m \{$value\} \{$widget\}"
		if {[string is integer $value] != 1 || [string length $value] > 2} {
			return 0
		} else {
			return 1
		}
	}
	proc record_add_editTimeMinValidate {value widget} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editTimeMinValidate \033\[0m \{$value\} \{$widget\}"
		if {[string is integer $value] != 1 || [string length $value] > 2} {
			return 0
		} else {
			return 1
		}
	}
	
	spinbox $recf.sb_time_hour \
	-from -1 \
	-to 24 \
	-width 3 \
	-validate key \
	-vcmd {record_add_editTimeHourValidate %P %W} \
	-repeatinterval 80 \
	-command record_add_editTimeHour \
	-textvariable record(time_hour)
	ttk::label $recf.l_time_colon \
	-text ":"
	spinbox $recf.sb_time_min \
	-from -1 \
	-to 60 \
	-width 3 \
	-validate key \
	-vcmd {record_add_editTimeMinValidate %P %W} \
	-repeatinterval 25 \
	-command record_add_editTimeMin \
	-textvariable record(time_min)
	ttk::separator $recf.sep1 \
	-orient vertical
	ttk::label $recf.l_date \
	-text [mc "Date:"]
	ttk::entry $recf.ent_date \
	-textvariable record(date) \
	-width 11 \
	-state disabled
	ttk::button $recf.b_date \
	-width 0 \
	-compound image \
	-image $::icon_s(calendar) \
	-command record_add_editDate
	ttk::separator $recf.sep2 \
	-orient horizontal
	ttk::label $recf.l_duration \
	-text [mc "Duration:"]
	
	proc record_add_editDurHourValidate {value widget} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDurHourValidate \033\[0m \{$value\} \{$widget\}"
		if {[string is integer $value] != 1 || [string length $value] > 2} {
			return 0
		} else {
			return 1
		}
	}
	proc record_add_editDurMinValidate {value widget} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDurMinValidate \033\[0m \{$value\} \{$widget\}"
		if {[string is integer $value] != 1 || [string length $value] > 2} {
			return 0
		} else {
			return 1
		}
	}
	proc record_add_editDurSecValidate {value widget} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDurSecValidate \033\[0m \{$value\} \{$widget\}"
		if {[string is integer $value] != 1 || [string length $value] > 2} {
			return 0
		} else {
			return 1
		}
	}
	
	spinbox $recf.sb_duration_hour \
	-from -1 \
	-to 99 \
	-width 3 \
	-validate key \
	-vcmd {record_add_editDurHourValidate %P %W} \
	-repeatinterval 25 \
	-command record_add_editDurHour \
	-textvariable record(duration_hour)
	ttk::label $recf.l_duration_colon1 \
	-text ":"
	spinbox $recf.sb_duration_min \
	-from -1 \
	-to 60 \
	-width 3 \
	-validate key \
	-vcmd {record_add_editDurMinValidate %P %W} \
	-repeatinterval 25 \
	-command record_add_editDurMin \
	-textvariable record(duration_min)
	ttk::label $recf.l_duration_colon2 \
	-text ":"
	spinbox $recf.sb_duration_sec \
	-from -1 \
	-to 60 \
	-width 3 \
	-validate key \
	-vcmd {record_add_editDurSecValidate %P %W} \
	-repeatinterval 25 \
	-command record_add_editDurSec \
	-textvariable record(duration_sec)
	ttk::separator $recf.sep3 \
	-orient vertical
	ttk::label $recf.l_resol \
	-text [mc "Resolution:"]
	
	proc record_add_editResolWidthValidate {value widget} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editResolWidthValidate \033\[0m \{$value\} \{$widget\}"
		if {[string is digit $value] != 1 || [string length $value] > 3} {
			return 0
		} else {
			return 1
		}
	}
	proc record_add_editResolHeightValidate {value widget} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editResolHeightValidate \033\[0m \{$value\} \{$widget\}"
		if {[string is digit $value] != 1 || [string length $value] > 3} {
			return 0
		} else {
			return 1
		}
	}
	
	spinbox $recf.sb_resol_width \
	-from 99 \
	-to 721 \
	-width 3 \
	-validate key \
	-vcmd {record_add_editResolWidthValidate %P %W} \
	-repeatinterval 10 \
	-command record_add_editResolWidth \
	-textvariable record(resolution_width)
	ttk::label $recf.l_resol_slash \
	-text "/"
	spinbox $recf.sb_resol_height \
	-width 3 \
	-validate key \
	-vcmd {record_add_editResolHeightValidate %P %W} \
	-repeatinterval 10 \
	-command record_add_editResolHeight \
	-textvariable record(resolution_height)
	if {"$::option(video_standard)" == "NTSC"} {
		$recf.sb_resol_height configure -from 99 -to 481
		set ::record(resolution_height_max) 480
		set ::record(resolution_height_min) 100
	} else {
		$recf.sb_resol_height configure -from 99 -to 577
		set ::record(resolution_height_max) 576
		set ::record(resolution_height_min) 100
	}
	
	ttk::labelframe $recf.lf_rec_file \
	-text [mc "Output file"]
	ttk::entry $recf.ent_file \
	-textvariable record(file) \
	-state disabled
	ttk::button $recf.b_file \
	-text "..." \
	-width 3 \
	-command [list record_add_editOfile $w]
	
	ttk::label $recf.l_warning \
	-compound left
	
	ttk::button $bf.b_apply \
	-text [mc "Apply"] \
	-compound left \
	-image $::icon_s(dialog-ok-apply)
	
	ttk::button $bf.b_cancel \
	-text [mc "Cancel"] \
	-compound left \
	-image $::icon_s(dialog-cancel) \
	-command [list record_add_editExit $w]
	
	grid rowconfigure $w 1 -weight 0
	grid rowconfigure $recf.lf_rec_values {0 2} -weight 1
	grid columnconfigure $w 1 -weight 1
	grid columnconfigure $recf.lf_rec_file 0 -weight 1
	grid columnconfigure $recf.lf_rec_values 0 -weight 1
	
	grid $lbf -in $w -row 0 -column 0 \
	-sticky nesw
	grid $recf -in $w -row 0 -column 1 \
	-sticky nesw
	grid $bf -in $w -row 1 -column 0 \
	-columnspan 2 \
	-sticky ew \
	-padx 3 \
	-pady 3
	grid anchor $bf e
	
	grid $lbf.lb_stations -in $lbf -row 0 -column 0 \
	-sticky nesw
	grid $lbf.scrollbar_stations -in $lbf -row 0 -column 1 \
	-sticky ns
	
	grid $recf.lf_rec_values -in $recf -row 0 -column 0 \
	-sticky new \
	-padx 5 \
	-pady 6
	grid $recf.l_time -in $recf.lf_rec_values -row 0 -column 0 \
	-sticky w \
	-padx 5 \
	-pady 3
	grid $recf.sb_time_hour -in $recf.lf_rec_values -row 0 -column 1 \
	-sticky w \
	-padx "0 2" \
	-pady 3
	grid $recf.l_time_colon -in $recf.lf_rec_values -row 0 -column 2 \
	-padx "0 2" \
	-pady 3
	grid $recf.sb_time_min -in $recf.lf_rec_values -row 0 -column 3 \
	-sticky w \
	-padx "0 5" \
	-pady 3
	grid $recf.sep1 -in $recf.lf_rec_values -row 0 -column 6 \
	-sticky ns \
	-padx 2
	grid $recf.l_date -in $recf.lf_rec_values -row 0 -column 7 \
	-sticky w \
	-padx 5 \
	-pady 3
	grid $recf.ent_date -in $recf.lf_rec_values -row 0 -column 8 \
	-sticky w \
	-padx "0 5" \
	-pady 3 \
	-columnspan 3
	grid $recf.b_date -in $recf.lf_rec_values -row 0 -column 11 \
	-sticky w \
	-padx "0 5" \
	-pady 3
	
	grid $recf.sep2 -in $recf.lf_rec_values -row 1 -column 0 \
	-sticky ew \
	-columnspan 12 \
	-padx 3
	
	grid $recf.l_duration -in $recf.lf_rec_values -row 2 -column 0 \
	-sticky w \
	-padx 5 \
	-pady "5 11"
	grid $recf.sb_duration_hour -in $recf.lf_rec_values -row 2 -column 1 \
	-sticky w \
	-padx "0 2" \
	-pady "5 11"
	grid $recf.l_duration_colon1 -in $recf.lf_rec_values -row 2 -column 2 \
	-padx "0 2" \
	-pady "5 11"
	grid $recf.sb_duration_min -in $recf.lf_rec_values -row 2 -column 3 \
	-sticky w \
	-padx "0 2" \
	-pady "5 11"
	grid $recf.l_duration_colon2 -in $recf.lf_rec_values -row 2 -column 4 \
	-padx "0 2" \
	-pady "5 11"
	grid $recf.sb_duration_sec -in $recf.lf_rec_values -row 2 -column 5 \
	-sticky w \
	-padx "0 5" \
	-pady "5 11"
	grid $recf.sep3 -in $recf.lf_rec_values -row 2 -column 6 \
	-sticky ns \
	-padx 2 \
	-pady "0 5"
	grid $recf.l_resol -in $recf.lf_rec_values -row 2 -column 7 \
	-sticky w \
	-padx 5 \
	-pady "5 11"
	grid $recf.sb_resol_width -in $recf.lf_rec_values -row 2 -column 8 \
	-sticky w \
	-padx "0 2" \
	-pady "5 11"
	grid $recf.l_resol_slash -in $recf.lf_rec_values -row 2 -column 9 \
	-padx "0 2" \
	-pady "5 11"
	grid $recf.sb_resol_height -in $recf.lf_rec_values -row 2 -column 10 \
	-sticky w \
	-padx "0 5" \
	-pady "5 11"
	
	grid $recf.lf_rec_file -in $recf -row 1 -column 0 \
	-sticky new \
	-padx 5 \
	-pady "0 6"
	grid $recf.ent_file -in $recf.lf_rec_file -row 0 -column 0 \
	-sticky ew \
	-padx 5 \
	-pady 3
	grid $recf.b_file -in $recf.lf_rec_file -row 0 -column 1 \
	-padx "0 5" \
	-pady 3
	
	grid $recf.l_warning -in $recf -row 2 -column 0 \
	-sticky w \
	-padx "5 0" \
	-pady 3
	
	grid $bf.b_apply -in $bf -row 0 -column 0 \
	-pady 7 \
	-padx 3
	grid $bf.b_cancel -in $bf -row 0 -column 1 \
	-pady 7 \
	-padx "0 3"
	
	wm resizable $w 0 0
	if {$com == 0} {
		wm title $w [mc "Add a new recording"]
	} else {
		wm title $w [mc "Edit recording"]
	}
	wm protocol $w WM_DELETE_WINDOW "record_add_editExit $w"
	wm iconphoto $w $::icon_b(record)
	wm transient $w .record_wizard
	
	proc record_add_editTimeHour {} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editTimeHour \033\[0m"
		if {$::record(time_hour) < 0} {
			set ::record(time_hour) 23
		}
		if {$::record(time_hour) > 23} {
			set ::record(time_hour) 0
		}
	}
	proc record_add_editTimeMin {} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editTimeMin \033\[0m"
		if {$::record(time_min) >= 60} {
			set ::record(time_min) 0
			if {$::record(time_hour) < 24} {
				set ::record(time_hour) [expr $::record(time_hour) + 1]
				record_add_editTimeHour
			}
		}
		if {$::record(time_min) <= -1} {
			set ::record(time_min) 59
			if {$::record(time_hour) > -1} {
				set ::record(time_hour) [expr $::record(time_hour) - 1]
				record_add_editTimeHour
			}
		}
	}
	
	proc record_add_editDurHour {} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDurHour \033\[0m"
		if {$::record(duration_hour) > 98} {
			set ::record(duration_hour) 0
		}
		if {$::record(duration_hour) < 0} {
			set ::record(duration_hour) 98
		}
	}
	proc record_add_editDurMin {} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDurMin \033\[0m"
		if {$::record(duration_min) == 60} {
			set ::record(duration_min) 0
			set ::record(duration_hour) [expr $::record(duration_hour) + 1]
			record_add_editDurHour
		}
		if {$::record(duration_min) < 0} {
			set ::record(duration_min) 59
			set ::record(duration_hour) [expr $::record(duration_hour) - 1]
			record_add_editDurHour
		}
	}
	proc record_add_editDurSec {} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDurSec\033\[0m"
		if {$::record(duration_sec) >= 60} {
			set ::record(duration_sec) 0
			set ::record(duration_min) [expr $::record(duration_min) + 1]
			record_add_editDurMin
		}
		if {$::record(duration_sec) < 0} {
			set ::record(duration_sec) 59
			set ::record(duration_min) [expr $::record(duration_min) - 1]
			record_add_editDurMin
		}
	}
	
	proc record_add_editResolWidth {} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editResolWidth \033\[0m"
		if {$::record(resolution_width) > 720} {
			set ::record(resolution_width) 100
		}
		if {$::record(resolution_width) < 100} {
			set ::record(resolution_width) 720
		}
	}
	proc record_add_editResolHeight {} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editResolHeight \033\[0m"
		if {$::record(resolution_height) > $::record(resolution_height_max)} {
			set ::record(resolution_height) 100
		}
		if {$::record(resolution_height) < 100} {
			set ::record(resolution_height) $::record(resolution_height_max)
		}
	}
	
	for {set i 1} {$i <= $::station(max)} {incr i} {
		$lbf.lb_stations insert end $::kanalid($i)
	}
	
	if {$com == 0} {
		$lbf.lb_stations see [expr [lindex $::station(last) 2] - 1]
		$lbf.lb_stations activate [expr [lindex $::station(last) 2] - 1]
		$lbf.lb_stations selection set [expr [lindex $::station(last) 2] - 1]
		
		$bf.b_apply configure -command [list record_applyTimeDate $tree $lbf.lb_stations $w add]
		set ::record(time_hour) [scan [clock format [clock scan now] -format %H] %d]
		set ::record(time_min) [scan [clock format [clock scan now] -format %M] %d]
		set ::record(date) [clock format [clock scan now] -format {%Y-%m-%d}]
		set ::record(duration_hour) [scan $::option(rec_duration_hour) %d]
		set ::record(duration_min) [scan $::option(rec_duration_min) %d]
		set ::record(duration_sec) [scan $::option(rec_duration_sec) %d]
		set ::record(resolution_width) 720
		if {"$::option(video_standard)" == "NTSC"} {
			set ::record(resolution_height) 480
		} else {
			set ::record(resolution_height) 576
		}
	} else {
		set station [lindex [$tree item [$tree selection] -values] 1]
		for {set i 1} {$i <= $::station(max)} {incr i} {
			if {"$::kanalid($i)" == "$station"} {
				$lbf.lb_stations see [expr $i - 1]
				$lbf.lb_stations activate [expr $i - 1]
				$lbf.lb_stations selection set [expr $i - 1]
				break
			}
		}
		$bf.b_apply configure -command [list record_applyTimeDate $tree $lbf.lb_stations $w edit]
		foreach {thour tmin} [split [lindex [$tree item [$tree selection] -values] 2] :] {
			set ::record(time_hour) [scan $thour %d]
			set ::record(time_min) [scan $tmin %d]
		}
		set ::record(date) [lindex [$tree item [$tree selection] -values] 3]
		foreach {dhour dmin dsec} [split [lindex [$tree item [$tree selection] -values] 4] :] {
			set ::record(duration_hour) $dhour
			set ::record(duration_min) $dmin
			set ::record(duration_sec) $dsec
		}
		foreach {rwidth rheight} [split [lindex [$tree item [$tree selection] -values] 5] "/"] {
			set ::record(resolution_width) $rwidth
			set ::record(resolution_height) $rheight
		}
		set ::record(file) [lindex [$tree item [$tree selection] -values] 6]
	}
	
	if {$::option(tooltips) == 1} {
		if {$::option(tooltips_record) == 1} {
			settooltip $lbf.lb_stations [mc "Choose station to record."]
			settooltip $recf.sb_time_hour [mc "Time when recording should start. (Hour)"]
			settooltip $recf.sb_time_min [mc "Time when recording should start. (Minute)"]
			settooltip $recf.ent_date [mc "Choose date on which recording should occur."]
			settooltip $recf.b_date [mc "Choose date on which recording should occur."]
			settooltip $recf.sb_duration_hour [mc "Duration for the recording. (Hours)"]
			settooltip $recf.sb_duration_min [mc "Duration for the recording. (Minutes)"]
			settooltip $recf.sb_duration_sec [mc "Duration for the recording. (Seconds)"]
			settooltip $recf.sb_resol_width [mc "Resolution (width) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards."]
 			settooltip $recf.sb_resol_width [mc "Resolution (height) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards."]
			settooltip $recf.ent_file [mc "Output file for recording. If you omit
this value TV-Viewer will determine a name
and store the file in the default record path."]
			settooltip $recf.b_file [mc "Output file for recording. If you omit
this value TV-Viewer will determine a name
and store the file in the default record path."]
			settooltip $bf.b_apply [mc "Apply your changes and exit the dialogue."]
			settooltip $bf.b_cancel [mc "Exit the dialogue without changes."]
		}
	}
	tkwait visibility $w
	grab $w
}

proc record_add_editExit {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editExit \033\[0m \{$w\}"
	log_writeOutTv 0 "Exiting 'add/edit recording'."
	unset -nocomplain ::record(time) ::record(date) ::record(duration) ::record(resolution) ::record(file)
	grab release $w
	destroy $w
}

proc record_add_editOfile {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_edit \033\[0m \{$w\}"
	set types {
	{{Video Files}      {.mpeg}       }
	}
	if {[info exists ::record(file)]} {
		if {[string trim $::record(file)] != {}} {
			set ofile [ttk::getSaveFile -filetypes $types -defaultextension ".mpeg" -initialfile "$::record(file)" -hidden 0 -title [mc "Choose output file"] -parent $w]
			if {"[file extension $ofile]" != ".mpeg" && [string trim $ofile] != {}} {
				set ofile "[file rootname $ofile].mpeg"
			}
		} else {
			set ofile [ttk::getSaveFile -filetypes $types -defaultextension ".mpeg" -initialdir "[subst $::option(rec_default_path)]" -hidden 0 -title [mc "Choose output file"] -parent $w]
			if {"[file extension $ofile]" != ".mpeg" && [string trim $ofile] != {}} {
				set ofile "[file rootname $ofile].mpeg"
			}
		}
	} else {
		set ofile [ttk::getSaveFile -filetypes $types -defaultextension ".mpeg" -initialdir "[subst $::option(rec_default_path)]" -hidden 0 -title [mc "Choose output file"] -parent $w]
		if {"[file extension $ofile]" != ".mpeg" && [string trim $ofile] != {}} {
			set ofile "[file rootname $ofile].mpeg"
		}
	}
	log_writeOutTv 0 "Chosen output file:"
	log_writeOutTv 0 "$ofile"
	$w.record_frame.ent_file state !disabled
	set ::record(file) "$ofile"
	$w.record_frame.ent_file state disabled
}


proc record_add_editDelete {tree} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDelete \033\[0m \{$tree\}"
	if {[string trim [$tree selection]] == {}} return
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
	log_writeOutTv 0 "Deleting recording [$tree selection]."
	if {[llength [$tree selection]] > 1} {
		foreach element [$tree selection] {
			$tree delete $element
		}
	} else {
		$tree delete [$tree selection]
	}
	catch {file delete -force "$::option(home)/config/scheduled_recordings.conf"}
	set f_open [open "$::option(home)/config/scheduled_recordings.conf" a]
	foreach ritem [split [$tree children {}]] {
		puts $f_open "[lindex [$tree item $ritem -values] 0] \{[lindex [$tree item $ritem -values] 1]\} [lindex [$tree item $ritem -values] 2] [lindex [$tree item $ritem -values] 3] [lindex [$tree item $ritem -values] 4] [lindex [$tree item $ritem -values] 5] \{[lindex [$tree item $ritem -values] 6]\}"
	}
	close $f_open
	if {$start} {
		log_writeOutTv 0 "Writing new scheduled_recordings.conf and execute scheduler."
		catch {exec ""}
		catch {exec "$::option(root)/data/record_scheduler.tcl" &}
	} else {
		log_writeOutTv 0 "Writing new scheduled_recordings.conf"
		log_writeOutTv 0 "Reinitiating scheduler"
		command_WritePipe "tv-viewer_scheduler scheduler_Init 1"
	}
}

proc record_add_editDate {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDate \033\[0m"
	log_writeOutTv 0 "Building record add/edit (choose date) dialogue."
	set w [toplevel .record_wizard.add_edit.date] ; place [ttk::label .record_wizard.add_edit.date.bg -style Toolbutton] -relwidth 1 -relheight 1
	set fnavi [ttk::frame $w.navi_frame]
	set fcho [ttk::frame $w.choose_frame]
	set bf [ttk::frame $w.button_frame -style TLabelframe]
	
	ttk::button $fnavi.b_year_back \
	-compound image \
	-image $::icon_s(rewind-big) \
	-width 0 \
	-command [list record_add_editDateYearMonth $fcho.calw_date_choose $fnavi.l_date_info -2]
	
	ttk::button $fnavi.b_month_back \
	-compound image \
	-image $::icon_s(rewind-small) \
	-width 0 \
	-command [list record_add_editDateYearMonth $fcho.calw_date_choose $fnavi.l_date_info -1]
	
	ttk::label $fnavi.l_date_info
	
	ttk::button $fnavi.b_month_forw \
	-compound image \
	-image $::icon_s(forward-small) \
	-width 0 \
	-command [list record_add_editDateYearMonth $fcho.calw_date_choose $fnavi.l_date_info 1]
	
	ttk::button $fnavi.b_year_forw \
	-compound image \
	-image $::icon_s(forward-big) \
	-width 0 \
	-command [list record_add_editDateYearMonth $fcho.calw_date_choose $fnavi.l_date_info 2]
	
	calwid $fcho.calw_date_choose \
	-background $::option(theme_$::option(use_theme)) \
	-callback [list record_add_editDateCallback $fnavi.l_date_info]
	
	ttk::button $bf.b_apply \
	-text [mc "Apply"] \
	-compound left \
	-image $::icon_s(dialog-ok-apply) \
	-command [list record_add_editDateApply $w $fnavi.l_date_info]
	
	ttk::button $bf.b_cancel \
	-text [mc "Cancel"] \
	-compound left \
	-image $::icon_s(dialog-cancel) \
	-command "grab release $w; grab .record_wizard.add_edit; destroy $w; wm protocol .record_wizard.add_edit WM_DELETE_WINDOW {record_add_editExit .record_wizard.add_edit}"
	
	grid columnconfigure $fcho 0 -weight 1
	grid rowconfigure $fcho 0 -weight 1
	
	grid $fnavi -in $w -row 0 -column 0 \
	-sticky ew
	grid $fcho -in $w -row 1 -column 0 \
	-sticky nesw
	grid $bf -in $w -row 2 -column 0 \
	-sticky ew \
	-padx 3 \
	-pady 3
	grid anchor $bf e
	grid anchor $fnavi center
	grid anchor $fcho center
	
	grid $fnavi.b_year_back -in $fnavi -row 0 -column 0 \
	-pady 3 \
	-padx 3
	grid $fnavi.b_month_back -in $fnavi -row 0 -column 1 \
	-pady 3
	grid $fnavi.l_date_info -in $fnavi -row 0 -column 2 \
	-pady 3 \
	-padx 10
	grid $fnavi.b_month_forw -in $fnavi -row 0 -column 3 \
	-pady 3
	grid $fnavi.b_year_forw -in $fnavi -row 0 -column 4 \
	-pady 3 \
	-padx 3
	grid $fcho.calw_date_choose -in $fcho -row 0 -column 0 \
	-pady "5 0"
	grid $bf.b_apply -in $bf -row 0 -column 0 \
	-pady 7 \
	-padx 3
	grid $bf.b_cancel -in $bf -row 0 -column 1 \
	-pady 7 \
	-padx "0 3"
	
	wm resizable $w 0 0
	wm title $w [mc "Choose date"]
	wm protocol .record_wizard.add_edit WM_DELETE_WINDOW " "
	wm protocol $w WM_DELETE_WINDOW "grab release $w; grab .record_wizard.add_edit; destroy $w; wm protocol .record_wizard.add_edit WM_DELETE_WINDOW {record_add_editExit .record_wizard.add_edit}"
	wm iconphoto $w $::icon_b(calendar)
	wm transient $w .record_wizard.add_edit
	
	if {[info exists ::record(date)] == 1 && [string trim $::record(date)] != {}} {
		set date [string map {{-} {}} $::record(date)]
		if {[string is digit $date]} {
			set day [expr {[clock format [clock scan $date] -format %e] - 1}]
			set row [expr [clock format [clock scan $date] -format {%u}] - 1]
			set column [expr {(($row - $day) % 7 + $day) / 7}]
			$fnavi.l_date_info configure -text "$::record(date)"
		} else {
			set day [expr {[clock format [clock scan now] -format %e] - 1}]
			set row [expr [clock format [clock scan now] -format {%u}] - 1]
			set column [expr {(($row - $day) % 7 + $day) / 7}]
			$fnavi.l_date_info configure -text "[clock format [clock scan now] -format {%Y-%m-%d}]"
		}
	} else {
		set day [expr {[clock format [clock scan now] -format %e] - 1}]
		set row [expr [clock format [clock scan now] -format {%u}] - 1]
		set column [expr {(($row - $day) % 7 + $day) / 7}]
		$fnavi.l_date_info configure -text "[clock format [clock scan now] -format {%Y-%m-%d}]"
	}
	$fcho.calw_date_choose configure -clicked [list $row $column]
	
	if {$::option(tooltips) == 1} {
		if {$::option(tooltips_record) == 1} {
			settooltip $fnavi.b_year_back [mc "Previous year."]
			settooltip $fnavi.b_month_back [mc "Previous month."]
			settooltip $fnavi.b_month_forw [mc "Next month."]
			settooltip $fnavi.b_year_forw [mc "Next year."]
		}
	}
	
	grab release .record_wizard.add_edit
	tkwait visibility $w
	grab $w
}

proc record_add_editDateCallback {w args} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDateCallback \033\[0m \{$w\} \{$args\}"
	set year [lindex $args 0]
	if {[string length [lindex $args 1]] < 2} {
		set month "0[lindex $args 1]"
	} else {
		set month "[lindex $args 1]"
	}
	if {[string length [lindex $args 2]] < 2} {
		set day "0[lindex $args 2]"
	} else {
		set day "[lindex $args 2]"
	}
	$w configure -text "$year-$month-$day"
}

proc record_add_editDateYearMonth {cal label com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDateYearMonth \033\[0m \{$cal\} \{$label\} \{$com\}"
	if {$com == -2} {
		$cal prevyear
		set year [$cal configure -year]
		if {[string length [$cal configure -month]] < 2} {
			set month "0[$cal configure -month]"
		} else {
			set month "[$cal configure -month]"
		}
		set day [lindex [string map {{-} { }} [$label cget -text]] end]
	}
	if {$com == -1} {
		$cal prevmonth
		set year [$cal configure -year]
		if {[string length [$cal configure -month]] < 2} {
			set month "0[$cal configure -month]"
		} else {
			set month "[$cal configure -month]"
		}
		set day [lindex [string map {{-} { }} [$label cget -text]] end]
	}
	if {$com == 1} {
		$cal nextmonth
		set year [$cal configure -year]
		if {[string length [$cal configure -month]] < 2} {
			set month "0[$cal configure -month]"
		} else {
			set month "[$cal configure -month]"
		}
		set day [lindex [string map {{-} { }} [$label cget -text]] end]
	}
	if {$com == 2} {
		$cal nextyear
		set year [$cal configure -year]
		if {[string length [$cal configure -month]] < 2} {
			set month "0[$cal configure -month]"
		} else {
			set month "[$cal configure -month]"
		}
		set day [lindex [string map {{-} { }} [$label cget -text]] end]
	}
	set daycalc [expr {[clock format [clock scan $year$month$day] -format %e] - 1}]
	set row [expr [clock format [clock scan $year$month$day] -format {%u}] - 1]
	set column [expr {(($row - $daycalc) % 7 + $daycalc) / 7}]
	
	$cal configure -clicked [list $row $column]
}

proc record_add_editDateApply {w label} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDateApply \033\[0m \{$w\} \{$label\}"
	.record_wizard.add_edit.record_frame.ent_date state !disabled
	set ::record(date) [$label cget -text]
	log_writeOutTv 0 "Chosen date [$label cget -text]."
	.record_wizard.add_edit.record_frame.ent_date state disabled
	grab release $w; grab .record_wizard.add_edit; destroy $w; wm protocol .record_wizard.add_edit WM_DELETE_WINDOW {record_add_editExit .record_wizard.add_edit}
}
