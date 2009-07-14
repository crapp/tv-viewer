#       config_record.tcl
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

proc option_screen_7 {} {
	
	# Setting up the interface
	
	foreach tab [split [.config_wizard.frame_configoptions.nb tabs]] {
		.config_wizard.frame_configoptions.nb hide $tab
	}
	
	if {[winfo exists .config_wizard.frame_configoptions.nb.f_rec]} {
		.config_wizard.frame_configoptions.nb add $::window(rec_nb1)
		.config_wizard.frame_configoptions.nb add $::window(rec_nb2)
		.config_wizard.frame_configoptions.nb select $::window(rec_nb1)
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt7 $::window(rec_nb1) $::window(rec_nb2)]
	} else {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting up record section in preferences."
		flush $::logf_tv_open_append
		set w .config_wizard.frame_configoptions.nb
		set ::window(rec_nb1) [ttk::frame $w.f_rec]
		$w add $::window(rec_nb1) -text [mc "Record Settings"] -padding 2
		ttk::labelframe $::window(rec_nb1).labelframe_rec \
		-text [mc "Standard folder"]
		ttk::entry $::window(rec_nb1).entry_rec \
		-textvariable choice(entry_rec_path)
		ttk::button $::window(rec_nb1).button_rec_path \
		-text ... \
		-width 3 \
		-command config_recordGetRecDir
		ttk::labelframe $::window(rec_nb1).labelframe_rec_dur \
		-text [mc "Default record duration"]
		proc config_recordDurHourValidate {value widget} {
			if {[string is integer $value] != 1 || [string length $value] > 2} {
				return 0
			} else {
				return 1
			}
		}
		proc config_recordDurMinValidate {value widget} {
			if {[string is integer $value] != 1 || [string length $value] > 2} {
				return 0
			} else {
				return 1
			}
		}
		proc config_recordDurSecValidate {value widget} {
			if {[string is integer $value] != 1 || [string length $value] > 2} {
				return 0
			} else {
				return 1
			}
		}
		
		spinbox $::window(rec_nb1).sb_lf_duration_hour \
		-from -1 \
		-to 99 \
		-width 3 \
		-validate key \
		-vcmd {config_recordDurHourValidate %P %W} \
		-repeatinterval 25 \
		-command config_recordDurHour \
		-textvariable choice(sb_duration_hour)
		spinbox $::window(rec_nb1).sb_lf_duration_min \
		-from -1 \
		-to 60 \
		-width 3 \
		-validate key \
		-vcmd {config_recordDurMinValidate %P %W} \
		-repeatinterval 25 \
		-command config_recordDurMin \
		-textvariable choice(sb_duration_min)
		spinbox $::window(rec_nb1).sb_lf_duration_sec \
		-from -1 \
		-to 60 \
		-width 3 \
		-validate key \
		-vcmd {config_recordDurSecValidate %P %W} \
		-repeatinterval 25 \
		-command config_recordDurSec \
		-textvariable choice(sb_duration_sec)
		ttk::labelframe $::window(rec_nb1).lf_rec_station_change \
		-text [mc "Allow station change while recording"]
		ttk::checkbutton $::window(rec_nb1).b_lf_allow_rec \
		-text [mc "Enable"] \
		-variable choice(cb_allow_schange_rec)
		ttk::labelframe $::window(rec_nb1).lf_scheduler_autostart \
		-text [mc "Autostart scheduler"]
		ttk::checkbutton $::window(rec_nb1).cb_lf_scheduler_autostart \
		-text [mc "Enable"] \
		-variable choice(cb_sched_auto) \
		-command config_recordScheduler
		
		
		set ::window(rec_nb2) [ttk::frame $w.f_times]
		$w add $::window(rec_nb2) -text [mc "Timeshift"] -padding 2
		ttk::labelframe $::window(rec_nb2).lf_times_stnd \
		-text [mc "Timeshift folder"]
		ttk::entry $::window(rec_nb2).e_lf_times_stnd \
		-textvariable choice(ent_times_folder)
		ttk::button $::window(rec_nb2).b_lf_times_stnd \
		-text "..." \
		-width 3 \
		-command config_recordTimesDir
		ttk::labelframe $::window(rec_nb2).lf_times_df \
		-text [mc "Space to be left free"]
		ttk::entry $::window(rec_nb2).e_lf_times_df \
		-textvariable choice(ent_times_df) \
		-validate key \
		-validatecommand {string is integer %P}
		ttk::label $::window(rec_nb2).l_lf_times_df \
		-text "MB"
		
		
		grid columnconfigure $::window(rec_nb1) 0 -weight 1
		grid columnconfigure $::window(rec_nb1).labelframe_rec 0 -weight 1
		grid columnconfigure $::window(rec_nb2) 0 -weight 1
		grid columnconfigure $::window(rec_nb2).lf_times_stnd 0 -weight 1
		
		grid $::window(rec_nb1).labelframe_rec -in $::window(rec_nb1) -row 0 -column 0 \
		-padx 5 \
		-pady "5 0" \
		-sticky ew
		grid $::window(rec_nb1).entry_rec -in $::window(rec_nb1).labelframe_rec -row 0 -column 0 \
		-sticky ew \
		-padx 7 \
		-pady 3
		grid $::window(rec_nb1).button_rec_path -in $::window(rec_nb1).labelframe_rec -row 0 -column 1 \
		-pady 3
		
		grid $::window(rec_nb1).labelframe_rec_dur -in $::window(rec_nb1) -row 1 -column 0 \
		-padx 5 \
		-pady "5 0" \
		-sticky ew
		grid $::window(rec_nb1).sb_lf_duration_hour -in $::window(rec_nb1).labelframe_rec_dur -row 0 -column 0 \
		-padx "7 3" \
		-pady 3
		grid $::window(rec_nb1).sb_lf_duration_min -in $::window(rec_nb1).labelframe_rec_dur -row 0 -column 1 \
		-padx "0 3" \
		-pady 3
		grid $::window(rec_nb1).sb_lf_duration_sec -in $::window(rec_nb1).labelframe_rec_dur -row 0 -column 2 \
		-padx "0 3" \
		-pady 3
		
		grid $::window(rec_nb1).lf_rec_station_change -in $::window(rec_nb1) -row 2 -column 0 \
		-padx 5 \
		-pady "5 0" \
		-sticky ew
		grid $::window(rec_nb1).b_lf_allow_rec -in $::window(rec_nb1).lf_rec_station_change -row 0 -column 0 \
		-padx 7 \
		-pady 3
		
		grid $::window(rec_nb1).lf_scheduler_autostart -in $::window(rec_nb1) -row 3 -column 0 \
		-padx 5 \
		-pady "5 0" \
		-sticky ew
		grid $::window(rec_nb1).cb_lf_scheduler_autostart -in $::window(rec_nb1).lf_scheduler_autostart -row 0 -column 0 \
		-padx 7 \
		-pady 3
		
		
		grid $::window(rec_nb2).lf_times_stnd -in $::window(rec_nb2) -row 0 -column 0 \
		-padx 5 \
		-pady "5 0" \
		-sticky ew
		grid $::window(rec_nb2).e_lf_times_stnd -in $::window(rec_nb2).lf_times_stnd -row 0 -column 0 \
		-sticky ew \
		-padx 7 \
		-pady 3
		grid $::window(rec_nb2).b_lf_times_stnd -in $::window(rec_nb2).lf_times_stnd -row 0 -column 1 \
		-pady 3
		
		grid $::window(rec_nb2).lf_times_df -in $::window(rec_nb2) -row 1 -column 0 \
		-sticky ew \
		-padx 5 \
		-pady "5 0"
		grid $::window(rec_nb2).e_lf_times_df -in $::window(rec_nb2).lf_times_df -row 0 -column 0 \
		-padx "7 0" \
		-pady 3
		grid $::window(rec_nb2).l_lf_times_df -in $::window(rec_nb2).lf_times_df -row 0 -column 1 \
		-sticky w \
		-pady 3
		
		# Additional Code
		
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt7 $::window(rec_nb1) $::window(rec_nb2)]
		
		# Subprocs
		
		proc config_recordGetRecDir {} {
			set old_dir "$::choice(entry_rec_path)"
			wm protocol .config_wizard WM_DELETE_WINDOW " "
			if {"[string trim $::choice(entry_rec_path)]" == "[subst $::option(rec_default_path)]" || [file isdirectory [string trim "$::choice(entry_rec_path)"]] != 1} {
				set :::choice(entry_rec_path) [ttk::chooseDirectory -parent .config_wizard -title [mc "Choose a directory"] -initialdir "[subst $::option(rec_default_path)]"]
			} else {
				set ::choice(entry_rec_path) [ttk::chooseDirectory -parent .config_wizard -title [mc "Choose a directory"] -initialdir "$::choice(entry_rec_path)"]
			}
			wm protocol .config_wizard WM_DELETE_WINDOW config_wizardExit
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Chosen record directory $::choice(entry_rec_path)"
			flush $::logf_tv_open_append
			if {[string trim "$::choice(entry_rec_path)"] == {}} {
				set ::choice(entry_rec_path) "$old_dir"
			}
		}
		proc config_recordDurHour {} {
			if {$::choice(sb_duration_hour) < 0} {
				set ::choice(sb_duration_hour) 0
			}
		}
		proc config_recordDurMin {} {
			if {$::choice(sb_duration_min) >= 60} {
				set ::choice(sb_duration_min) 0
				if {$::choice(sb_duration_hour) < 99} {
					set ::choice(sb_duration_hour) [expr $::choice(sb_duration_hour) + 1]
				}
			}
			if {$::choice(sb_duration_min) <= -1} {
				set ::choice(sb_duration_min) 59
				if {$::choice(sb_duration_hour) > 0} {
					set ::choice(sb_duration_hour) [expr $::choice(sb_duration_hour) - 1]
				}
			}
		}
		proc config_recordDurSec {} {
			if {$::choice(sb_duration_sec) >= 60} {
				set ::choice(sb_duration_sec) 0
				if {$::choice(sb_duration_min) < 60} {
					set ::choice(sb_duration_min) [expr $::choice(sb_duration_min) + 1]
					config_recordDurMin
				}
			}
			if {$::choice(sb_duration_sec) <= -1} {
				set ::choice(sb_duration_sec) 59
				if {$::choice(sb_duration_min) > 0} {
					set ::choice(sb_duration_min) [expr $::choice(sb_duration_min) - 1]
					config_recordDurMin
				}
			}
		}
		proc config_recordScheduler {} {
			if {$::choice(cb_sched_auto) == 1} {
				if {[file isdirectory "$::env(HOME)/.config"]} {
					if {[file isdirectory "$::env(HOME)/.config/autostart"]} {
						file copy -force "$::where_is/data/tv-viewer_scheduler.desktop" "$::env(HOME)/.config/autostart/"
					} else {
						file mkdir "$::env(HOME)/.config/autostart/"
						file copy -force "$::where_is/data/tv-viewer_scheduler.desktop" "$::env(HOME)/.config/autostart/"
					}
				} else {
					file mkdir "$::env(HOME)/.config/" "$::env(HOME)/.config/autostart/"
					file copy -force "$::where_is/data/tv-viewer_scheduler.desktop" "$::env(HOME)/.config/autostart/"
				}
			} else {
				catch {file delete "$::env(HOME)/.config/autostart/tv-viewer_scheduler.desktop"}
			}
		}
		proc config_recordTimesDir {} {
			set old_dir "$::choice(ent_times_folder)"
			wm protocol .config_wizard WM_DELETE_WINDOW " "
			if {"[string trim $::choice(ent_times_folder)]" == "[subst $::option(timeshift_path)]" || [file isdirectory [string trim "$::choice(ent_times_folder)"]] != 1} {
				set ::choice(ent_times_folder) [ttk::chooseDirectory -parent .config_wizard -title [mc "Choose a directory"] -initialdir "[subst $::option(timeshift_path)]"]
			} else {
				set ::choice(ent_times_folder) [ttk::chooseDirectory -parent .config_wizard -title [mc "Choose a directory"] -initialdir "$::choice(ent_times_folder)"]
			}
			wm protocol .config_wizard WM_DELETE_WINDOW config_wizardExit
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Chosen timeshift directory $::choice(ent_times_folder)"
			flush $::logf_tv_open_append
			if {[string trim "$::choice(ent_times_folder)"] == {}} {
				set ::choice(ent_times_folder) "$old_dir"
			}
		}
		
		proc default_opt7 {w w2} {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Starting to collect data for record section."
			flush $::logf_tv_open_append
			set ::choice(entry_rec_path) "[subst $::option(rec_default_path)]"
			set ::choice(sb_duration_hour) $::option(rec_duration_hour)
			set ::choice(sb_duration_min) $::option(rec_duration_min)
			set ::choice(sb_duration_sec) $::option(rec_duration_sec)
			set ::choice(cb_allow_schange_rec) $::option(rec_allow_sta_change)
			set ::choice(cb_sched_auto) $::option(rec_sched_auto)
			set ::choice(ent_times_folder) "[subst $::option(timeshift_path)]"
			set ::choice(ent_times_df) $::option(timeshift_df)
			if {$::option(tooltips) == 1} {
				if {$::option(tooltips_wizard) == 1} {
					settooltip $::window(rec_nb1).entry_rec [mc "Set the default directory for all recordings."]
					settooltip $::window(rec_nb1).button_rec_path [mc "Set the default directory for all recordings."]
					settooltip $::window(rec_nb1).sb_lf_duration_hour [mc "Define the default duration for recordings (Hours)."]
					settooltip $::window(rec_nb1).sb_lf_duration_min [mc "Define the default duration for recordings (Minutes)."]
					settooltip $::window(rec_nb1).sb_lf_duration_sec [mc "Define the default duration for recordings (Seconds)."]
					settooltip $::window(rec_nb1).b_lf_allow_rec [mc "Allow station change during recording."]
					settooltip $::window(rec_nb1).cb_lf_scheduler_autostart [mc "Autostart the scheduler.
This is necessary for scheduled recordings."]
					settooltip $::window(rec_nb2).e_lf_times_stnd [mc "Choose path where Timeshift events will be cached."]
					settooltip $::window(rec_nb2).b_lf_times_stnd [mc "Choose path where Timeshift events will be cached."]
					settooltip $::window(rec_nb2).e_lf_times_df [mc "Define the minimum free disk space.
If free disk space is falling below this value
timeshift will automatically be stopped."]
				} else {
					settooltip $::window(rec_nb1).entry_rec {}
					settooltip $::window(rec_nb1).button_rec_path {}
					settooltip $::window(rec_nb1).sb_lf_duration_hour {}
					settooltip $::window(rec_nb1).sb_lf_duration_min {}
					settooltip $::window(rec_nb1).sb_lf_duration_sec {}
					settooltip $::window(rec_nb1).b_lf_allow_rec {}
					settooltip $::window(rec_nb1).cb_lf_scheduler_autostart {}
				}
			}
		}
		proc stnd_opt7 {w w2} {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting record options to default."
			flush $::logf_tv_open_append
			set ::choice(entry_rec_path) "[subst $::stnd_opt(rec_default_path)]"
			set ::choice(sb_duration_hour) $::stnd_opt(rec_duration_hour)
			set ::choice(sb_duration_min) $::stnd_opt(rec_duration_min)
			set ::choice(sb_duration_sec) $::stnd_opt(rec_duration_sec)
			set ::choice(cb_allow_schange_rec) $::stnd_opt(rec_allow_sta_change)
			set ::choice(cb_sched_auto) $::stnd_opt(rec_sched_auto)
			config_recordScheduler
			set ::choice(ent_times_folder) "[subst $::stnd_opt(timeshift_path)]"
			set ::choice(ent_times_df) $::stnd_opt(timeshift_df)
		}
		
		default_opt7 $::window(rec_nb1) $::window(rec_nb2)
	}
}
