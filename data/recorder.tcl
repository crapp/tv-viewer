#!/usr/bin/env tclsh

#       recorder.tcl
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

package require Tcl 8.5

set ::option(appname) tv-viewer_recorder

set option(root) "[file dirname [file dirname [file normalize [file join [info script] bogus]]]]"
set option(home) "$::env(HOME)/.tv-viewer"

source "$option(root)/agrep.tcl"

proc recorderCheckMain {com fdin fdout} {
	if {"$com" == "cancel"} {
		
		return
	}
	set status [catch {file readlink "$::option(home)/tmp/lockfile.tmp"} result]
	if {$status == 0} {
		catch {exec ps -eo "%p"} read_pid
		set status_greppid [catch {agrep -w "$read_pid" $result} result_greppid]
		if { $status_greppid != 0 } {
			catch { chan close $fdin }
			catch { chan close $fdout }
			puts "Recorder error: Main app died while running timeshift."
			exit 1
		} else {
			after 1000 [list recorderCheckMain 0 $fdin $fdout]
		}
	} else {
		# Main is dead but recorder is doing timeshift. This is not
		# possible.
		catch { chan close $fdin }
		catch { chan close $fdout }
		puts "Recorder error: Main app died while running timeshift."
		exit 1
	}
}

proc recorderShowProgress { fdin fdout size bytes {error ""} } {
	if { $error != "" } {
		catch { chan close $fdin }
		catch { chan close $fdout }
		puts "Recorder error: $error"
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
		exit 0
	}
} else {
	after 1000 [list recorderCheckMain 0 $fdin $fdout]
}
vwait forever
