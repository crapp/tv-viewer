#!/usr/bin/env tclsh

#       lirc_emitter.tcl
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

#This file is a executable script which is connected to the symlink tv-viewer_lirc.
#Call this file with the appropriate options to trigger events. Use it together with a 
#daemon like irexec and lircrc configuration file.

set option(root) "[file dirname [file dirname [file normalize [file join [info script] bogus]]]]"
set option(home) "$::env(HOME)/.tv-viewer"
set option(appname) "tv-viewer_lirc"

source $option(root)/init.tcl

init_source "$option(root)" "release_version.tcl agrep.tcl process_config.tcl log_viewer.tcl command_socket.tcl monitor.tcl"

process_configRead

if {[file exists "$::option(home)/log/tvviewer.log"]} {
	if {$::option(log_files) == 1} {
		set log(tvAppend) [open $::option(home)/log/tvviewer.log a]
		fconfigure $log(tvAppend) -blocking no -buffering line
	} else {
		set log(tvAppend) [open /dev/null a]
		fconfigure $log(tvAppend) -blocking no -buffering line
	}
} else {
	set log(tvAppend) [open /dev/null a]
	fconfigure $log(tvAppend) -blocking no -buffering line
}

command_socket

array set start_options {teleview 0 station_prior 0 station_next 0 station_jump 0 key_0 0 key_1 0 key_2 0 key_3 0 key_4 0 key_5 0 key_6 0 key_7 0 key_8 0 key_9 0 station_nr 0 slist_osd 0 slist_osd_up 0 slist_osd_down 0 fullscreen 0 compact 0 quit 0 zoom_incr_small 0 zoom_incr_big 0 zoom_decr_small 0 zoom_decr_big 0 zoom_reset 0 zoom_auto 0 size_stnd 0 size_double 0 move_up 0 move_down 0 move_left 0 move_right 0 move_center 0 record 0 timeshift 0 radio 0 volume_incr 0 volume_decr 0 mute 0 adelay_incr 0 adelay_decr 0 forward_10s 0 forward_1m 0 forward_10m 0 forward_end 0 rewind_10s 0 rewind_1m 0 rewind_10m 0 rewind_start 0 pause 0 stop 0 start 0}
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

if {[array size ::start_options] != 53} {
	log_writeOut ::log(tvAppend) 2 "Lirc emitter received unknown command $argv"
	log_writeOut ::log(tvAppend) 2 "See the userguide for possible actions."
	exit 1
}
set status [monitor_partRunning 1]
if {[lindex $status 0] == 0} {
	log_writeOut ::log(tvAppend) 1 "Lirc emitter received signal while TV-Viewer is not running"
	exit 1
}
if {$start_options(teleview)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<teleview>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal teleview"
	exit 0
}
if {$start_options(station_prior)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<stationPrior>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal station_prior"
	exit 0
}
if {$start_options(station_next)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<stationNext>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal station_next"
	exit 0
}
if {$start_options(station_jump)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<stationJump>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal station_jump"
	exit 0
}
if {$start_options(key_0)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 0"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal key_0"
	exit 0
}
if {$start_options(key_1)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 1"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal key_1"
	exit 0
}
if {$start_options(key_2)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 2"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal key_2"
	exit 0
}
if {$start_options(key_3)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 3"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal key_3"
	exit 0
}
if {$start_options(key_4)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 4"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal key_4"
	exit 0
}
if {$start_options(key_5)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 5"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal key_5"
	exit 0
}
if {$start_options(key_6)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 6"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal key_6"
	exit 0
}
if {$start_options(key_7)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 7"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal key_7"
	exit 0
}
if {$start_options(key_8)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 8"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal key_8"
	exit 0
}
if {$start_options(key_9)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_lirc>> -data 9"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal key_9"
	exit 0
}
if {$start_options(station_nr)} {
	if {[info exists start_values(station_nr)] == 0} {
		log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal station_nr. Please provide a digit as value!"
		exit 1
	}
	command_WritePipe 0 "tv-viewer_main event generate . <<station_key_ext>> -data $start_values(station_nr)"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal station_nr $start_values(station_nr)"
	exit 0
}

