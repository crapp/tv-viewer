#       main_menu.tcl
#       © Copyright 2007-2012 Christian Rapp <christianrapp@users.sourceforge.net>
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

proc main_menuTvview {menubar toolbChanCtrl toolbPlay vidBg handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuTvview \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$vidBg\} \{$handler\}"
	if {"$handler" == "context"} {
		if {[winfo exists $vidBg.mContext] == 0} {
			set mTv [menu $vidBg.mContext -tearoff 0]
			set changeAccels 0
		} else {
			set mTv $vidBg.mContext
			set changeAccels 1
		}
	} else {
		if {[winfo exists $menubar.mbTvviewer.mTvviewer] == 0} {
			set mTv [menu $menubar.mbTvviewer.mTvviewer -tearoff 0 -postcommand [list main_menuPostcommand 0 "$menubar.mbTvviewer $menubar.mbNavigation $menubar.mbView $menubar.mbAudio $menubar.mbHelp" $menubar.mbTvviewer.mTvviewer]]
			set changeAccels 0
		} else {
			set mTv $menubar.mbTvviewer.mTvviewer
			set changeAccels 1
		}
	}
	
	#Fill menu TV-Viewer
	if {$changeAccels} {
		if {"$mTv" == ".fvidBg.mContext"} {
			$mTv entryconfigure 4 -accelerator [dict get $::keyseq colorm name]
			$mTv entryconfigure 5 -accelerator [dict get $::keyseq preferences name]
			$mTv entryconfigure 6 -accelerator [dict get $::keyseq sedit name]
			$mTv entryconfigure 8 -accelerator [dict get $::keyseq recTime name]
			$mTv entryconfigure 9 -accelerator [dict get $::keyseq recWizard name]
			$mTv entryconfigure 12 -accelerator [dict get $::keyseq startTv name]
		} else {
			$mTv entryconfigure 0 -accelerator [dict get $::keyseq colorm name]
			$mTv entryconfigure 1 -accelerator [dict get $::keyseq preferences name]
			$mTv entryconfigure 2 -accelerator [dict get $::keyseq sedit name]
			$mTv entryconfigure 4 -accelerator [dict get $::keyseq recTime name]
			$mTv entryconfigure 5 -accelerator [dict get $::keyseq recWizard name]
			$mTv entryconfigure 8 -accelerator [dict get $::keyseq startTv name]
		}
	} else {
		$mTv add command -label [mc "Color Management"] -compound left -image $::icon_men(color-management) -command colorm_mainUi -accelerator [dict get $::keyseq colorm name]
		$mTv add command -label [mc "Preferences"] -compound left -image $::icon_men(settings) -accelerator [dict get $::keyseq preferences name] -command {config_wizardMainUi}
		$mTv add command -label [mc "Station Editor"] -compound left -image $::icon_men(seditor) -command {station_editUi} -accelerator [dict get $::keyseq sedit name]
		$mTv add separator
		$mTv add command -label [mc "Timeshift"] -compound left -image $::icon_men(timeshift) -command {event generate . <<timeshift>>} -accelerator [dict get $::keyseq recTime name]
		$mTv add command -label [mc "Record Wizard"] -compound left -image $::icon_men(record) -command {event generate . <<record>>} -accelerator [dict get $::keyseq recWizard name]
		$mTv add command -label [mc "EPG"] -compound left -image $::icon_men(placeholder) -command main_frontendEpg -accelerator ""
		$mTv add command -label [mc "Radio"] -compound left -image $::icon_men(radio) -command "" -accelerator ""
		$mTv add command -label [mc "TV"] -compound left -image $::icon_men(starttv) -command {event generate . <<teleview>>} -accelerator [dict get $::keyseq startTv name]
		$mTv add separator
		$mTv add command -label [mc "Newsreader"] -compound left -image $::icon_men(newsreader) -command [list main_newsreaderCheckUpdate 0]
		$mTv add checkbutton -label [mc "System Tray"] -command {system_trayActivate 0} -variable menu(cbSystray)
		$mTv add separator
		$mTv add command -label [mc "Exit"] -compound left -image $::icon_men(dialog-close) -command [list event generate . <<exit>>] -accelerator "Ctrl+X"
	}
}

