#!/usr/bin/env tclsh

#       lirc_emitter.tcl
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

set option(root) "[file dirname [file dirname [file normalize [file join [info script] bogus]]]]"
set option(home) "$::env(HOME)/.tv-viewer"
set option(appname) "tv-viewer_lirc"

set option(release_version) {0.8.1.1 83 01.04.2010}

source $option(root)/main_read_config.tcl
source $option(root)/log_viewer.tcl
source $option(root)/command_socket.tcl

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

command_socket

array set start_options {teleview 0 station_up 0 station_down 0 station_jump 0 key_0 0 key_1 0 key_2 0 key_3 0 key_4 0 key_5 0 key_6 0 key_7 0 key_8 0 key_9 0 station_nr 0 slist_osd 0 slist_osd_up 0 slist_osd_down 0 fullscreen 0 quit 0 zoom_incr 0 zoom_decr 0 zoom_auto 0 size_stnd 0 size_double 0 move_up 0 move_down 0 move_left 0 move_right 0 move_center 0 record 0 timeshift 0 volume_incr 0 volume_decr 0 mute 0 forward_10s 0 forward_1m 0 forward_10m 0 forward_end 0 rewind_10s 0 rewind_1m 0 rewind_10m 0 rewind_start 0 pause 0 stop 0 start 0}
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

if {[array size ::start_options] != 46} {
	log_writeOutTv 2 "Lirc emitter received unknown command $argv"
	log_writeOutTv 2 "See the userguide for possible actions."
	exit 1
}
set status [command_ReceiverRunning 1]
if {$status == 0} {
	log_writeOutTv 1 "Lirc emitter received signal while TV-Viewer is not running"
	exit 1
}
if {$start_options(teleview)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<teleview>>"
	log_writeOutTv 0 "Lirc emitter received Signal teleview"
	exit 0
}
if {$start_options(station_up)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_up>>"
	log_writeOutTv 0 "Lirc emitter received Signal station_up"
	exit 0
}
if {$start_options(station_down)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_down>>"
	log_writeOutTv 0 "Lirc emitter received Signal station_down"
	exit 0
}
if {$start_options(station_jump)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_jump>>"
	log_writeOutTv 0 "Lirc emitter received Signal station_jump"
	exit 0
}
if {$start_options(key_0)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 0"
	log_writeOutTv 0 "Lirc emitter received Signal key_0"
	exit 0
}
if {$start_options(key_1)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 1"
	log_writeOutTv 0 "Lirc emitter received Signal key_1"
	exit 0
}
if {$start_options(key_2)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 2"
	log_writeOutTv 0 "Lirc emitter received Signal key_2"
	exit 0
}
if {$start_options(key_3)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 3"
	log_writeOutTv 0 "Lirc emitter received Signal key_3"
	exit 0
}
if {$start_options(key_4)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 4"
	log_writeOutTv 0 "Lirc emitter received Signal key_4"
	exit 0
}
if {$start_options(key_5)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 5"
	log_writeOutTv 0 "Lirc emitter received Signal key_5"
	exit 0
}
if {$start_options(key_6)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 6"
	log_writeOutTv 0 "Lirc emitter received Signal key_6"
	exit 0
}
if {$start_options(key_7)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 7"
	log_writeOutTv 0 "Lirc emitter received Signal key_7"
	exit 0
}
if {$start_options(key_8)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 8"
	log_writeOutTv 0 "Lirc emitter received Signal key_8"
	exit 0
}
if {$start_options(key_9)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 9"
	log_writeOutTv 0 "Lirc emitter received Signal key_9"
	exit 0
}
if {$start_options(station_nr)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_ext>> -data $start_values(station_nr)"
	log_writeOutTv 0 "Lirc emitter received Signal station_nr $start_values(station_nr)"
	exit 0
}

