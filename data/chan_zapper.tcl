#       chan_zapper.tcl
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

proc chan_zapperNext {tree} {
	# Zap to next station, tree is widget path of station list treeview
	puts $::main(debug_msg) "\033\[0;1;33mDebug: chan_zapperNext \033\[0m \{$tree\}"
	for {set i 1} {$i <= $::station(max)} {incr i} {
		if {[string match $::kanalid($i) [lindex $::station(last) 0]]} {
			set calculation [expr {($i == $::station(max)) ? 1 : ($i + 1)}]
			set ::station(last) "\{$::kanalid($calculation)\} $::kanalcall($calculation) $calculation"
			set ::station(old) "\{$::kanalid($i)\} $::kanalcall($i) $i"
			log_writeOutTv 0 "Station next $::kanalid($calculation)."
			bind $tree <<TreeviewSelect>> {}
			$tree selection set $::kanalitemID([lindex $::station(last) 2])
			$tree see [$tree selection]
			after idle [list after 0 chan_zapperEventLoop $tree last]
			chan_zapperInputStart $tree last
			break
		}
	}
}

proc chan_zapperPrior {tree} {
	# Zap to prior station, tree is widget path of station list treeview
	puts $::main(debug_msg) "\033\[0;1;33mDebug: chan_zapperPrior \033\[0m \{$tree\}"
	for {set i 1} {$i <= $::station(max)} {incr i} {
		if {[string match $::kanalid($i) [lindex $::station(last) 0]]} {
			set calculation [expr {($i == 1) ? $::station(max) : ($i - 1)}]
			set ::station(last) "\{$::kanalid($calculation)\} $::kanalcall($calculation) $calculation"
			set ::station(old) "\{$::kanalid($i)\} $::kanalcall($i) $i"
			log_writeOutTv 0 "Station prior $::kanalid($calculation)."
			bind $tree <<TreeviewSelect>> {}
			$tree selection set $::kanalitemID([lindex $::station(last) 2])
			$tree see [$tree selection]
			after idle [list after 0 chan_zapperEventLoop $tree last]
			chan_zapperInputStart $tree last
			break
		}
	}
}

proc chan_zapperEventLoop {tree lasts} {
	#FIXME Why is the proc chan_zapperEventLoopneeded?
	bind $tree <<TreeviewSelect>> [list chan_zapperTree $tree]
}

proc chan_zapperTree {tree} {
	# Zap to station selected in treeview, tree is widget path of station list treeview
	puts $::main(debug_msg) "\033\[0;1;33mDebug: chan_zapperTree \033\[0m \{$tree\}"
	if {"[$tree state]" != "disabled"} {
		set get_tree_item [$tree item [$tree selection] -values]
		set ::station(old) "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
		set ::station(last) "\{[lindex $get_tree_item 0]\} $::kanalcall([lindex $get_tree_item 1]) [lindex $get_tree_item 1]"
		log_writeOutTv 0 "Station treeview has been used to tune $::kanalid([lindex $::station(last) 2])."
		chan_zapperInputStart $tree last
	}
}

proc chan_zapperJump {tree} {
	# Jump between the last two stations, tree is widget path of station list treeview
	puts $::main(debug_msg) "\033\[0;1;33mDebug: chan_zapperJump \033\[0m \{$tree\}"
	if {$::chan(old_channel) == 0} {
		set ::chan(old_channel) 1
		log_writeOutTv 0 "Jumping to station $::kanalid([lindex $::station(old) 2])."
		bind $tree <<TreeviewSelect>> {}
		$tree selection set $::kanalitemID([lindex $::station(old) 2])
		$tree see [$tree selection]
		after idle [list after 0 chan_zapperEventLoop $tree old]
		chan_zapperInputStart $tree old
	} else {
		set ::chan(old_channel) 0
		log_writeOutTv 0 "Jumping to station $::kanalid([lindex $::station(last) 2])."
		bind $tree <<TreeviewSelect>> {}
		$tree selection set $::kanalitemID([lindex $::station(last) 2])
		$tree see [$tree selection]
		after idle [list after 0 chan_zapperEventLoop $tree last]
		chan_zapperInputStart $tree last
	}
}

