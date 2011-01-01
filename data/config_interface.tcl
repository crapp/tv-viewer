#       config_interface.tcl
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

proc option_screen_6 {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: option_screen_6 \033\[0m"
	
	# Setting up the interface
	
	foreach tab [split [.config_wizard.frame_configoptions.nb tabs]] {
		.config_wizard.frame_configoptions.nb hide $tab
	}
	
	if {[winfo exists .config_wizard.frame_configoptions.nb.f_interface]} {
		.config_wizard.frame_configoptions.nb add $::window(interface_nb1)
		.config_wizard.frame_configoptions.nb add $::window(interface_nb2)
		.config_wizard.frame_configoptions.nb add $::window(interface_nb3)
		.config_wizard.frame_configoptions.nb select $::window(interface_nb1)
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt6 $::window(interface_nb1) $::window(interface_nb2) $::window(interface_nb3)]
		bind $::window(interface_nb2_cont) <Map> {
			$::window(interface_nb2_cont) itemconfigure cont_int_nb2 -width [winfo width $::window(interface_nb2_cont)] -height [winfo reqheight $::window(interface_nb2_cont).f_windowprop2]
			$::window(interface_nb2_cont) configure -scrollregion [$::window(interface_nb2_cont) bbox all]
			$::window(interface_nb2_cont) yview moveto 0
		}
		bind $::window(interface_nb3_cont) <Map> {
			$::window(interface_nb3_cont) itemconfigure cont_int_nb3 -width [winfo width $::window(interface_nb3_cont)] -height [winfo reqheight $::window(interface_nb3_cont).f_osd2]
			$::window(interface_nb3_cont) configure -scrollregion [$::window(interface_nb3_cont) bbox all]
			$::window(interface_nb3_cont) yview moveto 0
		}
	} else {
		log_writeOutTv 0 "Setting up interface section in preferences"
		set w .config_wizard.frame_configoptions.nb
		set ::window(interface_nb1) [ttk::frame $w.f_interface]
		$w add $::window(interface_nb1) -text [mc "Interface Settings"] -padding 2
		ttk::labelframe $::window(interface_nb1).lf_theme -text [mc "Theme"]
		ttk::menubutton $::window(interface_nb1).mb_lf_theme -menu $::window(interface_nb1).mbTheme -textvariable choice(mbTheme)
		menu $::window(interface_nb1).mbTheme -tearoff 0
		ttk::checkbutton $::window(interface_nb1).cb_lf_tooltip -text [mc "Enable Tooltips"] \
		-variable choice(cb_tooltip) -command [list config_interfaceChangeTooltips $::window(interface_nb1)]
		ttk::labelframe $::window(interface_nb1).lf_tooltip -labelwidget $::window(interface_nb1).cb_lf_tooltip
		ttk::checkbutton $::window(interface_nb1).cb_lf_tooltip_main -text [mc "Main Gui"] -variable choice(cb_tooltip_main)
		ttk::checkbutton $::window(interface_nb1).cb_lf_tooltip_wizard -text [mc "Preferences"] \
		-variable choice(cb_tooltip_wizard)
		ttk::checkbutton $::window(interface_nb1).cb_lf_tooltip_station -text [mc "Station Editor"] -variable choice(cb_tooltip_station)
		ttk::checkbutton $::window(interface_nb1).cb_lf_tooltip_videocard -text [mc "Color Management"] -variable choice(cb_tooltip_colorm)
		ttk::checkbutton $::window(interface_nb1).cb_lf_tooltip_record -text [mc "Record Wizard"] -variable choice(cb_tooltip_record)
		
		ttk::labelframe $::window(interface_nb1).lf_splash -text [mc "Splash Screen"]
		ttk::checkbutton $::window(interface_nb1).cb_lf_splash -text [mc "Show Splash Screen on initialization"] -variable choice(cb_splash)
		
		
		set ::window(interface_nb2) [ttk::frame $w.f_windowprop]
		$w add $::window(interface_nb2) -text [mc "Window Properties"] -padding 2
		set ::window(interface_nb2_cont) [canvas $::window(interface_nb2).c_cont -yscrollcommand [list $::window(interface_nb2).scrollb_cont set] -highlightthickness 0]
		ttk::scrollbar $::window(interface_nb2).scrollb_cont -command [list $::window(interface_nb2).c_cont yview]
		$::window(interface_nb2_cont) create window 0 0 -window [ttk::frame $::window(interface_nb2_cont).f_windowprop2] -anchor w -tags cont_int_nb2
		
		ttk::labelframe $::window(interface_nb2_cont).f_windowprop2.lf_mainWindow -text [mc "Main window"]
		set lf_manWindow $::window(interface_nb2_cont).f_windowprop2.lf_mainWindow
		ttk::checkbutton $lf_manWindow.cb_fullscr -text [mc "Start in full-screen mode"] -variable choice(cb_fullscr)
		ttk::checkbutton $lf_manWindow.cb_remGeom -text [mc "Remember size and position"] -variable choice(cb_remGeom)
		
		ttk::labelframe $::window(interface_nb2_cont).f_windowprop2.lf_floatingCtrl -text [mc "Floating control"]
		set lf_floatingCtrl $::window(interface_nb2_cont).f_windowprop2.lf_floatingCtrl
		ttk::checkbutton $lf_floatingCtrl.cb_floatMain -text [mc "Main toolbar"] -variable choice(cb_floatMain)
		ttk::checkbutton $lf_floatingCtrl.cb_floatStation -text [mc "Station list"] -variable choice(cb_floatStation)
		ttk::checkbutton $lf_floatingCtrl.cb_floatPlay -text [mc "Control toolbar"] -variable choice(cb_floatPlay)
		
		ttk::labelframe $::window(interface_nb2_cont).f_windowprop2.lf_systray -text [mc "System Tray"]
		set lf_systray $::window(interface_nb2_cont).f_windowprop2.lf_systray
		ttk::checkbutton $lf_systray.cb_systray -text [mc "Show icon in system tray"] -variable choice(cb_systray) -command {system_trayActivate 0}
		ttk::checkbutton $lf_systray.cb_systray_mini -text [mc "Minimize to tray"] -variable choice(cb_systrayMini)
		ttk::checkbutton $lf_systray.cb_systrayClose -text [mc "Close to tray"] -variable choice(cb_systrayClose)
		ttk::checkbutton $lf_systray.cb_systrayResize -text [mc "Resize system tray icon"] -variable choice(cb_systrayResize) -state disabled
		ttk::label $lf_systray.l_systrayIcSize -text [mc "System tray icon size"]
		ttk::menubutton $lf_systray.mb_systrayIcSize -menu $lf_systray.mb_systrayIcSize.mIcSize
		
		set ::window(interface_nb3) [ttk::frame $w.f_osd]
		$w add $::window(interface_nb3) -text [mc "On screen Display"] -padding 2
		set ::window(interface_nb3_cont) [canvas $::window(interface_nb3).c_cont -yscrollcommand [list $::window(interface_nb3).scrollb_cont set] -highlightthickness 0]
		ttk::scrollbar $::window(interface_nb3).scrollb_cont -command [list $::window(interface_nb3).c_cont yview]
		$::window(interface_nb3_cont) create window 0 0 -window [ttk::frame $::window(interface_nb3_cont).f_osd2] -anchor w -tags cont_int_nb3
		set frame_nb3  "$::window(interface_nb3_cont).f_osd2"
		
		ttk::labelframe $frame_nb3.lf_osd_station -text [mc "Station"]
		set lf_osdStation $frame_nb3.lf_osd_station
		ttk::checkbutton $lf_osdStation.cb_osd_station_w -variable config_int(cb_osd_station_w) -text [mc "Windowed mode"] -command {set ::choice(osd_station_w) [lreplace $::choice(osd_station_w) 0 0 $::config_int(cb_osd_station_w)]}
		ttk::button $lf_osdStation.b_osd_station_fnt_w -command [list font_chooserUi $lf_osdStation.b_osd_station_fnt_w osd_station_w]
		ttk::checkbutton $lf_osdStation.cb_osd_station_f -variable config_int(cb_osd_station_f) -text [mc "Full-screen mode"] -command {set ::choice(osd_station_f) [lreplace $::choice(osd_station_f) 0 0 $::config_int(cb_osd_station_f)]}
		ttk::button $lf_osdStation.b_osd_station_fnt_f -command [list font_chooserUi $frame_nb3.b_osd_station_fnt_f osd_station_f]
		
		ttk::labelframe $frame_nb3.lf_osd_group -text [mc "Volume | Video input | Pan&Scan"]
		ttk::checkbutton $frame_nb3.cb_osd_group_w -variable config_int(cb_osd_group_w) -text [mc "Windowed mode"] -command {set ::choice(osd_group_w) [lreplace $::choice(osd_group_w) 0 0 $::config_int(cb_osd_group_w)]}
		ttk::button $frame_nb3.b_osd_group_fnt_w -command [list font_chooserUi $frame_nb3.b_osd_group_fnt_w osd_group_w]
		ttk::checkbutton $frame_nb3.cb_osd_group_f -variable config_int(cb_osd_group_f) -text [mc "Full-screen mode"] -command {set ::choice(osd_group_f) [lreplace $::choice(osd_group_f) 0 0 $::config_int(cb_osd_group_f)]}
		ttk::button $frame_nb3.b_osd_group_fnt_f -command [list font_chooserUi $frame_nb3.b_osd_group_fnt_f osd_group_f]
		
		ttk::labelframe $frame_nb3.lf_osd_key -text [mc "Key Input"]
		ttk::checkbutton $frame_nb3.cb_osd_key_w -variable config_int(cb_osd_key_w) -text [mc "Windowed mode"] -command {set ::choice(osd_key_w) [lreplace $::choice(osd_key_f) 0 0 $::config_int(cb_osd_key_w)]}
		ttk::button $frame_nb3.b_osd_key_fnt_w -command [list font_chooserUi $frame_nb3.b_osd_key_fnt_w osd_key_w]
		ttk::checkbutton $frame_nb3.cb_osd_key_f -variable config_int(cb_osd_key_f) -text [mc "Full-screen mode"] -command {set ::choice(osd_key_f) [lreplace $::choice(osd_key_f) 0 0 $::config_int(cb_osd_key_f)]}
		ttk::button $frame_nb3.b_osd_key_fnt_f -command [list font_chooserUi $frame_nb3.b_osd_key_fnt_f osd_key_f]
		
		ttk::labelframe $frame_nb3.lf_osd_lirc -text [mc "OSD Station list lirc"]
		ttk::label $frame_nb3.l_osd_lirc_fnt -text [mc "Full-screen mode"]
		ttk::button $frame_nb3.b_osd_lirc_fnt -command [list font_chooserUi $frame_nb3.b_osd_lirc_fnt osd_lirc]
		
		grid columnconfigure $::window(interface_nb1) 0 -weight 1
		grid columnconfigure $::window(interface_nb1).lf_theme 0 -minsize 120
		grid columnconfigure $::window(interface_nb2) 0 -weight 1
		grid columnconfigure $::window(interface_nb2_cont).f_windowprop2 0 -weight 1
		grid rowconfigure $::window(interface_nb2_cont).f_windowprop2 0 -weight 1
		grid columnconfigure $lf_systray 1 -minsize 120
		grid columnconfigure $::window(interface_nb3) 0 -weight 1
		grid columnconfigure $::window(interface_nb3_cont).f_osd2 0 -weight 1
		grid rowconfigure $::window(interface_nb3) 0 -weight 1
		
		grid $::window(interface_nb1).lf_theme -in $::window(interface_nb1) -row 0 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(interface_nb1).mb_lf_theme -in $::window(interface_nb1).lf_theme -row 0 -column 0 -sticky ew -padx 7 -pady 3
		grid $::window(interface_nb1).lf_tooltip -in $::window(interface_nb1) -row 1 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(interface_nb1).cb_lf_tooltip_main -in $::window(interface_nb1).lf_tooltip -row 0 -column 0 -sticky w -padx 7 -pady 3
		grid $::window(interface_nb1).cb_lf_tooltip_wizard -in $::window(interface_nb1).lf_tooltip -row 0 -column 1 -sticky w -pady 3
		grid $::window(interface_nb1).cb_lf_tooltip_station -in $::window(interface_nb1).lf_tooltip -row 0 -column 2 -sticky w -padx "7 0" -pady 3
		grid $::window(interface_nb1).cb_lf_tooltip_videocard -in $::window(interface_nb1).lf_tooltip -row 1 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $::window(interface_nb1).cb_lf_tooltip_record -in $::window(interface_nb1).lf_tooltip -row 1 -column 1 -sticky w -pady "0 3"
		grid $::window(interface_nb1).lf_splash -in $::window(interface_nb1) -row 2 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(interface_nb1).cb_lf_splash -in $::window(interface_nb1).lf_splash -row 0 -column 0 -padx 7 -pady 3
		
		grid $::window(interface_nb2_cont) -in $::window(interface_nb2) -row 0 -column 0 -sticky nesw
		grid $::window(interface_nb2).scrollb_cont -in $::window(interface_nb2) -row 0 -column 1 -sticky ns
		
		grid $lf_manWindow -in $::window(interface_nb2_cont).f_windowprop2 -row 0 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $lf_manWindow.cb_fullscr -in $lf_manWindow -row 0 -column 0 -sticky w -padx 7 -pady 3
		grid $lf_manWindow.cb_remGeom -in $lf_manWindow -row 1 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $lf_floatingCtrl -in $::window(interface_nb2_cont).f_windowprop2 -row 1 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $lf_floatingCtrl.cb_floatMain -in $lf_floatingCtrl -row 0 -column 0 -sticky w -padx 7 -pady 3
		grid $lf_floatingCtrl.cb_floatStation -in $lf_floatingCtrl -row 1 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $lf_floatingCtrl.cb_floatPlay -in $lf_floatingCtrl -row 2 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $lf_systray -in $::window(interface_nb2_cont).f_windowprop2 -row 2 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $lf_systray.cb_systray -in $lf_systray -row 0 -column 0 -sticky w -padx 7 -pady 3
		grid $lf_systray.cb_systray_mini -in $lf_systray -row 1 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $lf_systray.cb_systrayClose -in $lf_systray -row 2 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $lf_systray.cb_systrayResize -in $lf_systray -row 3 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $lf_systray.l_systrayIcSize -in $lf_systray -row 4 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $lf_systray.mb_systrayIcSize -in $lf_systray -row 4 -column 1 -sticky w -pady "0 3"
		
		grid $::window(interface_nb3_cont) -in $::window(interface_nb3) -row 0 -column 0 -sticky nesw
		grid $::window(interface_nb3).scrollb_cont -in $::window(interface_nb3) -row 0 -column 1 -sticky ns
		
		grid $lf_osdStation -in $frame_nb3 -row 0 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $lf_osdStation.cb_osd_station_w -in $lf_osdStation -row 0 -column 0 -sticky w -padx 7 -pady 3
		grid $lf_osdStation.b_osd_station_fnt_w -in $lf_osdStation -row 0 -column 1 -sticky ew -padx "0 7" -pady 3
		grid $lf_osdStation.cb_osd_station_f -in $lf_osdStation -row 1 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $lf_osdStation.b_osd_station_fnt_f -in $lf_osdStation -row 1 -column 1 -sticky ew -padx "0 7" -pady "0 3"
		
		grid $frame_nb3.lf_osd_group -in $frame_nb3 -row 1 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $frame_nb3.cb_osd_group_w -in $frame_nb3.lf_osd_group -row 0 -column 0 -sticky w -padx 7 -pady 3
		grid $frame_nb3.b_osd_group_fnt_w -in $frame_nb3.lf_osd_group -row 0 -column 1 -sticky ew -padx "0 7" -pady 3
		grid $frame_nb3.cb_osd_group_f -in $frame_nb3.lf_osd_group -row 1 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $frame_nb3.b_osd_group_fnt_f -in $frame_nb3.lf_osd_group -row 1 -column 1 -sticky ew -padx "0 7" -pady "0 3"
		
		grid $frame_nb3.lf_osd_key -in $frame_nb3 -row 2 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $frame_nb3.cb_osd_key_w -in $frame_nb3.lf_osd_key -row 0 -column 0 -sticky w -padx 7 -pady 3
		grid $frame_nb3.b_osd_key_fnt_w -in $frame_nb3.lf_osd_key -row 0 -column 1 -sticky ew -padx "0 7" -pady 3
		grid $frame_nb3.cb_osd_key_f -in $frame_nb3.lf_osd_key -row 1 -column 0 -sticky w -padx 7 -pady "0 3"
		grid $frame_nb3.b_osd_key_fnt_f -in $frame_nb3.lf_osd_key -row 1 -column 1 -sticky ew -padx "0 7" -pady "0 3"
		
		grid $frame_nb3.lf_osd_lirc -in $frame_nb3 -row 4 -column 0 -sticky ew -padx 5 -pady 5
		grid $frame_nb3.l_osd_lirc_fnt -in $frame_nb3.lf_osd_lirc -row 0 -column 0 -padx "23 7" -pady "3"
		grid $frame_nb3.b_osd_lirc_fnt -in $frame_nb3.lf_osd_lirc -row 0 -column 1 -sticky ew -pady "3"
		
		#Additional Code
		
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt6 $::window(interface_nb1) $::window(interface_nb2) $::window(interface_nb3)]
		
		foreach athemes [split [lsort [ttk::style theme names]]] {
			log_writeOutTv 0 "Found theme: $athemes"
			$::window(interface_nb1).mbTheme add radiobutton -variable choice(mbTheme) -command [list config_interfaceTheme $athemes] -label $athemes
		}
		menu $lf_systray.mb_systrayIcSize.mIcSize -tearoff 0
		foreach size {22 32 48 64} {
			$lf_systray.mb_systrayIcSize.mIcSize add radiobutton -variable choice(mb_systrayIcSize) -label "$size\px" -command [list config_interfaceSystray $size] -value $size
		}
		foreach scrollw [winfo children $::window(interface_nb2_cont).f_windowprop2] {
			bind $scrollw <Button-4> {config_interfaceMousew $::window(interface_nb2_cont) 120}
			bind $scrollw <Button-5> {config_interfaceMousew $::window(interface_nb2_cont) -120}
		}
		bind $::window(interface_nb2_cont).f_windowprop2  <Button-4> {config_interfaceMousew $::window(interface_nb2_cont) 120}
		bind $::window(interface_nb2_cont).f_windowprop2  <Button-5> {config_interfaceMousew $::window(interface_nb2_cont) -120}
		foreach scrollw [winfo children $::window(interface_nb3_cont).f_osd2] {
			bind $scrollw <Button-4> {config_interfaceMousew $::window(interface_nb3_cont) 120}
			bind $scrollw <Button-5> {config_interfaceMousew $::window(interface_nb3_cont) -120}
		}
		bind $::window(interface_nb3_cont).f_osd2  <Button-4> {config_interfaceMousew $::window(interface_nb3_cont) 120}
		bind $::window(interface_nb3_cont).f_osd2  <Button-5> {config_interfaceMousew $::window(interface_nb3_cont) -120}
		# Subprocs
		
		proc config_interfaceTheme {theme} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: config_interfaceTheme \033\[0m \{$theme\}"
			ttk::style theme use $theme
			if {"$theme" == "clam"} {
				ttk::style configure TLabelframe -labeloutside false -labelmargins {10 0 0 0}
			}
		}
		
		proc config_interfaceSystray {size} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: config_interfaceSystray \033\[0m \{$size\}"
			set lf_systray $::window(interface_nb2_cont).f_windowprop2.lf_systray
			set lf_manWindow $::window(interface_nb2_cont).f_windowprop2.lf_mainWindow
			$lf_systray.mb_systrayIcSize configure -text "$size\px"
			if {[winfo exists .tray]} {
				.tray configure -image $::icon_e(systray_icon$size)
				log_writeOutTv 0 "Changing systray icon size to $size"
			}
		}
		
		proc config_interfaceChangeTooltips {w} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: config_interfaceChangeTooltips \033\[0m \{$w\}"
			if {$::choice(cb_tooltip) == 1} {
				$w.cb_lf_tooltip_main state !disabled
				$w.cb_lf_tooltip_wizard state !disabled
				$w.cb_lf_tooltip_station state !disabled
				$w.cb_lf_tooltip_videocard state !disabled
				$w.cb_lf_tooltip_record state !disabled
			} else {
				$w.cb_lf_tooltip_main state disabled
				$w.cb_lf_tooltip_wizard state disabled
				$w.cb_lf_tooltip_station state disabled
				$w.cb_lf_tooltip_videocard state disabled
				$w.cb_lf_tooltip_record state disabled
			}
		}
		proc config_interfaceAlign {value cvar} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: config_interfaceAlign \033\[0m \{$value\} \{$cvar\}"
			set ::choice($cvar) [lreplace $::choice($cvar) 1 1 [lindex $value 1]]
			set ::config_int($cvar) [lindex $value 0]
		}
		proc config_interfaceMousew {window delta} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: config_interfaceMousew \033\[0m \{$window\} \{$delta\}"
			$window yview scroll [expr {-$delta/120}] units
		}
		proc default_opt6 {w1 w2 w3} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: default_opt6 \033\[0m \{$w1\} \{$w2\} \{$w3\}"
			log_writeOutTv 0 "Starting to collect data for interface section."
			
			set lf_systray $::window(interface_nb2_cont).f_windowprop2.lf_systray
			set lf_floatingCtrl $::window(interface_nb2_cont).f_windowprop2.lf_floatingCtrl
			set lf_manWindow $::window(interface_nb2_cont).f_windowprop2.lf_mainWindow
			set lf_osdStation $::window(interface_nb3_cont).f_osd2.lf_osd_station
			
			set ::choice(mbTheme) $::option(use_theme)
			set ::choice(cb_tooltip) $::option(tooltips)
			set ::choice(cb_tooltip_main) $::option(tooltips_main)
			set ::choice(cb_tooltip_wizard) $::option(tooltips_wizard)
			set ::choice(cb_tooltip_station) $::option(tooltips_editor)
			set ::choice(cb_tooltip_colorm) $::option(tooltips_colorm)
			set ::choice(cb_tooltip_record) $::option(tooltips_record)
			set ::choice(cb_splash) $::option(show_splash)
			set ::choice(cb_fullscr) $::option(window_full)
			set ::choice(cb_remGeom) $::option(window_remGeom)
			set ::choice(cb_floatMain) $::option(floatMain)
			set ::choice(cb_floatStation) $::option(floatStation)
			set ::choice(cb_floatPlay) $::option(floatPlay)
			set ::choice(cb_systray) $::option(systray)
			set ::choice(cb_systrayMini) $::option(systrayMini)
			set ::choice(cb_systrayClose) $::option(systrayClose)
			set ::choice(cb_systrayResize) $::option(systrayResize)
			set ::choice(mb_systrayIcSize) $::option(systrayIcSize)
			$lf_systray.mb_systrayIcSize configure -text $::option(systrayIcSize)\px
			set ::choice(osd_station_w) $::option(osd_station_w)
			set ::config_int(cb_osd_station_w) [lindex $::choice(osd_station_w) 0]
			if {"[lindex $::choice(osd_station_w) 2]" == "Regular"} {
				$lf_osdStation.b_osd_station_fnt_w configure -text "[lindex $::choice(osd_station_w) 1] | [lindex $::choice(osd_station_w) 3]"
			} else {
				$lf_osdStation.b_osd_station_fnt_w configure -text "[lindex $::choice(osd_station_w) 1] - [lindex $::choice(osd_station_w) 2] | [lindex $::choice(osd_station_w) 3]"
			}
			set ::choice(osd_station_f) $::option(osd_station_f)
			set ::config_int(cb_osd_station_f) [lindex $::choice(osd_station_f) 0]
			if {"[lindex $::choice(osd_station_f) 2]" == "Regular"} {
				$lf_osdStation.b_osd_station_fnt_f configure -text "[lindex $::choice(osd_station_f) 1] | [lindex $::choice(osd_station_f) 3]"
			} else {
				$lf_osdStation.b_osd_station_fnt_f configure -text "[lindex $::choice(osd_station_f) 1] - [lindex $::choice(osd_station_f) 2] | [lindex $::choice(osd_station_f) 3]"
			}
			set ::choice(osd_group_w) $::option(osd_group_w)
			set ::config_int(cb_osd_group_w) [lindex $::choice(osd_group_w) 0]
			if {"[lindex $::choice(osd_group_w) 2]" == "Regular"} {
				$::window(interface_nb3_cont).f_osd2.b_osd_group_fnt_w configure -text "[lindex $::choice(osd_group_w) 1] | [lindex $::choice(osd_group_w) 3]"
			} else {
				$::window(interface_nb3_cont).f_osd2.b_osd_group_fnt_w configure -text "[lindex $::choice(osd_group_w) 1] - [lindex $::choice(osd_group_w) 2] | [lindex $::choice(osd_group_w) 3]"
			}
			set ::choice(osd_group_f) $::option(osd_group_f)
			set ::config_int(cb_osd_group_f) [lindex $::choice(osd_group_f) 0]
			if {"[lindex $::choice(osd_group_f) 2]" == "Regular"} {
				$::window(interface_nb3_cont).f_osd2.b_osd_group_fnt_f configure -text "[lindex $::choice(osd_group_f) 1] | [lindex $::choice(osd_group_f) 3]"
			} else {
				$::window(interface_nb3_cont).f_osd2.b_osd_group_fnt_f configure -text "[lindex $::choice(osd_group_f) 1] - [lindex $::choice(osd_group_f) 2] | [lindex $::choice(osd_group_f) 3]"
			}
			set ::choice(osd_key_w) $::option(osd_key_w)
			set ::config_int(cb_osd_key_w) [lindex $::choice(osd_key_w) 0]
			if {"[lindex $::choice(osd_key_w) 2]" == "Regular"} {
				$::window(interface_nb3_cont).f_osd2.b_osd_key_fnt_w configure -text "[lindex $::choice(osd_key_w) 1] | [lindex $::choice(osd_key_w) 3]"
			} else {
				$::window(interface_nb3_cont).f_osd2.b_osd_key_fnt_w configure -text "[lindex $::choice(osd_key_w) 1] - [lindex $::choice(osd_key_w) 2] | [lindex $::choice(osd_key_w) 3]"
			}
			set ::choice(osd_key_f) $::option(osd_key_f)
			set ::config_int(cb_osd_key_f) [lindex $::choice(osd_key_f) 0]
			if {"[lindex $::choice(osd_key_f) 2]" == "Regular"} {
				$::window(interface_nb3_cont).f_osd2.b_osd_key_fnt_f configure -text "[lindex $::choice(osd_key_f) 1] | [lindex $::choice(osd_key_f) 3]"
			} else {
				$::window(interface_nb3_cont).f_osd2.b_osd_key_fnt_f configure -text "[lindex $::choice(osd_key_f) 1] - [lindex $::choice(osd_key_f) 2] | [lindex $::choice(osd_key_f) 3]"
			}
			set ::choice(osd_lirc) $::option(osd_lirc)
			if {"[lindex $::choice(osd_lirc) 2]" == "Regular"} {
				$::window(interface_nb3_cont).f_osd2.b_osd_lirc_fnt configure -text "[lindex $::choice(osd_lirc) 1] | [lindex $::choice(osd_lirc) 3]"
			} else {
				$::window(interface_nb3_cont).f_osd2.b_osd_lirc_fnt configure -text "[lindex $::choice(osd_lirc) 1] - [lindex $::choice(osd_lirc) 2] | [lindex $::choice(osd_lirc) 3]"
			}
			config_interfaceChangeTooltips $w1
			if {$::option(tooltips) == 1} {
				if {$::option(tooltips_wizard) == 1} {
					settooltip $::window(interface_nb1).mb_lf_theme [mc "Choose your preferred theme"]
					settooltip $::window(interface_nb1).cb_lf_tooltip [mc "Check this if you want to see tooltips"]
					settooltip $::window(interface_nb1).cb_lf_tooltip_main [mc "Tooltips for the main Interface"]
					settooltip $::window(interface_nb1).cb_lf_tooltip_wizard [mc "Tooltips for the preferences"]
					settooltip $::window(interface_nb1).cb_lf_tooltip_station [mc "Tooltips for the Station Editor"]
					settooltip $::window(interface_nb1).cb_lf_tooltip_videocard [mc "Tooltips for the Color Management"]
					settooltip $::window(interface_nb1).cb_lf_tooltip_record [mc "Tooltips for the Record Wizard"]
					settooltip $::window(interface_nb1).cb_lf_splash [mc "Check this if you want to see the splash screen at the start of TV-Viewer"]
					settooltip $lf_manWindow.cb_fullscr [mc "Start TV-Viewer in full-screen mode"]
					settooltip $lf_manWindow.cb_remGeom [mc "Remember window size and position"]
					settooltip $lf_floatingCtrl.cb_floatMain [mc "The floating control appears in fullscreen mode when the
mouse pointer is moved to the \"top\", of the screen."]
					settooltip $lf_floatingCtrl.cb_floatStation [mc "The floating control appears in fullscreen mode when the
mouse pointer is moved to the \"left side\", of the screen."]
					settooltip $lf_floatingCtrl.cb_floatPlay [mc "The floating control appears in fullscreen mode when the
mouse pointer is moved to the \"bottom\", of the screen."]
					settooltip $lf_systray.cb_systray [mc "Activate integration to system tray"]
					settooltip $lf_systray.cb_systray_mini [mc "Minimize to tray"]
					settooltip $lf_systray.cb_systrayClose [mc "Close to tray"]
					settooltip $lf_systray.cb_systrayResize [mc "Automatically resize system tray icon if the size of the tray 
itself is changed. Be careful with this option."]
					settooltip $lf_systray.mb_systrayIcSize [mc "Choose the size for the system tray icon"]
					settooltip $lf_osdStation.cb_osd_station_w [mc "OSD for station name in windowed mode"]
					settooltip $lf_osdStation.cb_osd_station_f [mc "OSD for station name in full-screen mode"]
					settooltip $lf_osdStation.b_osd_station_fnt_w [mc "Change font, color and alignment"]
					settooltip $lf_osdStation.b_osd_station_fnt_f [mc "Change font, color and alignment"]
					settooltip $w3.cb_osd_group_w [mc "OSD for Volume; Pan&Scan; Video input in windowed mode"]
					settooltip $w3.cb_osd_group_f [mc "OSD for Volume; Pan&Scan; Video input in full-screen mode"]
					settooltip $w3.b_osd_group_fnt_w [mc "Change font, color and alignment"]
					settooltip $w3.b_osd_group_fnt_f [mc "Change font, color and alignment"]
					settooltip $w3.cb_osd_key_w [mc "OSD for change stations via numbers input in windowed mode"]
					settooltip $w3.cb_osd_key_f [mc "OSD for change stations via numbers input in full-screen mode"]
					settooltip $w3.b_osd_key_fnt_w [mc "Change font, color and alignment"]
					settooltip $w3.b_osd_key_fnt_f [mc "Change font, color and alignment"]
					settooltip $w3.b_osd_lirc_fnt [mc "Change font, color and alignment"]
				} else {
					settooltip $::window(interface_nb1).mb_lf_theme {}
					settooltip $::window(interface_nb1).cb_lf_tooltip {}
					settooltip $::window(interface_nb1).cb_lf_tooltip_main {}
					settooltip $::window(interface_nb1).cb_lf_tooltip_wizard {}
					settooltip $::window(interface_nb1).cb_lf_tooltip_station {}
					settooltip $::window(interface_nb1).cb_lf_tooltip_videocard {}
					settooltip $::window(interface_nb1).cb_lf_tooltip_player {}
					settooltip $::window(interface_nb1).cb_lf_tooltip_record {}
					settooltip $::window(interface_nb1).cb_lf_splash {}
					settooltip $lf_manWindow.cb_fullscr {}
					settooltip $lf_manWindow.cb_remGeom {}
					settooltip $lf_floatingCtrl.cb_floatMain {}
					settooltip $lf_floatingCtrl.cb_floatStation {}
					settooltip $lf_floatingCtrl.cb_floatPlay {}
					settooltip $lf_systray.cb_systray {}
					settooltip $lf_systray.cb_systray_mini {}
					settooltip $lf_systray.cb_systrayClose {}
					settooltip $lf_systray.cb_systrayResize {}
					settooltip $lf_systray.mb_systrayIcSize {}
					settooltip $w3.cb_osd_station_w {}
					settooltip $w3.cb_osd_station_f {}
					settooltip $w3.b_osd_station_fnt_w {}
					settooltip $w3.b_osd_station_fnt_f {}
					settooltip $w3.cb_osd_group_w {}
					settooltip $w3.cb_osd_group_f {}
					settooltip $w3.b_osd_group_fnt_w {}
					settooltip $w3.b_osd_group_fnt_f {}
					settooltip $w3.cb_osd_key_w {}
					settooltip $w3.cb_osd_key_f {}
					settooltip $w3.b_osd_key_fnt_w {}
					settooltip $w3.b_osd_key_fnt_f {}
					settooltip $w3.b_osd_lirc_fnt {}
				}
			}
		}
		proc stnd_opt6 {w1 w2 w3} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: stnd_opt6 \033\[0m \{$w1\} \{$w2\} \{$w3\}"
			log_writeOutTv 1 "Setting interface options to default."
			
			set lf_systray $::window(interface_nb2_cont).f_windowprop2.lf_systray
			set lf_floatingCtrl $::window(interface_nb2_cont).f_windowprop2.lf_floatingCtrl
			set lf_manWindow $::window(interface_nb2_cont).f_windowprop2.lf_mainWindow
			set lf_osdStation $::window(interface_nb3_cont).f_osd2.lf_osd_station
			
			set ::choice(mbTheme) $::stnd_opt(use_theme)
			config_interfaceTheme $::stnd_opt(use_theme)
			set ::choice(cb_tooltip) $::stnd_opt(tooltips)
			set ::choice(cb_tooltip_main) $::stnd_opt(tooltips_main)
			set ::choice(cb_tooltip_wizard) $::stnd_opt(tooltips_wizard)
			set ::choice(cb_tooltip_station) $::stnd_opt(tooltips_editor)
			set ::choice(cb_tooltip_colorm) $::stnd_opt(tooltips_colorm)
			set ::choice(cb_tooltip_record) $::stnd_opt(tooltips_record)
			set ::choice(cb_splash) $::stnd_opt(show_splash)
			set ::choice(cb_fullscr) $::stnd_opt(window_full)
			set ::choice(cb_remGeom) $::stnd_opt(window_remGeom)
			set ::choice(cb_floatMain) $::stnd_opt(floatMain)
			set ::choice(cb_floatStation) $::stnd_opt(floatStation)
			set ::choice(cb_floatPlay) $::stnd_opt(floatPlay)
			set ::choice(cb_systray) $::stnd_opt(systray)
			set ::choice(cb_systrayMini) $::stnd_opt(systrayMini)
			set ::choice(cb_systrayClose) $::stnd_opt(systrayClose)
			set ::choice(cb_systrayResize) $::stnd_opt(systrayResize)
			set ::choice(mb_systrayIcSize) $::stnd_opt(systrayIcSize)
			$lf_systray.mb_systrayIcSize configure -text $::stnd_opt(systrayIcSize)\px
			set ::choice(osd_station_w) $::stnd_opt(osd_station_w)
			set ::config_int(cb_osd_station_w) [lindex $::choice(osd_station_w) 0]
			if {"[lindex $::choice(osd_station_w) 2]" == "Regular"} {
				$lf_osdStation.b_osd_station_fnt_w configure -text "[lindex $::choice(osd_station_w) 1] | [lindex $::choice(osd_station_w) 3]"
			} else {
				$lf_osdStation.b_osd_station_fnt_w configure -text "[lindex $::choice(osd_station_w) 1] - [lindex $::choice(osd_station_w) 2] | [lindex $::choice(osd_station_w) 3]"
			}
			set ::choice(osd_station_f) $::stnd_opt(osd_station_f)
			set ::config_int(cb_osd_station_f) [lindex $::choice(osd_station_f) 0]
			if {"[lindex $::choice(osd_station_f) 2]" == "Regular"} {
				$lf_osdStation.b_osd_station_fnt_f configure -text "[lindex $::choice(osd_station_f) 1] | [lindex $::choice(osd_station_f) 3]"
			} else {
				$lf_osdStation.b_osd_station_fnt_f configure -text "[lindex $::choice(osd_station_f) 1] - [lindex $::choice(osd_station_f) 2] | [lindex $::choice(osd_station_f) 3]"
			}
			set ::choice(osd_group_w) $::stnd_opt(osd_group_w)
			set ::config_int(cb_osd_group_w) [lindex $::choice(osd_group_w) 0]
			if {"[lindex $::choice(osd_group_w) 2]" == "Regular"} {
				$::window(interface_nb3_cont).f_osd2.b_osd_group_fnt_w configure -text "[lindex $::choice(osd_group_w) 1] | [lindex $::choice(osd_group_w) 3]"
			} else {
				$::window(interface_nb3_cont).f_osd2.b_osd_group_fnt_w configure -text "[lindex $::choice(osd_group_w) 1] - [lindex $::choice(osd_group_w) 2] | [lindex $::choice(osd_group_w) 3]"
			}
			set ::choice(osd_group_f) $::stnd_opt(osd_group_f)
			set ::config_int(cb_osd_group_f) [lindex $::choice(osd_group_f) 0]
			if {"[lindex $::choice(osd_group_f) 2]" == "Regular"} {
				$::window(interface_nb3_cont).f_osd2.b_osd_group_fnt_f configure -text "[lindex $::choice(osd_group_f) 1] | [lindex $::choice(osd_group_f) 3]"
			} else {
				$::window(interface_nb3_cont).f_osd2.b_osd_group_fnt_f configure -text "[lindex $::choice(osd_group_f) 1] - [lindex $::choice(osd_group_f) 2] | [lindex $::choice(osd_group_f) 3]"
			}
			set ::choice(osd_key_w) $::stnd_opt(osd_key_w)
			set ::config_int(cb_osd_key_w) [lindex $::choice(osd_key_w) 0]
			if {"[lindex $::choice(osd_key_w) 2]" == "Regular"} {
				$::window(interface_nb3_cont).f_osd2.b_osd_key_fnt_w configure -text "[lindex $::choice(osd_key_w) 1] | [lindex $::choice(osd_key_w) 3]"
			} else {
				$::window(interface_nb3_cont).f_osd2.b_osd_key_fnt_w configure -text "[lindex $::choice(osd_key_w) 1] - [lindex $::choice(osd_key_w) 2] | [lindex $::choice(osd_key_w) 3]"
			}
			set ::choice(osd_key_f) $::stnd_opt(osd_key_f)
			set ::config_int(cb_osd_key_f) [lindex $::choice(osd_key_f) 0]
			if {"[lindex $::choice(osd_key_f) 2]" == "Regular"} {
				$::window(interface_nb3_cont).f_osd2.b_osd_key_fnt_f configure -text "[lindex $::choice(osd_key_f) 1] | [lindex $::choice(osd_key_f) 3]"
			} else {
				$::window(interface_nb3_cont).f_osd2.b_osd_key_fnt_f configure -text "[lindex $::choice(osd_key_f) 1] - [lindex $::choice(osd_key_f) 2] | [lindex $::choice(osd_key_f) 3]"
			}
			set ::choice(osd_lirc) $::stnd_opt(osd_lirc)
			if {"[lindex $::choice(osd_lirc) 2]" == "Regular"} {
				$::window(interface_nb3_cont).f_osd2.b_osd_lirc_fnt configure -text "[lindex $::choice(osd_lirc) 1] | [lindex $::choice(osd_lirc) 3]"
			} else {
				$::window(interface_nb3_cont).f_osd2.b_osd_lirc_fnt configure -text "[lindex $::choice(osd_lirc) 1] - [lindex $::choice(osd_lirc) 2] | [lindex $::choice(osd_lirc) 3]"
			}
			config_interfaceChangeTooltips $w1
		}
		default_opt6 $::window(interface_nb1) $::window(interface_nb2) $frame_nb3
	}
}
