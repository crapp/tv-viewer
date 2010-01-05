#       main_frontend.tcl
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

proc main_frontendExitViewer {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendExitViewer \033\[0m"
	set status_timeslinkread [catch {file readlink "$::option(home)/tmp/timeshift_lockfile.tmp"} resultat_timeslinkread]
	if { $status_timeslinkread == 0 } {
		catch {exec ps -eo "%p"} read_ps
		set status_greppid_times [catch {agrep -w "$read_ps" $resultat_timeslinkread} resultat_greppid_times]
		if { $status_greppid_times == 0 } {
			log_writeOutTv 0 "Timeshift (PID: $resultat_timeslinkread) is running, will stop it."
			catch {exec kill $resultat_timeslinkread}
			catch {file delete "$::option(home)/tmp/timeshift_lockfile.tmp"}
		}
	}
	if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"]} {
		catch {file delete -force "[subst $::option(timeshift_path)/timeshift.mpeg]"}
	}
	catch {file delete "$::option(home)/tmp/lockfile.tmp"}
	destroy .top_newsreader
	destroy .top_about
	if {[winfo exists .tv]} {
		if {[winfo exists .tv.file_play_bar]} {
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
	set status_schedlinkread [catch {file readlink "$::option(home)/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
	if { $status_schedlinkread == 0 } {
		catch {exec ps -eo "%p"} read_ps
		set status_greppid_sched [catch {agrep -w "$read_ps" $resultat_schedlinkread} resultat_greppid_sched]
		if { $status_greppid_sched != 0 } {
			catch {file delete -force "$::option(home)/tmp/ComSocketMain"}
			catch {file delete -force "$::option(home)/tmp/ComSocketSched"}
		}
	} else {
		catch {file delete -force "$::option(home)/tmp/ComSocketMain"}
		catch {file delete -force "$::option(home)/tmp/ComSocketSched"}
	}
	destroy .tv
	exit 0
}

proc main_frontendEpg {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendEpg \033\[0m"
	log_writeOutTv 0 "Launching EPG program..."
	catch {exec sh -c "[subst $::option(epg_command)] >/dev/null 2>&1" &}
}

proc main_frontendShowslist {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendShowslist \033\[0m \{$w\}"
	if {[winfo exists .frame_slistbox] == 0} {
		
		log_writeOutTv 0 "Building station list..."
		
		$w.button_showslist state pressed
		
		set wflbox [ttk::frame .frame_slistbox]
		
		listbox $wflbox.listbox_slist \
		-yscrollcommand [list $wflbox.scrollbar_slist set] \
		-exportselection false \
		-takefocus 0
		
		ttk::scrollbar $wflbox.scrollbar_slist \
		-orient vertical \
		-command [list $wflbox.listbox_slist yview]
		
		grid $wflbox -in . -row 4 -column 0 \
		-columnspan 3 \
		-sticky news
		grid $wflbox.listbox_slist -in $wflbox -row 0 -column 0 \
		-sticky nesw \
		-pady "2 0"
		grid $wflbox.scrollbar_slist -in $wflbox -row 0 -column 1 \
		-sticky nws  \
		-pady "2 0"
		
		grid rowconfigure $wflbox 0 -weight 1
		grid columnconfigure $wflbox 0  -weight 1
		
		autoscroll $wflbox.scrollbar_slist
		
		wm resizable . 1 1
		
		if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
			log_writeOutTv 2 "There are no stations to insert into station list."
			$wflbox.listbox_slist configure -state disabled
		} else {
			for {set i 1} {$i <= $::station(max)} {incr i} {
				if {$i < 10} {
					$wflbox.listbox_slist insert end " $i     $::kanalid($i)"
				} else {
					if {$i < 100} {
						$wflbox.listbox_slist insert end " $i   $::kanalid($i)"
					} else {
						$wflbox.listbox_slist insert end " $i $::kanalid($i)"
					}
				}
			}
			bindtags $wflbox.listbox_slist {. .frame_slistbox.listbox_slist Listbox all}
			bind $wflbox.listbox_slist <<ListboxSelect>> [list main_stationListboxStations $wflbox.listbox_slist]
			bind $wflbox.listbox_slist <Key-Prior> {break}
			bind $wflbox.listbox_slist <Key-Next> {break}
			$wflbox.listbox_slist selection set [expr [lindex $::station(last) 2] - 1]
			bind . <Configure> {
				if {[winfo ismapped .frame_slistbox]} {
					if {[winfo height .frame_slistbox] < 36} {
						bind . <Configure> {}
						main_frontendShowslist .bottom_buttons
						.bottom_buttons.button_showslist state !pressed
					}
				}
			}
			$wflbox.listbox_slist see [$wflbox.listbox_slist curselection]
			set status_timeslinkread [catch {file readlink "$::option(home)/tmp/timeshift_lockfile.tmp"} resultat_timeslinkread]
			set status_recordlinkread [catch {file readlink "$::option(home)/tmp/record_lockfile.tmp"} resultat_recordlinkread]
			if { $status_recordlinkread == 0 || $status_timeslinkread == 0 } {
				catch {exec ps -eo "%p"} read_ps
				set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
				set status_greppid_times [catch {agrep -w "$read_ps" $resultat_timeslinkread} resultat_greppid_times]
				if { $status_greppid_record == 0 || $status_greppid_times == 0 } {
					if {$::option(rec_allow_sta_change) == 0} {
						log_writeOutTv 1 "Disabling station list due to an active recording."
						$wflbox.listbox_slist configure -state disabled
					}
				}
			}
		}
	} else {
		log_writeOutTv 0 "Station list already exists, using grid to manage window again."
		set wflbox .frame_slistbox
		if {[string trim [grid info $wflbox]] == {}} {
			grid $wflbox -in . -row 4 -column 0
			$w.button_showslist state pressed
			$wflbox.listbox_slist selection set [expr [lindex $::station(last) 2] - 1]
			$wflbox.listbox_slist see [expr [lindex $::station(last) 2] - 1]
			if {[info exists ::main(slist_height)]} {
				set newheight [expr [winfo height .] + $::main(slist_height)]
				wm geometry . [winfo width .]x$newheight
				wm resizable . 1 1
			}
			bind . <Configure> {
				if {[winfo ismapped .frame_slistbox]} {
					if {[winfo height .frame_slistbox] < 36} {
						bind . <Configure> {}
						main_frontendShowslist .bottom_buttons
						.bottom_buttons.button_showslist state !pressed
					}
				}
			}
		} else {
			log_writeOutTv 0 "Removing station list from grid manager."
			set ::main(slist_height) [winfo height $wflbox]
			if {$::main(slist_height) < 36} {
				set ::main(slist_height) 37
			}
			set newheight [expr [winfo height .] - $::main(slist_height)]
			grid remove $wflbox
			wm geometry . [lindex [wm minsize .] 0]x$newheight
			wm resizable . 0 0
			if {$::option(systray_close) == 1} {
				wm protocol . WM_DELETE_WINDOW {main_systemTrayTogglePre}
			}
		}
	}
}

proc msgcat::mcunknown {locale src args} {
	log_writeOutTv 1 "-=Unknown string for locale $locale"
	log_writeOutTv 1 "$src $args"
	return $src
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
	-command [list tv_playerVolumeControl $wfbottom] \
	-from 0 \
	-to 100
	set ::main(volume_scale) 100
	
	ttk::button $wfbottom.button_mute \
	-image $::icon_m(volume) \
	-style Toolbutton \
	-takefocus 0 \
	-command [list tv_playerVolumeControl $wfbottom mute]
	
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
	-sticky ns
	
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
	-command log_viewerMplayer \
	-label [mc "MPlayer Log"] \
	-variable choice(cb_log_mpl_main)
	$wfbar.mHelp add checkbutton \
	-command log_viewerScheduler \
	-label [mc "Scheduler Log"] \
	-variable choice(cb_log_sched_main)
	$wfbar.mHelp add checkbutton \
	-command log_viewerTvViewer \
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
		event_constrNoArray
	} else {
		.label_stations configure -text [lindex $::station(last) 0]
		event_constrArray
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
