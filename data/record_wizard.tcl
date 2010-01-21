#       record_wizard.tcl
#       © Copyright 2007-2010 Christian Rapp <saedelaere@arcor.de>
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
	#~ if {$::option(systray_close) == 1} {
		#~ wm protocol . WM_DELETE_WINDOW {main_systemTrayTogglePre}
	#~ }
	destroy .record_wizard
}

proc record_wizardExecScheduler {sbutton slable com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_wizardScheduler \033\[0m \{$sbutton\} \{$slable\} \{$com\}"
	if {$com == 0} {
		if {[winfo exists $sbutton]} {
			$sbutton configure -command {}
		}
		set status_schedlinkread [catch {file readlink "$::option(home)/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
		if { $status_schedlinkread == 0 } {
			catch {exec ps -eo "%p"} read_ps
			set status_greppid_sched [catch {agrep -w "$read_ps" $resultat_schedlinkread} resultat_greppid_sched]
			if { $status_greppid_sched == 0 } {
				log_writeOutTv 1 "Scheduler is running, will stop it."
				command_WritePipe 0 "tv-viewer_scheduler scheduler_exit"
			}
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

proc record_wizardUi {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_wizardUi \033\[0m"
	if {[winfo exists .record_wizard] == 0} {
		log_writeOutTv 0 "Starting Record Wizard."
		
		if {[wm attributes .tv -fullscreen] == 1} {
			tv_wmFullscreen .tv .tv.bg.w .tv.bg
		}
		
		set w [toplevel .record_wizard]
		
		place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		
		set topf [ttk::frame $w.top_frame] ; place [ttk::frame $topf.bgcolor -style Toolbutton]  -relwidth 1 -relheight 1
		set treef [ttk::frame $w.tree_frame]
		set statf [ttk::frame $w.status_frame]
		set bf [ttk::frame $w.button_frame -style TLabelframe]
		
		ttk::button $topf.b_add_rec \
		-text [mc "New recording"] \
		-style Toolbutton \
		-command [list record_add_edit $treef.tv_rec 0]
		ttk::button $topf.b_delete_rec \
		-text [mc "Delete"] \
		-style Toolbutton \
		-command [list record_add_editDelete $treef.tv_rec]
		ttk::button $topf.b_edit_rec \
		-text [mc "Edit"] \
		-style Toolbutton \
		-command [list record_add_edit $treef.tv_rec 1]
		ttk::separator $topf.sep_1 \
		-orient vertical
		
		ttk::treeview $treef.tv_rec \
		-yscrollcommand [list $treef.sb_rec_vert set] \
		-columns {jobid station time date duration resolution file} \
		-show headings
		ttk::scrollbar $treef.sb_rec_vert \
		-orient vertical \
		-command [list $treef.tv_rec yview]
		
		ttk::labelframe $statf.lf_status \
		-text [mc "Status"]
		ttk::label $statf.l_rec_sched \
		-text [mc "Scheduler status:"]
		ttk::label $statf.l_rec_sched_info
		ttk::button $statf.b_rec_sched \
		-text [mc "Stop Scheduler"]
		ttk::label $statf.l_rec_current \
		-text [mc "Currently recording:"]
		ttk::label $statf.l_rec_current_info
		ttk::button $statf.b_rec_current \
		-text [mc "Stop recording"] \
		-command [list record_linkerPreStop record]
		
		ttk::button $bf.b_exit \
		-text [mc "Exit"] \
		-compound left \
		-image $::icon_s(dialog-close) \
		-command record_wizardExit
		
		grid columnconfigure $w 0 -weight 1
		grid rowconfigure $w 1 -weight 1
		
		grid columnconfigure $treef {0} -weight 1
		grid rowconfigure $treef {0} -weight 1
		
		grid columnconfigure $statf {0} -weight 1
		
		grid columnconfigure $statf.lf_status {2} -minsize 120
		
		grid $topf -in $w -row 0 -column 0 \
		-sticky new
		grid $treef -in $w -row 1 -column 0 \
		-sticky nesw
		grid $statf -in $w -row 2 -column 0 \
		-sticky ew
		grid $bf -in $w -row 3 -column 0 \
		-sticky sew \
		-padx 3 \
		-pady 3
		
		grid $topf.b_add_rec -in $topf -row 0 -column 0 \
		-padx 3 \
		-pady 4
		grid $topf.b_delete_rec -in $topf -row 0 -column 1 \
		-padx "0 3" \
		-pady 4
		grid $topf.b_edit_rec -in $topf -row 0 -column 2 \
		-padx "0 3" \
		-pady 4
		grid $topf.sep_1 -in $topf -row 0 -column 3 \
		-sticky ns
		
		grid $treef.tv_rec -in $treef -row 0 -column 0 \
		-sticky nesw
		grid $treef.sb_rec_vert -in $treef -row 0 -column 1 \
		-sticky ns
		
		grid $statf.lf_status -in $statf -row 0 -column 0 \
		-sticky ew \
		-padx 15 \
		-pady 10
		grid $statf.l_rec_sched -in $statf.lf_status -row 0 -column 0 \
		-sticky w \
		-padx 7 \
		-pady 4
		grid $statf.l_rec_sched_info -in $statf.lf_status -row 0 -column 1 \
		-sticky w \
		-padx "0 7" \
		-pady 4
		grid $statf.b_rec_sched -in $statf.lf_status -row 0 -column 2 \
		-sticky ew \
		-padx "0 7" \
		-pady 4
		grid $statf.l_rec_current -in $statf.lf_status -row 1 -column 0 \
		-sticky w \
		-padx 7 \
		-pady "0 4"
		grid $statf.l_rec_current_info -in $statf.lf_status -row 1 -column 1 \
		-sticky w \
		-padx "0 7" \
		-pady "0 4"
		grid $statf.b_rec_current -in $statf.lf_status -row 1 -column 2 \
		-sticky ew \
		-padx "0 7" \
		-pady "0 4"
		
		grid $bf.b_exit -in $bf -row 0 -column 0 \
		-pady 7 \
		-padx 3
		grid anchor $bf e
		
		wm title $w [mc "Record Wizard"]
		wm protocol $w WM_DELETE_WINDOW record_wizardExit
		wm iconphoto $w $::icon_b(record)
		
		autoscroll $treef.sb_rec_vert
		
		set font [ttk::style lookup [$treef.tv_rec cget -style] -font]
		if {[string trim $font] == {}} {
			set font TkDefaultFont
			puts $::main(debug_msg) "\033\[0;1;33mDebug: record_wizardUi \033\[0;1;31m::font:: \033\[0m"
		}
		$treef.tv_rec heading jobid -text [mc "Job ID"]
		$treef.tv_rec column jobid -anchor center -width [expr [font measure $font [mc "Job ID"]] + 15]
		$treef.tv_rec heading station -text [mc "Station"]
		$treef.tv_rec column station -anchor center -width [expr [font measure $font [mc "Station"]] + 80]
		$treef.tv_rec heading time -text [mc "Time"]
		$treef.tv_rec column time -anchor center -width [expr [font measure $font [mc "Time"]] + 40]
		$treef.tv_rec heading date -text [mc "Date"]
		$treef.tv_rec column date -anchor center -width [expr [font measure $font [mc "Date"]] + 55]
		$treef.tv_rec heading duration -text [mc "Duration"]
		$treef.tv_rec column duration -anchor center -width [expr [font measure $font [mc "Duration"]] + 25]
		$treef.tv_rec heading resolution -text [mc "Resolution"]
		$treef.tv_rec column resolution -anchor center -width [expr [font measure $font [mc "Resolution"]] + 15]
		$treef.tv_rec heading file -text [mc "Output file"]
		$treef.tv_rec column file -anchor center -width [expr [font measure $font [mc "Output file"]] + 330]
		
		bind $treef.tv_rec <B1-Motion> break
		bind $treef.tv_rec <Motion> break
		bind $treef.tv_rec <Double-ButtonPress-1> [list record_add_edit $treef.tv_rec 1]
		bind $w <Control-Key-x> {record_wizardExit}
		bind $w <Key-F1> [list info_helpHelp]
		
		set status_recordlinkread [catch {file readlink "$::option(home)/tmp/record_lockfile.tmp"} resultat_recordlinkread]
		if { $status_recordlinkread == 0 } {
			catch {exec ps -eo "%p"} read_ps
			set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
			if { $status_greppid_record == 0 } {
				if {[file exists "$::option(home)/config/current_rec.conf"]} {
					set f_open [open "$::option(home)/config/current_rec.conf" r]
					while {[gets $f_open line]!=-1} {
						if {[string trim $line] == {}} continue
						lassign $line station sdate stime edate etime duration recfile
						$statf.l_rec_current_info configure -text [mc "% -- ends % at %" $station $edate $etime]
						$statf.b_rec_current state !disabled
						log_writeOutTv 0 "Found an active recording (PID $resultat_recordlinkread)."
					}
					close $f_open
				} else {
					log_writeOutTv 2 "Although there is an active recording, no current_rec.conf in config path."
				}
			} else {
				log_writeOutTv 0 "No active recording."
				$statf.l_rec_current_info configure -text "Idle"
				$statf.b_rec_current state disabled
			}
		} else {
			log_writeOutTv 0 "No active recording."
			$statf.l_rec_current_info configure -text "Idle"
			$statf.b_rec_current state disabled
		}
		catch {exec ""}
		set status_schedlinkread [catch {file readlink "$::option(home)/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
		if { $status_schedlinkread == 0 } {
			catch {exec ps -eo "%p"} read_ps
			set status_greppid_sched [catch {agrep -w "$read_ps" $resultat_schedlinkread} resultat_greppid_sched]
			if { $status_greppid_sched == 0 } {
				log_writeOutTv 0 "Scheduler is running (PID $resultat_schedlinkread)."
				record_wizardExecSchedulerCback 0
			} else {
				log_writeOutTv 0 "Scheduler is not running."
				record_wizardExecSchedulerCback 1
			}
		} else {
			log_writeOutTv 0 "Scheduler is not running."
			record_wizardExecSchedulerCback 1
		}
		if {[file exists "$::option(home)/config/scheduled_recordings.conf"]} {
			set f_open [open "$::option(home)/config/scheduled_recordings.conf" r]
			while {[gets $f_open line]!=-1} {
				if {[string trim $line] == {} || [string match #* $line]} continue
				$treef.tv_rec insert {} end -values [list [lindex $line 0] [lindex $line 1] [lindex $line 2] [lindex $line 3] [lindex $line 4] [lindex $line 5] [lindex $line 6]]
			}
		}
		if {$::option(tooltips) == 1} {
			if {$::option(tooltips_record) == 1} {
				settooltip $topf.b_add_rec [mc "Add a scheduled recording or
start recording immediately."]
				settooltip $topf.b_delete_rec [mc "Delete selected recordings."]
				settooltip $topf.b_edit_rec [mc "Edit selected recording."]
				settooltip $statf.l_rec_sched [mc "Indicates whether the Scheduler
is running or not."]
				settooltip $statf.l_rec_sched_info [mc "Indicates whether the Scheduler
is running or not."]
				settooltip $statf.l_rec_current [mc "Provides informations about the
current recording."]
				settooltip $statf.l_rec_current_info [mc "Provides informations about the
current recording."]
				settooltip $statf.b_rec_current [mc "If there is a running recording,
click here to stop it."]
				settooltip $bf.b_exit [mc "Exit Record Wizard"]
			}
		}
		tkwait visibility $w
		wm minsize .record_wizard [winfo reqwidth .record_wizard] [winfo reqheight .record_wizard]
	}
}
