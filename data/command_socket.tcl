#       log_viewer.tcl
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

proc command_socket {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: command_socket \033\[0m"}
	if {[file exists "$::option(where_is_home)/tmp/comSocket.tmp"] == 0} {
		set comsocket [open "$::option(where_is_home)/tmp/comSocket.tmp" w]
		close $comsocket
	} else {
		if {"$::option(appname)" == "tv-viewer_main"} {
			set status_schedlinkread [catch {file readlink "$::option(where_is_home)/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
			if { $status_schedlinkread == 0 } {
				catch {exec ps -eo "%p"} readpid_sched
				set status_greppid_sched [catch {agrep -w "$readpid_sched" $resultat_schedlinkread} resultat_greppid_sched]
				if { $status_greppid_sched == 0 } {
					log_writeOutTv 0 "Scheduler is running, will stop it."
					catch {exec kill $resultat_schedlinkread}
					catch {file delete "$::option(where_is_home)/tmp/scheduler_lockfile.tmp"}
					after 3000 {catch {exec "$::where_is/data/record_scheduler.tcl" &}}
				}
			}
			catch {file delete "$::option(where_is_home)/tmp/comSocket.tmp"}
			set comsocket [open "$::option(where_is_home)/tmp/comSocket.tmp" w]
			close $comsocket
		}
	}
	set comsocket [open "$::option(where_is_home)/tmp/comSocket.tmp" r]
	seek $comsocket 0 end
	set position [tell $comsocket]
	close $comsocket
	set ::data(comsocket) [open "$::option(where_is_home)/tmp/comSocket.tmp" a]
	puts ":data(comsocket) $:data(comsocket)"
	fconfigure $::data(comsocket) -blocking no -buffering line
	set ::data(comsocket_id) [after 100 [list command_getData "$::option(where_is_home)/tmp/comSocket.tmp" $position]]
}

proc command_getData {comfile position} {
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
	set ::data(comsocket_id) [after 20 [list command_getData $comfile $position]]
}
