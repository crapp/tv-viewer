#       log_viewer.tcl
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

proc command_socket {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: command_socket \033\[0m"}
	if {"$::option(appname)" == "tv-viewer_main"} {
		set comsocket [open "$::option(where_is_home)/tmp/comSocket.tmp" w]
		close $comsocket
	}
	if {[file exists "$::option(where_is_home)/tmp/comSocket.tmp"]} {
		set comsocket [open "$::option(where_is_home)/tmp/comSocket.tmp" r]
		seek $comsocket 0 end
		set position [tell $comsocket]
		close $comsocket
		set ::data(comsocket) [open "$::option(where_is_home)/tmp/comSocket.tmp" a]
		fconfigure $::data(comsocket) -blocking no -buffering line
		set ::data(comsocket_id) [after 50 [list command_getData "$::option(where_is_home)/tmp/comSocket.tmp" $position]]
	}
}

proc command_getData {comfile position} {
	if {"$position" == "cancel"} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: command_getData \033\[0;1;31m::cancel:: \033\[0m"
		catch {after cancel $::data(comsocket_id)}
		unset -nocomplain ::data(comsocket_id)
		return
	}
	if {[file exists "$comfile"]} {
		set fh [open $comfile r]
		fconfigure $fh -blocking no -buffering line
		seek $fh $position start
		while {[eof $fh] == 0} {
			gets $fh line
			if {[string length $line] > 0} {
				if {"[lindex $line 0]" == "$::option(appname)"} {
					set com [lrange $line 1 end]
					{*}$com
				}
			}
		}
		set position [tell $fh]
		close $fh
		set ::data(comsocket_id) [after 50 [list command_getData $comfile $position]]
	} else {
		command_getData 0 cancel
	}
}
