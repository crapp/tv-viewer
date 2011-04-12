#       system_tray.tcl
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

proc system_trayActivate {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: system_trayActivate \033\[0m"
	set status_present [catch {package present tktray 1.3.9} result_present]
	if {$status_present == 0} {
		log_writeOutTv 0 "Package tktray already loaded"
	} else {
		log_writeOutTv 0 "Loading shared library tktray"
		set status_tray [catch {package require tktray 1.3.9} result_tktray]
		if {$status_tray == 1} {
			log_writeOutTv 2 "Can not load shared library tktray"
			log_writeOutTv 2 "$result_tktray"
			status_feedbWarn 1 [mc "Can not load shared library tktray"]
		}
	}
	if {[winfo exists .tray] == 0} {
		catch {tktray::icon .tray -image $::icon_men(placeholder) -visible 0}
		if {[winfo exists .tray]} {
			if {$handler == 1} {
				if {$::option(show_splash) == 1} {
					set after_tray 2500
				} else {
					set after_tray 1500
				}
			} else {
				set after_tray 1000
			}
			
			after $after_tray {
				if {[winfo exists .tray]} {
					.tray configure -image $::icon_e(systray_icon$::option(systrayIcSize)) -visible 1
					if {$::menu(cbSystray) == 0} {
						set ::menu(cbSystray) 1
					}
					bind .tray <Button-1> {system_trayToggle 0}
					bind .tray <ButtonRelease-3> {system_trayMenu %X %Y}
					if {$::option(systrayMini)} {
						bind .fvidBg <Map> {
							bind .fvidBg <Map> {}
							bind .fvidBg <Unmap> {}
							after idle [list after 0 system_trayToggle 1]
						}
						bind .fvidBg <Unmap> {
							bind .fvidBg <Map> {}
							bind .fvidBg <Unmap> {}
							after idle [list after 0 system_trayToggle 1]
						}
					}
					if {$::option(systrayClose)} {
						wm protocol . WM_DELETE_WINDOW {bind .fvidBg <Map> {}; bind .fvidBg <Unmap> {}; after idle [list after 0 system_trayToggle 0]}
					}
					system_trayCheckEnvironment
					set ::system(iconSize) $::option(systrayIcSize)
					if {$::option(systrayResize)} {
						system_trayResizer cancel
						after 2000 {system_trayResizer 2000}
					}
					set ::mem(systray) $::menu(cbSystray)
					log_writeOutTv 0 "Succesfully added Icon to system tray."
				}
			}
		} else {
			if {$::option(log_warnDialogue)} {
				status_feedbWarn 1 [mc "Can not create system tray icon"]
			}
			log_writeOutTv 2 "Can not create an icon in the system tray"
			log_writeOutTv 2 "Start TV-Viewer from a terminal to see why tktray is not loading, you may want to report this incident."
		}
	} else {
		system_trayResizer cancel
		bind .tray <Button-1> {}
		bind .tray <ButtonRelease-3>  {}
		bind .fvidBg <Map> {}
		bind .fvidBg <Unmap> {}
		destroy .tray
		if {$::menu(cbSystray)} {
			set ::menu(cbSystray) 0
		}
		set ::mem(systray) $::menu(cbSystray)
		log_writeOutTv 0 "Removing Icon from system tray."
		wm protocol . WM_DELETE_WINDOW [list event generate . <<exit>>]
	}
}

proc system_trayCheckEnvironment {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: system_trayCheckEnvironment \033\[0m"
	# proc checks in what state TV-Viewer is. Uses appropriate icon and tooltip for tray icon
	set switchIcTooltip a ;#TV-Viewer is idle
	set status_rec [monitor_partRunning 3]
	if {[lindex $status_rec 0] == 1} {
		set switchIcTooltip b
	}
	set status_time [monitor_partRunning 4]
	if {[lindex $status_time 0] == 1} {
		set switchIcTooltip c
	}
	if {"$switchIcTooltip" == "a" } {
		set status_tv [vid_callbackMplayerRemote alive]
		if {$status_tv != 1} {
			#MPlayer is running
			if {$::vid(pbMode) != 1} {
				#TV playback
				set switchIcTooltip e
			} else {
				#File Playback
				set switchIcTooltip d
			}
		}
	}
	
	switch $switchIcTooltip {
		a {
			# TV-Viewer is idle
			system_trayChangeIc 0
			settooltip .tray [mc "TV-Viewer idle"]
		}
		b {
			# Recording
			system_trayChangeIc 1
			if {[file exists "$::option(home)/config/current_rec.conf"]} {
				set open_f [open "$::option(home)/config/current_rec.conf" r]
				while {[gets $open_f line]!=-1} {
					if {[string trim $line] == {}} continue
					lassign $line station sdate stime edate etime duration ::vid(current_rec_file)
				}
				settooltip .tray [mc "Recording \"%\"

Started: % %
Ends:    % %" $station $sdate $stime $edate $etime]
			} else {
				log_writeOutTv 2 "Fatal, could not detect current_rec.conf, you may want to report this incident."
				if {$::option(log_warnDialogue)} {
					status_feedbWarn 1 [mc "Missing file ../.tv-viewer/config/current_rec.conf"]
				}
				settooltip .tray [mc "TV-Viewer idle"]
			}
		}
		c {
			# Timeshift
			system_trayChangeIc 2
			settooltip .tray [mc "Timeshift %" [lindex $::station(last) 0]]
		}
		d {
			# File playback
			system_trayChangeIc 3
			set fileSplit [file split [file normalize $::vid(current_rec_file)]]
			set fileSplitReformatted "[lindex $fileSplit 0][lindex $fileSplit 1]/../[lindex $fileSplit end]"
			settooltip .tray [mc "Playing file: %" $fileSplitReformatted]
		}
		e {
			# TV playback
			system_trayChangeIc 4
			settooltip .tray [mc "Now playing %" [lindex $::station(last) 0]]
		}
	}
}

proc system_trayResizer {delay} {
	#This proc is a hack because the virtual event <<IconConfigure>> does not work on XFCE 4.6.2 and maybe other WM.
	if {"$delay" == "cancel"} {
		if {[info exists ::system(systrayResizerID)]} {
			foreach id $::system(systrayResizerID) {
				after cancel $id
			}
		}
		unset -nocomplain ::system(systrayResizerID)
		return
	}
	if {[winfo exists .tray]} {
		set tray_size [lindex [.tray bbox] end]
		set grow 0
		foreach isize {22 32 48 64} {
			if {$tray_size > [expr $isize - 1] || $tray_size > [expr $isize + 1]} {
				if {$isize > $::system(iconSize)} {
					.tray configure -image $::icon_e(systray_icon$isize)
					set ::system(iconSize) $isize
					set grow 1
					log_writeOutTv 0 "Resized systray icon to $::icon_e(systray_icon$isize)"
					break
				}
			}
		}
		if {$grow} {
			set ::system(systrayResizerID) [after $delay [list system_trayResizer $delay]]
			return
		}
		foreach isize {64 48 32 22} {
			if {$tray_size < [expr $isize - 8] || $tray_size < [expr $isize + 8]} {
				if {$isize < $::system(iconSize)} {
					.tray configure -image $::icon_e(systray_icon$isize)
					set ::system(iconSize) $isize
					log_writeOutTv 0 "Resized systray icon to $::icon_e(systray_icon$isize)"
					break
				}
			}
		}
		set ::system(systrayResizerID) [after $delay [list system_trayResizer $delay]]
	} else {
		log_writeOutTv 2 "system_trayResizer triggered but tray icon does not exist"
		system_trayResizer cancel
	}
}

proc system_trayMenu {x y} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: system_trayMenu \033\[0m \{$x\} \{$y\}" 
	if {[winfo exists .tray.mTray]} {
		if {$y < 200} {
			tk_popup .tray.mTray $x [expr $y + 15]
		}
		if {[expr [winfo screenheight .]] - 200 < $y} {
			tk_popup .tray.mTray $x [expr $y - 15]
		}
	} else {
		#Create menu .tray.mTray and fill with content
		menu .tray.mTray -tearoff 0
		.tray.mTray add command -label [mc "Hide"] -compound left -image $::icon_men(placeholder) -command [list system_trayToggle 0]
		.tray.mTray add separator
		if {"[.foptions_bar.mbTvviewer.mTvviewer entrycget 0 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Color Management"] -compound left -image $::icon_men(color-management) -command colorm_mainUi -accelerator [dict get $::keyseq colorm name] -state disabled
		} else {
			.tray.mTray add command -label [mc "Color Management"] -compound left -image $::icon_men(color-management) -command colorm_mainUi -accelerator [dict get $::keyseq colorm name]
		}
		.tray.mTray add command -label [mc "Preferences"] -compound left -image $::icon_men(settings) -accelerator [dict get $::keyseq preferences name] -command {config_wizardMainUi}
		if {"[.foptions_bar.mbTvviewer.mTvviewer entrycget 2 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Station Editor"] -compound left -image $::icon_men(seditor) -command {station_editUi} -accelerator [dict get $::keyseq sedit name] -state disabled
		} else {
			.tray.mTray add command -label [mc "Station Editor"] -compound left -image $::icon_men(seditor) -command {station_editUi} -accelerator [dict get $::keyseq sedit name]
		}
		if {"[.foptions_bar.mbTvviewer.mTvviewer entrycget 4 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Timeshift"] -compound left -image $::icon_men(timeshift) -command {event generate . <<timeshift>>} -accelerator [dict get $::keyseq recTime name] -state disabled
		} else {
			.tray.mTray add command -label [mc "Timeshift"] -compound left -image $::icon_men(timeshift) -command {event generate . <<timeshift>>} -accelerator [dict get $::keyseq recTime name]
		}
		.tray.mTray add command -label [mc "Record Wizard"] -compound left -image $::icon_men(record) -command {event generate . <<record>>} -accelerator [dict get $::keyseq recWizard name]
		.tray.mTray add command -label [mc "EPG"] -compound left -image $::icon_men(placeholder) -command main_frontendEpg -accelerator ""
		if {"[.foptions_bar.mbTvviewer.mTvviewer entrycget 7 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Radio"] -compound left -image $::icon_men(radio) -command "" -accelerator "" -state disabled
		} else {
			.tray.mTray add command -label [mc "Radio"] -compound left -image $::icon_men(radio) -command "" -accelerator ""
		}
		if {"[.foptions_bar.mbTvviewer.mTvviewer entrycget 8 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "TV"] -compound left -image $::icon_men(starttv) -command {event generate . <<teleview>>} -accelerator [dict get $::keyseq startTv name] -state disabled
		} else {
			.tray.mTray add command -label [mc "TV"] -compound left -image $::icon_men(starttv) -command {event generate . <<teleview>>} -accelerator [dict get $::keyseq startTv name]
		}
		.tray.mTray add separator
		if {"[.foptions_bar.mbNavigation.mNavigation entrycget 0 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Prior Station"] -compound left -image $::icon_men(channel-prior) -command [list chan_zapperPrior .fstations.treeSlist] -accelerator [dict get $::keyseq stationPrior name] -state disabled
		} else {
			.tray.mTray add command -label [mc "Prior Station"] -compound left -image $::icon_men(channel-prior) -command [list chan_zapperPrior .fstations.treeSlist] -accelerator [dict get $::keyseq stationPrior name]
		}
		if {"[.foptions_bar.mbNavigation.mNavigation entrycget 1 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Next Station"] -compound left -image $::icon_men(channel-next) -command [list chan_zapperNext .fstations.treeSlist] -accelerator [dict get $::keyseq stationNext name] -state disabled
		} else {
			.tray.mTray add command -label [mc "Next Station"] -compound left -image $::icon_men(channel-next) -command [list chan_zapperNext .fstations.treeSlist] -accelerator [dict get $::keyseq stationNext name]
		}
		if {"[.foptions_bar.mbNavigation.mNavigation entrycget 2 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Station jumper"] -compound left -image $::icon_men(channel-jump) -command [list chan_zapperJump .fstations.treeSlist] -accelerator [dict get $::keyseq stationJump name] -state disabled
		} else {
			.tray.mTray add command -label [mc "Station jumper"] -compound left -image $::icon_men(channel-jump) -command [list chan_zapperJump .fstations.treeSlist] -accelerator [dict get $::keyseq stationJump name]
		}
		.tray.mTray add separator
		if {"[.foptions_bar.mbNavigation.mNavigation entrycget 4 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Play"] -compound left -image $::icon_men(playback-start) -command {event generate . <<start>>} -state disabled -accelerator [dict get $::keyseq filePlay name] -state disabled
		} else {
			.tray.mTray add command -label [mc "Play"] -compound left -image $::icon_men(playback-start) -command {event generate . <<start>>} -state disabled -accelerator [dict get $::keyseq filePlay name]
		}
		if {"[.foptions_bar.mbNavigation.mNavigation entrycget 5 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Pause"] -compound left -image $::icon_men(playback-pause) -command {event generate . <<pause>>} -accelerator [dict get $::keyseq filePause name] -state disabled
		} else {
			.tray.mTray add command -label [mc "Pause"] -compound left -image $::icon_men(playback-pause) -command {event generate . <<pause>>} -state normal -accelerator [dict get $::keyseq filePause name]
		}
		if {"[.foptions_bar.mbNavigation.mNavigation entrycget 6 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Stop"] -compound left -image $::icon_men(playback-stop) -command {event generate . <<stop>>} -accelerator [dict get $::keyseq fileStop name] -state disabled
		} else {
			.tray.mTray add command -label [mc "Stop"] -compound left -image $::icon_men(playback-stop) -command {event generate . <<stop>>} -state normal -accelerator [dict get $::keyseq fileStop name]
		}
		.tray.mTray add separator
		.tray.mTray add command -label [mc "Exit"] -compound left -image $::icon_men(dialog-close) -command [list event generate . <<exit>>] -accelerator "Ctrl+X"
		if {$y < 200} {
			tk_popup .tray.mTray $x [expr $y + 15]
		}
		if {[expr [winfo screenheight .]] - 200 < $y} {
			tk_popup .tray.mTray $x [expr $y - 15]
		}
	}
	log_writeOutTv 0 "Popup context menu for system tray icon"
}

