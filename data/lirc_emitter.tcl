#!/usr/bin/env tclsh

#       lirc_emitter.tcl
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

package require Tcl 8.5

#~ wm withdraw .

#set processing_folder [file dirname [file normalize [info script]]]
if {[file type [info script]] == "link" } {
	set where_is [file dirname [file normalize [file readlink [info script]]]]
} else {
	set where_is [file dirname [file normalize [info script]]]
}
set option(where_is_home) "$::env(HOME)/.tv-viewer"

set option(release_version) {0.8.1b3 44 15.12.2009}

source $where_is/main_read_config.tcl
source $where_is/log_viewer.tcl

main_readConfig

if {[file exists "$::option(where_is_home)/log/tvviewer.log"]} {
	if {$::option(log_files) == 1} {
		set logf_tv_open_append [open $::option(where_is_home)/log/tvviewer.log a]
		fconfigure $logf_tv_open_append -blocking no -buffering line
	} else {
		set logf_tv_open_append [open /dev/null a]
		fconfigure $logf_tv_open_append -blocking no -buffering line
	}
} else {
	set logf_tv_open_append [open /dev/null a]
	fconfigure $logf_tv_open_append -blocking no -buffering line
}

if {[file exists "$::option(where_is_home)/tmp/comSocket.tmp"]} {
	set comsocket [open "$::option(where_is_home)/tmp/comSocket.tmp" a]
	fconfigure $comsocket -blocking no -buffering line
} else {
	log_writeOutTv 2 "comSocket.tmp does not exist. Can't send commands to main application."
	exit 1
}

array set start_options {teleview 0 station_up 0 station_down 0 station_jump 0 key_0 0 key_1 0 key_2 0 key_3 0 key_4 0 key_5 0 key_6 0 key_7 0 key_8 0 key_9 0 slist_osd 0 slist_osd_up 0 slist_osd_down 0 fullscreen 0 quit 0 zoom_incr 0 zoom_decr 0 zoom_auto 0 size_stnd 0 size_double 0 move_up 0 move_down 0 move_left 0 move_right 0 move_center 0 record 0 timeshift 0 volume_incr 0 volume_decr 0 mute 0 forward_10s 0 forward_1m 0 forward_10m 0 forward_end 0 rewind_10s 0 rewind_1m 0 rewind_10m 0 rewind_start 0 pause 0 stop 0 start 0}
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
		set values($key) $value
	}
}

