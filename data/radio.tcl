#       radio.tcl
#       © Copyright 2007-2010 Christian Rapp <christianrapp@users.sourceforge.net>
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

proc radio_ui {} {
	# The main ui for the radio interface
	if {[winfo exists .radio]} {
		#FIXME - Only "return" here or destroy radio interface
		log_writeOutTv 1 "Radio interface already running"
		return
	}
	#FIXME Fill with content, integrate with new interface. Make it a mode of the new interface.
	set rd [toplevel .radio -class "TV-Viewer"]
	place [ttk::frame $rd.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
	
}
