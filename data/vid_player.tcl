#       vid_player.tcl
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

proc vid_playerVolumeControl {vscale vbutton value} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_playerVolumeControl \033\[0m \{$vscale\} \{$vbutton\} \{$value\}"
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

proc vid_playerInfoVars {} {
	set varfile [open "$::env(HOME)/varfile" w+]
	foreach var [info globals] {
		if {[array exists ::$var]} {
			puts $varfile "FOUND ARRAY $var:"
			flush $varfile
			foreach {key elem} [array get ::$var] {
				puts $varfile "key: $key
element: $elem
"
				flush $varfile
			}
		} else {
			puts $varfile "
$var: [set ::$var]"
			flush $varfile
		}
	}
	close $varfile
}

proc vid_playerRendering {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_playerRendering \033\[0m"
	set status [vid_callbackMplayerRemote alive]
	if {$status != 1} {
		if {$::vid(pbMode) == 1} {
			vid_playbackStop 0 nopic
			vid_fileComputePos cancel
			vid_fileComputeSize cancel
			bind . <<pause>> {}
			bind . <<start>> {}
			bind . <<stop>> {}
			bind . <<forward_10s>> {}
			bind . <<forward_1m>> {}
			bind . <<forward_10m>> {}
			bind . <<rewind_10s>> {}
			bind . <<rewind_1m>> {}
			bind . <<rewind_10m>> {}
			bind . <<forward_end>> {}
			bind . <<rewind_start>> {}
			if {$::main(running_recording) == 1} {
				if {$::option(forcevideo_standard) == 1} {
					main_pic_streamForceVideoStandard
				}
				main_pic_streamDimensions
				if {$::option(streambitrate) == 1} {
					main_pic_streamVbitrate
				}
				if {$::option(temporal_filter) == 1} {
					main_pic_streamPicqualTemporal
				}
				main_pic_streamColormControls
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=mute=0}
				if {$::option(audio_v4l2) == 1} {
					main_pic_streamAudioV4l2
				}
				set ::main(running_recording) 0
			}
			.ftoolb_Disp.lDispIcon configure -image $::icon_s(starttv)
			.ftoolb_Disp.lDispText configure -text [mc "Now playing %" [lindex $::station(last) 0]]
			set status [vid_callbackMplayerRemote alive]
			if {$status != 1} {
				after 100 {vid_playerLoop}
			} else {
				if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"]} {
					catch {file delete -force "[subst $::option(timeshift_path)/timeshift.mpeg]"}
				}
				vid_Playback .fvidBg .fvidBg.cont
			}
		} else {
			vid_playbackStop 0 pic
		}
	} else {
		if {[info exists ::vid(pbMode)] && $::vid(pbMode) == 1} {
			vid_fileComputePos cancel
			vid_fileComputeSize cancel
			bind . <<pause>> {}
			bind . <<start>> {}
			bind . <<stop>> {}
			bind . <<forward_10s>> {}
			bind . <<forward_1m>> {}
			bind . <<forward_10m>> {}
			bind . <<rewind_10s>> {}
			bind . <<rewind_1m>> {}
			bind . <<rewind_10m>> {}
			bind . <<forward_end>> {}
			bind . <<rewind_start>> {}
			if {$::main(running_recording) == 1} {
				if {$::option(forcevideo_standard) == 1} {
					main_pic_streamForceVideoStandard
				}
				main_pic_streamDimensions
				if {$::option(streambitrate) == 1} {
					main_pic_streamVbitrate
				}
				if {$::option(temporal_filter) == 1} {
					main_pic_streamPicqualTemporal
				}
				main_pic_streamColormControls
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=mute=0}
				if {$::option(audio_v4l2) == 1} {
					main_pic_streamAudioV4l2
				}
				set ::main(running_recording) 0
			}
			if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"]} {
				catch {file delete -force "[subst $::option(timeshift_path)/timeshift.mpeg]"}
			}
			.ftoolb_Disp.lDispIcon configure -image $::icon_s(starttv)
			.ftoolb_Disp.lDispText configure -text [mc "Now playing %" [lindex $::station(last) 0]]
		}
		main_pic_streamDimensions
		vid_Playback .fvidBg .fvidBg.cont 0 0
	}
}

proc vid_playerLoop {} {
	set status [vid_callbackMplayerRemote alive]
	if {$status != 1} {
		after 100 {vid_playerLoop}
	} else {
		if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"]} {
			catch {file delete -force "[subst $::option(timeshift_path)/timeshift.mpeg]"}
		}
		puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_playerLoop \033\[0;1;31m::complete:: \033\[0m"
		vid_Playback .fvidBg .fvidBg.cont 0 0
	}
}

# Deprecated code that stays here in case it will be needed again

#~ proc tv_autorepeat_press {keycode serial seek_com} {
	#~ if {$::data(key_first_press) == 1} {
		#~ set ::data(key_first_press) 0
		#~ if {"[lindex $seek_com 0]" == "vid_seek"} {
			#~ set ::vid(seek_secs) [lindex $seek_com 1]
			#~ set ::vid(seek_dir) [lindex $seek_com 2]
			#~ set ::vid(getvid_seek) 1
			#~ vid_callbackMplayerRemote get_time_pos
		#~ }
	#~ }
	#~ set ::data(key_serial) $serial
#~ }
#~ 
#~ proc tv_autorepeat_release {keycode serial} {
	#~ global delay
	#~ after 10 "if {$serial != \$::data(key_serial)} {
	#~ set ::data(key_first_press) 1
	#~ }"
#~ }
#~ 
#~ proc tv_syncing_file_pos {stop} {
	#~ catch {after cancel $::data(sync_remoteid)}
	#~ catch {after cancel $::data(sync_id)}
	#~ set ::data(sync_remoteid) [after 500 {vid_callbackMplayerRemote get_time_pos}]
	#~ set ::data(sync_id) [after 1000 {
		#~ if {[string match -nocase "ANS_TIME_POSITION*" $::data(report)]} {
			#~ set pos [lindex [split $::data(report) \=] end]
			#~ set ::data(file_pos_calc) [expr [clock seconds] - [expr int($pos)]]
		#~ }
	#~ }]
#~ }
