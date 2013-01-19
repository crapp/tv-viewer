#       main_frontend.tcl
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

proc main_frontendExitViewer {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendExitViewer \033\[0m"
	set status_time [monitor_partRunning 4]
	if {[lindex $status_time 0] == 1} {
		log_writeOut ::log(tvAppend) 0 "Timeshift (PID: [lindex $status_time 1]) is running, will stop it."
		catch {exec kill [lindex $status_time 1]}
		catch {file delete "$::option(home)/tmp/timeshift_lockfile.tmp"}
	}
	if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"]} {
		catch {file delete -force "[subst $::option(timeshift_path)/timeshift.mpeg]"}
	}
	catch {file delete "$::option(home)/tmp/lockfile.tmp"}
	set done 0
	catch {file delete "$::option(home)/config/tv-viewer_mem.conf"}
	set wconfig_mem [open "$::option(home)/config/tv-viewer_mem.conf" w+]
	foreach {okey oelem} [array get ::mem] {
		if {$::option(window_remGeom)} {
			if {[wm attributes . -fullscreen] == 0} {
				if {"$okey" == "mainwidth"} {
					set width [lindex [split [string range [wm geometry .] 0 [expr [string first + [wm geometry .]] -1]] x] 0]
					if {$width < [expr [winfo screenwidth .] - 100]} {
						puts $wconfig_mem "mainwidth $width"
						set ::mem(mainwidth) $width
						continue
					}
				}
				if {"$okey" == "mainheight"} {
					set height [lindex [split [string range [wm geometry .] 0 [expr [string first + [wm geometry .]] -1]] x] 1]
					if {$height < [expr [winfo screenheight .] - 100]} {
						puts $wconfig_mem "mainheight $height"
						set ::mem(mainheight) $height
						continue
					}
				}
				if {"$okey" == "mainX"} {
					set x [lindex [split [string trimleft [string range [wm geometry .] [string first + [wm geometry .]] end] +] +] 0]
					puts $wconfig_mem "mainX $x"
					set ::mem(mainX) $x
					continue
				}
				if {"$okey" == "mainY"} {
					set y [lindex [split [string trimleft [string range [wm geometry .] [string first + [wm geometry .]] end] +] +] 1]
					puts $wconfig_mem "mainY $y"
					set ::mem(mainY) $y
					continue
				}
			}
		}
		# This is needed when there is no integer value in mem_conf and tv-viewer is exited in fullscreen mode. Otherwise a program code will be written into mem_conf because it is not substituted.
		if {"$okey" == "mainX" || "$okey" == "mainY" && [string is integer $oelem] == 0} {
			puts $wconfig_mem "$okey [subst $::mem($okey)]"
			set ::mem($okey) [subst $::mem($okey)]
			continue
		}
		if {$::option(volRem)} {
			if {"$okey" == "volume"} {
				if {[.ftoolb_Play.scVolume instate disabled]} {
					set ::mem(volume) $::volume(mute_old_value)
				} else {
					set ::mem(volume) $::main(volume_scale)
				}
				puts $wconfig_mem "volume $::mem(volume)"
				set done 1
				continue
			}
		}
		if {"$okey" == "compact"} {
			puts $wconfig_mem "compact $::main(compactMode)"
			set ::mem(compact) $::main(compactMode)
			continue
		}
		if {"$okey" == "ontop"} {
			puts $wconfig_mem "ontop $::vid(stayontop)"
			set ::mem(ontop) $::vid(stayontop)
			continue
		}
		puts $wconfig_mem "$okey $oelem"
	}
	close $wconfig_mem
	
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
	
	db_interfaceClose
	
	set status_scheduler [monitor_partRunning 2]
	if {[lindex $status_scheduler 0] == 0} {
		catch {file delete -force "$::option(home)/tmp/ComSocketMain"}
		catch {file delete -force "$::option(home)/tmp/ComSocketSched"}
	}
	set status_recorder [monitor_partRunning 3]
	if {[lindex $status_scheduler 0] == 0 && [lindex $status_recorder 0] == 0} {
		command_WritePipe 1 "tv-viewer_notifyd notifydExit"
	}
	catch {close $::data(comsocketRead)}
	catch {close $::data(comsocketWrite)}
	catch {close $::data(comsocketWrite2)}
	puts $::log(tvAppend) "#
#
# Stop session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
########################################################################
"
	puts $::log(mplAppend) "#
#
# Stop session [clock format [clock scan now] -format {%d.%m.%Y %H:%M:%S}]
########################################################################
"
	close $::log(tvAppend)
	close $::log(mplAppend)
	exit 0
}

