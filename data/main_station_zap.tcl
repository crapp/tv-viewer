#       main_station_zap.tcl
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

proc main_stationChannelDown {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_stationChannelDown \033\[0m \{$w\}"
	for {set i 1} {$i <= $::station(max)} {incr i} {
		if {[string match $::kanalid($i) [lindex $::station(last) 0]]} {
			set calculation [expr {($i == 1) ? $::station(max) : ($i - 1)}]
			set ::station(last) "\{$::kanalid($calculation)\} $::kanalcall($calculation) $calculation"
			set ::station(old) "\{$::kanalid($i)\} $::kanalcall($i) $i"
			$w configure -text "$::kanalid($calculation)"
			if {[winfo exists .frame_slistbox] == 1} {
				.frame_slistbox.listbox_slist see [expr $calculation - 1]
				if {[string trim [.frame_slistbox.listbox_slist curselection]] != {}} {
					.frame_slistbox.listbox_slist selection clear [.frame_slistbox.listbox_slist curselection]
					.frame_slistbox.listbox_slist activate [expr $calculation - 1]
				}
				.frame_slistbox.listbox_slist selection set [expr $calculation - 1]
			}
			log_writeOutTv 0 "Station prior $::kanalid($calculation)."
			catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
			set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
			if {$::kanalinput([lindex $::station(last) 2]) == [lindex $resultat_get_input 3]} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $::station(last) 1]} resultat_v4l2ctl
				after 1000 [list station_after_msg [lindex $::station(last) 2] $resultat_v4l2ctl]
			} else {
				set status_tv [tv_callbackMplayerRemote alive]
				if {$status_tv != 1} {
					tv_playbackStop 0 nopic
					set restart 1
				} else {
					set restart 0
				}
				main_stationInputLoop cancel 0 0 0 0 0
				set ::main(change_inputLoop_id) [after 200 [list main_stationInputLoop 0 $::kanalinput([lindex $::station(last) 2]) [lindex $::station(last) 1] [lindex $::station(last) 2] $restart 1]]
			}
			set last_channel_conf "$::where_is_home/config/lastchannel.conf"
			set last_channel_write [open $last_channel_conf w]
			puts -nonewline $last_channel_write "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
			close $last_channel_write
			return
		}
	}
}

proc main_stationChannelUp {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_stationChannelUp \033\[0m \{$w\}"
	for {set i 1} {$i <= $::station(max)} {incr i} {
		if {[string match $::kanalid($i) [lindex $::station(last) 0]]} {
			set calculation [expr {($i == $::station(max)) ? 1 : ($i + 1)}]
			set ::station(last) "\{$::kanalid($calculation)\} $::kanalcall($calculation) $calculation"
			set ::station(old) "\{$::kanalid($i)\} $::kanalcall($i) $i"
			$w configure -text "$::kanalid($calculation)"
			if {[winfo exists .frame_slistbox] == 1} {
				.frame_slistbox.listbox_slist see [expr $calculation - 1]
				if {[string trim [.frame_slistbox.listbox_slist curselection]] != {}} {
					.frame_slistbox.listbox_slist selection clear [.frame_slistbox.listbox_slist curselection]
					.frame_slistbox.listbox_slist activate [expr $calculation - 1]
				}
				.frame_slistbox.listbox_slist selection set [expr $calculation - 1]
			}
			log_writeOutTv 0 "Station next $::kanalid($calculation)."
			catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
			set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
			if {$::kanalinput([lindex $::station(last) 2]) == [lindex $resultat_get_input 3]} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $::station(last) 1]} resultat_v4l2ctl
				after 1000 [list station_after_msg [lindex $::station(last) 2] $resultat_v4l2ctl]
			} else {
				set status_tv [tv_callbackMplayerRemote alive]
				if {$status_tv != 1} {
					tv_playbackStop 0 nopic
					set restart 1
				} else {
					set restart 0
				}
				main_stationInputLoop cancel 0 0 0 0 0
				set ::main(change_inputLoop_id) [after 200 [list main_stationInputLoop 0 $::kanalinput([lindex $::station(last) 2]) [lindex $::station(last) 1] [lindex $::station(last) 2] $restart 1]]
			}
			set last_channel_conf "$::where_is_home/config/lastchannel.conf"
			set last_channel_write [open $last_channel_conf w]
			puts -nonewline $last_channel_write "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
			close $last_channel_write
			return
		}
	}
}

