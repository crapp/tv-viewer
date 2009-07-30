#       main_read_station_file.tcl
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

proc main_readStationFile {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_readStationFile \033\[0m"
	if !{[file exists "$::where_is_home/config/stations_$::option(frequency_table).conf"]} {
		puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] No valid stations_$::option(frequency_table).conf
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Please create one using the Station Editor.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Make sure you checked the configuration first!"
		flush $::logf_tv_open_append
		set ::main(running_recording) 0
	} else {
		set file "$::where_is_home/config/stations_$::option(frequency_table).conf"
		set open_channel_file [open $file r]
		set i 1
		while {[gets $open_channel_file line]!=-1} {
			if {[string match #* $line] || [string trim $line] == {} } continue
			if {[llength $line] < 3} {
				lassign $line ::kanalid($i) ::kanalcall($i)
				set ::kanalinput($i) $::option(video_input)
			} else {
				lassign $line ::kanalid($i) ::kanalcall($i) ::kanalinput($i)
			}
			set ::station(max) $i
			incr i
		}
		close $open_channel_file
		if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
			puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] No valid stations_$::option(frequency_table).conf
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Please create one using the Station Editor.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Make sure you checked the configuration first!"
			flush $::logf_tv_open_append
			set ::main(running_recording) 0
		} else {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Valid stations_$::option(frequency_table).conf found with $::station(max) stations."
			flush $::logf_tv_open_append
			set status_recordlinkread [catch {file readlink "$::where_is_home/tmp/record_lockfile.tmp"} resultat_recordlinkread]
			if { $status_recordlinkread == 0 } {
				catch {exec ps -eo "%p"} read_ps
				set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
				if { $status_greppid_record == 0 } {
					set ::main(running_recording) 1
					puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Found an active recording, won't change station."
					flush $::logf_tv_open_append
				} else {
					set ::main(running_recording) 0
				}
			} else {
				set ::main(running_recording) 0
			}
			if {[file exists "$::where_is_home/config/lastchannel.conf"]} {
				set last_channel_conf "$::where_is_home/config/lastchannel.conf"
				set open_lastchannel [open $last_channel_conf r]
				set open_lastchannel_read [read $open_lastchannel]
				lassign $open_lastchannel_read kanal channel sendernummer
				set ::station(last) "\{$kanal\} $channel $sendernummer"
				set ::station(old) "\{$kanal\} $channel $sendernummer"
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Last station $::station(last)"
				flush $::logf_tv_open_append
				if {$::main(running_recording) == 0} {
					catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
					set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
					if {$::kanalinput([lindex $::station(last) 2]) == [lindex $resultat_get_input 3]} {
						catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $::station(last) 1]} resultat_v4l2ctl
						after 1000 [list station_after_msg [lindex $::station(last) 2] $resultat_v4l2ctl]
					} else {
						set ::main(change_inputLoop_id) [after 200 [list main_stationInputLoop 0 $::kanalinput([lindex $::station(last) 2]) [lindex $::station(last) 1] [lindex $::station(last) 2] 0 1]]
					}
				}
				close $open_lastchannel
			} else {
				set last_channel_conf "$::where_is_home/config/lastchannel.conf"
				set fileId [open $last_channel_conf "w"]
				puts -nonewline $fileId "\{$::kanalid(1)\} $::kanalcall(1) 1"
				close $fileId
				set ::station(last) "\{$::kanalid(1)\} $::kanalcall(1) 1"
				set ::station(old) "\{$::kanalid(1)\} $::kanalcall(1) 1"
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Last station $::station(last)"
				flush $::logf_tv_open_append
				if {$::main(running_recording) == 0} {
					catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
					set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
					if {$::kanalinput([lindex $::station(last) 2]) == [lindex $resultat_get_input 3]} {
						catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $::station(last) 1]} resultat_v4l2ctl
						after 1000 [list station_after_msg [lindex $::station(last) 2] $resultat_v4l2ctl]
					} else {
						set ::main(change_inputLoop_id) [after 200 [list main_stationInputLoop 0 $::kanalinput([lindex $::station(last) 2]) [lindex $::station(last) 1] [lindex $::station(last) 2] 0 1]]
					}
				}
			}
		}
	}
}
