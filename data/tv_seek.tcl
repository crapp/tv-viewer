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
	tv_playerMplayerRemote get_time_pos
}

proc tv_seek {secs direct} {
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
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Seeking +$secs\s"
			flush $::logf_tv_open_append
			set seekpos [expr ($::data(file_pos) + $secs)]
			if {$seekpos < $::data(file_size)} {
				tv_playerMplayerRemote "seek $seekpos 2"
				after 650 {
					set ::tv(getvid_seek) 0
					tv_playerMplayerRemote get_time_pos
				}
			}
			return
		} else {
			set seekpos [expr ($::data(file_size) - $endpos($::option(player_cache)))]
			tv_playerMplayerRemote "seek $seekpos 2"
			after 650 {
				set ::tv(getvid_seek) 0
				tv_playerMplayerRemote get_time_pos
			}
			return
		}
	}
	if {$direct == 2} {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Seeking to the end of actual recording."
		flush $::logf_tv_open_append
		set seekpos [expr ($::data(file_size) - $endpos($::option(player_cache)))]
		tv_playerMplayerRemote "seek $seekpos 2"
		after 650 {
			set ::tv(getvid_seek) 0
			tv_playerMplayerRemote get_time_pos
		}
		return
	}
	if {$direct == -1} {
		if {[expr ($::data(file_pos) - $secs)] < 0} {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Seeking -$secs\s"
			flush $::logf_tv_open_append
			set seekpos 0
			tv_playerMplayerRemote "seek $seekpos 2"
			after 650 {
				set ::tv(getvid_seek) 0
				tv_playerMplayerRemote get_time_pos
			}
			return
		} else {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Seeking -$secs\s"
			flush $::logf_tv_open_append
			set seekpos [expr ($::data(file_pos) - $secs)]
			tv_playerMplayerRemote "seek $seekpos 2"
			after 650 {
				set ::tv(getvid_seek) 0
				tv_playerMplayerRemote get_time_pos
			}
			return
		}
	}
	if {$direct == -2} {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Seeking to the beginning of actual recording."
		flush $::logf_tv_open_append
		set seekpos 0
		tv_playerMplayerRemote "seek $seekpos 2"
		after 650 {
			set ::tv(getvid_seek) 0
			tv_playerMplayerRemote get_time_pos
		}
		return
	}
	if {$direct == 0} {
		if {[.tv.file_play_bar.b_pause instate disabled] == 0} {
			.tv.file_play_bar.b_pause state disabled
			.tv.file_play_bar.b_play state !disabled
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Pause playback."
			flush $::logf_tv_open_append
			bind .tv <<forward_10s>> {}
			bind .tv <<forward_1m>> {}
			bind .tv <<forward_10m>> {}
			bind .tv <<rewind_10s>> {}
			bind .tv <<rewind_1m>> {}
			bind .tv <<rewind_10m>> {}
			bind .tv <<forward_end>> {}
			bind .tv <<rewind_start>> {}
			tv_playerMplayerRemote pause
			return
		} else {
			.tv.file_play_bar.b_play state disabled
			.tv.file_play_bar.b_pause state !disabled
			set ::data(file_pos_calc) [expr [clock seconds] - $::data(file_pos)]
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Start playback."
			flush $::logf_tv_open_append
			bind .tv <<forward_end>> {tv_seekInitiate "tv_seek 0 2"}
			bind .tv <<forward_10s>> {tv_seekInitiate "tv_seek 10 1"}
			bind .tv <<forward_1m>> {tv_seekInitiate "tv_seek 60 1"}
			bind .tv <<forward_10m>> {tv_seekInitiate "tv_seek 600 1"}
			bind .tv <<rewind_10s>> {tv_seekInitiate "tv_seek 10 -1"}
			bind .tv <<rewind_1m>> {tv_seekInitiate "tv_seek 60 -1"}
			bind .tv <<rewind_10m>> {tv_seekInitiate "tv_seek 600 -1"}
			bind .tv <<rewind_start>> {tv_seekInitiate "tv_seek 0 -2"}
			tv_playerMplayerRemote pause
			return
		}
	}
}