proc main_menuNav {menubar toolbChanCtrl toolbPlay vidBg handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuNav \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$vidBg\} \{$handler\}"
	if {"$handler" == "context"} {
		set menubar .fvidBg.mContext
		if {[winfo exists $menubar.mNavigation] == 0} {
			set mNav [menu $menubar.mNavigation -tearoff 0]
				set mNavRew [menu $menubar.mNavigationRewind -tearoff 0]
				set mNavForw [menu $menubar.mNavigationForward -tearoff 0]
			$menubar insert 0 cascade -label [mc "Navigation"] -compound left -image $::icon_men(placeholder) -menu $mNav
			set changeAccels 0
		} else {
			set mNav $menubar.mNavigation
				set mNavRew $menubar.mNavigationRewind
				set mNavForw $menubar.mNavigationForward
			set changeAccels 1
		}
	} else {
		if {[winfo exists $menubar.mbNavigation.mNavigation] == 0} {
			set mNav [menu $menubar.mbNavigation.mNavigation -tearoff 0 -postcommand [list main_menuPostcommand 1 "$menubar.mbTvviewer $menubar.mbNavigation $menubar.mbView $menubar.mbAudio $menubar.mbHelp" $menubar.mbNavigation.mNavigation]]
				set mNavRew [menu $menubar.mbNavigation.mNavigation.mNavigationRewind -tearoff 0 ]
				set mNavForw [menu $menubar.mbNavigation.mNavigation.mNavigationForward -tearoff 0 ]
			set changeAccels 0
		} else {
			set mNav $menubar.mbNavigation.mNavigation
				set mNavRew $menubar.mbNavigation.mNavigation.mNavigationRewind
				set mNavForw $menubar.mbNavigation.mNavigation.mNavigationForward
			set changeAccels 1
		}
	}
	
	#$mNav add separator
	if {$changeAccels} {
		$mNav entryconfigure 0 -accelerator [dict get $::keyseq stationPrior name]
		$mNav entryconfigure 1 -accelerator [dict get $::keyseq stationNext name]
		$mNav entryconfigure 2 -accelerator [dict get $::keyseq stationJump name]
		$mNav entryconfigure 4 -accelerator [dict get $::keyseq filePlay name]
		$mNav entryconfigure 5 -accelerator [dict get $::keyseq filePause name]
		$mNav entryconfigure 6 -accelerator [dict get $::keyseq fileStop name]
			$mNavRew entryconfigure 0 -accelerator [dict get $::keyseq fileRew10s name]
			$mNavRew entryconfigure 1 -accelerator [dict get $::keyseq fileRew1m name]
			$mNavRew entryconfigure 2 -accelerator [dict get $::keyseq fileRew10m name]
			$mNavRew entryconfigure 3 -accelerator [dict get $::keyseq fileHome name]
			$mNavForw entryconfigure 0 -accelerator [dict get $::keyseq fileFow10s name]
			$mNavForw entryconfigure 1 -accelerator [dict get $::keyseq fileFow1m name]
			$mNavForw entryconfigure 2 -accelerator [dict get $::keyseq fileFow10m name]
			$mNavForw entryconfigure 3 -accelerator [dict get $::keyseq fileEnd name]
	} else {
		$mNav add command -label [mc "Prior Station"] -compound left -image $::icon_men(channel-prior) -command [list chan_zapperPrior .fstations.treeSlist] -accelerator [dict get $::keyseq stationPrior name]
		$mNav add command -label [mc "Next Station"] -compound left -image $::icon_men(channel-next) -command [list chan_zapperNext .fstations.treeSlist] -accelerator [dict get $::keyseq stationNext name]
		$mNav add command -label [mc "Station jumper"] -compound left -image $::icon_men(channel-jump) -command [list chan_zapperJump .fstations.treeSlist] -accelerator [dict get $::keyseq stationJump name]
		$mNav add separator
		$mNav add command -label [mc "Play"] -compound left -image $::icon_men(playback-start) -command {event generate . <<start>>} -state disabled -accelerator [dict get $::keyseq filePlay name]
		$mNav add command -label [mc "Pause"] -compound left -image $::icon_men(playback-pause) -command {event generate . <<pause>>} -state disabled -accelerator [dict get $::keyseq filePause name]
		$mNav add command -label [mc "Stop"] -compound left -image $::icon_men(playback-stop) -command {event generate . <<stop>>} -state disabled -accelerator [dict get $::keyseq fileStop name]
		$mNav add separator
		$mNav add cascade -label [mc "Rewind"] -compound left -image $::icon_men(rewind-small) -state disabled -menu $mNavRew
			$mNavRew add command -label [mc "-10 seconds"] -compound left -image $::icon_men(rewind-small) -command {event generate . <<rewind_10s>>} -accelerator [dict get $::keyseq fileRew10s name]
			$mNavRew add command -label [mc "-1 minute"] -compound left -image $::icon_men(rewind-small) -command {event generate . <<rewind_1m>>} -accelerator [dict get $::keyseq fileRew1m name]
			$mNavRew add command -label [mc "-10 minutes"] -compound left -image $::icon_men(rewind-small) -command {event generate . <<rewind_10m>>} -accelerator [dict get $::keyseq fileRew10m name]
			$mNavRew add command -label [mc "File beginning"] -compound left -image $::icon_men(rewind-first) -command {event generate . <<rewind_start>>} -accelerator [dict get $::keyseq fileHome name]
		$mNav add cascade -label [mc "Forward"] -compound left -image $::icon_men(forward-small) -state disabled -menu $mNavForw
			$mNavForw add command -label [mc "+10 seconds"] -compound left -image $::icon_men(forward-small) -command {event generate . <<forward_10s>>} -accelerator [dict get $::keyseq fileFow10s name]
			$mNavForw add command -label [mc "+1 minute"] -compound left -image $::icon_men(forward-small) -command {event generate . <<forward_1m>>} -accelerator [dict get $::keyseq fileFow1m name]
			$mNavForw add command -label [mc "+10 minutes"] -compound left -image $::icon_men(forward-small) -command {event generate . <<forward_10m>>} -accelerator [dict get $::keyseq fileFow10m name]
			$mNavForw add command -label [mc "File end"] -compound left -image $::icon_men(forward-last) -command {event generate . <<forward_end>>} -accelerator [dict get $::keyseq fileEnd name]
	}
}

