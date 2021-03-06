#       main_command_line_options.tcl
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

proc start_options {} {
	array set ::start_options {--help 0 --version 0 --debug 0}
	foreach command_argument $::argv {
		if {[string first = $command_argument] == -1 } {
			set i [string first - $command_argument]
			set key $command_argument
			set ::start_options($key) 1
		} else {
			set i [string first = $command_argument]
			set key [string range $command_argument 0 [expr {$i-1}]]
			set value [string range $command_argument [expr {$i+1}] end]
			set ::start_options($key) 1
			set ::values($key) $value
		}
	}
	if {[array size ::start_options] != 3} {
		puts "
TV-Viewer [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]
	
Unkown option(s): $::argv

Possible options are:

  --debug     Prints debug messages to stdout.
  --version   Shows the version of TV-Viewer, Tcl/Tk as well as
			  some infos about your machine.
  --help      Displays this help.
"
		exit 1
	}
	if {$::start_options(--help)} {
		puts "
TV-Viewer [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]

Possible options are:

  --debug     Prints debug messages to stdout.
  --version   Shows the version of TV-Viewer, Tcl/Tk as well as
			  some infos about your machine.
  --help      Displays this help.
"
		exit 0
	}
	if {$::start_options(--version)} {
		if {[file exists [glob -nocomplain /etc/*release]]} {
			if {[llength [glob -nocomplain /etc/*release]] > 1} {
				foreach relf [glob -nocomplain /etc/*release] {
					set df [open $relf r]
					set distri [read $df]
					lappend distri2 "$distri"
					close $df
				}
			} else {
				set distri [open [glob -nocomplain /etc/*release] r]
				set distri2 [read $distri]
			}
			if {[string trim $distri2] == {}} {
				set distri2 "Distribution unknown"
			}
		} else {
			set distri2 "Distribution unknown"
		}
		puts "
Found TV-Viewer    [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]
Found Tcl/Tk       [info patchlevel]
Machine:           [exec uname -m]

OS:    

[exec uname -s] [exec uname -r]
$distri2
"
		exit 0
	}
	if {$::start_options(--debug)} {
		set ::main(debug_msg) stdout
		puts "Activating debug messages"
	} else {
		set ::main(debug_msg) [open /dev/null a]
		fconfigure $::main(debug_msg) -blocking no -buffering line
	}
}
