#       difftime.tcl
#       © Copyright 2007-2012 Christian Rapp <christianrapp@users.sourceforge.net>
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


proc difftimeClockarith { seconds delta units } {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: difftimeClockarith \033\[0m \{$seconds\} \{$delta\} \{$units\}"}
	set stamp [clock format $seconds -format "%Y%m%d"]
	if { $delta < 0 } {
		append stamp " " - [expr { - $delta }] " " $units
	} else {
		append stamp "+ " $delta " " $units
	}
	return [clock scan $stamp]
}

proc difftime { s1 s2 } {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: difftime \033\[0m \{$s1\} \{$s2\}"}

	set y1 [clock format $s1 -format %Y]
	set y2 [clock format $s2 -format %Y]
	set y [expr { $y1 - $y2 - 1 }]

	set s2new $s2
	set yOut $y

	set s [difftimeClockarith $s2 $y years]
	while { $s <= $s1 } {
		set s2new $s
		set yOut $y
		incr y
		set s [difftimeClockarith $s2 $y years]
	}
	set s2 $s2new

	set m 0
	set mOut 0
	set s [difftimeClockarith $s2 $m months]
	while { $s <= $s1 } {
		set s2new $s
		set mOut $m
		incr m
		set s [difftimeClockarith $s2 $m months]
	}
	set s2 $s2new

	set d [expr { ( ( $s2 - $s1 ) / 86400 ) - 1 }]
	set dOut $d
	set s [difftimeClockarith $s2 $d days]
	while { $s <= $s1 } {
		set s2new $s
		set dOut $d
		incr d
		set s [difftimeClockarith $s2 $d days]
	}
	set s2 $s2new

	return [list $yOut $mOut $dOut]
}
