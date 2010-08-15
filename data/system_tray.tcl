#       system_tray.tcl
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

proc system_trayActivate {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: system_trayActivate \033\[0m"
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
					.tray configure -image $::icon_e(systray_icon22) -visible 1
					set ::system(iconSize) 22
					bind .tray <Button-1> {system_trayToggle}
					bind .tray <Button-3> {system_trayMenu %X %Y}
					settooltip .tray [mc "TV-Viewer idle"]
					system_trayResizer cancel
					after 2000 {system_trayResizer 2000}
					log_writeOutTv 0 "Succesfully added Icon to system tray."
				}
			}
		} else {
			log_writeOutTv 2 "Could not create an icon in system tray."
		}
	} else {
		system_trayResizer cancel
		bind .tray <Button-1> {}
		bind .tray <<IconConfigure>> {}
		destroy .tray
		wm protocol . WM_DELETE_WINDOW [list event generate . <<exit>>]
	}
}

proc system_trayResizer {delay} {
	#This proc is a hack because the virtual even <<IconConfigure>> does not work on XFCE 4.6.2 and maybe other WM.
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
		#FIXME Find a way to pop up menu some pixels away from mouse position
		tk_popup .tray.mTray $x $y
	} else {
		#Create menu .tray.mTray and fill with content
		menu .tray.mTray -tearoff 0 -background $::option(theme_$::option(use_theme))
		.tray.mTray add command -label [mc "Hide"] -compound left -image $::icon_men(placeholder) -command system_trayToggle
		.tray.mTray add separator
		if {"[.foptions_bar.mbTvviewer.mTvviewer entrycget 0 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Color Management"] -compound left -image $::icon_men(color-management) -command colorm_mainUi -accelerator [mc "Ctrl+M"] -state disabled
		} else {
			.tray.mTray add command -label [mc "Color Management"] -compound left -image $::icon_men(color-management) -command colorm_mainUi -accelerator [mc "Ctrl+M"]
		}
		.tray.mTray add command -label [mc "Preferences"] -compound left -image $::icon_men(settings) -accelerator [mc "Ctrl+P"] -command {config_wizardMainUi}
		if {"[.foptions_bar.mbTvviewer.mTvviewer entrycget 2 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Station Editor"] -compound left -image $::icon_men(seditor) -command {station_editUi} -accelerator [mc "Ctrl+E"] -state disabled
		} else {
			.tray.mTray add command -label [mc "Station Editor"] -compound left -image $::icon_men(seditor) -command {station_editUi} -accelerator [mc "Ctrl+E"]
		}
		if {"[.foptions_bar.mbTvviewer.mTvviewer entrycget 4 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Timeshift"] -compound left -image $::icon_men(timeshift) -command {event generate . <<timeshift>>} -accelerator "T" -state disabled
		} else {
			.tray.mTray add command -label [mc "Timeshift"] -compound left -image $::icon_men(timeshift) -command {event generate . <<timeshift>>} -accelerator "T"
		}
		.tray.mTray add command -label [mc "Record Wizard"] -compound left -image $::icon_men(record) -command {event generate . <<record>>} -accelerator "R"
		.tray.mTray add command -label [mc "EPG"] -compound left -image $::icon_men(placeholder) -command main_frontendEpg -accelerator ""
		if {"[.foptions_bar.mbTvviewer.mTvviewer entrycget 7 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Radio"] -compound left -image $::icon_men(radio) -command "" -accelerator "" -state disabled
		} else {
			.tray.mTray add command -label [mc "Radio"] -compound left -image $::icon_men(radio) -command "" -accelerator ""
		}
		if {"[.foptions_bar.mbTvviewer.mTvviewer entrycget 8 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "TV"] -compound left -image $::icon_men(starttv) -command {event generate . <<teleview>>} -accelerator "S" -state disabled
		} else {
			.tray.mTray add command -label [mc "TV"] -compound left -image $::icon_men(starttv) -command {event generate . <<teleview>>} -accelerator "S"
		}
		.tray.mTray add separator
		if {"[.foptions_bar.mbNavigation.mNavigation entrycget 0 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Next station"] -compound left -image $::icon_men(channel-up) -command [list chan_zapperUp .fstations.treeSlist] -accelerator [mc "PageDOWN"] -state disabled
		} else {
			.tray.mTray add command -label [mc "Next station"] -compound left -image $::icon_men(channel-up) -command [list chan_zapperUp .fstations.treeSlist] -accelerator [mc "PageDOWN"]
		}
		if {"[.foptions_bar.mbNavigation.mNavigation entrycget 1 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Previous station"] -compound left -image $::icon_men(channel-down) -command [list chan_zapperDown .fstations.treeSlist] -accelerator [mc "PageUP"] -state disabled
		} else {
			.tray.mTray add command -label [mc "Previous station"] -compound left -image $::icon_men(channel-down) -command [list chan_zapperDown .fstations.treeSlist] -accelerator [mc "PageUP"]
		}
		if {"[.foptions_bar.mbNavigation.mNavigation entrycget 2 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Station jumper"] -compound left -image $::icon_men(channel-jump) -command [list chan_zapperJump .fstations.treeSlist] -accelerator J -state disabled
		} else {
			.tray.mTray add command -label [mc "Station jumper"] -compound left -image $::icon_men(channel-jump) -command [list chan_zapperJump .fstations.treeSlist] -accelerator J
		}
		.tray.mTray add separator
		if {"[.foptions_bar.mbNavigation.mNavigation entrycget 4 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Play"] -compound left -image $::icon_men(playback-start) -command {event generate . <<start>>} -state disabled -accelerator [mc "Shift+P"] -state disabled
		} else {
			.tray.mTray add command -label [mc "Play"] -compound left -image $::icon_men(playback-start) -command {event generate . <<start>>} -state disabled -accelerator [mc "Shift+P"]
		}
		if {"[.foptions_bar.mbNavigation.mNavigation entrycget 5 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Pause"] -compound left -image $::icon_men(playback-pause) -command {event generate . <<pause>>} -accelerator P -state disabled
		} else {
			.tray.mTray add command -label [mc "Pause"] -compound left -image $::icon_men(playback-pause) -command {event generate . <<pause>>} -state normal -accelerator P
		}
		if {"[.foptions_bar.mbNavigation.mNavigation entrycget 6 -state]" == "disabled"} {
			.tray.mTray add command -label [mc "Stop"] -compound left -image $::icon_men(playback-stop) -command {event generate . <<stop>>} -accelerator [mc "Shift+S"] -state disabled
		} else {
			.tray.mTray add command -label [mc "Stop"] -compound left -image $::icon_men(playback-stop) -command {event generate . <<stop>>} -state normal -accelerator [mc "Shift+S"]
		}
		.tray.mTray add separator
		.tray.mTray add command -label [mc "Exit"] -compound left -image $::icon_men(dialog-close) -command [list event generate . <<exit>>] -accelerator [mc "Ctrl+X"]
		tk_popup .tray.mTray $x $y
	}
	log_writeOutTv 0 "Popup context menu for system tray icon"
}

