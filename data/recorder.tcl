#!/usr/bin/env tclsh

#       recorder.tcl
#       © Copyright 2007-2013 Christian Rapp <christianrapp@users.sourceforge.net>
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

set ::option(appname) tv-viewer_recorder

set option(root) "[file dirname [file dirname [file normalize [file join [info script] bogus]]]]"
set option(home) "$::env(HOME)/.tv-viewer"

source $option(root)/init.tcl

init_pkgReq "0"
init_autoPath
init_tclKit
init_source "$option(root)" "agrep.tcl monitor.tcl command_socket.tcl process_config.tcl"

process_configRead

proc recorderCheckMain {com fdin fdout} {
	if {"$com" == "cancel"} {
		
		return
	}
	set status_main [monitor_partRunning 1]
	if {[lindex $status_main 0] == 0} {
		# Main is dead but recorder is doing timeshift. This is not
		# possible.
		catch { chan close $fdin }
		catch { chan close $fdout }
		puts "recorder error: Main app died while running timeshift."
		exit 1
	} else {
		after 1000 [list recorderCheckMain 0 $fdin $fdout]
	}
}

proc recorderShowProgress { fdin fdout size bytes {error ""} } {
	if { $error != "" } {
		catch { chan close $fdin }
		catch { chan close $fdout }
		puts "recorder error: $error"
		exit 1
	}
	if { [eof $fdin] } {
		catch { chan close $fdin }
		catch { chan close $fdout }
	} else {
		after idle [list fcopy $fdin $fdout -size $size \
		-command [list recorderShowProgress $fdin $fdout $size]]
	}
}

set filename [lindex $::argv 0]
set bufsize  8192
set lifespan [lindex $::argv 2]
set fdin  [open [lindex $::argv 1] r]
set fdout [open $filename w]
set jobid [lindex $::argv 3]

catch {exec ps -eo "%p %a"} read_ps
set status [catch {agrep -w "$read_ps" [lindex $::argv 1]} result]
if {$status == 0} {
	foreach line [split $result \n] {
		set status [catch {agrep -m "$line" mplayer} result]
		if {$status == 0} {
			catch {exec kill [lindex $line 0]}
			puts "recorder error: killing MPlayer PID [lindex $line 0] this should not be necessary"
		}
	}
}

command_socket
if {"$lifespan" != "infinite"} {
	if {$::option(notify)} {
		set status_notify [monitor_partRunning 5]
		if {[lindex $status_notify 0] == 0} {
			if {$::option(tclkit) == 1} {
				set ntfy_pid [exec $::option(tclkit_path) $::option(root)/notifyd.tcl &]
			} else {
				set ntfy_pid [exec $::option(root)/notifyd.tcl &]
			}
			puts "notification daemon started, PID $ntfy_pid"
		}
	}
}

foreach chan [list $fdin $fdout] {
		chan configure $chan -encoding binary \
		-translation binary -buffersize $bufsize
}
chan copy $fdin $fdout -size $bufsize \
-command [list recorderShowProgress $fdin $fdout $bufsize]
if {"$lifespan" != "infinite"} {
	after [expr {$lifespan * 1000}] {
		catch { chan close $fdin }
		catch { chan close $fdout }
		catch {file delete -force "$::option(home)/tmp/record_lockfile.tmp"}
		set status_main [monitor_partRunning 1]
		if {[lindex $status_main 0]} {
			command_WritePipe 0 "tv-viewer_notifyd notifydId"
			command_WritePipe 0 [list tv-viewer_notifyd notifydUi 1 $::option(notifyPos) $::option(notifyTime) 0 " " "Recording finished" "Recording of job % has been finished" $jobid]
		} else {
			command_WritePipe 0 "tv-viewer_notifyd notifydId"
			command_WritePipe 0 [list tv-viewer_notifyd notifydUi 1 $::option(notifyPos) $::option(notifyTime) 1 "Start TV-Viewer" "Recording finished" "Recording of job % has been finished" $jobid]
		}
		exit 0
	}
} else {
	after 1000 [list recorderCheckMain 0 $fdin $fdout]
}

vwait forever