proc main_stationChannelJumper {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_stationChannelJumper \033\[0m \{$w\}"
	if {[info exists ::done_old_channel] == 0} {
		$w configure -text "[lindex $::station(old) 0]"
		if {[winfo exists .frame_slistbox] == 1} {
			.frame_slistbox.listbox_slist see [expr [lindex $::station(old) 2] - 1]
			if {[string trim [.frame_slistbox.listbox_slist curselection]] != {}} {
				.frame_slistbox.listbox_slist selection clear [.frame_slistbox.listbox_slist curselection]
				.frame_slistbox.listbox_slist activate [expr [lindex $::station(old) 2] - 1]
			}
			.frame_slistbox.listbox_slist selection set [expr [lindex $::station(old) 2] - 1]
		}
		set ::done_old_channel 1
		log_writeOutTv 0 "Jumping to station $::kanalid([lindex $::station(old) 2])."
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
		if {$::kanalinput([lindex $::station(old) 2]) == [lindex $resultat_get_input 3]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $::station(old) 1]} resultat_v4l2ctl
			after 1000 [list station_after_msg [lindex $::station(old) 2] $resultat_v4l2ctl]
		} else {
			set status_tv [tv_callbackMplayerRemote alive]
			if {$status_tv != 1} {
				tv_playbackStop 0 nopic
				set restart 1
			} else {
				set restart 0
			}
			main_stationInputLoop cancel 0 0 0 0 0
			set ::main(change_inputLoop_id) [after 200 [list main_stationInputLoop 0 $::kanalinput([lindex $::station(old) 2]) [lindex $::station(old) 1] [lindex $::station(old) 2] $restart 1]]
		}
		set last_channel_conf "$::where_is_home/config/lastchannel.conf"
		set last_channel_write [open $last_channel_conf w]
		puts -nonewline $last_channel_write "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
		close $last_channel_write
	} else {
		$w configure -text "[lindex $::station(last) 0]"
		if {[winfo exists .frame_slistbox] == 1} {
			.frame_slistbox.listbox_slist see [expr [lindex $::station(last) 2] - 1]
			if {[string trim [.frame_slistbox.listbox_slist curselection]] != {}} {
				.frame_slistbox.listbox_slist selection clear [.frame_slistbox.listbox_slist curselection]
				.frame_slistbox.listbox_slist activate [expr [lindex $::station(last) 2] - 1]
			}
			.frame_slistbox.listbox_slist selection set [expr [lindex $::station(last) 2] - 1]
		}
		unset -nocomplain ::done_old_channel
		log_writeOutTv 0 "Jumping to station $::kanalid([lindex $::station(last) 2])."
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
		if {$::kanalinput([lindex $::station(last) 2]) == [lindex $resultat_get_input 3]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $::station(last) 1]} resultat_v4l2ctl
			after 1000 [list station_after_msg [lindex $::station(last) 2] $resultat_v4l2ctl]
		} else {
			set status_tv [tv_callbackMplayerRemote alive]
			if {$status_tv != 1} {
				tv_playbackStop 0 nopic
				set restart 1
			} else {
				set restart 0
			}
			main_stationInputLoop cancel 0 0 0 0 0
			set ::main(change_inputLoop_id) [after 200 [list main_stationInputLoop 0 $::kanalinput([lindex $::station(last) 2]) [lindex $::station(last) 1] [lindex $::station(last) 2] $restart 1]]
		}
		set last_channel_conf "$::where_is_home/config/lastchannel.conf"
		set last_channel_write [open $last_channel_conf w]
		puts -nonewline $last_channel_write "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
		close $last_channel_write
	}
}

