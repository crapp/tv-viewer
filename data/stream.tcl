#       stream.tcl
#       © Copyright 2007-2013 Christian Rapp <christianrapp@users.sourceforge.net>
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

proc stream_videoStandard {handler} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: stream_videoStandard \033\[0m \{$handler\}"}
	#handler 0 = normal; 1 = called during startup
	if {"$::option(appname)" == "tv-viewer_main"} {
		set logCommand "log_writeOut ::log(tvAppend)"
	}
	if {"$::option(appname)" == "tv-viewer_scheduler"} {
		set logCommand "log_writeOut ::log(schedAppend)"
	}
	set check 0
	if {$::option(forcevideo_standard)} {
		{*}$logCommand 1 "Forcing video standard $::option(video_standard)"
		catch {exec v4l2-ctl --device=$::option(video_device) --set-standard=[string tolower $::option(video_standard)]}
		set check 1
	} else {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-standard} vidStandard
		set status [catch {agrep -m "[string tolower $vidStandard]" [string tolower $::option(video_standard)]} result]
		if {$status == 0} {
			{*}$logCommand 0 "Video standard \"[string trim $result]\", nothing to change"
		} else {
			{*}$logCommand 0 "Changing video standard to $::option(video_standard)"
			catch {exec v4l2-ctl --device=$::option(video_device) --set-standard=[string tolower $::option(video_standard)]}
			set check 1
		}
	}
	if {$check} {
		#check if setting the video standard was successful
		catch {exec v4l2-ctl --device=$::option(video_device) --get-standard} vidStandard
		set status [catch {agrep -m "[string tolower $vidStandard]" [string tolower $::option(video_standard)]} result]
		if {$status == 0} {
			{*}$logCommand 0 "Successfully changed video standard to \"[string trim $result]\""
		} else {
			if {"$::option(appname)" == "tv-viewer_main"} {
				log_writeOut ::log(tvAppend) 2 "Can not change video standard to $::option(video_standard)"
				log_writeOut ::log(tvAppend) 2 "Error message: \"$result\""
				if {$handler} {
					if {$::option(show_splash) == 1} {
						after 3500 {status_feedbWarn 1 2 [mc "Can not change video standard"]}
					} else {
						after 2500 {status_feedbWarn 1 2 [mc "Can not change video standard"]}
					}
				} else {
					status_feedbWarn 1 2 [mc "Can not change video standard"]
				}
			}
			if {"$::option(appname)" == "tv-viewer_scheduler"} {
				log_writeOut ::log(schedAppend) 2 "Can not change video standard to $::option(video_standard)"
				log_writeOut ::log(schedAppend) 2 "Error message: \"$result\""
			}
		}
	}
}

proc stream_dimensions {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: stream_dimensions \033\[0m"}
	catch {exec v4l2-ctl --device=$::option(video_device) -V} read_v4l2ctl
	set status_grepwidthheight [catch {agrep -m "$read_v4l2ctl" width} read_resol]
	if {$status_grepwidthheight == 0} {
		if {[string tolower $::option(video_standard)] == "ntsc" } {
			if {"[string trim [lindex $read_resol end]]" != "720/480"} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-fmt-video=width=720,height=480}
				log_writeOut ::log(tvAppend) 0 "Video resolution set to 720/480"
			}
		} else {
			if {"[string trim [lindex $read_resol end]]" != "720/576"} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-fmt-video=width=720,height=576}
				log_writeOut ::log(tvAppend) 0 "Video resolution set to 720/576"
			}
		}
	}
}

proc stream_temporal {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: stream_temporal \033\[0m"}
	catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=temporal_filter} read_temporal
	set temporal_filter_status [catch {agrep -m "$read_temporal" temporal} resultat_temporal_filter]
	if {$temporal_filter_status == 0} {
		if {[lindex $resultat_temporal_filter 1] != $::option(temporal_filter_value)} {
			catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=temporal_filter=$::option(temporal_filter_value)}
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=temporal_filter} read_temporal
			if {[lindex $read_temporal 1] == $::option(temporal_filter_value) } {
				log_writeOut ::log(tvAppend) 0 "Temporal filter set to $::option(temporal_filter_value)"
			} else {
				log_writeOut ::log(tvAppend) 2 "Can't change temporal filter"
			}
		}
	}
}

