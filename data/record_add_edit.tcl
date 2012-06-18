#       record_add_edit.tcl
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

proc record_add_edit {tree com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_edit \033\[0m \{$tree\} \{$com\}"
	#com 0 add new recording - 1 edit selected recording
	if {$com == 1} {
		if {[string trim [$tree selection]] == {}} {
			log_writeOut ::log(tvAppend) 1 "No recording selected to edit."
			return
		}
		if {[llength [$tree selection]] > 1} {
			log_writeOut ::log(tvAppend) 1 "Can not edit more than one recording at a time."
			return
		}
	}
	log_writeOut ::log(tvAppend) 0 "Building record add/edit dialogue."
	set w [toplevel .record_wizard.add_edit] ; place [ttk::label .record_wizard.add_edit.bg -style Toolbutton] -relwidth 1 -relheight 1
	set lbf [ttk::frame $w.listbox_frame]
	set recf [ttk::frame $w.record_frame]
	set bf [ttk::frame $w.button_frame -style TLabelframe]
	
	listbox $lbf.lb_stations -yscrollcommand [list $lbf.scrollbar_stations set] -exportselection false -takefocus 0 -width 0
	ttk::scrollbar $lbf.scrollbar_stations -orient vertical -command [list $lbf.lb_stations yview]
	
	ttk::labelframe $recf.lf_rec_values -text [mc "Record options"]
	set lf_recValues $recf.lf_rec_values
	ttk::label $lf_recValues.l_time -text [mc "Time:"]
	
	proc record_add_editTimeHourValidate {value valnew} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editTimeHourValidate \033\[0m \{$value\} \{$valnew\}"
		if {[string length $value] > 2} {
			return 0
		}
		set value [scan $value %d]
		if {[string is integer $value] == 0 || [string is integer $valnew] == 0} {
			return 0
		}
		if {$::option(rec_hour_format) == 12} {
			if {$value > 12} {
				return 0
			}
		}
		if {$::option(rec_hour_format) == 24} {
			if {$value > 24} {
				return 0
			}
		}
		return 1
	}
	proc record_add_editTimeMinValidate {value valnew} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editTimeMinValidate \033\[0m \{$value\} \{$valnew\}"
		if {[string length $value] > 2} {
			return 0
		}
		set value [scan $value %d]
		if {[string is integer $value] == 0 || [string is integer $valnew] == 0} {
			return 0
		}
		if {$value > 60} {
			return 0
		}
		return 1
	}
	
	spinbox $lf_recValues.sb_time_hour -from -1 -to 24 -width 3 -validate key -vcmd {record_add_editTimeHourValidate %P %S} -repeatinterval 80 -command record_add_editTimeHour -textvariable record(time_hour)
	ttk::label $lf_recValues.l_time_colon -text ":"
	spinbox $lf_recValues.sb_time_min -from -1 -to 60 -width 3 -validate key -vcmd {record_add_editTimeMinValidate %P %S} -repeatinterval 25 -command record_add_editTimeMin -textvariable record(time_min)
	ttk::menubutton $lf_recValues.mbHourFormat -menu $recf.mbHourFormat.mHour -textvariable record(mbHourFormat) -state disabled -width 0
	menu $lf_recValues.mbHourFormat.mHour -tearoff 0
	
	ttk::separator $lf_recValues.sep1 -orient vertical
	
	ttk::label $lf_recValues.l_date -text [mc "Date:"]
	ttk::entry $lf_recValues.ent_date -textvariable record(date) -width 11 -state readonly
	ttk::button $lf_recValues.b_date -width 0 -compound image -image $::icon_s(calendar) -command record_add_editDate
	ttk::separator $lf_recValues.sep2 -orient horizontal
	ttk::label $lf_recValues.l_duration -text [mc "Duration:"]
	
	proc record_add_editDurHourValidate {value valnew} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDurHourValidate \033\[0m \{$value\} \{$valnew\}"
		if {[string length $value] > 2} {
			return 0
		}
		set value [scan $value %d]
		if {[string is integer $value] == 0 || [string is integer $valnew] == 0} {
			return 0
		}
		return 1
	}
	proc record_add_editDurMinValidate {value valnew} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDurMinValidate \033\[0m \{$value\} \{$valnew\}"
		if {[string length $value] > 2} {
			return 0
		}
		set value [scan $value %d]
		if {[string is integer $value] == 0 || [string is integer $valnew] == 0} {
			return 0
		}
		if {$value > 60} {
			return 0
		}
		return 1
	}
	proc record_add_editDurSecValidate {value valnew} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDurSecValidate \033\[0m \{$value\} \{$valnew\}"
		if {[string length $value] > 2} {
			return 0
		}
		set value [scan $value %d]
		if {[string is integer $value] == 0 || [string is integer $valnew] == 0} {
			return 0
		}
		if {$value > 60} {
			return 0
		}
		return 1
	}
	
	spinbox $lf_recValues.sb_duration_hour -from -1 -to 99 -width 3 -validate key -vcmd {record_add_editDurHourValidate %P %S} -repeatinterval 25 -command record_add_editDurHour -textvariable record(duration_hour)
	ttk::label $lf_recValues.l_duration_colon1 -text ":"
	spinbox $lf_recValues.sb_duration_min -from -1 -to 60 -width 3 -validate key -vcmd {record_add_editDurMinValidate %P %S} -repeatinterval 25 -command record_add_editDurMin -textvariable record(duration_min)
	ttk::label $lf_recValues.l_duration_colon2 -text ":"
	spinbox $lf_recValues.sb_duration_sec -from -1 -to 60 -width 3 -validate key -vcmd {record_add_editDurSecValidate %P %S} -repeatinterval 25 -command record_add_editDurSec -textvariable record(duration_sec)
	
	ttk::separator $lf_recValues.sep3 -orient vertical
	
	ttk::label $lf_recValues.l_repeat -text [mc "Repeat:"]
	ttk::menubutton $lf_recValues.mb_repeat -menu $lf_recValues.mb_repeat.mRepeat -textvariable record(mbRepeat)
	menu $lf_recValues.mb_repeat.mRepeat -tearoff 0
	ttk::label $lf_recValues.l_repeatReps -text [mc "Repetitions:"]
	spinbox $lf_recValues.sb_repeat -from 1 -to 30 -width 3 -repeatinterval 25 -state readonly -textvariable record(sbRepeat)
	
	ttk::separator $lf_recValues.sep4 -orient horizontal
	
	ttk::label $lf_recValues.l_resol -text [mc "Resolution:"]
	
	proc record_add_editResolWidthValidate {value valnew} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editResolWidthValidate \033\[0m \{$value\} \{$valnew\}"
		if {[string length $value] > 3} {
			return 0
		}
		set value [scan $value %d]
		if {[string is integer $value] == 0 || [string is integer $valnew] == 0} {
			return 0
		}
		if {$value < 99 || $value > 721} {
			return 0
		}
		return 1
	}
	proc record_add_editResolHeightValidate {value valnew} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editResolHeightValidate \033\[0m \{$value\} \{$valnew\}"
		if {[string length $value] > 3} {
			return 0
		}
		set value [scan $value %d]
		if {[string is integer $value] == 0 || [string is integer $valnew] == 0} {
			return 0
		}
		if {"$::option(video_standard)" == "NTSC"} {
			if {$value < 99 || $value > 481} {
				return 0
			}
		} else {
			if {$value < 99 || $value > 577} {
				return 0
			}
		}
		return 1
	}
	
	spinbox $lf_recValues.sb_resol_width -from 99 -to 721 -width 3 -validate key -vcmd {record_add_editResolWidthValidate %P %S} -repeatinterval 10 -command record_add_editResolWidth -textvariable record(resolution_width)
	ttk::label $lf_recValues.l_resol_slash -text "/"
	spinbox $lf_recValues.sb_resol_height -width 3 -validate key -vcmd {record_add_editResolHeightValidate %P %S} -repeatinterval 10 -command record_add_editResolHeight -textvariable record(resolution_height)
	if {"$::option(video_standard)" == "NTSC"} {
		$lf_recValues.sb_resol_height configure -from 99 -to 481
		set ::record(resolution_height_max) 480
		set ::record(resolution_height_min) 100
	} else {
		$lf_recValues.sb_resol_height configure -from 99 -to 577
		set ::record(resolution_height_max) 576
		set ::record(resolution_height_min) 100
	}
	
	ttk::separator $lf_recValues.sep5 -orient vertical
	
	ttk::labelframe $recf.lf_rec_file -text [mc "Output file"]
	ttk::entry $recf.ent_file -textvariable record(file) -state readonly
	ttk::button $recf.b_file -text "..." -width 3 -command [list record_add_editOfile $w]
	
	ttk::label $recf.l_warning -compound left
	
	ttk::button $bf.b_apply -text [mc "Apply"] -compound left -image $::icon_s(dialog-ok-apply)
	
	ttk::button $bf.b_cancel -text [mc "Cancel"] -compound left -image $::icon_s(dialog-cancel) -command [list record_add_editExit $w]
	
	grid rowconfigure $w 1 -weight 0
	grid rowconfigure $lbf 0 -weight 1
	grid rowconfigure $recf.lf_rec_values {0 2} -weight 1
	grid columnconfigure $w 1 -weight 1
	grid columnconfigure $recf.lf_rec_file 0 -weight 1
	grid columnconfigure $recf.lf_rec_values 0 -weight 1
	
	grid $lbf -in $w -row 0 -column 0 -sticky nesw -pady "13 31" -padx "2 0"
	grid $recf -in $w -row 0 -column 1 -sticky nesw
	grid $bf -in $w -row 1 -column 0 -columnspan 2 -sticky ew -padx 3 -pady 3
	grid anchor $bf e
	
	grid $lbf.lb_stations -in $lbf -row 0 -column 0 -sticky nesw
	grid $lbf.scrollbar_stations -in $lbf -row 0 -column 1 -sticky ns
	
	grid $recf.lf_rec_values -in $recf -row 0 -column 0 -sticky new -padx 5 -pady 6
	grid $lf_recValues.l_time -in $lf_recValues -row 0 -column 0 -sticky w -padx 5 -pady 3
	grid $lf_recValues.sb_time_hour -in $lf_recValues -row 0 -column 1 -sticky w -padx "0 2" -pady 3
	grid $lf_recValues.l_time_colon -in $lf_recValues -row 0 -column 2 -padx "0 2" -pady 3
	grid $lf_recValues.sb_time_min -in $lf_recValues -row 0 -column 3 -sticky w -padx "0 5" -pady 3
	grid $lf_recValues.mbHourFormat -in $lf_recValues -row 0 -column 5 -padx "0 5" -pady 3 -sticky w
	
	grid $lf_recValues.sep1 -in $lf_recValues -row 0 -column 6 -sticky ns -padx 2
	
	grid $lf_recValues.l_date -in $lf_recValues -row 0 -column 7 -sticky w -padx 5 -pady 3
	grid $lf_recValues.ent_date -in $lf_recValues -row 0 -column 8 -sticky ew -padx "0 5" -pady 3 -columnspan 2
	grid $lf_recValues.b_date -in $lf_recValues -row 0 -column 10 -sticky w -padx "0 5" -pady 3
	
	grid $lf_recValues.sep2 -in $lf_recValues -row 1 -column 0 -sticky ew -columnspan 12 -padx 3
	
	grid $lf_recValues.l_duration -in $lf_recValues -row 2 -column 0 -sticky w -padx 5 -pady "5 0"
	grid $lf_recValues.sb_duration_hour -in $lf_recValues -row 2 -column 1 -sticky w -padx "0 2" -pady "5 0"
	grid $lf_recValues.l_duration_colon1 -in $lf_recValues -row 2 -column 2 -padx "0 2" -pady "5 0"
	grid $lf_recValues.sb_duration_min -in $lf_recValues -row 2 -column 3 -sticky w -padx "0 2" -pady "5 0"
	grid $lf_recValues.l_duration_colon2 -in $lf_recValues -row 2 -column 4 -padx "0 2" -pady "5 0"
	grid $lf_recValues.sb_duration_sec -in $lf_recValues -row 2 -column 5 -sticky w -padx "0 5" -pady "5 0"
	grid $lf_recValues.sep3 -in $lf_recValues -row 2 -column 6 -sticky ns -rowspan 2 -padx 2
	grid $lf_recValues.l_repeat -in $lf_recValues -row 2 -column 7 -sticky w -padx 5 -pady 3
	grid $lf_recValues.mb_repeat -in $lf_recValues -row 2 -column 8 -sticky ew -padx "0 5" -pady "3 0"
	grid $lf_recValues.l_repeatReps -in $lf_recValues -row 3 -column 7 -sticky w -padx 5 -pady 3
	grid $lf_recValues.sb_repeat -in $lf_recValues -row 3 -column 8 -sticky w -padx "0 5" -pady 3
	grid $lf_recValues.sep4 -in $lf_recValues -row 4 -column 0 -sticky ew -columnspan 12 -padx 3
	grid $lf_recValues.l_resol -in $lf_recValues -row 5 -column 0 -sticky w -padx 5 -pady "5 11"
	grid $lf_recValues.sb_resol_width -in $lf_recValues -row 5 -column 1 -sticky w -padx "0 2" -pady "5 11"
	grid $lf_recValues.l_resol_slash -in $lf_recValues -row 5 -column 2 -padx "0 2" -pady "5 11"
	grid $lf_recValues.sb_resol_height -in $lf_recValues -row 5 -column 3 -sticky w -padx "0 5" -pady "5 11"
	grid $lf_recValues.sep5 -in $lf_recValues -row 5 -column 6 -sticky ns -padx 2 -pady "0 5"
	
	grid $recf.lf_rec_file -in $recf -row 1 -column 0 -sticky new -padx 5 -pady "0 6"
	grid $recf.ent_file -in $recf.lf_rec_file -row 0 -column 0 -sticky ew -padx 5 -pady 3
	grid $recf.b_file -in $recf.lf_rec_file -row 0 -column 1 -padx "0 5" -pady 3
	
	grid $recf.l_warning -in $recf -row 2 -column 0 -sticky w -padx "5 0" -pady 3
	
	grid $bf.b_apply -in $bf -row 0 -column 0 -pady 7 -padx 3
	grid $bf.b_cancel -in $bf -row 0 -column 1 -pady 7 -padx "0 3"
	
	wm resizable $w 0 0
	if {$com == 0} {
		wm title $w [mc "Add a new recording"]
	} else {
		wm title $w [mc "Edit recording"]
	}
	wm protocol $w WM_DELETE_WINDOW "record_add_editExit $w"
	wm iconphoto $w $::icon_b(record)
	wm transient $w .record_wizard
	
	bind $lf_recValues.ent_date <Double-ButtonPress-1> {record_add_editDate}
	bind $recf.ent_file <Double-ButtonPress-1> [list record_add_editOfile $w]
	
	for {set i 1} {$i <= $::station(max)} {incr i} {
		$lbf.lb_stations insert end $::kanalid($i)
	}
	
	$lf_recValues.mbHourFormat.mHour add radiobutton -label am -variable record(rbAddEditHour) -command {set ::record(mbHourFormat) am}
	$lf_recValues.mbHourFormat.mHour add radiobutton -label pm -variable record(rbAddEditHour) -command {set ::record(mbHourFormat) pm}
	
	$lf_recValues.mb_repeat.mRepeat add radiobutton -label [mc "Never"] -variable record(rbRepeat) -value 0 -command {set ::record(mbRepeat) [mc "Never"]}
	$lf_recValues.mb_repeat.mRepeat add radiobutton -label [mc "Daily"] -variable record(rbRepeat) -value 1 -command {set ::record(mbRepeat) [mc "Daily"]}
	$lf_recValues.mb_repeat.mRepeat add radiobutton -label [mc "Weekday"] -variable record(rbRepeat) -value 2 -command {set ::record(mbRepeat) [mc "Weekday"]}
	$lf_recValues.mb_repeat.mRepeat add radiobutton -label [mc "Weekly"] -variable record(rbRepeat) -value 3 -command {set ::record(mbRepeat) [mc "Weekly"]}
	
	if {$com == 0} {
		$lbf.lb_stations see [expr [lindex $::station(last) 2] - 1]
		$lbf.lb_stations activate [expr [lindex $::station(last) 2] - 1]
		$lbf.lb_stations selection set [expr [lindex $::station(last) 2] - 1]
		
		$bf.b_apply configure -command [list record_applyTimeDate $tree $lbf.lb_stations $w add]
		if {$::option(rec_hour_format) == 24} {
			set ::record(time_hour) [scan [clock format [clock scan now] -format %H] %d]
			set ::record(time_HourOld) $::record(time_hour)
			set ::record(mbHourFormat) [clock format [clock scan now] -format %P]
		} else {
			set ::record(time_hour) [scan [clock format [clock scan now] -format %I] %d]
			set ::record(time_HourOld) $::record(time_hour)
			set ::record(mbHourFormat) [clock format [clock scan now] -format %P]
			set ::record(rbAddEditHour) [clock format [clock scan now] -format %P]
			$lf_recValues.mbHourFormat state !disabled
		}
		set ::record(time_min) [scan [clock format [clock scan now] -format %M] %d]
		set ::record(date) [clock format [clock scan now] -format {%Y-%m-%d}]
		set ::record(duration_hour) [scan $::option(rec_duration_hour) %d]
		set ::record(duration_min) [scan $::option(rec_duration_min) %d]
		set ::record(duration_sec) [scan $::option(rec_duration_sec) %d]
		set ::record(mbRepeat) [mc "Never"]
		set ::record(rbRepeat) 0
		set ::record(sbRepeat) 1
		set ::record(resolution_width) 720
		if {"$::option(video_standard)" == "NTSC"} {
			set ::record(resolution_height) 480
		} else {
			set ::record(resolution_height) 576
		}
	} else {
		#FIXME Read entry from DB?!
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
		if {$::option(rec_hour_format) == 12} {
			set ::record(time_hour) [scan [clock format [clock scan [lindex [$tree item [$tree selection] -values] 2]] -format %I] %d] 
			set ::record(time_min) [scan [clock format [clock scan [lindex [$tree item [$tree selection] -values] 2]] -format %M] %d]
			set ::record(mbHourFormat) [clock format [clock scan [lindex [$tree item [$tree selection] -values] 2]] -format %P]
			set ::record(rbAddEditHour) [clock format [clock scan [lindex [$tree item [$tree selection] -values] 2]] -format %P]
			$lf_recValues.mbHourFormat state !disabled
		} else {
			set ::record(time_hour) [scan [clock format [clock scan [lindex [$tree item [$tree selection] -values] 2]] -format %H] %d] 
			set ::record(time_min) [scan [clock format [clock scan [lindex [$tree item [$tree selection] -values] 2]] -format %M] %d]
			set ::record(mbHourFormat) [clock format [clock scan [lindex [$tree item [$tree selection] -values] 2]] -format %P]
		}
		set ::record(date) [lindex [$tree item [$tree selection] -values] 3]
		foreach {dhour dmin dsec} [split [lindex [$tree item [$tree selection] -values] 4] :] {
			set ::record(duration_hour) $dhour
			set ::record(duration_min) $dmin
			set ::record(duration_sec) $dsec
		}
		set ::record(rbRepeat) [lindex [$tree item [$tree selection] -values] 5]
		set ::record(mbRepeat) [$lf_recValues.mb_repeat.mRepeat entrycget [lindex [$tree item [$tree selection] -values] 5] -label]
		set ::record(sbRepeat) [lindex [$tree item [$tree selection] -values] 6]
		foreach {rwidth rheight} [split [lindex [$tree item [$tree selection] -values] 7] "/"] {
			set ::record(resolution_width) $rwidth
			set ::record(resolution_height) $rheight
		}
		set ::record(file) [lindex [$tree item [$tree selection] -values] 8]
	}
	
	if {$::option(tooltips) == 1} {
		if {$::option(tooltips_record) == 1} {
			settooltip $lbf.lb_stations [mc "Choose station to record"]
			settooltip $lf_recValues.sb_time_hour [mc "Time when recording should start (Hour)"]
			settooltip $lf_recValues.sb_time_min [mc "Time when recording should start (Minute)"]
			settooltip $lf_recValues.mbHourFormat [mc "Choose between before or after midday.
You may change hour format in the preferences (Record)."]
			settooltip $lf_recValues.ent_date [mc "Choose date on which recording should occur"]
			settooltip $lf_recValues.b_date [mc "Choose date on which recording should occur"]
			settooltip $lf_recValues.sb_duration_hour [mc "Duration for the recording (Hours)"]
			settooltip $lf_recValues.sb_duration_min [mc "Duration for the recording (Minutes)"]
			settooltip $lf_recValues.sb_duration_sec [mc "Duration for the recording (Seconds)"]
			settooltip $lf_recValues.mb_repeat [mc "Choose between never, daily (Mo - Su),
weekday (Mo - Fr), weekly"]
			settooltip $lf_recValues.sb_repeat [mc "Choose the quantity of repetitions"]
			settooltip $lf_recValues.sb_resol_width [mc "Resolution (width) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards."]
 			settooltip $lf_recValues.sb_resol_width [mc "Resolution (height) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards."]
			settooltip $recf.ent_file [mc "Output file for recording. If you omit
this value TV-Viewer will determine a name
and store the file in the default record path."]
			settooltip $recf.b_file [mc "Output file for recording. If you omit
this value TV-Viewer will determine a name
and store the file in the default record path."]
		}
	}
	tkwait visibility $w
	vid_wmCursor 0
	grab $w
}

proc record_add_editTimeHour {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editTimeHour \033\[0m"
	if {$::option(rec_hour_format) == 24} {
		if {$::record(time_hour) < 0} {
			set ::record(time_hour) 23
		}
		if {$::record(time_hour) > 23} {
			set ::record(time_hour) 0
		}
	} else {
		if {$::record(time_hour) < 1} {
			set ::record(time_hour) 12
		}
		if {$::record(time_hour) > 12} {
			set ::record(time_hour) 1
		}
		if {$::record(time_hour) < 12 && $::record(time_hour) > 10 && $::record(time_HourOld) == 12} {
			if {"$::record(rbAddEditHour)" == "pm"} {
				set ::record(rbAddEditHour) am
				set ::record(mbHourFormat) am
			} else {
				set ::record(rbAddEditHour) pm
				set ::record(mbHourFormat) pm
			}
		}
		if {$::record(time_hour) > 11 && $::record(time_HourOld) == 11} {
			if {"$::record(rbAddEditHour)" == "pm"} {
				set ::record(rbAddEditHour) am
				set ::record(mbHourFormat) am
			} else {
				set ::record(rbAddEditHour) pm
				set ::record(mbHourFormat) pm
			}
		}
	}
	set ::record(time_HourOld) $::record(time_hour)
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

proc record_add_editExit {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editExit \033\[0m \{$w\}"
	log_writeOut ::log(tvAppend) 0 "Exiting 'add/edit recording'."
	unset -nocomplain ::record(time_hour) ::record(time_HourOld) ::record(time_min) set ::record(rbAddEditHour) ::record(mbHourFormat) ::record(date) ::record(duration) ::record(mbRepeat) ::record(rbRepeat) ::record(sbRepeat) ::record(resolution) ::record(file)
	vid_wmCursor 1
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
	log_writeOut ::log(tvAppend) 0 "Chosen output file:"
	log_writeOut ::log(tvAppend) 0 "$ofile"
	set ::record(file) "$ofile"
}

proc record_add_editDelete {tree} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDelete \033\[0m \{$tree\}"
	if {[string trim [$tree selection]] == {}} return
	set top [toplevel .record_wizard.delete]
	place [ttk::frame $top.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
	set fMain [ttk::frame $top.f_delMain]
	set fBut [ttk::frame $top.f_delBut -style TLabelframe]
	
	ttk::label $fMain.l_delMessage -text [mc "Do you really want to delete the selected recording(s)?"] -image $::icon_b(dialog-warning) -compound left
	ttk::checkbutton $fMain.cb_delAsk -text [mc "Don't ask next time"] -variable ::record(cbDelAsk)
	
	ttk::button $fBut.b_delCancel -text [mc "Cancel"] -compound left -image $::icon_s(dialog-cancel) -command {vid_wmCursor 1; grab release .record_wizard.delete; destroy .record_wizard.delete} -default active
	ttk::button $fBut.b_delApply -text [mc "Delete"] -compound left -image $::icon_s(dialog-ok-apply) -command [list record_add_editDeleteRun $tree $top]
	
	grid $fMain -in $top -row 0 -column 0 -sticky ew
	grid $fBut -in $top -row 1 -column 0 -sticky ew -padx 3 -pady 3
	
	grid $fMain.l_delMessage -in $fMain -row 0 -column 0 -pady "3 7" -padx 5
	grid $fMain.cb_delAsk -in $fMain -row 1 -column 0 -sticky w -pady "0 7" -padx 5
	
	grid $fBut.b_delCancel -in $fBut -row 0 -column 0 -padx "0 3" -pady 7
	grid $fBut.b_delApply -in $fBut -row 0 -column 1 -padx "0 3" -pady 7
	grid anchor $fBut e
	
	wm iconphoto $top $::icon_b(record)
	wm resizable $top 0 0
	wm transient $top .record_wizard
	wm protocol $top WM_DELETE_WINDOW {vid_wmCursor 1; grab release .record_wizard.delete; destroy .record_wizard.delete}
	wm title $top [mc "Delete recordings"]
	
	if {[info exists ::record(cbDelAsk)] && $::record(cbDelAsk)} {
		record_add_editDeleteRun $tree $top
		return
	}
	tkwait visibility $top
	vid_wmCursor 0
	grab $top
	focus $fBut.b_delCancel
}

proc record_add_editDeleteRun {tree top} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDelete \033\[0m \{$tree\} \{$top\}"
	set status [monitor_partRunning 2]
	if {[lindex $status 0] == 1} {
		set start 0
	} else {
		set start 1
	}
	log_writeOut ::log(tvAppend) 0 "Deleting recording [$tree selection]."
	if {[llength [$tree selection]] > 1} {
		foreach element [$tree selection] {
			set delID [lindex [$tree item $element -values] 0]
			database transaction {
				database eval {DELETE FROM RECORDINGS WHERE ID = :delID}
			}
			if {[database errorcode] == 0} {
				$tree delete $element
			}
		}
	} else {
		set delID [lindex [$tree item [$tree selection] -values] 0]
		database transaction {
			database eval {DELETE FROM RECORDINGS WHERE ID = :delID}
		}
		if {[database errorcode] == 0} {
			$tree delete [$tree selection]
		}
	}
	
	if {$start} {
		log_writeOut ::log(tvAppend) 0 "Updating database and execute scheduler."
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
	vid_wmCursor 1
	grab release $top
	destroy $top
}

proc record_add_editDate {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_add_editDate \033\[0m"
	log_writeOut ::log(tvAppend) 0 "Building record add/edit (choose date) dialogue."
	set w [toplevel .record_wizard.add_edit.date] ; place [ttk::label .record_wizard.add_edit.date.bg -style Toolbutton] -relwidth 1 -relheight 1
	set fnavi [ttk::frame $w.navi_frame]
	set fcho [ttk::frame $w.choose_frame]
	set bf [ttk::frame $w.button_frame -style TLabelframe]
	
	ttk::button $fnavi.b_year_back -compound image -image $::icon_s(rewind-first) -width 0 -command [list record_add_editDateYearMonth $fcho.calw_date_choose $fnavi.l_date_info -2]
	ttk::button $fnavi.b_month_back -compound image -image $::icon_s(rewind-small) -width 0 -command [list record_add_editDateYearMonth $fcho.calw_date_choose $fnavi.l_date_info -1]
	ttk::label $fnavi.l_date_info
	ttk::button $fnavi.b_month_forw -compound image -image $::icon_s(forward-small) -width 0 -command [list record_add_editDateYearMonth $fcho.calw_date_choose $fnavi.l_date_info 1]
	ttk::button $fnavi.b_year_forw -compound image -image $::icon_s(forward-last) -width 0 -command [list record_add_editDateYearMonth $fcho.calw_date_choose $fnavi.l_date_info 2]
	calwid $fcho.calw_date_choose -callback [list record_add_editDateCallback $fnavi.l_date_info]
	
	ttk::button $bf.b_apply -text [mc "Apply"] -compound left -image $::icon_s(dialog-ok-apply) -command [list record_add_editDateApply $w $fnavi.l_date_info]
	ttk::button $bf.b_cancel -text [mc "Cancel"] -compound left -image $::icon_s(dialog-cancel) -command "grab release $w; grab .record_wizard.add_edit; destroy $w; wm protocol .record_wizard.add_edit WM_DELETE_WINDOW {record_add_editExit .record_wizard.add_edit}"
	
	grid columnconfigure $fcho 0 -weight 1
	grid rowconfigure $fcho 0 -weight 1
	
	grid $fnavi -in $w -row 0 -column 0 -sticky ew
	grid $fcho -in $w -row 1 -column 0 -sticky nesw
	grid $bf -in $w -row 2 -column 0 -sticky ew -padx 3 -pady 3
	grid anchor $bf e
	grid anchor $fnavi center
	grid anchor $fcho center
	
	grid $fnavi.b_year_back -in $fnavi -row 0 -column 0 -pady 3 -padx 3
	grid $fnavi.b_month_back -in $fnavi -row 0 -column 1 -pady 3
	grid $fnavi.l_date_info -in $fnavi -row 0 -column 2 -pady 3 -padx 10
	grid $fnavi.b_month_forw -in $fnavi -row 0 -column 3 -pady 3
	grid $fnavi.b_year_forw -in $fnavi -row 0 -column 4 -pady 3 -padx 3
	grid $fcho.calw_date_choose -in $fcho -row 0 -column 0 -pady "5 0"
	grid $bf.b_apply -in $bf -row 0 -column 0 -pady 7 -padx 3
	grid $bf.b_cancel -in $bf -row 0 -column 1 -pady 7 -padx "0 3"
	
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
			settooltip $fnavi.b_year_back [mc "Previous year"]
			settooltip $fnavi.b_month_back [mc "Previous month"]
			settooltip $fnavi.b_month_forw [mc "Next month"]
			settooltip $fnavi.b_year_forw [mc "Next year"]
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
	set ::record(date) [$label cget -text]
	log_writeOut ::log(tvAppend) 0 "Chosen date [$label cget -text]."
	grab release $w; grab .record_wizard.add_edit; destroy $w; wm protocol .record_wizard.add_edit WM_DELETE_WINDOW {record_add_editExit .record_wizard.add_edit}
}
