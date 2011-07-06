#       config_audio.tcl
#       © Copyright 2007-2011 Christian Rapp <christianrapp@users.sourceforge.net>
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

proc option_screen_4 {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: option_screen_4 \033\[0m"
	
	# Setting up the interface
	# audio section for the preferences
	
	foreach tab [split [.config_wizard.frame_configoptions.nb tabs]] {
		.config_wizard.frame_configoptions.nb hide $tab
	}
	
	if {[winfo exists .config_wizard.frame_configoptions.nb.f_audio]} {
		.config_wizard.frame_configoptions.nb add $::window(audio_nb1)
		.config_wizard.frame_configoptions.nb select $::window(audio_nb1)
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt4 $::window(audio_nb1)]
	} else {
		log_writeOut ::log(tvAppend) 0 "Setting up audio section in preferences"
		set w .config_wizard.frame_configoptions.nb
		set ::window(audio_nb1) [ttk::frame $w.f_audio]
		$w add $::window(audio_nb1) -text [mc "Audio Settings"] -padding 2
		ttk::labelframe $::window(audio_nb1).lf_audio_stnd -text [mc "Audio Settings"]
		set lf_audioStnd $::window(audio_nb1).lf_audio_stnd
		ttk::label $lf_audioStnd.l_audio -text [mc "Audio output driver"]
		ttk::menubutton $lf_audioStnd.mb_audio -menu $::window(audio_nb1).mbAudio -textvariable choice(mbAudio)
		menu $::window(audio_nb1).mbAudio -tearoff 0
		ttk::label $lf_audioStnd.l_channels -text [mc "Audio channels"]
		ttk::menubutton $lf_audioStnd.mb_channels -menu $::window(audio_nb1).mbAudio_channels -textvariable choice(mbAudio_channels)
		menu $::window(audio_nb1).mbAudio_channels -tearoff 0
		ttk::checkbutton $lf_audioStnd.cb_softvol -text [mc "Use software mixer"] -variable choice(cb_softvol)
		ttk::checkbutton $lf_audioStnd.cb_remAudio -text [mc "Remember volume level"] -variable choice(cb_remAdio)
		
		set lf_audioSync $::window(audio_nb1).lf_audio_sync
		ttk::labelframe $::window(audio_nb1).lf_audio_sync -text [mc "Audio synchronization"]
		ttk::checkbutton $lf_audioSync.cb_audautosync -text [mc "Auto synchronization"] -variable choice(cb_audautosync)
		ttk::label $lf_audioSync.l_auddelay -text [mc "Audio/Video sync correction"]
		spinbox $lf_audioSync.sb_auddelay -from -2 -to 2 -increment 0.1 -state readonly -textvariable choice(sb_auddelay)
		
		grid columnconfigure $::window(audio_nb1) 0 -weight 1
		grid columnconfigure $::window(audio_nb1).lf_audio_stnd 1 -minsize 120
		
		grid $lf_audioStnd -in $::window(audio_nb1) -row 0 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $lf_audioStnd.l_audio -in $lf_audioStnd -row 0 -column 0 -sticky w -padx 7 -pady 3
		grid $lf_audioStnd.mb_audio -in $lf_audioStnd -row 0 -column 1 -sticky ew -pady 3
		grid $lf_audioStnd.l_channels -in $lf_audioStnd -row 1 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $lf_audioStnd.mb_channels -in $lf_audioStnd -row 1 -column 1 -sticky ew -pady "0 3"
		grid $lf_audioStnd.cb_softvol -in $lf_audioStnd -row 2 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $lf_audioStnd.cb_remAudio -in $lf_audioStnd -row 3 -column 0 -sticky w -padx 7 -pady "0 3"
		
		grid $lf_audioSync -in $::window(audio_nb1) -row 1 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $lf_audioSync.cb_audautosync -in $lf_audioSync -row 0 -column 0 -sticky w -padx 7 -pady 3
		grid $lf_audioSync.l_auddelay -in $lf_audioSync -row 1 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $lf_audioSync.sb_auddelay -in $lf_audioSync -row 1 -column 1 -pady "0 3"
		
		#Additional Code
		
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt4 $::window(audio_nb1)]
		
		#Subprocs
		
		proc default_opt4 {w} {
			#Find and set values for audio section 
			puts $::main(debug_msg) "\033\[0;1;33mDebug: default_opt4 \033\[0m \{$w\}"
			log_writeOut ::log(tvAppend) 0 "Starting to collect data for audio section."
			set lf_audioStnd $::window(audio_nb1).lf_audio_stnd
			set lf_audioSync $::window(audio_nb1).lf_audio_sync
			catch {exec [auto_execok mplayer] -noconfig all -ao help} audio_out
			if {[string trim $audio_out] != {}} {
				foreach line [split $audio_out \n] {
					if {[string is lower [lindex $line 0]]} {
						if {[string match *child* [string trim [lindex $line 0]]] || [string trim $line] == {}} continue
						log_writeOut ::log(tvAppend) 0 "Found audio ouput driver [string trim [lindex $line 0]]"
						$w.mbAudio add radiobutton \
						-label [string trim [lindex $line 0]] \
						-variable choice(mbAudio)
						if {[string match alsa [string trim [lindex $line 0]]]} {
							if {[file exists /proc/asound/pcm]} {
								set open_alsa [open /proc/asound/pcm r]
								set alsa_dev [read $open_alsa]
								close $open_alsa
								set alsadev_status [catch {agrep -m "$alsa_dev" playback} resultat_alsadev] 
								if {$alsadev_status == 0} {
									set i 1
									foreach line [split $resultat_alsadev \n] {
										set device($i) "$line"
										set first [expr [string first : $device($i)] + 1]
										set second [expr [string first : $device($i) $first] - 1]
										set device_name($i) "[string trim [string range $device($i) $first $second]]"
										set devices_max $i
										incr i
									}
									for {set i 1} {$i <= $devices_max} {incr i} {
										set ident [string trimright [lindex $device($i) 0] ":"]
										foreach char [split $ident "-"] {
											set char [scan $char %d]
											if {[info exists alsa_hw]} {
												append alsa_hw ".$char"
											} else {
												append alsa_hw $char
											}
										}
										log_writeOut ::log(tvAppend) 0 "Found alsa hardware device $alsa_hw $device_name($i)"
										set device_ident($i) "$alsa_hw $device_name($i)"
										$w.mbAudio add radiobutton \
										-label "alsa $device_ident($i)" \
										-variable choice(mbAudio)
										unset -nocomplain alsa_hw
									}
								} else {
									log_writeOut ::log(tvAppend) 2 "Can't detect alsa hardware devices"
									log_writeOut ::log(tvAppend) 2 "Error message: $resultat_alsadev"
								}
							} else {
								log_writeOut ::log(tvAppend) 2 "Can't detect alsa hardware devices. There is no file /proc/asound/pcm"
							}
						}
					}
				}
				set max_mbentries [$w.mbAudio index end]
				set alsa_found 0
				if {$max_mbentries < 1} {
					for {set i 0} {$i <= $max_mbentries} {incr i} {
						if {[string trim [$w.mbAudio entrycget $i -label]] == "alsa"} {
							set alsa_found 1
						}
					}
				}
				if {$alsa_found == 0} {
					log_writeOut ::log(tvAppend) 1 "MPlayer did not report back alsa as audio output driver."
				}
			} else {
				$::window(audio_nb1).mb_lf_audio state disabled
				log_writeOut ::log(tvAppend) 2 "MPlayer did not report audio ouput drivers. Deactivating menubutton."
			}
			
			if {[info exists ::option(player_audio)]} {
				set ::choice(mbAudio) $::option(player_audio)
			} else {
				set ::choice(mbAudio) $::stnd_opt(player_audio)
			}
			
			set audio_channels {{2 (Stereo)} {4 (4.0 Surround)} {6 (5.1 Surround)}}
			foreach ac $audio_channels {
				$::window(audio_nb1).mbAudio_channels add radiobutton \
				-label $ac \
				-variable choice(mbAudio_channels)
			}
			
			if {[info exists ::option(player_audio_channels)]} {
				set ::choice(mbAudio_channels) $::option(player_audio_channels)
			} else {
				set ::choice(mbAudio_channels) $::stnd_opt(player_audio_channels)
			}
			
			if {[info exists ::option(player_aud_softvol)]} {
				set ::choice(cb_softvol) $::option(player_aud_softvol)
			} else {
				set ::choice(cb_softvol) $::stnd_opt(player_aud_softvol)
			}
			
			if {[info exists ::option(player_audio_autosync)]} {
				set ::choice(cb_audautosync) $::option(player_audio_autosync)
			} else {
				set ::choice(cb_audautosync) $::stnd_opt(player_audio_autosync)
			}
			
			if {[info exists ::option(player_audio_delay)]} {
				set ::choice(sb_auddelay) $::option(player_audio_delay)
			} else {
				set ::choice(sb_auddelay) $::stnd_opt(player_audio_delay)
			}
			set ::choice(cb_remAdio) $::option(volRem)
			
			if {$::option(tooltips) == 1} {
				if {$::option(tooltips_wizard) == 1} {
					settooltip $lf_audioStnd.mb_audio [mc "Choose an audio output driver, alsa is recommended."]
					settooltip $lf_audioStnd.cb_softvol [mc "Check this option to use the software mixer,
instead of the hardware mixer."]
					settooltip $lf_audioStnd.mb_channels [mc "This option tells MPlayer to decode
audio to the chosen value"]
					settooltip $lf_audioStnd.cb_remAudio [mc "Remeber volume level"]
					settooltip $lf_audioSync.cb_audautosync [mc "Gradually adjusts the A/V sync based on audio delay measurements"]
					settooltip $lf_audioSync.sb_auddelay [mc "Audio/Video sync correction per frame in seconds"]
				} else {
					settooltip $lf_audioStnd.mb_audio {}
					settooltip $lf_audioStnd.cb_softvol {}
					settooltip $lf_audioStnd.mb_channels {}
					settooltip $lf_audioStnd.cb_remAudio {}
					settooltip $lf_audioSync.cb_audautosync {}
					settooltip $lf_audioSync.sb_auddelay {}
				}
			}
		}
		proc stnd_opt4 {w} {
			#Setting defaults for audio section 
			puts $::main(debug_msg) "\033\[0;1;33mDebug: stnd_opt4 \033\[0m \{$w\}"
			log_writeOut ::log(tvAppend) 1 "Setting audio options to default."
			set lf_audioStnd $::window(audio_nb1).lf_audio_stnd
			set lf_audioSync $::window(audio_nb1).lf_audio_sync
			set ::choice(mbAudio) $::stnd_opt(player_audio)
			set ::choice(cb_softvol) $::stnd_opt(player_aud_softvol)
			set ::choice(mbAudio_channels) $::stnd_opt(player_audio_channels)
			set ::choice(cb_remAdio) $::stnd_opt(volRem)
			set ::choice(cb_audautosync) $::stnd_opt(player_audio_autosync)
			set ::choice(sb_auddelay) $::stnd_opt(player_audio_delay)
		}
		default_opt4 $::window(audio_nb1)
	}
}
