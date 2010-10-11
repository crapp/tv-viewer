#       config_analog.tcl
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

proc option_screen_1 {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: option_screen_1 \033\[0m"
	
	# Setting up the interface
	
	foreach tab [split [.config_wizard.frame_configoptions.nb tabs]] {
		.config_wizard.frame_configoptions.nb hide $tab
	}
	
	if {[winfo exists .config_wizard.frame_configoptions.nb.f_analog]} {
		if {[winfo exists .config_wizard.frame_configoptions.nb.f_analog_error]} {
			.config_wizard.frame_configoptions.nb add $::window(analog_nb1)
			.config_wizard.frame_configoptions.nb add $::window(analog_nb2)
			.config_wizard.frame_configoptions.nb add $::window(analog_nb3)
			.config_wizard.frame_configoptions.nb select $::window(analog_nb3)
			.config_wizard.frame_buttons.b_default configure -command {}
			.config_wizard.frame_configoptions.nb tab $::window(analog_nb1) -state disabled
			.config_wizard.frame_configoptions.nb tab $::window(analog_nb2) -state disabled
		} else {
			.config_wizard.frame_configoptions.nb add $::window(analog_nb1)
			.config_wizard.frame_configoptions.nb add $::window(analog_nb2)
			.config_wizard.frame_configoptions.nb select $::window(analog_nb1)
			.config_wizard.frame_buttons.b_default configure -command [list stnd_opt1 $::window(analog_nb1) $::window(analog_nb2)]
			if {$::config(rec_running) == 1} {
				.config_wizard.frame_configoptions.nb tab $::window(analog_nb1) -state disabled
				.config_wizard.frame_configoptions.nb tab $::window(analog_nb2) -state disabled
				.config_wizard.frame_configoptions.nb add $::window(analog_nb4)
				.config_wizard.frame_configoptions.nb select $::window(analog_nb4)
				.config_wizard.frame_buttons.b_default configure -command {}
			}
		}
	} else {
		log_writeOutTv 0 "Setting up analog section in preferences"
		set w .config_wizard.frame_configoptions.nb
		set ::window(analog_nb1) [ttk::frame $w.f_analog]
		$w add $::window(analog_nb1) -text [mc "Analog Settings"] -padding 2
		ttk::labelframe $::window(analog_nb1).lf_video_device -text [mc "Video Device Node"]
		ttk::menubutton $::window(analog_nb1).lf_mb_video_device -menu $::window(analog_nb1).mbVideo_device -textvariable choice(mbVideo)
		menu $::window(analog_nb1).mbVideo_device -tearoff 0
		ttk::labelframe $::window(analog_nb1).lf_video_standard -text [mc "Video Standard"]
		ttk::label $::window(analog_nb1).l_lf_video_standard -text [mc "Video Standard"]
		ttk::label $::window(analog_nb1).l_lf_freqtable -text [mc "Frequency Table"]
		ttk::checkbutton $::window(analog_nb1).cb_lf_video_standard -text [mc "Force Standard"] \
		-variable choice(cb_video_standard)
		ttk::menubutton $::window(analog_nb1).mb_lf_video_standard -menu $::window(analog_nb1).mbVideo_standard -direction above -textvariable choice(mbVideo_standard)
		ttk::menubutton $::window(analog_nb1).mb_lf_freqtable -menu $::window(analog_nb1).mbFreqtable -textvariable choice(mbFreqtable)
		menu $::window(analog_nb1).mbVideo_standard -tearoff 0
		menu $::window(analog_nb1).mbFreqtable -tearoff 0
		ttk::labelframe $::window(analog_nb1).lf_video_input -text [mc "Video Input"]
		ttk::menubutton $::window(analog_nb1).mb_lf_video_input -menu $::window(analog_nb1).mbVideo_input -textvariable choice(mbVideo_input)
		menu $::window(analog_nb1).mbVideo_input -tearoff 0
		
		
		set ::window(analog_nb2) [ttk::frame $w.f_analog_picture]
		$w add $::window(analog_nb2) -text [mc "Analog Stream Settings"] -padding 2
		ttk::checkbutton $::window(analog_nb2).cb_lf_streambitrate -text [mc "Stream Bitrate"] -command [list config_analogStreambitrate $::window(analog_nb2)] -variable choice(cb_streambitrate)
		ttk::labelframe $::window(analog_nb2).lf_streambitrate -labelwidget $::window(analog_nb2).cb_lf_streambitrate
		ttk::label $::window(analog_nb2).l_lf_videobitrate -text [mc "Video Bitrate"]
		ttk::scale $::window(analog_nb2).s_lf_videobitrate -variable choice(scale_videobitrate) -length 200 -command [list config_analog_VideobitrateValue $::window(analog_nb2)]
		ttk::entry $::window(analog_nb2).e_lf_videobitrate_value -textvariable choice(entry_vbitrate_value) -validate key -width 5 -validatecommand {config_analogValidateVb %P %W}
		ttk::label $::window(analog_nb2).l_lf_videopeakbitrate -text [mc "Video Peak Bitrate"]
		ttk::scale $::window(analog_nb2).s_lf_videopeakbitrate -variable choice(scale_videopeakbitrate) -length 200 -command [list config_analogVideopeakbitrateValue $::window(analog_nb2)]
		ttk::entry $::window(analog_nb2).e_lf_videopeakbitrate_value -textvariable choice(entry_pbitrate_value) -validate key -width 5 -validatecommand {config_analogValidateVbp %P %W}
		ttk::checkbutton $::window(analog_nb2).cb_lf_temporal -text [mc "Temporal Filter"] -command [list config_analogTemporal $::window(analog_nb2)] -variable choice(cb_temporal)
		ttk::labelframe $::window(analog_nb2).lf_temporal -labelwidget $::window(analog_nb2).cb_lf_temporal
		ttk::label $::window(analog_nb2).l_lf_temporal -text [mc "Temporal Filter"]
		spinbox $::window(analog_nb2).sb_lf_temporal -width 4 -textvariable choice(spinbox_temporal) -validate key -vcmd {string is integer %P}
		ttk::checkbutton $::window(analog_nb2).cb_audio_v4l2 -text [mc "Hardware volume level"] -variable choice(cb_audio_v4l2) -command config_analog_audioV4l2
		ttk::labelframe $::window(analog_nb2).lf_audio_v4l2 -labelwidget $::window(analog_nb2).cb_audio_v4l2
		ttk::label $::window(analog_nb2).l_audio_v4l2 -text [mc "Volume"]
		ttk::scale $::window(analog_nb2).s_audio_v4l2 -command [list config_analog_audioScale] -length 200
		ttk::label $::window(analog_nb2).l_audio_v4l2_val
		
		grid columnconfigure $::window(analog_nb1) 0 -weight 1
		grid columnconfigure $::window(analog_nb1).lf_video_device 0 -minsize 120
		grid columnconfigure $::window(analog_nb1).lf_video_standard 1 -minsize 120
		grid columnconfigure $::window(analog_nb1).lf_video_input 0 -minsize 120
		grid columnconfigure $::window(analog_nb2) 0 -weight 1
		
		grid $::window(analog_nb1).lf_video_device -in $::window(analog_nb1) -row 1 -column 0 -sticky ew -padx 5
		grid $::window(analog_nb1).lf_mb_video_device -in $::window(analog_nb1).lf_video_device -row 0 -column 0 -sticky ew -padx 7 -pady 3
		grid $::window(analog_nb1).lf_video_standard -in $::window(analog_nb1) -row 3 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(analog_nb1).l_lf_video_standard -in $::window(analog_nb1).lf_video_standard -row 0 -column 0 -pady 3 -padx 7
		grid $::window(analog_nb1).mb_lf_video_standard -in $::window(analog_nb1).lf_video_standard -row 0 -column 1 -sticky ew -pady 3
		grid $::window(analog_nb1).cb_lf_video_standard -in $::window(analog_nb1).lf_video_standard -row 0 -column 2 -pady 3 -padx "7 0"
		grid $::window(analog_nb1).l_lf_freqtable -in $::window(analog_nb1).lf_video_standard -row 2 -column 0 -pady "0 3" -padx 7
		grid $::window(analog_nb1).mb_lf_freqtable -in $::window(analog_nb1).lf_video_standard -row 2 -column 1 -sticky ew -pady "0 3"
		grid $::window(analog_nb1).lf_video_input -in $::window(analog_nb1) -row 5 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(analog_nb1).mb_lf_video_input -in $::window(analog_nb1).lf_video_input -row 0 -column 0 -sticky ew -padx 7 -pady 3
		
		grid $::window(analog_nb2).lf_streambitrate -in $::window(analog_nb2) -row 0 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(analog_nb2).l_lf_videobitrate -in $::window(analog_nb2).lf_streambitrate -row 0 -column 0 -sticky ew -padx 7 -pady "3 0"
		grid $::window(analog_nb2).s_lf_videobitrate -in $::window(analog_nb2).lf_streambitrate -row 0 -column 1 -pady "3 0"
		grid $::window(analog_nb2).e_lf_videobitrate_value -in $::window(analog_nb2).lf_streambitrate -row 0 -column 2 -padx 7 -pady "3 0"
		grid $::window(analog_nb2).l_lf_videopeakbitrate -in $::window(analog_nb2).lf_streambitrate -row 1 -column 0 -sticky ew -padx 7 -pady "3"
		grid $::window(analog_nb2).s_lf_videopeakbitrate -in $::window(analog_nb2).lf_streambitrate -row 1 -column 1 -pady 3
		grid $::window(analog_nb2).e_lf_videopeakbitrate_value -in $::window(analog_nb2).lf_streambitrate -row 1 -column 2 -padx 7 -pady "3"
		grid $::window(analog_nb2).lf_temporal -in $::window(analog_nb2) -row 1 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(analog_nb2).l_lf_temporal -in $::window(analog_nb2).lf_temporal -row 0 -column 0 -sticky ew -padx 7 -pady "3"
		grid $::window(analog_nb2).sb_lf_temporal -in $::window(analog_nb2).lf_temporal -row 0 -column 1 -sticky w -pady "3"
		grid $::window(analog_nb2).lf_audio_v4l2 -in $::window(analog_nb2) -row 2 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(analog_nb2).l_audio_v4l2 -in $::window(analog_nb2).lf_audio_v4l2 -row 0 -column 0 -padx "7 0" -pady 3
		grid $::window(analog_nb2).s_audio_v4l2 -in $::window(analog_nb2).lf_audio_v4l2 -row 0 -column 1 -sticky ew -padx "7 0" -pady 3
		grid $::window(analog_nb2).l_audio_v4l2_val -in $::window(analog_nb2).lf_audio_v4l2 -row 0 -column 2 -padx "7 0" -pady 3
		
		#Additional Code
		
		if {[string trim [auto_execok ivtv-tune]] == {} || [string trim [auto_execok v4l2-ctl]] == {}} {
			log_writeOutTv 2 "Could not detect either ivtv-tune or v4l2-ctl."
			log_writeOutTv 2 "Please check the system requirements!"
			$w tab $::window(analog_nb1) -state disabled
			$w tab $::window(analog_nb2) -state disabled
			set ::window(analog_nb3) [ttk::frame $w.f_analog_error]
			$w add $::window(analog_nb3) -text [mc "Error"]
			ttk::labelframe $::window(analog_nb3).lf_analog_error \
			-text [mc "Missing requirements"]
			ttk::label $::window(analog_nb3).l_error \
			-text [mc "Could not detect all necessary tools to run TV-Viewer"] \
			-compound left \
			-image $::icon_m(dialog-warning)
			ttk::label $::window(analog_nb3).l_error_ivtv \
			-text [mc "ivtv-tune"] \
			-justify left
			ttk::label $::window(analog_nb3).l_error_ivtv_img \
			-justify left
			ttk::label $::window(analog_nb3).l_error_v4l2 \
			-text [mc "v4l2-ctl"] \
			-justify left
			ttk::label $::window(analog_nb3).l_error_v4l2_img \
			-justify left
			
			grid $::window(analog_nb3).l_error -in $::window(analog_nb3) -row 0 -column 0 \
			-pady 10
			grid $::window(analog_nb3).lf_analog_error -in $::window(analog_nb3) -row 1 -column 0 \
			-pady 10 \
			-padx 5 \
			-sticky ew
			grid $::window(analog_nb3).l_error_ivtv -in $::window(analog_nb3).lf_analog_error -row 0 -column 0 \
			-pady 5 \
			-padx "7 0"
			grid $::window(analog_nb3).l_error_ivtv_img -in $::window(analog_nb3).lf_analog_error -row 0 -column 1 \
			-pady 5 \
			-padx "7 0"
			grid $::window(analog_nb3).l_error_v4l2 -in $::window(analog_nb3).lf_analog_error -row 1 -column 0 \
			-pady 5 \
			-padx "7 0"
			grid $::window(analog_nb3).l_error_v4l2_img -in $::window(analog_nb3).lf_analog_error -row 1 -column 1 \
			-pady 5 \
			-padx "7 0"
			
			grid columnconfigure $::window(analog_nb3) 0 -weight 1
			
			if {[string trim [auto_execok ivtv-tune]] == {}} {
				$::window(analog_nb3).l_error_ivtv_img configure -image $::icon_m(dialog-error)
			} else {
				$::window(analog_nb3).l_error_ivtv_img configure -image $::icon_m(dialog-ok)
			}
			if {[string trim [auto_execok v4l2-ctl]] == {}} {
				$::window(analog_nb3).l_error_v4l2_img configure -image $::icon_m(dialog-error)
			} else {
				$::window(analog_nb3).l_error_v4l2_img configure -image $::icon_m(dialog-ok)
			}
			
			.config_wizard.frame_buttons.b_default configure -command {}
			.config_wizard.frame_buttons.button_save state disabled
		} else {
			log_writeOutTv 0 "Found ivtv-tune and v4l2-ctl, GOOD"
			bind $::window(analog_nb2).e_lf_videobitrate_value <Return> [list config_analog_setScaleVideobitrate $::window(analog_nb2)]
			bind $::window(analog_nb2).e_lf_videobitrate_value <KP_Enter> [list config_analog_setScaleVideobitrate $::window(analog_nb2)]
			bind $::window(analog_nb2).e_lf_videopeakbitrate_value <Return> [list config_analog_setScaleVideopeakbitrate $::window(analog_nb2)]
			bind $::window(analog_nb2).e_lf_videopeakbitrate_value <KP_Enter> [list config_analog_setScaleVideopeakbitrate $::window(analog_nb2)]
			
			if {$::config(rec_running) == 1} {
				set ::window(analog_nb4) [ttk::frame $w.f_analog_rec]
				$w add $::window(analog_nb4) -text [mc "Disabled"]
				ttk::label $::window(analog_nb4).l_warn -text [mc "Analog settings are disabled,
while running a recording or timeshift"] -compound left -image $::icon_m(dialog-warning)
				
				grid $::window(analog_nb4).l_warn -in $::window(analog_nb4) -row 0 -column 0 -pady 10 -padx 5 -sticky w
			}
				.config_wizard.frame_buttons.b_default configure -command [list stnd_opt1 $::window(analog_nb1) $::window(analog_nb2)]
			
			set vidstds {PAL NTSC SECAM}
			foreach vstds [split $vidstds] {
				$::window(analog_nb1).mbVideo_standard add radiobutton \
				-variable choice(mbVideo_standard) \
				-label $vstds
			}
			
			# Subprocs
			
			proc config_analog_VideobitrateValue {w value} {
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_analogVideobitrateValue \033\[0m \{$w\} \{$value\}"
				set ::choice(entry_vbitrate_value) [expr int(ceil($value))]
			}
			proc config_analogVideopeakbitrateValue {w value} {
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_analogVideopeakbitrateValue \033\[0m \{$w\} \{$value\}"
				set ::choice(entry_pbitrate_value) [expr int(ceil($value))]
			}
			proc config_analog_setScaleVideobitrate {w} {
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_analog_setScaleVideobitrate \033\[0m \{$w\}"
				if {[string trim $::choice(entry_vbitrate_value)] == {}} return
				set ::choice(scale_videobitrate) $::choice(entry_vbitrate_value)
			}
			proc config_analog_setScaleVideopeakbitrate {w} {
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_analog_setScaleVideopeakbitrate \033\0m \{$w\}"
				if {[string trim $::choice(entry_pbitrate_value)] == {}} return
				set ::choice(scale_videopeakbitrate) $::choice(entry_pbitrate_value)
			}
			proc config_analog_optScrInput {value} {
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_analog_optScrInput \033\0m \{$value\}"
				set ::choice(mbVideo_input_value) $value
				catch {exec v4l2-ctl --device=$::choice(mbVideo) --set-input=$::choice(mbVideo_input_value)}
			}
			
			proc config_analogStreambitrate {w} {
				#Change states for all widgets in labelframe
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_analogStreambitrate \033\[0m \{$w\}"
				if {$::choice(cb_streambitrate) == 0} {
					$w.l_lf_videobitrate state disabled
					$w.s_lf_videobitrate state disabled
					$w.e_lf_videobitrate_value state disabled
					$w.l_lf_videopeakbitrate state disabled
					$w.s_lf_videopeakbitrate state disabled
					$w.e_lf_videopeakbitrate_value state disabled
				} else {
					$w.l_lf_videobitrate state !disabled
					$w.s_lf_videobitrate state !disabled
					$w.e_lf_videobitrate_value state !disabled
					$w.l_lf_videopeakbitrate state !disabled
					$w.s_lf_videopeakbitrate state !disabled
					$w.e_lf_videopeakbitrate_value state !disabled
				}
			}
			proc config_analogTemporal {w} {
				#Change states for all widgets in labelframe
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_analogTemporal \033\[0m \{$w\}"
				if {$::choice(cb_temporal) == 0} {
					$w.l_lf_temporal state disabled
					$w.sb_lf_temporal configure -state disabled
				} else {
					$w.l_lf_temporal state !disabled
					$w.sb_lf_temporal configure -state normal
				}
			}
			proc config_analogValidateVb {value1 value2} {
				#Validation script
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_analogValidateVb \033\[0m \{$value1\} \{$value2\}"
				if {[string is integer $value1] == 0 || $value1 < 0 || $value1 > [expr ($::analog(vbit) / 8) / 1024]} {
					return 0
				} else {
					return 1
				}
			}
			proc config_analogValidateVbp {value1 value2} {
				#Validation script
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_analogValidateVbp \033\[0m \{$value1\} \{$value2\}"
				if {[string is integer $value1] == 0 || $value1 < 0 || $value1 > [expr ($::analog(vbitp) / 8) / 1024]} {
					return 0
				} else {
					return 1
				}
			}
			proc config_analog_audioV4l2 {} {
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_analog_audioV4l2 \033\[0m"
				if {$::choice(cb_audio_v4l2) == 1} {
					$::window(analog_nb2).l_audio_v4l2 state !disabled
					$::window(analog_nb2).s_audio_v4l2 state !disabled
					$::window(analog_nb2).l_audio_v4l2_val state !disabled
				} else {
					$::window(analog_nb2).l_audio_v4l2 state disabled
					$::window(analog_nb2).s_audio_v4l2 state disabled
					$::window(analog_nb2).l_audio_v4l2_val state disabled
				}
			}
			proc config_analog_audioScale {value} {
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_analog_audioScale \033\[0m \{$value\}"
				set displayed_value [expr $value / $::choice(scale_recordvolume_mult)]
				set ::choice(scale_recordvolume) $displayed_value
				$::window(analog_nb2).l_audio_v4l2_val configure -text "[expr round($displayed_value)]%"
			}
			proc default_opt1 {w1 w2} {
				#Find and set values for analog section 
				puts $::main(debug_msg) "\033\[0;1;33mDebug: default_opt1 \033\[0m \{$w1\} \{$w2\}"
				log_writeOutTv 0 "Starting to collect data for analog section..."
				catch {
					$w1.mbVideo_device delete 0 end
					$w1.mbFreqtable delete 0 end
					$w1.mbVideo_input delete 0 end
				}
				set query_dev_node [lsort [glob -nocomplain /dev/video*]]
				if {[string trim $query_dev_node] != {}} {
					set i 1
					foreach node [split $query_dev_node] {
						$w1.mbVideo_device add radiobutton -variable choice(mbVideo) -label "$node" -command [list default_com1 $w1 $w2]
						set devnode($i) $node
						log_writeOutTv 0 "Found device node: $devnode($i)"
						incr i
					}
					set query_dev_node [lsort [glob -nocomplain /dev/*]]
					foreach node [split $query_dev_node] {
						if {"[file type $node]" == "link" } {
							if {[string match *video* [file readlink $node]] == 1} {
								for {set i 0} {$i <= [$w1.mbVideo_device index end]} {incr i} {
									if {"[lindex [$w1.mbVideo_device entryconfigure $i -label] end]" == "$node"} {
										set explode 1
										break
									}
								}
								if {[info exists explode] == 1} {
									unset explode
									continue
								}
								$w1.mbVideo_device add radiobutton -variable choice(mbVideo) -label "$node" -command [list default_com1 $w1 $w2]
								set devnode($i) $node
								incr i
							}
						}
					}
					if {[info exists ::option(video_device)]} {
						set ::choice(mbVideo) $::option(video_device)
					} else {
						catch {set ::choice(mbVideo) $devnode(1)}
					}
					if {[info exists ::choice(mbVideo)]} {
						catch {exec v4l2-ctl --device=$::choice(mbVideo) -n} read_vidinputs
						set status_vid_inputs [catch {agrep -w "$read_vidinputs" Name} resultat_vid_inputs]
						if {$status_vid_inputs == 0} {
							set i 1
							foreach vi [split $resultat_vid_inputs \n] {
								$w1.mbVideo_input add radiobutton \
								-variable choice(mbVideo_input) \
								-label "[string trimleft [string range $vi [string first : $vi] end] ": "]" \
								-command [list config_analog_optScrInput [expr $i - 1]]
								set vinput($i) "[string trimleft [string range $vi [string first : $vi] end] {: }]"
								log_writeOutTv 0 "Found video input: $vinput($i)"
								incr i
							}
						} else {
							$w1.lf_video_input state disabled
							$w1.mb_lf_video_input state disabled
						}
					}
					if {[info exists ::option(video_input)]} {
						catch {set ::choice(mbVideo_input) $vinput([expr $::option(video_input) + 1])}
					} else {
						catch {set ::choice(mbVideo_input) $vinput(1)}
					}
				} else {
					if {$::option(log_warnDialogue)} {
						status_feedbWarn 1 [mc "No video device nodes"]
					}
					log_writeOutTv 2 "Couldn't detect any video device nodes."
					log_writeOutTv 2 "Is your tv-card set up correctly?"
					$w1.lf_video_device state disabled
					$w1.lf_mb_video_device state disabled
					$w1.l_lf_video_standard state disabled
					$w1.l_lf_freqtable state disabled
					$w1.cb_lf_video_standard state disabled
					$w1.mb_lf_video_standard state disabled
					$w1.mb_lf_freqtable state disabled
					$w1.lf_video_input state disabled
					$w1.mb_lf_video_input state disabled
					$w2.lf_streambitrate state disabled
					$w2.cb_lf_streambitrate state disabled
					$w2.l_lf_videobitrate state disabled
					$w2.s_lf_videobitrate state disabled
					$w2.e_lf_videobitrate_value state disabled
					$w2.l_lf_videopeakbitrate state disabled
					$w2.s_lf_videopeakbitrate state disabled
					$w2.e_lf_videopeakbitrate_value state disabled
					$w2.cb_lf_temporal state disabled
					$w2.l_lf_temporal state disabled
					$w2.sb_lf_temporal configure -state disabled
					$w2.cb_audio_v4l2 state disabled
					$w2.l_audio_v4l2 state disabled
					$w2.s_audio_v4l2 state disabled
					$w2.l_audio_v4l2_val state disabled
				}
				catch {exec ivtv-tune -L} resultat_get_freqt
				foreach freqtable [split [lrange $resultat_get_freqt 0 end-2]] {
					log_writeOutTv 0 "Found frequency table: $freqtable"
					$w1.mbFreqtable add radiobutton -variable choice(mbFreqtable) -label $freqtable
				}
				set ::choice(mbFreqtable) $::option(frequency_table)
				set ::choice(mbVideo_standard) $::option(video_standard)
				set ::choice(cb_video_standard) $::option(forcevideo_standard)
				if {[info exists ::choice(mbVideo)]} {
					catch {exec v4l2-ctl --device=$::choice(mbVideo) -l} read_v4l2ctl
					set status_videobitrate [catch {agrep -w "$read_v4l2ctl" video_bitrate} resultat_videobitrate]
					if {$status_videobitrate == 0} {
						log_writeOutTv 0 "Will be able to handle videobitrate."
						array set videobitrate [split [string trim $resultat_videobitrate] { =}]
						$w2.s_lf_videobitrate configure -from $videobitrate(min) -to [expr ($videobitrate(max) / 8) / 1024]
						set ::analog(vbit) $videobitrate(max)
					} else {
						log_writeOutTv 2 "Videobitrate can't be set for $::choice(mbVideo)."
						$w2.cb_lf_streambitrate state !disabled
						$w2.l_lf_videobitrate state disabled
						$w2.s_lf_videobitrate state disabled
						$w2.e_lf_videobitrate_value state disabled
						$w2.l_lf_videopeakbitrate state disabled
						$w2.s_lf_videopeakbitrate state disabled
						$w2.e_lf_videopeakbitrate_value state disabled
					}
				}
				if {[info exists ::option(videobitrate)]} {
					set ::choice(scale_videobitrate) $::option(videobitrate)
					set ::choice(entry_vbitrate_value) $::option(videobitrate)
				} else {
					catch {set ::choice(scale_videobitrate) [expr ($videobitrate(default) / 8) / 1024]}
					catch {set ::choice(entry_vbitrate_value) [expr ($videobitrate(default) / 8) / 1024]}
				}
				if {[info exists ::choice(mbVideo)]} {
					catch {exec v4l2-ctl --device=$::choice(mbVideo) -l} read_v4l2ctl
					set status_peakbitrate [catch {agrep -w "$read_v4l2ctl" video_peak_bitrate} resultat_peakbitrate]
					if {$status_peakbitrate == 0} {
						log_writeOutTv 0 "Will be able to handle videobitrate_peak."
						array set peakbitrate [split [string trim $resultat_peakbitrate] { =}]
						$w2.s_lf_videopeakbitrate configure -from $peakbitrate(min) -to [expr ($peakbitrate(max) / 8) / 1024]
						set ::analog(vbitp) $peakbitrate(max)
					} else {
						log_writeOutTv 2 "Videobitrate_peak can't be set for $::choice(mbVideo)."
						$w2.cb_lf_streambitrate state disabled
						$w2.l_lf_videobitrate state disabled
						$w2.s_lf_videobitrate state disabled
						$w2.e_lf_videobitrate_value state disabled
						$w2.l_lf_videopeakbitrate state disabled
						$w2.s_lf_videopeakbitrate state disabled
						$w2.e_lf_videopeakbitrate_value state disabled
					}
				}
				if {[info exists ::option(videopeakbitrate)]} {
					set ::choice(scale_videopeakbitrate) $::option(videopeakbitrate)
					set ::choice(entry_pbitrate_value) $::option(videopeakbitrate)
				} else {
					catch {set ::choice(scale_videopeakbitrate) [expr ($peakbitrate(default) / 8) / 1024]}
					catch {set ::choice(entry_pbitrate_value) [expr ($peakbitrate(default) / 8) / 1024]}
				}
				if {[info exists ::choice(mbVideo)]} {
					catch {exec v4l2-ctl --device=$::choice(mbVideo) -l} read_v4l2ctl
					set status_temporal [catch {agrep -w "$read_v4l2ctl" temporal_filter} resultat_temporal]
					if {$status_temporal == 0} {
						log_writeOutTv 0 "Will be able to handle temporal filter."
						array set temporal [split [string trim $resultat_temporal] { =}]
						$w2.sb_lf_temporal configure -from $temporal(min) -to $temporal(max)
					} else {
						log_writeOutTv 2 "Temporal Filter can't be set for $::choice(mbVideo)."
						$w2.cb_lf_temporal state disabled
						$w2.l_lf_temporal state disabled
						$w2.sb_lf_temporal configure -state disabled
					}
				}
				if {[info exists ::option(temporal_filter_value)]} {
					set ::choice(spinbox_temporal) $::option(temporal_filter_value)
				} else {
					catch {set ::choice(spinbox_temporal) $temporal(default)}
				}
				if {[info exists ::choice(mbVideo)]} {
					catch {exec v4l2-ctl --device=$::choice(mbVideo) -l} read_v4l2ctl
					set status_volume [catch {agrep -w "$read_v4l2ctl" volume} resultat_volume]
					if {$status_volume == 0} {
						log_writeOutTv 0 "Will be able to handle volume."
						array set volume [split [string trim $resultat_volume] { =}]
						$w2.s_audio_v4l2 configure -from $volume(min) -to $volume(max)
						set ::choice(scale_recordvolume_mult) [expr $volume(max) / 100]
					} else {
						log_writeOutTv 2 "Can't change volume for $::choice(mbVideo)."
						$w2.cb_audio_v4l2 state disabled
						$w2.l_audio_v4l2 state disabled
						$w2.s_audio_v4l2 state disabled
						$w2.l_audio_v4l2_val state disabled
					}
				}
				if {[info exists ::option(audio_v4l2_value)]} {
					catch {$w2.s_audio_v4l2 configure -value [expr $::option(audio_v4l2_value) * $::choice(scale_recordvolume_mult)]}
					catch {config_analog_audioScale "[expr round($::option(audio_v4l2_value) * $::choice(scale_recordvolume_mult))].0"}
				} else {
					catch {$w2.s_audio_v4l2 configure -value $volume(default)}
					catch {config_analog_audioScale "$volume(default).0"}
				}
				
				if {$::option(tooltips) == 1} {
					if {$::option(tooltips_wizard) == 1} {
						settooltip $::window(analog_nb1).lf_mb_video_device [mc "Choose the video device node.
See \"dmesg | grep ivtv || pvrusb2 || cx18\""]
						settooltip $::window(analog_nb1).cb_lf_video_standard [mc "Constrain setting of the video standard.
Choose this if the driver selects the wrong one."]
						settooltip $::window(analog_nb1).mb_lf_video_standard [mc "Define the way of color transmission.
Depends on where you are located."]
						settooltip $::window(analog_nb1).mb_lf_freqtable [mc "The frequency table provides informations about the 
frequency band that should be used to search for tv stations."]
						settooltip $::window(analog_nb1).mb_lf_video_input [mc "Choose the video input"]
						settooltip $::window(analog_nb2).cb_lf_streambitrate [mc "Check this if you want to alter the videobitrate"]
						settooltip $::window(analog_nb2).s_lf_videobitrate [mc "Define the videobitrate. Don't set the
videobitrate to a higher value than videobitrate (peak)!
Standard values are recommended.
Data in kb/sec."]
						settooltip $::window(analog_nb2).e_lf_videobitrate_value [mc "Define the videobitrate. Don't set the
videobitrate to a higher value than videobitrate (peak)!
Standard values are recommended.
Data in kb/sec."]
						settooltip $::window(analog_nb2).s_lf_videopeakbitrate [mc "Define the videobitrate (peak). Don't set the 
videobitrate (peak) to a lower value than videobitrate.
Standard values are recommended.
Data in kb/sec."]
						settooltip $::window(analog_nb2).e_lf_videopeakbitrate_value [mc "Define the videobitrate (peak). Don't set the 
videobitrate (peak) to a lower value than videobitrate.
Standard values are recommended.
Data in kb/sec."]
						settooltip $::window(analog_nb2).cb_lf_temporal [mc "Check this if you want to change the temporal filter.
This option can help if you have a blurred picture."]
						settooltip $::window(analog_nb2).sb_lf_temporal [mc "Choose level of temporal filtering"]
						settooltip $::window(analog_nb2).cb_audio_v4l2 [mc "Enable this option if you want to change the hardware volume level."]
						settooltip $::window(analog_nb2).s_audio_v4l2 [mc "Specify the hardware volume level.
This applies to all stations and it is not recommended
to change this value."]
					} else {
						settooltip $::window(analog_nb1).lf_mb_video_device {}
						settooltip $::window(analog_nb1).cb_lf_video_standard {}
						settooltip $::window(analog_nb1).mb_lf_video_standard {}
						settooltip $::window(analog_nb1).mb_lf_freqtable {}
						settooltip $::window(analog_nb1).mb_lf_video_input {}
						settooltip $::window(analog_nb2).cb_lf_streambitrate {}
						settooltip $::window(analog_nb2).s_lf_videobitrate {}
						settooltip $::window(analog_nb2).e_lf_videobitrate_value {}
						settooltip $::window(analog_nb2).s_lf_videopeakbitrate {}
						settooltip $::window(analog_nb2).e_lf_videopeakbitrate_value {}
						settooltip $::window(analog_nb2).cb_lf_temporal {}
						settooltip $::window(analog_nb2).sb_lf_temporal {}
						settooltip $::window(analog_nb2).cb_audio_v4l2 {}
						settooltip $::window(analog_nb2).s_audio_v4l2 {}
					}
				}
			}
			proc default_com1 {w1 w2} {
				#Find and set values for analog section after changing device node.
				puts $::main(debug_msg) "\033\[0;1;33mDebug: default_com1 \033\[0m \{$w1\} \{$w2\}"
				log_writeOutTv 1 "Changing video device node, need to reread some options."
				catch {
					$w1.mbVideo_input delete 0 end
				}
				catch {exec v4l2-ctl --device=$::choice(mbVideo) -n} read_vidinputs
				set status_vid_inputs [catch {agrep -w "$read_vidinputs" Name} resultat_vid_inputs]
				if {$status_vid_inputs == 0} {
					set i 1
					foreach vi [split $resultat_vid_inputs \n] {
						$w1.mbVideo_input add radiobutton \
						-variable choice(mbVideo_input) \
						-label "[string trimleft [string range $vi [string first : $vi] end] {: }]" \
						-command [list config_analog_optScrInput [expr $i - 1]]
						set vinput($i) "[string trimleft [string range $vi [string first : $vi] end] {: }]"
						log_writeOutTv 0 "Found video input: $vinput($i)"
						incr i
					}
					$w1.lf_video_input state !disabled
					$w1.mb_lf_video_input state !disabled
				} else {
					$w1.lf_video_input state disabled
					$w1.mb_lf_video_input state disabled
				}
				catch {set ::choice(mbVideo_input) [$w1.mbVideo_input entrycget 0 -label]}
				catch {exec v4l2-ctl --device=$::choice(mbVideo) -l} read_v4l2ctl
				set status_videobitrate [catch {agrep -w "$read_v4l2ctl" video_bitrate} resultat_videobitrate]
				if {$status_videobitrate == 0} {
					log_writeOutTv 0 "Will be able to handle videobitrate."
					array set videobitrate [split [string trim $resultat_videobitrate] { =}]
					$w2.s_lf_videobitrate configure -from $videobitrate(min) -to [expr ($videobitrate(max) / 8) / 1024]
					set ::analog(vbit) $videobitrate(max)
					$w2.cb_lf_streambitrate state !disabled
					if {$::choice(cb_streambitrate) == 1} {
						$w2.l_lf_videobitrate state !disabled
						$w2.s_lf_videobitrate state !disabled
						$w2.e_lf_videobitrate_value state !disabled
						$w2.l_lf_videopeakbitrate state !disabled
						$w2.s_lf_videopeakbitrate state !disabled
						$w2.e_lf_videopeakbitrate_value state !disabled
					}
				} else {
					log_writeOutTv 0 "Videobitrate can't be set for $::choice(mbVideo)."
					$w2.cb_lf_streambitrate state disabled
					$w2.l_lf_videobitrate state disabled
					$w2.s_lf_videobitrate state disabled
					$w2.e_lf_videobitrate_value state disabled
					$w2.l_lf_videopeakbitrate state disabled
					$w2.s_lf_videopeakbitrate state disabled
					$w2.e_lf_videopeakbitrate_value state disabled
				}
				catch {set ::choice(scale_videobitrate) [expr ($videobitrate(default) / 8) / 1024]}
				catch {set ::choice(entry_vbitrate_value) [expr ($videobitrate(default) / 8) / 1024]}
				catch {exec v4l2-ctl --device=$::choice(mbVideo) -l} read_v4l2ctl
				set status_peakbitrate [catch {agrep -w "$read_v4l2ctl" video_peak_bitrate} resultat_peakbitrate]
				if {$status_peakbitrate == 0} {
					log_writeOutTv 0 "Will be able to handle videobitrate_peak."
					array set peakbitrate [split [string trim $resultat_peakbitrate] { =}]
					$w2.s_lf_videopeakbitrate configure -from $peakbitrate(min) -to [expr ($peakbitrate(max) / 8) / 1024]
					set ::analog(vbitp) $peakbitrate(max)
						$w2.cb_lf_streambitrate state !disabled
					if {$::choice(cb_streambitrate) == 1} {
						$w2.l_lf_videobitrate state !disabled
						$w2.s_lf_videobitrate state !disabled
						$w2.e_lf_videobitrate_value state !disabled
						$w2.l_lf_videopeakbitrate state !disabled
						$w2.s_lf_videopeakbitrate state !disabled
						$w2.e_lf_videopeakbitrate_value state !disabled
					}
				} else {
					log_writeOutTv 2 "Videobitrate_peak can't be set for $::choice(mbVideo)."
					$w2.cb_lf_streambitrate state disabled
					$w2.l_lf_videobitrate state disabled
					$w2.s_lf_videobitrate state disabled
					$w2.e_lf_videobitrate_value state disabled
					$w2.l_lf_videopeakbitrate state disabled
					$w2.s_lf_videopeakbitrate state disabled
					$w2.e_lf_videopeakbitrate_value state disabled
				}
				catch {set ::choice(scale_videopeakbitrate) [expr ($peakbitrate(default) / 8) / 1024]}
				catch {set ::choice(entry_pbitrate_value) [expr ($peakbitrate(default) / 8) / 1024]}
				catch {exec v4l2-ctl --device=$::choice(mbVideo) -l} read_v4l2ctl
				set status_temporal [catch {agrep -w "$read_v4l2ctl" temporal_filter} resultat_temporal]
				if {$status_temporal == 0} {
					log_writeOutTv 0 "Will be able to handle temporal filter."
					array set temporal [split [string trim $resultat_temporal] { =}]
					$w2.sb_lf_temporal configure -from $temporal(min) -to $temporal(max)
					$w2.cb_lf_temporal state !disabled
					if {$::choice(cb_temporal) == 1} {
						$w2.l_lf_temporal state !disabled
						$w2.sb_lf_temporal configure -state normal
					}
				} else {
					log_writeOutTv 2 "Temporal Filter can't be set for $::choice(mbVideo)."
					$w2.cb_lf_temporal state disabled
					$w2.l_lf_temporal state disabled
					$w2.sb_lf_temporal configure -state disabled
				}
				catch {set ::choice(spinbox_temporal) $temporal(default)}
				if {[info exists ::choice(mbVideo)]} {
					catch {exec v4l2-ctl --device=$::choice(mbVideo) -l} read_v4l2ctl
					set status_volume [catch {agrep -w "$read_v4l2ctl" volume} resultat_volume]
					if {$status_volume == 0} {
						log_writeOutTv 0 "Will be able to handle volume."
						array set volume [split [string trim $resultat_volume] { =}]
						$w2.s_audio_v4l2 configure -from $volume(min) -to $volume(max)
						set ::choice(scale_recordvolume_mult) [expr $volume(max) / 100]
						$w2.cb_audio_v4l2 state !disabled
						if {$::choice(cb_audio_v4l2) == 1} {
							$w2.l_audio_v4l2 state !disabled
							$w2.s_audio_v4l2 state !disabled
							$w2.l_audio_v4l2_val state !disabled
						}
					} else {
						log_writeOutTv 0 "Can't change volume for $::choice(mbVideo)."
						$w2.cb_audio_v4l2 state disabled
						$w2.l_audio_v4l2 state disabled
						$w2.s_audio_v4l2 state disabled
						$w2.l_audio_v4l2_val state disabled
					}
				}
				catch {$w2.s_audio_v4l2 configure -value $volume(default)}
				catch {config_analog_audioScale "$volume(default).0"}
			}
			
			proc stnd_opt1 {w1 w2} {
				#Setting defaults for analog section 
				puts $::main(debug_msg) "\033\[0;1;33mDebug: stnd_opt1 \033\[0m \{$w1\} \{$w2\}"
				catch {
					$w1.mbVideo_input delete 0 end
				}
				log_writeOutTv 0 "Setting analog options to default."
				catch {set ::choice(mbVideo) [$w1.mbVideo_device entrycget 0 -label]}
				set ::choice(mbFreqtable) $::stnd_opt(frequency_table)
				set ::choice(mbVideo_standard) $::stnd_opt(video_standard)
				set ::choice(cb_video_standard) $::stnd_opt(forcevideo_standard)
				set ::choice(cb_streambitrate) $::stnd_opt(streambitrate)
				set ::choice(cb_temporal) $::stnd_opt(temporal_filter)
				set ::choice(cb_audio_v4l2) $::stnd_opt(audio_v4l2)
				config_analogStreambitrate $::window(analog_nb2)
				config_analogTemporal $::window(analog_nb2)
				config_analog_audioV4l2
				
				if {[info exists ::choice(mbVideo)]} {
					catch {exec v4l2-ctl --device=$::choice(mbVideo) -n} read_vidinputs
					set status_vid_inputs [catch {agrep -w "$read_vidinputs" Name} resultat_vid_inputs]
					if {$status_vid_inputs == 0} {
						set i 1
						foreach vi [split $resultat_vid_inputs \n] {
							$w1.mbVideo_input add radiobutton -variable choice(mbVideo_input) -label "[string trimleft [string range $vi [string first : $vi] end] {: }]" -command [list config_analog_optScrInput [expr $i - 1]]
							set vinput($i) "[string trimleft [string range $vi [string first : $vi] end] {: }]"
							incr i
						}
						$w1.lf_video_input state !disabled
						$w1.mb_lf_video_input state !disabled
					} else {
						$w1.lf_video_input state disabled
						$w1.mb_lf_video_input state disabled
					}
					catch {set ::choice(mbVideo_input) [$w1.mbVideo_input entrycget 0 -label]}
				}
				
				if {[info exists ::choice(mbVideo)]} {
					catch {exec v4l2-ctl --device=$::choice(mbVideo) -l} read_v4l2ctl
					set status_videobitrate [catch {agrep -w "$read_v4l2ctl" video_bitrate} resultat_videobitrate]
					if {$status_videobitrate == 0} {
						array set videobitrate [split [string trim $resultat_videobitrate] { =}]
						$w2.s_lf_videobitrate configure -from $videobitrate(min) -to [expr ($videobitrate(max) / 8) / 1024]
						set ::analog(vbit) $videobitrate(max)
						$w2.cb_lf_streambitrate state !disabled
					} else {
						$w2.cb_lf_streambitrate state disabled
						$w2.l_lf_videobitrate state disabled
						$w2.s_lf_videobitrate state disabled
						$w2.e_lf_videobitrate_value state disabled
						$w2.l_lf_videopeakbitrate state disabled
						$w2.s_lf_videopeakbitrate state disabled
						$w2.e_lf_videopeakbitrate_value state disabled
					}
				}
				catch {set ::choice(scale_videobitrate) [expr ($videobitrate(default) / 8) / 1024]}
				catch {set ::choice(entry_vbitrate_value) [expr ($videobitrate(default) / 8) / 1024]}
				
				if {[info exists ::choice(mbVideo)]} {
					catch {exec v4l2-ctl --device=$::choice(mbVideo) -l} read_v4l2ctl
					set status_peakbitrate [catch {agrep -w "$read_v4l2ctl" video_peak_bitrate} resultat_peakbitrate]
					if {$status_peakbitrate == 0} {
						array set peakbitrate [split [string trim $resultat_peakbitrate] { =}]
						$w2.s_lf_videopeakbitrate configure -from $peakbitrate(min) -to [expr ( $peakbitrate(max) / 8) / 1024]
						set ::analog(vbitp) $peakbitrate(max)
						$w2.cb_lf_streambitrate state !disabled
					} else {
						$w2.cb_lf_streambitrate state disabled
						$w2.l_lf_videobitrate state disabled
						$w2.s_lf_videobitrate state disabled
						$w2.e_lf_videobitrate_value state disabled
						$w2.l_lf_videopeakbitrate state disabled
						$w2.s_lf_videopeakbitrate state disabled
						$w2.e_lf_videopeakbitrate_value state disabled
					}
				}
				catch {set ::choice(scale_videopeakbitrate) [expr ($peakbitrate(default) / 8) / 1024]}
				catch {set ::choice(entry_pbitrate_value) [expr ($peakbitrate(default) / 8) / 1024]}
				
				if {[info exists ::choice(mbVideo)]} {
					catch {exec v4l2-ctl --device=$::choice(mbVideo) -l} read_v4l2ctl
					set status_temporal [catch {agrep -w "$read_v4l2ctl" temporal_filter} resultat_temporal]
					if {$status_temporal == 0} {
						array set temporal [split [string trim $resultat_temporal] { =}]
						$w2.sb_lf_temporal configure -from $temporal(min) -to $temporal(max)
						$w2.cb_lf_temporal state !disabled
					} else {
						$w2.cb_lf_temporal state disabled
						$w2.l_lf_temporal state disabled
						$w2.sb_lf_temporal configure -state disabled
					}
				}
				catch {set ::choice(spinbox_temporal) $temporal(default)}
				
				if {[info exists ::choice(mbVideo)]} {
					catch {exec v4l2-ctl --device=$::choice(mbVideo) -l} read_v4l2ctl
					set status_volume [catch {agrep -w "$read_v4l2ctl" volume} resultat_volume]
					if {$status_volume == 0} {
						array set volume [split [string trim $resultat_volume] { =}]
						$w2.s_audio_v4l2 configure -from $volume(min) -to $volume(max)
						set ::choice(scale_recordvolume_mult) [expr $volume(max) / 100]
						$w2.cb_audio_v4l2 state !disabled
					} else {
						$w2.cb_audio_v4l2 state disabled
						$w2.l_audio_v4l2 state disabled
						$w2.s_audio_v4l2 state disabled
						$w2.l_audio_v4l2_val state disabled
					}
				}
				catch {$w2.s_audio_v4l2 configure -value $volume(default)}
				catch {config_analog_audioScale "$volume(default).0"}
			}
			set ::choice(cb_streambitrate) $::option(streambitrate)
			config_analogStreambitrate $::window(analog_nb2)
			set ::choice(cb_temporal) $::option(temporal_filter)
			config_analogTemporal $::window(analog_nb2)
			set ::choice(cb_audio_v4l2) $::option(audio_v4l2)
			config_analog_audioV4l2
			
			default_opt1 $::window(analog_nb1) $::window(analog_nb2)
		}
	}
}