proc system_trayToggle {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: system_trayToggle \033\[0m"
	if {[winfo exists .tray] == 1} {
		if {[winfo ismapped .] == 1} {
			if {$::option(systray) == 1} {
				array unset ::system_tray
				foreach w [winfo children .] {
					if {[string match . [winfo toplevel $w]] == 1 || [string match .tray [winfo toplevel $w]] == 1} continue
					set ::system_tray([winfo toplevel $w]) [winfo toplevel $w]
					wm withdraw $::system_tray($w)
					log_writeOutTv 0 "Docking \"$::system_tray($w)\" to system tray."
				}
				log_writeOutTv 0 "Docking \".\" to system tray."
				wm withdraw .
			} else {
				array unset ::system_tray
				foreach w [winfo children .] {
					if {[string match . [winfo toplevel $w]] == 1 || [string match .tray [winfo toplevel $w]] == 1 || [string match .tv [winfo toplevel $w]] == 1} continue
					set ::system_tray([winfo toplevel $w]) [winfo toplevel $w]
					wm withdraw $::system_tray($w)
					log_writeOutTv 0 "Docking \"$::system_tray($w)\" to system tray."
				}
				log_writeOutTv 0 "Docking \".\" to system tray."
				wm withdraw .
			}
			if {[winfo exists .tray.mTray]} {
				.tray.mTray entryconfigure 0 -label [mc "Restore"]
			}
			#~ set ::menu(cbSystray) 0
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
			#~ set ::menu(cbSystray) 0
		}
	} else {
		log_writeOutTv 2 "Coroutine attempted to dock TV-Viewer, but tray icon does not exist."
	}
}

#FIXME - Minimize to tray, problems when moving window from one desktop to another.
#FIXME Therefor deactivated this feature. Now we only have close to tray. Idea look if 
#FIXME window is still mapped when app receives <Map> <Unmap> events.
#FIXME On the other hand it might be the feature becomes obsolete with the new interface.
#~ proc system_trayClose {com} {
	#~ puts $::main(debug_msg) "\033\[0;1;33mDebug: system_trayClose \033\[0m \{$com\}"
	#~ if {"$com" == "tray"} {
		#~ if {[winfo exists .tray] == 1} {
			#~ wm protocol . WM_DELETE_WINDOW {system_trayTogglePre}
			#~ bind . <Map> [list main_systemTrayMini map]
			#~ if {$::option(systray) == 1} {
				#~ array unset ::system_tray
				#~ foreach w [winfo children .] {
					#~ if {[string match . [winfo toplevel $w]] == 1 || [string match .tray [winfo toplevel $w]] == 1} continue
					#~ set ::system_tray([winfo toplevel $w]) [winfo toplevel $w]
					#~ wm withdraw $::system_tray($w)
					#~ log_writeOutTv 0 "Docking \"$::system_tray($w)\" to system tray."
				#~ }
				#~ log_writeOutTv 0 "Docking \".\" to system tray."
				#~ wm withdraw .
			#~ } else {
				#~ array unset ::system_tray
				#~ foreach w [winfo children .] {
					#~ if {[string match . [winfo toplevel $w]] == 1 || [string match .tray [winfo toplevel $w]] == 1 || [string match .tv [winfo toplevel $w]] == 1} continue
					#~ set ::system_tray([winfo toplevel $w]) [winfo toplevel $w]
					#~ wm withdraw $::system_tray($w)
					#~ log_writeOutTv 0 "Docking \"$::system_tray($w)\" to system tray."
				#~ }
				#~ log_writeOutTv 0 "Docking \".\" to system tray."
				#~ wm withdraw .
			#~ }
		#~ } else {
			#~ log_writeOutTv 2 "Coroutine attempted to dock TV-Viewer, but tray icon does not exist."
		#~ }
	#~ }
	 #~ else {
		#~ bind . <Unmap> {
			#~ if {[winfo ismapped .] == 0} {
				#~ if {[winfo exists .tray] == 0} {
					#~ system_trayActivate 0
					#~ set ::menu(cbSystray) 1
				#~ }
				#~ main_systemTrayMini unmap
			#~ }
		#~ }
		#~ bind . <Map> {}
	#~ }
#~ }

proc system_trayTogglePre {} {
	if {[winfo exists .tray] == 0} {
		system_trayActivate 0
		set ::menu(cbSystray) 1
	}
	system_trayToggle
}