proc chan_zapperStationNrKeys {key} {
	# Use keys to select station, key is the pressed key. Shows the result in OSD
	puts $::main(debug_msg) "\033\[0;1;33mDebug: chan_zapperStationNrKeys \033\[0m \{$key\}"
	catch {after cancel $::chan(change_keyid)}
	if {[info exists ::chan(change_key)]} {
		if {[string length $::chan(change_key)] == 4} {
			if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_key_w) 0] == 1} {
				after 0 {vid_osd osd_key_w 1000 "$::chan(change_key)"}
			}
			if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_key_f) 0] == 1} {
				after 0 {vid_osd osd_key_f 1000 "$::chan(change_key)"}
			}
			set ::chan(change_keyid) [after 1000 [list chan_zapperStationNr .fstations.treeSlist $::chan(change_key)]]
			return
		}
	}
	append ::chan(change_key) $key
	if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_key_w) 0] == 1} {
		after 0 {vid_osd osd_key_w 1000 "$::chan(change_key)"}
	}
	if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_key_f) 0] == 1} {
		after 0 {vid_osd osd_key_f 1000 "$::chan(change_key)"}
	}
	set ::chan(change_keyid) [after 1000 [list chan_zapperStationNr .fstations.treeSlist $::chan(change_key)]]
}

proc chan_zapperStationNr {tree number} {
	#Doing the actual station change invoked by pressing numbers. tree --> treeview widget station list, number to work with
	puts $::main(debug_msg) "\033\[0;1;33mDebug: chan_zapperStationNr \033\[0m \{$tree\} \{$number\}"
	set number [scan $number %d]
	if {[info exists ::chan(change_key)]} {
		unset -nocomplain ::chan(change_key)
	}
	if {$number < 1 || $number > $::station(max)} {
		log_writeOutTv 1 "Selected station $number out of range."
		return
	}
	set ::station(old) "\{[lindex $::station(last) 0]\} [lindex $::station(last) 1] [lindex $::station(last) 2]"
	set ::station(last) "\{$::kanalid($number)\} $::kanalcall($number) $number"
	log_writeOutTv 0 "Keycode, tuning station $::kanalid($number)."
	bind $tree <<TreeviewSelect>> {}
	$tree selection set $::kanalitemID([lindex $::station(last) 2])
	$tree see [$tree selection]
	after idle [list after 0 chan_zapperEventLoop $tree last]
	chan_zapperInputStart $tree last
}

proc chan_zapperInput {com direct} {
	#Change Video Input through key-sequence (com 1) or at startup.
	puts $::main(debug_msg) "\033\[0;1;33mDebug: chan_zapperInput \033\[0m \{$com\} \{$direct\}"
	if {$com == 1} {
		chan_zapperInputQuery cancel 0 0
		bind . <<input_next>> {}
		bind . <<input_prior>> {}
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_query_input [catch {agrep -m "$read_vinput" video} resultat_query_input]
		catch {exec v4l2-ctl --device=$::option(video_device) --list-input} read_vinputs
		set status_list_input [catch {agrep -w "$read_vinputs" Input} resultat_list_input]
		if {$status_query_input == 0 && $status_list_input == 0} {
			set status_tv [vid_callbackMplayerRemote alive]
			if {$status_tv != 1} {
				vid_playbackStop 0 nopic
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
				set ::data(after_id_input) [after 100 [list chan_zapperInputQuery 100 0 $restart]]
				return
			}
			if {[expr [string trim [lindex $resultat_query_input 3]] + $direct] < 0} {
				set ::data(after_id_input) [after 100 [list chan_zapperInputQuery 100 $max_inputs $restart]]
			} else {
				set ::data(after_id_input) [after 100 [list chan_zapperInputQuery 100 [expr [string trim [lindex $resultat_query_input 3]] + $direct] $restart]]
				return
			}
		} else {
			log_writeOutTv 2 "Can not retrieve video inputs."
			log_writeOutTv 2 "Error message: $resultat_list_input"
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
			log_writeOutTv 2 "Can not change video input."
			log_writeOutTv 2 "Error message: $resultat_grep_input"
		}
	}
}

