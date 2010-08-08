#       main_menu.tcl
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

proc main_menuTvview {menubar toolbChanCtrl toolbPlay tvBg handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuTvview \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$tvBg\} \{$handler\}"
	if {"$handler" == "context"} {
		set mTv .ftvBg.mContext
	} else {
		set mTv [menu $menubar.mbTvviewer.mTvviewer \
		-tearoff 0 \
		-background $::option(theme_$::option(use_theme))]
	}
	
	#Fill menu TV-Viewer
	$mTv add separator
	$mTv add command \
	-label [mc "Color Management"] \
	-compound left \
	-image $::icon_s(color-management) \
	-command colorm_mainUi \
	-accelerator [mc "Ctrl+M"]
	$mTv add command \
	-label [mc "Preferences"] \
	-compound left \
	-image $::icon_s(settings) \
	-accelerator [mc "Ctrl+P"] \
	-command {config_wizardMainUi}
	$mTv add command \
	-label [mc "Station Editor"] \
	-compound left \
	-image $::icon_s(seditor) \
	-command {station_editUi} \
	-accelerator [mc "Ctrl+E"]
	$mTv add command \
	-label [mc "Record Wizard"] \
	-compound left \
	-image $::icon_s(record) \
	-command {event generate . <<record>>} \
	-accelerator "R"
	$mTv add separator
	$mTv add command \
	-label [mc "Newsreader"] \
	-compound left \
	-image $::icon_s(newsreader) \
	-command [list main_newsreaderCheckUpdate 0]
	$mTv add checkbutton \
	-label [mc "System Tray"] \
	-command {main_systemTrayActivate 0} \
	-variable choice(cb_systray_main)
	$mTv add separator
	$mTv add command \
	-label [mc "Exit"] \
	-compound left \
	-image $::icon_s(dialog-close) \
	-command [list event generate . <<exit>>] \
	-accelerator [mc "Ctrl+X"]
}

proc main_menuNav {menubar toolbChanCtrl toolbPlay tvBg handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuNav \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$tvBg\} \{$handler\}"
	if {"$handler" == "context"} {
		set menubar .ftvBg.mContext
		set mNav [menu $menubar.mNavigation \
		-tearoff 0 \
		-background $::option(theme_$::option(use_theme))]
			set mNavRew [menu $menubar.mNavigationRewind \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))]
			set mNavForw [menu $menubar.mNavigationForward \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))]
		$menubar add cascade \
		-label [mc "Navigation"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-menu $mNav
	} else {
		set mNav [menu $menubar.mbNavigation.mNavigation \
		-tearoff 0 \
		-background $::option(theme_$::option(use_theme))]
			set mNavRew [menu $menubar.mbNavigation.mNavigationRewind \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))]
			set mNavForw [menu $menubar.mbNavigation.mNavigationForward \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))]
	}
	
	$mNav add separator
	$mNav add command \
	-label [mc "Next station"] \
	-compound left \
	-image $::icon_s(channel-up) \
	-command [list chan_zapperUp .fstations.treeSlist] \
	-accelerator [mc "PageDOWN"]
	$mNav add command \
	-label [mc "Previous station"] \
	-compound left \
	-image $::icon_s(channel-down) \
	-command [list chan_zapperDown .fstations.treeSlist] \
	-accelerator [mc "PageUP"]
	$mNav add command \
	-label [mc "Station jumper"] \
	-compound left \
	-image $::icon_s(channel-jump) \
	-command [list chan_zapperJump .fstations.treeSlist] \
	-accelerator J
	$mNav add separator
	$mNav add command \
	-label [mc "Play"] \
	-compound left \
	-image $::icon_s(playback-start) \
	-command {event generate . <<start>>} \
	-accelerator [mc "Shift+P"]
	$mNav add command \
	-label [mc "Pause"] \
	-compound left \
	-image $::icon_s(playback-pause) \
	-command {event generate . <<pause>>} \
	-accelerator P
	$mNav add command \
	-label [mc "Stop"] \
	-compound left \
	-image $::icon_s(playback-stop) \
	-command {event generate . <<stop>>} \
	-accelerator [mc "Shift+S"]
	$mNav add separator
	$mNav add cascade \
	-label [mc "Rewind"] \
	-compound left \
	-image $::icon_s(rewind-small) \
	-menu $mNavRew
		$mNavRew add command \
		-label [mc "-10 seconds"] \
		-compound left \
		-image $::icon_s(rewind-small) \
		-command {event generate . <<rewind_10s>>} \
		-accelerator [mc "Left"]
		$mNavRew add command \
		-label [mc "-1 minute"] \
		-compound left \
		-image $::icon_s(rewind-small) \
		-command {event generate . <<rewind_1m>>} \
		-accelerator [mc "Shift+Left"]
		$mNavRew add command \
		-label [mc "-10 minute"] \
		-compound left \
		-image $::icon_s(rewind-small) \
		-command {event generate . <<rewind_10m>>} \
		-accelerator [mc "Ctrl+Shift+Left"]
		$mNavRew add command \
		-label [mc "Rewind start"] \
		-compound left \
		-image $::icon_s(rewind-first) \
		-command {event generate . <<rewind_start>>} \
		-accelerator [mc "Home"]
	$mNav add cascade \
	-label [mc "Forward"] \
	-compound left \
	-image $::icon_s(forward-small) \
	-menu $mNavForw
		$mNavForw add command \
		-label [mc "+10 seconds"] \
		-compound left \
		-image $::icon_s(forward-small) \
		-command {event generate . <<forward_10s>>} \
		-accelerator [mc "Right"]
		$mNavForw add command \
		-label [mc "+1 minute"] \
		-compound left \
		-image $::icon_s(forward-small) \
		-command {event generate . <<forward_1m>>} \
		-accelerator [mc "Shift+Right"]
		$mNavForw add command \
		-label [mc "+10 minutes"] \
		-compound left \
		-image $::icon_s(forward-small) \
		-command {event generate . <<forward_10m>>} \
		-accelerator [mc "Ctrl+Shift+Right"]
		$mNavForw add command \
		-label [mc "Forward end"] \
		-compound left \
		-image $::icon_s(forward-last) \
		-command {event generate . <<forward_end>>} \
		-accelerator [mc "End"]
}

