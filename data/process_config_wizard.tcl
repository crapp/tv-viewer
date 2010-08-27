#       process_config_wizard.tcl
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

proc process_config_wizardRead {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: process_config_wizardRead \033\[0m"
	log_writeOutTv 0 "Reading configuration values for preferences dialog."
	#FIXME Remove theme black if it does not work properly.
	array set ::option {
		language Autodetect
		language_value 0
		starttv_startup 0
		resolx 720
		resoly 576
		newsreader 1
		newsreader_interval 7
		epg_command "[auto_execok tvbrowser]"
		#log_files 1
		#log_size_tvviewer 30
		#log_size_mplay 30
		#log_size_scheduler 30
		#video_device /dev/video0
		video_standard PAL
		forcevideo_standard 0
		frequency_table europe-west
		#video_input_name {}
		#video_input 0
		#player_vo xv
		#player_deint Lowpass5
		#player_autoq 0
		#player_cache 2048
		#player_threads 1
		#player_audio alsa
		#player_audio_channels {2 (Stereo)}
		#player_aud_softvol 1
		#player_audio_autosync 0
		#player_audio_delay 0.0
		#player_dr 0
		#player_double 1
		#player_slice 0
		#player_fd 1
		#player_hfd 0
		#player_screens 1
		#player_screens_value 0
		#player_aspect 1
		#player_keepaspect 1
		#player_aspect_monpix 1
		#player_monaspect_val 16:9
		#player_pixaspect_val 1
		#player_shot 1
		#player_mconfig 0
		#player_additional_commands {}
		#player_add_vf_commands {}
		#player_add_af_commands {scaletempo}
		streambitrate 0
		#videobitrate ""
		#videopeakbitrate ""
		temporal_filter 0
		temporal_filter_value 0
		audio_v4l2 0
		#audio_v4l2_value 90
		#audio_v4l2_mult 655
		audio_delay 0
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
		systray 0
		systrayMini 0
		systrayClose 0
		systrayResize 0
		systrayIcSize 22
		osd_station_w {0 {Sans} {Regular} 32 0 #000000}
		osd_station_f {1 {Sans} {Regular} 72 0 #000000}
		osd_group_w {1 {Sans} {Regular} 32 1 #000000}
		osd_group_f {1 {Sans} {Regular} 72 1 #000000}
		osd_key_w {1 {Sans} {Regular} 32 0 #000000}
		osd_key_f {1 {Sans} {Regular} 72 0 #000000}
		osd_lirc {1 {Sans} {Regular} 32 4 #000000}
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
	
	array set ::stnd_opt {
		#FIXME Remove theme black if it does not work properly.
		language Autodetect
		language_value 0
		starttv_startup 0
		resolx 720
		resoly 576
		newsreader 1
		newsreader_interval 7
		epg_command "[auto_execok tvbrowser]"
		log_files 1
		log_size_tvviewer 30
		log_size_mplay 30
		log_size_scheduler 30
		#video_device /dev/video0
		video_standard PAL
		forcevideo_standard 0
		frequency_table europe-west
		#video_input_name {}
		#video_input 0
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
		player_shot 1
		player_mconfig 0
		player_additional_commands {}
		player_add_vf_commands {}
		player_add_af_commands {scaletempo}
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
		systray 0
		systrayMini 0
		systrayClose 0
		systrayResize 0
		systrayIcSize 22
		osd_station_w {0 {Sans} {Regular} 32 0 #000000}
		osd_station_f {1 {Sans} {Regular} 72 0 #000000}
		osd_group_w {1 {Sans} {Regular} 32 1 #000000}
		osd_group_f {1 {Sans} {Regular} 72 1 #000000}
		osd_key_w {1 {Sans} {Regular} 32 0 #000000}
		osd_key_f {1 {Sans} {Regular} 72 0 #000000}
		osd_lirc {1 {Sans} {Regular} 32 4 #000000}
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
	
	array set ::opt_choiceGeneral {
		mbLanguage language
		mbLanguage_value language_value
		checkbutton_starttv starttv_startup
		checkbutton_newsreader newsreader
		sb_newsreader newsreader_interval
		entry_epg epg_command
	}
	array set ::opt_choiceAnalog {
		mbVideo video_device
		mbVideo_standard video_standard
		cb_video_standard forcevideo_standard
		mbFreqtable frequency_table
		mbVideo_input video_input_name
		mbVideo_input_value video_input
	}
	array set ::opt_choiceStream {
		cb_streambitrate streambitrate
		entry_vbitrate_value videobitrate
		entry_pbitrate_value videopeakbitrate
		cb_temporal temporal_filter
		spinbox_temporal temporal_filter_value
		cb_audio_v4l2 audio_v4l2
		scale_recordvolume audio_v4l2_value
		scale_recordvolume_mult audio_v4l2_mult
	}
	array set ::opt_choiceVideo {
		mbVo player_vo
		mbDeint player_deint
		sb_autoq player_autoq
		mbCache player_cache
		sb_threads player_threads
		mbAudio player_audio
		mbAudio_channels player_audio_channels
		cb_softvol player_aud_softvol
		cb_dr player_dr
		cb_double player_double
		cb_slice player_slice
		cb_framedrop player_fd
		cb_hframedrop player_hfd
		cb_lf_screensaver player_screens
		rb_screensaver player_screens_value
		cb_lf_aspect player_aspect
		cb_keepaspect player_keepaspect
		rb_aspect player_aspect_monpix
		mbMoniaspect player_monaspect_val
		sb_monipixaspect player_pixaspect_val
		cb_advanced_shot player_shot
		cb_advanced_mconfig player_mconfig
		entry_mplayer_add_coms player_additional_commands
		entry_vf_mplayer player_add_vf_commands
		entry_af_mplayer player_add_af_commands
		cb_audautosync player_audio_autosync
		sb_auddelay player_audio_delay
	}
	array set ::opt_choiceInterface {
		mbTheme use_theme
		cb_tooltip tooltips
		cb_tooltip_main tooltips_main
		cb_tooltip_wizard tooltips_wizard
		cb_tooltip_station tooltips_editor
		cb_tooltip_colorm tooltips_colorm
		cb_tooltip_record tooltips_record
		cb_splash show_splash
		cb_fullscr window_full
		cb_remGeom window_remGeom
		cb_systray systray
		cb_systrayMini systrayMini
		cb_systrayClose systrayClose
		cb_systrayResize systrayResize
		mb_systrayIcSize systrayIcSize
		cb_remAdio volRem
	}
	array set ::opt_choiceOsd {
		osd_station_w osd_station_w
		osd_station_f osd_station_f
		osd_group_w osd_group_w
		osd_group_f osd_group_f
		osd_key_w osd_key_w
		osd_key_f osd_key_f
		osd_lirc osd_lirc
	}
	array set ::opt_choiceRec {
		entry_rec_path rec_default_path
		rcb_allow_schange_rec rec_allow_sta_change
		sb_duration_hour rec_duration_hour
		sb_duration_min rec_duration_min
		sb_duration_sec rec_duration_sec
		cb_sched_auto rec_sched_auto
		rb_clock rec_hour_format
		ent_times_df timeshift_df
		ent_times_folder timeshift_path
	}
	array set ::opt_choiceLog {
		cb_lf_logging log_files
		sb_logging_tv log_size_tvviewer
		sb_logging_mplayer log_size_mplay
		sb_logging_sched log_size_scheduler
	}

	if {[file exists "$::option(home)/config/tv-viewer.conf"]} {
		set open_config_file [open "$::option(home)/config/tv-viewer.conf" r]
		while {[gets $open_config_file line]!=-1} {
			if {[string match #* $line] || [string trim $line] == {} } continue
			if {[catch {array set ::option $line}]} {
				log_writeOutTv 2 "Config file line incorrect: $line"
			}
		}
		close $open_config_file
	} else {
		log_writeOutTv 1 "Could not locate a configuration file!"
		log_writeOutTv 1 "Will use standard values."
		foreach {key elem} [array get ::options] {
			log_writeOutTv 1 "$key $elem"
		}
	}
}
