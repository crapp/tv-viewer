#       vid_seek.tcl
#       © Copyright 2007-2011 Christian Rapp <christianrapp@users.sourceforge.net>
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


proc vid_seekInitiate {seek_com} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_seekInitiate \033\[0m \{$seek_com\}"
	set ::vid(seek_secs) [lindex $seek_com 1]
	set ::vid(seek_dir) [lindex $seek_com 2]
	set ::vid(getvid_seek) 1
	vid_callbackMplayerRemote get_time_pos
}

proc vid_seek {secs direct} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_seek \033\[0m \{$secs\} \{$direct\}"
	# direct 1 --> forward; 2 end of file; -1 --> backward; -2 beginning of the file; 0 toggles pause
	array set endpos {
		0 10
		512 10
		1024 10
		2048 10
		4096 10
		8192 12
		16384 18
	}
	if {[info exists ::vid(pbMode)] && $::vid(pbMode) == 1} {
		if {$direct == 1} {
			if {[expr ($::data(file_pos) + $secs)] < [expr ($::data(file_size) - 20)]} {
				log_writeOutTv 0 "Seeking +$secs\s"
				set seekpos [expr ($::data(file_pos) + $secs)]
				if {$seekpos < $::data(file_size)} {
					vid_callbackMplayerRemote "seek $secs 0"
				}
			} else {
				set calc_secs [expr ($::data(file_size) - $endpos($::option(player_cache))) - $::data(file_pos)]
				vid_callbackMplayerRemote "seek $calc_secs 0"
			}
		}
		if {$direct == 2} {
			log_writeOutTv 0 "Seeking to the end of actual recording."
			set calc_secs [expr ($::data(file_size) - $endpos($::option(player_cache))) - $::data(file_pos)]
			vid_callbackMplayerRemote "seek $calc_secs 0"
		}
		#~ if {$direct == 3} {
			#~ log_writeOutTv 0 "Seeking to position $secs"
			#~ set seekpos [expr ($secs - 2)]
			#~ vid_callbackMplayerRemote "seek $seekpos 2"
			#~ after 650 {
				#~ set ::vid(getvid_seek) 0
				#~ vid_callbackMplayerRemote get_time_pos
			#~ }
			#~ return
		#~ }
		if {$direct == -1} {
			if {[expr ($::data(file_pos) - $secs)] < 0} {
				log_writeOutTv 0 "Seeking -$secs\s"
				set seekpos 0
				vid_callbackMplayerRemote "seek $seekpos 2"
			} else {
				log_writeOutTv 0 "Seeking -$secs\s"
				set seekpos [expr ($::data(file_pos) - $secs)]
				vid_callbackMplayerRemote "seek -$secs 0"
			}
		}
		if {$direct == -2} {
			log_writeOutTv 0 "Seeking to the beginning of actual recording."
			set seekpos 0
			vid_callbackMplayerRemote "seek $seekpos 2"
		}
		if {$direct == 0} {
			if {[.ftoolb_Play.bPause instate disabled] == 0} {
				vid_pmhandlerButton {100 0} {100 0} {{1 !disabled} {2 disabled}}
				vid_pmhandlerMenuNav {{4 normal} {5 disabled}} {{4 normal} {5 disabled}}
				vid_pmhandlerMenuTray {{15 normal} {16 disabled}}
				log_writeOutTv 0 "Pause playback."
				bind . <<forward_10s>> {}
				bind . <<forward_1m>> {}
				bind . <<forward_10m>> {}
				bind . <<rewind_10s>> {}
				bind . <<rewind_1m>> {}
				bind . <<rewind_10m>> {}
				bind . <<forward_end>> {}
				bind . <<rewind_start>> {}
				vid_callbackMplayerRemote pause
			} else {
				vid_pmhandlerButton {100 0} {100 0} {{1 disabled} {2 !disabled}}
				vid_pmhandlerMenuNav {{4 disabled} {5 normal}} {{4 disabled} {5 normal}}
				vid_pmhandlerMenuTray {{15 disabled} {16 normal}}
				set ::data(file_pos_calc) [expr [clock seconds] - $::data(file_pos)]
				log_writeOutTv 0 "Start playback."
				bind . <<forward_end>> {vid_seekInitiate "vid_seek 0 2"}
				bind . <<forward_10s>> {vid_seekInitiate "vid_seek 10 1"}
				bind . <<forward_1m>> {vid_seekInitiate "vid_seek 60 1"}
				bind . <<forward_10m>> {vid_seekInitiate "vid_seek 600 1"}
				bind . <<rewind_10s>> {vid_seekInitiate "vid_seek 10 -1"}
				bind . <<rewind_1m>> {vid_seekInitiate "vid_seek 60 -1"}
				bind . <<rewind_10m>> {vid_seekInitiate "vid_seek 600 -1"}
				bind . <<rewind_start>> {vid_seekInitiate "vid_seek 0 -2"}
				vid_callbackMplayerRemote pause
			}
		} else {
			if {[info exists ::vid(afterid)]} {
				foreach id $::vid(afterid) {
					catch {after cancel $id}
				}
			}
			lappend ::vid(afterid) [after 650 {
				set ::vid(getvid_seek) 0
				vid_callbackMplayerRemote get_time_pos
			}]
		}
	} else {
		log_writeOutTv 2 "Function vid_seek was invoked while not in file playback mode."
	}
}

proc vid_seekSwitch {btn direct handler seek_var} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_seekSwitch \033\[0m \{$btn\} \{$direct\} \{$handler\} \{$seek_var\}"
	array set seek_com {
		-10s {event generate . <<rewind_10s>>}
		-1m {event generate . <<rewind_1m>>}
		-10m {event generate . <<rewind_10m>>}
		+10s {event generate . <<forward_10s>>}
		+1m {event generate . <<forward_1m>>}
		+10m {event generate . <<forward_10m>>}
	}
	set seek_var_rew {::vid(check_rew_10s) ::vid(check_rew_1m) ::vid(check_rew_10m)}
	set seek_var_for {::vid(check_fow_10s) ::vid(check_fow_1m) ::vid(check_fow_10m)}
	if {$direct == -1} {
		$btn configure -command "$seek_com($handler)"
		foreach var $seek_var_rew {
			set $var 0
		}
		set ::$seek_var 1
	} else {
		$btn configure -command "$seek_com($handler)"
		foreach var $seek_var_for {
			set $var 0
		}
		set ::$seek_var 1
	}
}