if {$start_options(slist_osd)} {
	command_WritePipe 0 "tv-viewer_main vid_slistLirc"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal slist_osd"
	exit 0
}
if {$start_options(slist_osd_up)} {
	command_WritePipe 0 "tv-viewer_main vid_slistLircMoveUp"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal slist_osd_up"
	exit 0
}
if {$start_options(slist_osd_down)} {
	command_WritePipe 0 "tv-viewer_main vid_slistLircMoveDown"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal slist_osd_down"
	exit 0
}
if {$start_options(fullscreen)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmFull>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal fullscreen"
	exit 0
}
if {$start_options(compact)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmCompact>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal compact"
	exit 0
}
if {$start_options(quit)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<exit>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal quit"
	exit 0
}
if {$start_options(zoom_incr_small)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmZoomIncSmall>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal zoom_incr_small"
	exit 0
}
if {$start_options(zoom_incr_big)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmZoomIncBig>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal zoom_incr_big"
	exit 0
}
if {$start_options(zoom_decr_small)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmZoomDecSmall>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal zoom_decr_small"
	exit 0
}
if {$start_options(zoom_decr_big)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmZoomDecBig>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal zoom_decr_big"
	exit 0
}
if {$start_options(zoom_reset)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmZoomReset>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal zoom_reset"
	exit 0
}
if {$start_options(zoom_auto)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmZoomAuto>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal zoom_auto"
	exit 0
}
if {$start_options(size_stnd)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmSize1>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal size_stnd"
	exit 0
}
if {$start_options(size_double)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmSize2>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal size_double"
	exit 0
}
if {$start_options(move_right)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmMoveRight>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal move_right"
	exit 0
}
if {$start_options(move_down)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmMoveDown>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal move_down"
	exit 0
}
if {$start_options(move_left)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmMoveLeft>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal move_left"
	exit 0
}
if {$start_options(move_up)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmMoveUp>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal move_up"
	exit 0
}
if {$start_options(move_center)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<wmMoveCenter>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal move_center"
	exit 0
}
if {$start_options(record)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<record>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal record"
	exit 0
}
if {$start_options(timeshift)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<timeshift>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal timeshift"
	exit 0
}
if {$start_options(radio)} {
	#FIXME Don't forget to activate radio support in lirc emitter
	#~ command_WritePipe 0 "tv-viewer_main event generate . <<radio>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal radio"
	exit 0
}
if {$start_options(volume_incr)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<volume_incr>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal volume_incr"
	exit 0
}
if {$start_options(volume_decr)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<volume_decr>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal volume_decr"
	exit 0
}
if {$start_options(mute)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<mute>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal mute"
	exit 0
}
if {$start_options(adelay_incr)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<delay_incr>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal adelay_incr"
	exit 0
}
if {$start_options(adelay_decr)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<delay_decr>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal adelay_decr"
	exit 0
}
if {$start_options(forward_10s)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<forward_10s>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal forward_10s"
	exit 0
}
if {$start_options(forward_1m)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<forward_1m>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal forward_1m"
	exit 0
}
if {$start_options(forward_10m)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<forward_10m>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal forward_10m"
	exit 0
}
if {$start_options(forward_end)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<forward_end>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal forward_end"
	exit 0
}
if {$start_options(rewind_10s)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<rewind_10s>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal rewind_10s"
	exit 0
}
if {$start_options(rewind_1m)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<rewind_1m>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal rewind_1m"
	exit 0
}
if {$start_options(rewind_10m)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<rewind_10m>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal rewind_10m"
	exit 0
}
if {$start_options(rewind_start)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<rewind_start>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal rewind_start"
	exit 0
}
if {$start_options(pause)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<pause>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal pause"
	exit 0
}
if {$start_options(start)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<start>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal start"
	exit 0
}
if {$start_options(stop)} {
	command_WritePipe 0 "tv-viewer_main event generate . <<stop>>"
	log_writeOut ::log(tvAppend) 0 "Lirc emitter received Signal stop"
	exit 0
}
catch {close $::data(comsocketWrite)}
exit 1