proc main_stationListboxStations {slist} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_stationListboxStations \033\[0m \{$slist\}"
	if {"[$slist cget -state]" != "disabled"} {
		set get_lb_index [$slist curselection]
		set get_lb_content [$slist get $get_lb_index]
		set ::station(old) "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
		set ::station(last) "\{[lrange $get_lb_content 1 end]\} $::kanalcall([lindex $get_lb_content 0]) [lindex $get_lb_content 0]"
		.label_stations configure -text [lrange $get_lb_content 1 end]
		log_writeOutTv 0 "Station listbox has been used to tune $::kanalid([lindex $::station(last) 2])."
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
		if {$::kanalinput([lindex $::station(last) 2]) == [lindex $resultat_get_input 3]} {
			catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $::station(last) 1]} resultat_v4l2ctl
			after 1000 [list station_after_msg [lindex $::station(last) 2] $resultat_v4l2ctl]
		} else {
			set status_tv [tv_callbackMplayerRemote alive]
			if {$status_tv != 1} {
				tv_playbackStop 0 nopic
				set restart 1
			} else {
				set restart 0
			}
			main_stationInputLoop cancel 0 0 0 0 0
			set ::main(change_inputLoop_id) [after 200 [list main_stationInputLoop 0 $::kanalinput([lindex $::station(last) 2]) [lindex $::station(last) 1] [lindex $::station(last) 2] $restart 1]]
		}
		if {"$slist" == ".tv.slist.lb_station"} {
			if {[winfo exists .frame_slistbox] == 1} {
				.frame_slistbox.listbox_slist see [expr [lindex $::station(last) 2] - 1]
				if {[string trim [.frame_slistbox.listbox_slist curselection]] != {}} {
					.frame_slistbox.listbox_slist selection clear [.frame_slistbox.listbox_slist curselection]
					.frame_slistbox.listbox_slist activate [expr [lindex $::station(last) 2] - 1]
				}
				.frame_slistbox.listbox_slist selection set [expr [lindex $::station(last) 2] - 1]
			}
		}
		set last_channel_conf "$::where_is_home/config/lastchannel.conf"
		set last_channel_write [open $last_channel_conf w]
		puts -nonewline $last_channel_write "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
		close $last_channel_write
	}
}

proc main_stationStationNrKeys {key} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_stationStationNrKeys \033\[0m \{$key\}"
	catch {after cancel $::main(change_keyid)}
	if {[info exists ::main(change_key)]} {
		if {[string length $::main(change_key)] == 4} {
			if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_key_w) 0] == 1} {
				after 0 {tv_osd osd_key_w 1000 "$::main(change_key)"}
			}
			if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_key_f) 0] == 1} {
				after 0 {tv_osd osd_key_f 1000 "$::main(change_key)"}
			}
			set ::main(change_keyid) [after 1000 [list main_stationStationNr .label_stations $::main(change_key)]]
			return
		}
	}
	append ::main(change_key) $key
	if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_key_w) 0] == 1} {
		after 0 {tv_osd osd_key_w 1000 "$::main(change_key)"}
	}
	if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_key_f) 0] == 1} {
		after 0 {tv_osd osd_key_f 1000 "$::main(change_key)"}
	}
	set ::main(change_keyid) [after 1000 [list main_stationStationNr .label_stations $::main(change_key)]]
}

