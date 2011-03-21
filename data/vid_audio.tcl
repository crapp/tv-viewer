#       vid_audio.tcl
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

proc vid_audioVolumeControl {vscale vbutton value} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_audioVolumeControl \033\[0m \{$vscale\} \{$vbutton\} \{$value\}"
	set status_vid_Playback [vid_callbackMplayerRemote alive]
	if {$status_vid_Playback != 1} {
		if {"$value" != "mute"} {
			if {[$vscale instate disabled] == 1} {return}
			set value [expr int($value)]
			if {$value > 100} {
				set value 100
				#return
			}
			if {$value < 0} {
				set value 0
				#return
			}
			if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
				after 0 [list vid_osd osd_group_w 1000 "Volume $value"]
			}
			if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
				after 0 [list vid_osd osd_group_f 1000 "Volume $value"]
			}
			
			set ::main(volume_scale) $value
			vid_callbackMplayerRemote "volume [expr int($value)] 1"
		} else {
			if {[$vscale instate disabled] == 0} {
				set ::volume(mute_old_value) "$::main(volume_scale)"
				set ::main(volume_scale) 0
				$vscale state disabled
				$vbutton configure -image $::icon_m(volume-error)
				if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
					after 0 [list vid_osd osd_group_w 1000 [mc "Mute"]]
				}
				if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
					after 0 [list vid_osd osd_group_f 1000 [mc "Mute"]]
				}
				vid_callbackMplayerRemote "volume 0 1"
			} else {
				set ::main(volume_scale) "$::volume(mute_old_value)"
				$vscale state !disabled
				$vbutton configure -image $::icon_m(volume)
				if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
					after 0 [list vid_osd osd_group_w 1000 "Volume $::volume(mute_old_value)"]
				}
				if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
					after 0 [list vid_osd osd_group_f 1000 "Volume $::volume(mute_old_value)"]
				}
				vid_callbackMplayerRemote "volume [expr int($::main(volume_scale))] 1"
			}
		}
	}
}

proc vid_playerAudioDelay {handler} {
	#~ Manage audio delay for MPlayer
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_playerAudioDelay \033\[0m \{$handler\}"
	set status_vid_Playback [vid_callbackMplayerRemote alive]
	if {$status_vid_Playback != 1} {
		if {"$handler" == "incr"} {
			if {$::option(player_audio_delay) == 2} {
				log_writeOutTv 1 "Audio delay reached maximum of +2 seconds"
				return
			}
			set ::option(player_audio_delay) [format %.1f [expr $::option(player_audio_delay) + 0.1]]
			if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
				after 0 [list vid_osd osd_group_w 1000 "Delay $::option(player_audio_delay)"]
			}
			if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
				after 0 [list vid_osd osd_group_f 1000 "Delay $::option(player_audio_delay)"]
			}
			vid_callbackMplayerRemote "audio_delay $::option(player_audio_delay) 1"
		}
		if {"$handler" == "decr"} {
			if {$::option(player_audio_delay) == -2} {
				log_writeOutTv 1 "Audio delay reached minimum of -2 seconds"
				return
			}
			set ::option(player_audio_delay) [format %.1f [expr $::option(player_audio_delay) - 0.1]]
			if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
				after 0 [list vid_osd osd_group_w 1000 "Delay $::option(player_audio_delay)"]
			}
			if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
				after 0 [list vid_osd osd_group_f 1000 "Delay $::option(player_audio_delay)"]
			}
			vid_callbackMplayerRemote "audio_delay $::option(player_audio_delay) 1"
		}
	}
}
