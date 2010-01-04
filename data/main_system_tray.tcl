#       main_system_tray.tcl
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

proc main_systemTrayActivate {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_systemTrayActivate \033\[0m"
	if {[winfo exists .tray] == 0} {
		catch {tktray::icon .tray -image $::icon_s(placeholder) -visible 0}
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
					.tray configure -image $::icon_e(tv-viewer_icon_systray) -visible 1
					bind .tray <Button-1> { main_systemTrayToggle}
					settooltip .tray [mc "TV-Viewer idle"]
					log_writeOutTv 0 "Succesfully added Icon to system tray."
				}
			}
		} else {
			log_writeOutTv 2 "Could not create an icon in system tray."
		}
	} else {
		bind .tray <Button-1> {}
		destroy .tray
		wm protocol . WM_DELETE_WINDOW [list event generate . <<exit>>]
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

#~ proc main_systemTrayClose {com} {
	#~ puts $::main(debug_msg) "\033\[0;1;33mDebug: main_systemTrayClose \033\[0m \{$com\}"
	#~ if {"$com" == "tray"} {
		#~ if {[winfo exists .tray] == 1} {
			#~ wm protocol . WM_DELETE_WINDOW {main_systemTrayTogglePre}
			#~ bind . <Map> [list main_systemTrayMini map]
			#~ if {$::option(systray_tv) == 1} {
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
					#~ main_systemTrayActivate 0
					#~ set ::choice(cb_systray_main) 1
				#~ }
				#~ main_systemTrayMini unmap
			#~ }
		#~ }
		#~ bind . <Map> {}
	#~ }
#~ }

proc main_systemTrayTogglePre {} {
	if {[winfo exists .tray] == 0} {
		main_systemTrayActivate 0
		set ::choice(cb_systray_main) 1
	}
	main_systemTrayToggle
}
