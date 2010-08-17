#       station_item.tcl
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

proc station_itemMove {w direction} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemMove \033\[0m \{$w\} \{$direction\}"
	if {[string trim [$w selection]] == {}} return
	if {$direction == 1} {
		if {[llength [$w selection]] > 1} {
			if {[string trim [$w next [lindex [$w selection] end]]] == {}} return
			foreach element [lsort -decreasing [$w selection]] {
				log_writeOutTv 0 "Moving $element down."
				$w move $element [$w parent $element] [expr [$w index $element] + 1]
			}
			$w see [lindex [$w selection] end]
			return
		} else {
			if {[string trim [$w next [$w selection]]] == {}} return
			log_writeOutTv 0 "Moving [$w selection] down."
			$w move [$w selection] [$w parent [$w selection]] [expr [$w index [$w selection]] + 1]
			$w see [$w selection]
			return
		}
	}
	if {$direction == -1} {
		if {[llength [$w selection]] > 1} {
			if {[string trim [$w prev [lindex [$w selection] 0]]] == {}} return
			foreach element [$w selection] {
				log_writeOutTv 0 "Moving $element up."
				$w move $element [$w parent $element] [expr [$w index $element] - 1]
			}
			$w see [lindex [$w selection] 0]
			return
		} else {
			if {[string trim [$w prev [$w selection]]] == {}} return
			log_writeOutTv 0 "Moving [$w selection] up."
			$w move [$w selection] [$w parent [$w selection]] [expr [$w index [$w selection]] - 1]
			$w see [$w selection]
		return
		}
	}
}

