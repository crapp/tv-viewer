#       colorm.tcl
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

proc colorm_readValues {wfscale} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: colorm_readValues \033\[0m \{$wfscale\}"
	#Read all standard values for hue, bridhtness, saturation and
	#contrast from the video device using v4l2-ctl.
	#The values will be stored in different arrays.
	#FIXME Divide this up in several procs for readability. 
	tkwait visibility .cm
	catch {exec v4l2-ctl --device=$::option(video_device) -l} read_v4l2ctl
	set status_v4l2ctl [catch {agrep -w "$read_v4l2ctl" hue} hue_default_read]
	if {$status_v4l2ctl == 0} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=hue} check_hue_available
		if { "[string tolower [lindex $check_hue_available 0]]" == "hue:" } {
			array set ::colorm_hue [split [string trim $hue_default_read] { =}]
			log_writeOut ::log(tvAppend) 0 "Default value for hue: $::colorm_hue(default)"
			$wfscale.s_hue configure -from $::colorm_hue(min) -to $::colorm_hue(max)
		} else {
			log_writeOut ::log(tvAppend) 2 "Can't read default value for hue."
			log_writeOut ::log(tvAppend) 2 "Error message: $hue_default_read"
			$wfscale.s_hue state disabled
			$wfscale.l_hue state disabled
		}
	} else {
		log_writeOut ::log(tvAppend) 2 "Can't read default value for hue."
		log_writeOut ::log(tvAppend) 2 "Error message: $hue_default_read"
		$wfscale.s_hue state disabled
		$wfscale.l_hue state disabled
	}
	catch {exec v4l2-ctl --device=$::option(video_device) -l} read_v4l2ctl
	set status_v4l2ctl [catch {agrep -w "$read_v4l2ctl" saturation} saturation_default_read]
	if {$status_v4l2ctl == 0} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=saturation} check_saturation_available
		if { "[string tolower [lindex $check_saturation_available 0]]" == "saturation:" } {
			split [string trim $saturation_default_read] { =}
			array set ::colorm_saturation [split [string trim $saturation_default_read] { =}]
			log_writeOut ::log(tvAppend) 0 "Default value for saturation: $::colorm_saturation(default)"
			$wfscale.s_saturation configure -from $::colorm_saturation(min) -to $::colorm_saturation(max)
		} else {
			log_writeOut ::log(tvAppend) 2 "Can't read default value for saturation."
			log_writeOut ::log(tvAppend) 2 "Error message: $saturation_default_read"
			$wfscale.s_saturation state disabled
			$wfscale.l_saturation state disabled
		}
	} else {
		log_writeOut ::log(tvAppend) 2 "Can't read default value for saturation."
		log_writeOut ::log(tvAppend) 2 "Error message: $saturation_default_read"
		$wfscale.s_saturation state disabled
		$wfscale.l_saturation state disabled
	}
	catch {exec v4l2-ctl --device=$::option(video_device) -l} read_v4l2ctl
	set status_v4l2ctl [catch {agrep -w "$read_v4l2ctl" contrast} contrast_default_read]
	if {$status_v4l2ctl == 0} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=contrast} check_contrast_available
		if { "[string tolower [lindex $check_contrast_available 0]]" == "contrast:" } {
			split [string trim $contrast_default_read] { =}
			array set ::colorm_contrast [split [string trim $contrast_default_read] { =}]
			log_writeOut ::log(tvAppend) 0 "Default value for contrast: $::colorm_contrast(default)"
			$wfscale.s_contrast configure -from $::colorm_contrast(min) -to $::colorm_contrast(max)
		} else {
			log_writeOut ::log(tvAppend) 2 "Can't read default value for contrast."
			log_writeOut ::log(tvAppend) 2 "Error message: $contrast_default_read"
			$wfscale.s_contrast state disabled
			$wfscale.l_contrast state disabled
		}
	} else {
		log_writeOut ::log(tvAppend) 2 "Can't read default value for contrast."
		log_writeOut ::log(tvAppend) 2 "Error message: $contrast_default_read"
		$wfscale.s_contrast state disabled
		$wfscale.l_contrast state disabled
	}
	catch {exec v4l2-ctl --device=$::option(video_device) -l} read_v4l2ctl
	set status_v4l2ctl [catch {agrep -w "$read_v4l2ctl" brightness} brightness_default_read]
	if {$status_v4l2ctl == 0} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=brightness} check_brightness_available
		if { "[string tolower [lindex $check_brightness_available 0]]" == "brightness:" } {
			split [string trim $brightness_default_read] { =}
			array set ::colorm_brightness [split [string trim $brightness_default_read] { =}]
			log_writeOut ::log(tvAppend) 0 "Default value for brightness: $::colorm_brightness(default)"
			$wfscale.s_brightness configure -from $::colorm_brightness(min) -to $::colorm_brightness(max)
		} else {
			log_writeOut ::log(tvAppend) 2 "Can't read default value for brightness."
			log_writeOut ::log(tvAppend) 2 "Error message: $brightness_default_read"
			$wfscale.s_brightness state disabled
			$wfscale.l_brightness state disabled
		}
	} else {
		log_writeOut ::log(tvAppend) 2 "Can't read default value for brightness."
		log_writeOut ::log(tvAppend) 2 "Error message: $brightness_default_read"
		$wfscale.s_brightness state disabled
		$wfscale.l_brightness state disabled
	}
	if {[info exists ::option(hue)] == 0} {
		if {[array exists ::colorm_hue]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=hue} hue_read
			foreach {id wert} [split $hue_read] {
				$wfscale.s_hue configure -value $wert
				update
				set ::colorm(l_hue_value) $wert
				set ::colorm(hue_old) $wert
				place $wfscale.l_hue_value -x [lindex [$wfscale.s_hue coords] 0] -rely 0 -anchor s -in $wfscale.s_hue
			}
		}
	} else {
		$wfscale.s_hue configure -value $::option(hue)
		update
		set ::colorm(l_hue_value) $::option(hue)
		set ::colorm(hue_old) $::option(hue)
		place $wfscale.l_hue_value -x [lindex [$wfscale.s_hue coords] 0] -rely 0 -anchor s -in $wfscale.s_hue
	}
	if {[info exists ::option(saturation)] == 0} {
		if {[array exists ::colorm_saturation]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=saturation} saturation_read
			foreach {id wert} [split $saturation_read] {
				$wfscale.s_saturation configure -value $wert
				update
				set ::colorm(l_saturation_value) $wert
				set ::colorm(saturation_old) $wert
				place $wfscale.l_saturation_value -x [lindex [$wfscale.s_saturation coords] 0] -rely 0 -anchor s -in $wfscale.s_saturation
			}
		}
	} else {
		$wfscale.s_saturation configure -value $::option(saturation)
		update
		set ::colorm(l_saturation_value) $::option(saturation)
		set ::colorm(saturation_old) $::option(saturation)
		place $wfscale.l_saturation_value -x [lindex [$wfscale.s_saturation coords] 0] -rely 0 -anchor s -in $wfscale.s_saturation
	}
	if {[info exists ::option(contrast)] == 0} {
		if {[array exists ::colorm_contrast]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=contrast} contrast_read
			foreach {id wert} [split $contrast_read] {
				$wfscale.s_contrast configure -value $wert
				update
				set ::colorm(l_contrast_value) $wert
				set ::colorm(contrast_old) $wert
				place $wfscale.l_contrast_value -x [lindex [$wfscale.s_contrast coords] 0] -rely 0 -anchor s -in $wfscale.s_contrast
			}
		}
	} else {
		$wfscale.s_contrast configure -value $::option(contrast)
		update
		set ::colorm(l_contrast_value) $::option(contrast)
		set ::colorm(contrast_old) $::option(contrast)
		place $wfscale.l_contrast_value -x [lindex [$wfscale.s_contrast coords] 0] -rely 0 -anchor s -in $wfscale.s_contrast
	}
	if {[info exists ::option(brightness)] == 0} {
		if {[array exists ::colorm_brightness]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=brightness} brightness_read
			foreach {id wert} [split $brightness_read] {
				$wfscale.s_brightness configure -value $wert
				update
				set ::colorm(l_brightness_value) $wert
				set ::colorm(brightness_old) $wert
				place $wfscale.l_brightness_value -x [lindex [$wfscale.s_brightness coords] 0] -rely 0 -anchor s -in $wfscale.s_brightness
			}
		}
	} else {
		$wfscale.s_brightness configure -value $::option(brightness)
		update
		set ::colorm(l_brightness_value) $::option(brightness)
		set ::colorm(brightness_old) $::option(brightness)
		place $wfscale.l_brightness_value -x [lindex [$wfscale.s_brightness coords] 0] -rely 0 -anchor s -in $wfscale.s_brightness
	}
}

