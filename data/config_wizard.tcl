#       config_wizard.tcl
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

proc config_wizardMainUi {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: config_wizardMainUi \033\[0m"
	if {[winfo exists .config_wizard]} return
	if {[winfo exists .tray] == 1} {
		if {[winfo ismapped .] == 0} {
			log_writeOutTv 1 "User attempted to start preferences while main is docked."
			log_writeOutTv 1 "Will undock main."
			 main_systemTrayToggle
		}
	}
	
	if {[wm attributes . -fullscreen] == 1} {
		tv_wmFullscreen . .ftvBg.cont .ftvBg
	}
	tv_playbackStop 1 pic
	log_writeOutTv 0 "Starting preferences..."
	
	# Setting up the interface
	
	set w [toplevel .config_wizard]
	
	place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
	
	#~ foreach sy [split [lsort [ttk::style theme names]]] {
		#~ ttk::style theme settings $sy {
			#~ ttk::style layout Plain.TNotebook.Tab null
		#~ }
	#~ }
	#ttk::frame $wfopt; place [ttk::label $wfopt.bg -style Toolbutton] -relwidth 1 -relheight 1
	set wfbox [ttk::frame $w.frame_configbox]
	
	set wfcopt [ttk::frame $w.frame_configoptions]
	set wfbtn [ttk::frame $w.frame_buttons -style TLabelframe]
	
	#FIXME Strange way of setting some font, why?
	listbox $wfbox.listbox_clist \
	-font -*-*-Bold-R-Normal-*-*-100-*-*-*-*-*-* \
	-width 0 \
	-height 0
	
	ttk::button $wfbtn.button_save \
	-text [mc "Apply"] \
	-command config_wizardSaveopts \
	-compound left \
	-image $::icon_s(dialog-ok-apply)
	
	ttk::button $wfbtn.b_default \
	-text [mc "Default"]
	
	ttk::button $wfbtn.button_quit \
	-text [mc "Cancel"] \
	-command config_wizardExit \
	-compound left \
	-image $::icon_s(dialog-cancel)
	
	ttk::notebook $wfcopt.nb
	
	grid rowconfigure $wfbox 0 -weight 1
	grid rowconfigure $wfcopt 0 -weight 1 -minsize 270
	grid columnconfigure $wfbox 0 -weight 1
	grid columnconfigure $wfcopt 0 -weight 1 -minsize 470
	
	grid $wfbox -in $w -row 0 -column 0 \
	-sticky nesw \
	-padx 5 \
	-pady 5
	grid $wfcopt -in $w -row 0 -column 1 \
	-sticky nesw \
	-padx 5 \
	-pady 5
	grid $wfbtn -in $w -row 1 -column 0 \
	-sticky ew \
	-columnspan 2 \
	-padx 3\
	-pady 3
	
	grid anchor $wfbtn e
	grid $wfbox.listbox_clist -in $wfbox -row 0 -column 0 \
	-sticky nesw
	grid $wfbtn.button_save -in $wfbtn -row 0 -column 0 \
	-padx "0 3" \
	-pady 7
	grid $wfbtn.b_default -in $wfbtn -row 0 -column 1 \
	-sticky ns \
	-pady 7
	grid $wfbtn.button_quit -in $wfbtn -row 0 -column 2 \
	-padx 3 \
	-pady 7
	grid $wfcopt.nb -in $wfcopt -row 0 -column 0 \
	-sticky nesw
	
	# Additional Code
	
	set conf_opts [list [mc "General"] [mc "Analog"] [mc "DVB"] [mc "Video"] [mc "Audio"] [mc "Radio"] [mc "Interface"] [mc "Record"] [mc "Advanced"]]
	
	foreach config_option [split $conf_opts] {
		$wfbox.listbox_clist insert end " $config_option"
	}
	bind $wfbox.listbox_clist <<ListboxSelect>> {config_wizardListbox}
	bind $w <Control-Key-x> {config_wizardExit}
	bind $w <Key-F1> [list info_helpHelp]
	
	$wfbox.listbox_clist selection set 0
	$wfbox.listbox_clist activate 0
	
	wm resizable $w 0 0
	wm protocol $w WM_DELETE_WINDOW config_wizardExit
	wm title $w [mc "Preferences"]
	wm iconphoto $w $::icon_b(settings)
	wm transient $w .
	
	config_wizardReadSettings
	
	settooltip $wfbtn.button_save [mc "Apply your changes and exit preferences dialog."]
	settooltip $wfbtn.b_default [mc "Load default values, for the corresponding section."]
	settooltip $wfbtn.button_quit [mc "Discard changes and close preferences dialog."]
	
	set ::config(rec_running) 0
	set status_time [monitor_partRunning 4]
	set status_record [monitor_partRunning 3]
	if {[lindex $status_time 0] == 1 || [lindex $status_record 0] == 1 } {
		log_writeOutTv 1 "There is a running recording/timeshift."
		log_writeOutTv 1 "Disabling analog settings."
		set ::config(rec_running) 1
	}
	
	option_screen_1
	option_screen_2
	option_screen_3
	option_screen_4
	option_screen_5
	option_screen_6
	option_screen_7
	option_screen_8
	option_screen_0
	
	if {$::option(systray_close) == 1} {
		wm protocol . WM_DELETE_WINDOW {  }
	}
	
	tkwait visibility $w
	grab $w
}

proc config_wizardListbox {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: config_wizardListbox \033\[0m"
	set wfopt .config_wizard.frame_optionsbar
	set wfbox .config_wizard.frame_configbox
	set wfcopt .config_wizard.frame_configoptions
	set get_lb_index [$wfbox.listbox_clist curselection]
	set get_lb_content [$wfbox.listbox_clist get $get_lb_index]
	option_screen_$get_lb_index
}

proc config_wizardExit {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: config_wizardExit \033\[0m"
	log_writeOutTv 0 "Closing preferences dialog and reread configuration."
	
	main_readConfig
	
	if {$::config(rec_running) == 0} {
		if {$::option(forcevideo_standard) == 1} {
			main_pic_streamForceVideoStandard
		}
		
		main_pic_streamDimensions
		
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
	
	tooltips .ftoolb_Top .ftoolb_Station .ftoolb_Bot main
	
	#FIXME No longer close to tray, this needs to be reworked probably.
	if {$::option(systray_close) == 1} {
		#~ wm protocol . WM_DELETE_WINDOW {main_systemTrayTogglePre}
	} else {
		#~ 
	}
	wm protocol . WM_DELETE_WINDOW [list event generate . <<exit>>]
	
	grab release .config_wizard
	destroy .config_wizard
}

proc config_wizardSaveopts {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: config_wizardSaveopts \033\[0m"
	log_writeOutTv 0 "Saving configuration values to $::option(home)/config/tv-viewer.conf"
	if {[file exists "$::option(home)/config/tv-viewer.conf"]} {
		file delete "$::option(home)/config/tv-viewer.conf"
	}
	set config_file_open [open "$::option(home)/config/tv-viewer.conf" w]
	puts $config_file_open "#TV-Viewer config file. File is generated automatically, do not edit manually."
	close $config_file_open
	set config_file_open [open "$::option(home)/config/tv-viewer.conf" a]
	puts $config_file_open "
#General settings
"
	foreach {okey oelem} [array get ::choice] {
		if {[string trim [array names ::opt_choiceGeneral $okey]] != {}} {
			puts $config_file_open "$::opt_choiceGeneral($okey) \{$oelem\}"
		}
	}
puts $config_file_open "
#Analog settings
"
	foreach {okey oelem} [array get ::choice] {
		if {[string trim [array names ::opt_choiceAnalog $okey]] != {}} {
			puts $config_file_open "$::opt_choiceAnalog($okey) \{$oelem\}"
		}
	}
	puts $config_file_open "
#Stream settings
"
	foreach {okey oelem} [array get ::choice] {
		if {[string trim [array names ::opt_choiceStream $okey]] != {}} {
			puts $config_file_open "$::opt_choiceStream($okey) \{$oelem\}"
		}
	}
	puts $config_file_open "
#Video settings
"
	foreach {okey oelem} [array get ::choice] {
		if {[string trim [array names ::opt_choiceVideo $okey]] != {}} {
			puts $config_file_open "$::opt_choiceVideo($okey) \{$oelem\}"
		}
	}
	puts $config_file_open "
#Interface settings
"
	foreach {okey oelem} [array get ::choice] {
		if {[string trim [array names ::opt_choiceInterface $okey]] != {}} {
			puts $config_file_open "$::opt_choiceInterface($okey) \{$oelem\}"
		}
	}
	puts $config_file_open "
#OSD settings
"
	foreach {okey oelem} [array get ::choice] {
		if {[string trim [array names ::opt_choiceOsd $okey]] != {}} {
			puts $config_file_open "$::opt_choiceOsd($okey) \{$oelem\}"
		}
	}
	puts $config_file_open "
#Recording / timeshift settings
"
	foreach {okey oelem} [array get ::choice] {
		if {[string trim [array names ::opt_choiceRec $okey]] != {}} {
			puts $config_file_open "$::opt_choiceRec($okey) \{$oelem\}"
		}
	}
	puts $config_file_open "
#Logfile settings
"
	foreach {okey oelem} [array get ::choice] {
		if {[string trim [array names ::opt_choiceLog $okey]] != {}} {
			puts $config_file_open "$::opt_choiceLog($okey) \{$oelem\}"
		}
	}
	puts $config_file_open "
#Videocard controls (hue / saturation / brightness / contrast)
"
	if {[string trim [array get ::option hue]] != {}} {
		puts $config_file_open "hue \{$::option(hue)\}"
	}
	if {[string trim [array get ::option saturation]] != {}} {
		puts $config_file_open "saturation \{$::option(saturation)\}"
	}
	if {[string trim [array get ::option brightness]] != {}} {
		puts $config_file_open "brightness \{$::option(brightness)\}"
	}
	if {[string trim [array get ::option contrast]] != {}} {
		puts $config_file_open "contrast \{$::option(contrast)\}"
	}
	close $config_file_open
	set status [monitor_partRunning 2]
	if {[lindex $status 0] == 1} {
		command_WritePipe 0 "tv-viewer_scheduler scheduler_Init 1"
	}
	config_wizardExit
}
