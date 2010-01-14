#       event_bind.tcl
#       © Copyright 2007-2010 Christian Rapp <saedelaere@arcor.de>
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

proc event_constrNoArray {} {
	set wfbar .options_bar
	set wftop .top_buttons
	set wfbottom .bottom_buttons
	
	bind . <Key-m> [list tv_playerVolumeControl $wfbottom mute]
	bind . <Key-F1> [list info_helpHelp]
	bind . <Alt-Key-o> [list event generate $wfbar.mb_options <<Invoke>>]
	bind . <Alt-Key-h> [list event generate $wfbar.mb_help <<Invoke>>]
	bind . <Control-Key-p> {config_wizardMainUi}
	bind . <Control-Key-m> {colorm_mainUi}
	bind . <Control-Key-e> {station_editUi}
	event add <<exit>> <Control-Key-x>
	bind . <<exit>> {main_frontendExitViewer}
	event add <<input_up>> <Control-Key-i>
	event add <<input_down>> <Control-Alt-Key-i>
	bind . <<input_up>> [list main_stationInput 1 1]
	bind . <<input_down>> [list main_stationInput 1 -1]
	event add <<volume_incr>> <Key-plus> <Key-KP_Add>
	event add <<volume_decr>> <Key-minus> <Key-KP_Subtract>
	bind . <<volume_decr>> {tv_playerVolumeControl .bottom_buttons [expr $::main(volume_scale) - 3]}
	bind . <<volume_incr>> {tv_playerVolumeControl .bottom_buttons [expr $::main(volume_scale) + 3]}
	event add <<forward_end>> <Key-End>
	event add <<forward_10s>> <Key-Right>
	event add <<forward_1m>> <Shift-Key-Right>
	event add <<forward_10m>> <Control-Shift-Key-Right>
	event add <<rewind_start>> <Key-Home>
	event add <<rewind_10s>> <Key-Left>
	event add <<rewind_1m>> <Shift-Key-Left>
	event add <<rewind_1m>> <Control-Shift-Key-Left>
	event add <<pause>> <Key-p>
	event add <<start>> <Shift-Key-P>
	event add <<stop>> <Shift-Key-S>
}

proc event_constrArray {} {
	set wfbar .options_bar
	set wftop .top_buttons
	set wfbottom .bottom_buttons
	
	bind . <Key-m> [list tv_playerVolumeControl $wfbottom mute]
	bind . <Key-F1> [list info_helpHelp]
	bind . <Alt-Key-o> [list event generate $wfbar.mb_options <<Invoke>>]
	bind . <Alt-Key-h> [list event generate $wfbar.mb_help <<Invoke>>]
	bind . <Control-Key-p> {config_wizardMainUi}
	bind . <Control-Key-m> {colorm_mainUi}
	bind . <Control-Key-e> {station_editUi}
	event add <<exit>> <Control-Key-x>
	bind . <<exit>> {main_frontendExitViewer}
	event add <<input_up>> <Control-Key-i>
	event add <<input_down>> <Control-Alt-Key-i>
	bind . <<input_up>> [list main_stationInput 1 1]
	bind . <<input_down>> [list main_stationInput 1 -1]
	event add <<record>> <Key-r>
	bind . <<record>> [list record_wizardUi]
	event add <<timeshift>> <Key-t>
	bind . <<timeshift>> [list timeshift $wftop.button_timeshift]
	event add <<teleview>> <Key-s>
	bind . <<teleview>> {tv_playerRendering}
	event add <<station_up>> <Key-Prior>
	event add <<station_down>> <Key-Next>
	event add <<station_jump>> <Key-j>
	event add <<station_key>> <Key-0> <Key-1> <Key-2> <Key-3> <Key-4> <Key-5> <Key-6> <Key-7> <Key-8> <Key-9> <Key-KP_Insert> <Key-KP_End> <Key-KP_Down> <Key-KP_Next> <Key-KP_Left> <Key-KP_Begin> <Key-KP_Right> <Key-KP_Home> <Key-KP_Up> <Key-KP_Prior>
	event add <<station_key_lirc>> station_key_lirc
	event add <<station_key_ext>> station_key_ext
	bind . <<station_up>> [list main_stationChannelUp .label_stations]
	bind . <<station_down>> [list main_stationChannelDown .label_stations]
	bind . <<station_jump>> [list main_stationChannelJumper .label_stations]
	bind . <<station_key>> [list main_stationStationNrKeys %A]
	bind . <<station_key_lirc>> [list main_stationStationNrKeys %d]
	bind . <<station_key_ext>> [list main_stationStationNr .label_stations %d]
	event add <<volume_incr>> <Key-plus> <Key-KP_Add>
	event add <<volume_decr>> <Key-minus> <Key-KP_Subtract>
	bind . <<volume_decr>> {tv_playerVolumeControl .bottom_buttons [expr $::main(volume_scale) - 3]}
	bind . <<volume_incr>> {tv_playerVolumeControl .bottom_buttons [expr $::main(volume_scale) + 3]}
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
}

proc event_deleSedit {} {
	event delete <<record>>
	bind . <<record>> {}
	event delete <<timeshift>>
	bind . <<timeshift>> {}
	event delete <<teleview>>
	bind . <<teleview>> {}
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

proc event_recordStart {handler} {
	if {$::option(rec_allow_sta_change) == 0} {
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
		bind . <<station_key_ext>> {}
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
	bind . <Control-Key-m> {}
	bind . <Control-Key-e> {}
	bind .tv <<teleview>> {}
	bind .tv <Control-Key-m> {}
	bind .tv <Control-Key-e> {}
	if {"$handler" != "timeshift"} {
		.top_buttons.button_timeshift state disabled
		bind . <<timeshift>> {}
		bind .tv <<timeshift>> {}
	}
}

proc event_recordStop {} {
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
	bind . <<station_key_ext>> [list main_stationStationNr .label_stations %d]
	bind . <<input_up>> [list main_stationInput 1 1]
	bind . <<input_down>> [list main_stationInput 1 -1]
	bind . <<timeshift>> [list timeshift .top_buttons.button_timeshift]
	bind .tv <Control-Key-m> {colorm_mainUi}
	bind .tv <Control-Key-e> {station_editUi}
	bind . <Control-Key-m> {colorm_mainUi}
	bind . <Control-Key-e> {station_editUi}
}