proc main_menuView {menubar toolbChanCtrl toolbPlay tvBg handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuView \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$tvBg\} \{$handler\}"
	if {"$handler" == "context"} {
		set menubar .ftvBg.mContext
		set mView [menu $menubar.mView \
		-tearoff 0 \
		-background $::option(theme_$::option(use_theme))]
			set mViewPan [menu $menubar.mViewPanScan \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))]
			set mViewSize [menu $menubar.mViewSize \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))]
			set mViewMove [menu $menubar.mViewMove \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))]
			set mViewTop [menu $menubar.mViewTop \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))]
		$menubar add cascade \
		-label [mc "View"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-menu $mView
	} else {
		set mView [menu $menubar.mbView.mView \
		-tearoff 0 \
		-background $::option(theme_$::option(use_theme))]
			set mViewPan [menu $menubar.mbView.mViewPanScan \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))]
			set mViewSize [menu $menubar.mbView.mViewSize \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))]
			set mViewMove [menu $menubar.mbView.mViewMove \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))]
			set mViewTop [menu $menubar.mbView.mViewTop \
			-tearoff 0 \
			-background $::option(theme_$::option(use_theme))]
	}
	
	$mView add separator
	$mView add cascade \
	-label [mc "Pan&Scan"] \
	-compound left \
	-image $::icon_s(placeholder) \
	-menu $mViewPan
		$mViewPan add command \
		-label [mc "Zoom +"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmPanscan .ftvBg.cont 1] \
		-accelerator "E"
		$mViewPan add command \
		-label [mc "Zoom -"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmPanscan .ftvBg.cont -1] \
		-accelerator "W"
		$mViewPan add command \
		-label [mc "Pan&Scan (16:9 / 4:3)"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command {vid_wmPanscanAuto} \
		-accelerator "Shift+W"
		$mViewPan add separator
		$mViewPan add command \
		-label [mc "Move up"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmMoveVideo 3] \
		-accelerator "Alt+Up"
		$mViewPan add command \
		-label [mc "Move down"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmMoveVideo 1] \
		-accelerator "Alt+Down"
		$mViewPan add command \
		-label [mc "Move left"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmMoveVideo 2] \
		-accelerator "Alt+Left"
		$mViewPan add command \
		-label [mc "Move right"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmMoveVideo 0] \
		-accelerator "Alt+Right"
		$mViewPan add command \
		-label [mc "Center video"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmMoveVideo 4] \
		-accelerator "Alt+C"
	$mView add cascade \
	-label [mc "Size"] \
	-compound left \
	-image $::icon_s(placeholder) \
	-menu $mViewSize
		$mViewSize add command \
		-label "50%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmGivenSize .ftvBg 0.5]
		$mViewSize add command \
		-label "75%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmGivenSize .ftvBg 0.75]
		$mViewSize add command \
		-label "100%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmGivenSize .ftvBg 1.0] \
		-accelerator [mc "Ctrl+1"]
		$mViewSize add command \
		-label "125%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmGivenSize .ftvBg 1.25]
		$mViewSize add command \
		-label "150%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmGivenSize .ftvBg 1.5]
		$mViewSize add command \
		-label "175%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmGivenSize .ftvBg 1.75]
		$mViewSize add command \
		-label "200%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list vid_wmGivenSize .ftvBg 2.0] \
		-accelerator [mc "Ctrl+2"]
	$mView add cascade \
	-label [mc "Stay on top"] \
	-compound left \
	-image $::icon_s(placeholder) \
	-menu $mViewTop
		$mViewTop add radiobutton \
		-label [mc "Never"] \
		-variable tv(stayontop) \
		-value 0 \
		-command [list vid_wmStayonTop 0]
		$mViewTop add radiobutton \
		-label [mc "Always"] \
		-variable tv(stayontop) \
		-value 1 \
		-command [list vid_wmStayonTop 1]
		$mViewTop add radiobutton \
		-label [mc "While playback"] \
		-variable tv(stayontop) \
		-value 2 \
		-command [list vid_wmStayonTop 2]
	$mView add command \
	-command "" \
	-compound left \
	-image $::icon_s(compact) \
	-label [mc "Compact mode"] \
	-accelerator [mc "Ctrl+C"]
	$mView add command \
	-command [list vid_wmFullscreen . .ftvBg .ftvBg.cont] \
	-compound left \
	-image $::icon_s(fullscreen) \
	-label [mc "Fullscreen"] \
	-accelerator F
	
}