if {$start_options(slist_osd)} {
	command_WritePipe 0 "tv-viewer_main tv_slistLirc"
	log_writeOutTv 0 "Lirc emitter received Signal slist_osd"
	exit 0
}
if {$start_options(slist_osd_up)} {
	command_WritePipe 0 "tv-viewer_main tv_slistLircMoveUp"
	log_writeOutTv 0 "Lirc emitter received Signal slist_osd_up"
	exit 0
}
if {$start_options(slist_osd_down)} {
	command_WritePipe 0 "tv-viewer_main tv_slistLircMoveDown"
	log_writeOutTv 0 "Lirc emitter received Signal slist_osd_down"
	exit 0
}
if {$start_options(fullscreen)} {
	command_WritePipe 0 "tv-viewer_main tv_wmFullscreen .tv .tv.bg.w .tv.bg"
	log_writeOutTv 0 "Lirc emitter received Signal fullscreen"
	exit 0
}
if {$start_options(quit)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<exit>>"
	log_writeOutTv 0 "Lirc emitter received Signal quit"
	exit 0
}
if {$start_options(zoom_incr)} {
	command_WritePipe 0 "tv-viewer_main tv_wmPanscan .tv.bg.w 1"
	log_writeOutTv 0 "Lirc emitter received Signal zoom_incr"
	exit 0
}
if {$start_options(zoom_decr)} {
	command_WritePipe 0 "tv-viewer_main tv_wmPanscan .tv.bg.w -1"
	log_writeOutTv 0 "Lirc emitter received Signal zoom_decr"
	exit 0
}
if {$start_options(zoom_auto)} {
	command_WritePipe 0 "tv-viewer_main tv_wmPanscanAuto"
	log_writeOutTv 0 "Lirc emitter received Signal zoom_auto"
	exit 0
}
if {$start_options(size_stnd)} {
	command_WritePipe 0 "tv-viewer_main tv_wmGivenSize .tv.bg 1"
	log_writeOutTv 0 "Lirc emitter received Signal size_stnd"
	exit 0
}
if {$start_options(size_double)} {
	command_WritePipe 0 "tv-viewer_main tv_wmGivenSize .tv.bg 2"
	log_writeOutTv 0 "Lirc emitter received Signal size_double"
	exit 0
}
if {$start_options(move_right)} {
	command_WritePipe 0 "tv-viewer_main tv_wmMoveVideo 0"
	log_writeOutTv 0 "Lirc emitter received Signal move_right"
	exit 0
}
if {$start_options(move_down)} {
	command_WritePipe 0 "tv-viewer_main tv_wmMoveVideo 1"
	log_writeOutTv 0 "Lirc emitter received Signal move_down"
	exit 0
}
if {$start_options(move_left)} {
	command_WritePipe 0 "tv-viewer_main tv_wmMoveVideo 2"
	log_writeOutTv 0 "Lirc emitter received Signal move_left"
	exit 0
}
if {$start_options(move_up)} {
	command_WritePipe 0 "tv-viewer_main tv_wmMoveVideo 3"
	log_writeOutTv 0 "Lirc emitter received Signal move_up"
	exit 0
}
if {$start_options(move_center)} {
	command_WritePipe 0 "tv-viewer_main tv_wmMoveVideo 4"
	log_writeOutTv 0 "Lirc emitter received Signal move_center"
	exit 0
}
if {$start_options(record)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<record>>"
	log_writeOutTv 0 "Lirc emitter received Signal record"
	exit 0
}
if {$start_options(timeshift)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<timeshift>>"
	log_writeOutTv 0 "Lirc emitter received Signal timeshift"
	exit 0
}
if {$start_options(volume_incr)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<volume_incr>>"
	log_writeOutTv 0 "Lirc emitter received Signal volume_incr"
	exit 0
}
if {$start_options(volume_decr)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<volume_decr>>"
	log_writeOutTv 0 "Lirc emitter received Signal volume_decr"
	exit 0
}
if {$start_options(mute)} {
	command_WritePipe 0 "tv-viewer_main tv_playerVolumeControl .bottom_buttons mute"
	log_writeOutTv 0 "Lirc emitter received Signal mute"
	exit 0
}
if {$start_options(forward_10s)} {
	command_WritePipe 0 "tv-viewer_main event generate .tv <<forward_10s>>"
	log_writeOutTv 0 "Lirc emitter received Signal forward_10s"
	exit 0
}
if {$start_options(forward_1m)} {
	command_WritePipe 0 "tv-viewer_main event generate .tv <<forward_1m>>"
	log_writeOutTv 0 "Lirc emitter received Signal forward_1m"
	exit 0
}
if {$start_options(forward_10m)} {
	command_WritePipe 0 "tv-viewer_main event generate .tv <<forward_10m>>"
	log_writeOutTv 0 "Lirc emitter received Signal forward_10m"
	exit 0
}
if {$start_options(forward_end)} {
	command_WritePipe 0 "tv-viewer_main event generate .tv <<forward_end>>"
	log_writeOutTv 0 "Lirc emitter received Signal forward_end"
	exit 0
}
if {$start_options(rewind_10s)} {
	command_WritePipe 0 "tv-viewer_main event generate .tv <<rewind_10s>>"
	log_writeOutTv 0 "Lirc emitter received Signal rewind_10s"
	exit 0
}
if {$start_options(rewind_1m)} {
	command_WritePipe 0 "tv-viewer_main event generate .tv <<rewind_1m>>"
	log_writeOutTv 0 "Lirc emitter received Signal rewind_1m"
	exit 0
}
if {$start_options(rewind_10m)} {
	command_WritePipe 0 "tv-viewer_main event generate .tv <<rewind_10m>>"
	log_writeOutTv 0 "Lirc emitter received Signal rewind_10m"
	exit 0
}
if {$start_options(rewind_start)} {
	command_WritePipe 0 "tv-viewer_main event generate .tv <<rewind_start>>"
	log_writeOutTv 0 "Lirc emitter received Signal rewind_start"
	exit 0
}
if {$start_options(pause)} {
	command_WritePipe 0 "tv-viewer_main event generate .tv <<pause>>"
	log_writeOutTv 0 "Lirc emitter received Signal pause"
	exit 0
}
if {$start_options(start)} {
	command_WritePipe 0 "tv-viewer_main event generate .tv <<start>>"
	log_writeOutTv 0 "Lirc emitter received Signal start"
	exit 0
}
if {$start_options(stop)} {
	command_WritePipe 0 "tv-viewer_main event generate .tv <<stop>>"
	log_writeOutTv 0 "Lirc emitter received Signal stop"
	exit 0
}
catch {close $::data(comsocketWrite)}
exit 1
