#       record_wizard.tcl
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

proc record_wizardExit {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_wizardExit \033\[0m"
	unset -nocomplain ::record(bbox)
	destroy .record_wizard
}

proc record_wizardExecScheduler {sbutton slable com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_wizardScheduler \033\[0m \{$sbutton\} \{$slable\} \{$com\}"
	if {$com == 0} {
		if {[winfo exists $sbutton]} {
			$sbutton configure -command {}
		}
		set status [monitor_partRunning 2]
		if {[lindex $status 0] == 1} {
			log_writeOutTv 1 "Scheduler is running, will stop it."
			command_WritePipe 0 "tv-viewer_scheduler scheduler_exit"
		}
		after 2000 {catch {exec ""}}
	}
	if {$com == 1} {
		if {[winfo exists $sbutton]} {
			$sbutton configure -command {}
		}
		log_writeOutTv 0 "Starting Scheduler..."
		catch {exec ""}
		catch {exec "$::option(root)/data/scheduler.tcl" &}
	}
}

proc record_wizardExecSchedulerCback {com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_wizardExecSchedulerCback \033\[0m \{$com\}"
	
	if {$com == 0} {
		if {[winfo exists .record_wizard]} {
			.record_wizard.status_frame.l_rec_sched_info configure -text [mc "Running"]
			.record_wizard.status_frame.b_rec_sched configure -text [mc "Stop Scheduler"] -command [list record_wizardExecScheduler .record_wizard.status_frame.b_rec_sched .record_wizard.status_frame.l_rec_sched_info 0]
		}
	}
	if {$com == 1} {
		if {[winfo exists .record_wizard]} {
			.record_wizard.status_frame.l_rec_sched_info configure -text [mc "Stopped"]
			.record_wizard.status_frame.b_rec_sched configure -text [mc "Start Scheduler"] -command [list record_wizardExecScheduler .record_wizard.status_frame.b_rec_sched .record_wizard.status_frame.l_rec_sched_info 1]
		}
	}
}

proc record_wizardUiMenu {tree x y} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_wizardUiMenu \033\[0m \{$tree\} \{$x\} \{$y\}"
	if {[winfo exists $tree.mCont] == 0} {
		menu $tree.mCont -tearoff 0
		$tree.mCont add command -label [mc "New recording"] -command [list record_add_edit $tree 0] -image $::icon_men(item-add) -compound left
		$tree.mCont add command -label [mc "Delete"] -command [list record_add_editDelete $tree] -image $::icon_men(item-remove) -compound left
		$tree.mCont add command -label [mc "Edit"] -command [list record_add_edit $tree 1] -image $::icon_men(seditor) -compound left
	}
	log_writeOutTv 0 "Pop up context for record wizard"
	if {[string trim [$tree selection]] == {}} {
		$tree.mCont entryconfigure 1 -state disabled
		$tree.mCont entryconfigure 2 -state disabled
	} else {
		$tree.mCont entryconfigure 1 -state normal
		$tree.mCont entryconfigure 2 -state normal
	}
	tk_popup $tree.mCont $x $y
}

proc record_wizardUi {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_wizardUi \033\[0m"
	if {[winfo exists .record_wizard] == 0} {
		log_writeOutTv 0 "Starting Record Wizard."
		
		if {[wm attributes . -fullscreen] == 1} {
			event generate . <<wmFull>>
		}
		
		set w [toplevel .record_wizard]
		
		place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		
		set topf [ttk::frame $w.top_frame] ; place [ttk::frame $topf.bgcolor -style Toolbutton]  -relwidth 1 -relheight 1
		set treef [ttk::frame $w.tree_frame]
		set statf [ttk::frame $w.status_frame]
		set bf [ttk::frame $w.button_frame -style TLabelframe]
		
		ttk::button $topf.b_add_rec -text [mc "New recording"] -style Toolbutton -command [list record_add_edit $treef.cv.f.tv_rec 0] -image $::icon_m(item-add) -compound top
		ttk::button $topf.b_delete_rec -text [mc "Delete"] -style Toolbutton -command [list record_add_editDelete $treef.cv.f.tv_rec] -image $::icon_m(item-remove) -compound top
		ttk::button $topf.b_edit_rec -text [mc "Edit"] -style Toolbutton -command [list record_add_edit $treef.cv.f.tv_rec 1] -image $::icon_m(seditor) -compound top
		ttk::separator $topf.sep_1 -orient vertical
		
		canvas $treef.cv -xscrollcommand [list $treef.sb_rec_hori set] -highlightthickness 0
		$treef.cv create window 0 0 -window [ttk::frame $treef.cv.f] -anchor w -tags cont_record
		ttk::treeview $treef.cv.f.tv_rec -yscrollcommand [list $treef.sb_rec_vert set] -columns {jobid station time date duration repeat reps resolution file} -show headings
		ttk::scrollbar $treef.sb_rec_vert -orient vertical -command [list $treef.cv.f.tv_rec yview]
		ttk::scrollbar $treef.sb_rec_hori -orient horizontal -command [list $treef.cv xview]
		ttk::label $treef.l_repeat -text [mc "Repeat: 0 - Never; 1 - Daily; 2 - Weekday; 3 - Weekly"]
		
		ttk::labelframe $statf.lf_status -text [mc "Status"]
		ttk::label $statf.l_rec_sched -text [mc "Scheduler status:"]
		ttk::label $statf.l_rec_sched_info
		ttk::button $statf.b_rec_sched -text [mc "Stop Scheduler"]
		ttk::label $statf.l_rec_current -text [mc "Currently recording:"]
		ttk::label $statf.l_rec_current_info
		ttk::button $statf.b_rec_current -text [mc "Stop recording"] -command [list record_linkerPreStop record]
		
		ttk::button $bf.b_exit -text [mc "Exit"] -compound left -image $::icon_s(dialog-close) -command record_wizardExit
		
		grid columnconfigure $w 0 -weight 1
		grid rowconfigure $w 1 -weight 1
		
		grid columnconfigure $treef {0} -weight 1
		grid rowconfigure $treef {0} -weight 1
		grid columnconfigure $treef.cv.f 0 -weight 1
		grid rowconfigure $treef.cv.f 0 -weight 1
		
		grid columnconfigure $statf {0} -weight 1
		
		grid columnconfigure $statf.lf_status {2} -minsize 120
		
		grid $topf -in $w -row 0 -column 0 -sticky new
		grid $treef -in $w -row 1 -column 0 -sticky nesw
		grid $statf -in $w -row 2 -column 0 -sticky ew
		grid $bf -in $w -row 3 -column 0 -sticky sew -padx 3 -pady 3
		
		grid $topf.b_add_rec -in $topf -row 0 -column 0 -padx 3 -pady 4
		grid $topf.b_delete_rec -in $topf -row 0 -column 1 -padx "0 3" -pady 4
		grid $topf.b_edit_rec -in $topf -row 0 -column 2 -padx "0 3" -pady 4
		grid $topf.sep_1 -in $topf -row 0 -column 3 -sticky ns
		
		grid $treef.cv -in $treef -row 0 -column 0 -sticky nesw
		grid $treef.cv.f.tv_rec -in $treef.cv.f -row 0 -column 0 -sticky nesw
		grid $treef.sb_rec_vert -in $treef -row 0 -column 1 -sticky ns
		grid $treef.sb_rec_hori -in $treef -row 1 -column 0 -sticky ew
		grid $treef.l_repeat -in $treef -row 2 -column 0 -sticky w -padx 10 -pady 2
		
		grid $statf.lf_status -in $statf -row 0 -column 0 -sticky ew -padx 15 -pady 10
		grid $statf.l_rec_sched -in $statf.lf_status -row 0 -column 0 -sticky w -padx 7 -pady 4
		grid $statf.l_rec_sched_info -in $statf.lf_status -row 0 -column 1 -sticky w -padx "0 7" -pady 4
		grid $statf.b_rec_sched -in $statf.lf_status -row 0 -column 2 -sticky ew -padx "0 7" -pady 4
		grid $statf.l_rec_current -in $statf.lf_status -row 1 -column 0 -sticky w -padx 7 -pady "0 4"
		grid $statf.l_rec_current_info -in $statf.lf_status -row 1 -column 1 -sticky w -padx "0 7" -pady "0 4"
		grid $statf.b_rec_current -in $statf.lf_status -row 1 -column 2 -sticky ew -padx "0 7" -pady "0 4"
		
		grid $bf.b_exit -in $bf -row 0 -column 0 -pady 7 -padx 3
		grid anchor $bf e
		
		wm title $w [mc "Record Wizard"]
		wm protocol $w WM_DELETE_WINDOW record_wizardExit
		wm iconphoto $w $::icon_b(record)
		
		autoscroll $treef.sb_rec_vert
		autoscroll $treef.sb_rec_hori; #FIXME autoscroll does not work here atm
		
		set font [ttk::style lookup [$treef.cv.f.tv_rec cget -style] -font]
		if {[string trim $font] == {}} {
			set font TkDefaultFont
			puts $::main(debug_msg) "\033\[0;1;33mDebug: record_wizardUi \033\[0;1;31m::font:: \033\[0m"
		}
		$treef.cv.f.tv_rec heading jobid -text [mc "Job ID"]
		$treef.cv.f.tv_rec column jobid -anchor center -stretch 0 -width [expr [font measure $font [mc "Job ID"]] + 15]
		set widthItemConfigure [expr [font measure $font [mc "Job ID"]] + 15]
		$treef.cv.f.tv_rec heading station -text [mc "Station"]
		$treef.cv.f.tv_rec column station -anchor center -stretch 0 -width [expr [font measure $font [mc "Station"]] + 80]
		set widthItemConfigure [expr $widthItemConfigure + ([font measure $font [mc "Station"]] + 80)]
		$treef.cv.f.tv_rec heading time -text [mc "Time"]
		$treef.cv.f.tv_rec column time -anchor center -stretch 0 -width [expr [font measure $font [mc "Time"]] + 55]
		set widthItemConfigure [expr $widthItemConfigure + ([font measure $font [mc "Time"]] + 55)]
		$treef.cv.f.tv_rec heading date -text [mc "Date"]
		$treef.cv.f.tv_rec column date -anchor center -stretch 0 -width [expr [font measure $font [mc "Date"]] + 60]
		set widthItemConfigure [expr $widthItemConfigure + ([font measure $font [mc "Date"]] + 60)]
		$treef.cv.f.tv_rec heading duration -text [mc "Duration"]
		$treef.cv.f.tv_rec column duration -anchor center -stretch 0 -width [expr [font measure $font [mc "Duration"]] + 25]
		set widthItemConfigure [expr $widthItemConfigure + ([font measure $font [mc "Duration"]] + 25)]
		$treef.cv.f.tv_rec heading repeat -text [mc "Repeat"]
		$treef.cv.f.tv_rec column repeat -anchor center -stretch 0 -width [expr [font measure $font [mc "Repeat"]] + 25]
		set widthItemConfigure [expr $widthItemConfigure + ([font measure $font [mc "Repeat"]] + 25)]
		$treef.cv.f.tv_rec heading reps -text [mc "Repetitions"]
		$treef.cv.f.tv_rec column reps -anchor center -stretch 0 -width [expr [font measure $font [mc "Repetitions"]] + 25]
		set widthItemConfigure [expr $widthItemConfigure + ([font measure $font [mc "Repetitions"]] + 25)]
		$treef.cv.f.tv_rec heading resolution -text [mc "Resolution"]
		$treef.cv.f.tv_rec column resolution -anchor center -stretch 0 -width [expr [font measure $font [mc "Resolution"]] + 20]
		set widthItemConfigure [expr $widthItemConfigure + ([font measure $font [mc "Resolution"]] + 20)]
		$treef.cv.f.tv_rec heading file -text [mc "Output file"]
		$treef.cv.f.tv_rec column file -anchor center -stretch 1 -minwidth [expr [font measure $font [mc "Output file"]] + 330]
		set widthItemConfigure [expr $widthItemConfigure + ([font measure $font [mc "Output file"]] + 330)]
		
		$treef.cv itemconfigure cont_record -width [expr $widthItemConfigure + 5]
		bind $treef.cv <Map> {
			%W itemconfigure cont_record -height [winfo height %W]
			set ::record(bbox) [%W bbox all]
			%W configure -scrollregion $::record(bbox)
			%W xview moveto 0
		}
		bind $treef.cv <Configure> {
			if {[info exists ::record(bbox)]} {
				if {[winfo width %W] >= [lindex $::record(bbox) 2]} {
					%W itemconfigure cont_record -width [winfo width %W]
				}
				if {[winfo height %W] >= [lindex $::record(bbox) 3]} {
					%W itemconfigure cont_record -height [winfo height %W]
					set scrollregion [lreplace [%W bbox all] 0 0 [lindex $::record(bbox) 0]]
					set scrollregion [lreplace $scrollregion 2 2 [lindex $::record(bbox) 2]]
					%W configure -scrollregion $scrollregion
				}
				if {[lindex [%W bbox all] 2] >= [expr [winfo screenwidth .] -100] && [winfo height .record_wizard] <= [expr [winfo screenheight .] -100] && [winfo width %W] < [lindex $::record(bbox) 2]} {
					%W itemconfigure cont_record -width [lindex $::record(bbox) 2]
				}
			}
		}
		bind $treef.cv.f.tv_rec <B1-Motion> break
		bind $treef.cv.f.tv_rec <Motion> break
		bind $treef.cv.f.tv_rec <Double-ButtonPress-1> [list record_add_edit $treef.cv.f.tv_rec 1]
		bind $treef.cv.f.tv_rec <Key-Delete> [list record_add_editDelete $treef.cv.f.tv_rec]
		bind $treef.cv.f.tv_rec <ButtonPress-3> [list record_wizardUiMenu $treef.cv.f.tv_rec %X %Y]
		bind $w <Key-x> {puts [winfo width .record_wizard]}
		bind $w <Key-y> {puts [winfo height .record_wizard]}
		bind $w <Control-Key-x> {record_wizardExit}
		bind $w <<help>> [list info_helpHelp]
		
		$treef.l_repeat configure -font "TkDefaultFont [font actual TkDefaultFont -displayof $treef.l_repeat -size] italic"
		
		set status_record [monitor_partRunning 3]
		if {[lindex $status_record 0] == 1} {
			if {[file exists "$::option(home)/config/current_rec.conf"]} {
				set f_open [open "$::option(home)/config/current_rec.conf" r]
				while {[gets $f_open line]!=-1} {
					if {[string trim $line] == {}} continue
					lassign $line station sdate stime edate etime duration recfile
					$statf.l_rec_current_info configure -text [mc "% -- ends % at %" $station $edate $etime]
					$statf.b_rec_current state !disabled
					log_writeOutTv 0 "Found an active recording (PID [lindex $status_record 1])."
				}
				close $f_open
			} else {
				log_writeOutTv 2 "Although there is an active recording, no current_rec.conf in config path."
				log_writeOutTv 2 "You may want to report this incident."
				if {$::option(log_warnDialogue)} {
					status_feedbWarn 1 [mc "Missing file ../.tv-viewer/config/current_rec.conf"]
				}
			}
		} else {
			log_writeOutTv 0 "No active recording."
			$statf.l_rec_current_info configure -text "Idle"
			$statf.b_rec_current state disabled
		}
		catch {exec ""}
		set status [monitor_partRunning 2]
		if {[lindex $status 0] == 1} {
			log_writeOutTv 0 "Scheduler is running (PID [lindex $status 1])."
			record_wizardExecSchedulerCback 0
		} else {
			log_writeOutTv 0 "Scheduler is not running."
			record_wizardExecSchedulerCback 1
		}
		if {[file exists "$::option(home)/config/scheduled_recordings.conf"]} {
			set f_open [open "$::option(home)/config/scheduled_recordings.conf" r]
			while {[gets $f_open line]!=-1} {
				if {[string trim $line] == {} || [string match #* $line]} continue
				$treef.cv.f.tv_rec insert {} end -values [list [lindex $line 0] [lindex $line 1] [lindex $line 2] [lindex $line 3] [lindex $line 4] [lindex $line 5] [lindex $line 6] [lindex $line 7] [lindex $line 8]]
			}
		}
		if {$::option(tooltips) == 1} {
			if {$::option(tooltips_record) == 1} {
				settooltip $topf.b_add_rec [mc "Add a scheduled recording or
start recording immediately."]
				settooltip $topf.b_delete_rec [mc "Delete selected recordings"]
				settooltip $topf.b_edit_rec [mc "Edit selected recording"]
				settooltip $statf.l_rec_sched [mc "Indicates whether the Scheduler is running or not"]
				settooltip $statf.l_rec_sched_info [mc "Indicates whether the Scheduler is running or not"]
				settooltip $statf.l_rec_current [mc "Provides informations about the current recording"]
				settooltip $statf.l_rec_current_info [mc "Provides informations about the current recording"]
				settooltip $statf.b_rec_current [mc "If there is a running recording, click here to stop it"]
				settooltip $bf.b_exit [mc "Exit Record Wizard"]
			}
		}
		tkwait visibility $w
		wm minsize .record_wizard [expr [winfo reqwidth .record_wizard] + 350] [winfo reqheight .record_wizard]
	} else {
		raise .record_wizard
	}
}