proc main_stationStationNr {w number} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_stationStationNr \033\[0m \{$w\} \{$number\}"
	set number [scan $number %d]
	if {[info exists ::main(change_key)]} {
		unset -nocomplain ::main(change_key)
	}
	if {$number < 1 || $number > $::station(max)} {
		log_writeOutTv 1 "Selected station $number out of range."
		return
	}
	set ::station(old) "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
	set ::station(last) "\{$::kanalid($number)\} $::kanalcall($number) $number"
	$w configure -text "$::kanalid($number)"
	if {[winfo exists .frame_slistbox] == 1} {
		.frame_slistbox.listbox_slist see [expr $number - 1]
		if {[string trim [.frame_slistbox.listbox_slist curselection]] != {}} {
			.frame_slistbox.listbox_slist selection clear [.frame_slistbox.listbox_slist curselection]
			.frame_slistbox.listbox_slist activate [expr $number - 1]
		}
		.frame_slistbox.listbox_slist selection set [expr $number - 1]
	}
	log_writeOutTv 0 "Keycode, tuning station $::kanalid($number)."
	catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
	set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
	if {$::kanalinput([lindex $::station(last) 2]) == [lindex $resultat_get_input 3]} {
		catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $::station(last) 1]} resultat_v4l2ctl
		after 1000 [list station_after_msg [lindex $::station(last) 2] $resultat_v4l2ctl]
	} else {
		set status_tv [tv_callbackMplayerRemote alive]
		if {$status_tv != 1} {
			tv_playbackStop 0 nopic
			set restart 1
		} else {
			set restart 0
		}
		catch {exec v4l2-ctl --device=$::option(video_device) --set-input=$::kanalinput([lindex $::station(last) 2])}
		main_stationInputLoop cancel 0 0 0 0 0
		set ::main(change_inputLoop_id) [after 200 [list main_stationInputLoop 0 $::kanalinput([lindex $::station(last) 2]) [lindex $::station(last) 1] [lindex $::station(last) 2] $restart 1]]
	}
	set last_channel_conf "$::where_is_home/config/lastchannel.conf"
	set last_channel_write [open $last_channel_conf w]
	puts -nonewline $last_channel_write "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
	close $last_channel_write
	return
}

proc main_stationInput {com direct} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_stationInput \033\[0m \{$com\} \{$direct\}"
	if {$com == 1} {
		main_stationInputQuery cancel 0 0
		bind . <<input_up>> {}
		bind . <<input_down>> {}
		bind .tv <<input_up>> {}
		bind .tv <<input_down>> {}
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_query_input [catch {agrep -m "$read_vinput" video} resultat_query_input]
		catch {exec v4l2-ctl --device=$::option(video_device) --list-input} read_vinputs
		set status_list_input [catch {agrep -w "$read_vinputs" Input} resultat_list_input]
		if {$status_query_input == 0 && $status_list_input == 0} {
			set status_tv [tv_callbackMplayerRemote alive]
			if {$status_tv != 1} {
				tv_playbackStop 0 nopic
				set restart 1
			} else {
				set restart 0
			}
			set i 0
			foreach input [split $resultat_list_input \n] {
				if {[string trim $input] == {}} continue
				set vinput($i) [lindex $input end]
				set max_inputs $i
				incr i
			}
			if {[expr [string trim [lindex $resultat_query_input 3]] + $direct] > $max_inputs} {
				set ::data(after_id_input) [after 100 [list main_stationInputQuery 100 0 $restart]]
				return
			}
			if {[expr [string trim [lindex $resultat_query_input 3]] + $direct] < 0} {
				set ::data(after_id_input) [after 100 [list main_stationInputQuery 100 $max_inputs $restart]]
			} else {
				set ::data(after_id_input) [after 100 [list main_stationInputQuery 100 [expr [string trim [lindex $resultat_query_input 3]] + $direct] $restart]]
				return
			}
		} else {
			log_writeOutTv 1 "Can not retrieve video inputs."
			log_writeOutTv 1 "Error message: $resultat_list_input"
		}
	} else {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_grep_input [catch {agrep -m "$read_vinput" video} resultat_grep_input]
		if {$status_grep_input == 0} {
			if {[lindex $resultat_grep_input 3] != $::option(video_input)} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-input=$::option(video_input)} resultat
				log_writeOutTv 0 "Change video input to $::option(video_input)"
			}
		} else {
			log_writeOutTv 1 "Can not change video input."
			log_writeOutTv 1 "Error message: $resultat_grep_input"
		}
	}
}

