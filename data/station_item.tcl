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

proc station_itemDelete {tree} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemDelete \033\[0m \{$tree\}"
	if {[string trim [$tree selection]] == {}} return
	set top [toplevel .station.delete]
	place [ttk::frame $top.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
	set fMain [ttk::frame $top.f_delMain]
	set fBut [ttk::frame $top.f_delBut -style TLabelframe]
	
	ttk::label $fMain.l_delMessage -text [mc "Do you really want to delete the selected station(s)?"] -image $::icon_b(dialog-warning) -compound left
	ttk::checkbutton $fMain.cb_delAsk -text [mc "Don't ask next time"] -variable ::sitem(cbDelAsk)
	
	ttk::button $fBut.b_delCancel -text [mc "Cancel"] -compound left -image $::icon_s(dialog-cancel) -command {grab release .station.delete; destroy .station.delete; grab .station} -default active
	ttk::button $fBut.b_delApply -text [mc "Delete"] -compound left -image $::icon_s(dialog-ok-apply) -command [list station_itemDeleteRun $tree $top]
	
	grid $fMain -in $top -row 0 -column 0 -sticky ew
	grid $fBut -in $top -row 1 -column 0 -sticky ew -padx 3 -pady 3
	
	grid $fMain.l_delMessage -in $fMain -row 0 -column 0 -pady "3 7" -padx 5
	grid $fMain.cb_delAsk -in $fMain -row 1 -column 0 -sticky w -pady "0 7" -padx 5
	
	grid $fBut.b_delCancel -in $fBut -row 0 -column 0 -padx "0 3" -pady 7
	grid $fBut.b_delApply -in $fBut -row 0 -column 1 -padx "0 3" -pady 7
	grid anchor $fBut e
	
	wm iconphoto $top $::icon_b(seditor)
	wm resizable $top 0 0
	wm transient $top .station
	wm protocol $top WM_DELETE_WINDOW {grab release .station.delete; destroy .station.delete; grab .station}
	wm title $top [mc "Delete stations"]
	
	if {[info exists ::sitem(cbDelAsk)] && $::sitem(cbDelAsk)} {
		station_itemDeleteRun $tree $top
		return
	}
	
	grab release .station
	tkwait visibility $top
	grab $top
	focus $fBut.b_delCancel
}

proc station_itemDeleteRun {tree top} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemAdd \033\[0m \{$tree\} \{$top\}"
	log_writeOutTv 0 "Deleting item [$tree selection]."
	if {[llength [$tree selection]] > 1} {
		if {[$tree next [lindex [$tree selection] end]] == {}} {
			set selitem [$tree prev [lindex [$tree selection] 0]]
		} else {
			set selitem [$tree next [lindex [$tree selection] end]]
		}
		foreach element [$tree selection] {
			$tree delete $element
		}
		catch {$tree selection set $selitem}
	} else {
		if {[$tree next [$tree selection]] == {}} {
			set selitem [$tree prev [$tree selection]]
		} else {
			set selitem [$tree next [$tree selection]]
		}
		$tree delete [$tree selection]
		catch {$tree selection set $selitem}
	}
	grab release $top
	destroy $top
	grab .station
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
	ttk::checkbutton $wfe.cb_External -text [mc "External Tuner"] -variable sitem(cbExternal) -command [list station_itemAddEditExternal $wfe.lf_External.e_External $wfe.lf_External.e_ExternalFreq]
	ttk::labelframe $wfe.lf_External -labelwidget $wfe.cb_External
	set lf_external $wfe.lf_External
	ttk::label $lf_external.l_ExternalCom -text [mc "Command:"]
	ttk::label $lf_external.l_ExternalFreq -text [mc "Internal frequency:"]
	ttk::entry $lf_external.e_External -textvariable sitem(eExternal) -state disabled
	ttk::entry $lf_external.e_ExternalFreq -textvariable sitem(eExternalFreq) -state disabled
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
	grid $lf_external -in $wfe  -row 2 -column 0 -columnspan 3 -sticky ew -padx 5 -pady "5 0"
	grid $lf_external.l_ExternalCom -in $lf_external -row 0 -column 0 -sticky w -pady "3 0"
	grid $lf_external.l_ExternalFreq -in $lf_external -row 0 -column 2 -sticky w -pady "3 0"
	grid $lf_external.e_External -in $lf_external -row 1 -column 0 -columnspan 2 -sticky ew -padx 7 -pady 3
	grid $lf_external.e_ExternalFreq -in $lf_external -row 1 -column 2 -sticky ew -padx "0 7" -pady 3
	grid $wfe.l_warning -in $wfe -row 4 -column 0 -padx 3 -pady 5 -columnspan 3
	
	grid $wfb.b_apply -in $wfb -row 0 -column 0 -pady 7
	grid $wfb.b_exit -in $wfb -row 0 -column 1 -padx 3
	
	grid columnconfigure $wfe 2 -minsize 120
	grid columnconfigure $lf_external 0 -weight 1
	
	# Subprocs
	
	catch {exec v4l2-ctl --device=$::option(video_device) -n} read_vinputs
	set status_vid_inputs [catch {agrep -m "$read_vinputs" name} resultat_vid_inputs]
	if {$status_vid_inputs == 0} {
		set i 0
		foreach vi [split $resultat_vid_inputs \n] {
			$wfe.mbVinput add radiobutton \
			-variable sitem(mbVinput) \
			-label "[string trimleft [string range $vi [string first : $vi] end] ": "]" \
			-command [list station_itemVideoNumber $i $wfe.e_freq e_Freq]
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
		set ::sitem(e_Station) Name
		set ::sitem(e_Freq) 175.000
		set ::sitem(mbVinput) $vinput($::option(video_input))
		set ::sitem(mbVinput_nr) $::option(video_input)
		set ::sitem(cbExternal) 0
		set ::sitem(eExternalFreq) 0
	} else {
		$wfb.b_apply configure -command [list station_itemApplyAddEdit $wtop $wfe.l_warning $tree 2]
		set ::sitem(e_Station) [lindex [$tree item [$tree selection] -values] 0]
		set ::sitem(e_Freq) [lindex [$tree item [$tree selection] -values] 1]
		set ::sitem(mbVinput) $vinput([lindex [$tree item [$tree selection] -values] 2])
		set ::sitem(mbVinput_nr) [lindex [$tree item [$tree selection] -values] 2]
		if {[lindex [$tree item [$tree selection] -values] 3] == 0} {
			set ::sitem(cbExternal) 0
			set ::sitem(eExternalFreq) [lindex [$tree item [$tree selection] -values] 4]
		} else {
			set ::sitem(cbExternal) 1
			set ::sitem(eExternal) [lindex [$tree item [$tree selection] -values] 3]
			set ::sitem(eExternalFreq) [lindex [$tree item [$tree selection] -values] 4]
			station_itemAddEditExternal $wfe.lf_External.e_External $wfe.lf_External.e_ExternalFreq
		}
	}
	
	wm geometry $wtop +[winfo x .station]+[winfo y .station]
	wm resizable $wtop 0 0
	if {$handler == 1} {
		wm title $wtop [mc "Add a new station"]
	} else {
		wm title $wtop [mc "Edit Station / Frequency"]
	}
	wm protocol $wtop WM_DELETE_WINDOW [list station_itemAddEditExit $wtop]
	wm iconphoto $wtop $::icon_b(seditor)
	wm transient $wtop .station
	if {$::option(tooltips) == 1} {
		if {$::option(tooltips_editor) == 1} {
			settooltip $wfe.e_station [mc "Provide a name for the television station"]
			settooltip $wfe.e_freq [mc "Frequency for the station, E.g. 175.250"]
			settooltip $wfe.mb_input [mc "Video input for this station. 
Normally you want television input."]
			settooltip $wfe.cb_External [mc "Use an external tuner"]
			settooltip $lf_external.e_External [mc "Specify a command for the external tuner.
You may use this substitutions:

%%F  Frequency
%%S  Station name
e.g. externalTune %%F %%S"]
			settooltip $lf_external.e_ExternalFreq [mc "If you use an external tuner that is connected to the TV input 
of your device you may need to set the internal tuner to a
specific frequency.
Use a value of \"0\" if you do not need your internal tuner
(e.g. if you are using composite or s-video)"]
		}
	}
	grab release .station
	tkwait visibility $wtop
	grab $wtop
}

proc station_itemAddEditExit {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemAddEditExit \033\[0m \{$w\}"
	unset -nocomplain ::sitem(mbVinput_nr) ::sitem(mbVinput) ::sitem(e_Station) ::sitem(e_Freq) ::sitem(eExternal) ::sitem(eExternalFreq) ::sitem(cbExternal)
	grab release $w
	destroy $w
	grab .station
}

proc station_itemApplyAddEdit {w warn tree handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemApplyAddEdit \033\[0m \{$w\} \{$warn\} \{$tree\} \{$handler\}"
	#handler 1 = add 2 = edit
	if {[info exists ::sitem(e_Station)] == 0 || [info exists ::sitem(e_Freq)] == 0} {
		$warn configure -text [mc "Please specify name and frequency for each station"] -image $::icon_m(dialog-warning) -compound left
		log_writeOutTv 1 "Please specify name and frequency for each station."
		return
	} else {
		if {[string trim $::sitem(e_Station)] == {} || [string trim $::sitem(e_Freq)] == {}} {
			$warn configure -text [mc "Please specify name and frequency for each station"] -image $::icon_m(dialog-warning) -compound left
			log_writeOutTv 1 "Please specify name and frequency for each station."
			return
		}
	}
	if {$::sitem(cbExternal) == 0} {
		set ext 0
	} else {
		# do some regsubs %F = Frequency %S = Stationname
		set ext [regsub -all %F [regsub -all %S $::sitem(eExternal) \{$::sitem(e_Station)\}] $::sitem(e_Freq)]
	}
	if {$handler == 1} {
		if {[string trim [$tree selection]] == {}} {
			$tree insert {} end -values "{$::sitem(e_Station)} [string trim $::sitem(e_Freq)] $::sitem(mbVinput_nr) {$ext} [string trim $::sitem(eExternalFreq)]"
			$tree see  [lindex [$tree children {}] end]
			$tree selection set [lindex [$tree children {}] end]
		} else {
			$tree insert {} [$tree index [$tree next [lindex [$tree selection] end]]] -values "{$::sitem(e_Station)} [string trim $::sitem(e_Freq)] $::sitem(mbVinput_nr) {$ext} [string trim $::sitem(eExternalFreq)]"
			$tree see [$tree next [$tree selection]]
			$tree selection set [$tree next [$tree selection]]
		}
		log_writeOutTv 0 "Adding item $::sitem(e_Station) [string trim $::sitem(e_Freq)] $::sitem(mbVinput_nr) {$ext} [string trim $::sitem(eExternalFreq)] to station list."
	} else {
		$tree item [$tree selection] -values "{$::sitem(e_Station)} [string trim $::sitem(e_Freq)] $::sitem(mbVinput_nr) {$ext} [string trim $::sitem(eExternalFreq)]"
		$tree see [$tree selection]
		log_writeOutTv 0 "Edited station $::sitem(e_Station) [string trim $::sitem(e_Freq)] $::sitem(mbVinput_nr) {$ext} [string trim $::sitem(eExternalFreq)]."
	}
	unset -nocomplain ::sitem(mbVinput_nr) ::sitem(mbVinput) ::sitem(e_Station) ::sitem(e_Freq) ::sitem(eExternal) ::sitem(eExternalFreq) ::sitem(cbExternal)
	grab release $w
	destroy $w
	grab .station
}

proc station_itemAddEditExternal {entryExt entryExtFreq} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemDeactivate \033\[0m \{$entryExt\} \{$entryExtFreq\}"
	if {$::sitem(cbExternal)} {
		$entryExt state !disabled
		$entryExtFreq state !disabled
	} else {
		$entryExt state disabled
		$entryExtFreq state disabled
	}
}

proc station_itemDeactivate {tree but com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemDeactivate \033\[0m \{$tree\} \{$com\}"
	#com 0 just change button locked/unlocked - 1 really (de)activate item
	if {[string trim [$tree selection]] == {}} return
	if {$com } {
		$tree tag configure disabled -foreground red
		if {[llength [$tree selection]] > 1} {
			foreach element [$tree selection] {
				set selected_item [$tree item $element -values]
				if {"[$tree item $element -tags]" == "disabled"} {
					$tree item $element -values "{[lindex $selected_item 0]} [lindex $selected_item 1] [lindex $selected_item 2] {[lindex $selected_item 3]} [lindex $selected_item 4]" -tags ""
					log_writeOutTv 0 "Enabling item $element."
				} else {
					$tree item $element -values "{[lindex $selected_item 0]} [lindex $selected_item 1] [lindex $selected_item 2] {[lindex $selected_item 3]} [lindex $selected_item 4]" -tags disabled
					log_writeOutTv 0 "Disabling item $element."
				}
			}
		} else {
			set selected_item [$tree item [$tree selection] -values]
			if {"[$tree item [$tree selection] -tags]" == "disabled"} {
				$tree item [$tree selection] -values "{[lindex $selected_item 0]} [lindex $selected_item 1] [lindex $selected_item 2] {[lindex $selected_item 3]} [lindex $selected_item 4]" -tags ""
				log_writeOutTv 0 "Enabling item [$tree selection]."
			} else {
				$tree item [$tree selection] -values "{[lindex $selected_item 0]} [lindex $selected_item 1] [lindex $selected_item 2] {[lindex $selected_item 3]} [lindex $selected_item 4]" -tags disabled
				log_writeOutTv 0 "Disabling item [$tree selection]."
			}
		}
	}
	if {[llength [$tree selection]] > 1} {
		set item [lindex [$tree selection] end]
	} else {
		set item [$tree selection]
	}
	if {"[$tree item $item -tags]" == "disabled"} {
		$but configure -image $::icon_m(unlocked) -text [mc "Unlock"]
		if {[winfo exists $tree.mCont]} {
			$tree.mCont entryconfigure 5 -image $::icon_men(unlocked) -label [mc "Unlock"]
		}
	} else {
		$but configure -image $::icon_m(locked) -text [mc "Lock"]
		if {[winfo exists $tree.mCont]} {
			$tree.mCont entryconfigure 5 -image $::icon_men(locked) -label [mc "Lock"]
		}
	}
}

proc station_itemVideoNumber {vinputnr widget var} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_itemVideoNumber \033\[0m \{$vinputnr\} \{$widget\} \{$var\}"
	set ::sitem(mbVinput_nr) $vinputnr
	if {[info exists ::sitem($var)]} {
		if {"[string trim $::sitem($var)]" != {} && "$::sitem($var)" != "0"} {
			set ::sitem(last_freq) $::sitem($var)
		}
	}
	if {$vinputnr != 0} {
		set ::sitem($var) 0
	} else {
		if {[info exists s::sitem(last_freq)]} {
			set ::sitem($var) $::sitem(last_freq)
		} else {
			set ::sitem($var) {}
		}
	}
}
