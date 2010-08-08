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
	if {[info exists ::vid(pbMode)]} {
		if {$::vid(pbMode) == 1} {
			set status_tv [vid_callbackMplayerRemote alive]
			if {$status_tv != 1} {
				vid_playbackStop 0 nopic
			}
		} else {
			set status_tv [vid_callbackMplayerRemote alive]
			if {$status_tv != 1} {
				vid_playbackStop 0 pic
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
		set status_vid_Playback [vid_callbackMplayerRemote alive]
		if {$status_vid_Playback != 1} {
			vid_playbackStop 0 pic
		}
		main_frontendDisableTree .fstations.treeSlist 1
		bind .fstations.treeSlist <<TreeviewSelect>> {}
		.ftoolb_Top.lInput configure -text [mc "unknown"]
		foreach widget [split [winfo children .ftoolb_Top]] {
			catch {$widget state disabled}
		}
		foreach widget [split [winfo children .ftoolb_ChanCtrl]] {
			catch {$widget state disabled}
		}
		foreach widget [split [winfo children .ftoolb_Play]] {
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
			foreach widget [split [winfo children .ftoolb_ChanCtrl]] {
				catch {$widget state disabled}
			}
			foreach widget [split [winfo children .ftoolb_Play]] {
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

proc main_frontendUi {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendUi \033\[0m "
	place [ttk::frame .bg] -x 0 -y 0 -relwidth 1 -relheight 1

	set menubar [ttk::frame .foptions_bar] ; place [ttk::label $menubar.bg -style Toolbutton] -relwidth 1 -relheight 1
	
	ttk::separator .seperatMenu -orient horizontal
		
	set toolbTop [ttk::frame .ftoolb_Top] ; place [ttk::label $toolbTop.bg -style Toolbutton] -relwidth 1 -relheight 1
	
	set stations [ttk::frame .fstations] ; place [ttk::label $stations.bg -style Toolbutton] -relwidth 1 -relheight 1
	
	set toolbChanCtrl [ttk::frame .ftoolb_ChanCtrl] ; place [ttk::label $toolbChanCtrl.bg -style Toolbutton] -relwidth 1 -relheight 1
	
	set toolbPlay [ttk::frame .ftoolb_Play] ; place [ttk::label $toolbPlay.bg -style Toolbutton] -relwidth 1 -relheight 1
	
	set toolbDisp [frame .ftoolb_Disp -background black]
	
	set tvBg [frame .ftvBg -background black -height 480 -width 654]
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
	-command vid_playerRendering
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
	
	ttk::button $toolbChanCtrl.bChanDown \
	-image $::icon_m(channel-down) \
	-style Toolbutton \
	-command [list chan_zapperDown $stations.treeSlist]
	ttk::button $toolbChanCtrl.bChanUp \
	-image $::icon_m(channel-up) \
	-style Toolbutton \
	-command [list chan_zapperUp $stations.treeSlist]
	ttk::button $toolbChanCtrl.bChanJump \
	-image $::icon_m(channel-jump) \
	-style Toolbutton \
	-command [list chan_zapperJump $stations.treeSlist]
	
	ttk::button $toolbPlay.bPlay \
	-image $::icon_m(playback-start) \
	-style Toolbutton \
	-state disabled \
	-command {event generate . <<start>>}
	ttk::button $toolbPlay.bPause \
	-image $::icon_m(playback-pause) \
	-style Toolbutton \
	-state disabled \
	-command {event generate . <<pause>>}
	ttk::button $toolbPlay.bStop \
	-image $::icon_m(playback-stop) \
	-style Toolbutton \
	-state disabled \
	-command {event generate . <<stop>>}
	
	ttk::separator $toolbPlay.seperat1 \
	-orient vertical
	
	ttk::button $toolbPlay.bRewStart \
	-style Toolbutton \
	-image $::icon_m(rewind-first) \
	-state disabled \
	-command {event generate . <<rewind_start>>}
	ttk::button $toolbPlay.bRewSmall \
	-style Toolbutton \
	-image $::icon_m(rewind-small) \
	-state disabled \
	-command {event generate . <<rewind_10s>>}
	ttk::menubutton $toolbPlay.mbRewChoose \
	-style Toolbutton \
	-image $::icon_e(arrow-d) \
	-menu $toolbPlay.mbRewChoose.mRewChoose \
	-state disabled
	ttk::button $toolbPlay.bForwSmall \
	-style Toolbutton \
	-image $::icon_m(forward-small) \
	-state disabled \
	-command {event generate . <<forward_10s>>}
	ttk::menubutton $toolbPlay.mbForwChoose \
	-style Toolbutton \
	-image $::icon_e(arrow-d) \
	-menu $toolbPlay.mbForwChoose.mForwChoose \
	-state disabled
	ttk::button $toolbPlay.bForwEnd \
	-style Toolbutton \
	-image $::icon_m(forward-last) \
	-state disabled \
	-command {event generate . <<forward_end>>}
	
	ttk::separator $toolbPlay.seperat2 \
	-orient vertical
	
	ttk::button $toolbPlay.bSave \
	-style Toolbutton \
	-image $::icon_m(floppy) \
	-state disabled \
	-command [list timeshift_Save .]
	
	ttk::button $toolbPlay.bVolMute \
	-style Toolbutton \
	-image $::icon_m(volume) \
	-command [list vid_playerVolumeControl .ftoolb_Play.scVolume .ftoolb_Play.bVolMute mute]
	ttk::scale $toolbPlay.scVolume \
	-orient horizontal \
	-from 0 \
	-to 100 \
	-variable main(volume_scale) \
	-command [list vid_playerVolumeControl .ftoolb_Play.scVolume .ftoolb_Play.bVolMute] \
	
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
	grid $toolbChanCtrl -in . -row 4 -column 0 \
	-sticky ew
	grid $toolbPlay -in . -row 4 -column 1 \
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
	
	grid $toolbChanCtrl.bChanDown -in $toolbChanCtrl -row 0 -column 0 \
	-pady 2 \
	-padx "2 0"
	grid $toolbChanCtrl.bChanUp -in $toolbChanCtrl -row 0 -column 1 \
	-pady 2 \
	-padx "2 0"
	grid $toolbChanCtrl.bChanJump -in $toolbChanCtrl -row 0 -column 2 \
	-pady 2 \
	-padx "2 0"
	
	grid $toolbPlay.bPlay -in $toolbPlay -row 0 -column 0 \
	-pady 2 \
	-padx "2 0"
	grid $toolbPlay.bPause -in $toolbPlay -row 0 -column 1 \
	-pady 2 \
	-padx "2 0"
	grid $toolbPlay.bStop -in $toolbPlay -row 0 -column 2 \
	-pady 2 \
	-padx "2 0"
	
	grid $toolbPlay.seperat1 -in $toolbPlay -row 0 -column 3 \
	-sticky ns \
	-pady 6 \
	-padx "2 0"
	
	grid $toolbPlay.bRewStart -in $toolbPlay -row 0 -column 4 \
	-pady 2 \
	-padx "2 0"
	grid $toolbPlay.mbRewChoose -in $toolbPlay -row 0 -column 5 \
	-sticky ns \
	-pady 2 \
	-padx "2 0"
	grid $toolbPlay.bRewSmall -in $toolbPlay -row 0 -column 6 \
	-pady 2
	grid $toolbPlay.bForwSmall -in $toolbPlay -row 0 -column 7 \
	-pady 2 \
	-padx "2 0"
	grid $toolbPlay.mbForwChoose -in $toolbPlay -row 0 -column 8 \
	-sticky ns \
	-pady 2
	grid $toolbPlay.bForwEnd -in $toolbPlay -row 0 -column 9 \
	-pady 2 \
	-padx "2 0"
	
	grid $toolbPlay.seperat2 -in $toolbPlay -row 0 -column 10 \
	-sticky ns \
	-pady 6 \
	-padx "2 0"
	
	grid $toolbPlay.bSave -in $toolbPlay -row 0 -column 11 \
	-pady 2 \
	-padx "2 0"
	
	grid $toolbPlay.bVolMute -in $toolbPlay -row 0 -column 12 \
	-pady 2 \
	-padx "2 0" \
	-sticky e
	grid $toolbPlay.scVolume -in $toolbPlay -row 0 -column 13 \
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
	grid columnconfigure $toolbPlay 12 -weight 1
	grid columnconfigure $toolbDisp 2 -weight 1
	
	place $tvBg.l_bgImage -relx 0.5 -rely 0.5 -anchor center
	
	set ::vid(stayontop) 0
	set ::option(cursor_old) [$tvCont cget -cursor]
	set ::main(compactMode) 0
	set ::data(panscan) 0
	set ::data(panscanAuto) 0
	set ::data(movevidX) 0
	set ::data(movevidY) 0
	set ::main(volume_scale) 100
	set ::main(label_file_time) " --:-- / --:--"
	set ::chan(old_channel) 0
	
	#FIXME Simplify and wrap the following code. Additionally swap out something to different procs
	
	main_menuTvview $menubar $toolbChanCtrl $toolbPlay $tvBg standard
	main_menuNav $menubar $toolbChanCtrl $toolbPlay $tvBg standard
	main_menuView $menubar $toolbChanCtrl $toolbPlay $tvBg standard
	main_menuAud $menubar $toolbChanCtrl $toolbPlay $tvBg standard
	main_menuHelp $menubar $toolbChanCtrl $toolbPlay $tvBg standard
	main_menuReFo $menubar $toolbChanCtrl $toolbPlay $tvBg standard
	main_menuContext $menubar $toolbChanCtrl $toolbPlay $tvBg
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
	
	tooltips $toolbTop $toolbChanCtrl $toolbPlay main
	
	if {$::option(newsreader) == 1} {
		after 5000 main_newsreaderAutomaticUpdate
	}
	
	wm title . [mc "TV-Viewer %" [lindex $::option(release_version) 0]]
	wm protocol . WM_DELETE_WINDOW [list event generate . <<exit>>]
	wm iconphoto . $::icon_e(tv-viewer_icon)
	
	bind . <Key-x> {puts "width [winfo width .ftvBg]"; puts "height [winfo height .ftvBg]"}
	bind . <Key-y> {wm geometry . {}; .ftvBg configure -width $::option(resolx) -height $::option(resoly)}
	
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
		vid_wmCursorHide .ftvBg.cont 0
		#~ vid_wmCursorPlaybar %Y
		#~ vid_slistCursor %X %Y
	}
	bind $tvBg <Motion> {
		vid_wmCursorHide .ftvBg 0
		#~ vid_wmCursorPlaybar %Y
		#~ vid_slistCursor %X %Y
	}
	bind . <ButtonPress-1> {.ftvBg.cont configure -cursor arrow
							.ftvBg configure -cursor arrow}
	set ::cursor($tvCont) ""
	set ::cursor($tvBg) ""
	vid_wmCursorHide $tvCont 0
	vid_wmCursorHide $tvBg 0
	
	if {$::option(systray_start) == 1} {
		set ::choice(cb_systray_main) 1
		main_systemTrayActivate 1
		if {[winfo exists .tray]} {
			settooltip .tray [mc "TV-Viewer idle"]
		}
		main_systemTrayToggle
		tkwait visibility .
		autoscroll $stations.scrbSlist
		set height [expr [winfo height .foptions_bar] + [winfo height .seperatMenu] + [winfo height .ftoolb_Top] + [winfo height .ftoolb_Play] + [winfo height .ftoolb_Disp] + 141]
		wm minsize . 250 $height
	} else {
		tkwait visibility .
		autoscroll $stations.scrbSlist
		set height [expr [winfo height .foptions_bar] + [winfo height .seperatMenu] + [winfo height .ftoolb_Top] + [winfo height .ftoolb_Play] + [winfo height .ftoolb_Disp] + 141]
		wm minsize . 250 $height
	}
	
	#FIXME No longer close to tray, this needs to be reworked probably.
	#~ if {$::option(systray_close) == 1} {
		#~ wm protocol . WM_DELETE_WINDOW {main_systemTrayTogglePre}
	#~ } else {
		#~ wm protocol . WM_DELETE_WINDOW [list event generate . <<exit>>]
	#~ }
}
