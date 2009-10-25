#       main_frontend.tcl
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

proc main_frontendExitViewer {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendExitViewer \033\[0m"
	set status_timeslinkread [catch {file readlink "$::where_is_home/tmp/timeshift_lockfile.tmp"} resultat_timeslinkread]
	if { $status_timeslinkread == 0 } {
		catch {exec ps -eo "%p"} read_ps
		set status_greppid_times [catch {agrep -w "$read_ps" $resultat_timeslinkread} resultat_greppid_times]
		if { $status_greppid_times == 0 } {
			log_writeOutTv 0 "Timeshift (PID: $resultat_timeslinkread) is running, will stop it."
			catch {exec kill $resultat_timeslinkread}
			catch {file delete "$::where_is_home/tmp/timeshift_lockfile.tmp"}
			if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"]} {
				catch {file delete -force "[subst $::option(timeshift_path)/timeshift.mpeg]"}
			}
		}
	}
	catch {file delete "$::where_is_home/tmp/lockfile.tmp"}
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
			log_writeOutTv 1 "There are no stations to insert into station list."
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
			set status_timeslinkread [catch {file readlink "$::where_is_home/tmp/timeshift_lockfile.tmp"} resultat_timeslinkread]
			set status_recordlinkread [catch {file readlink "$::where_is_home/tmp/record_lockfile.tmp"} resultat_recordlinkread]
			if { $status_recordlinkread == 0 || $status_timeslinkread == 0 } {
				catch {exec ps -eo "%p"} read_ps
				set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
				set status_greppid_times [catch {agrep -w "$read_ps" $resultat_timeslinkread} resultat_greppid_times]
				if { $status_greppid_record == 0 || $status_greppid_times == 0 } {
					if {$::option(rec_allow_sta_change) == 0} {
						log_writeOutTv 0 "Disabling station list due to an active recording."
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
			if {$::option(systray_mini) == 1} {
				bind . <Unmap> {
					if {[winfo ismapped .] == 0} {
						if {[winfo exists .tray] == 0} {
							main_systemTrayActivate
							set ::choice(cb_systray_main) 1
						}
						main_systemTrayMini unmap
					}
				}
			}
		}
	}
}

proc msgcat::mcunknown {locale src args} {
	log_writeOutTv 1 "Unknown string for locale $locale"
	log_writeOutTv 1 "$src $args"
	return $src
}

proc main_frontendLaunchDiagnostic {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendLaunchDiagnostic \033\[0m"
	if {[winfo exists .config_wizard.top_diagnostic] == 0} {
		
		set wtop [toplevel .top_diagnostic]
		
		place [ttk::frame $wtop.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		
		set mf [ttk::frame $wtop.f_main]
		
		set fbottom [ttk::frame $wtop.f_bottom -style TLabelframe]
		
		ttk::label $mf.l_diagnostic_msg \
		-text [mc "Diagnostic Routine is checking your system.
Please wait..."] \
		-compound left \
		-image $::icon_m(dialog-information)
		
		ttk::progressbar $mf.pgb_diagnostic \
		-orient horizontal \
		-mode indeterminate \
		-variable choice(pgb_diagnostic)
		
		ttk::button $fbottom.b_close \
		-command {main_frontendDiagnosticExit} \
		-text [mc "Exit"] \
		-compound left \
		-image $::icon_s(dialog-close)
		
		text $mf.t_diagtext \
		-width 0 \
		-height 0 \
		-bd 0 \
		-relief flat \
		-highlightthickness 0
		
		grid columnconfigure $mf 0 -weight 1 -minsize 350
		
		grid $mf -in $wtop -row 0 -column 0 \
		-sticky nesw
		
		grid $mf.l_diagnostic_msg -in $mf -row 0 -column 0 \
		-padx 5 \
		-pady 5 \
		-sticky w
		grid $mf.pgb_diagnostic -in $mf -row 1 -column 0 \
		-sticky ew \
		-padx 10 \
		-pady 10
		
		wm resizable $wtop 0 0
		wm title $wtop [mc "Diagnostic Routine"]
		wm protocol $wtop WM_DELETE_WINDOW " "
		wm iconphoto $wtop $::icon_e(tv-viewer_icon)
		wm transient $wtop .
		if {$::option(systray_mini) == 1} {
			bind . <Unmap> {}
		}
		tkwait visibility $wtop
		grab $wtop
		
		$mf.pgb_diagnostic start 10
		
		tv_playbackStop 0 pic
		
		catch {exec "$::where_is/data/tv-viewer_diag.tcl" &}
	}
}

proc main_frontendDiagnosticFinished {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendDiagnosticFinished \033\[0m"
	if {[winfo exists .top_diagnostic]} {
		
		grid rowconfigure .top_diagnostic.f_main {2} -weight 1 -minsize 150
		
		grid .top_diagnostic.f_main.t_diagtext -in .top_diagnostic.f_main -row 2 -column 0 \
		-sticky nesw \
		-padx 5 \
		-pady "0 5"
		
		grid .top_diagnostic.f_bottom -in .top_diagnostic -row 1 -column 0 \
		-sticky ew \
		-padx 3 \
		-pady 3
		grid anchor .top_diagnostic.f_bottom e
		
		grid .top_diagnostic.f_bottom.b_close -in .top_diagnostic.f_bottom -row 0 -column 0 \
		-padx 3 \
		-pady 7
		
		set hylink_enter "-foreground #0023FF -underline off"
		set hylink_leave "-foreground #0064FF -underline on"
		.top_diagnostic.f_main.t_diagtext tag configure hyper -underline on -foreground #0064FF
		.top_diagnostic.f_main.t_diagtext tag configure hyper_file -underline on -foreground #0064FF
		.top_diagnostic.f_main.t_diagtext tag bind hyper <Any-Enter> ".top_diagnostic.f_main.t_diagtext tag configure hyper $hylink_enter; .top_diagnostic.f_main.t_diagtext configure -cursor hand1"
		.top_diagnostic.f_main.t_diagtext tag bind hyper_file <Any-Enter> ".top_diagnostic.f_main.t_diagtext tag configure hyper_file $hylink_enter; .top_diagnostic.f_main.t_diagtext configure -cursor hand1"
		.top_diagnostic.f_main.t_diagtext tag bind hyper <Any-Leave> ".top_diagnostic.f_main.t_diagtext tag configure hyper $hylink_leave; .top_diagnostic.f_main.t_diagtext configure -cursor arrow"
		.top_diagnostic.f_main.t_diagtext tag bind hyper_file <Any-Leave> ".top_diagnostic.f_main.t_diagtext tag configure hyper_file $hylink_leave; .top_diagnostic.f_main.t_diagtext configure -cursor arrow"
		.top_diagnostic.f_main.t_diagtext tag bind hyper <Button-1> {catch {exec sh -c "xdg-open https://sourceforge.net/tracker2/?group_id=238442" &}}
		.top_diagnostic.f_main.t_diagtext tag bind hyper_file <Button-1> {catch {exec sh -c "xdg-open $::env(HOME)/tv-viewer_diag.out" &}}
		
		.top_diagnostic.f_main.pgb_diagnostic stop
		.top_diagnostic.f_main.pgb_diagnostic configure -mode determinate
		.top_diagnostic.f_main.pgb_diagnostic configure -value 100
		.top_diagnostic.f_main.l_diagnostic_msg configure -text [mc "Diagnostic Routine finished"]
		
		.top_diagnostic.f_main.t_diagtext insert end [mc "Generated file:"]
		.top_diagnostic.f_main.t_diagtext insert end "\n
$::env(HOME)/tv-viewer_diag.out" hyper_file
		.top_diagnostic.f_main.t_diagtext insert end "\n\n"
		.top_diagnostic.f_main.t_diagtext insert end [mc "Create a bug report on "]
		.top_diagnostic.f_main.t_diagtext insert end "sourceforge.net" hyper
		.top_diagnostic.f_main.t_diagtext insert end "\n"
		.top_diagnostic.f_main.t_diagtext insert end [mc "and attach the generated file."]
		.top_diagnostic.f_main.t_diagtext configure -state disabled
		
		wm protocol .top_diagnostic WM_DELETE_WINDOW "main_frontendDiagnosticExit"
	}
}

proc main_frontendDiagnosticExit {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_frontendDiagnosticExit \033\[0m"
	grab release .top_diagnostic
	if {$::option(systray_mini) == 1} {
		bind . <Unmap> {
			if {[winfo ismapped .] == 0} {
				if {[winfo exists .tray] == 0} {
					main_systemTrayActivate
					set ::choice(cb_systray_main) 1
				}
				main_systemTrayMini unmap
			}
		}
	}
	destroy .top_diagnostic
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
	-variable volume_scale \
	-command [list tv_playerVolumeControl $wfbottom] \
	-from 0 \
	-to 100
	set ::volume_scale 100
	
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
	-command {tv_playbackStop 0 pic ; config_wizardMainUi}
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
	-command main_newsreaderCheckUpdate
	$wfbar.mOptions add checkbutton \
	-label [mc "System Tray"] \
	-command main_systemTrayActivate \
	-variable choice(cb_systray_main)
	$wfbar.mOptions add separator
	$wfbar.mOptions add command \
	-label [mc "Exit"] \
	-compound left \
	-image $::icon_s(dialog-close) \
	-command main_frontendExitViewer \
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
	-command main_frontendLaunchDiagnostic
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
		bind . <Key-m> [list tv_playerVolumeControl $wfbottom mute]
		bind . <Key-F1> [list info_helpHelp]
		bind . <Alt-Key-o> [list event generate $wfbar.mb_options <<Invoke>>]
		bind . <Alt-Key-h> [list event generate $wfbar.mb_help <<Invoke>>]
		bind . <Control-Key-p> {tv_playbackStop 0 pic ; config_wizardMainUi}
		bind . <Control-Key-m> {colorm_mainUi}
		bind . <Control-Key-e> {station_editUi}
		bind . <Control-Key-x> {main_frontendExitViewer}
		event add <<input_up>> <Control-Key-i>
		event add <<input_down>> <Control-Alt-Key-i>
		bind . <<input_up>> [list main_stationInput 1 1]
		bind . <<input_down>> [list main_stationInput 1 -1]
		event add <<volume_incr>> <Key-plus> <Key-KP_Add>
		event add <<volume_decr>> <Key-minus> <Key-KP_Subtract>
		bind . <<volume_decr>> {tv_playerVolumeControl .bottom_buttons [expr $::volume_scale - 3]}
		bind . <<volume_incr>> {tv_playerVolumeControl .bottom_buttons [expr $::volume_scale + 3]}
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
	} else {
		.label_stations configure -text [lindex $::station(last) 0]
		bind . <Key-m> [list tv_playerVolumeControl $wfbottom mute]
		bind . <Key-F1> [list info_helpHelp]
		bind . <Alt-Key-o> [list event generate $wfbar.mb_options <<Invoke>>]
		bind . <Alt-Key-h> [list event generate $wfbar.mb_help <<Invoke>>]
		bind . <Control-Key-p> {tv_playbackStop 0 pic ; config_wizardMainUi}
		bind . <Control-Key-m> {colorm_mainUi}
		bind . <Control-Key-e> {station_editUi}
		bind . <Control-Key-x> {main_frontendExitViewer}
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
		bind . <<station_up>> [list main_stationChannelUp .label_stations]
		bind . <<station_down>> [list main_stationChannelDown .label_stations]
		bind . <<station_jump>> [list main_stationChannelJumper .label_stations]
		bind . <<station_key>> [list main_stationStationNrKeys %A]
		bind . <<station_key_lirc>> [list main_stationStationNrKeys %d]
		event add <<volume_incr>> <Key-plus> <Key-KP_Add>
		event add <<volume_decr>> <Key-minus> <Key-KP_Subtract>
		bind . <<volume_decr>> {tv_playerVolumeControl .bottom_buttons [expr $::volume_scale - 3]}
		bind . <<volume_incr>> {tv_playerVolumeControl .bottom_buttons [expr $::volume_scale + 3]}
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
	wm title . [mc "TV-Viewer %" $::option(release_version)]
	wm protocol . WM_DELETE_WINDOW main_frontendExitViewer
	wm iconphoto . $::icon_e(tv-viewer_icon)
	
	command_socket
	
	if {$::option(show_splash) == 1} {
		if {$::option(starttv_startup) == 1} {
			if {[string trim [auto_execok mplayer]] != {}} {
				if {$::main(running_recording) == 1} {
					after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash ; tv_playerUi ; record_schedulerPrestart record ; record_schedulerRec record}
				} else {
					after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash ; tv_playerUi ; event generate . <<teleview>>}
				}
			} else {
				log_writeOutTv 1 "Can't start tv playback, MPlayer is not installed on this system."
				after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ;  destroy .splash ; tv_playerUi}
				$wftop.button_starttv state disabled
				$wftop.button_record state disabled
				$wftop.button_timeshift state disabled
				$wfbar.mOptions entryconfigure 4 -state disabled
				event delete <<record>>
				event delete <<teleview>>
				bind . <<record>> {}
				bind . <<teleview>> {}
			}
		} else {
			if {[string trim [auto_execok mplayer]] != {}} {
				if {$::main(running_recording) == 1} {
					after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash ; tv_playerUi ; record_schedulerPrestart record ; record_schedulerRec record}
				} else {
					after 2500 {wm deiconify . ; launch_splashPlay cancel 0 0 0 ; destroy .splash ; tv_playerUi}
				}
			} else {
				$wftop.button_starttv state disabled
				$wftop.button_record state disabled
				$wftop.button_timeshift state disabled
				$wfbar.mOptions entryconfigure 4 -state disabled
				log_writeOutTv 1 "Deactivating Button \"Start TV\" because MPlayer is not installed."
				event delete <<record>>
				event delete <<teleview>>
				bind . <<record>> {}
				bind . <<teleview>> {}
			}
		}
	} else {
		if {$::option(starttv_startup) == 1} {
			if {[string trim [auto_execok mplayer]] != {}} {
				if {$::main(running_recording) == 1} {
					after 1500 {wm deiconify . ; tv_playerUi ; record_schedulerPrestart record ; record_schedulerRec record}
				} else {
					after 1500 {wm deiconify . ; tv_playerUi ; event generate . <<teleview>>}
				}
			} else {
				log_writeOutTv 1 "Can't start tv playback, MPlayer is not installed on this system."
				after 1500 {wm deiconify . ; tv_playerUi}
				$wftop.button_starttv state disabled
				$wftop.button_record state disabled
				$wftop.button_timeshift state disabled
				$wfbar.mOptions entryconfigure 4 -state disabled
				event delete <<record>>
				event delete <<teleview>>
				bind . <<record>> {}
				bind . <<teleview>> {}
			}
		} else {
			if {[string trim [auto_execok mplayer]] == {}} {
				$wftop.button_starttv state disabled
				$wftop.button_record state disabled
				$wftop.button_timeshift state disabled
				$wfbar.mOptions entryconfigure 4 -state disabled
				log_writeOutTv 1 "Deactivating Button \"Start TV\" because MPlayer is not installed."
				event delete <<record>>
				event delete <<teleview>>
				bind . <<record>> {}
				bind . <<teleview>> {}
				after 1500 {wm deiconify . ; tv_playerUi}
			} else {
				if {$::main(running_recording) == 1} {
					after 1500 {wm deiconify . ; tv_playerUi ; record_schedulerPrestart record ; record_schedulerRec record}
				} else {
					after 1500 {wm deiconify . ; tv_playerUi}
				}
			}
		}
	}
	if {$::option(systray_start) == 1} {
		set ::choice(cb_systray_main) 1
		main_systemTrayActivate
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
	if {$::option(systray_mini) == 1} {
		bind . <Unmap> {
			if {[winfo ismapped .] == 0} {
				if {[winfo exists .tray] == 0} {
					main_systemTrayActivate
					set ::choice(cb_systray_main) 1
				}
				main_systemTrayMini unmap
			}
		}
	} else {
		bind . <Unmap> {}
		bind . <Map> {}
	}
}
