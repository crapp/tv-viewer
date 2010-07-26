#       tooltip.tcl
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

proc tooltips {toolbTop toolbStation toolbBot section} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tooltips \033\[0m \{$toolbTop\} \{$toolbStation\} \{$toolbBot\} \{$section\}"
	if {"$section" == "main"} {
		if {$::option(tooltips) == 1} {
			if {$::option(tooltips_main) == 1} {
				settooltip $toolbStation.bChanUp [mc "Tune up."]
				settooltip $toolbStation.bChanDown [mc "Tune down."]
				settooltip $toolbStation.bChanJump [mc "Zap among the last two stations."]
				settooltip $toolbBot.scVolume [mc "Alter volume."]
				settooltip $toolbBot.bVolMute [mc "Toggle mute."]
				settooltip $toolbTop.bTimeshift [mc "Start/Stop timeshift."]
				settooltip $toolbTop.bRecord [mc "Start/Stop record."]
				settooltip $toolbTop.bEpg [mc "Execute the selected epg application."]
				settooltip $toolbTop.bRadio [mc "Switch to radio mode"]
				settooltip $toolbTop.bTv [mc "Start/Stop TV playback."]
			} else {
				settooltip $toolbStation.bChanUp {}
				settooltip $toolbStation.bChanDown {}
				settooltip $toolbStation.bChanJump {}
				settooltip $toolbBot.scVolume {}
				settooltip $toolbBot.bVolMute {}
				settooltip $toolbTop.bTimeshift {}
				settooltip $toolbTop.bRecord {}
				settooltip $toolbTop.bEpg {}
				settooltip $toolbTop.bRadio {}
				settooltip $toolbTop.bTv {}
			}
		} else {
			settooltip $toolbStation.bChanUp {}
			settooltip $toolbStation.bChanDown {}
			settooltip $toolbStation.bChanJump {}
			settooltip $toolbBot.scVolume {}
			settooltip $toolbBot.bVolMute {}
			settooltip $toolbTop.bTimeshift {}
			settooltip $toolbTop.bRecord {}
			settooltip $toolbTop.bEpg {}
			settooltip $toolbTop.bRadio {}
			settooltip $toolbTop.bTv {}
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