proc stream_vbitrate {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: stream_vbitrate \033\[0m"}
	if {$::option(streambitrate) == 1} {
		if {[info exists ::option(videopeakbitrate)]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=video_peak_bitrate} read_peak_bitrate
			if {[string is integer $read_peak_bitrate] == 1  && [expr ([lindex $read_peak_bitrate 1] / 8) / 1024] != $::option(videopeakbitrate)} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=video_peak_bitrate=[expr ($::option(videopeakbitrate) * 1024) * 8]}
				catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=video_peak_bitrate} read_peak_bitrate
				if {[expr ([lindex $read_peak_bitrate 1] / 8) / 1024] == $::option(videopeakbitrate)} {
					log_writeOut ::log(tvAppend) 0 "Setting 'video peak bitrate' to $::option(videopeakbitrate)"
				} else {
					log_writeOut ::log(tvAppend) 2 "Can't set 'video peak bitrate'"
				}
			}
		}
		if {[info exists ::option(videobitrate)]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=video_bitrate} read_bitrate
			if {[string is integer $read_bitrate] == 1  && [expr ([lindex $read_bitrate 1] / 8) / 1024] != $::option(videobitrate)} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=video_bitrate=[expr ($::option(videobitrate) * 1024) * 8]}
				catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=video_bitrate} read_bitrate
				if {[expr ([lindex $read_bitrate 1] / 8) / 1024] == $::option(videobitrate)} {
					log_writeOut ::log(tvAppend) 0 "Setting 'video bitrate' to $::option(videobitrate)"
				} else {
					log_writeOut ::log(tvAppend) 2 "Can't set 'video bitrate'"
				}
			}
		}
	}
}

proc stream_colormControls {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: stream_colormControls \033\[0m"}
	if {[info exists ::option(brightness)]} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=brightness} read_brightness
		set status_grepbrightness [catch {agrep -m "$read_bridghtness" brightness} brightness_check]
		if {$status_grepbrightness == 0} {
			if {[string trim [lindex $brightness_check end]] != $::option(brightness) } {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=brightness=$::option(brightness)}
				log_writeOut ::log(tvAppend) 0 "Adjusting brightness"
			}
		}
	}
	if {[info exists ::option(contrast)]} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=contrast} read_contrast
		set status_grepcontrast [catch {agrep -m "$read_contrast" contrast} contrast_check]
		if {$status_grepcontrast == 0} {
			if {[string trim [lindex $contrast_check end]] != $::option(contrast) } {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=contrast=$::option(contrast)}
				log_writeOut ::log(tvAppend) 0 "Adjusting contrast"
			}
		}
	}
	if {[info exists ::option(hue)]} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=hue} read_hue
		set status_grephue [catch {agrep -m "$read_hue" hue} hue_check]
		if {$status_grephue == 0} {
			if {[string trim [lindex $hue_check end]] != $::option(hue) } {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=hue=$::option(hue)}
				log_writeOut ::log(tvAppend) 0 "Adjusting hue"
			}
		}
	}
	if {[info exists ::option(saturation)]} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=saturation} read_saturation
		set status_grepsaturation [catch {agrep -m "$read_saturation" saturation} saturation_check]
		if {$status_grepsaturation == 0} {
			if {[string trim [lindex $saturation_check end]] != $::option(saturation) } {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=saturation=$::option(saturation)}
				log_writeOut ::log(tvAppend) 0 "Adjusting saturation"
			}
		}
	}
}

proc stream_audioV4l2 {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: stream_audioV4l2 \033\[0m"}
	if {[info exists ::option(audio_v4l2_value)]} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=volume} read_volume
		set status_audio [catch {agrep -m "$read_volume" volume} resultat_audio]
		if {$status_audio == 0} {
			if {[string trim [lindex $resultat_audio end]] != [expr round($::option(audio_v4l2_value) * $::option(audio_v4l2_mult))]} {
				log_writeOut ::log(tvAppend) 0 "Setting hardware audio level to [expr round($::option(audio_v4l2_value) * $::option(audio_v4l2_mult))]."
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=volume=[expr round($::option(audio_v4l2_value) * $::option(audio_v4l2_mult))]}
				catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=volume} result_audio
				if {[string trim [lindex $result_audio end]] != [expr round($::option(audio_v4l2_value) * $::option(audio_v4l2_mult))]} {
					log_writeOut ::log(tvAppend) 2 "Setting hardware audio level to [expr round($::option(audio_v4l2_value) * $::option(audio_v4l2_mult))] wasn't successful."
					log_writeOut ::log(tvAppend) 2 "Error message: $result_audio"
				}
			}
		} else {
			log_writeOut ::log(tvAppend) 2 "Can't access hardware audio control. Error message:"
			log_writeOut ::log(tvAppend) 2 "$resultat_audio"
		}
	}
}
