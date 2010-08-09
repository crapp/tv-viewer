#       config_dvb.tcl
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

proc option_screen_8 {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: option_screen_8 \033\[0m"
	# Setting up the interface
	
	foreach tab [split [.config_wizard.frame_configoptions.nb tabs]] {
		.config_wizard.frame_configoptions.nb hide $tab
	}
	
	if {[winfo exists .config_wizard.frame_configoptions.nb.f_advanced_mplayeropts]} {
		.config_wizard.frame_configoptions.nb add $::window(advanced_nb1)
		.config_wizard.frame_configoptions.nb add $::window(advanced_nb2)
		.config_wizard.frame_configoptions.nb add $::window(advanced_nb3)
		.config_wizard.frame_configoptions.nb select $::window(advanced_nb1)
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt8 $::window(advanced_nb1) $::window(advanced_nb2) $::window(advanced_nb3)]
	} else {
		log_writeOutTv 0 "Setting up advanced section in preferences"
		set w .config_wizard.frame_configoptions.nb
		set ::window(advanced_nb1) [ttk::frame $w.f_advanced]
		$w add $::window(advanced_nb1) -text [mc "Advanced"] -padding 2
		set lf_aspect $::window(advanced_nb1).lf_advanced_aspect
		ttk::checkbutton $::window(advanced_nb1).cb_advanced_aspect -text [mc "Manage aspect ratio"] -variable choice(cb_lf_aspect) -command [list config_advancedAspectLF $lf_aspect.cb_keepaspect $lf_aspect.rb_moniaspect $lf_aspect.mb_moniaspect $lf_aspect.rb_monipixaspect $lf_aspect.sb_monipixaspect]
		ttk::labelframe $::window(advanced_nb1).lf_advanced_aspect -labelwidget $::window(advanced_nb1).cb_advanced_aspect
		ttk::checkbutton $lf_aspect.cb_keepaspect -text [mc "Keep video aspect ratio"] -variable choice(cb_keepaspect)
		ttk::radiobutton $lf_aspect.rb_moniaspect -text [mc "Monitor aspect"] -variable choice(rb_aspect) -value 0 -command [list config_advancedAspect $lf_aspect.mb_moniaspect $lf_aspect.sb_monipixaspect]
		ttk::menubutton $lf_aspect.mb_moniaspect -menu $::window(advanced_nb1).mbMoniaspect -textvariable choice(mbMoniaspect)
		menu $::window(advanced_nb1).mbMoniaspect -tearoff 0 -background $::option(theme_$::option(use_theme))
		ttk::radiobutton $lf_aspect.rb_monipixaspect -text [mc "Monitor pixel aspect"] -variable choice(rb_aspect) -value 1 -command [list config_advancedAspect $lf_aspect.mb_moniaspect $lf_aspect.sb_monipixaspect]
		spinbox $lf_aspect.sb_monipixaspect -from 0.2 -to 9.0 -increment 0.1 -width 3 -repeatinterval 50 -state readonly -textvariable choice(sb_monipixaspect)
		set lf_shot $::window(advanced_nb1).lf_advanced_screenshot
		ttk::labelframe $::window(advanced_nb1).lf_advanced_screenshot -text [mc "Screenshot"]
		ttk::checkbutton $lf_shot.cb_advanced_shot -text [mc "Activate screenshot feature"] -variable choice(cb_advanced_shot)
		set lf_mconfig $::window(advanced_nb1).lf_advanced_mconfig
		ttk::labelframe $::window(advanced_nb1).lf_advanced_mconfig -text [mc "MPlayer config file"]
		ttk::checkbutton $lf_mconfig.cb_advanced_mconfig -text [mc "Do not process MPlayer config files"] -variable choice(cb_advanced_mconfig)
		ttk::labelframe $::window(advanced_nb1).lf_advanced_factory -text [mc "Default settings"]
		set lf_factory $::window(advanced_nb1).lf_advanced_factory
		ttk::button $lf_factory.b_reset -text [mc "Reset"] -command config_advancedReset
		
		set ::window(advanced_nb2) [ttk::frame $w.f_advanced_mplayeropts]
		$w add $::window(advanced_nb2) -text [mc "Additional options for MPlayer"] -padding 2
		ttk::labelframe $::window(advanced_nb2).lf_additional_mplayer_com -text [mc "Additional MPlayer options"]
		ttk::entry $::window(advanced_nb2).e_lf_additional_mplayer_com -textvariable choice(entry_mplayer_add_coms)
		ttk::labelframe $::window(advanced_nb2).lf_add_vf_mpl -text [mc "Additional video filter options"]
		ttk::entry $::window(advanced_nb2).e_lf_add_vf_mpl -textvariable choice(entry_vf_mplayer)
		ttk::labelframe $::window(advanced_nb2).lf_add_af_mpl -text [mc "Additional audio filter options"]
		ttk::entry $::window(advanced_nb2).e_lf_add_af_mpl -textvariable choice(entry_af_mplayer)
		
		set ::window(advanced_nb3) [ttk::frame $w.f_advanced_logs]
		$w add $::window(advanced_nb3) -text [mc "Logs"] -padding 2
		ttk::checkbutton $::window(advanced_nb3).cb_lf_logging -text [mc "Enable Logging"] -variable choice(cb_lf_logging) -command [list config_advancedLogging $::window(advanced_nb3)]
		ttk::labelframe $::window(advanced_nb3).lf_logging -labelwidget $::window(advanced_nb3).cb_lf_logging
		ttk::label $::window(advanced_nb3).l_logging_mplayer -text [mc "MPlayer logfile size in kBytes"]
		spinbox $::window(advanced_nb3).sb_logging_mplayer -from 10 -to 100 -increment 10 -state readonly -textvariable choice(sb_logging_mplayer)
		ttk::label $::window(advanced_nb3).l_logging_sched -text [mc "Scheduler logfile size in kBytes"]
		spinbox $::window(advanced_nb3).sb_logging_sched -from 10 -to 100 -increment 10 -state readonly -textvariable choice(sb_logging_sched)
		ttk::label $::window(advanced_nb3).l_logging_tv -text [mc "TV-Viewer logfile size in kBytes"]
		spinbox $::window(advanced_nb3).sb_logging_tv -from 10 -to 100 -increment 10 -state readonly -textvariable choice(sb_logging_tv)
		
		grid columnconfigure $::window(advanced_nb1) 0 -weight 1
		grid columnconfigure $lf_aspect 1 -minsize 100
		grid columnconfigure $::window(advanced_nb2) 0 -weight 1
		grid columnconfigure $::window(advanced_nb2).lf_additional_mplayer_com {0} -weight 1
		grid columnconfigure $::window(advanced_nb2).lf_add_vf_mpl {0} -weight 1
		grid columnconfigure $::window(advanced_nb2).lf_add_af_mpl {0} -weight 1
		grid columnconfigure $::window(advanced_nb3) 0 -weight 1
		
		grid $lf_aspect -in $::window(advanced_nb1) -row 0 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $lf_aspect.cb_keepaspect -in $lf_aspect -row 0 -column 0 -sticky w -padx 7 -pady 3
		grid $lf_aspect.rb_moniaspect -in $lf_aspect -row 1 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $lf_aspect.mb_moniaspect -in $lf_aspect -row 1 -column 1 -sticky ew -pady "0 3"
		grid $lf_aspect.rb_monipixaspect -in $lf_aspect -row 2 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $lf_aspect.sb_monipixaspect -in $lf_aspect -row 2 -column 1 -sticky ew -pady "0 3"
		grid $lf_shot -in $::window(advanced_nb1) -row 1 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $lf_shot.cb_advanced_shot -in $lf_shot -row 0 -column 0 -sticky w -padx 7 -pady 3
		grid $lf_mconfig -in $::window(advanced_nb1) -row 2 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $lf_mconfig.cb_advanced_mconfig -in $lf_mconfig -row 0 -column 0 -sticky w -padx 7 -pady 3
		grid $lf_factory -in $::window(advanced_nb1) -row 3 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $lf_factory.b_reset -in $lf_factory -row 0 -column 0 -sticky w -padx 7 -pady 3
		
		grid $::window(advanced_nb2).lf_additional_mplayer_com -in $::window(advanced_nb2) -row 0 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(advanced_nb2).e_lf_additional_mplayer_com -in $::window(advanced_nb2).lf_additional_mplayer_com -row 0 -column 0 -sticky ew -padx 7 -pady 3
		grid $::window(advanced_nb2).lf_add_vf_mpl -in $::window(advanced_nb2) -row 1 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(advanced_nb2).e_lf_add_vf_mpl -in $::window(advanced_nb2).lf_add_vf_mpl -row 0 -column 0 -sticky ew -padx 7 -pady 3
		grid $::window(advanced_nb2).lf_add_af_mpl -in $::window(advanced_nb2) -row 2 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(advanced_nb2).e_lf_add_af_mpl -in $::window(advanced_nb2).lf_add_af_mpl -row 0 -column 0 -sticky ew -padx 7 -pady 3
		
		grid $::window(advanced_nb3).lf_logging -in $::window(advanced_nb3) -row 0 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(advanced_nb3).l_logging_mplayer -in $::window(advanced_nb3).lf_logging -row 0 -column 0 -sticky w -padx 7 -pady 3
		grid $::window(advanced_nb3).sb_logging_mplayer -in $::window(advanced_nb3).lf_logging -row 0 -column 1 -pady 3
		grid $::window(advanced_nb3).l_logging_sched -in $::window(advanced_nb3).lf_logging -row 1 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $::window(advanced_nb3).sb_logging_sched -in $::window(advanced_nb3).lf_logging -row 1 -column 1 -pady "0 3"
		grid $::window(advanced_nb3).l_logging_tv -in $::window(advanced_nb3).lf_logging -row 2 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $::window(advanced_nb3).sb_logging_tv -in $::window(advanced_nb3).lf_logging -row 2 -column 1 -pady "0 3"
		
		#Additional Code
		
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt8 $::window(advanced_nb1) $::window(advanced_nb2) $::window(advanced_nb3)]
		
		set monaspects {4:3 16:9 5:4 16:10}
		foreach aspect $monaspects {
			$::window(advanced_nb1).mbMoniaspect add radiobutton \
			-label $aspect \
			-variable choice(mbMoniaspect)
		}
		
		# Subprocs
		
		proc config_advancedAspectLF {cb_keepaspect rb_moniaspect mb_moniaspect rb_monipixaspect sb_monipixaspect} {
			#Change states for all widgets in labelframe
			if {$::choice(cb_lf_aspect) == 0} {
				$cb_keepaspect state disabled
				$rb_moniaspect state disabled
				$mb_moniaspect state disabled
				$rb_monipixaspect state disabled
				$sb_monipixaspect configure -state disabled
			} else {
				$cb_keepaspect state !disabled
				$rb_moniaspect state !disabled
				$mb_moniaspect state !disabled
				$rb_monipixaspect state !disabled
				$sb_monipixaspect configure -state readonly
			}
		}
		
		proc config_advancedAspect {mb_moniaspect sb_monipixaspect} {
			#Radiobutton for Monitor aspect and corresponding spinboxes.
			if {$::choice(rb_aspect) == 0} {
				$sb_monipixaspect configure -state disabled
				$mb_moniaspect state !disabled
			} else {
				$sb_monipixaspect configure -state readonly
				$mb_moniaspect state disabled
			}
		}
		
		proc config_advancedLogging {w} {
			#Change states for all widgets in labelframe
			puts $::main(debug_msg) "\033\[0;1;33mDebug: config_advancedLogging \033\[0m \{$w\}"
			if {$::choice(cb_lf_logging) == 1} {
				$w.sb_logging_mplayer configure -state readonly
				$w.sb_logging_sched configure -state readonly
				$w.sb_logging_tv configure -state readonly
			} else {
				$w.sb_logging_mplayer configure -state disabled
				$w.sb_logging_sched configure -state disabled
				$w.sb_logging_tv configure -state disabled
			}
		}
		
		proc config_advancedReset {} {
			#Function to reset alle TV-Viewer options to defaults.
			if {$::config(rec_running) == 0} {
				stnd_opt0 $::window(general_nb1)
				stnd_opt1 $::window(analog_nb1) $::window(analog_nb2)
				stnd_opt2 $::window(dvb_nb1)
				stnd_opt3 $::window(video_nb1_cont).f_video2
				stnd_opt4 $::window(audio_nb1)
				stnd_opt5 $::window(radio_nb1)
				stnd_opt6 $::window(interface_nb1) $::window(interface_nb2) $::window(interface_nb3)
				stnd_opt7 $::window(rec_nb1) $::window(rec_nb2)
				stnd_opt8 $::window(advanced_nb1) $::window(advanced_nb2) $::window(advanced_nb3)
			} else {
				stnd_opt0 $::window(general_nb1)
				stnd_opt2 $::window(dvb_nb1)
				stnd_opt3 $::window(video_nb1_cont).f_video2
				stnd_opt4 $::window(audio_nb1)
				stnd_opt5 $::window(radio_nb1)
				stnd_opt6 $::window(interface_nb1) $::window(interface_nb2) $::window(interface_nb3)
				stnd_opt7 $::window(rec_nb1) $::window(rec_nb2)
				stnd_opt8 $::window(advanced_nb1) $::window(advanced_nb2) $::window(advanced_nb3)
			}
		}
		
		proc default_opt8 {w w2 w3} {
			#Collect and set data for advanced section.
			puts $::main(debug_msg) "\033\[0;1;33mDebug: default_opt8 \033\[0m \{$w\} \{$w2\}"
			log_writeOutTv 0 "Starting to collect data for advanced section."
			if {[info exists ::option(player_aspect)]} {
				set ::choice(cb_lf_aspect) $::option(player_aspect)
			} else {
				set ::choice(cb_lf_aspect) $::stnd_opt(player_aspect)
			}
			if {[info exists ::option(player_keepaspect)]} {
				set ::choice(cb_keepaspect) $::option(player_keepaspect)
			} else {
				set ::choice(cb_keepaspect) $::stnd_opt(player_keepaspect)
			}
			if {[info exists ::option(player_aspect_monpix)]} {
				set ::choice(rb_aspect) $::option(player_aspect_monpix)
			} else {
				set ::choice(rb_aspect) $::stnd_opt(player_aspect_monpix)
			}
			if {[info exists ::option(player_monaspect_val)]} {
				set ::choice(mbMoniaspect) $::option(player_monaspect_val)
			} else {
				set ::choice(mbMoniaspect) $::stnd_opt(player_monaspect_val)
			}
			if {[info exists ::option(player_pixaspect_val)]} {
				set ::choice(sb_monipixaspect) $::option(player_pixaspect_val)
			} else {
				set ::choice(sb_monipixaspect) $::stnd_opt(player_pixaspect_val)
			}
			if {[info exists ::option(player_shot)]} {
				set ::choice(cb_advanced_shot) $::option(player_shot)
			} else {
				set ::choice(cb_advanced_shot) $::stnd_opt(player_shot)
			}
			if {[info exists ::option(player_mconfig)]} {
				set ::choice(cb_advanced_mconfig) $::option(player_mconfig)
			} else {
				set ::choice(cb_advanced_mconfig) $::stnd_opt(player_mconfig)
			}
			config_advancedAspectLF $::window(advanced_nb1).lf_advanced_aspect.cb_keepaspect $::window(advanced_nb1).lf_advanced_aspect.rb_moniaspect $::window(advanced_nb1).lf_advanced_aspect.mb_moniaspect $::window(advanced_nb1).lf_advanced_aspect.rb_monipixaspect $::window(advanced_nb1).lf_advanced_aspect.sb_monipixaspect
			config_advancedAspect $::window(advanced_nb1).lf_advanced_aspect.mb_moniaspect $::window(advanced_nb1).lf_advanced_aspect.sb_monipixaspect
			
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
				if {$::option(log_size_tvviewer) > 100} {
					set ::choice(sb_logging_tv) $::stnd_opt(log_size_tvviewer)
				} else {
					set ::choice(sb_logging_tv) $::option(log_size_tvviewer)
				}
			} else {
				set ::choice(sb_logging_tv) $::stnd_opt(log_size_tvviewer)
			}
			if {[info exists ::option(log_size_mplay)]} {
				if {$::option(log_size_mplay) > 100} {
					set ::choice(sb_logging_mplayer) $::stnd_opt(log_size_mplay)
				} else {
					set ::choice(sb_logging_mplayer) $::option(log_size_mplay)
				}
			} else {
				set ::choice(sb_logging_mplayer) $::stnd_opt(log_size_mplay)
			}
			if {[info exists ::option(log_size_scheduler)]} {
				if {$::option(log_size_scheduler) > 100} {
					set ::choice(sb_logging_sched) $::stnd_opt(log_size_scheduler)
				} else {
					set ::choice(sb_logging_sched) $::option(log_size_scheduler)
				}
			} else {
				set ::choice(sb_logging_sched) $::stnd_opt(log_size_scheduler)
			}
			config_advancedLogging $::window(advanced_nb3)
			
			if {$::option(tooltips) == 1} {
				if {$::option(tooltips_wizard) == 1} {
					set lf_aspect $::window(advanced_nb1).lf_advanced_aspect
					set lf_shot $::window(advanced_nb1).lf_advanced_screenshot
					set lf_mconfig $::window(advanced_nb1).lf_advanced_mconfig
					set lf_factory $::window(advanced_nb1).lf_advanced_factory
					settooltip $::window(advanced_nb1).cb_advanced_aspect [mc "Let TV-Viewer manage video aspect ratio (recommended)"]
					settooltip $lf_aspect.cb_keepaspect [mc "Keep video aspect ratio"]
					settooltip $lf_aspect.rb_moniaspect [mc "Choose either monitor aspect ratio or monitor pixel aspect.
This may improve picture quality."]
					settooltip $lf_aspect.mb_moniaspect [mc "Choose either monitor aspect ratio or monitor pixel aspect.
This may improve picture quality."]
					settooltip $lf_aspect.rb_monipixaspect [mc "Choose either monitor aspect ratio or monitor pixel aspect.
This may improve picture quality."]
					settooltip $lf_aspect.sb_monipixaspect [mc "Choose either monitor aspect ratio or monitor pixel aspect.
This may improve picture quality."]
					settooltip $lf_shot.cb_advanced_shot [mc "Activate or deactive the screenshot feature.
Screenshots will be stored in the users home directory."]
					settooltip $lf_mconfig.cb_advanced_mconfig [mc "If enabled MPlayer will ignore all existing config files.
This will ensure only values set by TV-Viewer will be used."]
					settooltip $lf_factory.b_reset [mc "Reset all configuration options."]
					settooltip $::window(advanced_nb2).e_lf_additional_mplayer_com [mc "Here you may provide additional command line options for MPlayer.
Separate the different options with spaces.
See the MPlayer man pages for more informations."]
					settooltip $::window(advanced_nb2).e_lf_add_vf_mpl [mc "Additional video filter options must be separated with commas.
E.g. scale=512:-2,eq2=1.1
See the MPlayer man pages for more informations."]
					settooltip $::window(advanced_nb2).e_lf_add_af_mpl [mc "Additional audio filter options must be separated with commas.
E.g. resample=44100:0:0,volnorm
See the MPlayer man pages for more informations."]
					settooltip $::window(advanced_nb3).cb_lf_logging [mc "Check this to enable logging of TV-Viewer, Scheduler and MPlayer events.
You can find the three logfiles in %\/log\/
Refer to the 'Help' section of the main interface for the log viewers." $::option(home)]
					settooltip $::window(advanced_nb3).sb_logging_mplayer [mc "Specify the amount of space in kBytes the MPlayer logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 10kb Maximum: 100kb"]
					settooltip $::window(advanced_nb3).sb_logging_tv [mc "Specify the amount of space in kBytes the TV-Viewer logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 10kb Maximum: 100kb"]
					settooltip $::window(advanced_nb3).sb_logging_sched [mc "Specify the amount of space in kBytes the Scheduler logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 10kb Maximum: 100kb"]
				} else {
					set lf_aspect $::window(advanced_nb1).lf_advanced_aspect
					set lf_shot $::window(advanced_nb1).lf_advanced_screenshot
					set lf_mconfig $::window(advanced_nb1).lf_advanced_mconfig
					set lf_factory $::window(advanced_nb1).lf_advanced_factory
					settooltip $::window(advanced_nb1).cb_advanced_aspect {}
					settooltip $lf_aspect.cb_keepaspect {}
					settooltip $lf_aspect.rb_moniaspect {}
					settooltip $lf_aspect.mb_moniaspect {}
					settooltip $lf_aspect.rb_monipixaspect {}
					settooltip $lf_aspect.sb_monipixaspect {}
					settooltip $lf_shot.cb_advanced_shot {}
					settooltip $lf_mconfig.cb_advanced_mconfig {}
					settooltip $::window(advanced_nb2).e_lf_additional_mplayer_com {}
					settooltip $::window(advanced_nb2).e_lf_add_vf_mpl {}
					settooltip $::window(advanced_nb2).e_lf_add_af_mpl {}
					settooltip $::window(advanced_nb3).cb_lf_logging {}
					settooltip $::window(advanced_nb3).sb_logging_mplayer {}
					settooltip $::window(advanced_nb3).sb_logging_tv {}
					settooltip $::window(advanced_nb3).sb_logging_sched {}
				}
			}
		}
		
		proc stnd_opt8 {w w2 w3} {
			#Defaults for advanced section.
			puts $::main(debug_msg) "\033\[0;1;33mDebug: stnd_opt8 \033\[0m \{$w\} \{$w2\}"
			log_writeOutTv 1 "Setting advanced options to default."
			set ::choice(cb_lf_aspect) $::stnd_opt(player_aspect)
			set ::choice(cb_keepaspect) $::stnd_opt(player_keepaspect)
			set ::choice(rb_aspect) $::stnd_opt(player_aspect_monpix)
			set ::choice(mbMoniaspect) $::stnd_opt(player_monaspect_val)
			set ::choice(sb_monipixaspect) $::stnd_opt(player_pixaspect_val)
			set ::choice(cb_advanced_shot) $::stnd_opt(player_shot)
			set ::choice(cb_advanced_mconfig) $::stnd_opt(player_mconfig)
			config_advancedAspectLF $::window(advanced_nb1).lf_advanced_aspect.cb_keepaspect $::window(advanced_nb1).lf_advanced_aspect.rb_moniaspect $::window(advanced_nb1).lf_advanced_aspect.mb_moniaspect $::window(advanced_nb1).lf_advanced_aspect.rb_monipixaspect $::window(advanced_nb1).lf_advanced_aspect.sb_monipixaspect
			config_advancedAspect $::window(advanced_nb1).lf_advanced_aspect.mb_moniaspect $::window(advanced_nb1).lf_advanced_aspect.sb_monipixaspect
			set ::choice(entry_mplayer_add_coms) $::stnd_opt(player_additional_commands)
			set ::choice(entry_vf_mplayer) $::stnd_opt(player_add_vf_commands)
			set ::choice(entry_af_mplayer) $::stnd_opt(player_add_af_commands)
			set ::choice(cb_lf_logging) $::stnd_opt(log_files)
			set ::choice(sb_logging_tv) $::stnd_opt(log_size_tvviewer)
			set ::choice(sb_logging_mplayer) $::stnd_opt(log_size_mplay)
			set ::choice(sb_logging_sched) $::stnd_opt(log_size_scheduler)
			config_advancedLogging $::window(advanced_nb3)
		}
		default_opt8 $::window(advanced_nb1) $::window(advanced_nb2) $::window(advanced_nb3)
	}
}