proc station_itemDelete {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemDelete \033\[0m \{$w\}"
	if {[string trim [$w selection]] == {}} return
	log_writeOutTv 0 "Deleting item [$w selection]."
	if {[llength [$w selection]] > 1} {
		if {[$w next [lindex [$w selection] end]] == {}} {
			set selitem [$w prev [lindex [$w selection] 0]]
		} else {
			set selitem [$w next [lindex [$w selection] end]]
		}
		foreach element [$w selection] {
			$w delete $element
		}
		catch {$w selection set $selitem}
	} else {
		if {[$w next [$w selection]] == {}} {
			set selitem [$w prev [$w selection]]
		} else {
			set selitem [$w next [$w selection]]
		}
		$w delete [$w selection]
		catch {$w selection set $selitem}
	}
}

proc station_itemAddEdit {tree handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemAdd \033\[0m \{$tree\} \{$handler\}"
	#handler 1 = add 2 = edit
	if {$handler == 2} {
		if {[string trim [$tree selection]] == {}} return
		if {[llength [$tree selection]] > 1} {
			log_writeOutTv 1 "You have selected more than one item to edit. Can't open edit dialog."
			return
		}
	}
	log_writeOutTv 0 "Add/Edit Item"
	
	
	set wtop [toplevel .station.top_AddEdit]
	place [ttk::frame $wtop.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
	set wfe [ttk::frame $wtop.frame_entry]
	set wfb [ttk::frame $wtop.frame_buttons -style TLabelframe]
	
	ttk::label $wfe.l_station -text [mc "Station:"]
	ttk::entry $wfe.e_station -textvariable sitem(e_Station)
	ttk::label $wfe.l_freq -text [mc "Frequency:"]
	ttk::entry $wfe.e_freq -textvariable sitem(e_Freq)
	ttk::label $wfe.l_input -text [mc "Video input:"]
	ttk::menubutton $wfe.mb_input -menu $wfe.mbVinput -textvariable sitem(mbVinput)
	menu $wfe.mbVinput -tearoff 0
	ttk::checkbutton $wfe.cb_External -text [mc "External Tuner"] -variable sitem(cbExternal) -command [list station_itemAddEditExternal $wfe.e_External]
	ttk::entry $wfe.e_External -textvariable sitem(eExternal) -state disabled
	ttk::label $wfe.l_warning -justify left
	ttk::button $wfb.b_apply -text [mc "Apply"] -compound left -image $::icon_s(dialog-ok-apply)
	ttk::button $wfb.b_exit -text [mc "Cancel"] -command [list station_itemAddEditExit $wtop] -compound left -image $::icon_s(dialog-cancel)
	
	grid $wfe -in $wtop -row 0 -column 0 -sticky nesw
	grid $wfb -in $wtop -row 1 -column 0 -sticky ew -padx 3 -pady 3
	
	grid anchor $wfb e
	
	grid $wfe.l_station -in $wfe -row 0 -column 0 -sticky w -padx 3 -pady "7 0"
	grid $wfe.e_station -in $wfe -row 1 -column 0 -padx 3
	grid $wfe.l_freq -in $wfe -row 0 -column 1 -sticky w -padx 3 -pady "7 0"
	grid $wfe.e_freq -in $wfe -row 1 -column 1 -padx 3
	grid $wfe.l_input -in $wfe -row 0 -column 2 -sticky w -padx 3 -pady "7 0"
	grid $wfe.mb_input -in $wfe -row 1 -column 2 -sticky ew -padx 3
	grid $wfe.cb_External -in $wfe -row 2 -column 0 -sticky w -padx 3 -pady "7 0"
	grid $wfe.e_External -in $wfe -row 3 -column 0 -columnspan 2 -sticky ew -padx 3 -pady "7 0"
	grid $wfe.l_warning -in $wfe -row 4 -column 0 -padx 3 -columnspan 2
	
	grid $wfb.b_apply -in $wfb -row 0 -column 0 -pady 7
	grid $wfb.b_exit -in $wfb -row 0 -column 1 -padx 3
	
	grid columnconfigure $wfe 2 -minsize 120
	
	# Subprocs
	
	catch {exec v4l2-ctl --device=$::option(video_device) -n} read_vinputs
	set status_vid_inputs [catch {agrep -m "$read_vinputs" name} resultat_vid_inputs]
	if {$status_vid_inputs == 0} {
		set i 0
		foreach vi [split $resultat_vid_inputs \n] {
			$wfe.mbVinput add radiobutton \
			-variable sitem(mbVinput) \
			-label "[string trimleft [string range $vi [string first : $vi] end] ": "]" \
			-command [list station_itemVideoNumber $i $wfe.e_freq entry_freq_apply]
			set vinput($i) "[string trimleft [string range $vi [string first : $vi] end] {: }]"
			incr i
		}
	} else {
		log_writeOutTv 2 "Can't find any video inputs, please check the preferences (analog section)."
		foreach window [winfo children .station.top_AddEdit] {
			destroy $window
		}
		destroy .station.top_AddEdit
		return
	}
	if {$handler == 1} {
		$wfb.b_apply configure -command [list station_itemApplyAddEdit $wtop $wfe.l_warning $tree 1]
		set ::sitem(mbVinput) $vinput($::option(video_input))
		set ::sitem(mbVinput_nr) $::option(video_input)
		set ::sitem(cbExternal) 0
	} else {
		$wfb.b_apply configure -command [list station_itemApplyAddEdit $wtop $wfe.l_warning $tree 2]
		set ::sitem(e_Station) [lindex [$tree item [$tree selection] -values] 0]
		set ::sitem(e_Freq) [lindex [$tree item [$tree selection] -values] 1]
		set ::sitem(mbVinput) $vinput([lindex [$tree item [$tree selection] -values] 2])
		set ::sitem(mbVinput_nr) [lindex [$tree item [$tree selection] -values] 2]
		if {[lindex [$tree item [$tree selection] -values] 3] == 0} {
			set ::sitem(cbExternal) 0
		} else {
			set ::sitem(cbExternal) 1
			set ::sitem(eExternal) [lindex [$tree item [$tree selection] -values] 3]
		}
	}
	
	wm geometry $wtop +[winfo x .station]+[winfo y .station]
	wm resizable $wtop 0 0
	if {$handler == 1} {
		wm title $wtop [mc "Add a new station"]
	} else {
		wm title $wtop [mc "Edit Station / Frequency"]
	}
	wm protocol $wtop WM_DELETE_WINDOW [list station_itemAddExit $wtop]
	wm iconphoto $wtop $::icon_b(seditor)
	wm transient $wtop .station
	if {$::option(tooltips) == 1} {
		if {$::option(tooltips_editor) == 1} {
			settooltip $wfe.e_station [mc "Provide a name for the television station."]
			settooltip $wfe.e_freq [mc "Frequency for the station. E.g. 175.250"]
			settooltip $wfb.b_apply [mc "Apply changes and close window."]
			settooltip $wfb.b_exit [mc "Exit without changes."]
		}
	}
	grab release .station
	tkwait visibility $wtop
	grab $wtop
}

proc station_itemAddEditExit {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemAddEditExit \033\[0m \{$w\}"
	unset -nocomplain ::sitem(mbVinput_nr) ::sitem(mbVinput)
	grab release $w
	destroy $w
	grab .station
}

proc station_itemApplyAddEdit {w warn tree handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemApplyAddEdit \033\[0m \{$w\} \{$warn\} \{$tree\} \{$handler\}"
	#handler 1 = add 2 = edit
	if {[info exists ::sitem(e_Station)] == 0 || [info exists ::sitem(e_Freq)] == 0} {
		$warn configure -text [mc "Please specify name and frequency for each station"] -image $::icon_m(dialog-warning) -compound left
		log_writeOutTv 2 "Please specify name and frequency for each station."
		return
	} else {
		if {[string trim $::sitem(e_Station)] == {} || [string trim $::sitem(e_Freq)] == {}} {
			$warn configure -text [mc "Please specify name and frequency for each station"] -image $::icon_m(dialog-warning) -compound left
			log_writeOutTv 2 "Please specify name and frequency for each station."
			return
		}
	}
	if {$::sitem(cbExternal) == 0} {
		set ext 0
	} else {
		set ext $::sitem(eExternal)
	}
	if {$handler == 1} {
		if {[string trim [$tree selection]] == {}} {
			$tree insert {} end -values "{$::sitem(e_Station)} [string trim $::sitem(e_Freq)] $::sitem(mbVinput_nr) {$ext}"
			$tree see  [lindex [$tree children {}] end]
		} else {
			$tree insert {} [$tree index [$tree next [lindex [$tree selection] end]]] -values "{$::sitem(e_Station)} [string trim $::sitem(e_Freq)] $::sitem(mbVinput_nr) {$ext}"
		}
		log_writeOutTv 0 "Adding item $::sitem(e_Station) [string trim $::sitem(e_Freq)] $::sitem(mbVinput_nr) {$ext} to station list."
	} else {
		$tree item [$tree selection] -values "{$::sitem(e_Station)} [string trim $::sitem(e_Freq)] $::sitem(mbVinput_nr) {$ext}"
		log_writeOutTv 0 "Edited station $::sitem(e_Station) [string trim $::sitem(e_Freq)] $::sitem(mbVinput_nr) {$ext}."
	}
	unset -nocomplain ::sitem(mbVinput_nr) ::sitem(mbVinput) ::sitem(e_Station) ::sitem(e_Freq) ::sitem(eExternal) ::sitem(cbExternal)
	grab release $w
	destroy $w
	grab .station
}

proc station_itemAddEditExternal {entry} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemDeactivate \033\[0m \{$entry\}"
	if {$::sitem(cbExternal)} {
		$entry state !disabled
	} else {
		$entry state disabled
	}
}

proc station_itemDeactivate {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemDeactivate \033\[0m \{$w\}"
	if {[string trim [$w selection]] == {}} return
	$w tag configure disabled -foreground red
	if {[llength [$w selection]] > 1} {
		foreach element [$w selection] {
			set selected_item [$w item $element -values]
			if {"[$w item $element -tags]" == "disabled"} {
				$w item $element -values "{[lindex $selected_item 0]} [lindex $selected_item 1] [lindex $selected_item 2]" -tags ""
				log_writeOutTv 0 "Enabling item $element."
			} else {
				$w item $element -values "{[lindex $selected_item 0]} [lindex $selected_item 1] [lindex $selected_item 2]" -tags disabled
				log_writeOutTv 0 "Disabling item $element."
			}
		}
	} else {
		set selected_item [$w item [$w selection] -values]
		if {"[$w item [$w selection] -tags]" == "disabled"} {
			$w item [$w selection] -values "{[lindex $selected_item 0]} [lindex $selected_item 1] [lindex $selected_item 2]" -tags ""
			log_writeOutTv 0 "Enabling item [$w selection]."
		} else {
			$w item [$w selection] -values "{[lindex $selected_item 0]} [lindex $selected_item 1] [lindex $selected_item 2]" -tags disabled
			log_writeOutTv 0 "Disabling item [$w selection]."
		}
	}
}

proc station_itemVideoNumber {vinputnr widget var} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemVideoNumber \033\[0m \{$vinputnr\} \{$widget\} \{$var\}"
	set ::sitem(mbVinput_nr) $vinputnr
	if {[info exists ::choice($var)]} {
		if {"[string trim $::choice($var)]" != {} && "$::choice($var)" != "xxx"} {
			set ::item(last_freq) $::choice($var)
		}
	}
	if {$vinputnr != 0} {
		set ::choice($var) xxx
		$widget state disabled
	} else {
		$widget state !disabled
		if {[info exists ::item(last_freq)]} {
			set ::choice($var) $::item(last_freq)
		} else {
			set ::choice($var) {}
		}
	}
}
