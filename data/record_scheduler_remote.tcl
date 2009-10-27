#       record_scheduler_remote.tcl
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

proc record_schedulerPrestart {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_schedulerPrestart \033\[0m \{$handler\}"
	if {"$handler" == "record"} {
		log_writeOutTv 0 "Scheduler initiated prestart sequence for recording."
	} else {
		log_writeOutTv 0 "Initiated prestart sequence for timeshift."
	}
	tv_fileComputePos cancel 
	tv_fileComputeSize cancel
	catch {tv_playbackStop 0 nopic}
	if {[winfo exists .tv.file_play_bar]} {
		destroy .tv.file_play_bar
	}
	if {[winfo exists .tv.l_image]} {
		place forget .tv.l_image
	}
	if {$::main(running_recording) != 1} {
		set img_list [launch_splashAnigif "$::where_is/icons/extras/BigBlackIceRoller.gif"]
		label .tv.l_anigif -image [lindex $img_list 0] -borderwidth 0 -background #000000
		place .tv.l_anigif -in .tv.bg -anchor center -relx 0.5 -rely 0.5
		set img_list_length [llength $img_list]
		after 0 [list launch_splashPlay $img_list $img_list_length 1 .tv.l_anigif]
	}
	if {[winfo exists .record_wizard]} {
		.record_wizard configure -cursor watch
	}
	if {$::option(rec_allow_sta_change) == 0} {
		log_writeOutTv 1 "Station change not allowed during recording."
		.bottom_buttons.button_channelup state disabled
		.bottom_buttons.button_channeldown state disabled
		.bottom_buttons.button_channeljumpback state disabled
		if {[winfo exists .frame_slistbox] == 1} {
			.frame_slistbox.listbox_slist configure -state disabled
		}
		bind .tv <<station_up>> {}
		bind .tv <<station_down>> {}
		bind .tv <<station_jump>> {}
		bind .tv <<station_key>> {}
		bind .tv <<input_up>> {}
		bind .tv <<input_down>> {}
		bind . <<station_up>> {}
		bind . <<station_down>> {}
		bind . <<station_jump>> {}
		bind . <<station_key>> {}
		bind . <<station_key_lirc>> {}
		bind . <<input_up>> {}
		bind . <<input_down>> {}
	}
	bind .tv <<stop>> {tv_playbackStop 1 pic}
	bind .tv <<forward_end>> {tv_seekInitiate "tv_seek 0 2"}
	bind .tv <<forward_10s>> {tv_seekInitiate "tv_seek 10 1"}
	bind .tv <<forward_1m>> {tv_seekInitiate "tv_seek 60 1"}
	bind .tv <<forward_10m>> {tv_seekInitiate "tv_seek 600 1"}
	bind .tv <<rewind_10s>> {tv_seekInitiate "tv_seek 10 -1"}
	bind .tv <<rewind_1m>> {tv_seekInitiate "tv_seek 60 -1"}
	bind .tv <<rewind_10m>> {tv_seekInitiate "tv_seek 600 -1"}
	bind .tv <<rewind_start>> {tv_seekInitiate "tv_seek 0 -2"}
	bind . <<teleview>> {}
	bind . <Control-Key-p> {}
	bind . <Control-Key-m> {}
	bind . <Control-Key-e> {}
	bind .tv <<teleview>> {}
	bind .tv <Control-Key-p> {}
	bind .tv <Control-Key-m> {}
	bind .tv <Control-Key-e> {}
	if {"$handler" != "timeshift"} {
		.top_buttons.button_timeshift state disabled
		bind . <<timeshift>> {}
		bind .tv <<timeshift>> {}
	}
	.top_buttons.button_starttv state disabled
	.options_bar.mOptions entryconfigure 1 -state disabled
	.options_bar.mOptions entryconfigure 2 -state disabled
	.options_bar.mOptions entryconfigure 3 -state disabled
	.options_bar.mHelp entryconfigure 8 -state disabled
}

proc record_scheduler_prestartCancel {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_scheduler_prestartCancel \033\[0m \{$handler\}"
	if {"$handler" != "timeshift"} {
		log_writeOutTv 0 "Prestart sequence for recording has been canceled."
		if {[winfo exists .record_wizard]} {
			.record_wizard configure -cursor arrow
		}
	} else {
		log_writeOutTv 0 "Prestart sequence for timeshift has been canceled."
	}
	. configure -cursor arrow; .tv configure -cursor arrow
	.top_buttons.button_timeshift state !disabled
	.top_buttons.button_epg state !disabled
	.top_buttons.button_starttv state !disabled
	.bottom_buttons.button_channelup state !disabled
	.bottom_buttons.button_channeldown state !disabled
	.bottom_buttons.button_channeljumpback state !disabled
	.options_bar.mOptions entryconfigure 1 -state normal
	.options_bar.mOptions entryconfigure 2 -state normal
	.options_bar.mOptions entryconfigure 3 -state normal
	.options_bar.mHelp entryconfigure 8 -state normal
	if {[winfo exists .frame_slistbox] == 1} {
		.frame_slistbox.listbox_slist configure -state normal
	}
	bind .tv <<teleview>> {tv_playerRendering}
	bind .tv <<station_down>> [list main_stationChannelDown .label_stations]
	bind .tv <<station_up>> [list main_stationChannelUp .label_stations]
	bind .tv <<station_jump>> [list main_stationChannelJumper .label_stations]
	bind .tv <<station_key>> [list main_stationStationNrKeys %A]
	bind .tv <<input_up>> [list main_stationInput 1 1]
	bind .tv <<input_down>> [list main_stationInput 1 -1]
	bind .tv <<timeshift>> [list timeshift .top_buttons.button_timeshift]
	bind . <<teleview>> {tv_playerRendering}
	bind . <<station_up>> [list main_stationChannelUp .label_stations]
	bind . <<station_down>> [list main_stationChannelDown .label_stations]
	bind . <<station_jump>> [list main_stationChannelJumper .label_stations]
	bind . <<station_key>> [list main_stationStationNrKeys %A]
	bind . <<station_key_lirc>> [list main_stationStationNrKeys %d]
	bind . <<input_up>> [list main_stationInput 1 1]
	bind . <<input_down>> [list main_stationInput 1 -1]
	bind . <<timeshift>> [list timeshift .top_buttons.button_timeshift]
	bind .tv <Control-Key-p> {tv_playbackStop 0 pic ; config_wizardMainUi}
	bind .tv <Control-Key-m> {colorm_mainUi}
	bind .tv <Control-Key-e> {station_editUi}
	bind . <Control-Key-p> {tv_playbackStop 0 pic ; config_wizardMainUi}
	bind . <Control-Key-m> {colorm_mainUi}
	bind . <Control-Key-e> {station_editUi}
}

proc record_schedulerRec {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_schedulerRec \033\[0m \{$handler\}"
	if {"$handler" != "timeshift"} {
		log_writeOutTv 0 "Scheduler initiated record sequence for main application."
	} else {
		log_writeOutTv 0 "Initiated timeshift sequence for main application."
	}
	bind .tv <<pause>> {tv_seek 0 0}
	if {"$handler" != "timeshift"} {
		bind .tv <<start>> {tv_Playback .tv.bg .tv.bg.w record "$::tv(current_rec_file)"}
	} else {
		bind .tv <<start>> {tv_Playback .tv.bg .tv.bg.w timeshift "$::tv(current_rec_file)"}
	}
	if {"$handler" != "timeshift"} {
		if {[file exists "$::where_is_home/config/current_rec.conf"]} {
			set open_f [open "$::where_is_home/config/current_rec.conf" r]
			while {[gets $open_f line]!=-1} {
				if {[string trim $line] == {}} continue
				lassign $line station sdate stime edate etime duration ::tv(current_rec_file)
			}
		} else {
			log_writeOutTv 2 "Fatal, could not detect current_rec.conf"
		}
	}
	if {[winfo exists .tray]} {
		if {"$handler" != "timeshift"} {
			settooltip .tray [mc "Currently recording %
Started at %" [lindex $::station(last) 0] $stime]
		} else {
			settooltip .tray [mc "Timeshift %" [lindex $::station(last) 0]]
		}
	}
	if {"$handler" != "timeshift"} {
		wm title .tv [mc "Recording % - Started at %" [lindex $::station(last) 0] $stime]
		wm iconphoto .tv $::icon_b(record)
	} else {
		wm title .tv [mc "Timeshift %" [lindex $::station(last) 0]]
		wm iconphoto .tv $::icon_b(timeshift)
	}
	if {"$handler" != "timeshift"} {
		catch {tv_Playback .tv.bg .tv.bg.w record "$::tv(current_rec_file)"}
	} else {
		catch {tv_Playback .tv.bg .tv.bg.w timeshift "$::tv(current_rec_file)"}
	}
	. configure -cursor arrow; .tv configure -cursor arrow
	if {"$handler" != "timeshift"} {
		if {[winfo exists .record_wizard]} {
			.record_wizard configure -cursor arrow
			.record_wizard.status_frame.l_rec_current_info configure -text [mc "% -- ends % at %" $station $edate $etime]
			.record_wizard.status_frame.b_rec_current state !disabled
			foreach ritem [split [.record_wizard.tree_frame.tv_rec children {}]] {
				.record_wizard.tree_frame.tv_rec delete $ritem
			}
			if {[file exists "$::where_is_home/config/scheduled_recordings.conf"]} {
				set f_open [open "$::where_is_home/config/scheduled_recordings.conf" r]
				while {[gets $f_open line]!=-1} {
					if {[string trim $line] == {} || [string match #* $line]} continue
					.record_wizard.tree_frame.tv_rec insert {} end -values [list [lindex $line 0] [lindex $line 1] [lindex $line 2] [lindex $line 3] [lindex $line 4] [lindex $line 5] [lindex $line 6]]
				}
			}
		}
		if {$::main(running_recording) == 1} {
			set timed [clock format [clock scan $edate] -format "%Y%m%d"]
			set timet [clock format [clock scan $etime] -format "%H%M%S"]
			set dt [expr {([clock scan $timed\T$timet]-[clock seconds])*1000}]
			set ::record(after_prestop_id) [after $dt {record_schedulerPreStop record}]
		} else {
			set ::record(after_prestop_id) [after [expr {$duration * 1000}] {record_schedulerPreStop record}]
		}
	}
}

proc record_schedulerStation {station number} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_schedulerStation \033\[0m \{$station\} \{$number\}"
	log_writeOutTv 0 "Scheduler initiated station sequence for main application."
	set ::station(old) "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
	set ::station(last) "\{$station\} $::kanalcall($number) $number"
}

proc record_schedulerPreStop {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: record_schedulerPreStop \033\[0m \{$handler\}"
	if {"$handler" != "timeshift"} {
		log_writeOutTv 0 "Prestop sequence for recording initiated."
		catch {after cancel $::record(after_prestop_id)}
		unset -nocomplain ::record(after_prestop_id)
		set status_recordlinkread [catch {file readlink "$::where_is_home/tmp/record_lockfile.tmp"} resultat_recordlinkread]
		if { $status_recordlinkread == 0 } {
			catch {exec ps -eo "%p"} read_ps
			set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
			if { $status_greppid_record == 0 } {
				log_writeOutTv 0 "There is an active recording (PID $resultat_recordlinkread)."
				catch {exec kill $resultat_greppid_record}
				catch {file delete -force "$::where_is_home/tmp/record_lockfile.tmp"}
				after 3000 {
					puts $::data(comsocket) "tv-viewer_scheduler scheduler_zombie"
					flush $::data(comsocket)
				}
			}
		}
	} else {
		log_writeOutTv 0 "Prestop sequence for timeshift initiated."
	}
	.top_buttons.button_timeshift state !disabled
	.top_buttons.button_epg state !disabled
	.top_buttons.button_starttv state !disabled
	.bottom_buttons.button_channelup state !disabled
	.bottom_buttons.button_channeldown state !disabled
	.bottom_buttons.button_channeljumpback state !disabled
	.options_bar.mOptions entryconfigure 1 -state normal
	.options_bar.mOptions entryconfigure 2 -state normal
	.options_bar.mOptions entryconfigure 3 -state normal
	.options_bar.mHelp entryconfigure 8 -state normal
	if {[winfo exists .frame_slistbox] == 1} {
		.frame_slistbox.listbox_slist configure -state normal
	}
	bind .tv <<teleview>> {tv_playerRendering}
	bind .tv <<station_down>> [list main_stationChannelDown .label_stations]
	bind .tv <<station_up>> [list main_stationChannelUp .label_stations]
	bind .tv <<station_jump>> [list main_stationChannelJumper .label_stations]
	bind .tv <<station_key>> [list main_stationStationNrKeys %A]
	bind .tv <<input_up>> [list main_stationInput 1 1]
	bind .tv <<input_down>> [list main_stationInput 1 -1]
	bind .tv <<timeshift>> [list timeshift .top_buttons.button_timeshift]
	bind . <<teleview>> {tv_playerRendering}
	bind . <<station_up>> [list main_stationChannelUp .label_stations]
	bind . <<station_down>> [list main_stationChannelDown .label_stations]
	bind . <<station_jump>> [list main_stationChannelJumper .label_stations]
	bind . <<station_key>> [list main_stationStationNrKeys %A]
	bind . <<station_key_lirc>> [list main_stationStationNrKeys %d]
	bind . <<input_up>> [list main_stationInput 1 1]
	bind . <<input_down>> [list main_stationInput 1 -1]
	bind . <<timeshift>> [list timeshift .top_buttons.button_timeshift]
	bind .tv <Control-Key-p> {tv_playbackStop 0 pic ; config_wizardMainUi}
	bind .tv <Control-Key-m> {colorm_mainUi}
	bind .tv <Control-Key-e> {station_editUi}
	bind . <Control-Key-p> {tv_playbackStop 0 pic ; config_wizardMainUi}
	bind . <Control-Key-m> {colorm_mainUi}
	bind . <Control-Key-e> {station_editUi}
	if {[wm attributes .tv -fullscreen] == 1} {
		bind .tv.bg.w <Motion> {tv_wmCursorHide .tv.bg.w 0}
		bind .tv.bg <Motion> {tv_wmCursorHide .tv.bg 0}
	}
	if {"$handler" != "timeshift"} {
		if {[winfo exists .record_wizard] == 1} {
			.record_wizard.status_frame.l_rec_current_info configure -text "Idle"
			.record_wizard.status_frame.b_rec_current state disabled
		}
	}
	if {[winfo exists .tv.l_anigif]} {
		catch {launch_splashPlay cancel 0 0 0}
		catch {place forget .tv.l_anigif}
		catch {destroy .tv.l_anigif}
	}
	tv_fileComputeSize cancel_rec
}