proc main_menuView {menubar toolbChanCtrl toolbPlay vidBg handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuView \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$vidBg\} \{$handler\}"
	if {"$handler" == "context"} {
		set menubar .fvidBg.mContext
		if {[winfo exists $menubar.mView] == 0} {
			set mView [menu $menubar.mView -tearoff 0]
				set mViewPan [menu $menubar.mViewPanScan -tearoff 0]
				set mViewSize [menu $menubar.mViewSize -tearoff 0]
				set mViewMove [menu $menubar.mViewMove -tearoff 0]
				set mViewTop [menu $menubar.mViewTop -tearoff 0]
				set mViewToolb [menu $menubar.mViewToolb -tearoff 0]
				set mViewStatusb [menu $menubar.mViewStatusb -tearoff 0]
			$menubar insert 1 cascade -label [mc "View"] -compound left -image $::icon_men(placeholder) -menu $mView
			set changeAccels 0
		} else {
			set mView $menubar.mView
				set mViewPan $menubar.mViewPanScan
				set mViewSize $menubar.mViewSize
				set mViewMove $menubar.mViewMove
				set mViewTop $menubar.mViewTop
				set mViewToolb $menubar.mViewToolb
				set mViewStatusb $menubar.mViewStatusb
			set changeAccels 1
		}
	} else {
		if {[winfo exists $menubar.mbView.mView] == 0} {
			set mView [menu $menubar.mbView.mView -tearoff 0 -postcommand [list main_menuPostcommand 2 "$menubar.mbTvviewer $menubar.mbNavigation $menubar.mbView $menubar.mbAudio $menubar.mbHelp" $menubar.mbView.mView]]
				set mViewPan [menu $menubar.mbView.mView.mViewPanScan -tearoff 0]
				set mViewSize [menu $menubar.mbView.mView.mViewSize -tearoff 0]
				set mViewMove [menu $menubar.mbView.mView.mViewMove -tearoff 0]
				set mViewTop [menu $menubar.mbView.mView.mViewTop -tearoff 0]
				set mViewToolb [menu $menubar.mbView.mView.mViewToolb -tearoff 0]
				set mViewStatusb [menu $menubar.mbView.mView.mViewStatusb -tearoff 0]
			set changeAccels 0
		} else {
			set mView $menubar.mbView.mView
				set mViewPan $menubar.mbView.mView.mViewPanScan
				set mViewSize $menubar.mbView.mView.mViewSize
				set mViewMove $menubar.mbView.mView.mViewMove
				set mViewTop $menubar.mbView.mView.mViewTop
				set mViewToolb $menubar.mbView.mView.mViewToolb
				set mViewStatusb $menubar.mbView.mView.mViewStatusb
			set changeAccels 1
		}
	}
	
	if {$changeAccels} {
			$mViewPan entryconfigure 0 -accelerator [dict get $::keyseq wmZoomIncSmall name]
			$mViewPan entryconfigure 1 -accelerator [dict get $::keyseq wmZoomIncBig name]
			$mViewPan entryconfigure 2 -accelerator [dict get $::keyseq wmZoomDecSmall name]
			$mViewPan entryconfigure 3 -accelerator [dict get $::keyseq wmZoomDecBig name]
			$mViewPan entryconfigure 4 -accelerator [dict get $::keyseq wmZoomReset name]
			$mViewPan entryconfigure 5 -accelerator [dict get $::keyseq wmZoomAuto name]
			$mViewPan entryconfigure 7 -accelerator [dict get $::keyseq wmMoveUp name]
			$mViewPan entryconfigure 8 -accelerator [dict get $::keyseq wmMoveDown name]
			$mViewPan entryconfigure 9 -accelerator [dict get $::keyseq wmMoveLeft name]
			$mViewPan entryconfigure 10 -accelerator [dict get $::keyseq wmMoveRight name]
			$mViewPan entryconfigure 11 -accelerator [dict get $::keyseq wmMoveCenter name]
			$mViewSize entryconfigure 2 -accelerator [dict get $::keyseq wmSize1 name]
			$mViewSize entryconfigure 6 -accelerator [dict get $::keyseq wmSize2 name]
			$mViewToolb entryconfigure 0 -accelerator [dict get $::keyseq wmMainToolbar name]
			$mViewToolb entryconfigure 1 -accelerator [dict get $::keyseq wmStationList name]
			$mViewToolb entryconfigure 2 -accelerator [dict get $::keyseq wmControlbar name]
		$mView entryconfigure 5 -accelerator [dict get $::keyseq wmCompact name]
		$mView entryconfigure 6 -accelerator [dict get $::keyseq wmFull name]
	} else {
		$mView add cascade -label [mc "Pan&Scan"] -compound left -image $::icon_men(placeholder) -menu $mViewPan
			$mViewPan add command -label [mc "Zoom +"] -compound left -image $::icon_men(placeholder) -command {event generate . <<wmZoomIncSmall>>} -accelerator [dict get $::keyseq wmZoomIncSmall name]
			$mViewPan add command -label [mc "Zoom ++"] -compound left -image $::icon_men(placeholder) -command {event generate . <<wmZoomIncBig>>} -accelerator [dict get $::keyseq wmZoomIncBig name]
			$mViewPan add command -label [mc "Zoom -"] -compound left -image $::icon_men(placeholder) -command {event generate . <<wmZoomDecSmall>>} -accelerator [dict get $::keyseq wmZoomDecSmall name]
			$mViewPan add command -label [mc "Zoom --"] -compound left -image $::icon_men(placeholder) -command {event generate . <<wmZoomDecBig>>} -accelerator [dict get $::keyseq wmZoomDecBig name]
			$mViewPan add command -label [mc "Reset zoom"] -compound left -image $::icon_men(placeholder) -command {event generate . <<wmZoomReset>>} -accelerator [dict get $::keyseq wmZoomReset name]
			$mViewPan add command -label [mc "Pan&Scan (16:9 / 4:3)"] -compound left -image $::icon_men(placeholder) -command {event generate . <<wmZoomAuto>>} -accelerator [dict get $::keyseq wmZoomAuto name]
			$mViewPan add separator
			$mViewPan add command -label [mc "Move up"] -compound left -image $::icon_men(placeholder) -command {event generate . <<wmMoveUp>>} -accelerator [dict get $::keyseq wmMoveUp name]
			$mViewPan add command -label [mc "Move down"] -compound left -image $::icon_men(placeholder) -command {event generate . <<wmMoveDown>>} -accelerator [dict get $::keyseq wmMoveDown name]
			$mViewPan add command -label [mc "Move left"] -compound left -image $::icon_men(placeholder) -command {event generate . <<wmMoveLeft>>} -accelerator [dict get $::keyseq wmMoveLeft name]
			$mViewPan add command -label [mc "Move right"] -compound left -image $::icon_men(placeholder) -command {event generate . <<wmMoveRight>>} -accelerator [dict get $::keyseq wmMoveRight name]
			$mViewPan add command -label [mc "Center video"] -compound left -image $::icon_men(placeholder) -command {event generate . <<wmMoveCenter>>} -accelerator [dict get $::keyseq wmMoveCenter name]
		$mView add cascade -label [mc "Size"] -compound left -image $::icon_men(placeholder) -menu $mViewSize
			$mViewSize add command -label "50%" -compound left -image $::icon_men(placeholder) -command [list vid_wmGivenSize .fvidBg 0.5]
			$mViewSize add command -label "75%" -compound left -image $::icon_men(placeholder) -command [list vid_wmGivenSize .fvidBg 0.75]
			$mViewSize add command -label "100%" -compound left -image $::icon_men(placeholder) -command {event generate . <<wmSize1>>} -accelerator [dict get $::keyseq wmSize1 name]
			$mViewSize add command -label "125%" -compound left -image $::icon_men(placeholder) -command [list vid_wmGivenSize .fvidBg 1.25]
			$mViewSize add command -label "150%" -compound left -image $::icon_men(placeholder) -command [list vid_wmGivenSize .fvidBg 1.5]
			$mViewSize add command -label "175%" -compound left -image $::icon_men(placeholder) -command [list vid_wmGivenSize .fvidBg 1.75]
			$mViewSize add command -label "200%" -compound left -image $::icon_men(placeholder) -command {event generate . <<wmSize2>>} -accelerator [dict get $::keyseq wmSize2 name]
		$mView add cascade -label [mc "Stay on top"] -compound left -image $::icon_men(placeholder) -menu $mViewTop
			$mViewTop add radiobutton -label [mc "Never"] -variable vid(stayontop) -value 0 -command [list vid_wmStayonTop 0]
			$mViewTop add radiobutton -label [mc "Always"] -variable vid(stayontop) -value 1 -command [list vid_wmStayonTop 1]
			$mViewTop add radiobutton -label [mc "While playback"] -variable vid(stayontop) -value 2 -command [list vid_wmStayonTop 2]
		$mView add cascade -label [mc "Toolbars"] -compound left -image $::icon_men(placeholder) -menu $mViewToolb
			$mViewToolb add checkbutton -label [mc "Main toolbar"] -variable menu(cbViewMainToolbar) -command {event generate . <<wmMainToolbar>>} -accelerator [dict get $::keyseq wmMainToolbar name]
			$mViewToolb add checkbutton -label [mc "Station list"] -variable menu(cbViewStationl) -command {event generate . <<wmStationList>>} -accelerator [dict get $::keyseq wmStationList name]
			$mViewToolb add checkbutton -label [mc "Control toolbar"] -variable menu(cbViewControlbar) -command {event generate . <<wmControlbar>>} -accelerator [dict get $::keyseq wmControlbar name]
		$mView add cascade -label [mc "Statusbar"] -compound left -image $::icon_men(placeholder) -menu $mViewStatusb
			$mViewStatusb add checkbutton -label [mc "Show status messages"] -variable menu(cbViewStatusm) -command {vid_wmViewStatus ltxt}
			$mViewStatusb add checkbutton -label [mc "Show playback time"] -variable menu(cbViewStatust) -command {vid_wmViewStatus ltm}
		$mView add command -command {event generate . <<wmCompact>>} -compound left -image $::icon_men(compact) -label [mc "Compact mode"] -accelerator [dict get $::keyseq wmCompact name]
		$mView add command -command {event generate . <<wmFull>>} -compound left -image $::icon_men(fullscreen) -label [mc "Fullscreen"] -accelerator [dict get $::keyseq wmFull name]
		set ::menu(cbViewMainToolbar) $::mem(toolbMain)
		set ::menu(cbViewStationl) $::mem(toolbStation)
		set ::menu(cbViewControlbar) $::mem(toolbControl)
		set ::menu(cbViewStatusm) $::mem(sbarStatus)
		set ::menu(cbViewStatust) $::mem(sbarTime)
	}
}

