#       create_icons.tcl
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

proc create_icons {} {
	puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Creating icons for TV-Viewer."
	flush $::logf_tv_open_append
	if {[package vcompare [info patchlevel] 8.6] == -1} {
		set status_img [catch {package require Img} resultat_img]
		if { $status_img != 0 } {
			puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Your version of Tcl/Tk doesn't support png.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Install tkimg (libtk-img) to get high quality icons."
			flush $::logf_tv_open_append
			foreach ic [split [glob $::where_is/icons/16x16/*.gif]] {
				set ::icon_s([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
			}
			foreach ic [split [glob $::where_is/icons/22x22/*.gif]] {
				set ::icon_m([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
			}
			foreach ic [split [glob $::where_is/icons/32x32/*.gif]] {
				set ::icon_b([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
			}
			foreach ic [split [glob $::where_is/icons/extras/*.gif]] {
				set ::icon_e([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
			}
		} else {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Found package tkimg, activating png support for icons."
			flush $::logf_tv_open_append
			foreach ic [split [glob $::where_is/icons/16x16/*.png]] {
				set ::icon_s([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
			}
			foreach ic [split [glob $::where_is/icons/22x22/*.png]] {
				set ::icon_m([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
			}
			foreach ic [split [glob $::where_is/icons/32x32/*.png]] {
				set ::icon_b([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
			}
			foreach ic [split [glob $::where_is/icons/extras/*.png]] {
				set ::icon_e([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
			}
		}
	} else {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Found Tcl/Tk >=8.6 , activating png support for icons."
		flush $::logf_tv_open_append
		foreach ic [split [glob $::where_is/icons/16x16/*.png]] {
			set ::icon_s([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
		}
		foreach ic [split [glob $::where_is/icons/22x22/*.png]] {
			set ::icon_m([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
		}
		foreach ic [split [glob $::where_is/icons/32x32/*.png]] {
			set ::icon_b([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
		}
		foreach ic [split [glob $::where_is/icons/extras/*.png]] {
			set ::icon_e([lindex [file split [file rootname $ic]] end]) [image create photo -file "$ic"]
		}
	}
	# Creating a special icon for choosing font color.
	set ::icon_e(pick-color3) [image create bitmap -file "$::where_is/icons/extras/pick-color3.xbm"]
	set ::icon_e(arrow-d) [image create photo -file "$::where_is/icons/extras/arrow-d.gif"]
}
