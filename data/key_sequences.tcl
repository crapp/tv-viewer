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
	if {[winfo exists .key] == 0} {
		log_writeOutTv 0 "Launching key sequences screen..."
		
		set w [toplevel .key]
		place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		set mftop [ttk::frame $w.f_key_top]
		set mftree [ttk::frame $w.f_key_treeview]
		set mfbottom [ttk::frame $w.f_key_bottom -style TLabelframe]
		
		ttk::label $mftop.l_key_msg -text [mc "Available Key Sequences"]
		
		ttk::treeview $mftree.tv_key -yscrollcommand [list $mftree.sb_key set] -columns {action key} -show headings -selectmode browse
		ttk::scrollbar $mftree.sb_key -orient vertical -command [list $mftree.tv_key yview]
		ttk::button $mftree.b_ChangeKey -command [list key_sequencesEdit $mftree.tv_key] -text [mc "Change shortcut"]
		ttk::button $mfbottom.b_save -text [mc "Apply"] -command [list key_sequencesApply $w $mftree.tv_key] -compound left -image $::icon_s(dialog-ok-apply)
		ttk::button $mfbottom.b_default -text [mc "Default"] -command [list key_sequencesDefault $mftree.tv_key]
		ttk::button $mfbottom.b_quit -text [mc "Cancel"] -command [list destroy $w] -compound left -image $::icon_s(dialog-cancel)
		
		grid $mftop -in $w -row 0 -column 0
		grid $mftree -in $w -row 1 -column 0
		grid $mfbottom -in $w -row 2 -column 0 -sticky ew -padx 3 -pady 3
		grid anchor $mfbottom e
		
		grid $mftop.l_key_msg -in $mftop -row 0 -column 0 -padx "3 0" -pady 2
		grid $mftree.tv_key -in $mftree -row 0 -column 0 -sticky nesw
		grid $mftree.sb_key -in $mftree -row 0 -column 1 -sticky ns -pady 5
		grid $mftree.b_ChangeKey -in $mftree -row 1 -column 0 -sticky e -padx 3 -pady "7 7"
		grid $mfbottom.b_save -in $mfbottom -row 0 -column 0 -pady 7 -padx "0 3"
		grid $mfbottom.b_default -in $mfbottom -row 0 -column 1 -pady 7 -padx "0 3" -sticky ns
		grid $mfbottom.b_quit -in $mfbottom -row 0 -column 2 -pady 7 -padx "0 3"
		
		foreach col {action key} name {"Action" "Key Sequence"} {
			$mftree.tv_key heading $col -text $name
		}
		set font [ttk::style lookup [$mftree.tv_key cget -style] -font]
		if {[string trim $font] == {}} {
			set font TkDefaultFont
			puts $::main(debug_msg) "\033\[0;1;33mDebug: key_sequences \033\[0;1;31m::font:: \033\[0m"
		}
		key_sequencesRead 1 $mftree.tv_key
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

proc key_sequencesRead {handler tree} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: key_sequencesRead \033\[0m \{$handler\} \{$tree\}"
	#handler 0 == read default; 1 == read standard
	foreach child [$tree children {}] {
		$tree delete $child
	}
	set font [ttk::style lookup [$tree cget -style] -font]
	if {[string trim $font] == {}} {
		set font TkDefaultFont
		puts $::main(debug_msg) "\033\[0;1;33mDebug: key_sequences \033\[0;1;31m::font:: \033\[0m"
	}
	$tree heading action -text [mc "Action"]
	$tree heading key -text [mc "Key Sequence"]
	$tree tag configure fat -font "TkTextFont [font actual TkTextFont -displayof $tree -size] bold"
	$tree tag configure small -font "TkTextFont 1"
	array set keyTags {
		1 noedit
		2 noedit
		3 noedit
		4 noedit
		5 noedit
		6 noedit
		7 noedit
		8 noedit
		9 noedit
		10 noedit
		11 {}
		12 {}
		13 {}
		14 {}
		15 noedit
		16 {}
		17 {}
		18 {}
		19 {}
		20 {}
		21 {}
		22 {}
		23 {}
		24 {}
		25 {}
		26 {}
		27 {}
		28 {}
		29 {}
		30 {}
		31 {}
		32 {}
		33 {}
		34 {}
		35 {}
		36 noedit
		37 noedit
		38 {}
		39 {}
		40 {}
		41 {}
		42 {}
		43 {}
		44 {}
		45 {}
		46 {}
		47 {}
		48 {}
	}
	set line_length 0
	set i 1
	if {$handler == 0} {
		process_KeyFile 0
		if {[winfo exists .key.default]} {
			vid_wmCursor 1
			grab release .key.default
			destroy .key.default
		}
	}
	foreach id [dict keys $::keyseq] {
		if {$i == 1} {
			$tree insert {} end -values [list [mc "General"]] -tags {fat noedit}
		}
		if {$i == 11} {
			$tree insert {} end -values " " -tags {small noedit}
			$tree insert {} end -values [list [mc "Television"]] -tags {fat noedit}
		}
		if {$i == 23} {
			$tree insert {} end -values " " -tags {small noedit}
			$tree insert {} end -values [list [mc "Window management"]] -tags {fat noedit}
		}
		if {$i == 36} {
			$tree insert {} end -values " " -tags {small noedit}
			$tree insert {} end -values [list [mc "Recording / File playback"]] -tags {fat noedit}
		}
		$tree insert {} end -values [list "[dict get $::keyseq $id label]" "[dict get $::keyseq $id name]"] -tags $keyTags($i)
		if {[font measure $font "[dict get $::keyseq $id label]"] > $line_length} {
			set line_length [font measure $font "[dict get $::keyseq $id label]"]
		}
		incr i
	}
	$tree column action -width [expr $line_length + 40]
	$tree column key -width [expr [font measure $font [mc "Key Sequence"]] + 25]
}

proc key_sequencesDefault {tree} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: key_sequencesDefault \033\[0m \{$tree\}"
	set top [toplevel .key.default]
	place [ttk::frame $top.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
	set fMain [ttk::frame $top.f_defMain]
	set fBut [ttk::frame $top.f_defBut -style TLabelframe]
	
	ttk::label $fMain.l_defMessage -text [mc "Do you really want to load default values for all key sequences?

This will happen instantly and can not be undone!"] -image $::icon_b(dialog-warning) -compound left
	
	ttk::button $fBut.b_defCancel -text [mc "Cancel"] -compound left -image $::icon_s(dialog-cancel) -command {vid_wmCursor 1; grab release .key.default; destroy .key.default} -default active
	ttk::button $fBut.b_defApply -text [mc "Apply"] -compound left -image $::icon_s(dialog-ok-apply) -command [list key_sequencesRead 0 $tree]
	
	grid $fMain -in $top -row 0 -column 0 -sticky ew
	grid $fBut -in $top -row 1 -column 0 -sticky ew -padx 3 -pady 3
	
	grid $fMain.l_defMessage -in $fMain -row 0 -column 0 -pady "3 7" -padx 5
	
	grid $fBut.b_defCancel -in $fBut -row 0 -column 0 -padx "0 3" -pady 7
	grid $fBut.b_defApply -in $fBut -row 0 -column 1 -padx "0 3" -pady 7
	grid anchor $fBut e
	
	wm iconphoto $top $::icon_b(key-bindings)
	wm resizable $top 0 0
	wm transient $top .key
	wm protocol $top WM_DELETE_WINDOW {vid_wmCursor 1; grab release .key.default; destroy .key.default}
	wm title $top [mc "Set shortcuts to default values"]
	
	tkwait visibility $top
	vid_wmCursor 0
	grab $top
	focus $fBut.b_defCancel
}

proc key_sequencesApply {top tree} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: key_sequencesApply \033\[0m \{$top\} \{$tree\}"
	catch {file delete $::option(home)/config/key-sequences.key}
	set keyf [open $::option(home)/config/key-sequences.key w+]
	foreach child [$tree children {}] {
		if {[string match *fat* [$tree item $child -tags]] || [string match *small* [$tree item $child -tags]] || [string trim [$tree item $child -values]] == {}} continue
		lappend setKeys [lindex [$tree item $child -values] 1]
	}
	foreach key [dict keys $::keyseq] children $setKeys {
		puts $keyf [list $key name $children]
		set i 1
		set doResidue 1
		if {[string match "+" $children] || [string match "-" $children]} {
			set keySeq [regsub -all {^\+} $children <Key-plus]
			if {"$keySeq" == "<Key-plus"} {
				append childSeqKP "<Key-KP_Add"
			}
			set keySeq [regsub -all {^\-} $keySeq <Key-minus]
			if {"$keySeq" == "<Key-minus"} {
				append childSeqKP "<Key-KP_Subtract"
			}
			append childSeq "$keySeq"
			unset -nocomplain keySeq
			set doResidue 0
		}
		if {[string match "*++" $children] || [string match "*+-" $children]} {
			set children [regsub -all {\+\-} $children +Key-minus]
			set children [regsub -all {\+\+} $children +Key-plus]
			set doResidue 1
		}
		if {$doResidue} {
			set returnValue [key_sequencesApplyManString $children $i]
			if {[llength $returnValue] > 1} {
				set childSeq [lindex $returnValue 0]
				set childSeqKP [lindex $returnValue 1]
			} else {
				set childSeq $returnValue
			}
		}
		if {[info exists childSeqKP]} {
			append childSeq ">"
			append childSeqKP ">"
			puts $keyf [list $key seq "$childSeq $childSeqKP"]
		} else {
			append childSeq ">"
			puts $keyf [list $key seq $childSeq]
		}
		unset -nocomplain childSeq childSeqKP
	}
	log_writeOutTv 0 "Writing new shortcuts to"
	log_writeOutTv 0 "$::option(home)/config/key-sequences.key"
	close $keyf
	destroy .key
	process_KeyFile 1
	main_menuCreate .foptions_bar .fstations.ftoolb_ChanCtrl .ftoolb_Play .fvidBg standard
	event_delete all
	if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
		event_constr 0
	} else {
		event_constr 1
	}
}

proc key_sequencesApplyManString {children i} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: key_sequencesApplyManString \033\[0m \{$children\}"
	foreach elem [split $children "+"] {
		if {[string match "Ctrl" [string trim $elem]]} {
			if {$i == 1} {
				append childSeq "<Control"
			} else {
				append childSeq "-Control"
			}
			incr i
			continue
		}
		if {[string match {[A-Z]} $elem]} {
			if {$i == 1} {
				append childSeq "<Key-[string tolower $elem]"
			} else {
				if {[string match "*Shift*" $childSeq]} {
					append childSeq "-Key-$elem"
				} else {
					append childSeq "-Key-[string tolower $elem]"
				}
			}
			incr i
			continue
		}
		if {[regexp {[^A-Za-z]*} $elem] && [string match "*Shift*" $elem] != 1 && [string match "*Alt" $elem] != 1 && [string match "*Ctrl*" $elem] != 1 && [string match "*Key-*" $elem] != 1} {
			if {[string match "Super" $elem]} {
				if {$i == 1} {
					append childSeq "<Mod4"
				} else {
					append childSeq "-Mod4"
				}
				incr i
				continue
			}
			if {[string match "Return" $elem]} {
				if {$i == 1} {
					append childSeq "<Key-$elem"
					append childSeqKP "<Key-KP_Enter"
				} else {
					append childSeq "-Key-$elem"
					set childSeqKP [regsub -all "Key-$elem" $childSeq Key-KP_Enter]
				}
				incr i
				continue
			}
			if {[string match "asterisk" $elem]} {
				if {$i == 1} {
					append childSeq "<Key-$elem"
					append childSeqKP "<Key-KP_Multiply"
				} else {
					append childSeq "-Key-$elem"
					set childSeqKP [regsub -all "Key-$elem" $childSeq Key-KP_Multiply]
				}
				incr i
				continue
			}
			if {[string match "slash" $elem]} {
				if {$i == 1} {
					append childSeq "<Key-$elem"
					append childSeqKP "<Key-KP_Divide"
				} else {
					append childSeq "-Key-$elem"
					set childSeqKP [regsub -all "Key-$elem" $childSeq Key-KP_Divide]
				}
				incr i
				continue
			}
			if {[string match "comma" $elem]} {
				if {$i == 1} {
					append childSeq "<Key-$elem"
					append childSeqKP "<Key-KP_Delete"
				} else {
					append childSeq "-Key-$elem"
					set childSeqKP [regsub -all "Key-$elem" $childSeq Key-KP_Delete]
				}
				incr i
				continue
			}
			if {$i == 1} {
				append childSeq "<Key-$elem"
			} else {
				append childSeq "-Key-$elem"
			}
			incr i
			continue
		}
		if {[string match "*Key-minus*" $elem]} {
			set childSeqKP "$childSeq[regsub -all {Key-minus} $elem -Key-KP_Subtract]"
		}
		if {[string match "*Key-plus*" $elem]} {
			set childSeqKP "$childSeq[regsub -all {Key-plus} $elem -Key-KP_Add]"
		}
		if {$i == 1} {
			append childSeq "<$elem"
		} else {
			append childSeq "-$elem"
		}
		incr i
	}
	if {[info exists childSeqKP]} {
		return [list $childSeq $childSeqKP]
	} else {
		return [list $childSeq]
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
	if {[llength [$tree item [$tree selection] -tags]] > 1} {
		set tag [lindex [$tree item [$tree selection] -tags] 1]
	} else {
		set tag [$tree item [$tree selection] -tags]
	}
	set w [toplevel $tree.w_keyEdit]
	set f [ttk::frame $w.f_edit]
	ttk::label $f.l_Key -text [mc "Press the key combination you want to assign"]
	ttk::entry $f.e_Key -textvariable key(entrySequence) -state readonly
	ttk::label $f.l_KeyWarn
	
	ttk::button $f.b_KeyClear -text [mc "Clear"] -command {set ::key(entrySequence) ""; set ::key(sequenceList) ""}
	ttk::button $f.b_KeyCancel -text [mc "Cancel"] -command {vid_wmCursor 1; grab release .key.f_key_treeview.tv_key.w_keyEdit; destroy .key.f_key_treeview.tv_key.w_keyEdit}
	ttk::button $f.b_KeyApply -text [mc "Apply"] -command [list key_sequencesEditApply $tree $f.l_KeyWarn]
	
	
	grid $f -in $w -row 0 -column 0 -sticky nesw
	grid $f.l_Key -in $f -row 0 -column 0 -sticky w -pady 3
	grid $f.e_Key -in $f -row 1 -column 0 -columnspan 3 -sticky ew
	grid $f.l_KeyWarn -in $f -row 2 -column 0 -sticky w -pady 3
	grid $f.b_KeyClear -in $f -row 3 -column 0 -sticky w -padx 3 -pady "3 5"
	grid $f.b_KeyCancel -in $f -row 3 -column 1 -sticky e -padx "0 3" -pady "3 5"
	grid $f.b_KeyApply -in $f -row 3 -column 2 -sticky e -padx "0 3" -pady "3 5"
	
	grid rowconfigure $w 0 -weight 1
	grid columnconfigure $w 0 -weight 1
	
	wm title $w [mc "Modify shortcut"]
	wm resizable $w 0 0
	wm transient $w .key
	wm iconphoto $w $::icon_b(key-bindings)
	wm protocol $w WM_DELETE_WINDOW {vid_wmCursor 1; grab release .key.f_key_treeview.tv_key.w_keyEdit; destroy .key.f_key_treeview.tv_key.w_keyEdit}
	
	bind $w <KeyPress> {key_sequencesProcess %K}
	bind $w <KeyRelease> {set ::key(sequenceDone) 1}
	
	set ::key(sequenceList) ""
	set ::key(sequenceDone) 0
	set ::key(entrySequence) [lindex [$tree item [$tree selection] -values] end]
	if {"$tag" == "noedit"} {
		log_writeOutTv 1 "Key sequence \"[lindex [$tree item [$tree selection] -values] 0]\" can not be edited"
		$f.b_KeyApply state disabled
		$f.b_KeyClear state disabled
		$f.e_Key state disabled
		$f.l_KeyWarn configure -text [mc "It is not possible to edit this shortcut"] -image $::icon_m(dialog-warning) -compound left
	}
	
	tkwait visibility $w
	vid_wmCursor 0
	grab $w
}

proc key_sequencesProcess {key} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: key_sequencesProcess \033\[0m \{$key\}"
	set noKey {Num_Lock Print Scroll_Lock Pause Menu ISO_Level3_Shift Tab Caps_Lock ?? Meta_L Meta_R}
	foreach k $noKey {
		if {"$k" == "$key"} {
			log_writeOutTv 1 "It is not possible to use $key for a shortcut"
			return
		}
	}
	if {[string match KP_* $key]} {
		array set kpKey {
			KP_Divide "slash"
			KP_Multiply "asterisk"
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
			KP_Delete "comma"
		}
		foreach kp [array get kpKey] {
			if {"$kp" == "$key"} {
				set key $kpKey($kp)
				break
			}
		}
	}
	if {[string match Enter $key]} {
		set key Return
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
	if {"[lindex $::key(sequenceList) end]" == "$key" && [llength $::key(sequenceList)] == 1} {
		puts "lindex $::key(sequenceList) end [lindex $::key(sequenceList) end]"
		puts "key $key"
		puts "llength $::key(sequenceList) [llength $::key(sequenceList)]"
		return
	}
	set goOn 1
	if {[llength $::key(sequenceList)] >= 1 && $::key(sequenceDone) == 0} {
		set lastKey {Ctrl Shift Super Alt}
		set goOn 0
		foreach k $lastKey {
			if {"[lindex $::key(sequenceList) end]" == "$k"} {
				set goOn 1
				break
			}
		}
	}
	puts "goOn $goOn"
	puts "key $key"
	puts "::key(sequenceDone) $::key(sequenceDone)"
	puts "llength ::key(sequenceList) [llength $::key(sequenceList)]"
	if {$goOn == 0} {
		log_writeOutTv 1 "It is only allowed to use several modifier keys"
		if {$::key(sequenceDone)} {
			set ::key(sequenceList) ""
			set ::key(sequenceDone) 0
		}
		return
	}
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

proc key_sequencesEditApply {tree lbl} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: key_sequencesProcess \033\[0m \{$tree\} \{$lbl\}"
	set end 0
	foreach child [$tree children {}] {
		if {[string trim $::key(entrySequence)] != {} && [string is integer "$::key(entrySequence)"]} {
			$lbl configure -text [mc "Conflict detected with station by number \"0-9\""] -image $::icon_m(dialog-warning) -compound left
			log_writeOutTv 1 "Conflict detected with station by number \[0-9\]"
			set end 1
			break
		}
		if {"[lindex [$tree item $child -values] 1]" == "$::key(entrySequence)" && "[$tree selection]" != "$child"} {
			set conflictKey "[lindex [$tree item $child -values] 0]"
			$lbl configure -text [mc "Conflict detected with %" $conflictKey] -image $::icon_m(dialog-warning) -compound left
			log_writeOutTv 1 "Conflict detected with $conflictKey"
			set end 1
			break
		}
	}
	if {$end} return
	$tree item [$tree selection] -values "[lrange [$tree item [$tree selection] -values] 0 end-1] $::key(entrySequence)"
	log_writeOutTv 0 "Changing key sequence for \"[lindex [$tree item [$tree selection] -values] 0]\" to \"$::key(entrySequence)\""
	vid_wmCursor 1
	grab release $tree.w_keyEdit
	destroy $tree.w_keyEdit
}
