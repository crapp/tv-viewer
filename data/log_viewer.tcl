#       log_viewer.tcl
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

proc log_viewerCheck {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: log_viewerCheck \033\[0m"
	if {$::option(log_files) == 1} {
		if {[file exists "$::option(where_is_home)/log/tvviewer.log"]} {
			if {[file size "$::option(where_is_home)/log/tvviewer.log"] > [expr $::option(log_size_tvviewer) * 1000]} {
				catch {file delete "$::option(where_is_home)/log/tvviewer.log"}
				set logf_tv_open [open "$::option(where_is_home)/log/tvviewer.log" w]
				puts $logf_tv_open "
########################################################################
# TV-Viewer logfile. Release version [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]
# Start new session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
#"
				close $logf_tv_open
				set ::logf_tv_open_append [open "$::option(where_is_home)/log/tvviewer.log" a]
			} else {
				set ::logf_tv_open_append [open "$::option(where_is_home)/log/tvviewer.log" a]
				puts $::logf_tv_open_append "
########################################################################
# TV-Viewer logfile. Release version [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]
# Start new session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
#"
				flush $::logf_tv_open_append
			}
		} else {
			set logf_tv_open [open "$::option(where_is_home)/log/tvviewer.log" w]
			puts $logf_tv_open "
########################################################################
# TV-Viewer logfile. Release version [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]
# Start new session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
#"
			close $logf_tv_open
			set ::logf_tv_open_append [open "$::option(where_is_home)/log/tvviewer.log" a]
		}
		if {[file exists "$::option(where_is_home)/log/videoplayer.log"]} {
			if {[file size "$::option(where_is_home)/log/videoplayer.log"] > [expr $::option(log_size_mplay) * 1000]} {
				catch {file delete "$::option(where_is_home)/log/videoplayer.log"}
				set logf_mpl_open [open "$::option(where_is_home)/log/videoplayer.log" w]
				puts $logf_mpl_open "
########################################################################
# MPlayer logfile. Release version [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]
# Start new session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
#"
				close $logf_mpl_open
				set ::logf_mpl_open_append [open "$::option(where_is_home)/log/videoplayer.log" a]
			} else {
				set ::logf_mpl_open_append [open "$::option(where_is_home)/log/videoplayer.log" a]
				puts $::logf_mpl_open_append "
########################################################################
# MPlayer logfile. Release version [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]
# Start new session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]"
				flush $::logf_tv_open_append
			}
		} else {
			set logf_mpl_open [open "$::option(where_is_home)/log/videoplayer.log" w]
			puts $logf_mpl_open "
########################################################################
# MPlayer logfile. Release version [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]
# Start new session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
#"
			close $logf_mpl_open
			set ::logf_mpl_open_append [open "$::option(where_is_home)/log/videoplayer.log" a]
		}
		log_writeOutTv 0 "Logging is enabled in the configuration."
		log_writeOutTv 0 "Starting to log events generated by TV-Viewer and MPlayer."
	} else {
		set ::logf_mpl_open_append [open /dev/null a]
		set ::logf_tv_open_append [open /dev/null a]
	}
	fconfigure $::logf_tv_open_append -blocking no -buffering line
	fconfigure $::logf_mpl_open_append -blocking no -buffering line
}

proc log_viewerSaveLog {handler parent} {
	set types {
	{{Logfiles}      {.log}       }
	}
	array set sofile {
		type(tv) tv-viewer
		type(mpl) videoplayer
		type(sched) scheduler
	}
	
	set ofile [ttk::getSaveFile -filetypes $types -defaultextension ".log" -initialdir "$::env(HOME)" -initialfile "[subst $sofile(type\($handler\))]" -hidden 0 -title [mc "Choose output file"] -parent $parent]
	if {[string trim $ofile] == {}} {
		return
	}
	if {[file isdirectory [file dirname "$ofile"]] == 0} {
		log_writeOutTv 2 "Can not save logfile"
		log_writeOutTv 2 "$ofile"
		log_writeOutTv 2 "Not a directory"
		return
	}
	file copy "$::option(where_is_home)/log/$sofile(type\($handler\)).log" "$ofile"
}

proc log_viewerMplayer {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: log_viewerMplayer \033\[0m"
	if {[winfo exists .log_viewer_mplayer] == 0} {
		
		log_writeOutTv 0 "Launching log viewer for MPlayer."
		
		set w [toplevel .log_viewer_mplayer -class "TV-Viewer Log Viewer"]
		
		place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		
		set mf [ttk::frame $w.f_log_mplayer]
		
		set wfbottom [ttk::frame $w.f_log_mplayer_buttons -style TLabelframe]
		
		set ftop [ttk::frame $w.f_log_mplayer_top]
		
		ttk::separator $w.sep_main \
		-orient horizontal
		
		ttk::button $ftop.b_save \
		-style Toolbutton \
		-image $::icon_m(floppy) \
		-command [list log_viewerSaveLog mpl $w]
		
		ttk::button $ftop.b_email \
		-style Toolbutton \
		-image $::icon_m(e-mail) \
		-command {catch {exec xdg-email saedelaere@arcor.de --attach "$::option(where_is_home)/log/videoplayer.log" &}}
		
		ttk::separator $ftop.sep_sep1 \
		-orient vertical
		
		ttk::checkbutton $ftop.cb_verb_debug \
		-text Debug \
		-variable log(verboseMpl_debug) \
		-command [list log_viewerMplReadFile $mf.t_log_mplayer $mf.lb_log_mplayer]
		
		ttk::checkbutton $ftop.cb_verb_warn \
		-text Warning \
		-variable log(verboseMpl_warn) \
		-command [list log_viewerMplReadFile $mf.t_log_mplayer $mf.lb_log_mplayer]
		
		ttk::checkbutton $ftop.cb_verb_err \
		-text Error \
		-variable log(verboseMpl_err) \
		-command [list log_viewerMplReadFile $mf.t_log_mplayer $mf.lb_log_mplayer]
		
		listbox $mf.lb_log_mplayer \
		-yscrollcommand [list $mf.scrollb_lb_log_mplayer set] \
		-width 0
		
		ttk::scrollbar $mf.scrollb_lb_log_mplayer \
		-command [list $mf.lb_log_mplayer yview]
		
		text $mf.t_log_mplayer \
		-yscrollcommand [list $mf.scrollb_log_mplayer set] \
		-wrap word
		
		ttk::scrollbar $mf.scrollb_log_mplayer \
		-command [list $mf.t_log_mplayer yview]
		
		ttk::button $wfbottom.b_exit_log_mplayer \
		-text [mc "Exit"] \
		-compound left \
		-image $::icon_s(dialog-close) \
		-command "destroy $w; set ::choice(cb_log_mpl_main) 0; log_viewerMplTail 0 cancel 0"
		
		grid $ftop -in $w -row 0 -column 0 \
		-sticky ew
		grid $w.sep_main -in $w -row 1 -column 0 \
		-sticky ew \
		-padx 4
		grid $mf -in $w -row 2 -column 0 \
		-sticky nesw
		grid $wfbottom -in $w -row 3 -column 0 \
		-sticky ew \
		-padx 3 \
		-pady 3
		
		grid anchor $wfbottom e
		
		grid $ftop.b_save -in $ftop -row 0 -column 0 \
		-padx 2 \
		-pady 1
		grid $ftop.b_email -in $ftop -row 0 -column 1 \
		-pady 1
		grid $ftop.sep_sep1 -in $ftop -row 0 -column 2 \
		-sticky ns \
		-padx 5
		grid $ftop.cb_verb_debug -in $ftop -row 0 -column 3 \
		-padx 2
		grid $ftop.cb_verb_warn -in $ftop -row 0 -column 4 \
		-padx 2
		grid $ftop.cb_verb_err -in $ftop -row 0 -column 5
		
		grid $mf.lb_log_mplayer -in $mf -row 0 -column 0 \
		-sticky nesw \
		-pady 3 \
		-padx 3
		grid $mf.scrollb_lb_log_mplayer -in $mf -row 0 -column 1 \
		-sticky ns \
		-pady 5
		grid $mf.t_log_mplayer -in $mf -row 0 -column 2 \
		-sticky nesw \
		-pady 3 \
		-padx 3
		grid $mf.scrollb_log_mplayer -in $mf -row 0 -column 3 \
		-sticky ns \
		-pady 5
		grid $wfbottom.b_exit_log_mplayer -in $wfbottom -row 0 -column 0 \
		-pady 7 \
		-padx 3
		
		grid rowconfigure $mf 0 -weight 1 -minsize 350
		grid columnconfigure $mf 2 -weight 1 -minsize 515
		grid rowconfigure $w {0} -weight 1
		grid columnconfigure $w {0} -weight 1
		
		autoscroll $mf.scrollb_lb_log_mplayer
		autoscroll $mf.scrollb_log_mplayer
		
		wm title $w [mc "MPlayer Log"]
		wm protocol $w WM_DELETE_WINDOW "destroy $w; set ::choice(cb_log_mpl_main) 0; log_viewerMplTail 0 cancel 0"
		wm iconphoto $w $::icon_e(tv-viewer_icon)
		
		foreach event {<KeyPress> <<PasteSelection>>} {
			bind $mf.t_log_mplayer $event break
		}
		bind $mf.t_log_mplayer <Control-c> {event generate %W <<Copy>>}
		
		if {$::option(tooltips) == 1 && $::option(tooltips_main) == 1} {
			settooltip $ftop.b_save [mc "Save logfile to disk"]
			settooltip $ftop.b_email [mc "Send logfile by e-mail to the authors"]
			settooltip $ftop.cb_verb_debug [mc "Show/hide Debug messages"]
			settooltip $ftop.cb_verb_warn [mc "Show/hide Warning messages"]
			settooltip $ftop.cb_verb_err [mc "Show/hide Error messages"]
		}
		
		set ::log(verboseMpl_debug) 1
		set ::log(verboseMpl_warn) 1
		set ::log(verboseMpl_err) 1
		log_writeOutTv 0 "Read existing logfile, insert into log viewer and start monitoring logfile for MPlayer."
		after 0 [list log_viewerMplReadFile $mf.t_log_mplayer $mf.lb_log_mplayer]
		tkwait visibility .log_viewer_mplayer
		log_viewerMplayerLb $mf.lb_log_mplayer
		wm minsize .log_viewer_mplayer [winfo reqwidth .log_viewer_mplayer] [winfo reqheight .log_viewer_mplayer]
	} else {
		log_writeOutTv 0 "Closing log viewer for MPlayer."
		log_viewerMplTail 0 cancel 0; destroy .log_viewer_mplayer
	}
}

proc log_viewerMplReadFile {logw loglb} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: log_viewerMplReadFile \033\[0m \{$logw\}"
	if {[file exists "$::option(where_is_home)/log/videoplayer.log"]} {
		log_viewerMplTail 0 cancel 0
		$logw delete 0.0 end
		$loglb delete 0 end
		set mlogfile_open [open "$::option(where_is_home)/log/videoplayer.log" r]
		$logw tag configure fat_blue -font "TkTextFont [font actual TkTextFont -displayof $logw -size] bold" -foreground #0030C4
		$logw tag configure fat_red -font "TkTextFont [font actual TkTextFont -displayof $logw -size] bold" -foreground #DF0F0F
		set i 0
		set match_date ""
		while {[gets $mlogfile_open line]!=-1} {
			set match 0
			if {$::log(verboseMpl_warn) == 1} {
				if {[string match "*WARNING:*" $line]} {
					set match 1
					$logw insert end $line\n fat_blue
				}
			} else {
				if {[string match "*WARNING:*" $line]} continue
			}
			if {$::log(verboseMpl_err) == 1} {
				if {[string match "*ERROR:*" $line]} {
					set match 1
					$logw insert end $line\n fat_red
				}
			} else {
				if {[string match "*ERROR:*" $line]} continue
			}
			if {$::log(verboseMpl_debug) == 1} {
				if {[string match "*DEBUG:*" $line]} {
					set match 1
					$logw insert end $line\n
				}
			} else {
				if {[string match "*DEBUG:*" $line]} continue
			}
			if {[string match "# Start new session*" $line]} {
				set match 1
				if {"[lindex $line 4]" == "$match_date"} {
					incr i
					$loglb insert end "Session [lindex $line 4] - $i"
					set match_date [lindex $line 4]
					$logw insert end $line\n
					$logw mark set [string map {{ } {}} "[lindex $line 4] - $i"] [$logw index "end -10 chars"]
				} else {
					$loglb insert end "Session [lindex $line 4] - 1"
					set i 1
					set match_date [lindex $line 4]
					$logw insert end $line\n
					$logw mark set [string map {{ } {}} "[lindex $line 4] - 1"] [$logw index "end -10 chars"]
				}
			}
			if {$match == 0} {
				$logw insert end $line\n
			}
			unset -nocomplain match
		}
		bind $loglb <<ListboxSelect>> [list log_viewerMplayerLb $loglb]
		$loglb activate end
		$loglb selection set end
		$loglb see end
		seek $mlogfile_open 0 end
		set position [tell $mlogfile_open]
		close $mlogfile_open
		set ::data(log_mpl_id) [after 100 "log_viewerMplTail $::option(where_is_home)/log/videoplayer.log $position $logw"]
	}
}

proc log_viewerMplTail {filename position logw} {
	if {"$position" == "cancel"} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: log_viewerMplTail \033\[0;1;31m::cancel:: \033\[0m"
		catch {after cancel $::data(log_mpl_id)}
		unset -nocomplain ::data(log_mpl_id)
		return
	}
	if {[winfo exists .log_viewer_mplayer]} {
		$logw tag configure fat_blue -font "TkTextFont [font actual TkTextFont -displayof $logw -size] bold" -foreground #0030C4
		
		$logw tag configure fat_red -font "TkTextFont [font actual TkTextFont -displayof $logw -size] bold" -foreground #DF0F0F
		
		set fh [open $filename r]
		fconfigure $fh -blocking no -buffering line
		seek $fh $position start
		while {[eof $fh] == 0} {
			gets $fh line
			if {[string length $line] > 0} {
				if {$::log(verboseMpl_warn) == 1} {
					if {[string match "*WARNING:*" $line]} {
						$logw insert end $line\n fat_blue
						$logw see end
					}
				} else {
					if {[string match "*WARNING:*" $line]} continue
				}
				if {$::log(verboseMpl_err) == 1} {
					if {[string match "*ERROR:*" $line]} {
						$logw insert end $line\n fat_red
						$logw see end
					}
				} else {
					if {[string match "*ERROR:*" $line]} continue
				}
				if {$::log(verboseMpl_debug) == 1} {
					if {[string match "*DEBUG:*" $line]} {
						$logw insert end $line\n
						$logw see end
					}
				} else {
					if {[string match "*DEBUG:*" $line]} continue
				}
			}
		}
		set position [tell $fh]
		close $fh
		set ::data(log_mpl_id) [after 1000 [list log_viewerMplTail $filename $position $logw]]
	}
}

proc log_viewerMplayerLb {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: log_viewerMplayerLb \033\[0m \{$w\}"
	set get_lb_index [$w curselection]
	set get_lb_content [$w get $get_lb_index]
	set marking [string map {{ } {}} [lrange $get_lb_content end-2 end]]
	.log_viewer_mplayer.f_log_mplayer.t_log_mplayer see $marking
}

proc log_writeOutMpl {handler text} {
	set logformat "#"
	if {$handler == 0} {
		append logformat " \[[clock format [clock scan now] -format {%H:%M:%S}]\] DEBUG: "
	}
	if {$handler == 1} {
		append logformat " \[[clock format [clock scan now] -format {%H:%M:%S}]\] WARNING: "
	}
	if {$handler == 2} {
		append logformat " \[[clock format [clock scan now] -format {%H:%M:%S}]\] ERROR: "
	}
	puts $::logf_mpl_open_append "$logformat $text"
	flush $::logf_mpl_open_append
}

proc log_viewerScheduler {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: log_viewerScheduler \033\[0m"
	if {[winfo exists .log_viewer_scheduler] == 0} {
		
		log_writeOutTv 0 "Launching log viewer for Scheduler."
		
		set w [toplevel .log_viewer_scheduler -class "TV-Viewer Log Viewer"]
		
		place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		
		set mf [ttk::frame $w.f_log_scheduler]
		
		set wfbottom [ttk::frame $w.f_log_scheduler_buttons -style TLabelframe]
		
		set ftop [ttk::frame $w.f_log_scheduler_top]
		
		ttk::separator $w.sep_main \
		-orient horizontal
		
		ttk::button $ftop.b_save \
		-style Toolbutton \
		-image $::icon_m(floppy) \
		-command [list log_viewerSaveLog sched $w]
		
		ttk::button $ftop.b_email \
		-style Toolbutton \
		-image $::icon_m(e-mail) \
		-command {catch {exec xdg-email saedelaere@arcor.de --attach "$::option(where_is_home)/log/scheduler.log" &}}
		
		ttk::separator $ftop.sep_sep1 \
		-orient vertical
		
		ttk::checkbutton $ftop.cb_verb_debug \
		-text Debug \
		-variable log(verboseSched_debug) \
		-command [list log_viewerSchedReadFile $mf.t_log_scheduler $mf.lb_log_scheduler]
		
		ttk::checkbutton $ftop.cb_verb_warn \
		-text Warning \
		-variable log(verboseSched_warn) \
		-command [list log_viewerSchedReadFile $mf.t_log_scheduler $mf.lb_log_scheduler]
		
		ttk::checkbutton $ftop.cb_verb_err \
		-text Error \
		-variable log(verboseSched_err) \
		-command [list log_viewerSchedReadFile $mf.t_log_scheduler $mf.lb_log_scheduler]
		
		listbox $mf.lb_log_scheduler \
		-yscrollcommand [list $mf.scrollb_lb_log_scheduler set] \
		-width 0
		
		ttk::scrollbar $mf.scrollb_lb_log_scheduler \
		-command [list $mf.lb_log_scheduler yview]
		
		text $mf.t_log_scheduler \
		-yscrollcommand [list $mf.scrollb_log_scheduler set] \
		-wrap word
		
		ttk::scrollbar $mf.scrollb_log_scheduler \
		-command [list $mf.t_log_scheduler yview]
		
		ttk::button $wfbottom.b_exit_log_scheduler \
		-text [mc "Exit"] \
		-compound left \
		-image $::icon_s(dialog-close) \
		-command "destroy $w; set ::choice(cb_log_sched_main) 0; log_viewerSchedTail 0 cancel 0"
		
		grid $ftop -in $w -row 0 -column 0 \
		-sticky ew
		grid $w.sep_main -in $w -row 1 -column 0 \
		-sticky ew \
		-padx 4
		grid $mf -in $w -row 2 -column 0 \
		-sticky nesw
		grid $wfbottom -in $w -row 3 -column 0 \
		-sticky ew \
		-padx 3 \
		-pady 3
		
		grid anchor $wfbottom e
		
		grid $ftop.b_save -in $ftop -row 0 -column 0 \
		-padx 2 \
		-pady 1
		grid $ftop.b_email -in $ftop -row 0 -column 1 \
		-pady 1
		grid $ftop.sep_sep1 -in $ftop -row 0 -column 2 \
		-sticky ns \
		-padx 5
		grid $ftop.cb_verb_debug -in $ftop -row 0 -column 3 \
		-padx 2
		grid $ftop.cb_verb_warn -in $ftop -row 0 -column 4 \
		-padx 2
		grid $ftop.cb_verb_err -in $ftop -row 0 -column 5
		
		grid $mf.lb_log_scheduler -in $mf -row 0 -column 0 \
		-sticky nesw \
		-pady 3 \
		-padx 3
		grid $mf.scrollb_lb_log_scheduler -in $mf -row 0 -column 1 \
		-sticky ns \
		-pady 5
		grid $mf.t_log_scheduler -in $mf -row 0 -column 2 \
		-sticky nesw \
		-pady 3 \
		-padx 3
		grid $mf.scrollb_log_scheduler -in $mf -row 0 -column 3 \
		-sticky ns \
		-pady 5
		grid $wfbottom.b_exit_log_scheduler -in $wfbottom -row 0 -column 0 \
		-pady 7 \
		-padx 3
		
		grid rowconfigure $mf 0 -weight 1 -minsize 350
		grid columnconfigure $mf 2 -weight 1 -minsize 515
		grid rowconfigure $w {0} -weight 1
		grid columnconfigure $w {0} -weight 1
		
		autoscroll $mf.scrollb_lb_log_scheduler
		autoscroll $mf.scrollb_log_scheduler
		
		wm title $w [mc "Scheduler Log"]
		wm protocol $w WM_DELETE_WINDOW "destroy $w; set ::choice(cb_log_sched_main) 0; log_viewerSchedTail 0 cancel 0"
		wm iconphoto $w $::icon_e(tv-viewer_icon)
		
		foreach event {<KeyPress> <<PasteSelection>>} {
			bind $mf.t_log_scheduler $event break
		}
		bind $mf.t_log_scheduler <Control-c> {event generate %W <<Copy>>}
		
		if {$::option(tooltips) == 1 && $::option(tooltips_main) == 1} {
			settooltip $ftop.b_save [mc "Save logfile to disk"]
			settooltip $ftop.b_email [mc "Send logfile by e-mail to the authors"]
			settooltip $ftop.cb_verb_debug [mc "Show/hide Debug messages"]
			settooltip $ftop.cb_verb_warn [mc "Show/hide Warning messages"]
			settooltip $ftop.cb_verb_err [mc "Show/hide Error messages"]
		}
		
		set ::log(verboseSched_debug) 1
		set ::log(verboseSched_warn) 1
		set ::log(verboseSched_err) 1
		log_writeOutTv 0 "Read existing logfile, insert into log viewer and start monitoring logfile for Scheduler."
		after 0 [list log_viewerSchedReadFile $mf.t_log_scheduler $mf.lb_log_scheduler]
		tkwait visibility .log_viewer_scheduler
		log_viewerSchedLb $mf.lb_log_scheduler
		wm minsize .log_viewer_scheduler [winfo reqwidth .log_viewer_scheduler] [winfo reqheight .log_viewer_scheduler]
	} else {
		log_writeOutTv 0 "Closing log viewer for Scheduler."
		log_viewerSchedTail 0 cancel 0; destroy .log_viewer_scheduler
	}
}

proc log_viewerSchedReadFile {logw loglb} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: log_viewerSchedReadFile \033\[0m \{$logw\}"
	if {[file exists "$::option(where_is_home)/log/scheduler.log"]} {
		log_viewerSchedTail 0 cancel 0
		$logw delete 0.0 end
		$loglb delete 0 end
		set mlogfile_open [open "$::option(where_is_home)/log/scheduler.log" r]
		$logw tag configure fat_blue -font "TkTextFont [font actual TkTextFont -displayof $logw -size] bold" -foreground #0030C4
		$logw tag configure fat_red -font "TkTextFont [font actual TkTextFont -displayof $logw -size] bold" -foreground #DF0F0F
		set i 0
		set match_date ""
		while {[gets $mlogfile_open line]!=-1} {
			set match 0
			if {$::log(verboseSched_warn) == 1} {
				if {[string match "*WARNING:*" $line]} {
					set match 1
					$logw insert end $line\n fat_blue
				}
			} else {
				if {[string match "*WARNING:*" $line]} continue
			}
			if {$::log(verboseSched_err) == 1} {
				if {[string match "*ERROR:*" $line]} {
					set match 1
					$logw insert end $line\n fat_red
				}
			} else {
				if {[string match "*ERROR:*" $line]} continue
			}
			if {$::log(verboseSched_debug) == 1} {
				if {[string match "*DEBUG:*" $line]} {
					set match 1
					$logw insert end $line\n
				}
			} else {
				if {[string match "*DEBUG:*" $line]} continue
			}
			if {[string match "# Start new session*" $line]} {
				set match 1
				if {"[lindex $line 4]" == "$match_date"} {
					incr i
					$loglb insert end "Session [lindex $line 4] - $i"
					set match_date [lindex $line 4]
					$logw insert end $line\n
					$logw mark set [string map {{ } {}} "[lindex $line 4] - $i"] [$logw index "end -10 chars"]
				} else {
					$loglb insert end "Session [lindex $line 4] - 1"
					set i 1
					set match_date [lindex $line 4]
					$logw insert end $line\n
					$logw mark set [string map {{ } {}} "[lindex $line 4] - 1"] [$logw index "end -10 chars"]
				}
			}
			if {$match == 0} {
				$logw insert end $line\n
			}
			unset -nocomplain match
		}
		bind $loglb <<ListboxSelect>> [list log_viewerSchedLb $loglb]
		$loglb activate end
		$loglb selection set end
		$loglb see end
		seek $mlogfile_open 0 end
		set position [tell $mlogfile_open]
		close $mlogfile_open
		set ::data(log_sched_id) [after 100 "log_viewerSchedTail $::option(where_is_home)/log/scheduler.log $position $logw"]
	}
}

proc log_viewerSchedTail {filename position logw} {
	if {"$position" == "cancel"} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: log_viewerSchedTail \033\[0;1;31m::cancel:: \033\[0m"
		catch {after cancel $::data(log_sched_id)}
		unset -nocomplain ::data(log_sched_id)
		return
	}
	if {[winfo exists .log_viewer_scheduler]} {
		$logw tag configure fat_blue -font "TkTextFont [font actual TkTextFont -displayof $logw -size] bold" -foreground #0030C4
		
		$logw tag configure fat_red -font "TkTextFont [font actual TkTextFont -displayof $logw -size] bold" -foreground #DF0F0F
		
		set fh [open $filename r]
		fconfigure $fh -blocking no -buffering line
		seek $fh $position start
		while {[eof $fh] == 0} {
			gets $fh line
			if {[string length $line] > 0} {
				set match 0
				if {$::log(verboseSched_warn) == 1} {
					if {[string match "*WARNING:*" $line]} {
						set match 1
						$logw insert end $line\n fat_blue
						$logw see end
					}
				} else {
					if {[string match "*WARNING:*" $line]} continue
				}
				if {$::log(verboseSched_err) == 1} {
					if {[string match "*ERROR:*" $line]} {
						set match 1
						$logw insert end $line\n fat_red
						$logw see end
					}
				} else {
					if {[string match "*ERROR:*" $line]} continue
				}
				if {$::log(verboseSched_debug) == 1} {
					if {[string match "*DEBUG:*" $line]} {
						set match 1
						$logw insert end $line\n
						$logw see end
					}
				} else {
					if {[string match "*DEBUG:*" $line]} continue
				}
				if {$match == 0} {
					$logw insert end $line\n
					$logw see end
				}
				unset -nocomplain match
			}
		}
		set position [tell $fh]
		close $fh
		set ::data(log_sched_id) [after 1000 [list log_viewerSchedTail $filename $position $logw]]
	}
}

proc log_viewerSchedLb {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: log_viewerSchedLb \033\[0m \{$w\}"
	set get_lb_index [$w curselection]
	set get_lb_content [$w get $get_lb_index]
	set marking [string map {{ } {}} [lrange $get_lb_content end-2 end]]
	.log_viewer_scheduler.f_log_scheduler.t_log_scheduler see $marking
}

proc log_viewerTvViewer {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: log_viewerTvViewer \033\[0m"
	if {[winfo exists .log_viewer_tvviewer] == 0} {
		
		log_writeOutTv 0 "Launching log viewer for TV-Viewer."
		
		set w [toplevel .log_viewer_tvviewer -class "TV-Viewer Log Viewer"]
		
		place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		
		set mf [ttk::frame $w.f_log_tvviewer]
		
		set wfbottom [ttk::frame $w.f_log_tvviewer_buttons -style TLabelframe]
		
		set ftop [ttk::frame $w.f_log_tvviewer_top]
		
		ttk::separator $w.sep_main \
		-orient horizontal
		
		ttk::button $ftop.b_save \
		-style Toolbutton \
		-image $::icon_m(floppy) \
		-command [list log_viewerSaveLog tv $w]
		
		ttk::button $ftop.b_email \
		-style Toolbutton \
		-image $::icon_m(e-mail) \
		-command {catch {exec xdg-email saedelaere@arcor.de --attach "$::option(where_is_home)/log/tvviewer.log" &}}
		
		ttk::separator $ftop.sep_sep1 \
		-orient vertical
		
		ttk::checkbutton $ftop.cb_verb_debug \
		-text Debug \
		-variable log(verboseTv_debug) \
		-command [list log_viewerTvReadFile $mf.t_log_tvviewer $mf.lb_log_tvviewer]
		
		ttk::checkbutton $ftop.cb_verb_warn \
		-text Warning \
		-variable log(verboseTv_warn) \
		-command [list log_viewerTvReadFile $mf.t_log_tvviewer $mf.lb_log_tvviewer]
		
		ttk::checkbutton $ftop.cb_verb_err \
		-text Error \
		-variable log(verboseTv_err) \
		-command [list log_viewerTvReadFile $mf.t_log_tvviewer $mf.lb_log_tvviewer]
		
		listbox $mf.lb_log_tvviewer \
		-yscrollcommand [list $mf.scrollb_lb_log_tvviewer set] \
		-width 0
		
		ttk::scrollbar $mf.scrollb_lb_log_tvviewer \
		-command [list $mf.lb_log_tvviewer yview]
		
		text $mf.t_log_tvviewer \
		-yscrollcommand [list $mf.scrollb_log_tvviewer set] \
		-wrap word
		
		ttk::scrollbar $mf.scrollb_log_tvviewer \
		-command [list $mf.t_log_tvviewer yview]
		
		ttk::button $wfbottom.b_exit_log_tvviewer \
		-text [mc "Exit"] \
		-compound left \
		-image $::icon_s(dialog-close) \
		-command "destroy $w; set ::choice(cb_log_tv_main) 0; log_viewerTvTail 0 cancel 0"
		
		grid $ftop -in $w -row 0 -column 0 \
		-sticky ew
		grid $w.sep_main -in $w -row 1 -column 0 \
		-sticky ew \
		-padx 4
		grid $mf -in $w -row 2 -column 0 \
		-sticky nesw
		grid $wfbottom -in $w -row 3 -column 0 \
		-sticky ew \
		-padx 3 \
		-pady 3
		
		grid anchor $wfbottom e
		
		grid $ftop.b_save -in $ftop -row 0 -column 0 \
		-padx 2 \
		-pady 1
		grid $ftop.b_email -in $ftop -row 0 -column 1 \
		-pady 1
		grid $ftop.sep_sep1 -in $ftop -row 0 -column 2 \
		-sticky ns \
		-padx 5
		grid $ftop.cb_verb_debug -in $ftop -row 0 -column 3 \
		-padx 2
		grid $ftop.cb_verb_warn -in $ftop -row 0 -column 4 \
		-padx 2
		grid $ftop.cb_verb_err -in $ftop -row 0 -column 5
		
		grid $mf.lb_log_tvviewer -in $mf -row 0 -column 0 \
		-sticky nesw \
		-pady 3 \
		-padx 3
		grid $mf.scrollb_lb_log_tvviewer -in $mf -row 0 -column 1 \
		-sticky ns \
		-pady 5
		grid $mf.t_log_tvviewer -in $mf -row 0 -column 2 \
		-sticky nesw \
		-pady 3 \
		-padx 3
		grid $mf.scrollb_log_tvviewer -in $mf -row 0 -column 3 \
		-sticky ns \
		-pady 5
		grid $wfbottom.b_exit_log_tvviewer -in $wfbottom -row 0 -column 0 \
		-pady 7 \
		-padx 3
		
		grid rowconfigure $mf 0 -weight 1 -minsize 350
		grid columnconfigure $mf 2 -weight 1 -minsize 515
		grid rowconfigure $w {0} -weight 1
		grid columnconfigure $w {0} -weight 1
		
		autoscroll $mf.scrollb_lb_log_tvviewer
		autoscroll $mf.scrollb_log_tvviewer
		
		wm title $w [mc "TV-Viewer Log"]
		wm protocol $w WM_DELETE_WINDOW "destroy $w; set ::choice(cb_log_tv_main) 0; log_viewerTvTail 0 cancel 0"
		wm iconphoto $w $::icon_e(tv-viewer_icon)
		
		foreach event {<KeyPress> <<PasteSelection>>} {
			bind $mf.t_log_tvviewer $event break
		}
		bind $mf.t_log_tvviewer <Control-c> {event generate %W <<Copy>>}
		
		if {$::option(tooltips) == 1 && $::option(tooltips_main) == 1} {
			settooltip $ftop.b_save [mc "Save logfile to disk"]
			settooltip $ftop.b_email [mc "Send logfile by e-mail to the authors"]
			settooltip $ftop.cb_verb_debug [mc "Show/hide Debug messages"]
			settooltip $ftop.cb_verb_warn [mc "Show/hide Warning messages"]
			settooltip $ftop.cb_verb_err [mc "Show/hide Error messages"]
		}
		
		set ::log(verboseTv_debug) 1
		set ::log(verboseTv_warn) 1
		set ::log(verboseTv_err) 1
		log_writeOutTv 0 "Read existing logfile, insert into log viewer and start monitoring logfile for TV-Viewer."
		after 0 [list log_viewerTvReadFile $mf.t_log_tvviewer $mf.lb_log_tvviewer]
		tkwait visibility .log_viewer_tvviewer
		log_viewerTvLb $mf.lb_log_tvviewer
		wm minsize .log_viewer_tvviewer [winfo reqwidth .log_viewer_tvviewer] [winfo reqheight .log_viewer_tvviewer]
	} else {
		log_writeOutTv 0 "Closing log viewer for TV-Viewer."
		log_viewerTvTail 0 cancel 0; destroy .log_viewer_tvviewer
	}
}

proc log_viewerTvReadFile {logw loglb} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: log_viewerTvReadFile \033\[0m \{$logw\}"
	if {[file exists "$::option(where_is_home)/log/tvviewer.log"]} {
		log_viewerTvTail 0 cancel 0
		$logw delete 0.0 end
		$loglb delete 0 end
		set mlogfile_open [open "$::option(where_is_home)/log/tvviewer.log" r]
		$logw tag configure fat_blue -font "TkTextFont [font actual TkTextFont -displayof $logw -size] bold" -foreground #0030C4
		$logw tag configure fat_red -font "TkTextFont [font actual TkTextFont -displayof $logw -size] bold" -foreground #DF0F0F
		set i 0
		set match_date ""
		while {[gets $mlogfile_open line]!=-1} {
			set match 0
			if {$::log(verboseTv_warn) == 1} {
				if {[string match "*WARNING:*" $line]} {
					set match 1
					$logw insert end $line\n fat_blue
				}
			} else {
				if {[string match "*WARNING:*" $line]} continue
			}
			if {$::log(verboseTv_err) == 1} {
				if {[string match "*ERROR:*" $line]} {
					set match 1
					$logw insert end $line\n fat_red
				}
			} else {
				if {[string match "*ERROR:*" $line]} continue
			}
			if {$::log(verboseTv_debug) == 1} {
				if {[string match "*DEBUG:*" $line]} {
					set match 1
					$logw insert end $line\n
				}
			} else {
				if {[string match "*DEBUG:*" $line]} continue
			}
			if {[string match "# Start new session*" $line]} {
				set match 1
				if {"[lindex $line 4]" == "$match_date"} {
					incr i
					$loglb insert end "Session [lindex $line 4] - $i"
					set match_date [lindex $line 4]
					$logw insert end $line\n
					$logw mark set [string map {{ } {}} "[lindex $line 4] - $i"] [$logw index "end -10 chars"]
				} else {
					$loglb insert end "Session [lindex $line 4] - 1"
					set i 1
					set match_date [lindex $line 4]
					$logw insert end $line\n
					$logw mark set [string map {{ } {}} "[lindex $line 4] - 1"] [$logw index "end -10 chars"]
				}
			}
			if {$match == 0} {
				$logw insert end $line\n
			}
			unset -nocomplain match
		}
		bind $loglb <<ListboxSelect>> [list log_viewerTvLb $loglb]
		$loglb activate end
		$loglb selection set end
		$loglb see end
		seek $mlogfile_open 0 end
		set position [tell $mlogfile_open]
		close $mlogfile_open
		set ::data(log_tv_id) [after 100 "log_viewerTvTail $::option(where_is_home)/log/tvviewer.log $position $logw"]
	}
}

proc log_viewerTvTail {filename position logw} {
	if {"$position" == "cancel"} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: log_viewerTvTail \033\[0;1;31m::cancel:: \033\[0m"
		catch {after cancel $::data(log_tv_id)}
		unset -nocomplain ::data(log_tv_id)
		return
	}
	if {[winfo exists .log_viewer_tvviewer]} {
		$logw tag configure fat_blue -font "TkTextFont [font actual TkTextFont -displayof $logw -size] bold" -foreground #0030C4
		
		$logw tag configure fat_red -font "TkTextFont [font actual TkTextFont -displayof $logw -size] bold" -foreground #DF0F0F
		
		set fh [open $filename r]
		fconfigure $fh -blocking no -buffering line
		seek $fh $position start
		while {[eof $fh] == 0} {
			gets $fh line
			if {[string length $line] > 0} {
				if {$::log(verboseTv_warn) == 1} {
					if {[string match "*WARNING:*" $line]} {
						$logw insert end $line\n fat_blue
						$logw see end
					}
				} else {
					if {$::log(verboseTv_warn) == 1} continue
				}
				if {$::log(verboseTv_err) == 1} {
					if {[string match "*ERROR:*" $line]} {
						$logw insert end $line\n fat_red
						$logw see end
					}
				} else {
					if {[string match "*ERROR:*" $line]} continue
				}
				if {$::log(verboseTv_debug) == 1} {
					if {[string match "*DEBUG:*" $line]} {
						$logw insert end $line\n
						$logw see end
					}
				} else {
					if {$::log(verboseTv_debug) == 1} continue
				}
			}
		}
		set position [tell $fh]
		close $fh
		set ::data(log_tv_id) [after 1000 [list log_viewerTvTail $filename $position $logw]]
	}
}

proc log_viewerTvLb {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: log_viewerTvLb \033\[0m \{$w\}"
	set get_lb_index [$w curselection]
	set get_lb_content [$w get $get_lb_index]
	set marking [string map {{ } {}} [lrange $get_lb_content end-2 end]]
	.log_viewer_tvviewer.f_log_tvviewer.t_log_tvviewer see $marking
}

proc log_writeOutTv {handler text} {
	set logformat "#"
	if {$handler == 0} {
		append logformat " \[[clock format [clock scan now] -format {%H:%M:%S}]\] DEBUG: "
	}
	if {$handler == 1} {
		append logformat " \[[clock format [clock scan now] -format {%H:%M:%S}]\] WARNING: "
	}
	if {$handler == 2} {
		append logformat " \[[clock format [clock scan now] -format {%H:%M:%S}]\] ERROR: "
	}
	puts $::logf_tv_open_append "$logformat $text"
	flush $::logf_tv_open_append
}
