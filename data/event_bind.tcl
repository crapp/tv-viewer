#       event_bind.tcl
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

proc event_constr {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: event_constr \033\[0m \{$handler\}"
	#Construct events and make necessary bindings
	#handler 0 == nokanal; 1 == existing stations
	event add <<menuTv>> {*}[dict get $::keyseq mTv seq]
	bind . <<menuTv>> [list event generate .foptions_bar.mbTvviewer <<Invoke>>]
	event add <<menuNav>> {*}[dict get $::keyseq mNav seq]
	bind . <<menuNav>> [list event generate .foptions_bar.mbNavigation <<Invoke>>]
	event add <<menuView>> {*}[dict get $::keyseq mView seq]
	bind . <<menuView>> [list event generate .foptions_bar.mbView <<Invoke>>]
	event add <<menuAudio>> {*}[dict get $::keyseq mAudio seq]
	bind . <<menuAudio>> [list event generate .foptions_bar.mbAudio <<Invoke>>]
	event add <<menuHelp>> {*}[dict get $::keyseq mHelp seq]
	bind . <<menuHelp>> [list event generate .foptions_bar.mbHelp <<Invoke>>]
	
	event add <<prefs>> {*}[dict get $::keyseq preferences seq]
	bind . <<prefs>> {config_wizardMainUi}
	event add <<colorm>> {*}[dict get $::keyseq colorm seq]
	bind . <<colorm>> {colorm_mainUi}
	event add <<sedit>> {*}[dict get $::keyseq sedit seq]
	bind . <<sedit>> {station_editUi}
	event add <<help>> {*}[dict get $::keyseq help seq]
	bind . <<help>> [list info_helpHelp]
	event add <<exit>> <Control-Key-x>
	bind . <<exit>> {main_frontendExitViewer}
	
	event add <<input_next>> {*}[dict get $::keyseq vinputNext seq]
	event add <<input_prior>> {*}[dict get $::keyseq vinputPrior seq]
	bind . <<input_next>> [list chan_zapperInput 1 1]
	bind . <<input_prior>> [list chan_zapperInput 1 -1]
	event add <<volume_incr>> {*}[dict get $::keyseq volInc seq]
	event add <<volume_decr>> {*}[dict get $::keyseq volDec seq]
	bind . <<volume_decr>> {vid_audioVolumeControl .ftoolb_Play.scVolume .ftoolb_Play.bVolMute [expr $::main(volume_scale) - 3]}
	bind . <<volume_incr>> {vid_audioVolumeControl .ftoolb_Play.scVolume .ftoolb_Play.bVolMute [expr $::main(volume_scale) + 3]}
	event add <<delay_incr>> {*}[dict get $::keyseq delayInc seq]
	event add <<delay_decr>> {*}[dict get $::keyseq delayDec seq]
	bind . <<delay_incr>> {vid_playerAudioDelay incr}
	bind . <<delay_decr>> {vid_playerAudioDelay decr}
	event add <<mute>> {*}[dict get $::keyseq volMute seq]
	bind . <<mute>> [list vid_audioVolumeControl .ftoolb_Play.scVolume .ftoolb_Play.bVolMute mute]
	
	event add <<forward_end>> {*}[dict get $::keyseq fileEnd seq]
	event add <<forward_10s>> {*}[dict get $::keyseq fileFow10s seq]
	event add <<forward_1m>> {*}[dict get $::keyseq fileFow1m seq]
	event add <<forward_10m>> {*}[dict get $::keyseq fileFow10m seq]
	event add <<rewind_start>> {*}[dict get $::keyseq fileHome seq]
	event add <<rewind_10s>> {*}[dict get $::keyseq fileRew10s seq]
	event add <<rewind_1m>> {*}[dict get $::keyseq fileRew1m seq]
	event add <<rewind_10m>> {*}[dict get $::keyseq fileRew10m seq]
	event add <<pause>> {*}[dict get $::keyseq filePause seq]
	event add <<start>> {*}[dict get $::keyseq filePlay seq]
	event add <<stop>> {*}[dict get $::keyseq fileStop seq]
	
	event add <<wmFull>> {*}[dict get $::keyseq wmFull seq]
	bind . <<wmFull>> [list vid_wmFullscreen . .fvidBg .fvidBg.cont]
	bind .fvidBg.cont <Double-ButtonPress-1> {event generate . <<wmFull>>}
	bind .fvidBg <Double-ButtonPress-1> {event generate . <<wmFull>>}
	event add <<wmCompact>> {*}[dict get $::keyseq wmCompact seq]
	bind . <<wmCompact>> vid_wmCompact
	event add <<wmZoomIncSmall>> {*}[dict get $::keyseq wmZoomIncSmall seq]
	bind . <<wmZoomIncSmall>> [list vid_wmPanscan .fvidBg.cont 1 1]
	event add <<wmZoomIncBig>> {*}[dict get $::keyseq wmZoomIncBig seq]
	bind . <<wmZoomIncBig>> [list vid_wmPanscan .fvidBg.cont 1 2]
	event add <<wmZoomDecSmall>> {*}[dict get $::keyseq wmZoomDecSmall seq]
	bind . <<wmZoomDecSmall>> [list vid_wmPanscan .fvidBg.cont -1 1]
	event add <<wmZoomDecBig>> {*}[dict get $::keyseq wmZoomDecBig seq]
	bind . <<wmZoomDecBig>> [list vid_wmPanscan .fvidBg.cont -1 2]
	event add <<wmZoomReset>> {*}[dict get $::keyseq wmZoomReset seq]
	bind . <<wmZoomReset>> {vid_wmPanscan .fvidBg.cont 2 1}
	event add <<wmZoomAuto>> {*}[dict get $::keyseq wmZoomAuto seq]
	bind . <<wmZoomAuto>> {vid_wmPanscanAuto}
	event add <<wmMoveRight>> {*}[dict get $::keyseq wmMoveRight seq]
	event add <<wmMoveDown>> {*}[dict get $::keyseq wmMoveDown seq]
	event add <<wmMoveLeft>> {*}[dict get $::keyseq wmMoveLeft seq]
	event add <<wmMoveUp>> {*}[dict get $::keyseq wmMoveUp seq]
	event add <<wmMoveCenter>> {*}[dict get $::keyseq wmMoveCenter seq]
	bind . <<wmMoveRight>> [list vid_wmMoveVideo 0]
	bind . <<wmMoveDown>> [list vid_wmMoveVideo 1]
	bind . <<wmMoveLeft>> [list vid_wmMoveVideo 2]
	bind . <<wmMoveUp>> [list vid_wmMoveVideo 3]
	bind . <<wmMoveCenter>> [list vid_wmMoveVideo 4]
	event add <<wmSize1>> {*}[dict get $::keyseq wmSize1 seq]
	bind . <<wmSize1>> [list vid_wmGivenSize .fvidBg 1.0]
	event add <<wmSize2>> {*}[dict get $::keyseq wmSize2 seq]
	bind . <<wmSize2>> [list vid_wmGivenSize .fvidBg 2.0]
	event add <<wmMainToolbar>> {*}[dict get $::keyseq wmMainToolbar seq]
	bind . <<wmMainToolbar>> [list vid_wmViewToolb main]
	event add <<wmStationList>> {*}[dict get $::keyseq wmStationList seq]
	bind . <<wmStationList>> [list vid_wmViewToolb station]
	event add <<wmControlbar>> {*}[dict get $::keyseq wmControlbar seq]
	bind . <<wmControlbar>> [list vid_wmViewToolb control]
	
	bind .fvidBg <Button-3> [list tk_popup .fvidBg.mContext %X %Y]
	bind .fvidBg.cont <Button-3> [list tk_popup .fvidBg.mContext %X %Y]
	
	event add <<scrshot>> {*}[dict get $::keyseq scrshot seq]
	bind . <<scrshot>> [list vid_callbackMplayerRemote "screenshot 0"]
	
	if {$handler} {
		event add <<record>> {*}[dict get $::keyseq recWizard seq]
		bind . <<record>> [list record_wizardUi]
		event add <<timeshift>> {*}[dict get $::keyseq recTime seq]
		bind . <<timeshift>> [list timeshift .ftoolb_Top.bTimeshift]
		event add <<teleview>> {*}[dict get $::keyseq startTv seq]
		bind . <<teleview>> {vid_playbackRendering}
		event add <<stationPrior>> {*}[dict get $::keyseq stationPrior seq]
		event add <<stationNext>> {*}[dict get $::keyseq stationNext seq]
		event add <<stationJump>> {*}[dict get $::keyseq stationJump seq]
		event add <<station_key>> <Key-0> <Key-1> <Key-2> <Key-3> <Key-4> <Key-5> <Key-6> <Key-7> <Key-8> <Key-9> <Key-KP_Insert> <Key-KP_End> <Key-KP_Down> <Key-KP_Next> <Key-KP_Left> <Key-KP_Begin> <Key-KP_Right> <Key-KP_Home> <Key-KP_Up> <Key-KP_Prior>
		event add <<station_key_lirc>> station_key_lirc
		event add <<station_key_ext>> station_key_ext
		bind . <<stationPrior>> [list chan_zapperPrior .fstations.treeSlist]
		bind . <<stationNext>> [list chan_zapperNext .fstations.treeSlist]
		bind . <<stationJump>> [list chan_zapperJump .fstations.treeSlist]
		bind . <<station_key>> [list chan_zapperStationNrKeys %A]
		bind . <<station_key_lirc>> [list chan_zapperStationNrKeys %d]
		bind . <<station_key_ext>> [list chan_zapperStationNr .fstations.treeSlist %d]
		bind . <<record>> [list record_wizardUi]
	}
}

proc event_delete {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: event_delete \033\[0m \{$handler\}"
	#handler all = delete all virtual events; nomplay = no mplayer installed; nokanal = no station config file
	if {"$handler" == "all"} {
		set baseEvents {<<Undo>> <<PasteSelection>> <<Copy>> <<Cut>> <<PrevWindow>> <<Redo>> <<Paste>>}
		foreach event [event info] {
			set doDel 1
			foreach baseEvent $baseEvents {
				if {"$event" == "$baseEvent"} {
					set doDel 0
					break
				}
			}
			if {$doDel == 0} {
				continue
			}
			event delete $event
		}
	}
	if {"$handler" == "nomplay"} {
		event delete <<record>>
		bind . <<record>> {}
		event delete <<timeshift>>
		bind . <<timeshift>> {}
		event delete <<teleview>>
		bind . <<teleview>> {}
	}
	if {"$handler" == "nokanal"} {
		event delete <<record>>
		bind . <<record>> {}
		event delete <<timeshift>>
		bind . <<timeshift>> {}
		event delete <<teleview>>
		bind . <<teleview>> {}
		event delete <<stationPrior>>
		event delete <<stationNext>>
		event delete <<stationJump>>
		event delete <<station_key>>
		event delete <<station_key_lirc>>
		event delete <<station_key_ext>>
		bind . <<stationPrior>> {}
		bind . <<stationNext>> {}
		bind . <<stationJump>> {}
		bind . <<station_key>> {}
		bind . <<station_key_lirc>> {}
		bind . <<station_key_ext>> {}
	}
}

proc event_recordStart {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: event_recordStart \033\[0m \{$handler\}"
	if {$::option(rec_allow_sta_change) == 0} {
		bind . <<stationPrior>> {}
		bind . <<stationNext>> {}
		bind . <<<stationJump>> {}
		bind . <<station_key>> {}
		bind . <<station_key_lirc>> {}
		bind . <<station_key_ext>> {}
		bind . <<input_next>> {}
		bind . <<input_prior>> {}
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
	bind . <<colorm>> {}
	bind . <<sedit>> {}
	if {"$handler" != "timeshift"} {
		vid_pmhandlerButton {{1 disabled}} {100 0} {100 0}
		vid_pmhandlerMenuTv {{4 disabled}} {{8 disabled}} 
		vid_pmhandlerMenuTray {{7 disabled}}
		bind . <<timeshift>> {}
	}
}

proc event_recordStop {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: event_recordStop \033\[0m"
	bind . <<teleview>> {vid_playbackRendering}
	bind . <<stationPrior>> [list chan_zapperPrior .fstations.treeSlist]
	bind . <<stationNext>> [list chan_zapperNext .fstations.treeSlist]
	bind . <<stationJump>> [list chan_zapperJump .fstations.treeSlist]
	bind . <<station_key>> [list chan_zapperStationNrKeys %A]
	bind . <<station_key_lirc>> [list chan_zapperStationNrKeys %d]
	bind . <<station_key_ext>> [list chan_zapperStationNr .fstations.treeSlist %d]
	bind . <<input_next>> [list chan_zapperInput 1 1]
	bind . <<input_prior>> [list chan_zapperInput 1 -1]
	bind . <<timeshift>> [list timeshift .ftoolb_Top.bTimeshift]
	bind . <<colorm>> {colorm_mainUi}
	bind . <<sedit>> {station_editUi}
}