proc main_menuAud {menubar toolbChanCtrl toolbPlay vidBg handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuAud \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$vidBg\} \{$handler\}"
	if {"$handler" == "context"} {
		set menubar .fvidBg.mContext
		if {[winfo exists $menubar.mAudio] == 0} {
			set mAud [menu $menubar.mAudio -tearoff 0]
			$menubar insert 2 cascade -label [mc "Audio"] -compound left -image $::icon_men(placeholder) -menu $mAud
			set changeAccels 0
		} else {
			set mAud $menubar.mAudio
			set changeAccels 1
		}
	} else {
		if {[winfo exists $menubar.mbAudio.mAudio] == 0} {
			set mAud [menu $menubar.mbAudio.mAudio -tearoff 0 -postcommand [list main_menuPostcommand 3 "$menubar.mbTvviewer $menubar.mbNavigation $menubar.mbView $menubar.mbAudio $menubar.mbHelp" $menubar.mbAudio.mAudio]]
			set changeAccels 0
		} else {
			set mAud $menubar.mbAudio.mAudio
			set changeAccels 1
		}
	}
	
	if {$changeAccels} {
		$mAud entryconfigure 0 -accelerator [dict get $::keyseq volInc name]
		$mAud entryconfigure 1 -accelerator [dict get $::keyseq volDec name]
		$mAud entryconfigure 2 -accelerator [dict get $::keyseq volMute name]
		$mAud entryconfigure 4 -accelerator [dict get $::keyseq delayInc name]
		$mAud entryconfigure 5 -accelerator [dict get $::keyseq delayDec name]
	} else {
		$mAud add command -compound left -image $::icon_men(volume) -label [mc "Volume +"] -command {event generate . <<volume_incr>>} -accelerator [dict get $::keyseq volInc name]
		$mAud add command -compound left -image $::icon_men(volume) -label [mc "Volume -"] -command {event generate . <<volume_decr>>} -accelerator [dict get $::keyseq volDec name]
		$mAud add command -compound left -image $::icon_men(volume-error) -label [mc "Mute"] -command {event generate . <<mute>>} -accelerator [dict get $::keyseq volMute name]
		$mAud add separator
		$mAud add command -compound left -image $::icon_men(placeholder) -label [mc "Delay +"] -command {event generate . <<delay_incr>>} -accelerator [dict get $::keyseq delayInc name]
		$mAud add command -compound left -image $::icon_men(placeholder) -label [mc "Delay -"] -command {event generate . <<delay_decr>>} -accelerator [dict get $::keyseq delayDec name]
	}
}

