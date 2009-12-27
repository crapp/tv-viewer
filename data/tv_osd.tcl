#       tv_osd.tcl
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

proc tv_osd {ident atime osd_text} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_osd \033\[0m \{$ident\} \{$atime\} \{$osd_text\}"
	if {[info exists ::data(after_id_osd)]} {
		foreach id [split $::data(after_id_osd)] {
			after cancel $id
		}
		unset -nocomplain ::data(after_id_osd)
		destroy .tv.osd
	}
	array set alignment {
		0 {-anchor nw -x 10 -y 10}
		1 {-anchor n -relx 0.5 -y 10}
		2 {-anchor ne -relx 1.0 -x -10 -y 10}
		3 {-anchor w -rely 0.5 -x 10}
		4 {-anchor center -relx 0.5 -rely 0.5}
		5 {-anchor e -relx 1.0 -rely 0.5 -x -10}
		6 {-anchor sw -rely 1.0 -x 10 -y -10}
		7 {-anchor s -relx 0.5 -rely 1.0 -y -10}
		8 {-anchor se -relx 1.0 -rely 1.0 -x -10 -y -10}
	}
	set font "[lindex $::option($ident) 1]"
	set style "[string tolower [lindex $::option($ident) 2]]"
	set size [lindex $::option($ident) 3]
	set bias [lindex $::option($ident) 4]
	set color [lindex $::option($ident) 5]
	
	set osd [frame .tv.osd -bg #004AFF -padx 5 -pady 5]
	pack [label $osd.label -bg white -fg $color -text "$osd_text" -justify left]
	
	if {"$style" == "regular"} {
		$osd.label configure -font "{$font} $size"
	} else {
		$osd.label configure -font "{$font} $size {$style}"
	}
	
	place $osd -in .tv {*}$alignment($bias)
	set ::data(after_id_osd) [after $atime "destroy .tv.osd"]
	log_writeOutTv 0 "OSD invoked, ident: $ident, time: $atime, text: $osd_text"
}
