#       agrep.tcl
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

proc agrep {switch input modifier} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: agrep \033\[0m \{$switch\} \{$modifier\}"}
	foreach line [split "$input" \n] {
		if {"$switch" == "-m"} {
			if {[string match -nocase *$modifier "$line"] || [string match -nocase *$modifier* "$line"] || [string match -nocase $modifier* "$line"]} {
				lappend return_value "$line"
			}
		}
		if {"$switch" == "-w"} {
			if {[lsearch "$line" "$modifier"] != -1} {
				lappend return_value "$line"
			}
		}
	}
	if {[info exists return_value]} {
		if {[llength $return_value] > 1} {
			set return_value [join $return_value \n]
			return -code 0 "$return_value"
		} else {
			set return_value [join $return_value]
			return -code 0 "$return_value"
		}
	} else {
		return -code 1 "agrep could not find $modifier in $input"
	}
}
