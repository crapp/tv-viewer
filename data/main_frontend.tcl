#       main_frontend.tcl
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

proc main_frontendExitViewer {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendExitViewer \033\[0m"
	set status_time [monitor_partRunning 4]
	if {[lindex $status_time 0] == 1} {
		log_writeOutTv 0 "Timeshift (PID: [lindex $status_time 1]) is running, will stop it."
		catch {exec kill [lindex $status_time 1]}
		catch {file delete "$::option(home)/tmp/timeshift_lockfile.tmp"}
	}
	if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"]} {
		catch {file delete -force "[subst $::option(timeshift_path)/timeshift.mpeg]"}
	}
	catch {file delete "$::option(home)/tmp/lockfile.tmp"}
	destroy .top_newsreader
	destroy .top_about
	if {[info exists ::tv(pbMode)]} {
		if {$::tv(pbMode) == 1} {
			set status_tv [tv_callbackMplayerRemote alive]
			if {$status_tv != 1} {
				tv_playbackStop 0 nopic
			}
		} else {
			set status_tv [tv_callbackMplayerRemote alive]
			if {$status_tv != 1} {
				tv_playbackStop 0 pic
			}
		}
	}
	puts $::logf_tv_open_append "#
#
# Stop session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
########################################################################
"
	puts $::logf_mpl_open_append "#
#
# Stop session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
########################################################################
"
	close $::logf_tv_open_append
	close $::logf_mpl_open_append
	catch {close $::data(comsocketRead)}
	catch {close $::data(comsocketWrite)}
	set status [monitor_partRunning 2]
	if {[lindex $status 0] == 0} {
		catch {file delete -force "$::option(home)/tmp/ComSocketMain"}
		catch {file delete -force "$::option(home)/tmp/ComSocketSched"}
	}
	exit 0
}

