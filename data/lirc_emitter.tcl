#!/usr/bin/env wish

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

wm withdraw .

#set processing_folder [file dirname [file normalize [info script]]]
if {[file type [info script]] == "link" } {
	set where_is [file dirname [file normalize [file readlink [info script]]]]
} else {
	set where_is [file dirname [file normalize [info script]]]
}
set where_is_home "$::env(HOME)/.tv-viewer"

set option(release_version) "0.8.1a1.15"

source $where_is/main_read_config.tcl

main_readConfig

if {[file exists $::where_is_home/log/tvviewer.log]} {
	if {$::option(log_files) == 1} {
		set logf_tv_open_append [open $::where_is_home/log/tvviewer.log a]
		fconfigure $::logf_tv_open_append -blocking no -buffering line
	} else {
		set logf_tv_open_append [open /dev/null a]
		fconfigure $logf_tv_open_append -blocking no -buffering line
	}
} else {
	set logf_tv_open_append [open /dev/null a]
	fconfigure $logf_tv_open_append -blocking no -buffering line
}

if {[file exists "$::where_is_home/tmp/comSocket.tmp"]} {
	set comsocket [open "$::where_is_home/tmp/comSocket.tmp" a]
	fconfigure $comsocket -blocking no -buffering line
} else {
	puts $logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] comSocket.tmp does not exist. Can't send commands to main application."
	flush $logf_tv_open_append
	exit 1
}

array set start_options {teleview 0 station_up 0 station_down 0 station_jump 0 key_0 0 key_1 0 key_2 0 key_3 0 key_4 0 key_5 0 key_6 0 key_7 0 key_8 0 key_9 0 slist_osd 0 slist_osd_up 0 slist_osd_down 0 fullscreen 0 quit 0 zoom_incr 0 zoom_decr 0 zoom_auto 0 size_stnd 0 size_double 0 move_up 0 move_down 0 move_left 0 move_right 0 record 0 timeshift 0 volume_incr 0 volume_decr 0 mute 0 forward_10s 0 forward_1m 0 forward_10m 0 forward_end 0 rewind_10s 0 rewind_1m 0 rewind_10m 0 rewind_start 0 pause 0 stop 0 start 0}
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

if {[array size ::start_options] != 44} {
	puts $logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received unknown command $argv
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] See the userguide for possible actions."
	flush $logf_tv_open_append
	exit 1
}
if {$start_options(teleview)} {
	puts $comsocket "tv-viewer_main event generate . <<teleview>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal teleview"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(station_up)} {
	puts $comsocket "tv-viewer_main event generate . <<station_up>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal station_up"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(station_down)} {
	puts $comsocket "tv-viewer_main event generate . <<station_down>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal station_down"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(station_jump)} {
	puts $comsocket "tv-viewer_main event generate . <<station_jump>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal station_jump"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(key_0)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 0"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal key_0"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(key_1)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 1"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal key_1"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(key_2)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 2"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal key_2"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(key_3)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 3"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal key_3"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(key_4)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 4"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal key_4"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(key_5)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 5"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal key_5"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(key_6)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 6"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal key_6"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(key_7)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 7"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal key_7"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(key_8)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 8"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal key_8"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(key_9)} {
	puts $comsocket "tv-viewer_main event generate . <<station_key_lirc>> -data 9"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal key_9"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(slist_osd)} {
	puts $comsocket "tv-viewer_main tv_slistLirc"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal slist_osd"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(slist_osd_up)} {
	puts $comsocket "tv-viewer_main tv_slistLircMoveUp"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal slist_osd_up"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(slist_osd_down)} {
	puts $comsocket "tv-viewer_main tv_slistLircMoveDown"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal slist_osd_down"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(fullscreen)} {
	puts $comsocket "tv-viewer_main tv_wmFullscreen .tv .tv.bg.w .tv.bg"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal fullscreen"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(quit)} {
	puts $comsocket "tv-viewer_main main_frontendExitViewer"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal quit"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(zoom_incr)} {
	puts $comsocket "tv-viewer_main tv_wmPanscan .tv.bg.w 1"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal zoom_incr"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(zoom_decr)} {
	puts $comsocket "tv-viewer_main tv_wmPanscan .tv.bg.w -1"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal zoom_decr"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(zoom_auto)} {
	puts $comsocket "tv-viewer_main tv_wmPanscanAuto"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal zoom_auto"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(record)} {
	puts $comsocket "tv-viewer_main event generate . <<record>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal record"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(timeshift)} {
	puts $comsocket "tv-viewer_main event generate . <<timeshift>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal timeshift"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(volume_incr)} {
	puts $comsocket "tv-viewer_main event generate . <<volume_incr>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal volume_incr"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(volume_decr)} {
	puts $comsocket "tv-viewer_main event generate . <<volume_decr>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal volume_decr"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(mute)} {
	puts $comsocket "tv-viewer_main tv_playerVolumeControl .bottom_buttons mute"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal mute"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(forward_10s)} {
	puts $comsocket "tv-viewer_main event generate .tv <<forward_10s>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal forward_10s"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(forward_1m)} {
	puts $comsocket "tv-viewer_main event generate .tv <<forward_1m>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal forward_1m"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(forward_10m)} {
	puts $comsocket "tv-viewer_main event generate .tv <<forward_10m>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal forward_10m"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(forward_end)} {
	puts $comsocket "tv-viewer_main event generate .tv <<forward_end>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal forward_end"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(rewind_10s)} {
	puts $comsocket "tv-viewer_main event generate .tv <<rewind_10s>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal rewind_10s"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(rewind_1m)} {
	puts $comsocket "tv-viewer_main event generate .tv <<rewind_1m>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal rewind_1m"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(rewind_10m)} {
	puts $comsocket "tv-viewer_main event generate .tv <<rewind_10m>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal rewind_10m"
	flush $logf_tv_open_append
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
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal pause"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(start)} {
	puts $comsocket "tv-viewer_main event generate .tv <<start>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal start"
	flush $logf_tv_open_append
	exit 0
}
if {$start_options(stop)} {
	puts $comsocket "tv-viewer_main event generate .tv <<stop>>"
	flush $comsocket
	puts $logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Lirc emitter received Signal stop"
	flush $logf_tv_open_append
	exit 0
}
exit 1
