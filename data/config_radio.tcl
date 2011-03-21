#       config_radio.tcl
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

proc option_screen_5 {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: option_screen_5 \033\[0m"
	
	# Setting up the interface
	
	foreach tab [split [.config_wizard.frame_configoptions.nb tabs]] {
		.config_wizard.frame_configoptions.nb hide $tab
	}
	
	if {[winfo exists .config_wizard.frame_configoptions.nb.f_radio]} {
		.config_wizard.frame_configoptions.nb add $::window(radio_nb1)
		.config_wizard.frame_configoptions.nb select $::window(radio_nb1)
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt5 $::window(radio_nb1)]
	} else {
		log_writeOutTv 0 "Setting up radio section in preferences."
		set w .config_wizard.frame_configoptions.nb
		set ::window(radio_nb1) [ttk::frame $w.f_radio]
		$w add $::window(radio_nb1) -text [mc "Radio Settings"] -padding 2
		ttk::label $::window(radio_nb1).l_dvb_more -text [mc "Expect more soon"]
		
		grid columnconfigure $::window(radio_nb1) 0 -weight 1
		
		grid $::window(radio_nb1).l_dvb_more -in $::window(radio_nb1) -row 0 -column 0 -pady 3
		
		# Additional Code
		
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt5 $::window(radio_nb1)]
		
		# Subprocs
		
		proc default_opt5 {w} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: default_opt5 \033\[0m \{$w\}"
			# Nothing to do yet
			log_writeOutTv 0 "Starting to collect data for radio section."
		}
		proc stnd_opt5 {w} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: stnd_opt5 \033\[0m \{$w\}"
			# Nothing to do yet
			log_writeOutTv 1 "Setting radio options to default."
		}
	}
}
