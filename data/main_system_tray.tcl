#       main_system_tray.tcl
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

proc main_systemTrayActivate {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_systemTrayActivate \033\[0m"
	catch {
		if {[winfo exists .tray] == 0} {
			tktray::icon .tray -image $::icon_e(tv-viewer_icon_systray)
			#after 500 {.tray configure -image $::icon_e(tv-viewer_icon_systray)}
			after 600 {.tray configure -image $::icon_b(placeholder)}
			after 1000 {
				.tray configure -image $::icon_e(tv-viewer_icon_systray)
				bind .tray <Button-1> { main_systemTrayToggle}
				if {[winfo exists .tray] == 1} {
					settooltip .tray [mc "TV-Viewer idle"]
					log_writeOutTv 0 "Succesfully added Icon to system tray."
				} else {
					log_writeOutTv 2 "Could not create an icon in system tray."
				}
			}
		} else {
			bind .tray <Button-1> {}
			destroy .tray
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

proc main_systemTrayToggle {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_systemTrayToggle \033\[0m"
	if {[winfo exists .tray] == 1} {
		if {[winfo ismapped .] == 1} {
			if {$::option(systray_tv) == 1} {
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
		} else {
			wm deiconify .
			log_writeOutTv 0 "Undocking \".\" from system tray."
			foreach {key elem} [array get ::system_tray] {
				if {[winfo exists $elem]} {
					wm deiconify $elem
					log_writeOutTv 0 "Undocking \"$elem\" from system tray."
				}
			}
		}
	} else {
		log_writeOutTv 2 "Coroutine attempted to dock TV-Viewer, but tray icon does not exist."
	}
}

proc main_systemTrayMini {com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_systemTrayMini \033\[0m \{$com\}"
	if {"$com" == "unmap"} {
		if {[winfo exists .tray] == 1} {
			bind . <Unmap> {}
			bind . <Map> [list main_systemTrayMini map]
			if {$::option(systray_tv) == 1} {
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
		} else {
			log_writeOutTv 2 "Coroutine attempted to dock TV-Viewer, but tray icon does not exist."
		}
	} else {
		bind . <Unmap> {
			if {[winfo ismapped .] == 0} {
				if {[winfo exists .tray] == 0} {
					main_systemTrayActivate
					set ::choice(cb_systray_main) 1
				}
				main_systemTrayMini unmap
			}
		}
		bind . <Map> {}
	}
}
