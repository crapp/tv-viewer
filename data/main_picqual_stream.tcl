#       main_picqual_stream.tcl
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

proc main_pic_streamForceVideoStandard {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_pic_streamForceVideoStandard \033\[0m"}
	catch {exec v4l2-ctl --device=$::option(video_device) --set-standard=[string tolower $::option(video_standard)]}
}

proc main_pic_streamDimensions {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_pic_streamDimension \033\[0m"}
	catch {exec v4l2-ctl --device=$::option(video_device) -V} read_v4l2ctl
	set status_grepwidthheight [catch {agrep -m "$read_v4l2ctl" width} read_resol]
	if {$status_grepwidthheight == 0} {
		if {[string tolower $::option(video_standard)] == "ntsc" } {
			if {"[string trim [lindex $read_resol end]]" != "720/480"} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-fmt-video=width=720,height=480}
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Video resolution set to 720/480."
				flush $::logf_tv_open_append
			}
		} else {
			if {"[string trim [lindex $read_resol end]]" != "720/576"} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-fmt-video=width=720,height=576}
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Video resolution set to 720/576."
				flush $::logf_tv_open_append
			}
		}
	}
}

proc main_pic_streamPicqualTemporal {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_pic_streamPicqualTemporal \033\[0m"}
	catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=temporal_filter} read_temporal
	set temporal_filter_status [catch {agrep -m "$read_temporal" temporal} resultat_temporal_filter]
	if {$temporal_filter_status == 0} {
		if {[lindex $resultat_temporal_filter 1] != $::option(temporal_filter_value)} {
			catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=temporal_filter=$::option(temporal_filter_value)}
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=temporal_filter} read_temporal
			if {[lindex $read_temporal 1] == $::option(temporal_filter_value) } {
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Temporal filter set to $::option(temporal_filter_value)"
				flush $::logf_tv_open_append
			} else {
				puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Can't change temporal filter"
				flush $::logf_tv_open_append
			}
		}
	}
}

proc main_pic_streamVbitrate {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_pic_streamVbitrate \033\[0m"}
	if {$::option(streambitrate) == 1} {
		if {[info exists ::option(videopeakbitrate)]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=video_peak_bitrate} read_peak_bitrate
			if {[expr ([lindex $read_peak_bitrate 1] / 8) / 1024] != $::option(videopeakbitrate)} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=video_peak_bitrate=[expr ($::option(videopeakbitrate) * 1024) * 8]}
				catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=video_peak_bitrate} read_peak_bitrate
				if {[expr ([lindex $read_peak_bitrate 1] / 8) / 1024] == $::option(videopeakbitrate)} {
					puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting 'video peak bitrate' to $::option(videopeakbitrate)"
					flush $::logf_tv_open_append
				} else {
					puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Can't set 'video peak bitrate'"
					flush $::logf_tv_open_append
				}
			}
		}
		if {[info exists ::option(videobitrate)]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=video_bitrate} read_bitrate
			if {[expr ([lindex $read_bitrate 1] / 8) / 1024] != $::option(videobitrate)} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=video_bitrate=[expr ($::option(videobitrate) * 1024) * 8]}
				catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=video_bitrate} read_bitrate
				if {[expr ([lindex $read_bitrate 1] / 8) / 1024] == $::option(videobitrate)} {
					puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting 'video bitrate' to $::option(videobitrate)"
					flush $::logf_tv_open_append
				} else {
					puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Can't set 'video bitrate'"
					flush $::logf_tv_open_append
				}
			}
		}
	}
}

proc main_pic_streamColormControls {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_pic_streamColormControls \033\[0m"}
	if {[info exists ::option(brightness)]} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=brightness} read_brightness
		set status_grepbrightness [catch {agrep -m "$read_bridghtness" brightness} brightness_check]
		if {$status_grepbrightness == 0} {
			if {[string trim [lindex $brightness_check end]] != $::option(brightness) } {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=brightness=$::option(brightness)}
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Adjusting brightness."
				flush $::logf_tv_open_append
			}
		}
	}
	if {[info exists ::option(contrast)]} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=contrast} read_contrast
		set status_grepcontrast [catch {agrep -m "$read_contrast" contrast} contrast_check]
		if {$status_grepcontrast == 0} {
			if {[string trim [lindex $contrast_check end]] != $::option(contrast) } {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=contrast=$::option(contrast)}
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Adjusting contrast."
				flush $::logf_tv_open_append
			}
		}
	}
	if {[info exists ::option(hue)]} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=hue} read_hue
		set status_grephue [catch {agrep -m "$read_hue" hue} hue_check]
		if {$status_grephue == 0} {
			if {[string trim [lindex $hue_check end]] != $::option(hue) } {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=hue=$::option(hue)}
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Adjusting hue."
				flush $::logf_tv_open_append
			}
		}
	}
	if {[info exists ::option(saturation)]} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=saturation} read_saturation
		set status_grepsaturation [catch {agrep -m "$read_saturation" saturation} saturation_check]
		if {$status_grepsaturation == 0} {
			if {[string trim [lindex $saturation_check end]] != $::option(saturation) } {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=saturation=$::option(saturation)}
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Adjusting saturation."
				flush $::logf_tv_open_append
			}
		}
	}
}

proc main_pic_streamAudioV4l2 {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_pic_streamAudioV4l2 \033\[0m"}
	if {[info exists ::option(audio_v4l2_value)]} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=volume} read_volume
		set status_audio [catch {agrep -m "$read_volume" volume} resultat_audio]
		if {$status_audio == 0} {
			if {[string trim [lindex $resultat_audio end]] != [expr round($::option(audio_v4l2_value) * $::option(audio_v4l2_mult))]} {
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting hardware audio level to [expr round($::option(audio_v4l2_value) * $::option(audio_v4l2_mult))]."
				flush $::logf_tv_open_append
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=volume=[expr round($::option(audio_v4l2_value) * $::option(audio_v4l2_mult))]}
				catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=volume} result_audio
				if {[string trim [lindex $result_audio end]] != [expr round($::option(audio_v4l2_value) * $::option(audio_v4l2_mult))]} {
					puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Setting hardware audio level to [expr round($::option(audio_v4l2_value) * $::option(audio_v4l2_mult))] wasn't successful.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Error message: $result_audio"
					flush $::logf_tv_open_append
				}
			}
		} else {
			puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Can't access hardware audio control. Error message:
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] $resultat_audio"
			flush $::logf_tv_open_append
		}
	}
}
