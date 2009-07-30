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
	puts $::main(debug_msg) "\033\[0;1;33mDebug: launch_splash_screen \033\[0m"
	puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Launching splash screen..."
	flush $::logf_tv_open_append
	set img_list [launch_splashAnigif "$::where_is/icons/extras/animated_loading.gif"]
	set w [toplevel .splash -borderwidth 0 -relief raised -highlightthickness 0]
	set f_img [frame $w.f_img -background #414141]
	set f_pb [frame $w.f_pb -background #414141]
	label $f_img.l -image $::icon_e(logo-tv-viewer08x-noload) -borderwidth 0
	label $f_pb.l -image [lindex $img_list 0] -borderwidth 0 -background #414141 -foreground #414141
	
	grid $f_img -in $w -row 0 -column 0 \
	-sticky nesw
	grid $f_img.l -in $f_img -row 0 -column 0 \
	-sticky nesw
	grid $f_pb.l -in $f_pb -row 0 -column 0 \
	-sticky nesw
	grid rowconfigure $f_img 0 -weight 1
	grid rowconfigure $f_pb 0 -weight 1
	grid columnconfigure $f_img 0 -weight 1
	grid columnconfigure $f_pb 0 -weight 1
	
	wm overrideredirect $w 1
	::tk::PlaceWindow $w
	tkwait visibility $w
	place $f_pb -in $w -anchor se -relx 1.0 -rely 1.0 -x -4 -y -3
	set img_list_length [llength $img_list]
	after 0 [list launch_splashPlay $img_list $img_list_length 1 $f_pb.l]
}

proc launch_splashAnigif {gif} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: launch_splashAnigif \033\[0m \{$gif\}"
	set index 0
	set results {}
	while 1 {
		if [catch {
			image create photo -file $gif -format "gif -index $index"
		} res] {
			return $results
		}
		lappend results $res
		incr index
	}
}

proc launch_splashPlay {img_list img_list_length index container} {
	if {"$img_list" == "cancel"} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: launch_splashPlay \033\[0;1;31m::cancel:: \033\[0m"
		catch {after cancel $::splash(after_id)}
		unset -nocomplain ::splash(after_id)
		return
	}
	if {$img_list_length == $index} {
		set index 0
	}
	$container configure -image [lindex $img_list $index]
	set ::splash(after_id) [after 100 [list launch_splashPlay $img_list $img_list_length [incr index] $container]]
}