proc main_menuHelp {menubar toolbChanCtrl toolbPlay vidBg handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuHelp \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$vidBg\} \{$handler\}"
	if {"$handler" == "context"} {
		set menubar .fvidBg.mContext
		if {[winfo exists $menubar.mHelp] == 0} {
			set mHelp [menu $menubar.mHelp -tearoff 0]
			$menubar insert 3 cascade -label [mc "Help"] -compound left -image $::icon_men(placeholder) -menu $mHelp
			set changeAccels 0
		} else {
			set mHelp $menubar.mHelp
			set changeAccels 1
		}
	} else {
		if {[winfo exists $menubar.mbHelp.mHelp] == 0} {
			set mHelp [menu $menubar.mbHelp.mHelp -tearoff 0 -postcommand [list main_menuPostcommand 4 "$menubar.mbTvviewer $menubar.mbNavigation $menubar.mbView $menubar.mbAudio $menubar.mbHelp" $menubar.mbHelp.mHelp]]
			set changeAccels 0
		} else {
			set mHelp $menubar.mbHelp.mHelp
			set changeAccels 1
		}
	}
	
	#Fill menu help
	if {$changeAccels} {
		$mHelp entryconfigure 0 -accelerator [dict get $::keyseq help name]
	} else {
		$mHelp add command -command info_helpHelp -compound left -image $::icon_men(help) -label [mc "User Guide"] -accelerator [dict get $::keyseq help name]
		$mHelp add command -command key_sequences -compound left -image $::icon_men(key-bindings) -label [mc "Key Sequences"]
		$mHelp add separator
		$mHelp add checkbutton -command [list log_viewerUi 2 0] -label [mc "MPlayer Log"] -variable choice(cb_log_mpl_main)
		$mHelp add checkbutton -command [list log_viewerUi 3 0] -label [mc "Scheduler Log"] -variable choice(cb_log_sched_main)
		$mHelp add checkbutton -command [list log_viewerUi 1 0] -label [mc "TV-Viewer Log"] -variable choice(cb_log_tv_main)
		$mHelp add separator
		$mHelp add command -label [mc "Diagnostic Routine"] -compound left -image $::icon_men(diag) -command diag_Ui
		$mHelp add separator
		$mHelp add command -command info_helpAbout -compound left -image $::icon_men(help-about) -label [mc "Info"]
	}
}