proc colorm_saveValues {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: \033\[0m colorm_saveValues \{$w\}"
	#On exit of the color management dialog the new values can be saved.
	#They are stored in the standard tv-viewer config file.
	log_writeOut ::log(tvAppend) 0 "Saving color management values to $::option(home)/config/tv-viewer.conf"
	set config_file "$::option(home)/config/tv-viewer.conf"
	if {[file exists "$config_file"]} {
		set open_config_file [open "$config_file" r]
		set i 1
		while {[gets $open_config_file line]!=-1} {
			if {[string match brightness* $line] || [string match hue* $line] || [string match saturation* $line] || [string match contrast* $line]} continue
			set linien($i) $line
			set total_lines $i
			incr i
			}
		close $open_config_file
		for {set i 1} {$i <= $total_lines} {incr i} {
			if {$i == 1} {
				set config_file_write [open $config_file w]
				puts $config_file_write "$linien(1)"
				close $config_file_write
			} else {
				set config_file_append [open $config_file a]
				puts $config_file_append "$linien($i)"
				close $config_file_append
			}
		}
		set config_file_append [open $config_file a]
		if {[info exists ::colorm(l_brightness_value)]} {
			puts $config_file_append "brightness \{$::colorm(l_brightness_value)\}"
			set ::option(brightness) $::colorm(l_brightness_value)
		}
		if {[info exists ::colorm(l_contrast_value)]} {
			puts $config_file_append "contrast \{$::colorm(l_contrast_value)\}"
			set ::option(contrast) $::colorm(l_contrast_value)
		}
		if {[info exists ::colorm(l_hue_value)]} {
			puts $config_file_append "hue \{$::colorm(l_hue_value)\}"
			set ::option(hue) $::colorm(l_hue_value)
		}
		if {[info exists ::colorm(l_saturation_value)]} {
			puts -nonewline $config_file_append "saturation \{$::colorm(l_saturation_value)\}"
			set ::option(saturation) $::colorm(l_saturation_value)
		}
		close $config_file_append
	} else {
		set config_file_write [open $config_file w]
		puts $config_file_write "#TV-Viewer config file. File is generated automatically, do not edit manually."
		close $config_file_write
		set config_file_append [open $config_file a]
		puts $config_file_append "
#Videocard controls (hue / saturation / brightness / contrast)
"
		if {[info exists ::colorm(l_brightness_value)]} {
			puts $config_file_append "brightness \{$::colorm(l_brightness_value)\}"
			set ::option(brightness) $::colorm(l_brightness_value)
		}
		if {[info exists ::colorm(l_contrast_value)]} {
			puts $config_file_append "contrast \{$::colorm(l_contrast_value)\}"
			set ::option(contrast) $::colorm(l_contrast_value)
		}
		if {[info exists ::colorm(l_hue_value)]} {
			puts $config_file_append "hue \{$::colorm(l_hue_value)\}"
			set ::option(hue) $::colorm(l_hue_value)
		}
		if {[info exists ::colorm(l_saturation_value)]} {
			puts -nonewline $config_file_append "saturation \{$::colorm(l_saturation_value)\}"
			set ::option(saturation) $::colorm(l_saturation_value)
		}
		close $config_file_append
	}
	log_writeOut ::log(tvAppend) 0 "Closing Color Management."
	destroy .cm
}

proc colorm_exit {w} {
	#Exit Color management without saving values and apply old ones.
	puts $::main(debug_msg) "\033\[0;1;33mDebug: colom_exit \033\[0m \{$w\}"
	log_writeOut ::log(tvAppend) 1 "Closing Color Management without saving values."
	catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=hue=$::colorm(hue_old)}
	catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=saturation=$::colorm(saturation_old)}
	catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=brightness=$::colorm(brightness_old)}
	catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=contrast=$::colorm(contrast_old)}
	destroy .cm
}