proc main_menuAud {menubar toolbChanCtrl toolbPlay tvBg handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuAud \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$tvBg\} \{$handler\}"
	if {"$handler" == "context"} {
		set menubar .ftvBg.mContext
		set mAud [menu $menubar.mAudio \
		-tearoff 0 \
		-background $::option(theme_$::option(use_theme))]
		$menubar add cascade \
		-label [mc "Audio"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-menu $mAud
	} else {
		set mAud [menu $menubar.mbAudio.mAudio \
		-tearoff 0 \
		-background $::option(theme_$::option(use_theme))]
	}
	
	$mAud add separator
	$mAud add command \
	-compound left \
	-image $::icon_s(volume) \
	-label [mc "Volume +"] \
	-command {event generate . <<volume_incr>>} \
	-accelerator +
	$mAud add command \
	-compound left \
	-image $::icon_s(volume) \
	-label [mc "Volume -"] \
	-command {event generate . <<volume_decr>>} \
	-accelerator -
	$mAud add command \
	-compound left \
	-image $::icon_s(volume-error) \
	-label [mc "Mute"] \
	-command [list vid_playerVolumeControl .ftoolb_Play.scVolume .ftoolb_Play.bVolMute mute]
	$mAud add separator
	$mAud add command \
	-compound left \
	-image $::icon_s(placeholder) \
	-label [mc "Delay +"] \
	-command {event generate . <<delay_incr>>} \
	-accelerator [mc "Alt++"]
	$mAud add command \
	-compound left \
	-image $::icon_s(placeholder) \
	-label [mc "Delay -"] \
	-command {event generate . <<delay_decr>>} \
	-accelerator [mc "Alt+-"]
}


