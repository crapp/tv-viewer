#       config_audio.tcl
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

proc option_screen_4 {} {
	
	# Setting up the interface
	
	foreach tab [split [.config_wizard.frame_configoptions.nb tabs]] {
		.config_wizard.frame_configoptions.nb hide $tab
	}
	
	if {[winfo exists .config_wizard.frame_configoptions.nb.f_audio]} {
		.config_wizard.frame_configoptions.nb add $::window(audio_nb1)
		.config_wizard.frame_configoptions.nb select $::window(audio_nb1)
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt4 $::window(audio_nb1)]
	} else {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting up audio section in preferences"
		flush $::logf_tv_open_append
		set w .config_wizard.frame_configoptions.nb
		set ::window(audio_nb1) [ttk::frame $w.f_audio]
		$w add $::window(audio_nb1) -text [mc "Audio Settings"] -padding 2
		ttk::labelframe $::window(audio_nb1).lf_audio_stnd \
		-text [mc "Audio Settings"]
		ttk::label $::window(audio_nb1).l_lf_audio \
		-text [mc "Audio output driver"]
		ttk::menubutton $::window(audio_nb1).mb_lf_audio \
		-menu $::window(audio_nb1).mbAudio \
		-textvariable choice(mbAudio)
		menu $::window(audio_nb1).mbAudio \
		-tearoff 0 \
		-background $::option(theme_$::option(use_theme))
		ttk::label $::window(audio_nb1).l_lf_channels \
		-text [mc "Audio channels"]
		ttk::menubutton $::window(audio_nb1).mb_lf_channels \
		-menu $::window(audio_nb1).mbAudio_channels \
		-textvariable choice(mbAudio_channels)
		menu $::window(audio_nb1).mbAudio_channels \
		-tearoff 0 \
		-background $::option(theme_$::option(use_theme))
		ttk::checkbutton $::window(audio_nb1).cb_lf_softvol \
		-text [mc "Use software mixer"] \
		-variable choice(cb_softvol)
		
		grid columnconfigure $::window(audio_nb1) 0 -weight 1
		grid columnconfigure $::window(audio_nb1).lf_audio_stnd 1 -minsize 120
		
		grid $::window(audio_nb1).lf_audio_stnd -in $::window(audio_nb1) -row 0 -column 0 \
		-sticky ew \
		-padx 5 \
		-pady "5 0"
		grid $::window(audio_nb1).l_lf_audio -in $::window(audio_nb1).lf_audio_stnd -row 0 -column 0 \
		-sticky w \
		-padx 7 \
		-pady 3
		grid $::window(audio_nb1).mb_lf_audio -in $::window(audio_nb1).lf_audio_stnd -row 0 -column 1 \
		-sticky ew \
		-pady 3
		grid $::window(audio_nb1).l_lf_channels -in $::window(audio_nb1).lf_audio_stnd -row 1 -column 0 \
		-sticky w \
		-padx 7 \
		-pady "0 3"
		grid $::window(audio_nb1).mb_lf_channels -in $::window(audio_nb1).lf_audio_stnd -row 1 -column 1 \
		-sticky ew \
		-pady "0 3"
		grid $::window(audio_nb1).cb_lf_softvol -in $::window(audio_nb1).lf_audio_stnd -row 2 -column 0 \
		-padx 7 \
		-pady "0 3"
		
		#Additional Code
		
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt4 $::window(audio_nb1)]
		
		#Subprocs
		
		proc default_opt4 {w} {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Starting to collect data for audio section."
			flush $::logf_tv_open_append
			set audio {oss alsa pulse sdl}
			foreach aelem [split $audio] {
				$w.mbAudio add radiobutton \
				-label $aelem \
				-variable choice(mbAudio)
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
			if {$::option(tooltips) == 1} {
				if {$::option(tooltips_wizard) == 1} {
					settooltip $::window(audio_nb1).mb_lf_audio [mc "Choose an audio output driver, alsa is recommended."]
					settooltip $::window(audio_nb1).cb_lf_softvol [mc "Check this option to use the software mixer,
instead of the hardware mixer."]
					settooltip $::window(audio_nb1).mb_lf_channels [mc "This option is used by MPlayer so the audio is decoded
to the chosen value."]
				} else {
					settooltip $::window(audio_nb1).mb_lf_audio {}
					settooltip $::window(audio_nb1).cb_lf_softvol {}
					settooltip $::window(audio_nb1).mb_lf_channels {}
				}
			}
		}
		proc stnd_opt4 {w} {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting audio options to default."
			flush $::logf_tv_open_append
			set ::choice(mbAudio) $::stnd_opt(player_audio)
			set ::choice(cb_softvol) $::stnd_opt(player_aud_softvol)
			set ::choice(mbAudio_channels) $::stnd_opt(player_audio_channels)
		}
		default_opt4 $::window(audio_nb1)
	}
}