if {[array size ::start_options] != 45} {
	log_writeOutTv 2 "Lirc emitter received unknown command $argv"
	log_writeOutTv 2 "See the userguide for possible actions."
	exit 1
}
if {$start_options(teleview)} {
	puts $comsocket "tv-viewer_main event generate . <<teleview>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal teleview"
	exit 0
}
if {$start_options(station_up)} {
	puts $comsocket "tv-viewer_main event generate . <<station_up>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal station_up"
	exit 0
}
if {$start_options(station_down)} {
	puts $comsocket "tv-viewer_main event generate . <<station_down>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal station_down"
	exit 0
}
if {$start_options(station_jump)} {
	puts $comsocket "tv-viewer_main event generate . <<station_jump>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal station_jump"
	exit 0
}
if {$start_options(key_0)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 0"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal key_0"
	exit 0
}
if {$start_options(key_1)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 1"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal key_1"
	exit 0
}
if {$start_options(key_2)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 2"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal key_2"
	exit 0
}
if {$start_options(key_3)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 3"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal key_3"
	exit 0
}
if {$start_options(key_4)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 4"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal key_4"
	exit 0
}
if {$start_options(key_5)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 5"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal key_5"
	exit 0
}
if {$start_options(key_6)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 6"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal key_6"
	exit 0
}
if {$start_options(key_7)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 7"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal key_7"
	exit 0
}
if {$start_options(key_8)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 8"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal key_8"
	exit 0
}
if {$start_options(key_9)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 9"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal key_9"
	exit 0
}
if {$start_options(slist_osd)} {
	puts $comsocket "tv-viewer_main tv_slistLirc"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal slist_osd"
	exit 0
}
if {$start_options(slist_osd_up)} {
	puts $comsocket "tv-viewer_main tv_slistLircMoveUp"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal slist_osd_up"
	exit 0
}
if {$start_options(slist_osd_down)} {
	puts $comsocket "tv-viewer_main tv_slistLircMoveDown"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal slist_osd_down"
	exit 0
}
if {$start_options(fullscreen)} {
	puts $comsocket "tv-viewer_main tv_wmFullscreen .tv .tv.bg.w .tv.bg"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal fullscreen"
	exit 0
}
if {$start_options(quit)} {
	puts $comsocket "tv-viewer_main main_frontendExitViewer"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal quit"
	exit 0
}
if {$start_options(zoom_incr)} {
	puts $comsocket "tv-viewer_main tv_wmPanscan .tv.bg.w 1"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal zoom_incr"
	exit 0
}
if {$start_options(zoom_decr)} {
	puts $comsocket "tv-viewer_main tv_wmPanscan .tv.bg.w -1"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal zoom_decr"
	exit 0
}
if {$start_options(zoom_auto)} {
	puts $comsocket "tv-viewer_main tv_wmPanscanAuto"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal zoom_auto"
	exit 0
}
if {$start_options(size_stnd)} {
	puts $comsocket "tv-viewer_main tv_wmGivenSize .tv.bg 1"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal size_stnd"
	exit 0
}
if {$start_options(size_double)} {
	puts $comsocket "tv-viewer_main tv_wmGivenSize .tv.bg 2"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal size_double"
	exit 0
}
if {$start_options(move_right)} {
	puts $comsocket "tv-viewer_main tv_wmMoveVideo 0"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal move_right"
	exit 0
}
if {$start_options(move_down)} {
	puts $comsocket "tv-viewer_main tv_wmMoveVideo 1"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal move_down"
	exit 0
}
if {$start_options(move_left)} {
	puts $comsocket "tv-viewer_main tv_wmMoveVideo 2"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal move_left"
	exit 0
}
if {$start_options(move_up)} {
	puts $comsocket "tv-viewer_main tv_wmMoveVideo 3"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal move_up"
	exit 0
}
if {$start_options(move_center)} {
	puts $comsocket "tv-viewer_main tv_wmMoveVideo 4"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal move_center"
	exit 0
}
if {$start_options(record)} {
	puts $comsocket "tv-viewer_main event generate . <<record>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal record"
	exit 0
}
if {$start_options(timeshift)} {
	puts $comsocket "tv-viewer_main event generate . <<timeshift>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal timeshift"
	exit 0
}
if {$start_options(volume_incr)} {
	puts $comsocket "tv-viewer_main event generate . <<volume_incr>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal volume_incr"
	exit 0
}
if {$start_options(volume_decr)} {
	puts $comsocket "tv-viewer_main event generate . <<volume_decr>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal volume_decr"
	exit 0
}
if {$start_options(mute)} {
	puts $comsocket "tv-viewer_main tv_playerVolumeControl .bottom_buttons mute"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal mute"
	exit 0
}
if {$start_options(forward_10s)} {
	puts $comsocket "tv-viewer_main event generate .tv <<forward_10s>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal forward_10s"
	exit 0
}
if {$start_options(forward_1m)} {
	puts $comsocket "tv-viewer_main event generate .tv <<forward_1m>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal forward_1m"
	exit 0
}
if {$start_options(forward_10m)} {
	puts $comsocket "tv-viewer_main event generate .tv <<forward_10m>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal forward_10m"
	exit 0
}
if {$start_options(forward_end)} {
	puts $comsocket "tv-viewer_main event generate .tv <<forward_end>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal forward_end"
	exit 0
}
if {$start_options(rewind_10s)} {
	puts $comsocket "tv-viewer_main event generate .tv <<rewind_10s>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal rewind_10s"
	exit 0
}
if {$start_options(rewind_1m)} {
	puts $comsocket "tv-viewer_main event generate .tv <<rewind_1m>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal rewind_1m"
	exit 0
}
if {$start_options(rewind_10m)} {
	puts $comsocket "tv-viewer_main event generate .tv <<rewind_10m>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal rewind_10m"
	exit 0
}
if {$start_options(rewind_start)} {
	puts $comsocket "tv-viewer_main event generate .tv <<rewind_start>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal rewind_start"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(pause)} {
	puts $comsocket "tv-viewer_main event generate .tv <<pause>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal pause"
	exit 0
}
if {$start_options(start)} {
	puts $comsocket "tv-viewer_main event generate .tv <<start>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal start"
	exit 0
}
if {$start_options(stop)} {
	puts $comsocket "tv-viewer_main event generate .tv <<stop>>"
	flush $comsocket
	log_writeOutTv 0 "Lirc emitter received Signal stop"
	exit 0
}
exit 1