proc colorm_mainUi {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: colorm_mainUi \033\[0m"
	if {[wm attributes . -fullscreen] == 1} {
		event generate . <<wmFull>>
	}
	
	if {[winfo exists .cm] == 0} {
		log_writeOut ::log(tvAppend) 0 "Setting up Color Management."
		# Setting up main Interface
		set cm_w [toplevel .cm ]
		place [ttk::frame $cm_w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		
		set wfscale [ttk::frame $cm_w.f_vscale]
		
		set wfbtn [ttk::frame $cm_w.b_vbtn -style TLabelframe]
		
		ttk::scale $wfscale.s_brightness -command [list colormScalemove $wfscale.s_brightness $wfscale.l_brightness_value]
		
		ttk::scale $wfscale.s_contrast -command [list colormScalemove $wfscale.s_contrast $wfscale.l_contrast_value]
		
		ttk::scale $wfscale.s_hue -command [list colormScalemove $wfscale.s_hue $wfscale.l_hue_value]
		
		ttk::scale $wfscale.s_saturation -command [list colormScalemove $wfscale.s_saturation $wfscale.l_saturation_value]
		
		ttk::label $wfscale.l_brightness_value -textvariable colorm(l_brightness_value)
		
		ttk::label $wfscale.l_contrast_value -textvariable colorm(l_contrast_value)
		
		ttk::label $wfscale.l_hue_value -textvariable colorm(l_hue_value)
		
		ttk::label $wfscale.l_saturation_value -textvariable colorm(l_saturation_value)
		
		ttk::label $wfscale.l_brightness -text [mc "Brightness"] -padding "5 0 0 0"
		
		ttk::label $wfscale.l_contrast -text [mc "Contrast"] -padding "5 0 0 0"
		
		ttk::label $wfscale.l_hue -text [mc "Hue"] -padding "5 0 0 0"
		
		ttk::label $wfscale.l_saturation -text [mc "Saturation"] -padding "5 0 0 0"
		
		ttk::button $wfbtn.b_ok -text [mc "Apply"] -command [list colorm_saveValues $wfscale] -compound left -image $::icon_s(dialog-ok-apply)
		
		ttk::button $wfbtn.b_default -text [mc "Default"] -command [list colorm_setDefault $wfscale]
		
		ttk::button $wfbtn.b_exit -text [mc "Cancel"] -command [list colorm_exit $wfscale] -compound left -image $::icon_s(dialog-cancel)
		
		grid anchor $wfbtn e
		
		grid $wfscale -in .cm -row 0 -column 0 -sticky nesw
		grid $wfbtn -in .cm -row 2 -column 0 -sticky ew -padx 3 -pady 3
		
		grid $wfscale.l_brightness -in $wfscale -row 1 -column 0 -sticky ew
		grid $wfscale.l_contrast -in $wfscale -row 3 -column 0 -sticky ew
		grid $wfscale.l_hue -in $wfscale -row 5 -column 0 -sticky ew
		grid $wfscale.l_saturation -in $wfscale -row 7 -column 0 -sticky ew
		
		grid $wfscale.s_brightness -in $wfscale -row 1 -column 1 -sticky ew -padx 5
		grid $wfscale.s_contrast -in $wfscale -row 3 -column 1 -sticky ew -padx 5
		grid $wfscale.s_hue -in $wfscale -row 5 -column 1 -sticky ew -padx 5
		grid $wfscale.s_saturation -in $wfscale -row 7 -column 1 -sticky ew -padx 5
		
		grid $wfbtn.b_ok -in $wfbtn -row 0 -column 0 -padx 3 -pady 7
		grid $wfbtn.b_default -in $wfbtn -row 0 -column 1 -pady 7
		grid $wfbtn.b_exit -in $wfbtn -row 0 -column 2 -pady 7 -padx 3
		
		grid rowconfigure $wfscale 0 -minsize 20
		grid rowconfigure $wfscale 2 -minsize 20
		grid rowconfigure $wfscale 4 -minsize 20
		grid rowconfigure $wfscale 6 -minsize 20
		grid columnconfigure $wfscale 1 -weight 1
		
		# Subprocs
		
		proc colormScalemove {scale label val} {
			#Special function so a value can be displayed above
			#ttk::scales
			upvar #0 [$label cget -textvariable] var
			set xpos [lindex [$scale coords] 0]
			set var [expr {round($val)}]
			place $label -x $xpos -rely 0 -anchor s -in $scale
			catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=[lindex [split $scale "_"] end]=$val}
		}
		
		proc colorm_setDefault {w} {
			#Set all values back to defaults.
			puts $::main(debug_msg) "\033\[0;1;33mDebug: colorm_setDefault \033\[0m \{$w\}"
			log_writeOut ::log(tvAppend) 1 "Setting color management values to default."
			if {[array exists ::colorm_hue]} {
				$w.s_hue configure -value $::colorm_hue(default)
				update
				set ::colorm(l_hue_value) $::colorm_hue(default)
				place $w.l_hue_value -x [lindex [$w.s_hue coords] 0] -rely 0 -anchor s -in $w.s_hue
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=hue=$::colorm_hue(default)}
			}
			if {[array exists ::colorm_brightness]} {
				$w.s_brightness configure -value $::colorm_brightness(default)
				update
				set ::colorm(l_brightness_value) $::colorm_brightness(default)
				place $w.l_brightness_value -x [lindex [$w.s_brightness coords] 0] -rely 0 -anchor s -in $w.s_brightness
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=brightness=$::colorm_brightness(default)}
			}
			if {[array exists ::colorm_saturation]} {
				$w.s_saturation configure -value $::colorm_saturation(default)
				update
				set ::colorm(l_saturation_value) $::colorm_saturation(default)
				place $w.l_saturation_value -x [lindex [$w.s_saturation coords] 0] -rely 0 -anchor s -in $w.s_saturation
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=saturation=$::colorm_saturation(default)}
			}
			if {[array exists ::colorm_contrast]} {
				$w.s_contrast configure -value $::colorm_contrast(default)
				update
				set ::colorm(l_contrast_value) $::colorm_contrast(default)
				place $w.l_contrast_value -x [lindex [$w.s_contrast coords] 0] -rely 0 -anchor s -in $w.s_contrast
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=contrast=$::colorm_contrast(default)}
			}
		}
		
		# Additional Code
		
		wm resizable .cm 0 0
		wm protocol .cm WM_DELETE_WINDOW "colorm_exit $wfscale"
		wm iconphoto .cm $::icon_b(color-management)
		wm title .cm [mc "Color Management"]
		if {$::option(tooltips) == 1} {
			if {$::option(tooltips_colorm) == 1} {
				settooltip $wfscale.s_brightness [mc "Set brightness, this is a global value"]
				settooltip $wfscale.s_contrast [mc "Set contrast, this is a global value"]
				settooltip $wfscale.s_hue [mc "Set hue, this is a global value"]
				settooltip $wfscale.s_saturation [mc "Set saturation, this is a global value"]
				settooltip $wfbtn.b_ok [mc "Save values and close color management"]
				settooltip $wfbtn.b_default [mc "Load default values"]
				settooltip $wfbtn.b_exit [mc "Close color management without saving changes"]
			} else {
				settooltip $wfscale.s_brightness {}
				settooltip $wfscale.s_contrast {}
				settooltip $wfscale.s_hue {}
				settooltip $wfscale.s_saturation {}
				settooltip $wfbtn.b_ok {}
				settooltip $wfbtn.b_default {}
				settooltip $wfbtn.b_exit {}
			}
		}
		colorm_readValues $wfscale
	} else {
		raise .cm
	}
}
