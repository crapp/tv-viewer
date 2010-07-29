#       tv_callback.tcl
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

proc tv_callbackVidData {} {
	if {[info exists ::data(mplayer)]} {
		gets $::data(mplayer) line
		if {[eof $::data(mplayer)]} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: \033\[0;1;31mEnd of file\033\[0m"
			log_writeOutTv 1 "MPlayer reported end of file. Playback has stopped."
			fconfigure $::data(mplayer) -blocking 1
			set mpid [pid $::data(mplayer)]
			catch {close $::data(mplayer)}
			set mplmatch 0
			set mplcode 0
			foreach str $::errorCode {
				if {$str == $mpid} {
					set mplmatch 1
				}
				if {$str == 1} {
					set mplcode 1
				}
			}
			if {$mplmatch == 1 && $mplcode == 1} {
				log_writeOutTv 2 "MPlayer crashed, see videoplayer logfile for details."
				log_writeOutMpl 2 "MPlayer crashed"
				foreach line [split $::errorInfo \n] {
					if {[string match "*while executing*" $line]} break
					log_writeOutMpl 2 "$line"
				}
			}
			unset -nocomplain ::data(mplayer)
			place forget .ftvBg.cont
			bind .ftvBg.cont <Configure> {}
			if {[.ftoolb_Top.bTimeshift instate disabled] == 0} {
				if {[winfo exists .ftvBg.l_anigif]} {
					launch_splashPlay cancel 0 0 0
					place forget .ftvBg.l_anigif
					destroy .ftvBg.l_anigif
				}
			}
			if {[winfo exists .station]} {
				.station.top_buttons.b_station_preview state !pressed
				.ftoolb_Top.bTv state !pressed
			} else {
				.ftoolb_Top.bTv state !pressed
			}
			tv_fileComputePos cancel
			if {$::option(player_screens_value) == 1} {
				tv_wmHeartbeatCmd cancel 
			}
			if {$::tv(pbMode) == 1} {
				.ftoolb_Bot.bPlay state !disabled
				.ftoolb_Bot.bPause state disabled
				.ftoolb_Bot.bPlay configure -command {tv_Playback .ftvBg .ftvBg.cont 0 "$::tv(current_rec_file)"}
				bind . <<start>> {tv_Playback .ftvBg .ftvBg.cont 0 "$::tv(current_rec_file)"}
			}
			if {[winfo exists .tray] == 1} {
				set status_record [monitor_partRunning 3]
				if {[lindex $status_record 0] == 0} {
					settooltip .tray [mc "TV-Viewer idle"]
				}
			}
			if {$::tv(stayontop) == 2} {
				wm attributes . -topmost 0
			}
		} else {
			if {[string match "A:*V:*A-V:*" $line] != 1} {
				log_writeOutMpl 0 "$line"
				puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_callbackVidData \033\[0m \{$line\}"
			}
			if {[regexp {^VO:.*=> *([^ ]+)} $line => resolution] == 1} {
				log_writeOutTv 0 "MPlayer reported video resolution $resolution."
				if {$::option(player_aspect) == 1} {
					foreach {resolx resoly} [split $resolution x] {
						set ::option(resolx) $resolx
						set ::option(resoly) $resoly
					}
					.ftvBg configure -width $::option(resolx) -height $::option(resoly)
					bind .ftvBg.cont <Configure> {place %W -width [expr (%h * ($::option(resolx).0 / $::option(resoly).0))]}
				} else {
					bind .ftvBg.cont <Configure> {}
					log_writeOutTv 1 "Video aspect not managed by TV-Viewer."
				}
			}
			if {[string match -nocase "ID_LENGTH=*" $line]} {
				log_writeOutTv 0 "This is a recording, starting to calculate file size and position."
				set status_time [monitor_partRunning 4]
				set status_record [monitor_partRunning 3]
				if {[lindex $status_record 0] == 1 || [lindex $status_time 0] == 1} {
					tv_fileComputeSize cancel
					set length [lindex [split $line "="] end]
					set length_int [expr int($length)]
					set seconds [expr [clock seconds] - $length_int]
					after 0 [list tv_fileComputeSize $seconds]
				} else {
					tv_fileComputeSize cancel_rec
					if {[info exists ::data(file_size)] == 0} {
						set length [lindex [split $line "="] end]
						set length_int [expr int($length)]
						set ::data(file_size) $length_int
					}
				}
				set ::data(file_pos_calc) [clock seconds]
				after 10 [list tv_fileComputePos $::data(file_pos_calc)]
			}
			if {[string match -nocase "Starting playback*" $line]} {
				catch {launch_splashPlay cancel 0 0 0}
				catch {place forget .ftvBg.l_anigif}
				catch {destroy .ftvBg.l_anigif}
				if {$::option(player_aspect) == 1} {
					if {$::option(player_keepaspect) == 1} {
						place .ftvBg.cont -in .ftvBg -relx 0.5 -rely 0.5 -anchor center -relheight 1
						bind .ftvBg.cont <Configure> {place %W -width [expr (%h * ($::option(resolx).0 / $::option(resoly).0))]}
					} else {
						place .ftvBg.cont -in .ftvBg -relx 0.5 -rely 0.5 -anchor center -relheight 1 -relwidth 1
					}
				} else {
					place .ftvBg.cont -in .ftvBg -relx 0.5 -rely 0.5 -anchor center -width $::option(resolx) -height $::option(resoly)
					bind .ftvBg.cont <Configure> {}
				}
				if {$::data(movevidX) != 0} {
					place .ftvBg.cont -relx [expr ([dict get [place info .ftvBg.cont] -relx] + [expr $::data(movevidX) * 0.005])]
				}
				if {$::data(movevidY) != 0} {
					place .ftvBg.cont -rely [expr ([dict get [place info .ftvBg.cont] -rely] + [expr $::data(movevidY) * 0.005])]
				}
				if {$::data(panscanAuto) == 1} {
					set ::tv(id_panscanAuto) [after 500 {
						catch {after cancel $::tv(id_panscanAuto)}
						set ::data(panscanAuto) 0
						tv_wmPanscanAuto
					}]
				} else {
					if {$::data(panscan) != 0} {
						place .ftvBg.cont -relheight [expr ([dict get [place info .ftvBg.cont] -relheight] + [expr $::data(panscan).0 / 100])]
					}
				}
				tv_playerVolumeControl .ftoolb_Bot.scVolume .ftoolb_Bot.bVolMute $::main(volume_scale)
				tv_callbackMplayerRemote "audio_delay $::option(player_audio_delay) 1"
				set status_time [monitor_partRunning 4]
				set status_record [monitor_partRunning 3]
				if {[lindex $status_record 0] == 0 && [lindex $status_time 0] == 0} {
					bind . <<input_up>> "chan_zapperInput 1 1"
					bind . <<input_down>> "chan_zapperInput 1 -1"
					bind . <<teleview>> {tv_playerRendering}
				}
			}
			if {[string match -nocase "ANS_TIME_POSITION*" $line]} {
				if {$::tv(getvid_seek) == 0} {
					tv_fileComputePos cancel
					set pos [lindex [split $line \=] end]
					set ::data(file_pos_calc) [expr [clock seconds] - [expr round($pos)]]
					set ::data(file_pos) [expr round($pos)]
					after 10 [list tv_fileComputePos 0]
					bind . <<forward_end>> {tv_seekInitiate "tv_seek 0 2"}
					bind . <<forward_10s>> {tv_seekInitiate "tv_seek 10 1"}
					bind . <<forward_1m>> {tv_seekInitiate "tv_seek 60 1"}
					bind . <<forward_10m>> {tv_seekInitiate "tv_seek 600 1"}
					bind . <<rewind_10s>> {tv_seekInitiate "tv_seek 10 -1"}
					bind . <<rewind_1m>> {tv_seekInitiate "tv_seek 60 -1"}
					bind . <<rewind_10m>> {tv_seekInitiate "tv_seek 600 -1"}
					bind . <<rewind_start>> {tv_seekInitiate "tv_seek 0 -2"}
				} else {
					tv_fileComputePos cancel
					set pos [lindex [split $line \=] end]
					set ::data(file_pos_calc) [expr [clock seconds] - [expr round($pos)]]
					set ::data(file_pos) [expr round($pos)]
					after 10 [list tv_fileComputePos 0]
					tv_seek $::tv(seek_secs) $::tv(seek_dir)
				}
			}
			set ::data(report) $line
		}
	} else {
		log_writeOutTv 2 "Tried to read channel ::data(mplayer)."
		log_writeOutTv 2 "Pipe seems to be broken."
	}
}

proc tv_callbackMplayerRemote {command} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_callbackMplayerRemote \033\[0m \{$command\}"
	if {[info exists ::data(mplayer)] == 0} {return 1}
	if {[string trim $::data(mplayer)] != {}} {
		log_writeOutTv 0 "Sending command $command to MPlayer remote channel."
		catch {puts -nonewline $::data(mplayer) "$command \n"}
		flush $::data(mplayer)
		return 0
	} else {
		log_writeOutTv 2 "Can't access mplayer command pipe."
		return 1
	}
}
