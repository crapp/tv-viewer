#       key_sequences.tcl
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

proc key_sequences {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: key_sequences \033\[0m"
	#FIXME Make key sequences editable 
	if {[winfo exists .key] == 0} {
		log_writeOutTv 0 "Launching key sequences screen..."
		
		set w [toplevel .key]
		place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		set mftop [ttk::frame $w.f_key_top]
		set mftree [ttk::frame $w.f_key_treeview]
		set mfbottom [ttk::frame $w.f_key_bottom -style TLabelframe]
		
		ttk::label $mftop.l_key_msg -text [mc "Available Key Sequences"]
		
		ttk::treeview $mftree.tv_key -yscrollcommand [list $mftree.sb_key set] -columns {action key} -show headings
		ttk::scrollbar $mftree.sb_key -orient vertical -command [list $mftree.tv_key yview]
		ttk::button $mftree.b_ChangeKey -command [list key_sequencesEdit $mftree.tv_key] -text [mc "Change shortcut"]
		ttk::button $mfbottom.b_save -text [mc "Apply"] -command "" -compound left -image $::icon_s(dialog-ok-apply)
		ttk::button $mfbottom.b_default -text [mc "Default"]
		ttk::button $mfbottom.b_quit -text [mc "Cancel"] -command "" -compound left -image $::icon_s(dialog-cancel)
		
		grid $mftop -in $w -row 0 -column 0
		grid $mftree -in $w -row 1 -column 0
		grid $mfbottom -in $w -row 2 -column 0 -sticky ew -padx 3 -pady 3
		grid anchor $mfbottom e
		
		grid $mftop.l_key_msg -in $mftop -row 0 -column 0 -padx "3 0" -pady 2
		grid $mftree.tv_key -in $mftree -row 0 -column 0 -sticky nesw
		grid $mftree.sb_key -in $mftree -row 0 -column 1 -sticky ns -pady 5
		grid $mftree.b_ChangeKey -in $mftree -row 1 -column 0 -sticky e -padx 3 -pady "7 7"
		grid $mfbottom.b_save -in $mfbottom -row 0 -column 0 -pady 7 -padx "0 3"
		grid $mfbottom.b_default -in $mfbottom -row 0 -column 1 -pady 7 -padx "0 3"
		grid $mfbottom.b_quit -in $mfbottom -row 0 -column 2 -pady 7 -padx "0 3"
		
		set font [ttk::style lookup [$mftree.tv_key cget -style] -font]
		if {[string trim $font] == {}} {
			set font TkDefaultFont
			puts $::main(debug_msg) "\033\[0;1;33mDebug: key_sequences \033\[0;1;31m::font:: \033\[0m"
		}
		foreach col {action key} name {"Action" "Key Sequence"} {
			$mftree.tv_key heading $col -text $name
		}
		$mftree.tv_key heading action -text [mc "Action"]
		$mftree.tv_key heading key -text [mc "Key Sequence"]
		$mftree.tv_key tag configure fat -font "TkTextFont [font actual TkTextFont -displayof $mftree.tv_key -size] bold"
		$mftree.tv_key tag configure small -font "TkTextFont 1"
		
		if {$::option(language_value) != 0} {
			set keseq "$::option(root)/shortcuts/keysequ_$::option(language_value).conf"
		} else {
			set locale_split [lindex [split $::env(LANG) _] 0]
			set keseq "$::option(root)/shortcuts/keysequ_$locale_split.conf"
			if {[file exists "$keseq"] == 0} {
				log_writeOutTv 1 "No translated Key Sequences for $::env(LANG)"
				log_writeOutTv 1 "Switching back to english."
				set keseq "$::option(root)/shortcuts/keysequ_en.conf"
			}
		}
		if {[file exists "$keseq"]} {
			set open_keyseq [open "$keseq" r]
			set line_length 0
			while {[gets $open_keyseq line]!=-1} {
				if {[string trim $line] == {} } continue
				if {[string match #* $line]} {
					if {[llength [$mftree.tv_key children {}]] != 0} {
						$mftree.tv_key insert {} end -values " " -tags small
						$mftree.tv_key insert {} end -values [list [lindex $line 1] [lindex $line end]] -tags fat
					} else {
						$mftree.tv_key insert {} end -values [list [lindex $line 1] [lindex $line end]] -tags fat
					}
				} else {
					$mftree.tv_key insert {} end -values [list [lindex $line 0] [lindex $line end]]
				}
				if {[font measure $font "[lindex $line 0]"] > $line_length} {
					set line_length [font measure $font "[lindex $line 0]"]
				}
			}
			close $open_keyseq
		}
		$mftree.tv_key column action -width [expr $line_length + 40]
		$mftree.tv_key column key -width [expr [font measure $font [mc "Key Sequence"]] + 25]
		bind $mftree.tv_key <B1-Motion> break
		bind $mftree.tv_key <Motion> break
		bind $mftree.tv_key <Double-ButtonPress-1> [list key_sequencesEdit $mftree.tv_key]
		
		wm resizable $w 0 0
		wm title $w [mc "Key Sequences"]
		wm protocol $w WM_DELETE_WINDOW [list destroy $w]
		wm iconphoto $w $::icon_b(key-bindings)
		tkwait visibility $w
	} else {
		raise .key
	}
}

proc key_sequencesEdit {tree} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: key_sequencesEdit \033\[0m"
	if {[winfo exists $tree.w_keyEdit]} {
		log_writeOutTv 0 "Edit dialog for shortcuts already open"
		return
	}
	if {[llength [$tree selection]] == 0} {
		log_writeOutTv 0 "No item selected to edit the shortcut"
		return
	}
	if {[string trim [lindex [$tree item [$tree selection] -values] end]] == {}} {
		log_writeOutTv 0 "No item selected to edit the shortcut"
		return
	}
	set w [toplevel $tree.w_keyEdit]
	set f [ttk::frame $w.f_edit]
	ttk::label $f.l_Key -text [mc "Press the key combination you want to assign"]
	ttk::entry $f.e_Key -textvariable key(entrySequence) -state readonly
	
	ttk::button $f.b_KeyClear -text [mc "Clear"] -command {set ::key(entrySequence) ""; set ::key(sequenceList) ""}
	ttk::button $f.b_KeyCancel -text [mc "Cancel"] -command {grab release .key.f_key_treeview.tv_key.w_keyEdit; destroy .key.f_key_treeview.tv_key.w_keyEdit}
	ttk::button $f.b_KeyApply -text [mc "Apply"] -command [list key_sequencesEditApply $tree]
	
	grid $f -in $w -row 0 -column 0 -sticky nesw
	grid $f.l_Key -in $f -row 0 -column 0 -sticky w -pady 3
	grid $f.e_Key -in $f -row 1 -column 0 -columnspan 3 -sticky ew
	grid $f.b_KeyClear -in $f -row 2 -column 0 -sticky w -padx 3 -pady "3 5"
	grid $f.b_KeyCancel -in $f -row 2 -column 1 -sticky e -padx "0 3" -pady "3 5"
	grid $f.b_KeyApply -in $f -row 2 -column 2 -sticky e -padx "0 3" -pady "3 5"
	
	grid rowconfigure $w 0 -weight 1
	grid columnconfigure $w 0 -weight 1
	
	wm title $w [mc "Modify shortcut"]
	wm resizable $w 0 0
	wm transient $w .key
	wm iconphoto $w $::icon_b(key-bindings)
	wm protocol $w WM_DELETE_WINDOW {grab release .key.f_key_treeview.tv_key.w_keyEdit; destroy .key.f_key_treeview.tv_key.w_keyEdit}
	
	bind $w <KeyPress> {key_sequencesProcess %K}
	bind $w <KeyRelease> {set ::key(sequenceDone) 1}
	
	set ::key(sequenceList) ""
	set ::key(sequenceDone) 0
	set ::key(entrySequence) [lindex [$tree item [$tree selection] -values] end]
	
	tkwait visibility $w
	grab $w
}

proc key_sequencesProcess {key} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: key_sequencesProcess \033\[0m \{$key\}"
	set noKey {Num_Lock Print Scroll_Lock Pause Menu ISO_Level3_Shift Tab Caps_Lock}
	foreach k $noKey {
		if {[string match $k $key]} {
			log_writeOutTv 1 "It is not possible to use $key for a shortcut"
			return
		}
	}
	if {[string match KP_* $key]} {
		array set kpKey {
			KP_Divide "/"
			KP_Multiply "*"
			KP_Subtract "-"
			KP_Home 7
			KP_Up 8
			KP_Prior 9
			KP_Left 4
			KP_Begin 5
			KP_Right 6
			KP_Add "+"
			KP_Enter "Enter"
			KP_End 1
			KP_Down 2
			KP_Next 3
			KP_Insert 0
			KP_Delete ","
		}
		foreach kp [array get kpKey] {
			if {"$kp" == "$key"} {
				set key $kpKey($kp)
				break
			}
		}
	}
	if {[string match Control_* $key]} {
		set key Ctrl
	}
	if {[string match Shift_* $key]} {
		set key Shift
	}
	if {[string match Super_* $key]} {
		set key Super
	}
	if {[string match Alt_* $key]} {
		set key Alt
	}
	if {[string match plus $key]} {
		set key +
	}
	if {[string match minus $key]} {
		set key -
	}
	if {[string length $key] == 1 && [regexp {[a-z]} $key]} {
		set key [string toupper $key]
	}
	if {"[lindex $::key(sequenceList) end]" == "$key"} return
	if {$::key(sequenceDone)} {
		set ::key(sequenceList) ""
		set ::key(sequenceDone) 0
	}
	lappend ::key(sequenceList) $key
	set ::key(entrySequence) ""
	if {[llength $::key(sequenceList)] > 1} {
		set i 1
		foreach pkey $::key(sequenceList) {
			if {[llength $::key(sequenceList)] == $i} {
				append ::key(entrySequence) "$pkey"
				continue
			}
			append ::key(entrySequence) "$pkey\+"
			incr i
		}
	} else {
		set ::key(entrySequence) $key
	}
}

proc key_sequencesEditApply {tree} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: key_sequencesProcess \033\[0m \{$tree\}"
	$tree item [$tree selection] -values "[lrange [$tree item [$tree selection] -values] 0 end-1] $::key(entrySequence)"
	grab release $tree.w_keyEdit
	destroy $tree.w_keyEdit
}
