#       record_wizard.tcl
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

proc record_wizardExit {} {
	if {$::option(systray_mini) == 1} {
		bind . <Unmap> {
			if {[winfo ismapped .] == 0} {
				if {[winfo exists .tray] == 0} {
					main_systemTrayActivate
					set ::choice(cb_systray_main) 1
				}
				main_systemTrayMini unmap
			}
		}
	}
	destroy .record_wizard
}

proc record_wizardScheduler {sbutton slable com} {
	if {$com == 0} {
		$sbutton configure -command {}
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Stopping Scheduler..."
		flush $::logf_tv_open_append
		catch {exec ""}
		set status_schedlinkread [catch {file readlink "$::where_is_home/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
		if { $status_schedlinkread == 0 } {
			catch {exec ps -eo "%p"} read_ps
			set status_greppid_sched [catch {agrep -w "$read_ps" $resultat_schedlinkread} resultat_greppid_sched]
			if { $status_greppid_sched == 0 } {
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Scheduler is running, will stop it."
				flush $::logf_tv_open_append
				puts $::data(comsocket) "tv-viewer_scheduler scheduler_exit"
				flush $::data(comsocket)
			}
		}
		after 2000 {
			catch {
				catch {exec ""}
				set status_schedlinkread [catch {file readlink "$::where_is_home/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
				if { $status_schedlinkread == 0 } {
				catch {exec ps -eo "%p"} read_ps
					set status_greppid_sched [catch {agrep -w "$read_ps" $resultat_schedlinkread} resultat_greppid_sched]
					if { $status_greppid_sched == 0 } {
						.record_wizard.status_frame.l_rec_sched_info configure -text [mc "Running"]
						.record_wizard.status_frame.b_rec_sched configure -text [mc "Stop Scheduler"] -command [list record_wizardScheduler .record_wizard.status_frame.b_rec_sched .record_wizard.status_frame.l_rec_sched_info 0]
					} else {
						.record_wizard.status_frame.l_rec_sched_info configure -text [mc "Stopped"]
						.record_wizard.status_frame.b_rec_sched configure -text [mc "Start Scheduler"] -command [list record_wizardScheduler .record_wizard.status_frame.b_rec_sched .record_wizard.status_frame.l_rec_sched_info 1]
					}
				} else {
					.record_wizard.status_frame.l_rec_sched_info configure -text [mc "Stopped"]
					.record_wizard.status_frame.b_rec_sched configure -text [mc "Start Scheduler"] -command [list record_wizardScheduler .record_wizard.status_frame.b_rec_sched .record_wizard.status_frame.l_rec_sched_info 1]
				}
			}
		}
	}
	if {$com == 1} {
		$sbutton configure -command {}
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Starting Scheduler..."
		flush $::logf_tv_open_append
		catch {exec "$::where_is/data/record_scheduler.tcl" &}
		after 2000 {
			catch {
				catch {exec ""}
				set status_schedlinkread [catch {file readlink "$::where_is_home/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
				if { $status_schedlinkread == 0 } {
					catch {exec ps -eo "%p"} read_ps
					set status_greppid_sched [catch {agrep -w "$read_ps" $resultat_schedlinkread} resultat_greppid_sched]
					if { $status_greppid_sched == 0 } {
						.record_wizard.status_frame.l_rec_sched_info configure -text [mc "Running"]
						.record_wizard.status_frame.b_rec_sched configure -text [mc "Stop Scheduler"] -command [list record_wizardScheduler .record_wizard.status_frame.b_rec_sched .record_wizard.status_frame.l_rec_sched_info 0]
					} else {
						.record_wizard.status_frame.l_rec_sched_info configure -text [mc "Stopped"]
						.record_wizard.status_frame.b_rec_sched configure -text [mc "Start Scheduler"] -command [list record_wizardScheduler .record_wizard.status_frame.b_rec_sched .record_wizard.status_frame.l_rec_sched_info 1]
					}
				} else {
					.record_wizard.status_frame.l_rec_sched_info configure -text [mc "Stopped"]
					.record_wizard.status_frame.b_rec_sched configure -text [mc "Start Scheduler"] -command [list record_wizardScheduler .record_wizard.status_frame.b_rec_sched .record_wizard.status_frame.l_rec_sched_info 1]
				}
			}
		}
	}
}

proc record_wizardUi {} {
	if {[winfo exists .record_wizard] == 0} {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Starting Record Wizard."
		flush $::logf_tv_open_append
		
		if {[wm attributes .tv -fullscreen] == 1} {
			tv_playerFullscreen .tv .tv.bg.w .tv.bg
		}
		
		set w [toplevel .record_wizard]
		
		place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		
		set topf [ttk::frame $w.top_frame]
		set treef [ttk::frame $w.tree_frame]
		set statf [ttk::frame $w.status_frame]
		set bf [ttk::frame $w.button_frame -relief groove -borderwidth 2]
		
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
		-command [list record_schedulerPreStop record]
		
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
		
		if {$::option(systray_mini) == 1} {
			bind . <Unmap> {}
		}
		set status_recordlinkread [catch {file readlink "$::where_is_home/tmp/record_lockfile.tmp"} resultat_recordlinkread]
		if { $status_recordlinkread == 0 } {
			catch {exec ps -eo "%p"} read_ps
			set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
			if { $status_greppid_record == 0 } {
				if {[file exists "$::where_is_home/config/current_rec.conf"]} {
					set f_open [open "$::where_is_home/config/current_rec.conf" r]
					while {[gets $f_open line]!=-1} {
						if {[string trim $line] == {}} continue
						lassign $line station sdate stime edate etime duration recfile
						$statf.l_rec_current_info configure -text [mc "% -- ends % at %" $station $edate $etime]
						$statf.b_rec_current state !disabled
						puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Found an active recording (PID $resultat_recordlinkread)."
						flush $::logf_tv_open_append
					}
					close $f_open
				} else {
					puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Although there is an active recording, no current_rec.conf in config path."
					flush $::logf_tv_open_append
				}
			} else {
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] No active recording."
				flush $::logf_tv_open_append
				$statf.l_rec_current_info configure -text "Idle"
				$statf.b_rec_current state disabled
			}
		} else {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] No active recording."
			flush $::logf_tv_open_append
			$statf.l_rec_current_info configure -text "Idle"
			$statf.b_rec_current state disabled
		}
		catch {exec ""}
		set status_schedlinkread [catch {file readlink "$::where_is_home/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
		if { $status_schedlinkread == 0 } {
			catch {exec ps -eo "%p"} read_ps
			set status_greppid_sched [catch {agrep -w "$read_ps" $resultat_schedlinkread} resultat_greppid_sched]
			if { $status_greppid_sched == 0 } {
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Scheduler is running (PID $resultat_schedlinkread)."
				flush $::logf_tv_open_append
				$statf.l_rec_sched_info configure -text [mc "Running"]
				$statf.b_rec_sched configure -text [mc "Stop Scheduler"] -command [list record_wizardScheduler $statf.b_rec_sched $statf.l_rec_sched_info 0]
			} else {
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Scheduler is not running."
				flush $::logf_tv_open_append
				$statf.l_rec_sched_info configure -text [mc "Stopped"]
				$statf.b_rec_sched configure -text [mc "Start Scheduler"] -command [list record_wizardScheduler $statf.b_rec_sched $statf.l_rec_sched_info 1]
			}
		} else {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Scheduler is not running."
			flush $::logf_tv_open_append
			$statf.l_rec_sched_info configure -text [mc "Stopped"]
			$statf.b_rec_sched configure -text [mc "Start Scheduler"] -command [list record_wizardScheduler $statf.b_rec_sched $statf.l_rec_sched_info 1]
		}
		if {[file exists "$::where_is_home/config/scheduled_recordings.conf"]} {
			set f_open [open "$::where_is_home/config/scheduled_recordings.conf" r]
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