proc main_menuContext {menubar toolbChanCtrl toolbPlay vidBg} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuContext \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$vidBg\}"
	main_menuTvview $menubar $toolbChanCtrl $toolbPlay $vidBg context
	main_menuNav $menubar $toolbChanCtrl $toolbPlay $vidBg context
	main_menuView $menubar $toolbChanCtrl $toolbPlay $vidBg context
	main_menuAud $menubar $toolbChanCtrl $toolbPlay $vidBg context
	main_menuHelp $menubar $toolbChanCtrl $toolbPlay $vidBg context
}

proc main_menuReFo {menubar toolbChanCtrl toolbPlay vidBg handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuReFo \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$vidBg\} \{$handler\}"
	if {[winfo exists $toolbPlay.mbRewChoose.mRewChoose] == 0} {
		set mRew [menu $toolbPlay.mbRewChoose.mRewChoose -tearoff 0]
		set mForw [menu $toolbPlay.mbForwChoose.mForwChoose -tearoff 0]
		set changeAccels 0
	} else {
		set mRew $toolbPlay.mbRewChoose.mRewChoose
		set mForw $toolbPlay.mbForwChoose.mForwChoose
		set changeAccels 1
	}
	
	#Fill menu rewind selector
	if {$changeAccels} {
		$mRew entryconfigure 0 -accelerator [dict get $::keyseq fileRew10s name]
		$mRew entryconfigure 1 -accelerator [dict get $::keyseq fileRew1m name]
		$mRew entryconfigure 2 -accelerator [dict get $::keyseq fileRew10m name]
	} else {
		$mRew add checkbutton -label [mc "-10 seconds"] -command [list vid_seekSwitch .ftoolb_Play.bRewSmall -1 -10s vid(check_rew_10s)] -variable tv(check_rew_10s) -accelerator [dict get $::keyseq fileRew10s name]
		$mRew add checkbutton -label [mc "-1 minute"] -command [list vid_seekSwitch .ftoolb_Play.bRewSmall -1 -1m vid(check_rew_1m)] -variable tv(check_rew_1m) -accelerator [dict get $::keyseq fileRew1m name]
		$mRew add checkbutton -label [mc "-10 minutes"] -command [list vid_seekSwitch .ftoolb_Play.bRewSmall -1 -10m vid(check_rew_10m)] -variable tv(check_rew_10m) -accelerator [dict get $::keyseq fileRew10m name]
	}
	
	#Fill menu forward selector
	if {$changeAccels} {
		$mForw entryconfigure 0 -accelerator [dict get $::keyseq fileFow10s name]
		$mForw entryconfigure 1 -accelerator [dict get $::keyseq fileFow1m name]
		$mForw entryconfigure 2 -accelerator [dict get $::keyseq fileFow10m name]
	} else {
		$mForw add checkbutton -label [mc "+10 seconds"] -command [list vid_seekSwitch .ftoolb_Play.bForwSmall 1 +10s vid(check_fow_10s)] -variable tv(check_fow_10s) -accelerator [dict get $::keyseq fileFow10s name]
		$mForw add checkbutton -label [mc "+1 minute"] -command [list vid_seekSwitch .ftoolb_Play.bForwSmall 1 +1m vid(check_fow_1m)] -variable tv(check_fow_1m) -accelerator [dict get $::keyseq fileFow1m name]
		$mForw add checkbutton -label [mc "+10 minutes"] -command [list vid_seekSwitch .ftoolb_Play.bForwSmall 1 +10m vid(check_fow_10m)] -variable tv(check_fow_10m) -accelerator [dict get $::keyseq fileFow10m name]
	}
}