proc chan_zapperInputLoop {secs input freq snumber restart aftmsg} {
	#A loop function that tries for 3 seconds to change video input. This necessary because sometimes after stoping Playback the device is still blocked. 
	#Additionally this function handels the frequency changing.
	#secs - Time that has passed since the function was called; input - Video Input, freq - Frequency, snumber - Station Number; restart - Restart playback; aftmsg - Message to write to log and display in osd
	puts $::main(debug_msg) "\033\[0;1;33mDebug: chan_zapperInputLoop \033\[0m \{$secs\} \{$input\} \{$freq\} \{$snumber\} \{$restart\} \{$aftmsg\}"
	if {"$secs" == "cancel"} {
		if {[info exists ::chan(change_inputLoop_id)]} {
			foreach id [split $::chan(change_inputLoop_id)] {
				after cancel $id
			}
		}
		unset -nocomplain ::chan(change_inputLoop_id)
		return
	}
	if {$secs == 3000} {
		log_writeOutTv 2 "Waited 3 seconds to change video input to $input."
		log_writeOutTv 2 "This didn't work, BAD."
		if {$::option(log_warnDialogue)} {
			status_feedbWarn 1 [mc "Timeout for changing video input"]
		}
		return
	}
	if {[file exists $::option(video_device)] == 0} {
		log_writeOutTv 2 "The Video Device $::option(video_device) does not exist."
		log_writeOutTv 2 "Have a look into the preferences and change it."
		if {$::option(log_warnDialogue)} {
			status_feedbWarn 1 [mc "Video device % does not exist" $::option(video_device)]
		}
		return
	}
	set status_tv [vid_callbackMplayerRemote alive]
	if {$status_tv != 1} {
		#FIXME Why is the next line deactivated
		#~ vid_playbackStop 0 nopic
		set ::chan(change_inputLoop_id) [after 100 [list chan_zapperInputLoop [expr $secs + 100] $input $freq $snumber $restart $aftmsg]]
	} else {
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_grep_input [catch {agrep -m "$read_vinput" video} resultat_grep_input]
		if {$status_grep_input == 0} {
			if {$input == [lindex $resultat_grep_input 3]} {
				log_writeOutTv 0 "Changed video input to $input."
				if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
					after 0 [list vid_osd osd_group_w 1000 [string trim [string range $resultat_grep_input [string first \( $resultat_grep_input] end] ()]]
				}
				if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
					after 0 [list vid_osd osd_group_f 1000 [string trim [string range $resultat_grep_input [string first \( $resultat_grep_input] end] ()]]
				}
				if {$snumber == 0} {
					catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$freq} resultat_v4l2ctl
				} else {
					if {[string is digit $snumber]} {
						if {$::kanalext($snumber) == 0} {
							catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$freq} resultat_v4l2ctl
						} else {
							if {$::kanalextfreq($snumber) != 0} {
								catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$::kanalextfreq($snumber)} resultat_v4l2ctl
							}
							catch {exec {*}$::kanalext($snumber) &}
							set resultat_v4l2ctl External
						}
					} else {
						catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $snumber end]} resultat_v4l2ctl
						set extCommand [lrange $snumber 0 end-1]
						catch {exec {*}$extCommand &}
						set resultat_v4l2ctl External
					}
				}
				if {$aftmsg == 1} {
					if {$secs < 1000} {
						after [expr 1000 - $secs] [list station_after_msg $snumber $resultat_v4l2ctl]
					} else {
						after 0 [list station_after_msg $snumber $resultat_v4l2ctl]
					}
				}
				if {$restart == 1} {
					vid_playbackRendering
				}
				return
			} else {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-input=$input}
				set ::chan(change_inputLoop_id) [after 100 [list chan_zapperInputLoop [expr $secs + 100] $input $freq $snumber $restart $aftmsg]]
			}
		} else {
			log_writeOutTv 2 "Can not change video input to $input."
			log_writeOutTv 2 "$resultat_grep_input."
			return
		}
	}
}

