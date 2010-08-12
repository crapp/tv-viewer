#       event_bind.tcl
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

proc event_constr {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: event_constr \033\[0m \{$handler\}"
	#Construct events and make necessary bindings
	bind . <Key-m> [list vid_audioVolumeControl .ftoolb_Play.scVolume .ftoolb_Play.bVolMute mute]
	bind . <Key-F1> [list info_helpHelp]
	bind . <Alt-Key-t> [list event generate .foptions_bar.mbTvviewer <<Invoke>>]
	bind . <Alt-Key-n> [list event generate .foptions_bar.mbNavigation <<Invoke>>]
	bind . <Alt-Key-v> [list event generate .foptions_bar.mbView <<Invoke>>]
	bind . <Alt-Key-a> [list event generate .foptions_bar.mbAudio <<Invoke>>]
	bind . <Alt-Key-h> [list event generate .foptions_bar.mbHelp <<Invoke>>]
	bind . <Control-Key-p> {config_wizardMainUi}
	bind . <Control-Key-m> {colorm_mainUi}
	bind . <Control-Key-e> {station_editUi}
	event add <<exit>> <Control-Key-x>
	bind . <<exit>> {main_frontendExitViewer}
	event add <<input_up>> <Control-Key-i>
	event add <<input_down>> <Control-Alt-Key-i>
	bind . <<input_up>> [list chan_zapperInput 1 1]
	bind . <<input_down>> [list chan_zapperInput 1 -1]
	event add <<volume_incr>> <Key-plus> <Key-KP_Add>
	event add <<volume_decr>> <Key-minus> <Key-KP_Subtract>
	bind . <<volume_decr>> {vid_audioVolumeControl .ftoolb_Play.scVolume .ftoolb_Play.bVolMute [expr $::main(volume_scale) - 3]}
	bind . <<volume_incr>> {vid_audioVolumeControl .ftoolb_Play.scVolume .ftoolb_Play.bVolMute [expr $::main(volume_scale) + 3]}
	event add <<delay_incr>> <Alt-Key-plus> <Alt-Key-KP_Add>
	event add <<delay_decr>> <Alt-Key-minus> <Alt-Key-KP_Subtract>
	bind . <<delay_incr>> {vid_playerAudioDelay incr}
	bind . <<delay_decr>> {vid_playerAudioDelay decr}
	event add <<forward_end>> <Key-End>
	event add <<forward_10s>> <Key-Right>
	event add <<forward_1m>> <Shift-Key-Right>
	event add <<forward_10m>> <Control-Shift-Key-Right>
	event add <<rewind_start>> <Key-Home>
	event add <<rewind_10s>> <Key-Left>
	event add <<rewind_1m>> <Shift-Key-Left>
	event add <<rewind_10m>> <Control-Shift-Key-Left>
	event add <<pause>> <Key-p>
	event add <<start>> <Shift-Key-P>
	event add <<stop>> <Shift-Key-S>
	bind . <Key-f> [list vid_wmFullscreen . .fvidBg .fvidBg.cont]
	bind . <Control-Key-c> vid_wmCompact
	bind .fvidBg.cont <Double-ButtonPress-1> [list vid_wmFullscreen . .fvidBg .fvidBg.cont]
	bind .fvidBg <Double-ButtonPress-1> [list vid_wmFullscreen . .fvidBg .fvidBg.cont]
	bind . <Control-Key-1> [list vid_wmGivenSize .fvidBg 1]
	bind . <Control-Key-2> [list vid_wmGivenSize .fvidBg 2]
	bind . <Key-e> [list vid_wmPanscan .fvidBg.cont 1]
	bind . <Key-w> [list vid_wmPanscan .fvidBg.cont -1]
	bind . <Shift-Key-W> {vid_wmPanscanAuto}
	bind . <Alt-Key-Right> [list vid_wmMoveVideo 0]
	bind . <Alt-Key-Down> [list vid_wmMoveVideo 1]
	bind . <Alt-Key-Left> [list vid_wmMoveVideo 2]
	bind . <Alt-Key-Up> [list vid_wmMoveVideo 3]
	bind . <Key-c> [list vid_wmMoveVideo 4]
	bind .fvidBg <ButtonPress-3> [list tk_popup .fvidBg.mContext %X %Y]
	bind .fvidBg.cont <ButtonPress-3> [list tk_popup .fvidBg.mContext %X %Y]
	bind . <Mod4-Key-s> [list vid_callbackMplayerRemote "screenshot 0"]
	if {$handler} {
		event add <<record>> <Key-r>
		bind . <<record>> [list record_wizardUi]
		event add <<timeshift>> <Key-t>
		bind . <<timeshift>> [list timeshift .ftoolb_Top.bTimeshift]
		event add <<teleview>> <Key-s>
		bind . <<teleview>> {vid_playbackRendering}
		event add <<station_up>> <Key-Prior>
		event add <<station_down>> <Key-Next>
		event add <<station_jump>> <Key-j>
		event add <<station_key>> <Key-0> <Key-1> <Key-2> <Key-3> <Key-4> <Key-5> <Key-6> <Key-7> <Key-8> <Key-9> <Key-KP_Insert> <Key-KP_End> <Key-KP_Down> <Key-KP_Next> <Key-KP_Left> <Key-KP_Begin> <Key-KP_Right> <Key-KP_Home> <Key-KP_Up> <Key-KP_Prior>
		event add <<station_key_lirc>> station_key_lirc
		event add <<station_key_ext>> station_key_ext
		bind . <<station_up>> [list chan_zapperUp .fstations.treeSlist]
		bind . <<station_down>> [list chan_zapperDown .fstations.treeSlist]
		bind . <<station_jump>> [list chan_zapperJump .fstations.treeSlist]
		bind . <<station_key>> [list chan_zapperStationNrKeys %A]
		bind . <<station_key_lirc>> [list chan_zapperStationNrKeys %d]
		bind . <<station_key_ext>> [list chan_zapperStationNr .fstations.treeSlist %d]
		bind . <<record>> [list record_wizardUi]
	}
}

proc event_deleSedit {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: event_deleSedit \033\[0m \{$handler\}"
	event delete <<record>>
	bind . <<record>> {}
	event delete <<timeshift>>
	bind . <<timeshift>> {}
	event delete <<teleview>>
	bind . <<teleview>> {}
	if {"$handler" == "nokanal"} {
		event delete <<station_up>>
		event delete <<station_down>>
		event delete <<station_jump>>
		event delete <<station_key>>
		event delete <<station_key_lirc>>
		event delete <<station_key_ext>>
		bind . <<station_up>> {}
		bind . <<station_down>> {}
		bind . <<station_jump>> {}
		bind . <<station_key>> {}
		bind . <<station_key_lirc>> {}
		bind . <<station_key_ext>> {}
	}
}

proc event_recordStart {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: event_recordStart \033\[0m \{$handler\}"
	if {$::option(rec_allow_sta_change) == 0} {
		bind . <<station_up>> {}
		bind . <<station_down>> {}
		bind . <<station_jump>> {}
		bind . <<station_key>> {}
		bind . <<station_key_lirc>> {}
		bind . <<station_key_ext>> {}
		bind . <<input_up>> {}
		bind . <<input_down>> {}
	}
	bind . <<stop>> {vid_playbackStop 1 pic}
	bind . <<forward_end>> {vid_seekInitiate "vid_seek 0 2"}
	bind . <<forward_10s>> {vid_seekInitiate "vid_seek 10 1"}
	bind . <<forward_1m>> {vid_seekInitiate "vid_seek 60 1"}
	bind . <<forward_10m>> {vid_seekInitiate "vid_seek 600 1"}
	bind . <<rewind_10s>> {vid_seekInitiate "vid_seek 10 -1"}
	bind . <<rewind_1m>> {vid_seekInitiate "vid_seek 60 -1"}
	bind . <<rewind_10m>> {vid_seekInitiate "vid_seek 600 -1"}
	bind . <<rewind_start>> {vid_seekInitiate "vid_seek 0 -2"}
	bind . <<teleview>> {}
	bind . <Control-Key-m> {}
	bind . <Control-Key-e> {}
	if {"$handler" != "timeshift"} {
		vid_pmhandlerButton {{1 disabled}} {100 0} {100 0}
		vid_pmhandlerMenuTv {{4 disabled}} {{7 disabled}} 
		vid_pmhandlerMenuTray {{7 disabled}}
		bind . <<timeshift>> {}
	}
}

proc event_recordStop {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: event_recordStop \033\[0m"
	bind . <<teleview>> {vid_playbackRendering}
	bind . <<station_up>> [list chan_zapperUp .fstations.treeSlist]
	bind . <<station_down>> [list chan_zapperDown .fstations.treeSlist]
	bind . <<station_jump>> [list chan_zapperJump .fstations.treeSlist]
	bind . <<station_key>> [list chan_zapperStationNrKeys %A]
	bind . <<station_key_lirc>> [list chan_zapperStationNrKeys %d]
	bind . <<station_key_ext>> [list chan_zapperStationNr .fstations.treeSlist %d]
	bind . <<input_up>> [list chan_zapperInput 1 1]
	bind . <<input_down>> [list chan_zapperInput 1 -1]
	bind . <<timeshift>> [list timeshift .ftoolb_Top.bTimeshift]
	bind . <Control-Key-m> {colorm_mainUi}
	bind . <Control-Key-e> {station_editUi}
}