proc system_trayToggle {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: system_trayToggle \033\[0m \{$handler\}"
	#handler 0 == -- 1 == 
	if {[winfo exists .tray] == 1} {
		set doIt 0
		set w {.station .station.delete .station.top_AddEdit .station.top_searchUi .station.top_search .config_wizard .config_wizard.fontchooser .top_about .top_cp_progress .top_diagnostic .record_wizard.add_edit .record_wizard.add_edit.date .record_wizard.delete .error_w .topWarn .key.default .key.f_key_treeview.tv_key.w_keyEdit .__ttk_filedialog .log_viewer.__ttk_filedialog}
		foreach window $w {
			if {[winfo exists $window]} {
				set doIt 1
				break
			}
		}
		if {$doIt} {
			log_writeOutTv 1 "Can not minimize/close to tray when $window exists."
			if {$::option(systrayMini)} {
				bind .fvidBg <Map> {
					bind .fvidBg <Map> {}
					bind .fvidBg <Unmap> {}
					after idle [list after 0 system_trayToggle 1]
				}
				bind .fvidBg <Unmap> {
					bind .fvidBg <Map> {}
					bind .fvidBg <Unmap> {}
					after idle [list after 0 system_trayToggle 1]
				}
			}
			if {$::option(systrayClose)} {
				wm protocol . WM_DELETE_WINDOW {bind .fvidBg <Map> {}; bind .fvidBg <Unmap> {}; after idle [list after 0 system_trayToggle 0]}
			}
			return
		}
		if {$handler == 0} {
			if {[winfo ismapped .] == 1} {
				array unset ::system_tray
				foreach w [winfo children .] {
					if {[string match . [winfo toplevel $w]] == 1 || [string match .tray [winfo toplevel $w]] == 1} continue
					set ::system_tray([winfo toplevel $w]) [winfo toplevel $w]
					wm withdraw $::system_tray($w)
					log_writeOutTv 0 "Docking \"$::system_tray($w)\" to system tray."
				}
				log_writeOutTv 0 "Docking \".\" to system tray."
				wm withdraw .
				if {[winfo exists .tray.mTray]} {
					.tray.mTray entryconfigure 0 -label [mc "Restore"]
				}
			} else {
				wm deiconify .
				log_writeOutTv 0 "Undocking \".\" from system tray."
				foreach {key elem} [array get ::system_tray] {
					if {[winfo exists $elem]} {
						wm deiconify $elem
						log_writeOutTv 0 "Undocking \"$elem\" from system tray."
					}
				}
				if {[winfo exists .tray.mTray]} {
					.tray.mTray entryconfigure 0 -label [mc "Hide"]
				}
				if {$::option(systrayMini)} {
					bind .fvidBg <Map> {
						bind .fvidBg <Map> {}
						bind .fvidBg <Unmap> {}
						after idle [list after 0 system_trayToggle 1]
					}
					bind .fvidBg <Unmap> {
						bind .fvidBg <Map> {}
						bind .fvidBg <Unmap> {}
						after idle [list after 0 system_trayToggle 1]
					}
				}
				if {$::option(systrayClose)} {
					wm protocol . WM_DELETE_WINDOW {bind .fvidBg <Map> {}; bind .fvidBg <Unmap> {}; after idle [list after 0 system_trayToggle 0]}
				}
			}
		} else {
			if {[winfo ismapped .] == 0} {
				array unset ::system_tray
				foreach w [winfo children .] {
					if {[string match . [winfo toplevel $w]] == 1 || [string match .tray [winfo toplevel $w]] == 1} continue
					set ::system_tray([winfo toplevel $w]) [winfo toplevel $w]
					wm withdraw $::system_tray($w)
					log_writeOutTv 0 "Docking \"$::system_tray($w)\" to system tray."
				}
				log_writeOutTv 0 "Docking \".\" to system tray."
				wm withdraw .
				if {[winfo exists .tray.mTray]} {
					.tray.mTray entryconfigure 0 -label [mc "Restore"]
				}
			}
			if {$::option(systrayMini)} {
				bind .fvidBg <Map> {
					bind .fvidBg <Map> {}
					bind .fvidBg <Unmap> {}
					after idle [list after 0 system_trayToggle 1]
				}
				bind .fvidBg <Unmap> {
					bind .fvidBg <Map> {}
					bind .fvidBg <Unmap> {}
					after idle [list after 0 system_trayToggle 1]
				}
			}
			if {$::option(systrayClose)} {
				wm protocol . WM_DELETE_WINDOW {bind .fvidBg <Map> {}; bind .fvidBg <Unmap> {}; after idle [list after 0 system_trayToggle 0]}
			}
		}
	} else {
		log_writeOutTv 2 "Coroutine attempted to dock TV-Viewer, but tray icon does not exist."
	}
}

proc system_trayChangeIc {icId} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: system_trayChangeIc \033\[0m \{$icId\}"
	if {[winfo exists .tray] == 0} {
		return
	}
	#icId which icon to choose, see array icons
	array set icons {
		0 systray_icon
		1 systray_icon_rec
		2 systray_icon_time
		3 systray_icon_video
		4 systray_icon_tv
	}
	.tray configure -image $::icon_e($icons($icId)$::option(systrayIcSize))
}