proc main_menuCreate {menubar toolbChanCtrl toolbPlay vidBg handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuCreate \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$vidBg\} \{$handler\}"
	main_menuTvview $menubar $toolbChanCtrl $toolbPlay $vidBg standard
	main_menuNav $menubar $toolbChanCtrl $toolbPlay $vidBg standard
	main_menuView $menubar $toolbChanCtrl $toolbPlay $vidBg standard
	main_menuAud $menubar $toolbChanCtrl $toolbPlay $vidBg standard
	main_menuHelp $menubar $toolbChanCtrl $toolbPlay $vidBg standard
	main_menuReFo $menubar $toolbChanCtrl $toolbPlay $vidBg standard
	main_menuContext $menubar $toolbChanCtrl $toolbPlay $vidBg
}

proc main_menuPostcommand {id menubtn menu} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuPostcommand \033\[0m \{$menubtn\} \{$menu\}"
	set i 0
	foreach mb $menubtn {
		if {$id == $i} {
			$mb state pressed
			bind $menu <Unmap> "$mb state !pressed; bind $menu <Unmap> {}"
		} else {
			#FIXME Mouse traversal won't work this way, we don't get an enter event.
			#~ bind $mb <Any-Enter> "puts {any enter $mb}"
		}
		incr i
	}
}