proc main_stationInputLoop {secs input freq snumber restart aftmsg} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_stationInputLoop \033\[0m \{$secs\} \{$input\} \{$freq\} \{$snumber\} \{$restart\} \{$aftmsg\}"
	if {"$secs" == "cancel"} {
		if {[info exists ::main(change_inputLoop_id)]} {
			foreach id [split $::main(change_inputLoop_id)] {
				after cancel $id
			}
		}
		unset -nocomplain ::main(change_inputLoop_id)
		return
	}
	if {$secs == 3000} {
		log_writeOutTv 1 "Waited 3 seconds to change video input to $input."
		log_writeOutTv 1 "This didn't work, BAD."
		return
	}
	catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
	set status_grep_input [catch {agrep -m "$read_vinput" video} resultat_grep_input]
	if {$status_grep_input == 0} {
		if {$input == [lindex $resultat_grep_input 3]} {
			log_writeOutTv 0 "Changed video input to $input."
			if {[winfo exists .tv]} {
				if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
					after 0 [list tv_osd osd_group_w 1000 [string trim [string range $resultat_grep_input [string first \( $resultat_grep_input] end] ()]]
				}
				if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
					after 0 [list tv_osd osd_group_f 1000 [string trim [string range $resultat_grep_input [string first \( $resultat_grep_input] end] ()]]
				}
			}
			catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$freq} resultat_v4l2ctl
			if {$aftmsg == 1} {
				if {$secs < 1000} {
					after [expr 1000 - $secs] [list station_after_msg $snumber $resultat_v4l2ctl]
				} else {
					after 0 [list station_after_msg $snumber $resultat_v4l2ctl]
				}
			}
			if {$restart == 1} {
				tv_playerRendering
			}
			return
		} else {
			catch {exec v4l2-ctl --device=$::option(video_device) --set-input=$input}
			set ::main(change_inputLoop_id) [after 100 [list main_stationInputLoop [expr $secs + 100] $input $freq $snumber $restart $aftmsg]]
		}
	} else {
		log_writeOutTv 1 "Can not change video input to $input."
		log_writeOutTv 1 "$resultat_grep_input."
		return
	}
}

proc main_stationInputQuery {secs input restart} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: main_stationInputQuery \033\[0m \{$secs\} \{$input\} \{$restart\}"
	if {"$secs" == "cancel"} {
		if {[info exists ::data(after_id_input)]} {
			foreach id [split $::data(after_id_input)] {
				after cancel $id
			}
		}
		unset -nocomplain ::data(after_id_input)
		return
	}
	if {$secs == 3000} {
		log_writeOutTv 1 "Waited 3 seconds to change video input to $input."
		log_writeOutTv 1 "This didn't work, BAD."
		return
	}
	catch {exec v4l2-ctl --device=$::option(video_device) --get-input} check_back_input
	if {[string trim $check_back_input] != {}} {
		if {[string trim [lindex $check_back_input 3]] != $input} {
			catch {exec v4l2-ctl --device=$::option(video_device) --set-input=$input}
			set ::data(after_id_input) [after 100 "main_stationInputQuery [expr $secs + 100] $input $restart"]
		} else {
			log_writeOutTv 0 "Changed video input to $input"
			if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
				after 0 [list tv_osd osd_group_w 1000 [string trim [string range $check_back_input [string first \( $check_back_input] end] ()]]
			}
			if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
				after 0 [list tv_osd osd_group_f 1000 [string trim [string range $check_back_input [string first \( $check_back_input] end] ()]]
			}
			if {$restart == 1} {
				tv_Playback .tv.bg .tv.bg.w 0 0
			} else {
				bind . <<input_up>> "main_stationInput 1 1"
				bind . <<input_down>> "main_stationInput 1 -1"
				bind .tv <<input_up>> "main_stationInput 1 1"
				bind .tv <<input_down>> "main_stationInput 1 -1"
			}
			return
		}
	}
}
