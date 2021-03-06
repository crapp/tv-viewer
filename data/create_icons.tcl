#       create_icons.tcl
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

proc create_icons {} {
	# loads all icons and makes them accessible. either png or gif format
	puts $::main(debug_msg) "\033\[0;1;33mDebug: create_icons \033\[0m"
	log_writeOut ::log(tvAppend) 0 "Creating icons for TV-Viewer."
	set fileExtension "gif"
	if {[package vcompare [info patchlevel] 8.6] == -1} {
		set status_img [catch {package require Img} resultat_img]
		#FIXME Create icons is missing a routine if an icon does not exist.
		if { $status_img != 0 } {
			log_writeOut ::log(tvAppend) 1 "Your version of Tcl/Tk doesn't support png."
			log_writeOut ::log(tvAppend) 1 "Install tkimg (libtk-img) to get high quality icons."
			set fileExtension "gif"
		} else {
			log_writeOut ::log(tvAppend) 0 "Found package tkimg, using png icons"
			set fileExtension "png"
		}
	} else {
		log_writeOut ::log(tvAppend) 0 "Found Tcl/Tk >=8.6 , using png icons."
		set fileExtension "png"
	}
	foreach ic [split [glob $::option(root)/icons/16x16/*.$fileExtension]] {
		set ::icon_s([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
		set ::icon_men([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic" -width 20]
	}
	foreach ic [split [glob $::option(root)/icons/22x22/*.$fileExtension]] {
		set ::icon_m([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
	}
	foreach ic [split [glob $::option(root)/icons/32x32/*.$fileExtension]] {
		set ::icon_b([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
	}
	foreach ic [split [glob $::option(root)/icons/extras/*.$fileExtension]] {
		set ::icon_e([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
	}
	# Creating a special icon for choosing font color and an arrow-down image
	set ::icon_e(pick-color3) [image create bitmap -file "$::option(root)/icons/extras/pick-color3.xbm"]
	set ::icon_e(arrow-d) [image create photo -file "$::option(root)/icons/extras/arrow-d.gif"]
}