proc main_menuHelp {menubar toolbChanCtrl toolbPlay tvBg handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuHelp \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$tvBg\} \{$handler\}"
	set mHelp [menu $menubar.mbHelp.mHelp \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	
	#Fill menu help
	$mHelp add separator
	$mHelp add command \
	-command info_helpHelp \
	-compound left \
	-image $::icon_s(help) \
	-label [mc "User Guide"] \
	-accelerator F1
	$mHelp add command \
	-command key_sequences \
	-compound left \
	-image $::icon_s(key-bindings) \
	-label [mc "Key Sequences"]
	$mHelp add separator
	$mHelp add checkbutton \
	-command [list log_viewerUi 2] \
	-label [mc "MPlayer Log"] \
	-variable choice(cb_log_mpl_main)
	$mHelp add checkbutton \
	-command [list log_viewerUi 3] \
	-label [mc "Scheduler Log"] \
	-variable choice(cb_log_sched_main)
	$mHelp add checkbutton \
	-command [list log_viewerUi 1] \
	-label [mc "TV-Viewer Log"] \
	-variable choice(cb_log_tv_main)
	$mHelp add separator
	$mHelp add command \
	-label [mc "Diagnostic Routine"] \
	-compound left \
	-image $::icon_s(diag) \
	-command diag_Ui
	$mHelp add separator
	$mHelp add command \
	-command info_helpAbout \
	-compound left \
	-image $::icon_s(help-about) \
	-label [mc "Info"]
}

proc main_menuReFo {menubar toolbChanCtrl toolbPlay tvBg handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuReFo \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$tvBg\} \{$handler\}"
	set mRew [menu $toolbPlay.mbRewChoose.mRewChoose \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	set mForw [menu $toolbPlay.mbForwChoose.mForwChoose \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	
	#Fill menu rewind selector
	$mRew add checkbutton \
	-label [mc "-10 seconds"] \
	-accelerator [mc "Left"] \
	-command [list vid_seekSwitch .ftoolb_Play.bRewSmall -1 -10s tv(check_rew_10s)] \
	-variable tv(check_rew_10s)
	$mRew add checkbutton \
	-label [mc "-1 minute"] \
	-accelerator [mc "Shift+Left"] \
	-command [list vid_seekSwitch .ftoolb_Play.bRewSmall -1 -1m tv(check_rew_1m)] \
	-variable tv(check_rew_1m)
	$mRew add checkbutton \
	-label [mc "-10 minutes"] \
	-accelerator [mc "Ctrl+Shift+Left"] \
	-command [list vid_seekSwitch .ftoolb_Play.bRewSmall -1 -10m tv(check_rew_10m)] \
	-variable tv(check_rew_10m)
	
	#Fill menu forward selector
	$mForw add checkbutton \
	-label [mc "+10 seconds"] \
	-accelerator [mc "Right"] \
	-command [list vid_seekSwitch .ftoolb_Play.bForwSmall 1 +10s tv(check_fow_10s)] \
	-variable tv(check_fow_10s)
	$mForw add checkbutton \
	-label [mc "+1 minute"] \
	-accelerator [mc "Shift+Right"] \
	-command [list vid_seekSwitch .ftoolb_Play.bForwSmall 1 +1m tv(check_fow_1m)] \
	-variable tv(check_fow_1m)
	$mForw add checkbutton \
	-label [mc "+10 minutes"] \
	-accelerator [mc "Ctrl+Shift+Right"] \
	-command [list vid_seekSwitch .ftoolb_Play.bForwSmall 1 +10m tv(check_fow_10m)] \
	-variable tv(check_fow_10m)
}

proc main_menuContext {menubar toolbChanCtrl toolbPlay tvBg} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_menuContext \033\[0m \{$menubar\} \{$toolbChanCtrl\} \{$toolbPlay\} \{$tvBg\}"
	set mContext [menu $tvBg.mContext \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	$mContext add separator
	
	main_menuNav $menubar $toolbChanCtrl $toolbPlay $tvBg context
	main_menuView $menubar $toolbChanCtrl $toolbPlay $tvBg context
	main_menuAud $menubar $toolbChanCtrl $toolbPlay $tvBg context
	main_menuTvview $menubar $toolbChanCtrl $toolbPlay $tvBg context
}
