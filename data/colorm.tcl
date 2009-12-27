#       colorm.tcl
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

proc colorm_readValues {wfscale} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: colorm_readValues \033\[0m \{$wfscale\}"
	tkwait visibility .cm
	catch {exec v4l2-ctl --device=$::option(video_device) -l} read_v4l2ctl
	set status_v4l2ctl [catch {agrep -w "$read_v4l2ctl" hue} hue_default_read]
	if {$status_v4l2ctl == 0} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=hue} check_hue_available
		if { "[string tolower [lindex $check_hue_available 0]]" == "hue:" } {
			array set ::hue [split [string trim $hue_default_read] { =}]
			log_writeOutTv 0 "Default value for hue: $::hue(default)"
			$wfscale.s_hue configure -from $::hue(min) -to $::hue(max)
		} else {
			log_writeOutTv 2 "Can't read default value for hue."
			log_writeOutTv 2 "Error message: $hue_default_read"
			$wfscale.s_hue state disabled
			$wfscale.l_hue state disabled
		}
	} else {
		log_writeOutTv 2 "Can't read default value for hue."
		log_writeOutTv 2 "Error message: $hue_default_read"
		$wfscale.s_hue state disabled
		$wfscale.l_hue state disabled
	}
	catch {exec v4l2-ctl --device=$::option(video_device) -l} read_v4l2ctl
	set status_v4l2ctl [catch {agrep -w "$read_v4l2ctl" saturation} saturation_default_read]
	if {$status_v4l2ctl == 0} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=saturation} check_saturation_available
		if { "[string tolower [lindex $check_saturation_available 0]]" == "saturation:" } {
			split [string trim $saturation_default_read] { =}
			array set ::saturation [split [string trim $saturation_default_read] { =}]
			log_writeOutTv 0 "Default value for saturation: $::saturation(default)"
			$wfscale.s_saturation configure -from $::saturation(min) -to $::saturation(max)
		} else {
			log_writeOutTv 2 "Can't read default value for saturation."
			log_writeOutTv 2 "Error message: $saturation_default_read"
			$wfscale.s_saturation state disabled
			$wfscale.l_saturation state disabled
		}
	} else {
		log_writeOutTv 2 "Can't read default value for saturation."
		log_writeOutTv 2 "Error message: $saturation_default_read"
		$wfscale.s_saturation state disabled
		$wfscale.l_saturation state disabled
	}
	catch {exec v4l2-ctl --device=$::option(video_device) -l} read_v4l2ctl
	set status_v4l2ctl [catch {agrep -w "$read_v4l2ctl" contrast} contrast_default_read]
	if {$status_v4l2ctl == 0} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=contrast} check_contrast_available
		if { "[string tolower [lindex $check_contrast_available 0]]" == "contrast:" } {
			split [string trim $contrast_default_read] { =}
			array set ::contrast [split [string trim $contrast_default_read] { =}]
			log_writeOutTv 0 "Default value for contrast: $::contrast(default)"
			$wfscale.s_contrast configure -from $::contrast(min) -to $::contrast(max)
		} else {
			log_writeOutTv 2 "Can't read default value for contrast."
			log_writeOutTv 2 "Error message: $contrast_default_read"
			$wfscale.s_contrast state disabled
			$wfscale.l_contrast state disabled
		}
	} else {
		log_writeOutTv 2 "Can't read default value for contrast."
		log_writeOutTv 2 "Error message: $contrast_default_read"
		$wfscale.s_contrast state disabled
		$wfscale.l_contrast state disabled
	}
	catch {exec v4l2-ctl --device=$::option(video_device) -l} read_v4l2ctl
	set status_v4l2ctl [catch {agrep -w "$read_v4l2ctl" brightness} brightness_default_read]
	if {$status_v4l2ctl == 0} {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=brightness} check_brightness_available
		if { "[string tolower [lindex $check_brightness_available 0]]" == "brightness:" } {
			split [string trim $brightness_default_read] { =}
			array set ::brightness [split [string trim $brightness_default_read] { =}]
			log_writeOutTv 0 "Default value for brightness: $::brightness(default)"
			$wfscale.s_brightness configure -from $::brightness(min) -to $::brightness(max)
		} else {
			log_writeOutTv 2 "Can't read default value for brightness."
			log_writeOutTv 2 "Error message: $brightness_default_read"
			$wfscale.s_brightness state disabled
			$wfscale.l_brightness state disabled
		}
	} else {
		log_writeOutTv 2 "Can't read default value for brightness."
		log_writeOutTv 2 "Error message: $brightness_default_read"
		$wfscale.s_brightness state disabled
		$wfscale.l_brightness state disabled
	}
	if {[info exists ::option(hue)] == 0} {
		if {[array exists ::hue]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=hue} hue_read
			foreach {id wert} [split $hue_read] {
				$wfscale.s_hue configure -value $wert
				update
				set ::l_hue_value $wert
				set ::option(hue_old) $wert
				place $wfscale.l_hue_value -x [lindex [$wfscale.s_hue coords] 0] -rely 0 -anchor s -in $wfscale.s_hue
			}
		}
	} else {
		$wfscale.s_hue configure -value $::option(hue)
		update
		set ::l_hue_value $::option(hue)
		set ::option(hue_old) $::option(hue)
		place $wfscale.l_hue_value -x [lindex [$wfscale.s_hue coords] 0] -rely 0 -anchor s -in $wfscale.s_hue
	}
	if {[info exists ::option(saturation)] == 0} {
		if {[array exists ::saturation]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=saturation} saturation_read
			foreach {id wert} [split $saturation_read] {
				$wfscale.s_saturation configure -value $wert
				update
				set ::l_saturation_value $wert
				set ::option(saturation_old) $wert
				place $wfscale.l_saturation_value -x [lindex [$wfscale.s_saturation coords] 0] -rely 0 -anchor s -in $wfscale.s_saturation
			}
		}
	} else {
		$wfscale.s_saturation configure -value $::option(saturation)
		update
		set ::l_saturation_value $::option(saturation)
		set ::option(saturation_old) $::option(saturation)
		place $wfscale.l_saturation_value -x [lindex [$wfscale.s_saturation coords] 0] -rely 0 -anchor s -in $wfscale.s_saturation
	}
	if {[info exists ::option(contrast)] == 0} {
		if {[array exists ::contrast]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=contrast} contrast_read
			foreach {id wert} [split $contrast_read] {
				$wfscale.s_contrast configure -value $wert
				update
				set ::l_contrast_value $wert
				set ::option(contrast_old) $wert
				place $wfscale.l_contrast_value -x [lindex [$wfscale.s_contrast coords] 0] -rely 0 -anchor s -in $wfscale.s_contrast
			}
		}
	} else {
		$wfscale.s_contrast configure -value $::option(contrast)
		update
		set ::l_contrast_value $::option(contrast)
		set ::option(contrast_old) $::option(contrast)
		place $wfscale.l_contrast_value -x [lindex [$wfscale.s_contrast coords] 0] -rely 0 -anchor s -in $wfscale.s_contrast
	}
	if {[info exists ::option(brightness)] == 0} {
		if {[array exists ::brightness]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --get-ctrl=brightness} brightness_read
			foreach {id wert} [split $brightness_read] {
				$wfscale.s_brightness configure -value $wert
				update
				set ::l_brightness_value $wert
				set ::option(brightness_old) $wert
				place $wfscale.l_brightness_value -x [lindex [$wfscale.s_brightness coords] 0] -rely 0 -anchor s -in $wfscale.s_brightness
			}
		}
	} else {
		$wfscale.s_brightness configure -value $::option(brightness)
		update
		set ::l_brightness_value $::option(brightness)
		set ::option(brightness_old) $::option(brightness)
		place $wfscale.l_brightness_value -x [lindex [$wfscale.s_brightness coords] 0] -rely 0 -anchor s -in $wfscale.s_brightness
	}
}

