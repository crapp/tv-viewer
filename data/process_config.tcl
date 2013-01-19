#       process_config.tcl
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

proc process_configRead {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: process_configRead \033\[0m"}
	array set ::option {
		language Autodetect
		language_value 0
		starttv_startup 0
		resolx 640
		resoly 480
		newsreader 1
		newsreader_interval 3
		epg_command "[auto_execok tvbrowser]"
		log_files 1
		log_size_tvviewer 30
		log_size_mplay 30
		log_size_scheduler 30
		log_warnDialogue 1
		video_device /dev/video0
		video_standard PAL
		forcevideo_standard 0
		frequency_table europe-west
		video_input_name {}
		video_input 0
		player_vo xv
		player_deint Lowpass5
		player_autoq 0
		player_cache 2048
		player_threads 1
		player_audio alsa
		player_audio_channels {2 (Stereo)}
		player_aud_softvol 1
		player_audio_autosync 0
		player_audio_delay 0.0
		player_dr 0
		player_double 1
		player_slice 0
		player_fd 1
		player_hfd 0
		player_screens 1
		player_screens_value 0
		player_aspect 1
		player_keepaspect 1
		player_aspect_monpix 1
		player_monaspect_val 16:9
		player_pixaspect_val 1
		player_mpixaspect_val 1.0
		player_shot 1
		player_mconfig 0
		player_additional_commands {}
		player_add_vf_commands {}
		player_add_af_commands {}
		streambitrate 0
		#videobitrate ""
		#videopeakbitrate ""
		temporal_filter 0
		temporal_filter_value 0
		audio_v4l2 0
		#audio_v4l2_value 90
		#audio_v4l2_mult 655
		use_theme "default"
		tooltips 1
		tooltips_main 1
		tooltips_wizard 1
		tooltips_editor 1
		tooltips_colorm 1
		tooltips_record 1
		show_splash 1
		window_full 0
		window_remGeom 1
		volRem 1
		floatMain 0
		floatStation 1
		floatPlay 0
		systrayMini 0
		systrayClose 0
		systrayResize 0
		systrayIcSize 22
		osd_enabled 1
		osd_font "DejaVu Sans Mono"
		osd_font_size 72
		osd_font_style regular
		osd_font_align left
		osd_font_color #000000
		osd_station_w {0 {Sans} {Regular} 32 0 #000000}
		osd_station_f {1 {Sans} {Regular} 72 0 #000000}
		osd_group_w {1 {Sans} {Regular} 32 1 #000000}
		osd_group_f {1 {Sans} {Regular} 72 1 #000000}
		osd_key_w {1 {Sans} {Regular} 32 0 #000000}
		osd_key_f {1 {Sans} {Regular} 72 0 #000000}
		osd_lirc {1 {Sans} {Regular} 32 4 #000000}
		notify 1
		notifyPos 0
		notifyTime 7
		rec_default_path $::env(HOME)
		rec_allow_sta_change 0
		rec_duration_hour 2
		rec_duration_min 0
		rec_duration_sec 0
		rec_sched_auto 1
		rec_hour_format 24
		timeshift_df 1000
		timeshift_path "$::option(home)/tmp"
	}
	if {[info exists ::log(tvAppend)]} {
		if {"$::option(appname)" == "tv-viewer_main"} {
			log_writeOut ::log(tvAppend) 0 "Reading configuration values."
		}
	}
	
	if {[file exists "$::option(home)/config/tv-viewer.conf"]} {
		set open_config_file [open "$::option(home)/config/tv-viewer.conf" r]
		while {[gets $open_config_file line]!=-1} {
			if {[string match #* $line] || [string trim $line] == {} } continue
			if {[catch {array set ::option $line}]} {
				if {[info exists ::log(tvAppend)]} {
					log_writeOut ::log(tvAppend) 2 "Config file line incorrect: $line"
				}
			}
		}
		close $open_config_file
	} else {
		if {[info exists ::log(tvAppend)]} {
			log_writeOut ::log(tvAppend) 1 "Could not locate a configuration file!"
			log_writeOut ::log(tvAppend) 1 "Will use standard values."
		}
		foreach {key elem} [array get ::option] {
			if {[info exists ::log(tvAppend)]} {
				log_writeOut ::log(tvAppend) 1 "$key $elem"
			}
		}
	}
}

proc process_configMem {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: process_configMem \033\[0m"}
	array set ::mem {
		mainwidth 654
		mainheight 480
		mainX "[expr {(([winfo screenwidth .] / 2) - 327)}]"
		mainY "[expr {(([winfo screenheight .] / 2) - 240)}]"
		ontop 0
		compact 0
		toolbMain 1
		toolbStation 1
		toolbControl 1
		sbarStatus 1
		sbarTime 1
		systray 0
		volume 100
		wizardSec 0
		wizardTab .config_wizard.frame_configoptions.nb.f_general
	}
	
	if {[info exists ::log(tvAppend)]} {
		if {"$::option(appname)" == "tv-viewer_main"} {
			log_writeOut ::log(tvAppend) 0 "Reading memory configuration values."
		}
	}
	if {[file exists "$::option(home)/config/tv-viewer_mem.conf"]} {
		set open_config_file [open "$::option(home)/config/tv-viewer_mem.conf" r]
		while {[gets $open_config_file line]!=-1} {
			if {[string match #* $line] || [string trim $line] == {} } continue
			if {[catch {array set ::mem $line}]} {
				if {[info exists ::log(tvAppend)]} {
					log_writeOut ::log(tvAppend) 2 "Mem config file line incorrect: $line"
				}
			}
		}
		close $open_config_file
	} else {
		if {[info exists ::log(tvAppend)]} {
			log_writeOut ::log(tvAppend) 1 "Could not locate a mem configuration file!"
			log_writeOut ::log(tvAppend) 1 "Will use standard values."
		}
		foreach {key elem} [array get ::mem] {
			if {[info exists ::log(tvAppend)]} {
				log_writeOut ::log(tvAppend) 1 "$key $elem"
			}
		}
	}
}
