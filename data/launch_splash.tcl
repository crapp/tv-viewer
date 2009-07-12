#       launch_splash.tcl
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

proc launch_splash_screen {} {
	puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Launching splash screen..."
	flush $::logf_tv_open_append
	set window .splash
	set window [toplevel .splash -borderwidth 0 -relief raised -highlightthickness 0]
	frame $window.f -background #414141
	pack $window.f -fill both -expand 1
	set w $window.f
	label $w.img -image $::icon_e(logo_splash_tux_tv-viewer08x) -borderwidth 0
	grid $w.img
	wm overrideredirect $window 1
	::tk::PlaceWindow $window
	update
}