proc colorm_saveValues {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: \033\[0m colorm_saveValues \{$w\}"
	log_writeOutTv 0 "Saving color management values to $::option(where_is_home)/config/tv-viewer.conf"
	set config_file "$::option(where_is_home)/config/tv-viewer.conf"
	if {[file exists "$config_file"]} {
		set open_config_file [open "$config_file" r]
		set i 1
		while {[gets $open_config_file line]!=-1} {
			if {[string match brightness* $line] || [string match hue* $line] || [string match saturation* $line] || [string match contrast* $line] || [string trim $line] == {} } continue
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
		if {[info exists ::l_brightness_value]} {
			puts $config_file_append "brightness \{$::l_brightness_value\}"
			set ::option(brightness) $::l_brightness_value
		}
		if {[info exists ::l_contrast_value]} {
			puts $config_file_append "contrast \{$::l_contrast_value\}"
			set ::option(contrast) $::l_contrast_value
		}
		if {[info exists ::l_hue_value]} {
			puts $config_file_append "hue \{$::l_hue_value\}"
			set ::option(hue) $::l_hue_value
		}
		if {[info exists ::l_saturation_value]} {
			puts -nonewline $config_file_append "saturation \{$::l_saturation_value\}"
			set ::option(saturation) $::l_saturation_value
		}
		close $config_file_append
	} else {
		set config_file_write [open $config_file w]
		puts $config_file_write "#TV-Viewer config file. File is generated automatically, do not edit. Datei wird automatisch erstellt, bitte nicht editieren"
		close $config_file_write
		set config_file_append [open $config_file a]
		if {[info exists ::l_brightness_value]} {
			puts $config_file_append "brightness \{$::l_brightness_value\}"
			set ::option(brightness) $::l_brightness_value
		}
		if {[info exists ::l_contrast_value]} {
			puts $config_file_append "contrast \{$::l_contrast_value\}"
			set ::option(contrast) $::l_contrast_value
		}
		if {[info exists ::l_hue_value]} {
			puts $config_file_append "hue \{$::l_hue_value\}"
			set ::option(hue) $::l_hue_value
		}
		if {[info exists ::l_saturation_value]} {
			puts -nonewline $config_file_append "saturation \{$::l_saturation_value\}"
			set ::option(saturation) $::l_saturation_value
		}
		close $config_file_append
	}
	log_writeOutTv 0 "Closing Color Management."
	destroy .cm
}

proc colorm_exit {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: colom_exit \033\[0m \{$w\}"
	log_writeOutTv 1 "Closing Color Management without saving values."
	catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=hue=$::option(hue_old)}
	catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=saturation=$::option(saturation_old)}
	catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=brightness=$::option(brightness_old)}
	catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=contrast=$::option(contrast_old)}
	destroy .cm
}

