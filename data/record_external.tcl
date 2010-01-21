#!/usr/bin/env tclsh

#       record_external.tcl
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

set option(root) "[file dirname [file dirname [file dirname [file normalize [file join [info script] bogus]]]]]"
set option(home) "$::env(HOME)/.tv-viewer"
set option(appname) "tv-viewer_recext"

set option(release_version) {0.8.1.1 76 21.01.2010}

set main(debug_msg) [open /dev/null a]

source $option(root)/data/main_read_config.tcl
source $option(root)/data/main_read_station_file.tcl
source $option(root)/data/log_viewer.tcl
source $option(root)/data/command_socket.tcl
source $option(root)/data/record_handler.tcl

main_readConfig

if {[file exists "$::option(home)/log/tvviewer.log"]} {
	if {$::option(log_files) == 1} {
		set logf_tv_open_append [open $::option(home)/log/tvviewer.log a]
		fconfigure $logf_tv_open_append -blocking no -buffering line
	} else {
		set logf_tv_open_append [open /dev/null a]
		fconfigure $logf_tv_open_append -blocking no -buffering line
	}
} else {
	set logf_tv_open_append [open /dev/null a]
	fconfigure $logf_tv_open_append -blocking no -buffering line
}

main_readStationFile
command_socket

array set start_options {duration 0 start_time 0 start_date 0 title 0 resolution 0 path 0 station_ext 0}
foreach command_argument $argv {
	if {[string first = $command_argument] == -1 } {
		set i [string first - $command_argument]
		set key $command_argument
		set start_options($key) 1
	} else {
		set i [string first = $command_argument]
		set key [string range $command_argument 0 [expr {$i-1}]]
		set value [string range $command_argument [expr {$i+1}] end]
		set start_options($key) 1
		set start_values($key) $value
	}
}

if {[array size start_options] != 7} {
	#~ log_writeOutTv 2 "External record scheduler received unknown command $argv"
	#~ log_writeOutTv 2 "See the userguide for possible actions."
	puts "unknown commands"
	exit 1
}

if {$start_options(duration)} {
	if {[info exists start_values(duration)] && [string is integer $start_values(duration)]} {
		set seconds $start_values(duration)
		set record(duration_hour) [expr $seconds / 3600]
		set record(duration_min) [expr ($seconds - ($record(duration_hour) * 3600)) / 60]
		set record(duration_sec) [expr ($seconds - ($record(duration_hour) * 3600) - ($record(duration_min) * 60))]
	} else {
		log_writeOutTv 2 "External record scheduler: You need to specifiy an integer value for the duration."
		exit 1
	}
} else {
	log_writeOutTv 2 "External record scheduler: You need to specify an integer value for the duration."
	exit 1
}

set record(time_hour) [clock format [clock scan $start_values(start_time)] -format %H]
set record(time_min) [clock format [clock scan $start_values(start_time)] -format %M]
set record(date) $start_values(start_date)
set record(resolution_width) 720
if {"$::option(video_standard)" == "NTSC"} {
	set record(resolution_height) 480
} else {
	set record(resolution_height) 576
}
set record(lbcontent) $kanalid($start_values(station_ext))
set title [string map {{ } {_}} "$start_values(title)"]
set record(file) "$option(rec_default_path)/$title.mpeg"
set tree .record_wizard.tree_frame.tv_rec 
set lb .record_wizard.add_edit.listbox_frame.lb_stations 
set w .record_wizard.add_edit
set handler add

record_applyEndgame $tree $lb $start_values(duration) $w $handler 

exit 0
