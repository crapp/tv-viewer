#       config_general.tcl
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

proc option_screen_0 {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: option_screen_0 \033\[0m"
	# Setting up the interface
	# general section of the preferences
	
	foreach tab [split [.config_wizard.frame_configoptions.nb tabs]] {
		.config_wizard.frame_configoptions.nb hide $tab
	}
	
	if {[winfo exists .config_wizard.frame_configoptions.nb.f_general]} {
		.config_wizard.frame_configoptions.nb add $::window(general_nb1)
		.config_wizard.frame_configoptions.nb select $::window(general_nb1)
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt0 $::window(general_nb1)]
	} else {
		log_writeOut ::log(tvAppend) 0 "Setting up general section in preferences"
		set w .config_wizard.frame_configoptions.nb
		set ::window(general_nb1) [ttk::frame $w.f_general]
		$w add $::window(general_nb1) -text [mc "General Settings"] -padding 2
		ttk::labelframe $::window(general_nb1).lf_language -text [mc "Language"]
		ttk::menubutton $::window(general_nb1).mb_lf_language -menu $::window(general_nb1).mbLanguage -textvariable choice(mbLanguage)
		ttk::labelframe $::window(general_nb1).lf_starttv -text [mc "Start TV on startup"]
		ttk::checkbutton $::window(general_nb1).cb_lf_starttv -text [mc "Enable"] -variable choice(checkbutton_starttv)
		ttk::checkbutton $::window(general_nb1).cb_lf_newsreader -text [mc "Newsreader"] -variable choice(checkbutton_newsreader) -command [list config_generalNewsreaderChange $::window(general_nb1)]
		ttk::labelframe $::window(general_nb1).lf_newsreader -labelwidget $::window(general_nb1).cb_lf_newsreader
		ttk::label $::window(general_nb1).l_lf_newsreader -text [mc "Time interval in days"]
		spinbox $::window(general_nb1).sb_newsreader -width 4 -from 1 -to 30 -validate key -vcmd {string is integer %P} -textvariable choice(sb_newsreader)
		ttk::labelframe $::window(general_nb1).lf_epg -text [mc "Electronic Program Guide"]
		ttk::label $::window(general_nb1).l_lf_epg -text [mc "Choose a program"]
		ttk::entry $::window(general_nb1).e_lf_epg -textvariable choice(entry_epg) -takefocus 0
		ttk::button $::window(general_nb1).b_lf_epg -text "..." -width 3 -command [list config_generalChooseEpg $::window(general_nb1)]
		
		grid columnconfigure $::window(general_nb1) 0 -weight 1
		grid columnconfigure $::window(general_nb1).lf_language 0 -minsize 120
		
		grid $::window(general_nb1).lf_language -in $::window(general_nb1) -row 1 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(general_nb1).mb_lf_language -in $::window(general_nb1).lf_language -row 1 -column 0 -sticky ew -padx 7 -pady 3
		grid $::window(general_nb1).lf_starttv -in $::window(general_nb1) -row 2 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(general_nb1).cb_lf_starttv -in $::window(general_nb1).lf_starttv -row 0 -column 0 -padx "7 0" -pady 3
		grid $::window(general_nb1).lf_newsreader -in $::window(general_nb1) -row 3 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(general_nb1).l_lf_newsreader -in $::window(general_nb1).lf_newsreader -row 0 -column 0 -padx 7 -pady 3
		grid $::window(general_nb1).sb_newsreader -in $::window(general_nb1).lf_newsreader -row 0 -column 1 -pady 3
		grid $::window(general_nb1).lf_epg -in $::window(general_nb1) -row 4 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $::window(general_nb1).l_lf_epg -in $::window(general_nb1).lf_epg -row 0 -column 0 -padx 7 -pady 3
		grid $::window(general_nb1).e_lf_epg -in $::window(general_nb1).lf_epg -row 0 -column 1 -pady 3
		grid $::window(general_nb1).b_lf_epg -in $::window(general_nb1).lf_epg -row 0 -column 2 -padx "7 0" -pady 3
		
		# Additional Code
		
		.config_wizard.frame_buttons.b_default configure -command [list stnd_opt0 $::window(general_nb1)]
		
		# Subprocs
		proc config_generalLangs {men} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: config_generalLangs \033\[0m \{$men\}"
			$men add radiobutton -variable choice(mbLanguage) -command {set ::choice(mbLanguage_value) 0; msgcat::mclocale $::env(LANG); catch {msgcat::mcload $::option(root)/msgs}} -label [mc "Autodetect"]
			#Open ISO file with language codes
			if {[file exists "$::option(root)/msgs/ISO-639-2_utf-8.txt"]} {
				set openLC [open "$::option(root)/msgs/ISO-639-2_utf-8.txt" r]
				while {[gets $openLC line]!=-1} {
					if {[string match #* $line] || [string trim $line] == {}} {
						continue
					}
					array set lCodes [split $line "|"]
				}
				if {[array exists lCodes]} {
					set filelist_msg [lsort [glob -directory "$::option(root)/msgs" *.msg]]
					foreach msgFile $filelist_msg {
						set fName [lindex [file split [file rootname $msgFile]] end]
						if {[string trim [array get lCodes $fName]] != {}} {
							$men add radiobutton -variable choice(mbLanguage) -command "set ::choice(mbLanguage_value) $fName; msgcat::mclocale $fName; catch {msgcat::mcload $::option(root)/msgs}" -label "$lCodes($fName) ($fName)"
						}
					}
				}
			} else {
				log_writeOut ::log(tvAppend) 2 "Ca not read file containing language codes. Only autodetect will be available"
			}
		}
		
		proc config_generalLangsVars {handler} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: config_generalLangs \033\[0m \{$handler\}"
			#handler: 0 default; 1 standard
			if {$handler == 0} {
				set opt option
			} else {
				set opt stnd_opt
			}
			set ::choice(mbLanguage_value) [set ::[set opt](language_value)]
			if {$::option(language_value) == 0} {
				set ::choice(mbLanguage) [mc "Autodetect"]
			} else {
				set ::choice(mbLanguage) [set ::[set opt](language)]
			}
		}
		
		proc config_generalNewsreaderChange {w} {
			#Change state of all widgets in labelframe
			puts $::main(debug_msg) "\033\[0;1;33mDebug: config_generalNewsreaderChange \033\[0m \{$w\}"
			if {$::choice(checkbutton_newsreader) == 0} {
				$w.sb_newsreader configure -state disabled
				$w.l_lf_newsreader state disabled
			} else {
				$w.sb_newsreader configure -state normal
				$w.l_lf_newsreader state !disabled
			}
		}
		proc config_generalChooseEpg {w} {
			#Choose epg application
			puts $::main(debug_msg) "\033\[0;1;33mDebug: config_generalChooseEpg \033\[0m \{$w\}"
			wm protocol .config_wizard WM_DELETE_WINDOW " "
			set ::choice(entry_epg) [ttk::getOpenFile -parent .config_wizard -title [mc "Choose an EPG application"] -initialfile $::choice(entry_epg) -initialdir [file dirname $::choice(entry_epg)]]
			wm protocol .config_wizard WM_DELETE_WINDOW [list config_wizardExit .config_wizard.frame_configbox.listbox_clist .config_wizard.frame_configoptions.nb]
			if {[string trim $::choice(entry_epg)] == {}} {
				set ::choice(entry_epg) [subst $::stnd_opt(epg_command)]
			}
			log_writeOut ::log(tvAppend) 0 "Chosen epg program $::choice(entry_epg)"
		}
		proc default_opt0 {w} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: default_opt0 \033\[0m \{$w\}"
			log_writeOut ::log(tvAppend) 0 "Starting to collect data for general section."
			menu $::window(general_nb1).mbLanguage -tearoff 0
			config_generalLangs $::window(general_nb1).mbLanguage
			config_generalLangsVars 0
			set ::choice(checkbutton_starttv) $::option(starttv_startup)
			set ::choice(checkbutton_newsreader) $::option(newsreader)
			set ::choice(sb_newsreader) $::option(newsreader_interval)
			set ::choice(entry_epg) [subst $::option(epg_command)]
			config_generalNewsreaderChange $w
			if {$::option(tooltips) == 1} {
				if {$::option(tooltips_wizard) == 1} {
					settooltip $::window(general_nb1).mb_lf_language [mc "Choose your language.
You'll need to restart TV-Viewer for changes to take effect."]
					settooltip $::window(general_nb1).cb_lf_starttv [mc "Autostart tv playback on program start"]
					settooltip $::window(general_nb1).cb_lf_newsreader [mc "Activate Newsreader.
The Newsreader will check for news about TV-Viewer."]
					settooltip $::window(general_nb1).sb_newsreader [mc "Choose time intervall in days for Newsreader (1-30)"]
					settooltip $::window(general_nb1).e_lf_epg [mc "Specify a program to retrieve the television program"]
					settooltip $::window(general_nb1).b_lf_epg [mc "Specify a program to retrieve the television program"]
				} else {
					settooltip $::window(general_nb1).mb_lf_language {}
					settooltip $::window(general_nb1).cb_lf_starttv {}
					settooltip $::window(general_nb1).cb_lf_newsreader {}
					settooltip $::window(general_nb1).sb_newsreader {}
					settooltip $::window(general_nb1).e_lf_epg {}
					settooltip $::window(general_nb1).b_lf_epg {}
				}
			}
		}
		proc stnd_opt0 {w} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: stnd_opt0 \033\[0m \{$w\}"
			log_writeOut ::log(tvAppend) 1 "Setting general options to default."
			config_generalLangsVars 1
			msgcat::mclocale $::env(LANG); catch {msgcat::mcload $::option(root)/msgs}
			set ::choice(checkbutton_starttv) $::stnd_opt(starttv_startup)
			set ::choice(checkbutton_newsreader) $::stnd_opt(newsreader)
			set ::choice(sb_newsreader) $::stnd_opt(newsreader_interval)
			set ::choice(entry_epg) [subst $::stnd_opt(epg_command)]
			config_generalNewsreaderChange $w
		}
		default_opt0 $::window(general_nb1)
	}
}