proc colorm_mainUi {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: colorm_mainUi \033\[0m"
	if {[wm attributes .tv -fullscreen] == 1} {
		tv_wmFullscreen .tv .tv.bg.w .tv.bg
	}
	
	if {[winfo exists .cm] == 0} {
		log_writeOutTv 0 "Setting up Color Management."
		# Setting up main Interface
		set cm_w [toplevel .cm -class "TV-Viewer"]
		place [ttk::frame $cm_w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		
		set wfscale [ttk::frame $cm_w.f_vscale]
		
		set wfbtn [ttk::frame $cm_w.b_vbtn -style TLabelframe]
		
		ttk::scale $wfscale.s_brightness \
		-command [list colormScalemove $wfscale.s_brightness $wfscale.l_brightness_value]
		
		ttk::scale $wfscale.s_contrast \
		-command [list colormScalemove $wfscale.s_contrast $wfscale.l_contrast_value]
		
		ttk::scale $wfscale.s_hue \
		-command [list colormScalemove $wfscale.s_hue $wfscale.l_hue_value]
		
		ttk::scale $wfscale.s_saturation \
		-command [list colormScalemove $wfscale.s_saturation $wfscale.l_saturation_value]
		
		ttk::label $wfscale.l_brightness_value \
		-textvariable l_brightness_value
		
		ttk::label $wfscale.l_contrast_value \
		-textvariable l_contrast_value
		
		ttk::label $wfscale.l_hue_value \
		-textvariable l_hue_value
		
		ttk::label $wfscale.l_saturation_value \
		-textvariable l_saturation_value
		
		ttk::label $wfscale.l_brightness \
		-text [mc "Brightness"] \
		-padding "5 0 0 0"
		
		ttk::label $wfscale.l_contrast \
		-text [mc "Contrast"] \
		-padding "5 0 0 0"
		
		ttk::label $wfscale.l_hue \
		-text [mc "Hue"] \
		-padding "5 0 0 0"
		
		ttk::label $wfscale.l_saturation \
		-text [mc "Saturation"] \
		-padding "5 0 0 0"
		
		ttk::button $wfbtn.b_ok \
		-text [mc "Apply"] \
		-command [list colorm_saveValues $wfscale] \
		-compound left \
		-image $::icon_s(dialog-ok-apply)
		
		ttk::button $wfbtn.b_default \
		-text [mc "Default"] \
		-command [list colorm_setDefault $wfscale]
		
		ttk::button $wfbtn.b_exit \
		-text [mc "Cancel"] \
		-command [list colorm_exit $wfscale] \
		-compound left \
		-image $::icon_s(dialog-cancel)
		
		grid anchor $wfbtn e
		
		grid $wfscale -in .cm -row 0 -column 0 \
		-sticky nesw
		grid $wfbtn -in .cm -row 2 -column 0 \
		-sticky ew \
		-padx 3 \
		-pady 3
		
		grid $wfscale.l_brightness -in $wfscale -row 1 -column 0 \
		-sticky ew
		grid $wfscale.l_contrast -in $wfscale -row 3 -column 0 \
		-sticky ew
		grid $wfscale.l_hue -in $wfscale -row 5 -column 0 \
		-sticky ew
		grid $wfscale.l_saturation -in $wfscale -row 7 -column 0 \
		-sticky ew
		
		grid $wfscale.s_brightness -in $wfscale -row 1 -column 1 \
		-sticky ew \
		-padx 5
		grid $wfscale.s_contrast -in $wfscale -row 3 -column 1 \
		-sticky ew \
		-padx 5
		grid $wfscale.s_hue -in $wfscale -row 5 -column 1 \
		-sticky ew \
		-padx 5
		grid $wfscale.s_saturation -in $wfscale -row 7 -column 1 \
		-sticky ew \
		-padx 5
		
		grid $wfbtn.b_ok -in $wfbtn -row 0 -column 0 \
		-padx 3 \
		-pady 7
		grid $wfbtn.b_default -in $wfbtn -row 0 -column 1 \
		-pady 7
		grid $wfbtn.b_exit -in $wfbtn -row 0 -column 2 \
		-pady 7 \
		-padx 3
		
		grid rowconfigure . 1 -minsize 5
		
		grid rowconfigure $wfscale 0 -minsize 20
		grid rowconfigure $wfscale 2 -minsize 20
		grid rowconfigure $wfscale 4 -minsize 20
		grid rowconfigure $wfscale 6 -minsize 20
		grid columnconfigure $wfscale 1 -weight 1
		
		# Subprocs
		
		proc colormScalemove {scale label val} {
			upvar #0 [$label cget -textvariable] var
			set xpos [lindex [$scale coords] 0]
			set var [expr {round($val)}]
			place $label -x $xpos -rely 0 -anchor s -in $scale
			catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=[lindex [split $scale "_"] end]=$val}
		}
		
		proc colorm_setDefault {w} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: colorm_setDefault \033\[0m \{$w\}"
			log_writeOutTv 1 "Setting color management values to default."
			if {[array exists ::hue]} {
				$w.s_hue configure -value $::hue(default)
				update
				set ::l_hue_value $::hue(default)
				place $w.l_hue_value -x [lindex [$w.s_hue coords] 0] -rely 0 -anchor s -in $w.s_hue
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=hue=$::hue(default)}
			}
			if {[array exists ::brightness]} {
				$w.s_brightness configure -value $::brightness(default)
				update
				set ::l_brightness_value $::brightness(default)
				place $w.l_brightness_value -x [lindex [$w.s_brightness coords] 0] -rely 0 -anchor s -in $w.s_brightness
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=brightness=$::brightness(default)}
			}
			if {[array exists ::saturation]} {
				$w.s_saturation configure -value $::saturation(default)
				update
				set ::l_saturation_value $::saturation(default)
				place $w.l_saturation_value -x [lindex [$w.s_saturation coords] 0] -rely 0 -anchor s -in $w.s_saturation
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=saturation=$::saturation(default)}
			}
			if {[array exists ::contrast]} {
				$w.s_contrast configure -value $::contrast(default)
				update
				set ::l_contrast_value $::contrast(default)
				place $w.l_contrast_value -x [lindex [$w.s_contrast coords] 0] -rely 0 -anchor s -in $w.s_contrast
				catch {exec v4l2-ctl --device=$::option(video_device) --set-ctrl=contrast=$::contrast(default)}
			}
		}
		
		# Additional Code
		
		wm resizable .cm 0 0
		wm protocol .cm WM_DELETE_WINDOW "colorm_exit $wfscale"
		wm iconphoto .cm $::icon_b(color-management)
		wm title .cm [mc "Color Management"]
		if {$::option(tooltips) == 1} {
			if {$::option(tooltips_colorm) == 1} {
				settooltip $wfscale.s_brightness [mc "Set brightness, this is a global value."]
				settooltip $wfscale.s_contrast [mc "Set contrast, this is a global value."]
				settooltip $wfscale.s_hue [mc "Set hue, this is a global value."]
				settooltip $wfscale.s_saturation [mc "Set saturation, this is a global value."]
				settooltip $wfbtn.b_ok [mc "Save values and close color management."]
				settooltip $wfbtn.b_default [mc "Load default values."]
				settooltip $wfbtn.b_exit [mc "Close color management without saving changes."]
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
	}
}
