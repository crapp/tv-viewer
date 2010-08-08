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
		
		set w [toplevel .key -class "TV-Viewer"] 
		
		place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		
		set mftop [ttk::frame $w.f_key_top]
		
		set mftree [ttk::frame $w.f_key_treeview]
		
		set mfbottom [ttk::frame $w.f_key_bottom -style TLabelframe]
		
		ttk::label $mftop.l_key_msg \
		-text [mc "Available Key Sequences"]
		
		ttk::treeview $mftree.tv_key \
		-yscrollcommand [list $mftree.sb_key set] \
		-columns {action key} \
		-show headings
			
		ttk::scrollbar $mftree.sb_key \
		-orient vertical \
		-command [list $mftree.tv_key yview]
		
		ttk::button .key.f_key_bottom.b_exit \
		-text [mc "Exit"] \
		-compound left \
		-image $::icon_s(dialog-close) \
		-command [list destroy $w]
		
		grid $mftop -in $w -row 0 -column 0
		grid $mftree -in $w -row 1 -column 0
		grid $mfbottom -in $w -row 2 -column 0 \
		-sticky ew \
		-padx 3 \
		-pady 3
		grid anchor $mfbottom e
		
		grid $mftop.l_key_msg -in $mftop -row 0 -column 0 \
		-padx "3 0" \
		-pady 2
		grid $mftree.tv_key -in $mftree -row 0 -column 0 \
		-sticky nesw
		grid $mftree.sb_key -in $mftree -row 0 -column 1 \
		-sticky ns \
		-pady 5
		grid $mfbottom.b_exit -in $mfbottom -row 0 -column 0 \
		-pady 7 \
		-padx 3
		
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
		
		wm resizable $w 0 0
		wm title $w [mc "Key Sequences"]
		wm protocol $w WM_DELETE_WINDOW [list destroy $w]
		wm iconphoto $w $::icon_b(key-bindings)
		tkwait visibility $w
	}
}
