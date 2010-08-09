#       font_chooser.tcl
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

proc font_chooserUi {returnw cvar} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: font_chooserUi \033\[0m \{$returnw\} \{$cvar\}"
	if {[winfo exists .config_wizard.fontchooser]} {
		return
	}
	
	log_writeOutTv 0 "Starting TV-Viewer font chooser..."
	
	set w [toplevel .config_wizard.fontchooser]
	place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
	set mffont [ttk::frame $w.f_ch_font]
	set mfcol [ttk::frame $w.f_ch_col]
	set mfpre [ttk::frame $w.f_ch_pre]
	set mfbottom [ttk::frame $w.f_ch_bottom -style TLabelframe]
	
	ttk::label $mffont.l_fam -text [mc "Family:"]
	listbox $mffont.lb_fam -exportselection false -yscrollcommand [list $mffont.scrollb_famy set] -xscrollcommand [list $mffont.scrollb_famx set]
	ttk::scrollbar $mffont.scrollb_famy -orient vertical -command [list $mffont.lb_fam yview]
	ttk::scrollbar $mffont.scrollb_famx -orient horizontal -command [list $mffont.lb_fam xview]
	
	ttk::label $mffont.l_style -text [mc "Style:"]
	listbox $mffont.lb_style -exportselection false -yscrollcommand [list $mffont.scrollb_styley set]
	ttk::scrollbar $mffont.scrollb_styley -orient vertical -command [list $mffont.lb_style yview]
	
	ttk::label $mffont.l_size -text [mc "Size:"]
	listbox $mffont.lb_size -exportselection false -yscrollcommand [list $mffont.scrollb_sizey set] -width 0
	ttk::scrollbar $mffont.scrollb_sizey -orient vertical -command [list $mffont.lb_size yview]
	
	ttk::label $mfcol.l_color -text [mc "Font color:"]
	ttk::button $mfcol.b_color -compound image -image $::icon_e(pick-color3) -command [list font_chooserUiCol $mfpre.f_prev.c_abc]
	ttk::label $mfcol.l_align -text [mc "Display:"]
	ttk::menubutton $mfcol.mb_align -menu $mfcol.mbAlign -textvariable font_chooser(mb_align)
	menu $mfcol.mbAlign -tearoff 0 -background $::option(theme_$::option(use_theme))
	
	ttk::label $mfpre.l_prev -text [mc "Preview:"]
	ttk::frame $mfpre.f_prev -borderwidth 2 -relief groove
	canvas $mfpre.f_prev.c_abc -height 110 -background white
	
	ttk::button $mfbottom.b_apply -text [mc "Apply"] -command [list font_chooserUiApply $mffont.lb_fam $mffont.lb_style $mffont.lb_size $returnw $cvar] -compound left -image $::icon_s(dialog-ok-apply)
	ttk::button $mfbottom.b_cancel -text [mc "Cancel"] -command "grab release .config_wizard.fontchooser; destroy .config_wizard.fontchooser; grab .config_wizard" -compound left -image $::icon_s(dialog-cancel)
	
	
	grid columnconfigure $mfpre 0 -weight 1
	grid columnconfigure $mfpre.f_prev 0 -weight 1
	
	grid $mffont -in $w -row 0 -column 0 -sticky ew -padx 8 -pady 8
	grid $mfcol -in $w -row 1 -column 0 -sticky ew -padx 8 -pady "0 8"
	grid $mfpre -in $w -row 2 -column 0 -sticky ew -padx 8
	grid $mfbottom -in $w -row 3 -column 0 -sticky ew -padx 8 -pady 8
	
	grid anchor $mfbottom e
	
	grid $mffont.l_fam -in $mffont -row 0 -column 0 -sticky w
	grid $mffont.lb_fam -in $mffont -row 1 -column 0
	grid $mffont.scrollb_famy -row 1 -column 1 -sticky ns -padx "1 4"
	grid $mffont.scrollb_famx -row 2 -column 0 -sticky ew -pady "1 0"
	
	grid $mffont.l_style -in $mffont -row 0 -column 2 -sticky w
	grid $mffont.lb_style -in $mffont -row 1 -column 2 -rowspan 2 -sticky ns
	grid $mffont.scrollb_styley -in $mffont -row 1 -column 3 -rowspan 2 -sticky ns -padx "1 4"
	
	grid $mffont.l_size -in $mffont -row 0 -column 4 -sticky w -columnspan 2
	grid $mffont.lb_size -in $mffont -row 1 -column 4 -rowspan 2 -sticky nsew
	grid $mffont.scrollb_sizey -in $mffont -row 1 -column 5 -rowspan 2 -sticky ns -padx "1 0"
	
	grid $mfcol.l_color -in $mfcol -row 0 -column 0 -padx "0 5"
	grid $mfcol.b_color -in $mfcol -row 0 -column 1
	grid $mfcol.l_align -in $mfcol -row 0 -column 2 -padx "10 5"
	grid $mfcol.mb_align -in $mfcol -row 0 -column 3
	
	grid $mfpre.l_prev -in $mfpre -row 0 -column 0 -sticky w
	grid $mfpre.f_prev -in $mfpre -row 1 -column 0 -sticky ew
	grid $mfpre.f_prev.c_abc -in $mfpre.f_prev -row 0 -column 0 -sticky nesw
	
	grid $mfbottom.b_apply -in $mfbottom -row 0 -column 0 -pady 7
	grid $mfbottom.b_cancel -in $mfbottom -row 0 -column 1 -padx 3
	
	set fontfamilies [font families]
	lappend fontfamilies {*}Sans Serif Monospace
	set i 0
	foreach fam [lsort $fontfamilies] {
		$mffont.lb_fam insert end " $fam"
		if {"$fam" == "[lindex $::choice($cvar) 1]"} {
			set fontindex $i
		}
		incr i
	}
	
	set avail_styles {Regular Italic Bold "Bold Italic"}
	set i 0
		foreach style $avail_styles {
		$mffont.lb_style insert end " $style"
		if {"$style" == "[lindex $::choice($cvar) 2]"} {
			set styleindex $i
		}
		incr i
	}
	
	set avail_sizes {8 9 10 11 12 14 16 18 20 22 24 26 28 32 36 40 48 54 60 66 72 80 88 96}
	set i 0
	foreach size $avail_sizes {
		$mffont.lb_size insert end " $size "
		if {$size == [lindex $::choice($cvar) 3]} {
			set sizeindex $i
		}
		incr i
	}
	
	set avail_aligns [dict create [mc "top left"] 0 [mc "top"] 1 [mc "top right"] 2 [mc "left"] 3 [mc "center"] 4 [mc "right"] 5 [mc "bottom left"] 6 [mc "bottom"] 7 [mc "bottom right"] 8]
	foreach {key elem} [dict get $avail_aligns] {
		$mfcol.mbAlign add radiobutton -label "$key" -value "{$key} $elem" -command [list font_chooserUiAlign "{$key} $elem" $cvar]
	}
	
	bind $mffont.lb_fam <<ListboxSelect>> [list font_chooserUiCfont $mffont.lb_fam $mffont.lb_style $mffont.lb_size $mfpre.f_prev.c_abc]
	bind $mffont.lb_style <<ListboxSelect>> [list font_chooserUiCfont $mffont.lb_fam $mffont.lb_style $mffont.lb_size $mfpre.f_prev.c_abc]
	bind $mffont.lb_size <<ListboxSelect>> [list font_chooserUiCfont $mffont.lb_fam $mffont.lb_style $mffont.lb_size $mfpre.f_prev.c_abc]
	
	if {[info exists fontindex] == 0 || [info exists styleindex] == 0 || [info exists sizeindex] == 0} {
		log_writeOutTv 2 "Can not identify font. Font chooser will be closed. Report this incident to the Author."
		destroy $w
		return
	} else {
		$mffont.lb_fam selection set $fontindex
		$mffont.lb_fam see $fontindex
		$mffont.lb_style selection set $styleindex
		$mffont.lb_style see $styleindex
		$mffont.lb_size selection set $sizeindex
		$mffont.lb_size see $sizeindex
		$::icon_e(pick-color3) configure -foreground [lindex $::choice($cvar) end]
		$mfcol.mbAlign invoke [lindex $::choice($cvar) 4]
	}
	
	$mfpre.f_prev.c_abc create text 3 55 -text "abcdefghijk ABCDEFGHIJK" -tags theText -anchor w; $mfpre.f_prev.c_abc focus theText
	
	font_chooserUiCfont $mffont.lb_fam $mffont.lb_style $mffont.lb_size $mfpre.f_prev.c_abc
	$mfpre.f_prev.c_abc itemconfigure theText -fill [lindex $::choice($cvar) end]
	if {$::option(tooltips) == 1 && $::option(tooltips_wizard) == 1} {
		settooltip $mffont.lb_fam [mc "Choose a font"]
		settooltip $mffont.lb_style [mc "Choose font style"]
		settooltip $mffont.lb_size [mc "Choose font size"]
		settooltip $mfcol.b_color [mc "Choose font color"]
		settooltip $mfcol.mb_align [mc "Specify where the message box should be
displayed in the video frame"]
	}
	wm resizable $w 0 0
	wm protocol $w WM_DELETE_WINDOW "grab release .config_wizard.fontchooser; destroy .config_wizard.fontchooser; grab .config_wizard"
	wm title $w [mc "Choose font"]
	wm iconphoto $w $::icon_b(settings)
	wm transient $w .config_wizard
	grab release .config_wizard
	tkwait visibility $w
	grab $w
}

proc font_chooserUiCfont {lb1 lb2 lb3 pre_entry} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: font_chooserUiCfont \033\[0m \{$lb1\} \{$lb2\} \{$lb3\} \{$pre_entry\}"
	set font "[string trim [$lb1 get [$lb1 curselection]]]"
	set style "[string trim [string tolower [$lb2 get [$lb2 curselection]]]]"
	set size "[string trim [$lb3 get [$lb3 curselection]]]"
	if {"$style" == "regular"} {
		$pre_entry itemconfigure theText -font "{$font} $size"
		$pre_entry focus theText
	} else {
		$pre_entry itemconfigure theText -font "{$font} $size $style"
		$pre_entry focus theText
	}
	return
}

proc font_chooserUiCol {pre_entry} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: font_chooserUiCol \033\[0m \{$pre_entry\}"
	wm protocol .config_wizard.fontchooser WM_DELETE_WINDOW " "
	set color [tk_chooseColor -parent .config_wizard.fontchooser -initialcolor [$::icon_e(pick-color3) cget -foreground] -title [mc "Choose color"]]
	wm protocol .config_wizard.fontchooser WM_DELETE_WINDOW "grab release .config_wizard.fontchooser; destroy .config_wizard.fontchooser; grab .config_wizard"
	if {[string trim $color] != {}} {
		$::icon_e(pick-color3) configure -foreground $color
		$pre_entry itemconfigure theText -fill $color
		$pre_entry focus theText
	}
}

proc font_chooserUiAlign {value cvar} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: font_chooserUiAlign \033\[0m \{$value\} \{$cvar\}"
	set ::font_chooser(mb_align) [lindex $value 0]
	set ::font_chooser(mb_align_value) [lindex $value 1]
}

proc font_chooserUiApply {lb1 lb2 lb3 returnw cvar} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: font_chooserUiApply \033\0m \{$lb1\} \{$lb2\} \{$lb3\} \{$returnw\} \{$cvar\}"
	set font "[string trim [$lb1 get [$lb1 curselection]]]"
	set style "[string trim [$lb2 get [$lb2 curselection]]]"
	set size "[string trim [$lb3 get [$lb3 curselection]]]"
	if {"$style" == "Regular"} {
		$returnw configure -text "$font | $size"
	} else {
		$returnw configure -text "$font - $style | $size"
	}
	set ::choice($cvar) [list [lindex $::choice($cvar) 0] $font $style $size $::font_chooser(mb_align_value) [$::icon_e(pick-color3) cget -foreground]]
	log_writeOutTv 0 "Chosen font $::choice($cvar)"
	grab release .config_wizard.fontchooser
	destroy .config_wizard.fontchooser
	grab .config_wizard
}
