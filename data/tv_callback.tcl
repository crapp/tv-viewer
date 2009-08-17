#       tv_callback.tcl
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

proc tv_callbackVidData {} {
	if {[info exists ::data(mplayer)]} {
		gets $::data(mplayer) line
		if {[eof $::data(mplayer)]} {
			puts $::main(debug_msg) "\033\[0;1;33mDebug: \033\[0;1;31mEnd of file\033\[0m"
			puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] MPlayer reported end of file. Playback is stopped."
			flush $::logf_tv_open_append
			catch {close $::data(mplayer)}
			unset -nocomplain ::data(mplayer)
			place forget .tv.bg.w
			#~ place .tv.l_image -relx 0.5 -rely 0.5 -anchor center
			bind .tv.bg.w <Configure> {}
			if {[winfo exists .tv.l_anigif]} {
				launch_splashPlay cancel 0 0 0
				place forget .tv.l_anigif
				destroy .tv.l_anigif
			}
			if {[winfo exists .station]} {
				.station.top_buttons.b_station_preview state !pressed
			} else {
				.top_buttons.button_starttv state !pressed
			}
			tv_fileComputePos cancel
			tv_wmHeartbeatCmd cancel
			if {[winfo exists .tv.file_play_bar] == 1} {
				.tv.file_play_bar.b_play state !disabled
				.tv.file_play_bar.b_pause state disabled
				.tv.file_play_bar.b_play configure -command {tv_Playback .tv.bg .tv.bg.w 0 "$::tv(current_rec_file)"}
				bind .tv <<start>> {tv_Playback .tv.bg .tv.bg.w 0 "$::tv(current_rec_file)"}
			}
			if {[winfo exists .tray] == 1} {
				set status_recordlinkread [catch {file readlink "$::where_is_home/tmp/record_lockfile.tmp"} resultat_recordlinkread]
				if { $status_recordlinkread == 0 } {
					catch {exec ps -eo "%p"} read_ps
					set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
					if { $status_greppid_record != 0 } {
						settooltip .tray [mc "TV-Viewer idle"]
					}
				} else {
					settooltip .tray [mc "TV-Viewer idle"]
				}
			}
			if {$::tv(stayontop) == 2} {
				wm attributes .tv -topmost 0
			}
		} else {
			if {[string match "A:*V:*A-V:*" $line] != 1} {
				puts $::logf_mpl_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] $line"
				flush $::logf_mpl_open_append
				puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_callbackVidData \033\[0m \{$line\}"
			}
			if {[regexp {^VO:.*=> *([^ ]+)} $line => resolution] == 1} {
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] MPlayer reported video resolution $resolution."
				flush $::logf_tv_open_append
				foreach {resolx resoly} [split $resolution x] {
					set ::option(resolx) $resolx
					set ::option(resoly) $resoly
				}
				.tv.bg configure -width $::option(resolx) -height $::option(resoly)
				bind .tv.bg.w <Configure> {place %W -width [expr (%h * ($::option(resolx).0 / $::option(resoly).0))]}
			}
			if {[string match -nocase "ID_LENGTH=*" $line]} {
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] This is a recording, starting to calculate file size and position."
				flush $::logf_tv_open_append
				set status_timeslinkread [catch {file readlink "$::where_is_home/tmp/timeshift_lockfile.tmp"} resultat_timeslinkread]
				set status_recordlinkread [catch {file readlink "$::where_is_home/tmp/record_lockfile.tmp"} resultat_recordlinkread]
				if { $status_recordlinkread == 0 || $status_timeslinkread == 0 } {
					catch {exec ps -eo "%p"} read_ps
					set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
					set status_greppid_times [catch {agrep -w "$read_ps" $resultat_timeslinkread} resultat_greppid_times]
					if { $status_greppid_record == 0 || $status_greppid_times == 0 } {
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
				catch {place forget .tv.l_anigif}
				catch {destroy .tv.l_anigif}
				place .tv.bg.w -in .tv.bg -relx 0.5 -rely 0.5 -anchor center -relheight 1
				bind .tv.bg.w <Configure> {place %W -width [expr (%h * ($::option(resolx).0 / $::option(resoly).0))]}
				tv_playerVolumeControl .bottom_buttons $::volume_scale
				set status_timeslinkread [catch {file readlink "$::where_is_home/tmp/timeshift_lockfile.tmp"} resultat_timeslinkread]
				set status_recordlinkread [catch {file readlink "$::where_is_home/tmp/record_lockfile.tmp"} resultat_recordlinkread]
				if { $status_recordlinkread == 0 || $status_timeslinkread == 0 } {
					catch {exec ps -eo "%p"} read_ps
					set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
					set status_greppid_times [catch {agrep -w "$read_ps" $resultat_timeslinkread} resultat_greppid_times]
					if { $status_greppid_record != 0 && $status_greppid_times != 0 } {
						bind . <<input_up>> "main_stationInput 1 1"
						bind . <<input_down>> "main_stationInput 1 -1"
						bind . <<teleview>> {tv_playerRendering}
						bind .tv <<input_up>> "main_stationInput 1 1"
						bind .tv <<input_down>> "main_stationInput 1 -1"
						bind .tv <<teleview>> {tv_playerRendering}
					}
				} else {
					bind . <<input_up>> "main_stationInput 1 1"
					bind . <<input_down>> "main_stationInput 1 -1"
					bind . <<teleview>> {tv_playerRendering}
					bind .tv <<input_up>> "main_stationInput 1 1"
					bind .tv <<input_down>> "main_stationInput 1 -1"
					bind .tv <<teleview>> {tv_playerRendering}
				}
			}
			if {[string match -nocase "ANS_TIME_POSITION*" $line]} {
				if {$::tv(getvid_seek) == 0} {
					tv_fileComputePos cancel
					set pos [lindex [split $line \=] end]
					set ::data(file_pos_calc) [expr [clock seconds] - [expr round($pos)]]
					set ::data(file_pos) [expr round($pos)]
					after 10 [list tv_fileComputePos 0]
					bind .tv <<forward_end>> {tv_seekInitiate "tv_seek 0 2"}
					bind .tv <<forward_10s>> {tv_seekInitiate "tv_seek 10 1"}
					bind .tv <<forward_1m>> {tv_seekInitiate "tv_seek 60 1"}
					bind .tv <<forward_10m>> {tv_seekInitiate "tv_seek 600 1"}
					bind .tv <<rewind_10s>> {tv_seekInitiate "tv_seek 10 -1"}
					bind .tv <<rewind_1m>> {tv_seekInitiate "tv_seek 60 -1"}
					bind .tv <<rewind_10m>> {tv_seekInitiate "tv_seek 600 -1"}
					bind .tv <<rewind_start>> {tv_seekInitiate "tv_seek 0 -2"}
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
		puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Tried to read channel ::data(mplayer).
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Pipe seems to be broken."
		flush $::logf_tv_open_append
	}
}

proc tv_callbackMplayerRemote {command} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_callbackMplayerRemote \033\[0m \{$command\}"
	if {[info exists ::data(mplayer)] == 0} {return 1}
	if {[string trim $::data(mplayer)] != {}} {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Sending command $command to MPlayer remote channel."
		flush $::logf_tv_open_append
		catch {puts -nonewline $::data(mplayer) "$command \n"}
		flush $::data(mplayer)
		return 0
	} else {
		return 1
	}
}