proc main_frontendEpg {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendEpg \033\[0m"
	log_writeOut ::log(tvAppend) 0 "Launching EPG program..."
	catch {exec sh -c "[subst $::option(epg_command)] >/dev/null 2>&1" &}
}

proc msgcat::mcunknown {locale src args} {
	log_writeOut ::log(tvAppend) 1 "Unknown string for locale $locale"
	log_writeOut ::log(tvAppend) 1 "$src $args"
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
	#handler main; sedit
	if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
		log_writeOut ::log(tvAppend) 2 "There are no stations to insert into station list."
		set status_vid_Playback [vid_callbackMplayerRemote alive]
		if {$status_vid_Playback != 1} {
			vid_playbackStop 0 pic
		}
		set font [ttk::style lookup [.fstations.treeSlist cget -style] -font]
		if {[string trim $font] == {}} {
			set font TkDefaultFont
		}
		.fstations.treeSlist heading name -text [mc "Name"]
		.fstations.treeSlist column name -width [expr [font measure $font [mc "Name"]] + 20]
		.fstations.treeSlist heading number -text [mc "No"]
		.fstations.treeSlist column number -width [expr [font measure $font [mc "No"]] + 20] -anchor center
		main_frontendDisableTree .fstations.treeSlist 1
		bind .fstations.treeSlist <<TreeviewSelect>> {}
		foreach widget [split [winfo children .ftoolb_Top]] {
			catch {$widget state disabled}
		}
		foreach widget [split [winfo children .fstations.ftoolb_ChanCtrl]] {
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
			event_delete nokanal
			set status [monitor_partRunning 2]
			if {[lindex $status 0] == 1} {
				command_WritePipe 0 "tv-viewer_scheduler scheduler_Init 1"
			}
		}
	} else {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_grep_input [catch {agrep -m "$read_vinput" video} resultat_grep_input]
		if {$status_grep_input == 1} {
			log_writeOut ::log(tvAppend) 2 "Can not read video input."
			log_writeOut ::log(tvAppend) 2 "$resultat_grep_input."
		}
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
			ttk::treeview .fstations.treeSlist -yscrollcommand [list .fstations.scrbSlist set] -columns {name number} -show headings -selectmode browse -takefocus 0
			grid .fstations.treeSlist -in .fstations -row 0 -column 0 -sticky nesw
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
				log_writeOut ::log(tvAppend) 1 "Disabling station list due to an active recording."
				main_frontendDisableTree .fstations.treeSlist 1
			}
		}
		if {"$handler" == "sedit"} {
			foreach widget [split [winfo children .ftoolb_Top]] {
				catch {$widget state !disabled}
			}
			foreach widget [split [winfo children .fstations.ftoolb_ChanCtrl]] {
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

	set menubar [ttk::frame .foptions_bar] ; place [ttk::label $menubar.bg -style Toolbutton ] -relwidth 1 -relheight 1
	
	ttk::separator .seperatMenu -orient horizontal
	
	set toolbTop [ttk::frame .ftoolb_Top] ; place [ttk::label $toolbTop.bg -style Toolbutton] -relwidth 1 -relheight 1
	set stations [ttk::frame .fstations] ; place [ttk::label $stations.bg -style Toolbutton] -relwidth 1 -relheight 1
	set toolbChanCtrl [ttk::frame .fstations.ftoolb_ChanCtrl] ; place [ttk::label $toolbChanCtrl.bg -style Toolbutton] -relwidth 1 -relheight 1
	set toolbPlay [ttk::frame .ftoolb_Play] ; place [ttk::label $toolbPlay.bg -style Toolbutton] -relwidth 1 -relheight 1
	set toolbDisp [frame .ftoolb_Disp -background black]
	set toolbDispIcTxt [frame .ftoolb_Disp.fIcTxt -background black]
	
	set vidBg [frame .fvidBg -background black -height 480 -width 654 -bd 1 -relief sunken]
	set vidCont [frame .fvidBg.cont -background "" -container yes]
	
	ttk::menubutton $menubar.mbTvviewer -text TV-Viewer -style Toolbutton -underline 0 -menu $menubar.mbTvviewer.mTvviewer
	ttk::menubutton $menubar.mbNavigation -text [mc "Navigation"] -style Toolbutton -underline 0 -menu $menubar.mbNavigation.mNavigation
	ttk::menubutton $menubar.mbView -text [mc "View"] -style Toolbutton -underline 0 -menu $menubar.mbView.mView
	ttk::menubutton $menubar.mbAudio -text [mc "Audio"] -style Toolbutton -underline 0 -menu $menubar.mbAudio.mAudio
	ttk::menubutton $menubar.mbHelp -text [mc "Help"] -style Toolbutton -underline 0 -menu $menubar.mbHelp.mHelp
	
	ttk::button $toolbTop.bTimeshift -image $::icon_m(timeshift) -style Toolbutton -command {event generate . <<timeshift>>}
	ttk::button $toolbTop.bRecord -image $::icon_m(record) -style Toolbutton -command {event generate . <<record>>}
	ttk::button $toolbTop.bEpg -text EPG -style Toolbutton -command main_frontendEpg
	ttk::button $toolbTop.bRadio -image $::icon_m(radio) -style Toolbutton -command {log_writeOut ::log(tvAppend) 1 "Radio support will be included in version 0.8.3"}
	ttk::button $toolbTop.bTv -image $::icon_m(starttv) -style Toolbutton -command {event generate . <<teleview>>}
	
	ttk::treeview $stations.treeSlist -yscrollcommand [list $stations.scrbSlist set] -columns {name number} -show headings -selectmode browse -takefocus 0
	ttk::scrollbar $stations.scrbSlist -command [list $stations.treeSlist yview]
	
	ttk::button $toolbChanCtrl.bChanDown -image $::icon_m(channel-next) -style Toolbutton -command [list chan_zapperNext $stations.treeSlist]
	ttk::button $toolbChanCtrl.bChanUp -image $::icon_m(channel-prior) -style Toolbutton -command [list chan_zapperPrior $stations.treeSlist]
	ttk::button $toolbChanCtrl.bChanJump -image $::icon_m(channel-jump) -style Toolbutton -command [list chan_zapperJump $stations.treeSlist]
	
	ttk::button $toolbPlay.bPlay -image $::icon_m(playback-start) -style Toolbutton -state disabled -command {event generate . <<start>>}
	ttk::button $toolbPlay.bPause -image $::icon_m(playback-pause) -style Toolbutton -state disabled -command {event generate . <<pause>>}
	ttk::button $toolbPlay.bStop -image $::icon_m(playback-stop) -style Toolbutton -state disabled -command {event generate . <<stop>>}
	
	ttk::separator $toolbPlay.seperat1 -orient vertical
	
	ttk::button $toolbPlay.bRewStart -style Toolbutton -image $::icon_m(rewind-first) -state disabled -command {event generate . <<rewind_start>>}
	ttk::button $toolbPlay.bRewSmall -style Toolbutton -image $::icon_m(rewind-small) -state disabled -command {event generate . <<rewind_10s>>}
	ttk::menubutton $toolbPlay.mbRewChoose -style Toolbutton -image $::icon_e(arrow-d) -menu $toolbPlay.mbRewChoose.mRewChoose -state disabled
	ttk::button $toolbPlay.bForwSmall -style Toolbutton -image $::icon_m(forward-small) -state disabled -command {event generate . <<forward_10s>>}
	ttk::menubutton $toolbPlay.mbForwChoose -style Toolbutton -image $::icon_e(arrow-d) -menu $toolbPlay.mbForwChoose.mForwChoose -state disabled
	ttk::button $toolbPlay.bForwEnd -style Toolbutton -image $::icon_m(forward-last) -state disabled -command {event generate . <<forward_end>>}
	
	ttk::separator $toolbPlay.seperat2 -orient vertical
	
	ttk::button $toolbPlay.bSave -style Toolbutton -image $::icon_m(floppy) -state disabled -command [list timeshift_Save .]
	
	ttk::label $toolbPlay.lFillSpace
	
	ttk::button $toolbPlay.bVolMute -style Toolbutton -image $::icon_m(volume) -command {event generate . <<mute>>}
	ttk::scale $toolbPlay.scVolume -orient horizontal -from 0 -to 100 -variable main(volume_scale) -command [list vid_audioVolumeControl .ftoolb_Play.scVolume .ftoolb_Play.bVolMute]
	
	label $toolbDispIcTxt.lDispIcon -compound center -background black -foreground white -image $::icon_s(starttv)
	label $toolbDispIcTxt.lDispText -background black -foreground white -text [mc "Welcome to TV-Viewer %" [lindex $::option(release_version) 0]] -anchor center
	label $toolbDisp.lTime -background black -foreground white -anchor center -textvariable main(label_file_time)
	
	if {[clock format [clock seconds] -format {%d%m}] == 2412} {
		ttk::label $vidBg.l_bgImage -image $::icon_e(logo-tv-viewer08x-noload_xmas) -background #414141
	} else {
		ttk::label $vidBg.l_bgImage -image $::icon_e(logo-tv-viewer08x-noload) -background #414141
	}
	
	grid $menubar -in . -row 0 -column 0 -sticky new -columnspan 2
	grid .seperatMenu -in . -row 1 -column 0 -sticky ew -padx 2 -columnspan 2
	if {$::mem(toolbMain)} {
		grid $toolbTop -in . -row 2 -column 0 -columnspan 2 -sticky ew
	}
	if {$::mem(toolbStation)} {
		grid $stations -in . -row 3 -column 0 -sticky nesw -padx "0 2"
	}
	grid $vidBg -in . -row 3 -column 1 -sticky nesw
	if {$::mem(toolbControl)} {
		grid $toolbPlay -in . -row 4 -column 0 -columnspan 2 -sticky ew
	}
	grid $toolbDisp -in . -row 5 -column 0 -columnspan 2 -sticky ew -pady "2 0"
	
	grid $menubar.mbTvviewer -in $menubar -row 0 -column 0
	grid $menubar.mbNavigation -in $menubar -row 0 -column 1
	grid $menubar.mbView -in $menubar -row 0 -column 2
	grid $menubar.mbAudio -in $menubar -row 0 -column 3
	grid $menubar.mbHelp -in $menubar -row 0 -column 4
	
	grid $toolbTop.bTimeshift -in $toolbTop -row 0 -column 0 -pady 1 -padx "2 0"
	grid $toolbTop.bRecord -in $toolbTop -row 0 -column 1 -pady 1 -padx "2 0"
	grid $toolbTop.bEpg -in $toolbTop -row 0 -column 2 -pady 1 -padx "2 0"
	#FIXME Deactivated Radio Button
	#~ grid $toolbTop.bRadio -in $toolbTop -row 0 -column 3 -pady 1 -padx "2 0"
	grid $toolbTop.bTv -in $toolbTop -row 0 -column 3 -pady 1 -padx "2 0"
	
	grid $toolbChanCtrl -in $stations -row 1 -column 0 -columnspan 2 -sticky ew
	grid $stations.treeSlist -in $stations -row 0 -column 0 -sticky nesw
	grid $stations.scrbSlist -in $stations -row 0 -column 1 -sticky ns
	
	grid $toolbChanCtrl.bChanDown -in $toolbChanCtrl -row 0 -column 0 -pady 2 -padx "2 0"
	grid $toolbChanCtrl.bChanUp -in $toolbChanCtrl -row 0 -column 1 -pady 2 -padx "2 0"
	grid $toolbChanCtrl.bChanJump -in $toolbChanCtrl -row 0 -column 2 -pady 2 -padx "2 0"
	
	grid $toolbPlay.bPlay -in $toolbPlay -row 0 -column 0 -pady 2 -padx "2 0"
	grid $toolbPlay.bPause -in $toolbPlay -row 0 -column 1 -pady 2 -padx "2 0"
	grid $toolbPlay.bStop -in $toolbPlay -row 0 -column 2 -pady 2 -padx "2 0"
	
	grid $toolbPlay.seperat1 -in $toolbPlay -row 0 -column 3 -sticky ns -pady 6 -padx "2 0"
	
	grid $toolbPlay.bRewStart -in $toolbPlay -row 0 -column 4 -pady 2 -padx "2 0"
	grid $toolbPlay.mbRewChoose -in $toolbPlay -row 0 -column 5 -sticky ns -pady 2 -padx "2 0"
	grid $toolbPlay.bRewSmall -in $toolbPlay -row 0 -column 6 -pady 2
	grid $toolbPlay.bForwSmall -in $toolbPlay -row 0 -column 7 -pady 2 -padx "2 0"
	grid $toolbPlay.mbForwChoose -in $toolbPlay -row 0 -column 8 -sticky ns -pady 2
	grid $toolbPlay.bForwEnd -in $toolbPlay -row 0 -column 9 -pady 2 -padx "2 0"
	
	grid $toolbPlay.seperat2 -in $toolbPlay -row 0 -column 10 -sticky ns -pady 6 -padx "2 0"
	
	grid $toolbPlay.bSave -in $toolbPlay -row 0 -column 11 -pady 2 -padx "2 0"
	
	grid $toolbPlay.lFillSpace -in $toolbPlay -row 0 -column 12 -sticky e
	
	grid $toolbPlay.bVolMute -in $toolbPlay -row 0 -column 13 -pady 2 -padx "2 0"
	grid $toolbPlay.scVolume -in $toolbPlay -row 0 -column 14 -pady 2 -padx "2 6"
	
	grid $toolbDispIcTxt -in $toolbDisp -row 0 -column 0
	grid $toolbDispIcTxt.lDispIcon -in $toolbDispIcTxt -row 0 -column 0 -sticky nsw -padx 2
	if {$::mem(sbarStatus)} {
		grid $toolbDispIcTxt.lDispText -in $toolbDispIcTxt -row 0 -column 1 -sticky nsw -padx "0 2"
	}
	if {$::mem(sbarTime)} {
		grid $toolbDisp.lTime -in $toolbDisp -row 0 -column 1  -sticky nse -padx 2
	}
	
	
	grid rowconfigure . 3 -weight 1
	grid rowconfigure $stations 0 -weight 1
	grid columnconfigure . 0 -weight 1
	grid columnconfigure . 1 -weight 10000 -minsize 250
	grid columnconfigure $stations 0 -weight 1
	grid columnconfigure $toolbTop 5 -weight 1
	grid columnconfigure $toolbPlay 12 -weight 10000 -minsize 1
	grid columnconfigure $toolbDisp 0 -weight 1
	grid columnconfigure $toolbDisp 1 -weight 10000 -minsize 150
	
	place $vidBg.l_bgImage -relx 0.5 -rely 0.5 -anchor center
	
	set ::vid(stayontop) 0
	set ::option(cursor_old) [$vidCont cget -cursor]
	set ::main(compactMode) 0
	set ::data(panscan) 0
	set ::data(panscanAuto) 0
	set ::data(movevidX) 0
	set ::data(movevidY) 0
	if {$::option(volRem)} {
		set ::main(volume_scale) $::mem(volume)
	} else {
		set ::main(volume_scale) 100
	}
	set ::main(label_file_time) " --:-- / --:--"
	set ::chan(old_channel) 0
	set ::vid(recStart) 0
	set ::vid(pbStatus) 0
	
	#FIXME Simplify and wrap the following code. Additionally swap out something to different procs
	
	main_menuCreate $menubar $toolbChanCtrl $toolbPlay $vidBg standard
	
	main_frontendChannelHandler main
	
	if {$::main(running_recording) == 0} {
		
		stream_videoStandard 1
		
		if {$::option(streambitrate) == 1} {
			stream_vbitrate
		}
		
		if {$::option(temporal_filter) == 1} {
			stream_temporal
		}
		
		stream_colormControls
		
		catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=mute=0}
		
		if {$::option(audio_v4l2) == 1} {
			stream_audioV4l2
		}
	}
	
	tooltips $toolbTop $toolbChanCtrl $toolbPlay main
	
	if {$::option(newsreader) == 1} {
		after 3000 {main_newsreaderAutomaticUpdate}
	}
	
	wm title . "TV-Viewer"
	wm protocol . WM_DELETE_WINDOW [list event generate . <<exit>>]
	wm iconphoto . $::icon_e(tv-viewer_icon)
	
	bind . <Key-x> {command_WritePipe 1 "tv-viewer_notifyd notifydId"; command_WritePipe 1 [list tv-viewer_notifyd notifydUi 1 $::option(notifyPos) $::option(notifyTime) 3 "Start Newsreader" "News" "There are News about TV-Viewer"]}
	bind . <Key-y> {status_feedbWarn 1 0 "Test Message 1 can be very long, so we need to check what happens with the stats_feedbWarn"}
	
	
	command_socket
	
	if {$::option(notify)} {
		set status_notify [monitor_partRunning 5]
		if {[lindex $status_notify 0] == 0} {
			if {$::option(tclkit) == 1} {
				set ntfy_pid [exec $::option(tclkit_path) $::option(root)/data/notifyd.tcl &]
			} else {
				set ntfy_pid [exec $::option(root)/data/notifyd.tcl &]
			}
			log_writeOut ::log(tvAppend) 0 "notification daemon started, PID $ntfy_pid"
		}
	}
	
	array set startAvailCommand {
		0 2500
		1 1500
		2 {wm deiconify .}
		3 {launch_splashPlay cancel 0 0 0}
		4 {destroy .splash}
		5 {record_linkerPrestart record}
		6 {record_linkerRec record}
		7 {event generate . <<teleview>>}
	}
	#FIXME The following if else conditions are strongly nested. Find a way to improve this!
	if {$::option(show_splash) == 1} {
		if {$::option(starttv_startup) == 1} {
			if {[string trim [auto_execok mplayer]] != {}} {
				if {$::main(running_recording) == 1} {
					set startCommand [list 2500 "$startAvailCommand(2)" "$startAvailCommand(3)" "$startAvailCommand(4)" "$startAvailCommand(5)" "$startAvailCommand(6)"]
				} else {
					set startCommand [list 2500 "$startAvailCommand(2)" "$startAvailCommand(3)" "$startAvailCommand(4)" "$startAvailCommand(7)"]
				}
			} else {
				set startCommand [list 2500 "$startAvailCommand(2)" "$startAvailCommand(3)" "$startAvailCommand(4)"]
			}
		} else {
			if {[string trim [auto_execok mplayer]] != {}} {
				if {$::main(running_recording) == 1} {
					set startCommand [list 2500 "$startAvailCommand(2)" "$startAvailCommand(3)" "$startAvailCommand(4)" "$startAvailCommand(5)" "$startAvailCommand(6)"]
				} else {
					set startCommand [list 2500 "$startAvailCommand(2)" "$startAvailCommand(3)" "$startAvailCommand(4)"]
				}
			} else {
				set startCommand [list 2500 "$startAvailCommand(2)" "$startAvailCommand(3)" "$startAvailCommand(4)"]
			}
		}
	} else {
		if {$::option(starttv_startup) == 1} {
			if {[string trim [auto_execok mplayer]] != {}} {
				if {$::main(running_recording) == 1} {
					set startCommand [list 1500 "$startAvailCommand(2)" "$startAvailCommand(5)" "$startAvailCommand(6)"]
				} else {
					set startCommand [list 1500 "$startAvailCommand(2)" "$startAvailCommand(7)"]
				}
			} else {
				set startCommand [list 1500 "$startAvailCommand(2)"]
			}
		} else {
			if {[string trim [auto_execok mplayer]] == {}} {
				set startCommand [list 1500 "$startAvailCommand(2)"]
			} else {
				if {$::main(running_recording) == 1} {
					set startCommand [list 1500 "$startAvailCommand(2)" "$startAvailCommand(5)" "$startAvailCommand(6)"]
				} else {
					set startCommand [list 1500 "$startAvailCommand(2)"]
				}
			}
		}
	}
	if {[string trim [auto_execok mplayer]] == {}} {
		log_writeOut ::log(tvAppend) 2 "Could not detect MPlayer, have a look at the system requirements"
		if {$::option(log_warnDialogue)} {
			status_feedbWarn 1 0 [mc "Could not detect MPlayer"]
		}
		vid_pmhandlerButton {{1 disabled} {2 disabled} {4 disabled} {5 disabled}} {100 0} {100 0}
		vid_pmhandlerMenuTv {{2 disabled} {4 disabled} {5 disabled} {7 disabled} {8 disabled}} {{6 disabled} {8 disabled} {9 disabled} {11 disabled} {12 disabled}}
		vid_pmhandlerMenuTray {{4 disabled} {5 disabled} {6 disabled} {8 disabled} {9 disabled}}
		event_delete nomplay
	}
	after [lindex $startCommand 0] [list main_frontendStartCommand $startCommand]
	vid_wmCursor 1
	
	if {$::main(upgrade)} {
		log_writeOut ::log(tvAppend) 1 "Congratulations! You have installed a new version of TV-Viewer"
		if {$::option(log_warnDialogue)} {
			after 5000 {status_feedbWarn 1 1 [mc "Congratulations! You have installed a new version of TV-Viewer:
% (Bazaar r%), running on Tcl/tk %
Build date: %" [lindex $::option(release_version) 0] [lindex $::option(release_version) 1] [info patchlevel] [lindex $::option(release_version) 2]]}
		}
	}
	unset -nocomplain ::main(upgrade)
	
	if {$::mem(systray) == 1} {
		system_trayActivate 1
	}
	if {$::option(window_remGeom)} {
		if {$::mem(compact) == 0} {
			wm geometry . $::mem(mainwidth)\x$::mem(mainheight)\+[subst $::mem(mainX)]\+[subst $::mem(mainY)]
		}
	}
	
	#Do everything that needs to be done after root window is visible
	tkwait visibility .
	log_writeOut ::log(tvAppend) 0 "Main is visible, processing things that need to be done now."
	autoscroll $stations.scrbSlist
	if {$::menu(cbViewMainToolbar)} {
		set mainHeight [winfo height .ftoolb_Top]
	} else {
		set mainHeight 0
	}
	if {$::menu(cbViewControlbar)} {
		set controlbHeight [winfo height .ftoolb_Play]
	} else {
		set controlbHeight 0
	}
	set height [expr [winfo height .foptions_bar] + [winfo height .seperatMenu] + $mainHeight + $controlbHeight + [winfo height .ftoolb_Disp] + 141]
	wm minsize . 250 $height
	if {$::mem(compact)} {
		event generate . <<wmCompact>>
		if {$::option(window_remGeom)} {
			wm geometry . $::mem(mainwidth)\x$::mem(mainheight)\+[subst $::mem(mainX)]\+[subst $::mem(mainY)]
		}
	}
	set ::vid(stayontop) $::mem(ontop)
	vid_wmStayonTop $::vid(stayontop)
	if {$::option(window_full)} {
		after 500 {event generate . <<wmFull>>}
	}
}

proc main_frontendStartCommand {startCommand} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendStartCommand \033\[0m \{$startCommand\}"
	for {set i 1} {$i <= [llength $startCommand]} {incr i} {
		{*}[lindex $startCommand $i]
	}
}

proc main_frontendInfoVars {} {
	#Debug proc to analyse all existing arrays and variables
	set varfile [open "$::env(HOME)/varfile" w+]
	foreach var [info globals] {
		if {[array exists ::$var]} {
			puts $varfile "FOUND ARRAY $var:"
			flush $varfile
			foreach {key elem} [array get ::$var] {
				puts $varfile "key: $key
element: $elem
"
				flush $varfile
			}
		} else {
			puts $varfile "
$var: [set ::$var]"
			flush $varfile
		}
	}
	close $varfile
}

proc main_frontendcheckMapped {} {
	#Debug proc to test if widget ismapped
	puts "
	
"
	foreach w [winfo children .] {
		puts "w $w"
		if {[winfo ismapped $w]} {
			puts "$w ismapped"
		}
		if {[winfo viewable $w]} {
			puts "$w viewable"
		}
	}
}
