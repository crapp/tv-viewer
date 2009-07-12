#       config_dvb.tcl
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

proc option_screen_8 {} {
	
	# Setting up the interface
	
	foreach tab [split [.config_wizard.frame_configoptions.nb tabs]] {
		.config_wizard.frame_configoptions.nb hide $tab
	}
	
	if {[winfo exists .config_wizard.frame_configoptions.nb.f_advanced_mplayeropts]} {
		.config_wizard.frame_configoptions.nb add $::window(advanced_nb1)
		.config_wizard.frame_configoptions.nb add $::window(advanced_nb2)
		.config_wizard.frame_configoptions.nb select $::window(advanced_nb1)
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt8 $::window(advanced_nb1) $::window(advanced_nb2)]
	} else {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting up advanced section in preferences"
		flush $::logf_tv_open_append
		
		set w .config_wizard.frame_configoptions.nb
		set ::window(advanced_nb1) [ttk::frame $w.f_advanced_mplayeropts]
		$w add $::window(advanced_nb1) -text [mc "Additional options for MPlayer"] -padding 2
		ttk::labelframe $::window(advanced_nb1).lf_additional_mplayer_com \
		-text [mc "Additional MPlayer options"]
		ttk::entry $::window(advanced_nb1).e_lf_additional_mplayer_com \
		-textvariable choice(entry_mplayer_add_coms)
		ttk::labelframe $::window(advanced_nb1).lf_add_vf_mpl \
		-text [mc "Additional video filter options"]
		ttk::entry $::window(advanced_nb1).e_lf_add_vf_mpl \
		-textvariable choice(entry_vf_mplayer)
		ttk::labelframe $::window(advanced_nb1).lf_add_af_mpl \
		-text [mc "Additional audio filter options"]
		ttk::entry $::window(advanced_nb1).e_lf_add_af_mpl \
		-textvariable choice(entry_af_mplayer)
		
		set ::window(advanced_nb2) [ttk::frame $w.f_advanced_logs]
		$w add $::window(advanced_nb2) -text [mc "Logs"] -padding 2
		ttk::checkbutton $::window(advanced_nb2).cb_lf_logging \
		-text [mc "Enable Logging"] \
		-variable choice(cb_lf_logging) \
		-command [list config_advancedLogging $::window(advanced_nb2)]
		ttk::labelframe $::window(advanced_nb2).lf_logging \
		-labelwidget $::window(advanced_nb2).cb_lf_logging
		ttk::label $::window(advanced_nb2).l_logging_mplayer \
		-text [mc "MPlayer logfile size in kBytes"]
		
		proc config_advanced_validateLogSb {value1 value2} {
			if {[string is integer $value1] == 0 || $value1 < 100 || $value1 > 1000} {
				return 0
			} else {
				return 1
			}
		}
		
		spinbox $::window(advanced_nb2).sb_logging_mplayer \
		-from 100 \
		-to 1000 \
		-increment 50 \
		-validate key \
		-vcmd {config_advanced_validateLogSb %P %W} \
		-textvariable choice(sb_logging_mplayer)
		ttk::label $::window(advanced_nb2).l_logging_sched \
		-text [mc "Scheduler logfile size in kBytes"]
		spinbox $::window(advanced_nb2).sb_logging_sched \
		-from 100 \
		-to 1000 \
		-increment 50 \
		-validate key \
		-vcmd {config_advanced_validateLogSb %P %W} \
		-textvariable choice(sb_logging_sched)
		ttk::label $::window(advanced_nb2).l_logging_tv \
		-text [mc "TV-Viewer logfile size in kBytes"]
		spinbox $::window(advanced_nb2).sb_logging_tv \
		-from 100 \
		-to 1000 \
		-increment 50 \
		-validate key \
		-vcmd {config_advanced_validateLogSb %P %W} \
		-textvariable choice(sb_logging_tv)
		
		grid columnconfigure $::window(advanced_nb1) 0 -weight 1
		grid columnconfigure $::window(advanced_nb1).lf_additional_mplayer_com {0} -weight 1
		grid columnconfigure $::window(advanced_nb1).lf_add_vf_mpl {0} -weight 1
		grid columnconfigure $::window(advanced_nb1).lf_add_af_mpl {0} -weight 1
		grid columnconfigure $::window(advanced_nb2) 0 -weight 1
		
		grid $::window(advanced_nb1).lf_additional_mplayer_com -in $::window(advanced_nb1) -row 0 -column 0 \
		-sticky ew \
		-padx 5 \
		-pady "5 0"
		grid $::window(advanced_nb1).e_lf_additional_mplayer_com -in $::window(advanced_nb1).lf_additional_mplayer_com -row 0 -column 0 \
		-sticky ew \
		-padx 7 \
		-pady 3
		grid $::window(advanced_nb1).lf_add_vf_mpl -in $::window(advanced_nb1) -row 1 -column 0 \
		-sticky ew \
		-padx 5 \
		-pady "5 0"
		grid $::window(advanced_nb1).e_lf_add_vf_mpl -in $::window(advanced_nb1).lf_add_vf_mpl -row 0 -column 0 \
		-sticky ew \
		-padx 7 \
		-pady 3
		grid $::window(advanced_nb1).lf_add_af_mpl -in $::window(advanced_nb1) -row 2 -column 0 \
		-sticky ew \
		-padx 5 \
		-pady "5 0"
		grid $::window(advanced_nb1).e_lf_add_af_mpl -in $::window(advanced_nb1).lf_add_af_mpl -row 0 -column 0 \
		-sticky ew \
		-padx 7 \
		-pady 3
		
		grid $::window(advanced_nb2).lf_logging -in $::window(advanced_nb2) -row 0 -column 0 \
		-sticky ew \
		-padx 5 \
		-pady "5 0"
		grid $::window(advanced_nb2).l_logging_mplayer -in $::window(advanced_nb2).lf_logging -row 0 -column 0 \
		-sticky w \
		-padx 7 \
		-pady 3
		grid $::window(advanced_nb2).sb_logging_mplayer -in $::window(advanced_nb2).lf_logging -row 0 -column 1 \
		-pady 3
		grid $::window(advanced_nb2).l_logging_sched -in $::window(advanced_nb2).lf_logging -row 1 -column 0 \
		-sticky w \
		-padx 7 \
		-pady "0 3"
		grid $::window(advanced_nb2).sb_logging_sched -in $::window(advanced_nb2).lf_logging -row 1 -column 1 \
		-pady "0 3"
		grid $::window(advanced_nb2).l_logging_tv -in $::window(advanced_nb2).lf_logging -row 2 -column 0 \
		-sticky w \
		-padx 7 \
		-pady "0 3"
		grid $::window(advanced_nb2).sb_logging_tv -in $::window(advanced_nb2).lf_logging -row 2 -column 1 \
		-pady "0 3"
		
		#Additional Code
		
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt2 $::window(advanced_nb1) $::window(advanced_nb2)]
		
		proc config_advancedLogging {w} {
			if {$::choice(cb_lf_logging) == 1} {
				$w.sb_logging_mplayer configure -state normal
				$w.sb_logging_sched configure -state normal
				$w.sb_logging_tv configure -state normal
			} else {
				$w.sb_logging_mplayer configure -state disabled
				$w.sb_logging_sched configure -state disabled
				$w.sb_logging_tv configure -state disabled
			}
		}
		
		proc default_opt8 {w w2} {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Starting to collect data for advanced section."
			flush $::logf_tv_open_append
			if {[info exists ::option(player_additional_commands)]} {
				set ::choice(entry_mplayer_add_coms) $::option(player_additional_commands)
			} else {
				set ::choice(entry_mplayer_add_coms) $::stnd_opt(player_additional_commands)
			}
			if {[info exists ::option(player_add_vf_commands)]} {
				set ::choice(entry_vf_mplayer) $::option(player_add_vf_commands)
			} else {
				set ::choice(entry_vf_mplayer) $::stnd_opt(player_add_vf_commands)
			}
			if {[info exists ::option(player_add_af_commands)]} {
				set ::choice(entry_af_mplayer) $::option(player_add_af_commands)
			} else {
				set ::choice(entry_af_mplayer) $::stnd_opt(player_add_af_commands)
			}
			
			if {[info exists ::option(log_files)]} {
				set ::choice(cb_lf_logging) $::option(log_files)
			} else {
				set ::choice(cb_lf_logging) $::stnd_opt(log_files)
			}
			if {[info exists ::option(log_size_tvviewer)]} {
				set ::choice(sb_logging_tv) $::option(log_size_tvviewer)
			} else {
				set ::choice(sb_logging_tv) $::stnd_opt(log_size_tvviewer)
			}
			if {[info exists ::option(log_size_mplay)]} {
				set ::choice(sb_logging_mplayer) $::option(log_size_mplay)
			} else {
				set ::choice(sb_logging_mplayer) $::stnd_opt(log_size_mplay)
			}
			if {[info exists ::option(log_size_scheduler)]} {
				set ::choice(sb_logging_sched) $::option(log_size_scheduler)
			} else {
				set ::choice(sb_logging_sched) $::stnd_opt(log_size_scheduler)
			}
			config_advancedLogging $::window(advanced_nb2)
			
			if {$::option(tooltips) == 1} {
				if {$::option(tooltips_wizard) == 1} {
					settooltip $::window(advanced_nb1).e_lf_additional_mplayer_com [mc "Here you may provide additional command line options for MPlayer.
Separate the different options with spaces.
See the MPlayer man pages for more informations."]
					settooltip $::window(advanced_nb1).e_lf_add_vf_mpl [mc "Additional video filter options must be separated with commas.
E.g. scale=512:-2,eq2=1.1
See the MPlayer man pages for more informations."]
					settooltip $::window(advanced_nb1).e_lf_add_af_mpl [mc "Additional audio filter options must be separated with commas.
E.g. resample=44100:0:0,volnorm
See the MPlayer man pages for more informations."]
					settooltip $::window(advanced_nb2).cb_lf_logging [mc "Check this to enable logging of TV-Viewer, Scheduler and MPlayer events.
You can find the three logfiles in %\/log\/
Refer to the 'Help' section of the main interface for the log viewers." $::where_is_home]
					settooltip $::window(advanced_nb2).sb_logging_mplayer [mc "Specify the amount of space in kBytes the MPlayer logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 100kb Maximum: 1000kb"]
					settooltip $::window(advanced_nb2).sb_logging_tv [mc "Specify the amount of space in kBytes the TV-Viewer logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 100kb Maximum: 1000kb"]
					settooltip $::window(advanced_nb2).sb_logging_sched [mc "Specify the amount of space in kBytes the Scheduler logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 100kb Maximum: 1000kb"]
				} else {
					settooltip $::window(advanced_nb1).e_lf_additional_mplayer_com {}
					settooltip $::window(advanced_nb1).e_lf_add_vf_mpl {}
					settooltip $::window(advanced_nb1).e_lf_add_af_mpl {}
					settooltip $::window(advanced_nb2).cb_lf_logging {}
					settooltip $::window(advanced_nb2).sb_logging_mplayer {}
					settooltip $::window(advanced_nb2).sb_logging_tv {}
					settooltip $::window(advanced_nb2).sb_logging_sched {}
				}
			}
		}
		
		proc stnd_opt8 {w w2} {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting advanced options to default."
			flush $::logf_tv_open_append
			set ::choice(entry_mplayer_add_coms) $::stnd_opt(player_additional_commands)
			set ::choice(entry_vf_mplayer) $::stnd_opt(player_add_vf_commands)
			set ::choice(entry_af_mplayer) $::stnd_opt(player_add_af_commands)
			set ::choice(cb_lf_logging) $::stnd_opt(log_files)
			set ::choice(sb_logging_tv) $::stnd_opt(log_size_tvviewer)
			set ::choice(sb_logging_mplayer) $::stnd_opt(log_size_mplay)
			set ::choice(sb_logging_sched) $::stnd_opt(log_size_scheduler)
			config_advancedLogging $::window(advanced_nb2)
		}
		default_opt8 $::window(advanced_nb1) $::window(advanced_nb2)
	}
}
