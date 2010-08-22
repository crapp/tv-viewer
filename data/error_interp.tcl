#       error_interp.tcl
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

proc error_interpUi {msg options} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: error_interpUi \033\[0m \{$msg\} \{$options\}"
	log_writeOutTv 2 "TV-Viewer crashed..."
	log_writeOutTv 2 "$msg"
	if {[info exists ::err(cb_stoperr)]} {
		if {$::err(cb_stoperr) == 1} {
			log_writeOutTv 1 "User does not want to see error dialog anymore."
			return
		}
	}
	set w [toplevel .error_w] ; place [ttk::label $w.bg -style Toolbutton] -relwidth 1 -relheight 1
	set mf [ttk::frame $w.f_main]
	set bf [ttk::frame $w.f_buttons -style TLabelframe]
	
	ttk::label $mf.l_info -image $::icon_m(dialog-warning) -compound left
	text $mf.t_info -yscrollcommand [list $mf.scrollb_info set] -wrap word -height 10
	ttk::scrollbar $mf.scrollb_info -command [list $mf.t_info yview]
	ttk::checkbutton $mf.cb_stoperr -variable err(cb_stoperr) -text [mc "Skip further error messages"]
	ttk::button $bf.b_ok -text [mc "OK"] -command [list destroy $w]
	ttk::button $bf.b_bugr -text [mc "File bug report"] -command error_interpFbug
	ttk::button $bf.b_save -text [mc "Save to disk"] -command [list error_interpSdisk $msg $options]
	
	grid rowconfigure $w 0 -weight 1
	grid rowconfigure $mf 0 -weight 1
	grid columnconfigure $w 0 -weight 1
	grid columnconfigure $mf 0 -weight 1
	
	grid $mf -in $w -row 0 -column 0 -sticky nesw
	grid $bf -in $w -row 1 -column 0 -sticky ew -padx 3 -pady 3
	
	grid anchor $bf e
	
	grid $mf.l_info -in $mf -row 0 -column 0 -sticky w -padx 5 -pady 10 -columnspan 2
	grid $mf.t_info -in $mf -row 1 -column 0 -sticky nesw -padx 3 -pady 3
	grid $mf.scrollb_info -in $mf -row 1 -column 1 -sticky ns -pady 5
	grid $mf.cb_stoperr -in $mf -row 2 -column 0 -sticky w -padx 5 -pady 7
	
	grid $bf.b_ok -in $bf -row 0 -column 0 -pady 7 -padx 3
	grid $bf.b_bugr -in $bf -row 0 -column 1 -pady 7 -padx "0 3"
	grid $bf.b_save -in $bf -row 0 -column 2 -pady 7 -padx "0 3"
	
	if {[string trim $msg] != {}} {
		$mf.l_info configure -text [mc "Error: %" $msg]
	}
	if {[string trim $options] != {}} {
		if {[dict exists $options -errorinfo]} {
			$mf.t_info insert end [dict get $options -errorinfo]
		}
	}
	
	foreach event {<KeyPress> <<PasteSelection>>} {
		bind $mf.t_info $event break
	}
	bind $mf.t_info <Control-c> {event generate %W <<Copy>>}
	bind $mf.t_info <Control-Key-a> {%W tag add sel 0.0 end; break}
	bind $mf.t_info <ButtonPress-3> [list tk_popup $mf.t_info.mContext %X %Y]
	
	menu $mf.t_info.mContext -tearoff 0
	
	$mf.t_info.mContext add command -label [mc "Select everything"] -compound left -image $::icon_men(placeholder) -command [list $mf.t_info tag add sel 0.0 end] -accelerator [mc "Ctrl-A"]
	$mf.t_info.mContext add separator
	$mf.t_info.mContext add command -label [mc "Copy to clipboard"] -compound left -image $::icon_men(clipboard) -command [list event generate $mf.t_info <<Copy>>] -accelerator [mc "Ctrl-C"]
	
	wm resizable $w 0 0
	wm title $w [mc "TV-Viewer crashed"]
	wm iconphoto $w $::icon_b(dialog-error)
	
	::tk::PlaceWindow $w
	raise $w
	vid_wmCursor 0
	::tk::SetFocusGrab $w

	tkwait visibility $w
	$mf.l_info configure -wraplength [winfo reqwidth $mf.t_info]
	tkwait window $w
	vid_wmCursor 1
	::tk::RestoreFocusGrab $w destroy
}

proc error_interpFbug {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: error_interpFbug \033\[0m"
	log_writeOutTv 0 "Executing your favorite internet browser."
	catch {exec xdg-open http://sourceforge.net/tracker/?func=add&group_id=238442&atid=1106486 &}
}

proc error_interpSdisk {msg options} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: error_interpSdisk \033\[0m \{$msg\} \{$options\}"
	set types {
	{{Log Files}      {.log}       }
	}
	set infile "tv-viewer_error.log"
	set ofile [ttk::getSaveFile -filetypes $types -defaultextension ".log" -initialfile "$infile" -initialdir "$::env(HOME)" -hidden 0 -title [mc "Choose name and location"] -parent .error_w]
	if {[string trim $ofile] != {}} {
		if {[file isdirectory [file dirname "$ofile"]]} {
			log_writeOutTv 0 "Saving error message to log file:"
			log_writeOutTv 0 "$ofile"
			set ofilew [open "$ofile" w+]
			puts $ofilew "TV-Viewer [lindex $::option(release_version) 0] r[lindex $::option(release_version) 1] error log
"
			puts $ofilew "Message: $msg

"
			if {[string trim $options] != {}} {
				if {[dict exists $options -errorinfo]} {
					puts $ofilew "Errorinfo: [dict get $options -errorinfo]"
				}
			}
			close $ofilew
		} else {
			log_writeOutTv 2 "Can not save timeshift video file."
			log_writeOutTv 2 "[file dirname $ofile]"
			log_writeOutTv 2 "Not a directory."
		}
	}
}

proc error_interpWarn {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: error_interpWarn \033\[0m"
	
}
