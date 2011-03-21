#       vid_file_calc.tcl
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

proc vid_fileComputeSize {seconds} {
	if {"$seconds" == "cancel"} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_fileComputeSize \033\[0;1;31m::cancel:: \033\[0m"
		if {[info exists ::data(file_sizeid)]} {
			foreach id $::data(file_sizeid) {
				catch {after cancel $id}
			}
		}
		unset -nocomplain ::data(file_size)
		return
	}
	if {"$seconds" == "cancel_rec"} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_fileComputeSize ::cancel_rec:: \033\[0m"
		catch {after cancel $::data(file_sizeid)}
		return
	}
	set ::data(file_size) [expr [clock seconds] - $seconds]
	set ::data(file_sizeid) [after 100 [list vid_fileComputeSize $seconds]]
}

proc vid_fileComputePos {stop} {
	if {"$stop" == "cancel"} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_fileComputePos \033\[0;1;31m::cancel:: \033\[0m"
		if {[info exists ::data(file_posid)]} {
			foreach id $::data(file_posid) {
				catch {after cancel $id}
			}
		}
		unset -nocomplain ::data(file_posid)
		return
	}
	if {[.ftoolb_Play.bPause instate disabled] == 0} {
		set ::data(file_pos) [expr [clock seconds] - $::data(file_pos_calc)]
		set lhours [expr ($::data(file_pos)%86400)/3600]
		if {[string length $lhours] < 2} {
			set lhours "0$lhours"
		}
		set lmins [expr ($::data(file_pos)%3600)/60]
		if {[string length $lmins] < 2} {
			set lmins "0$lmins"
		}
		set lsecs [expr $::data(file_pos)%60]
		if {[string length $lsecs] < 2} {
			set lsecs "0$lsecs"
		}
		if {[info exists ::data(file_size)]} {
			set shours [expr ($::data(file_size)%86400)/3600]
			if {[string length $shours] < 2} {
				set shours "0$shours"
			}
			set smins [expr ($::data(file_size)%3600)/60]
			if {[string length $smins] < 2} {
				set smins "0$smins"
			}
			set ssecs [expr $::data(file_size)%60]
			if {[string length $ssecs] < 2} {
				set ssecs "0$ssecs"
			}
			if {"$::main(label_file_time)" != "$lhours:$lmins:$lsecs / $shours:$smins:$ssecs"} {
				set ::main(label_file_time) "$lhours:$lmins:$lsecs / $shours:$smins:$ssecs"
			}
		}  else {
			if {"$::main(label_file_time)" != "$lhours:$lmins:$lsecs / 00:00:00"} {
				set ::main(label_file_time) "$lhours:$lmins:$lsecs / 00:00:00"
			}
		}
		if {[info exists ::data(file_posid)]} {
			foreach id $::data(file_posid) {
				catch {after cancel $id}
			}
		}
		unset -nocomplain ::data(file_posid)
		lappend ::data(file_posid) [after 50 [list vid_fileComputePos 0]]
	} else {
		set lhours [expr ($::data(file_pos)%86400)/3600]
		if {[string length $lhours] < 2} {
			set lhours "0$lhours"
		}
		set lmins [expr ($::data(file_pos)%3600)/60]
		if {[string length $lmins] < 2} {
			set lmins "0$lmins"
		}
		set lsecs [expr $::data(file_pos)%60]
		if {[string length $lsecs] < 2} {
			set lsecs "0$lsecs"
		}
		if {[info exists ::data(file_size)]} {
			set shours [expr ($::data(file_size)%86400)/3600]
			if {[string length $shours] < 2} {
				set shours "0$shours"
			}
			set smins [expr ($::data(file_size)%3600)/60]
			if {[string length $smins] < 2} {
				set smins "0$smins"
			}
			set ssecs [expr $::data(file_size)%60]
			if {[string length $ssecs] < 2} {
				set ssecs "0$ssecs"
			}
			if {"$::main(label_file_time)" != "$lhours:$lmins:$lsecs / $shours:$smins:$ssecs"} {
				set ::main(label_file_time) "$lhours:$lmins:$lsecs / $shours:$smins:$ssecs"
			}
		} else {
			if {"$::main(label_file_time)" != "$lhours:$lmins:$lsecs / 00:00:00"} {
				set ::main(label_file_time) "$lhours:$lmins:$lsecs / 00:00:00"
			}
		}
		if {[info exists ::data(file_posid)]} {
			foreach id $::data(file_posid) {
				catch {after cancel $id}
			}
		}
		unset -nocomplain ::data(file_posid)
		lappend ::data(file_posid) [after 50 [list vid_fileComputePos 0]]
	}
}
