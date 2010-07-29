#       tv_seek.tcl
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


proc tv_seekInitiate {seek_com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_seekInitiate \033\[0m \{$seek_com\}"
	bind . <<forward_10s>> {}
	bind . <<forward_1m>> {}
	bind . <<forward_10m>> {}
	bind . <<rewind_10s>> {}
	bind . <<rewind_1m>> {}
	bind . <<rewind_10m>> {}
	bind . <<forward_end>> {}
	bind . <<rewind_start>> {}
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
	if {$::tv(pbMode) == 1} {
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
			if {[.ftoolb_Bot.bPause instate disabled] == 0} {
				.ftoolb_Bot.bPause state disabled
				.ftoolb_Bot.bPlay state !disabled
				log_writeOutTv 0 "Pause playback."
				bind . <<forward_10s>> {}
				bind . <<forward_1m>> {}
				bind . <<forward_10m>> {}
				bind . <<rewind_10s>> {}
				bind . <<rewind_1m>> {}
				bind . <<rewind_10m>> {}
				bind . <<forward_end>> {}
				bind . <<rewind_start>> {}
				tv_callbackMplayerRemote pause
				return
			} else {
				.ftoolb_Bot.bPlay state disabled
				.ftoolb_Bot.bPause state !disabled
				set ::data(file_pos_calc) [expr [clock seconds] - $::data(file_pos)]
				log_writeOutTv 0 "Start playback."
				bind . <<forward_end>> {tv_seekInitiate "tv_seek 0 2"}
				bind . <<forward_10s>> {tv_seekInitiate "tv_seek 10 1"}
				bind . <<forward_1m>> {tv_seekInitiate "tv_seek 60 1"}
				bind . <<forward_10m>> {tv_seekInitiate "tv_seek 600 1"}
				bind . <<rewind_10s>> {tv_seekInitiate "tv_seek 10 -1"}
				bind . <<rewind_1m>> {tv_seekInitiate "tv_seek 60 -1"}
				bind . <<rewind_10m>> {tv_seekInitiate "tv_seek 600 -1"}
				bind . <<rewind_start>> {tv_seekInitiate "tv_seek 0 -2"}
				tv_callbackMplayerRemote pause
				return
			}
		}
	} else {
		log_writeOutTv 2 "Function tv_seek was invoked while not in file playback mode."
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
