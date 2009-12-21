#       tooltip.tcl
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

proc settooltip {tool_tip_widget tool_tip_text} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: settooltip \033\[0m \{$tool_tip_widget\} \{$tool_tip_text\}"
	if { [string trim $tool_tip_text] != {} } {
		bind $tool_tip_widget <Any-Enter>    [list after 500 [list showtooltip %W $tool_tip_text]]
		bind $tool_tip_widget <Any-Leave>    [list after 500 [list destroy %W.tooltip]]
		bind $tool_tip_widget <Any-KeyPress> [list after 500 [list destroy %W.tooltip]]
		bind $tool_tip_widget <Any-Button>   [list after 500 [list destroy %W.tooltip]]
	} else {
		bind $tool_tip_widget <Any-Enter>    {}
		bind $tool_tip_widget <Any-Leave>    {}
		bind $tool_tip_widget <Any-KeyPress> {}
		bind $tool_tip_widget <Any-Button>   {}
	}
}

proc tooltips {w1 w2 section} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tooltips \033\[0m \{$w1\} \{$w2\} \{$section\}"
	if {"$section" == "main"} {
		if {$::option(tooltips) == 1} {
			if {$::option(tooltips_main) == 1} {
				settooltip $w1.button_channelup [mc "Tune up."]
				settooltip $w1.button_channeldown [mc "Tune down."]
				settooltip $w1.button_channeljumpback [mc "Zap among the last two stations."]
				settooltip $w1.button_showslist [mc "Show/hide station list."]
				settooltip $w1.scale_volume [mc "Alter volume."]
				settooltip $w1.button_mute [mc "Toggle mute."]
				settooltip $w2.button_timeshift [mc "Start/Stop timeshift."]
				settooltip $w2.button_record [mc "Start/Stop record."]
				settooltip $w2.button_epg [mc "Execute the selected epg application."]
				settooltip $w2.button_starttv [mc "Start/Stop tv playback."]
			} else {
				settooltip $w1.button_channelup {}
				settooltip $w1.button_channeldown {}
				settooltip $w1.button_channeljumpback {}
				settooltip $w1.button_showslist {}
				settooltip $w1.scale_volume {}
				settooltip $w1.button_mute {}
				settooltip $w2.button_timeshift {}
				settooltip $w2.button_record {}
				settooltip $w2.button_epg {}
				settooltip $w2.button_starttv {}
			}
		} else {
			settooltip $w1.button_channelup {}
			settooltip $w1.button_channeldown {}
			settooltip $w1.button_channeljumpback {}
			settooltip $w1.button_showslist {}
			settooltip $w1.scale_volume {}
			settooltip $w1.button_mute {}
			settooltip $w2.button_timeshift {}
			settooltip $w2.button_record {}
			settooltip $w2.button_epg {}
			settooltip $w2.button_starttv {}
		}
		return
	}
}

proc showtooltip {tool_tip_widget tool_tip_text} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: showtooltip \033\[0m \{$tool_tip_widget\} \{$tool_tip_text\}"
	global tcl_platform
	if {[string match $tool_tip_widget* [winfo containing -displayof . [winfo pointerx .] [winfo pointery .]] ] == 0 && "$tool_tip_widget" != ".tray"} {
		return
	}
	catch { destroy $tool_tip_widget.tooltip }
	set scrh [winfo screenheight $tool_tip_widget]
	set scrw [winfo screenwidth $tool_tip_widget]
	set tooltip [toplevel $tool_tip_widget.tooltip -bd 1 -bg black]
	wm geometry $tooltip +$scrh+$scrw
	wm overrideredirect $tooltip 1
	
	pack [label $tooltip.label -bg lightyellow -fg black -text $tool_tip_text -justify left]
	
	set width [winfo reqwidth $tooltip.label]
	set height [winfo reqheight $tooltip.label]
	
	set positionX [winfo pointerx .]
	set positionY [expr [winfo pointery .] + 15]
	
	if  {[expr $positionX + $width] > [winfo screenwidth .]} {
		set positionX [expr ($positionX - (($positionX + $width) - [winfo screenwidth .]))]
	}
	if {[expr $positionY + $height] > [winfo screenheight .]} {
		set positionY [expr [winfo pointery .] - 30]
	}
	
	wm geometry $tooltip [join  "$width x $height + $positionX + $positionY" {}]
	raise $tooltip
	
	bind $tool_tip_widget.tooltip <Any-Enter> {destroy %W}
	bind $tool_tip_widget.tooltip <Any-Leave> {destroy %W}
}
