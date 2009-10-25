#       tv_seek.tcl
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


proc tv_seekInitiate {seek_com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_seekInitiate \033\[0m \{$seek_com\}"
	bind .tv <<forward_10s>> {}
	bind .tv <<forward_1m>> {}
	bind .tv <<forward_10m>> {}
	bind .tv <<rewind_10s>> {}
	bind .tv <<rewind_1m>> {}
	bind .tv <<rewind_10m>> {}
	bind .tv <<forward_end>> {}
	bind .tv <<rewind_start>> {}
	set ::tv(seek_secs) [lindex $seek_com 1]
	set ::tv(seek_dir) [lindex $seek_com 2]
	set ::tv(getvid_seek) 1
	tv_callbackMplayerRemote get_time_pos
}

proc tv_seek {secs direct} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_seek \033\[0m \{$secs\} \{$direct\}"
	array set endpos {
		0 10
		512 10
		1024 10
		2048 10
		4096 10
		8192 12
		16384 18
	}
	if {$direct == 1} {
		if {[expr ($::data(file_pos) + $secs)] < [expr ($::data(file_size) - 20)]} {
			log_writeOutTv 0 "Seeking +$secs\s"
			set seekpos [expr ($::data(file_pos) + $secs)]
			if {$seekpos < $::data(file_size)} {
				tv_callbackMplayerRemote "seek $seekpos 2"
				after 650 {
					set ::tv(getvid_seek) 0
					tv_callbackMplayerRemote get_time_pos
				}
			}
			return
		} else {
			set seekpos [expr ($::data(file_size) - $endpos($::option(player_cache)))]
			tv_callbackMplayerRemote "seek $seekpos 2"
			after 650 {
				set ::tv(getvid_seek) 0
				tv_callbackMplayerRemote get_time_pos
			}
			return
		}
	}
	if {$direct == 2} {
		log_writeOutTv 0 "Seeking to the end of actual recording."
		set seekpos [expr ($::data(file_size) - $endpos($::option(player_cache)))]
		tv_callbackMplayerRemote "seek $seekpos 2"
		after 650 {
			set ::tv(getvid_seek) 0
			tv_callbackMplayerRemote get_time_pos
		}
		return
	}
	if {$direct == -1} {
		if {[expr ($::data(file_pos) - $secs)] < 0} {
			log_writeOutTv 0 "Seeking -$secs\s"
			set seekpos 0
			tv_callbackMplayerRemote "seek $seekpos 2"
			after 650 {
				set ::tv(getvid_seek) 0
				tv_callbackMplayerRemote get_time_pos
			}
			return
		} else {
			log_writeOutTv 0 "Seeking -$secs\s"
			set seekpos [expr ($::data(file_pos) - $secs)]
			tv_callbackMplayerRemote "seek $seekpos 2"
			after 650 {
				set ::tv(getvid_seek) 0
				tv_callbackMplayerRemote get_time_pos
			}
			return
		}
	}
	if {$direct == -2} {
		log_writeOutTv 0 "Seeking to the beginning of actual recording."
		set seekpos 0
		tv_callbackMplayerRemote "seek $seekpos 2"
		after 650 {
			set ::tv(getvid_seek) 0
			tv_callbackMplayerRemote get_time_pos
		}
		return
	}
	if {$direct == 0} {
		if {[.tv.file_play_bar.b_pause instate disabled] == 0} {
			.tv.file_play_bar.b_pause state disabled
			.tv.file_play_bar.b_play state !disabled
			log_writeOutTv 0 "Pause playback."
			bind .tv <<forward_10s>> {}
			bind .tv <<forward_1m>> {}
			bind .tv <<forward_10m>> {}
			bind .tv <<rewind_10s>> {}
			bind .tv <<rewind_1m>> {}
			bind .tv <<rewind_10m>> {}
			bind .tv <<forward_end>> {}
			bind .tv <<rewind_start>> {}
			tv_callbackMplayerRemote pause
			return
		} else {
			.tv.file_play_bar.b_play state disabled
			.tv.file_play_bar.b_pause state !disabled
			set ::data(file_pos_calc) [expr [clock seconds] - $::data(file_pos)]
			log_writeOutTv 0 "Start playback."
			bind .tv <<forward_end>> {tv_seekInitiate "tv_seek 0 2"}
			bind .tv <<forward_10s>> {tv_seekInitiate "tv_seek 10 1"}
			bind .tv <<forward_1m>> {tv_seekInitiate "tv_seek 60 1"}
			bind .tv <<forward_10m>> {tv_seekInitiate "tv_seek 600 1"}
			bind .tv <<rewind_10s>> {tv_seekInitiate "tv_seek 10 -1"}
			bind .tv <<rewind_1m>> {tv_seekInitiate "tv_seek 60 -1"}
			bind .tv <<rewind_10m>> {tv_seekInitiate "tv_seek 600 -1"}
			bind .tv <<rewind_start>> {tv_seekInitiate "tv_seek 0 -2"}
			tv_callbackMplayerRemote pause
			return
		}
	}
}

proc tv_seekSwitch {w direct handler seek_var} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_seekSwitch \033\[0m \{$w\} \{$direct\} \{$handler\} \{$seek_var\}"
	array set seek_com {
		-10s {event generate .tv <<rewind_10s>>}
		-1m {event generate .tv <<rewind_1m>>}
		-10m {event generate .tv <<rewind_10m>>}
		+10s {event generate .tv <<forward_10s>>}
		+1m {event generate .tv <<forward_1m>>}
		+10m {event generate .tv <<forward_10m>>}
	}
	set seek_var_rew {::tv(check_rew_10s) ::tv(check_rew_1m) ::tv(check_rew_10m)}
	set seek_var_for {::tv(check_fow_10s) ::tv(check_fow_1m) ::tv(check_fow_10m)}
	if {$direct == -1} {
		$w.b_rewind_small configure -command "$seek_com($handler)"
		foreach var $seek_var_rew {
			set $var 0
		}
		set ::$seek_var 1
	} else {
		$w.b_forward_small configure -command "$seek_com($handler)"
		foreach var $seek_var_for {
			set $var 0
		}
		set ::$seek_var 1
	}
}
