#       config_dvb.tcl
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

proc option_screen_2 {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: option_screen_2 \033\[0m"
	
	# Setting up the interface
	
	foreach tab [split [.config_wizard.frame_configoptions.nb tabs]] {
		.config_wizard.frame_configoptions.nb hide $tab
	}
	
	if {[winfo exists .config_wizard.frame_configoptions.nb.f_dvb]} {
		.config_wizard.frame_configoptions.nb add $::window(dvb_nb1)
		.config_wizard.frame_configoptions.nb select $::window(dvb_nb1)
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt2 $::window(dvb_nb1)]
	} else {
		log_writeOutTv 0 "Setting up dvb section in preferences"
		set w .config_wizard.frame_configoptions.nb
		set ::window(dvb_nb1) [ttk::frame $w.f_dvb]
		$w add $::window(dvb_nb1) -text [mc "DVB Settings"] -padding 2
		ttk::label $::window(dvb_nb1).l_dvb_more -text [mc "Expect more soon"]
		
		grid columnconfigure $::window(dvb_nb1) 0 -weight 1
		
		grid $::window(dvb_nb1).l_dvb_more -in $::window(dvb_nb1) -row 0 -column 0 -padx 5
		
		#Additional Code
		
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt2 $::window(dvb_nb1)]
		
		proc default_opt2 {w} {
			#Find and values for dvb section 
			puts $::main(debug_msg) "\033\[0;1;33mDebug: default_opt2 \033\[0m \{$w\}"
			log_writeOutTv 0 "Starting to collect data for dvb section."
			# Nothing to do yet
		}
		
		proc stnd_opt2 {w} {
			#Setting defaults for dvb section 
			puts $::main(debug_msg) "\033\[0;1;33mDebug: stnd_opt2 \033\[0m \{$w\}"
			log_writeOutTv 1 "Setting dvb options to default."
		}
	}
}