proc chan_zapperInputQuery {secs input restart} {
	# Loop that tries to change the video input every 100 ms until 3 seconds
	puts $::main(debug_msg) "\033\[0;1;33mDebug: chan_zapperInputQuery \033\[0m \{$secs\} \{$input\} \{$restart\}"
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
		log_writeOutTv 2 "Waited 3 seconds to change video input to $input."
		log_writeOutTv 2 "This didn't work, BAD."
		if {$::option(log_warnDialogue)} {
			status_feedbWarn 1 [mc "Timeout for changing video input"]
		}
		return
	}
	if {[file exists $::option(video_device)] == 0} {
		log_writeOutTv 2 "The Video Device $::option(video_device) does not exist."
		log_writeOutTv 2 "Have a look into the preferences and change it."
		if {$::option(log_warnDialogue)} {
			status_feedbWarn 1 [mc "Video device % does not exist" $::option(video_device)]
		}
		return
	}
	catch {exec v4l2-ctl --device=$::option(video_device) --get-input} check_back_input
	if {[string trim $check_back_input] != {}} {
		if {[string trim [lindex $check_back_input 3]] != $input} {
			catch {exec v4l2-ctl --device=$::option(video_device) --set-input=$input}
			set ::data(after_id_input) [after 100 "chan_zapperInputQuery [expr $secs + 100] $input $restart"]
		} else {
			log_writeOutTv 0 "Changed video input to $input"
			if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_group_w) 0] == 1} {
				after 0 [list vid_osd osd_group_w 1000 [string trim [string range $check_back_input [string first \( $check_back_input] end] ()]]
			}
			if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_group_f) 0] == 1} {
				after 0 [list vid_osd osd_group_f 1000 [string trim [string range $check_back_input [string first \( $check_back_input] end] ()]]
			}
			if {$restart == 1} {
				vid_Playback .fvidBg .fvidBg.cont 0 0
			} else {
				bind . <<input_next>> "chan_zapperInput 1 1"
				bind . <<input_prior>> "chan_zapperInput 1 -1"
			}
			return
		}
	}
}

proc chan_zapperInputStart {tree lasts} {
	#Invoked by all channel changer procs. Changing video input if necessary then frequency.
	puts $::main(debug_msg) "\033\[0;1;33mDebug: chan_zapperInputStart \033\[0m \{$tree\} \{$lasts\}"
	catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
	set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
	if {$status_get_input == 0} {
		if {$::kanalinput([lindex $::station($lasts) 2]) == [lindex $resultat_get_input 3]} {
			if {$::kanalext([lindex $::station($lasts) 2]) == 0} {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $::station($lasts) 1]} resultat_v4l2ctl
			} else {
				if {$::kanalextfreq([lindex $::station($lasts) 2]) != 0} {
					catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$::kanalextfreq([lindex $::station($lasts) 2])} resultat_v4l2ctl
				}
				catch {exec {*}$::kanalext([lindex $::station($lasts) 2]) &}
				set resultat_v4l2ctl External
			}
			after 1000 [list station_after_msg [lindex $::station($lasts) 2] $resultat_v4l2ctl]
		} else {
			set status_tv [vid_callbackMplayerRemote alive]
			if {$status_tv != 1} {
				vid_playbackStop 0 nopic
				set restart 1
			} else {
				set restart 0
			}
			chan_zapperInputLoop cancel 0 0 0 0 0
			set ::chan(change_inputLoop_id) [after 200 [list chan_zapperInputLoop 0 $::kanalinput([lindex $::station($lasts) 2]) [lindex $::station($lasts) 1] [lindex $::station($lasts) 2] $restart 1]]
		}
		set last_channel_conf "$::option(home)/config/lastchannel.conf"
		set last_channel_write [open $last_channel_conf w]
		puts -nonewline $last_channel_write "\{[lindex $::station($lasts) 0]\} [lindex $::station($lasts) 1] [lindex $::station($lasts) 2]"
		close $last_channel_write
	} else {
		log_writeOutTv 2 "Can not read video inputs. Changing stations not possible."
	}
}
