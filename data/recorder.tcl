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

#set processing_folder [file dirname [file normalize [info script]]]
if {[file type [info script]] == "link" } {
	set where_is [file dirname [file normalize [file readlink [info script]]]]
} else {
	set where_is [file dirname [file normalize [info script]]]
}
set option(where_is_home) "$::env(HOME)/.tv-viewer"

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
		exit 0
	}
}
vwait forever