proc main_frontendEpg {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendEpg \033\[0m"
	log_writeOutTv 0 "Launching EPG program..."
	catch {exec sh -c "[subst $::option(epg_command)] >/dev/null 2>&1" &}
}

proc msgcat::mcunknown {locale src args} {
	log_writeOutTv 1 "-=Unknown string for locale $locale"
	log_writeOutTv 1 "$src $args"
	return $src
}

proc main_frontendDisableTree {tree com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendDisableTree \033\[0m \{$tree\} \{$com\}"
	#Hack because treeview widgets do not respond to disable state
	if {$com} {
		bind $tree <ButtonPress-1> break
		$tree tag configure disabled -foreground #A0A0A0
		if {[array exists ::kanalitemID]} {
			foreach elem [$tree children {}] {
				$tree item $elem -tag disabled
			}
		}
	}
	if {$com == 0} {
		bind $tree <ButtonPress-1> [list event generate $tree <<Treeview>>]
		if {[array exists ::kanalitemID]} {
			foreach elem [$tree children {}] {
				$tree item $elem -tag {}
			}
		}
	}
}


proc main_frontendChannelHandler {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendChannelHandler \033\[0m \{$handler\}"
	if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
		log_writeOutTv 2 "There are no stations to insert into station list."
		set status_tv_playback [tv_callbackMplayerRemote alive]
		if {$status_tv_playback != 1} {
			tv_playbackStop 0 pic
		}
		main_frontendDisableTree .fstations.treeSlist 1
		bind .fstations.treeSlist <<TreeviewSelect>> {}
		.ftoolb_Top.lInput configure -text [mc "unknown"]
		foreach widget [split [winfo children .ftoolb_Top]] {
			catch {$widget state disabled}
		}
		foreach widget [split [winfo children .ftoolb_Station]] {
			catch {$widget state disabled}
		}
		foreach widget [split [winfo children .ftoolb_Bot]] {
			if {[string match *bVolMute $widget] || [string match *scVolume $widget]} continue
			catch {$widget state disabled}
		}
		if {"$handler" == "main"} {
			event_constr 0
		} else {
			if {[array exists ::kanalitemID]} {
				foreach {key elem} [array get ::kanalitemID] {
					.fstations.treeSlist delete $elem
				}
			}
			catch {array unset ::kanalitemID}
			event_deleSedit
			set status [monitor_partRunning 2]
			if {[lindex $status 0] == 1} {
				command_WritePipe 0 "tv-viewer_scheduler scheduler_Init 1"
			}
		}
	} else {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_grep_input [catch {agrep -m "$read_vinput" video} resultat_grep_input]
		if {$status_grep_input == 0} {
			.ftoolb_Top.lInput configure -text [string trim [string range $resultat_grep_input [string first \( $resultat_grep_input] end] ()]
		} else {
			log_writeOutTv 2 "Can not read video input."
			log_writeOutTv 2 "$resultat_grep_input."
		}
		.ftoolb_Top.lDevice configure -text $::option(video_device)
		event_constr 1
		
		if {[array exists ::kanalitemID]} {
			foreach {key elem} [array get ::kanalitemID] {
				.fstations.treeSlist delete $elem
			}
		}
		catch {array unset ::kanalitemID}
		set font [ttk::style lookup [.fstations.treeSlist cget -style] -font]
		if {[string trim $font] == {}} {
			set font TkDefaultFont
		}
		if {"$handler" == "sedit"} {
			destroy .fstations.treeSlist
			ttk::treeview .fstations.treeSlist \
			-yscrollcommand [list .fstations.scrbSlist set] \
			-columns {name number} \
			-show headings \
			-selectmode browse \
			-takefocus 0
			grid .fstations.treeSlist -in .fstations -row 0 -column 0 \
			-sticky nesw
		}
		.fstations.treeSlist heading name -text [mc "Name"]
		set minwidth [expr [font measure $font [mc "Name"]] + 20]
		.fstations.treeSlist heading number -text [mc "No"]
		.fstations.treeSlist column number -width [expr [font measure $font [mc "No"]] + 20] -anchor center
		set width 0
		for {set i 1} {$i <= $::station(max)} {incr i} {
			.fstations.treeSlist insert {} end -values [list $::kanalid($i) $i]
			if {[expr [font measure $font $::kanalid($i)] + 20] > $width} {
				set width [expr [font measure $font $::kanalid($i)] + 20]
			}
			set ::kanalitemID($i) [lindex [.fstations.treeSlist children {}] end]
		}
		if {$width < $minwidth} {
			.fstations.treeSlist column name -width $minwidth -stretch 0
		} else {
			.fstations.treeSlist column name -width $width -stretch 0
		}
		bindtags .fstations.treeSlist {. .fstations.treeSlist Treeview all}
		.fstations.treeSlist selection set $::kanalitemID([lindex $::station(last) 2])
		.fstations.treeSlist see [.fstations.treeSlist selection]
		bind .fstations.treeSlist <<TreeviewSelect>> [list chan_zapperTree .fstations.treeSlist]
		bind .fstations.treeSlist <Key-Prior> {break}
		bind .fstations.treeSlist <Key-Next> {break}
		#FIXME Not very nice to break usage of Key Up and Down. Conflict with move video frame.
		bind .fstations.treeSlist <Key-Up> {break}
		bind .fstations.treeSlist <Key-Down> {break}
		bind .fstations.treeSlist <B1-Motion> break
		bind .fstations.treeSlist <Motion> break
		set status_time [monitor_partRunning 4]
		set status_record [monitor_partRunning 3]
		if {[lindex $status_time 0] == 1 || [lindex $status_record 0] == 1 } {
			if {$::option(rec_allow_sta_change) == 0} {
				log_writeOutTv 1 "Disabling station list due to an active recording."
				main_frontendDisableTree .fstations.treeSlist 1
			}
		}
		if {"$handler" == "sedit"} {
			foreach widget [split [winfo children .ftoolb_Top]] {
				catch {$widget state !disabled}
			}
			foreach widget [split [winfo children .ftoolb_Station]] {
				catch {$widget state !disabled}
			}
			foreach widget [split [winfo children .ftoolb_Bot]] {
				if {[string match *bVolMute $widget] || [string match *scVolume $widget]} continue
				catch {$widget state !disabled}
			}
			set status [monitor_partRunning 2]
			if {[lindex $status 0] == 1} {
				command_WritePipe 0 "tv-viewer_scheduler scheduler_Init 1"
			}
		}
	}
}

proc main_frontendMenu {menubar toolbBot tvBg} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendMenu \033\[0m \{$menubar\} \{$toolbBot\} \{$tvBg\}"
	
	log_writeOutTv 0 "Creating menus for main frontend"
	
	set mTv [menu $menubar.mbTvviewer.mTvviewer \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	set mNav [menu $menubar.mbNavigation.mNavigation \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	set mView [menu $menubar.mbView.mView \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	set mViewPan [menu $menubar.mbView.mViewPanScan \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	set mViewSize [menu $menubar.mbView.mViewSize \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	set mViewTop [menu $menubar.mbView.mViewTop \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	set mAud [menu $menubar.mbAudio.mAudio \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	set mHelp [menu $menubar.mbHelp.mHelp \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	
	set mRew [menu $toolbBot.mbRewChoose.mRewChoose \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	set mForw [menu $toolbBot.mbForwChoose.mForwChoose \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	
	set mContext [menu .ftvBg.context \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	set mContextPan [menu .ftvBg.context.panscan \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	set mContextSize [menu .ftvBg.context.size \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	set mContextTop [menu .ftvBg.context.ontop \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))]
	
	log_writeOutTv 0 "Filling menus for main frontend with content"
	
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
	
	#FIXME Fill View menu with content. 
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
		-command [list tv_wmPanscan .ftvBg.cont 1] \
		-accelerator "E"
		$mViewPan add command \
		-label [mc "Zoom -"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmPanscan .ftvBg.cont -1] \
		-accelerator "W"
		$mViewPan add command \
		-label [mc "Pan&Scan (16:9 / 4:3)"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command {tv_wmPanscanAuto} \
		-accelerator "Shift+W"
		$mViewPan add separator
		$mViewPan add command \
		-label [mc "Move up"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmMoveVideo 3] \
		-accelerator "Alt+Up"
		$mViewPan add command \
		-label [mc "Move down"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmMoveVideo 1] \
		-accelerator "Alt+Down"
		$mViewPan add command \
		-label [mc "Move left"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmMoveVideo 2] \
		-accelerator "Alt+Left"
		$mViewPan add command \
		-label [mc "Move right"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmMoveVideo 0] \
		-accelerator "Alt+Right"
		$mViewPan add command \
		-label [mc "Center video"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmMoveVideo 4] \
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
		-command [list tv_wmGivenSize .ftvBg 0.5]
		$mViewSize add command \
		-label "75%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmGivenSize .ftvBg 0.75]
		$mViewSize add command \
		-label "100%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmGivenSize .ftvBg 1.0] \
		-accelerator [mc "Ctrl+1"]
		$mViewSize add command \
		-label "125%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmGivenSize .ftvBg 1.25]
		$mViewSize add command \
		-label "150%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmGivenSize .ftvBg 1.5]
		$mViewSize add command \
		-label "175%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmGivenSize .ftvBg 1.75]
		$mViewSize add command \
		-label "200%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmGivenSize .ftvBg 2.0] \
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
		-command [list tv_wmStayonTop 0]
		$mViewTop add radiobutton \
		-label [mc "Always"] \
		-variable tv(stayontop) \
		-value 1 \
		-command [list tv_wmStayonTop 1]
		$mViewTop add radiobutton \
		-label [mc "While playback"] \
		-variable tv(stayontop) \
		-value 2 \
		-command [list tv_wmStayonTop 2]
	$mView add command \
	-command "" \
	-compound left \
	-image $::icon_s(compact) \
	-label [mc "Compact mode"] \
	-accelerator [mc "Ctrl+C"]
	$mView add command \
	-command "" \
	-compound left \
	-image $::icon_s(fullscreen) \
	-label [mc "Fullscreen"] \
	-accelerator F

	
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
	
	#FIXME Fill context menu with content 
	
	#Fill menu rewind selector
	$mRew add checkbutton \
	-label [mc "-10 seconds"] \
	-accelerator [mc "Left"] \
	-command [list tv_seekSwitch .ftoolb_Bot.bRewSmall -1 -10s tv(check_rew_10s)] \
	-variable tv(check_rew_10s)
	$mRew add checkbutton \
	-label [mc "-1 minute"] \
	-accelerator [mc "Shift+Left"] \
	-command [list tv_seekSwitch .ftoolb_Bot.bRewSmall -1 -1m tv(check_rew_1m)] \
	-variable tv(check_rew_1m)
	$mRew add checkbutton \
	-label [mc "-10 minutes"] \
	-accelerator [mc "Ctrl+Shift+Left"] \
	-command [list tv_seekSwitch .ftoolb_Bot.bRewSmall -1 -10m tv(check_rew_10m)] \
	-variable tv(check_rew_10m)
	
	#Fill menu forward selector
	$mForw add checkbutton \
	-label [mc "+10 seconds"] \
	-accelerator [mc "Right"] \
	-command [list tv_seekSwitch .ftoolb_Bot.bForwSmall 1 +10s tv(check_fow_10s)] \
	-variable tv(check_fow_10s)
	$mForw add checkbutton \
	-label [mc "+1 minute"] \
	-accelerator [mc "Shift+Right"] \
	-command [list tv_seekSwitch .ftoolb_Bot.bForwSmall 1 +1m tv(check_fow_1m)] \
	-variable tv(check_fow_1m)
	$mForw add checkbutton \
	-label [mc "+10 minutes"] \
	-accelerator [mc "Ctrl+Shift+Right"] \
	-command [list tv_seekSwitch .ftoolb_Bot.bForwSmall 1 +10m tv(check_fow_10m)] \
	-variable tv(check_fow_10m)
	
	$mContext add cascade \
	-label [mc "Pan&Scan"] \
	-compound left \
	-image $::icon_s(placeholder) \
	-menu $mContextPan
		$mContextPan add command \
		-label [mc "Zoom +"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmPanscan .ftvBg.cont 1] \
		-accelerator "E"
		$mContextPan add command \
		-label [mc "Zoom -"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmPanscan .ftvBg.cont -1] \
		-accelerator "W"
		$mContextPan add command \
		-label [mc "Pan&Scan (16:9 / 4:3)"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command {tv_wmPanscanAuto} \
		-accelerator "Shift+W"
		$mContextPan add separator
		$mContextPan add command \
		-label [mc "Move up"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmMoveVideo 3] \
		-accelerator "Alt+Up"
		$mContextPan add command \
		-label [mc "Move down"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmMoveVideo 1] \
		-accelerator "Alt+Down"
		$mContextPan add command \
		-label [mc "Move left"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmMoveVideo 2] \
		-accelerator "Alt+Left"
		$mContextPan add command \
		-label [mc "Move right"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmMoveVideo 0] \
		-accelerator "Alt+Right"
		$mContextPan add command \
		-label [mc "Center video"] \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmMoveVideo 4] \
		-accelerator "Alt+C"
	$mContext add cascade \
	-label [mc "Size"] \
	-compound left \
	-image $::icon_s(placeholder) \
	-menu $mContextSize
		$mContextSize add command \
		-label "50%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmGivenSize .ftvBg 0.5]
		$mContextSize add command \
		-label "75%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmGivenSize .ftvBg 0.75]
		$mContextSize add command \
		-label "100%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmGivenSize .ftvBg 1.0] \
		-accelerator [mc "Ctrl+1"]
		$mContextSize add command \
		-label "125%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmGivenSize .ftvBg 1.25]
		$mContextSize add command \
		-label "150%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmGivenSize .ftvBg 1.5]
		$mContextSize add command \
		-label "175%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmGivenSize .ftvBg 1.75]
		$mContextSize add command \
		-label "200%" \
		-compound left \
		-image $::icon_s(placeholder) \
		-command [list tv_wmGivenSize .ftvBg 2.0] \
		-accelerator [mc "Ctrl+2"]
	$mContext add cascade \
	-label [mc "Stay on top"] \
	-compound left \
	-image $::icon_s(placeholder) \
	-menu $mContextTop
		$mContextTop add radiobutton \
		-label [mc "Never"] \
		-variable tv(stayontop) \
		-value 0 \
		-command [list tv_wmStayonTop 0]
		$mContextTop add radiobutton \
		-label [mc "Always"] \
		-variable tv(stayontop) \
		-value 1 \
		-command [list tv_wmStayonTop 1]
		$mContextTop add radiobutton \
		-label [mc "While playback"] \
		-variable tv(stayontop) \
		-value 2 \
		-command [list tv_wmStayonTop 2]
	$mContext add command \
	-label [mc "TV playback"] \
	-compound left \
	-image $::icon_s(starttv) \
	-command {event generate . <<teleview>>} \
	-accelerator "S"
	$mContext add command \
	-label [mc "Exit"] \
	-compound left \
	-image $::icon_s(dialog-close) \
	-command [list event generate . <<exit>>] \
	-accelerator [mc "Ctrl+X"]
}

proc main_frontendNewUi {} {
	
	#FIXME Think about a new name for main
	place [ttk::frame .bg] -x 0 -y 0 -relwidth 1 -relheight 1

	set menubar [ttk::frame .foptions_bar] ; place [ttk::label $menubar.bg -style Toolbutton] -relwidth 1 -relheight 1
	
	ttk::separator .seperatMenu -orient horizontal
		
	set toolbTop [ttk::frame .ftoolb_Top] ; place [ttk::label $toolbTop.bg -style Toolbutton] -relwidth 1 -relheight 1
	
	set stations [ttk::frame .fstations] ; place [ttk::label $stations.bg -style Toolbutton] -relwidth 1 -relheight 1
	
	set toolbStation [ttk::frame .ftoolb_Station] ; place [ttk::label $toolbStation.bg -style Toolbutton] -relwidth 1 -relheight 1
	
	set toolbBot [ttk::frame .ftoolb_Bot] ; place [ttk::label $toolbBot.bg -style Toolbutton] -relwidth 1 -relheight 1
	
	set toolbDisp [frame .ftoolb_Disp -background black]
	
	set tvBg [frame .ftvBg -background black -width $::option(resolx) -height $::option(resoly)]
	set tvCont [frame .ftvBg.cont -background "" -container yes]
	
	ttk::menubutton $menubar.mbTvviewer \
	-text TV-Viewer \
	-style Toolbutton \
	-underline 0 \
	-menu $menubar.mbTvviewer.mTvviewer
	ttk::menubutton $menubar.mbNavigation \
	-text [mc "Navigation"] \
	-style Toolbutton \
	-underline 0 \
	-menu $menubar.mbNavigation.mNavigation
	ttk::menubutton $menubar.mbView \
	-text [mc "View"] \
	-style Toolbutton \
	-underline 0 \
	-menu $menubar.mbView.mView
	ttk::menubutton $menubar.mbAudio \
	-text [mc "Audio"] \
	-style Toolbutton \
	-underline 0 \
	-menu $menubar.mbAudio.mAudio
	ttk::menubutton $menubar.mbHelp \
	-text Help \
	-style Toolbutton \
	-underline 0 \
	-menu $menubar.mbHelp.mHelp
	
	ttk::button $toolbTop.bTimeshift \
	-image $::icon_m(timeshift) \
	-style Toolbutton \
	-command {event generate . <<timeshift>>}
	ttk::button $toolbTop.bRecord \
	-image $::icon_m(record) \
	-style Toolbutton \
	-command {event generate . <<record>>}
	ttk::button $toolbTop.bEpg \
	-text EPG \
	-style Toolbutton\
	-command main_frontendEpg
	ttk::button $toolbTop.bRadio \
	-text Radio \
	-style Toolbutton
	#FIXME Find icon for Radio Button
	ttk::button $toolbTop.bTv \
	-image $::icon_m(starttv) \
	-style Toolbutton \
	-command tv_playerRendering
	#FIXME Which foreground color in label
	label $toolbTop.lInput \
	-width 10 \
	-background black \
	-foreground #EB3939 \
	-anchor center \
	-relief sunken \
	-borderwidth 2
	label $toolbTop.lDevice \
	-width 10 \
	-background black \
	-foreground #FF5757 \
	-anchor center \
	-relief sunken \
	-borderwidth 2
	
	ttk::treeview $stations.treeSlist \
	-yscrollcommand [list $stations.scrbSlist set] \
	-columns {name number} \
	-show headings \
	-selectmode browse \
	-takefocus 0
	ttk::scrollbar $stations.scrbSlist \
	-command [list $stations.treeSlist yview]
	
	ttk::button $toolbStation.bChanDown \
	-image $::icon_m(channel-down) \
	-style Toolbutton \
	-command [list chan_zapperDown $stations.treeSlist]
	ttk::button $toolbStation.bChanUp \
	-image $::icon_m(channel-up) \
	-style Toolbutton \
	-command [list chan_zapperUp $stations.treeSlist]
	ttk::button $toolbStation.bChanJump \
	-image $::icon_m(channel-jump) \
	-style Toolbutton \
	-command [list chan_zapperJump $stations.treeSlist]
	
	ttk::button $toolbBot.bPlay \
	-image $::icon_m(playback-start) \
	-style Toolbutton \
	-state disabled \
	-command {event generate . <<start>>}
	ttk::button $toolbBot.bPause \
	-image $::icon_m(playback-pause) \
	-style Toolbutton \
	-state disabled \
	-command {event generate . <<pause>>}
	ttk::button $toolbBot.bStop \
	-image $::icon_m(playback-stop) \
	-style Toolbutton \
	-state disabled \
	-command {event generate . <<stop>>}
	
	ttk::separator $toolbBot.seperat1 \
	-orient vertical
	
	ttk::button $toolbBot.bRewStart \
	-style Toolbutton \
	-image $::icon_m(rewind-first) \
	-state disabled \
	-command {event generate . <<rewind_start>>}
	ttk::button $toolbBot.bRewSmall \
	-style Toolbutton \
	-image $::icon_m(rewind-small) \
	-state disabled \
	-command {event generate . <<rewind_10s>>}
	ttk::menubutton $toolbBot.mbRewChoose \
	-style Toolbutton \
	-image $::icon_e(arrow-d) \
	-menu $toolbBot.mbRewChoose.mRewChoose \
	-state disabled
	ttk::button $toolbBot.bForwSmall \
	-style Toolbutton \
	-image $::icon_m(forward-small) \
	-state disabled \
	-command {event generate . <<forward_10s>>}
	ttk::menubutton $toolbBot.mbForwChoose \
	-style Toolbutton \
	-image $::icon_e(arrow-d) \
	-menu $toolbBot.mbForwChoose.mForwChoose \
	-state disabled
	ttk::button $toolbBot.bForwEnd \
	-style Toolbutton \
	-image $::icon_m(forward-last) \
	-state disabled \
	-command {event generate . <<forward_end>>}
	
	ttk::separator $toolbBot.seperat2 \
	-orient vertical
	
	ttk::button $toolbBot.bSave \
	-style Toolbutton \
	-image $::icon_m(floppy) \
	-state disabled \
	-command [list timeshift_Save .]
	
	ttk::button $toolbBot.bVolMute \
	-style Toolbutton \
	-image $::icon_m(volume) \
	-command [list tv_playerVolumeControl .ftoolb_Bot.scVolume .ftoolb_Bot.bVolMute mute]
	ttk::scale $toolbBot.scVolume \
	-orient horizontal \
	-from 0 \
	-to 100 \
	-variable main(volume_scale) \
	-command [list tv_playerVolumeControl .ftoolb_Bot.scVolume .ftoolb_Bot.bVolMute] \
	
	label $toolbDisp.lDispIcon \
	-compound center \
	-background black \
	-foreground white \
	-image $::icon_s(starttv)
	label $toolbDisp.lDispText \
	-background black \
	-foreground white \
	-text [mc "Welcome to TV-Viewer"] \
	-anchor center
	label $toolbDisp.lTime \
	-width 20 \
	-background black \
	-foreground white \
	-anchor center \
	-textvariable main(label_file_time)
	
	if {[clock format [clock seconds] -format {%d%m}] == 2412} {
		ttk::label $tvBg.l_bgImage \
		-image $::icon_e(logo-tv-viewer08x-noload_xmas) \
		-background #414141
	} else {
		ttk::label $tvBg.l_bgImage \
		-image $::icon_e(logo-tv-viewer08x-noload) \
		-background #414141
	}
	
	
	grid $menubar -in . -row 0 -column 0 \
	-sticky new \
	-columnspan 2
	grid .seperatMenu -in . -row 1 -column 0 \
	-sticky ew \
	-padx 2 \
	-columnspan 2
	grid $toolbTop -in . -row 2 -column 0 \
	-columnspan 2 \
	-sticky ew
	grid $stations -in . -row 3 -column 0 \
	-sticky nesw \
	-padx "0 2"
	grid $tvBg -in . -row 3 -column 1 \
	-sticky nesw
	grid $toolbStation -in . -row 4 -column 0 \
	-sticky ew
	grid $toolbBot -in . -row 4 -column 1 \
	-sticky ew
	grid $toolbDisp -in . -row 5 -column 0 \
	-columnspan 2 \
	-sticky ew
	
	grid $menubar.mbTvviewer -in $menubar -row 0 -column 0
	grid $menubar.mbNavigation -in $menubar -row 0 -column 1
	grid $menubar.mbView -in $menubar -row 0 -column 2
	grid $menubar.mbAudio -in $menubar -row 0 -column 3
	grid $menubar.mbHelp -in $menubar -row 0 -column 4
	
	grid $toolbTop.bTimeshift -in $toolbTop -row 0 -column 0 \
	-pady 1
	grid $toolbTop.bRecord -in $toolbTop -row 0 -column 1 \
	-pady 1
	grid $toolbTop.bEpg -in $toolbTop -row 0 -column 2 \
	-pady 1
	grid $toolbTop.bRadio -in $toolbTop -row 0 -column 3 \
	-pady 1
	grid $toolbTop.bTv -in $toolbTop -row 0 -column 4 \
	-pady 1
	grid $toolbTop.lInput -in $toolbTop -row 0 -column 5 \
	-sticky e \
	-padx 1
	grid $toolbTop.lDevice -in $toolbTop -row 0 -column 6 \
	-padx "0 2"
	
	grid $stations.treeSlist -in $stations -row 0 -column 0 \
	-sticky nesw
	grid $stations.scrbSlist -in $stations -row 0 -column 1 \
	-sticky ns
	
	grid $toolbStation.bChanDown -in $toolbStation -row 0 -column 0
	grid $toolbStation.bChanUp -in $toolbStation -row 0 -column 1
	grid $toolbStation.bChanJump -in $toolbStation -row 0 -column 2
	
	grid $toolbBot.bPlay -in $toolbBot -row 0 -column 0 \
	-pady 2 \
	-padx "2 0"
	grid $toolbBot.bPause -in $toolbBot -row 0 -column 1 \
	-pady 2 \
	-padx "2 0"
	grid $toolbBot.bStop -in $toolbBot -row 0 -column 2 \
	-pady 2 \
	-padx "2 0"
	
	grid $toolbBot.seperat1 -in $toolbBot -row 0 -column 3 \
	-sticky ns \
	-pady 6 \
	-padx "2 0"
	
	grid $toolbBot.bRewStart -in $toolbBot -row 0 -column 4 \
	-pady 2 \
	-padx "2 0"
	grid $toolbBot.mbRewChoose -in $toolbBot -row 0 -column 5 \
	-sticky ns \
	-pady 2 \
	-padx "2 0"
	grid $toolbBot.bRewSmall -in $toolbBot -row 0 -column 6 \
	-pady 2
	grid $toolbBot.bForwSmall -in $toolbBot -row 0 -column 7 \
	-pady 2 \
	-padx "2 0"
	grid $toolbBot.mbForwChoose -in $toolbBot -row 0 -column 8 \
	-sticky ns \
	-pady 2
	grid $toolbBot.bForwEnd -in $toolbBot -row 0 -column 9 \
	-pady 2 \
	-padx "2 0"
	
	grid $toolbBot.seperat2 -in $toolbBot -row 0 -column 10 \
	-sticky ns \
	-pady 6 \
	-padx "2 0"
	
	grid $toolbBot.bSave -in $toolbBot -row 0 -column 11 \
	-pady 2 \
	-padx "2 0"
	
	grid $toolbBot.bVolMute -in $toolbBot -row 0 -column 12 \
	-pady 2 \
	-padx "2 0" \
	-sticky e
	grid $toolbBot.scVolume -in $toolbBot -row 0 -column 13 \
	-pady 2 \
	-padx "2 6"
	
	grid $toolbDisp.lDispIcon -in $toolbDisp -row 0 -column 0 \
	-sticky nsw \
	-padx 2
	grid $toolbDisp.lDispText -in $toolbDisp -row 0 -column 1 \
	-sticky nsw \
	-padx "0 2"
	grid $toolbDisp.lTime -in $toolbDisp -row 0 -column 2  \
	-sticky nse \
	-padx "2"
	
	
	grid rowconfigure . 3 -weight 1
	grid rowconfigure $stations 0 -weight 1
	grid columnconfigure . 0 -weight 1
	grid columnconfigure . 1 -weight 10000 -minsize 250
	grid columnconfigure $stations 0 -weight 1
	grid columnconfigure $toolbTop 5 -weight 1
	grid columnconfigure $toolbBot 12 -weight 1
	grid columnconfigure $toolbDisp 2 -weight 1
	
	place $tvBg.l_bgImage -relx 0.5 -rely 0.5 -anchor center
	
	set ::tv(stayontop) 0
	set ::option(cursor_old) [$tvCont cget -cursor]
	set ::data(panscan) 0
	set ::data(panscanAuto) 0
	set ::data(movevidX) 0
	set ::data(movevidY) 0
	set ::main(volume_scale) 100
	set ::main(label_file_time) " --:-- / --:--"
	set ::chan(old_channel) 0
	
	#FIXME Simplify and wrap the following code. Additionally swap out something to different procs
	
	main_frontendMenu $menubar $toolbBot $tvBg
	main_frontendChannelHandler main
	
	if {$::main(running_recording) == 0} {
		
		if {$::option(forcevideo_standard) == 1} {
			main_pic_streamForceVideoStandard
		}
		
		if {$::option(streambitrate) == 1} {
			main_pic_streamVbitrate
		}
		
		if {$::option(temporal_filter) == 1} {
			main_pic_streamPicqualTemporal
		}
		
		main_pic_streamColormControls
		
		catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=mute=0}
		
		if {$::option(audio_v4l2) == 1} {
			main_pic_streamAudioV4l2
		}
	}
	
	tooltips $toolbTop $toolbStation $toolbBot main
	
	if {$::option(newsreader) == 1} {
		after 5000 main_newsreaderAutomaticUpdate
	}
	
	wm title . [mc "TV-Viewer %" [lindex $::option(release_version) 0]]
	wm protocol . WM_DELETE_WINDOW [list event generate . <<exit>>]
	wm iconphoto . $::icon_e(tv-viewer_icon)
	
	bind . <Key-x> {puts "width tree [winfo width .fstations.treeSlist]"; puts "width treefrrame [winfo width .fstations]"; puts "width column name [.fstations.treeSlist column name -width]";  puts "width column number [.fstations.treeSlist column number -width]"}
	
	command_socket
	
	if {$::option(show_splash) == 1} {
		if {$::option(starttv_startup) == 1} {
			if {[string trim [auto_execok mplayer]] != {}} {
				if {$::main(running_recording) == 1} {
					after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash ; record_linkerPrestart record ; record_linkerRec record}
				} else {
					after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash ; event generate . <<teleview>>}
				}
			} else {
				log_writeOutTv 2 "Can't start tv playback, MPlayer is not installed on this system."
				after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ;  destroy .splash}
				$toolbTop.bRecord state disabled
				$toolbTop.bEpg state disabled
				$toolbTop.bRadio state disabled
				$toolbTop.bTv state disabled
				#$wfbar.mOptions entryconfigure 4 -state disabled
				event delete <<record>>
				event delete <<teleview>>
				event delete <<timeshift>>
				bind . <<record>> {}
				bind . <<timeshift>> {}
				bind . <<teleview>> {}
			}
		} else {
			if {[string trim [auto_execok mplayer]] != {}} {
				if {$::main(running_recording) == 1} {
					after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash ; record_linkerPrestart record ; record_linkerRec record}
				} else {
					after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash}
				}
			} else {
				after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash ; tv_playerUi}
				$toolbTop.bRecord state disabled
				$toolbTop.bEpg state disabled
				$toolbTop.bRadio state disabled
				$toolbTop.bTv state disabled
				#$wfbar.mOptions entryconfigure 4 -state disabled
				log_writeOutTv 2 "Deactivating Button \"Start TV\" because MPlayer is not installed."
				event delete <<record>>
				event delete <<teleview>>
				event delete <<timeshift>>
				bind . <<record>> {}
				bind . <<timeshift>> {}
				bind . <<teleview>> {}
			}
		}
	} else {
		if {$::option(starttv_startup) == 1} {
			if {[string trim [auto_execok mplayer]] != {}} {
				if {$::main(running_recording) == 1} {
					after 1500 {wm deiconify . ; record_linkerPrestart record ; record_linkerRec record}
				} else {
					after 1500 {wm deiconify . ; event generate . <<teleview>>}
				}
			} else {
				log_writeOutTv 2 "Can't start tv playback, MPlayer is not installed on this system."
				after 1500 {wm deiconify .}
				$toolbTop.bRecord state disabled
				$toolbTop.bEpg state disabled
				$toolbTop.bRadio state disabled
				$toolbTop.bTv state disabled
				#$wfbar.mOptions entryconfigure 4 -state disabled
				event delete <<record>>
				event delete <<teleview>>
				event delete <<timeshift>>
				bind . <<record>> {}
				bind . <<timeshift>> {}
				bind . <<teleview>> {}
			}
		} else {
			if {[string trim [auto_execok mplayer]] == {}} {
				$toolbTop.bRecord state disabled
				$toolbTop.bEpg state disabled
				$toolbTop.bRadio state disabled
				$toolbTop.bTv state disabled
				#$wfbar.mOptions entryconfigure 4 -state disabled
				log_writeOutTv 2 "Deactivating Button \"Start TV\" because MPlayer is not installed."
				event delete <<record>>
				event delete <<teleview>>
				event delete <<timeshift>>
				bind . <<record>> {}
				bind . <<timeshift>> {}
				bind . <<teleview>> {}
				after 1500 {wm deiconify .}
			} else {
				if {$::main(running_recording) == 1} {
					after 1500 {wm deiconify . ; record_linkerPrestart record ; record_linkerRec record}
				} else {
					after 1500 {wm deiconify .}
				}
			}
		}
	}
	
	#FIXME Hide cursor in windowed mode?
	
	bind $tvCont <Motion> {
		tv_wmCursorHide .ftvBg.cont 0
		#~ tv_wmCursorPlaybar %Y
		#~ tv_slistCursor %X %Y
	}
	bind $tvBg <Motion> {
		tv_wmCursorHide .ftvBg 0
		#~ tv_wmCursorPlaybar %Y
		#~ tv_slistCursor %X %Y
	}
	bind . <ButtonPress-1> {.ftvBg.cont configure -cursor arrow
							.ftvBg configure -cursor arrow}
	set ::cursor($tvCont) ""
	set ::cursor($tvBg) ""
	tv_wmCursorHide $tvCont 0
	tv_wmCursorHide $tvBg 0
	
	if {$::option(systray_start) == 1} {
		set ::choice(cb_systray_main) 1
		main_systemTrayActivate 1
		if {[winfo exists .tray]} {
			settooltip .tray [mc "TV-Viewer idle"]
		}
		main_systemTrayToggle
		tkwait visibility .
		autoscroll $stations.scrbSlist
		#FIXME Does root window need a minsize?
		#~ wm minsize . [winfo reqwidth .] [winfo reqheight .]
		set height [expr [winfo height .foptions_bar] + [winfo height .seperatMenu] + [winfo height .ftoolb_Top] + [winfo height .ftoolb_Bot] + [winfo height .ftoolb_Disp] + 141]
		wm minsize . 250 $height
	} else {
		tkwait visibility .
		autoscroll $stations.scrbSlist
		set height [expr [winfo height .foptions_bar] + [winfo height .seperatMenu] + [winfo height .ftoolb_Top] + [winfo height .ftoolb_Bot] + [winfo height .ftoolb_Disp] + 141]
		wm minsize . 250 $height
	}
	
	#FIXME No longer close to tray, this needs to be reworked probably.
	#~ if {$::option(systray_close) == 1} {
		#~ wm protocol . WM_DELETE_WINDOW {main_systemTrayTogglePre}
	#~ } else {
		#~ wm protocol . WM_DELETE_WINDOW [list event generate . <<exit>>]
	#~ }
}

proc main_frontendUiTvviewer {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendUiTvviewer \033\[0m"
	# Setting up main Interface
	
	log_writeOutTv 0 "Setting up main interface."
	
	place [ttk::frame .bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
	
	set wfbar [ttk::frame .options_bar] ; place [ttk::label $wfbar.bg -style Toolbutton] -relwidth 1 -relheight 1
	
	ttk::separator .sep_bar -orient horizontal
	
	set wftop [ttk::frame .top_buttons] ; place [ttk::label $wftop.bg -style Toolbutton] -relwidth 1 -relheight 1
	
	set wfbottom [ttk::frame .bottom_buttons] ; place [ttk::label $wfbottom.bg -style Toolbutton] -relwidth 1 -relheight 1
	
	ttk::menubutton $wfbar.mb_options \
	-menu $wfbar.mOptions \
	-text [mc "Options"] \
	-underline 0 \
	-style Toolbutton
	
	ttk::menubutton $wfbar.mb_help \
	-menu $wfbar.mHelp \
	-text [mc "Help"] \
	-underline 0 \
	-style Toolbutton
	
	label .label_stations \
	-borderwidth 2 \
	-relief sunken \
	-anchor center \
	-width 11
	catch {.label_stations configure -font -*-Helvetica-Bold-R-Normal-*-*-280-*-*-*-*-*-* -foreground #00a006 -background black}
	
	ttk::button $wfbottom.button_channelup \
	-image $::icon_m(channel-up) \
	-style Toolbutton \
	-takefocus 0 \
	-command [list main_stationChannelUp .label_stations]
	
	ttk::button $wfbottom.button_channeldown \
	-image $::icon_m(channel-down) \
	-style Toolbutton \
	-takefocus 0 \
	-command [list main_stationChannelDown .label_stations]
	
	ttk::button $wfbottom.button_channeljumpback \
	-image $::icon_m(channel-jump) \
	-style Toolbutton \
	-takefocus 0 \
	-command [list main_stationChannelJumper .label_stations]
	
	ttk::button $wfbottom.button_showslist \
	-image $::icon_m(stationlist) \
	-style Toolbutton \
	-takefocus 0 \
	-command [list main_frontendShowslist $wfbottom]
	
	ttk::scale $wfbottom.scale_volume \
	-orient horizontal \
	-variable main(volume_scale) \
	-command [list tv_playerVolumeControl .ftoolb_Bot.scVolume .ftoolb_Bot.bVolMute] \
	-from 0 \
	-to 100
	set ::main(volume_scale) 100
	
	ttk::button $wfbottom.button_mute \
	-image $::icon_m(volume) \
	-style Toolbutton \
	-takefocus 0 \
	-command [list tv_playerVolumeControl .ftoolb_Bot.scVolume .ftoolb_Bot.bVolMute mute]
	
	ttk::button $wftop.button_timeshift \
	-image $::icon_m(timeshift) \
	-style Toolbutton \
	-takefocus 0 \
	-command {event generate . <<timeshift>>}
	
	ttk::button $wftop.button_record \
	-image $::icon_m(record) \
	-style Toolbutton \
	-takefocus 0 \
	-command [list record_wizardUi]
	
	ttk::button $wftop.button_epg \
	-text EPG \
	-style Toolbutton \
	-takefocus 0 \
	-command main_frontendEpg
	
	ttk::button $wftop.button_starttv \
	-image $::icon_m(starttv) \
	-style Toolbutton \
	-takefocus 0 \
	-command tv_playerRendering
	
	menu $wfbar.mOptions \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))
	menu $wfbar.mHelp \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))
	
	grid $wfbar -in . -row 0 -column 0 \
	-columnspan 3 \
	-sticky new
	grid .sep_bar -in . -row 1 -column 0 \
	-columnspan 3 \
	-sticky ew
	grid $wftop -in . -row 2 -column 0 \
	-columnspan 3 \
	-sticky nwe
	grid $wfbottom -in . -row 5 -column 0 \
	-columnspan 3 \
	-sticky swe
	grid .label_stations -in . -row 3 -column 0 \
	-columnspan 3 \
	-sticky news \
	-padx 4
	grid $wfbar.mb_options -in $wfbar -row 0 -column 0
	grid $wfbar.mb_help -in $wfbar -row 0 -column 1
	grid $wfbottom.button_showslist -in $wfbottom -row 0 -column 0 \
	-padx 2 \
	-pady 2 \
	-sticky ns
	grid $wfbottom.button_channeldown -in $wfbottom -row 0 -column 1 \
	-pady 2 \
	-sticky ns
	grid $wfbottom.button_channelup -in $wfbottom -row 0 -column 2 \
	-padx 2 \
	-pady 2 \
	-sticky ns
	grid $wfbottom.button_channeljumpback -in $wfbottom -row 0 -column 3 \
	-pady 2 \
	-sticky ns
	grid $wfbottom.scale_volume -in $wfbottom -row 0 -column 5 \
	-padx 2
	grid $wfbottom.button_mute -in $wfbottom -row 0 -column 4 \
	-padx "10 2" \
	-pady 2 \
	-sticky nes
	
	grid $wftop.button_timeshift -in $wftop -row 0 -column 0 \
	-padx 2 \
	-pady 2 \
	-sticky ns
	grid $wftop.button_record -in $wftop -row 0 -column 1 \
	-padx 2 \
	-pady 2 \
	-sticky ns
	grid $wftop.button_epg -in $wftop -row 0 -column 2 \
	-padx 2 \
	-pady 2 \
	-sticky ns
	grid $wftop.button_starttv -in $wftop -row 0 -column 3 \
	-pady 2 \
	-padx 2 \
	-sticky ns
	
	grid rowconfigure . 4 -weight 1
	grid columnconfigure . 0 -weight 1
	grid columnconfigure $wfbottom 4 -weight 1
	
	# Additional Code
	
	$wfbar.mOptions add separator
	$wfbar.mOptions add command \
	-label [mc "Color Management"] \
	-compound left \
	-image $::icon_s(color-management) \
	-command colorm_mainUi \
	-accelerator [mc "Ctrl+M"]
	$wfbar.mOptions add command \
	-label [mc "Preferences"] \
	-compound left \
	-image $::icon_s(settings) \
	-accelerator [mc "Ctrl+P"] \
	-command {config_wizardMainUi}
	$wfbar.mOptions add command \
	-label [mc "Station Editor"] \
	-compound left \
	-image $::icon_s(seditor) \
	-command {station_editUi} \
	-accelerator [mc "Ctrl+E"]
	$wfbar.mOptions add command \
	-label [mc "Record Wizard"] \
	-compound left \
	-image $::icon_s(record) \
	-command {event generate . <<record>>} \
	-accelerator "R"
	$wfbar.mOptions add separator
	$wfbar.mOptions add command \
	-label [mc "Newsreader"] \
	-compound left \
	-image $::icon_s(newsreader) \
	-command [list main_newsreaderCheckUpdate 0]
	$wfbar.mOptions add checkbutton \
	-label [mc "System Tray"] \
	-command {main_systemTrayActivate 0} \
	-variable choice(cb_systray_main)
	$wfbar.mOptions add separator
	$wfbar.mOptions add command \
	-label [mc "Exit"] \
	-compound left \
	-image $::icon_s(dialog-close) \
	-command [list event generate . <<exit>>] \
	-accelerator [mc "Ctrl+X"]
	
	$wfbar.mHelp add separator
	$wfbar.mHelp add command \
	-command info_helpHelp \
	-compound left \
	-image $::icon_s(help) \
	-label [mc "User Guide"] \
	-accelerator F1
	$wfbar.mHelp add command \
	-command key_sequences \
	-compound left \
	-image $::icon_s(key-bindings) \
	-label [mc "Key Sequences"]
	$wfbar.mHelp add separator
	$wfbar.mHelp add checkbutton \
	-command [list log_viewerUi 2] \
	-label [mc "MPlayer Log"] \
	-variable choice(cb_log_mpl_main)
	$wfbar.mHelp add checkbutton \
	-command [list log_viewerUi 3] \
	-label [mc "Scheduler Log"] \
	-variable choice(cb_log_sched_main)
	$wfbar.mHelp add checkbutton \
	-command [list log_viewerUi 1] \
	-label [mc "TV-Viewer Log"] \
	-variable choice(cb_log_tv_main)
	$wfbar.mHelp add separator
	$wfbar.mHelp add command \
	-label [mc "Diagnostic Routine"] \
	-compound left \
	-image $::icon_s(diag) \
	-command diag_Ui
	$wfbar.mHelp add separator
	$wfbar.mHelp add command \
	-command info_helpAbout \
	-compound left \
	-image $::icon_s(help-about) \
	-label [mc "Info"]
	
	if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
		.label_stations configure -text ...
		foreach widget [split [winfo children $wftop]] {
			$widget state disabled
		}
		foreach widget [split [winfo children $wfbottom]] {
			if {[string match *scale_volume $widget] || [string match *button_mute $widget]} continue
			$widget state disabled
		}
		event_constr 0
	} else {
		.label_stations configure -text [lindex $::station(last) 0]
		event_constr 1
	}
	
	# Hier alles einfügen was noch ausgeführt werden muss. picqual ...
	
	if {$::main(running_recording) == 0} {
		
		if {$::option(forcevideo_standard) == 1} {
			main_pic_streamForceVideoStandard
		}
		
		if {$::option(streambitrate) == 1} {
			main_pic_streamVbitrate
		}
		
		if {$::option(temporal_filter) == 1} {
			main_pic_streamPicqualTemporal
		}
		
		main_pic_streamColormControls
		
		catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=mute=0}
		
		if {$::option(audio_v4l2) == 1} {
			main_pic_streamAudioV4l2
		}
	}
	
	tooltips $wfbottom $wftop main
	
	if {$::option(newsreader) == 1} {
		after 5000 main_newsreaderAutomaticUpdate
	}
	
	wm resizable . 0 0
	wm title . [mc "TV-Viewer %" [lindex $::option(release_version) 0]]
	wm protocol . WM_DELETE_WINDOW [list event generate . <<exit>>]
	wm iconphoto . $::icon_e(tv-viewer_icon)
	
	command_socket
	
	if {$::option(show_splash) == 1} {
		if {$::option(starttv_startup) == 1} {
			if {[string trim [auto_execok mplayer]] != {}} {
				if {$::main(running_recording) == 1} {
					after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash ; tv_playerUi ; record_linkerPrestart record ; record_linkerRec record}
				} else {
					after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash ; tv_playerUi ; event generate . <<teleview>>}
				}
			} else {
				log_writeOutTv 2 "Can't start tv playback, MPlayer is not installed on this system."
				after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ;  destroy .splash ; tv_playerUi}
				$wftop.button_starttv state disabled
				$wftop.button_record state disabled
				$wftop.button_timeshift state disabled
				$wfbar.mOptions entryconfigure 4 -state disabled
				event delete <<record>>
				event delete <<teleview>>
				event delete <<timeshift>>
				bind . <<record>> {}
				bind . <<timeshift>> {}
				bind . <<teleview>> {}
			}
		} else {
			if {[string trim [auto_execok mplayer]] != {}} {
				if {$::main(running_recording) == 1} {
					after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash ; tv_playerUi ; record_linkerPrestart record ; record_linkerRec record}
				} else {
					after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash ; tv_playerUi}
				}
			} else {
				after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash ; tv_playerUi}
				$wftop.button_starttv state disabled
				$wftop.button_record state disabled
				$wftop.button_timeshift state disabled
				$wfbar.mOptions entryconfigure 4 -state disabled
				log_writeOutTv 2 "Deactivating Button \"Start TV\" because MPlayer is not installed."
				event delete <<record>>
				event delete <<teleview>>
				event delete <<timeshift>>
				bind . <<record>> {}
				bind . <<timeshift>> {}
				bind . <<teleview>> {}
			}
		}
	} else {
		if {$::option(starttv_startup) == 1} {
			if {[string trim [auto_execok mplayer]] != {}} {
				if {$::main(running_recording) == 1} {
					after 1500 {wm deiconify . ; tv_playerUi ; record_linkerPrestart record ; record_linkerRec record}
				} else {
					after 1500 {wm deiconify . ; tv_playerUi ; event generate . <<teleview>>}
				}
			} else {
				log_writeOutTv 2 "Can't start tv playback, MPlayer is not installed on this system."
				after 1500 {wm deiconify . ; tv_playerUi}
				$wftop.button_starttv state disabled
				$wftop.button_record state disabled
				$wftop.button_timeshift state disabled
				$wfbar.mOptions entryconfigure 4 -state disabled
				event delete <<record>>
				event delete <<teleview>>
				event delete <<timeshift>>
				bind . <<record>> {}
				bind . <<timeshift>> {}
				bind . <<teleview>> {}
			}
		} else {
			if {[string trim [auto_execok mplayer]] == {}} {
				$wftop.button_starttv state disabled
				$wftop.button_record state disabled
				$wftop.button_timeshift state disabled
				$wfbar.mOptions entryconfigure 4 -state disabled
				log_writeOutTv 2 "Deactivating Button \"Start TV\" because MPlayer is not installed."
				event delete <<record>>
				event delete <<teleview>>
				event delete <<timeshift>>
				bind . <<record>> {}
				bind . <<timeshift>> {}
				bind . <<teleview>> {}
				after 1500 {wm deiconify . ; tv_playerUi}
			} else {
				if {$::main(running_recording) == 1} {
					after 1500 {wm deiconify . ; tv_playerUi ; record_linkerPrestart record ; record_linkerRec record}
				} else {
					after 1500 {wm deiconify . ; tv_playerUi}
				}
			}
		}
	}
	if {$::option(systray_start) == 1} {
		set ::choice(cb_systray_main) 1
		main_systemTrayActivate 1
		if {[winfo exists .tray]} {
			settooltip .tray [mc "TV-Viewer idle"]
		}
		tkwait visibility .
		wm minsize . [winfo reqwidth .] [winfo reqheight .]
		main_systemTrayToggle
	} else {
		tkwait visibility .
		wm minsize . [winfo reqwidth .] [winfo reqheight .]
	}
	if {$::option(show_slist) == 1} {
		main_frontendShowslist $wfbottom
	}
	if {$::option(systray_close) == 1} {
		wm protocol . WM_DELETE_WINDOW {main_systemTrayTogglePre}
	} else {
		wm protocol . WM_DELETE_WINDOW [list event generate . <<exit>>]
	}
}
