#       command_socket.tcl
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
	#TV-Viewer uses different fifos for communication between the
	#different parts of the program. Here all named pipes will be
	#created
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: command_socket \033\[0m"}	
	catch {exec mkfifo "$::option(home)/tmp/ComSocketSched"}
	catch {exec mkfifo "$::option(home)/tmp/ComSocketMain"}
	if {"$::option(appname)" == "tv-viewer_main"} {
		set ::data(comsocketRead) [open "$::option(home)/tmp/ComSocketMain" r+]
		set ::data(comsocketWrite) [open "$::option(home)/tmp/ComSocketSched" r+]
		fconfigure $::data(comsocketRead) -blocking 0 -buffering line
		fconfigure $::data(comsocketWrite) -blocking 0 -buffering line
		fileevent $::data(comsocketRead) readable [list command_getData log_writeOutTv]
	}
	if {"$::option(appname)" == "tv-viewer_scheduler"} {
		set ::data(comsocketRead) [open "$::option(home)/tmp/ComSocketSched" r+]
		set ::data(comsocketWrite) [open "$::option(home)/tmp/ComSocketMain" r+]
		fconfigure $::data(comsocketRead) -blocking 0 -buffering line
		fconfigure $::data(comsocketWrite) -blocking 0 -buffering line
		fileevent $::data(comsocketRead) readable [list command_getData scheduler_logWriteOut]
	}
	if {"$::option(appname)" == "tv-viewer_lirc" || "$::option(appname)" == "tv-viewer_diag"} {
		#~ set ::data(comsocketRead) [open "$::option(home)/tmp/ComSocketSched" r+]
		set ::data(comsocketWrite) [open "$::option(home)/tmp/ComSocketMain" r+]
		#~ fconfigure $::data(comsocketRead) -blocking 0 -buffering line
		fconfigure $::data(comsocketWrite) -blocking 0 -buffering line
		#~ fileevent $::data(comsocketRead) readable [list command_getData]
	}
}

proc command_getData {logw} {
	#Analyze data send through the named pipes.
	if {[info exists ::data(comsocketRead)]} {
		set status [catch { gets $::data(comsocketRead) line } result]
		if {[eof $::data(comsocketRead)]} {
			{*}$logw 2 "CommandSocket reached EOF."
			catch {close $::data(comsocketRead)}
			unset -nocomplain ::data(comsocketRead)
			return
		}
		if { $status != 0 } {
			{*}$logw 2 "Error reading $::data(comsocketRead): $result"
		} elseif { $result >= 0 } {
			# Successfully read the channel
			if {[string length [string trim $line]] > 0} {
				if {"[lindex $line 0]" == "$::option(appname)"} {
					set com [lrange $line 1 end]
					{*}$com
				}
			}
		} elseif { [fblocked $::data(comsocketRead)] } {
			# Read blocked.  Just return
		} else {
			# Something else
			{*}$logw 2 "Error in CommandSocket $::data(comsocketRead), unknown."
		}
	}
}

proc command_WritePipe {com} {
	#Write commands to the named pipes.
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: command_WritePipe \033\[0m \{$com\}"}
	if {[info exists ::data(comsocketWrite)] == 0} {return 1}
	if {[string trim $::data(comsocketWrite)] != {}} {
		puts -nonewline $::data(comsocketWrite) "$com \n"
		flush $::data(comsocketWrite)
		return 0
	} else {
		if {"$::option(appname)" == "tv-viewer_main"} {
			log_writeOutTv 2 "Can't access application command pipe."
		}
		if {"$::option(appname)" == "tv-viewer_scheduler"} {
			scheduler_logWriteOut 2 "Can't access application command pipe."
		}
		return 1
	}
}
