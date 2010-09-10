#       process_key_file.tcl
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

proc process_KeyFile {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: process_KeyFile \033\[0m"
	#Main menu
	dict set ::keyseq mTv name Alt+T
	dict set ::keyseq mTv seq <Alt-Key-t>
	dict set ::keyseq mTv label [mc "TV-Viewer Menu"]
	dict set ::keyseq mNav name Alt+N
	dict set ::keyseq mNav seq <Alt-Key-n>
	dict set ::keyseq mNav label [mc "Navigation Menu"]
	dict set ::keyseq mView name Alt+V
	dict set ::keyseq mView seq <Alt-Key-v>
	dict set ::keyseq mView label [mc "View Menu"]
	dict set ::keyseq mAudio name Alt+A
	dict set ::keyseq mAudio seq <Alt-Key-a>
	dict set ::keyseq mAudio label [mc "Audio Menu"]
	dict set ::keyseq mHelp name Alt+H
	dict set ::keyseq mHelp seq <Alt-Key-h>
	dict set ::keyseq mHelp label [mc "Help Menu"]
	
	dict set ::keyseq preferences name Ctrl+P
	dict set ::keyseq preferences seq <Control-Key-p>
	dict set ::keyseq preferences label [mc "Preferences"]
	dict set ::keyseq sedit name Ctrl+E
	dict set ::keyseq sedit seq <Control-Key-e>
	dict set ::keyseq sedit label [mc "Station Editor"]
	dict set ::keyseq colorm name Ctrl+M
	dict set ::keyseq colorm seq <Control-Key-m>
	dict set ::keyseq colorm label [mc "Color Management"]
	dict set ::keyseq help name F1
	dict set ::keyseq help seq <Key-F1>
	dict set ::keyseq help label [mc "User Guide"]
	dict set ::keyseq exit name Ctrl+X
	dict set ::keyseq exit seq <Ctrl-Key-x>
	dict set ::keyseq exit label [mc "Exit TV-Viewer"]
	
	dict set ::keyseq startTv name S
	dict set ::keyseq startTv seq <Key-s>
	dict set ::keyseq startTv label [mc "Toggle TV playback"]
	
	dict set ::keyseq stationNext name Next
	dict set ::keyseq stationNext seq <Key-Next>
	dict set ::keyseq stationNext label [mc "Next Station"]
	dict set ::keyseq stationPrior name Prior
	dict set ::keyseq stationPrior seq <Key-Prior>
	dict set ::keyseq stationPrior label [mc "Prior Station"]
	dict set ::keyseq stationJump name J
	dict set ::keyseq stationJump seq <Key-j>
	dict set ::keyseq stationJump label [mc "Jump between the last two stations"]
	dict set ::keyseq stationKey name \[0-9\]
	dict set ::keyseq stationKey seq \[0-9\]
	dict set ::keyseq stationKey label [mc "Station by number"]
	
	dict set ::keyseq vinputNext name Alt+Next
	dict set ::keyseq vinputNext seq <Alt-Next>
	dict set ::keyseq vinputNext label [mc "Next video input"]
	dict set ::keyseq vinputPrior name Alt+Prior
	dict set ::keyseq vinputPrior seq <Alt-Prior>
	dict set ::keyseq vinputPrior label [mc "Previous video input"]
	
	dict set ::keyseq volInc name +
	dict set ::keyseq volInc seq {<Key-plus> <Key-KP_Add>}
	dict set ::keyseq volInc label [mc "Increase Volume"]
	dict set ::keyseq volDec name -
	dict set ::keyseq volDec seq {<Key-minus> <Key-KP_Subtract>}
	dict set ::keyseq volDec label [mc "Decrease Volume"]
	dict set ::keyseq delayInc name Alt++
	dict set ::keyseq delayInc seq {<Alt-Key-plus> <Alt-Key-KP_Add>}
	dict set ::keyseq delayInc label [mc "Increase audio delay"]
	dict set ::keyseq delayDec name Alt+-
	dict set ::keyseq delayDec seq {<Alt-Key-minus> <Alt-Key-KP_Subtract>}
	dict set ::keyseq delayDec label [mc "Decrease audio delay"]
	dict set ::keyseq volMute name M
	dict set ::keyseq volMute seq <Key-m>
	dict set ::keyseq volMute label [mc "Toggle mute"]
	
	dict set ::keyseq wmFull name F
	dict set ::keyseq wmFull seq <Key-f>
	dict set ::keyseq wmFull label [mc "Toggle Fullscreen"]
	dict set ::keyseq wmCompact name Ctrl+C
	dict set ::keyseq wmCompact seq <Control-Key-c>
	dict set ::keyseq wmCompact label [mc "Compact mode"]
	dict set ::keyseq wmZoomInc name E
	dict set ::keyseq wmZoomInc seq <Key-e>
	dict set ::keyseq wmZoomInc label [mc "Increase Zoom"]
	dict set ::keyseq wmZoomDec name W
	dict set ::keyseq wmZoomDec seq <Key-w>
	dict set ::keyseq wmZoomDec label [mc "Decrease Zoom"]
	dict set ::keyseq wmZoomAuto name Shift+W
	dict set ::keyseq wmZoomAuto seq <Shift-Key-W>
	dict set ::keyseq wmZoomAuto label [mc "Pan&Scan (16:9 / 4:3)"]
	dict set ::keyseq wmMoveUp name Alt+Up
	dict set ::keyseq wmMoveUp seq <Alt-Key-Up>
	dict set ::keyseq wmMoveUp label [mc "Move video up"]
	dict set ::keyseq wmMoveDown name Alt+Down
	dict set ::keyseq wmMoveDown seq <Alt-Key-Down>
	dict set ::keyseq wmMoveDown label [mc "Move video down"]
	dict set ::keyseq wmMoveRight name Alt+Right
	dict set ::keyseq wmMoveRight seq <Alt-Key-Right>
	dict set ::keyseq wmMoveRight label [mc "Move video right"]
	dict set ::keyseq wmMoveLeft name Alt+Left
	dict set ::keyseq wmMoveLeft seq <Alt-Key-Left>
	dict set ::keyseq wmMoveLeft label [mc "Move video left"]
	dict set ::keyseq wmMoveCenter name Alt+C
	dict set ::keyseq wmMoveCenter seq <Alt-Key-c>
	dict set ::keyseq wmMoveCenter label [mc "Center video"]
	dict set ::keyseq wmSize1 name Ctrl+1
	dict set ::keyseq wmSize1 seq <Control-Key-1>
	dict set ::keyseq wmSize1 label [mc "Original window size"]
	dict set ::keyseq wmSize2 name Ctrl+2
	dict set ::keyseq wmSize2 seq <Control-Key-2>
	dict set ::keyseq wmSize2 label [mc "Double window size"]
	
	dict set ::keyseq scrshot name Super+S
	dict set ::keyseq scrshot seq <Mod4-Key-s>
	dict set ::keyseq scrshot label [mc "Take a screenshot"]
	
	dict set ::keyseq recWizard name R
	dict set ::keyseq recWizard seq <Key-r>
	dict set ::keyseq recWizard label [mc "Record wizard"]
	dict set ::keyseq recTime name T
	dict set ::keyseq recTime seq <Key-t>
	dict set ::keyseq recTime label [mc "Timeshift"]
	
	dict set ::keyseq filePause name P
	dict set ::keyseq filePause seq <Key-p>
	dict set ::keyseq filePause label [mc "Toggle pause"]
	dict set ::keyseq filePlay name Shift+P
	dict set ::keyseq filePlay seq <Shift-Key-P>
	dict set ::keyseq filePlay label [mc "Start playback"]
	dict set ::keyseq fileStop name Shift+S
	dict set ::keyseq fileStop seq <Shift-Key-S>
	dict set ::keyseq fileStop label [mc "Stop playback"]
	dict set ::keyseq fileRew10s name Left
	dict set ::keyseq fileRew10s seq <Key-Left>
	dict set ::keyseq fileRew10s label [mc "-10 seconds"]
	dict set ::keyseq fileRew1m name Shift+Left
	dict set ::keyseq fileRew1m seq <Shift-Key-Left>
	dict set ::keyseq fileRew1m label [mc "-1 minute"]
	dict set ::keyseq fileRew10m name Ctrl+Shift+Left
	dict set ::keyseq fileRew10m seq <Control-Shift-Key-Left>
	dict set ::keyseq fileRew10m label [mc "-10 minutes"]
	dict set ::keyseq fileFow10s name Right
	dict set ::keyseq fileFow10s seq <Key-Right>
	dict set ::keyseq fileFow10s label [mc "+10 seconds"]
	dict set ::keyseq fileFow1m name Shift+Right
	dict set ::keyseq fileFow1m seq <Shift-Key-Right>
	dict set ::keyseq fileFow1m label [mc "+1 minute"]
	dict set ::keyseq fileFow10m name Ctrl+Shift+Right
	dict set ::keyseq fileFow10m seq <Control-Shift-Key-Right>
	dict set ::keyseq fileFow10m label [mc "+10 minutes"]
	dict set ::keyseq fileHome name Home
	dict set ::keyseq fileHome seq <Key-Home>
	dict set ::keyseq fileHome label [mc "File beginning"]
	dict set ::keyseq fileEnd name End
	dict set ::keyseq fileEnd seq <Key-End>
	dict set ::keyseq fileEnd label [mc "File end"]
	
	if {[file exists "$::option(home)/config/key-sequences.key"]} {
		set open_key_file [open "$::option(home)/config/key-sequences.key" r]
		while {[gets $open_key_file line]!=-1} {
			if {[string match #* $line] || [string trim $line] == {}} continue
			puts "line proc_key_file $line"
			dict set ::keyseq {*}$line
		}
	} else {
		catch {log_writeOutTv 0 "Using standard key sequences"}
	}
}
