#       station_edit.tcl
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

proc station_editPreview {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_editPreview \033\[0m \{$w\}"
	log_writeOutTv 0 "Starting tv playback for preview stations."
	set status_vid_Playback [vid_callbackMplayerRemote alive]
	if {$status_vid_Playback != 1} {
		vid_playbackStop 0 pic
	} else {
		if {"[string trim [$w selection]]" == {}} {
			log_writeOutTv 1 "You need to select a channel to be previewed."
			return
		}
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
		if {$status_get_input == 0} {
			if {[lindex [$w item [lindex [$w selection] end] -values] 2] == [lindex $resultat_get_input 3]} {
				set freq [lindex [$w item [lindex [$w selection] end] -values] 1]
				if {[lindex [$w item [lindex [$w selection] end] -values] 3] == 0} {
					catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$freq}
				} else {
					catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex [$w item [lindex [$w selection] end] -values] 4]}
					catch {exec {*}[lindex [$w item [lindex [$w selection] end] -values] 3] &}
				}
				status_feedbMsgs 0 [mc "Now playing %" [lindex [$w item [lindex [$w selection] end] -values] 0]]
				vid_Playback .fvidBg .fvidBg.cont 0 0
			} else {
				vid_playbackStop 0 nopic
				chan_zapperInputLoop cancel 0 0 0 0 0
				if {[lindex [$w item [lindex [$w selection] end] -values] 3] != 0 && [lindex [$w item [lindex [$w selection] end] -values] 4] != 0} {
					set ::chan(change_inputLoop_id) [after 200 [list chan_zapperInputLoop 0 [lindex [$w item [lindex [$w selection] end] -values] 2] [lindex [$w item [lindex [$w selection] end] -values] 2] "[lindex [$w item [lindex [$w selection] end] -values] 3] [lindex [$w item [lindex [$w selection] end] -values] 4]" 1 0]]
				} else {
					set ::chan(change_inputLoop_id) [after 200 [list chan_zapperInputLoop 0 [lindex [$w item [lindex [$w selection] end] -values] 2] [lindex [$w item [lindex [$w selection] end] -values] 2] [lindex [$w item [lindex [$w selection] end] -values] 3] 1 0]]
				}
				status_feedbMsgs 0 [mc "Now playing %" [lindex [$w item [lindex [$w selection] end] -values] 0]]
			}
		} else {
			log_writeOutTv 2 "Can not read video inputs. Changing stations not possible."
		}
	}
}

proc station_editZap {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_editZap \033\[0m \{$w\}"
	set status_vid_Playback [vid_callbackMplayerRemote alive]
	if {$status_vid_Playback != 1} {
		log_writeOutTv 0 "Changing frequency to [lindex [$w item [lindex [$w selection] end] -values] 1]."
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
		if {$status_get_input == 0} {
			if {[lindex [$w item [lindex [$w selection] end] -values] 2] == [lindex $resultat_get_input 3]} {
				if {[lindex [$w item [lindex [$w selection] end] -values] 3] == 0} {
					catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex [$w item [lindex [$w selection] end] -values] 1]}
				} else {
					catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex [$w item [lindex [$w selection] end] -values] 4]}
					catch {exec {*}[lindex [$w item [lindex [$w selection] end] -values] 3] &}
				}
				status_feedbMsgs 0 [mc "Now playing %" [lindex [$w item [lindex [$w selection] end] -values] 0]]
				return
			} else {
				vid_playbackStop 0 nopic
				chan_zapperInputLoop cancel 0 0 0 0 0
				if {[lindex [$w item [lindex [$w selection] end] -values] 3] != 0 && [lindex [$w item [lindex [$w selection] end] -values] 4] != 0} {
					set ::chan(change_inputLoop_id) [after 200 [list chan_zapperInputLoop 0 [lindex [$w item [lindex [$w selection] end] -values] 2] [lindex [$w item [lindex [$w selection] end] -values] 1] "[lindex [$w item [lindex [$w selection] end] -values] 3] [lindex [$w item [lindex [$w selection] end] -values] 4]" 1 0]]
				} else {
					set ::chan(change_inputLoop_id) [after 200 [list chan_zapperInputLoop 0 [lindex [$w item [lindex [$w selection] end] -values] 2] [lindex [$w item [lindex [$w selection] end] -values] 1] [lindex [$w item [lindex [$w selection] end] -values] 3] 1 0]]
				}
				status_feedbMsgs 0 [mc "Now playing %" [lindex [$w item [lindex [$w selection] end] -values] 0]]
			}
		} else {
			log_writeOutTv 2 "Can not read video inputs. Changing stations not possible."
		}
	}
}


proc station_editSave {w} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_editSave \033\[0m \{$w\}"
	log_writeOutTv 0 "Writing stations to $::option(home)/config/stations_$::option(frequency_table).conf"
	catch {file delete "$::option(home)/config/stations_$::option(frequency_table).conf"}
	catch {file delete "$::option(home)/config/lastchannel.conf"}
	foreach sitem [split [$w children {}]] {
		if {[file exists "$::option(home)/config/stations_$::option(frequency_table).conf"] != 1} {
			set open_sfile_write [open "$::option(home)/config/stations_$::option(frequency_table).conf" w]
			if {"[$w item $sitem -tags]" == "disabled"} {
				puts -nonewline $open_sfile_write "\#\{[lindex [$w item $sitem -values] 0]\} [string trim [lindex [$w item $sitem -values] 1]] [lindex [$w item $sitem -values] 2] \{[lindex [$w item $sitem -values] 3]\} [lindex [$w item $sitem -values] 4]"
			} else {
				puts -nonewline $open_sfile_write "\{[lindex [$w item $sitem -values] 0]\} [string trim [lindex [$w item $sitem -values] 1]] [lindex [$w item $sitem -values] 2] \{[lindex [$w item $sitem -values] 3]\} [lindex [$w item $sitem -values] 4]"
			}
			close $open_sfile_write
		} else {
			set open_sfile_append [open "$::option(home)/config/stations_$::option(frequency_table).conf" a]
			if {"[$w item $sitem -tags]" == "disabled"} {
				puts -nonewline $open_sfile_append "
\#\{[lindex [$w item $sitem -values] 0]\} [string trim [lindex [$w item $sitem -values] 1]] [lindex [$w item $sitem -values] 2] \{[lindex [$w item $sitem -values] 3]\} [lindex [$w item $sitem -values] 4]"
			} else {
				puts -nonewline $open_sfile_append "
\{[lindex [$w item $sitem -values] 0]\} [string trim [lindex [$w item $sitem -values] 1]] [lindex [$w item $sitem -values] 2] \{[lindex [$w item $sitem -values] 3]\} [lindex [$w item $sitem -values] 4]"
			}
			close $open_sfile_append
		}
	}
	station_editExit save
}

proc station_editExit {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_editExit \033\[0m \{$handler\}"
	if {"$handler" == "save"} {
		catch {array unset ::kanalid}
		catch {array unset ::kanalcall}
		catch {array unset ::kanalinput}
		catch {array unset ::kanalext}
		catch {array unset ::kanalextfreq}
		log_writeOutTv 0 "Rereading all stations and corresponding frequencies for main application."
		if !{[file exists "$::option(home)/config/stations_$::option(frequency_table).conf"]} {
			set status_vid_Playback [vid_callbackMplayerRemote alive]
			if {$status_vid_Playback != 1} {
				vid_playbackStop 0 nopic
			}
			log_writeOutTv 2 "No valid stations_$::option(frequency_table).conf"
			log_writeOutTv 2 "Please create one using the Station Editor."
			log_writeOutTv 2 "Make sure you checked the configuration first!"
		} else {
			set file "$::option(home)/config/stations_$::option(frequency_table).conf"
			set open_channel_file [open $file r]
			set i 1
			while {[gets $open_channel_file line]!=-1} {
				if {[string match #* $line] || [string trim $line] == {} } continue
				if {[llength $line] < 5} {
					if {[llength $line] == 2} {
						lassign $line ::kanalid($i) ::kanalcall($i)
						set ::kanalinput($i) $::option(video_input)
						set ::kanalext($i) 0
						set ::kanalextfreq($i) 0
					}
					if {[llength $line] == 3} {
						lassign $line ::kanalid($i) ::kanalcall($i) ::kanalinput($i)
						set ::kanalext($i) 0
						set ::kanalextfreq($i) 0
					}
					if {[llength $line] == 4} {
						lassign $line ::kanalid($i) ::kanalcall($i) ::kanalinput($i) ::kanalext($i)
						set ::kanalextfreq($i) 0
					}
				} else {
					lassign $line ::kanalid($i) ::kanalcall($i) ::kanalinput($i) ::kanalext($i) ::kanalextfreq($i)
				}
				set ::station(max) $i
				incr i
			}
			close $open_channel_file
			if {[array exists ::kanalid] == 0 || [array exists ::kanalcall] == 0 } {
				log_writeOutTv 2 "No valid stations_$::option(frequency_table).conf"
				log_writeOutTv 2 "Please create one using the Station Editor."
				log_writeOutTv 2 "Make sure you checked the configuration first!"
			} else {
				log_writeOutTv 0 "Valid stations_$::option(frequency_table).conf found with $::station(max) stations."
				if {[file exists "$::option(home)/config/lastchannel.conf"]} {
					set last_channel_conf "$::option(home)/config/lastchannel.conf"
					set open_lastchannel [open $last_channel_conf r]
					set open_lastchannel_read [read $open_lastchannel]
					lassign $open_lastchannel_read kanal channel sendernummer
					set ::station(last) "\{$kanal\} $channel $sendernummer"
					set ::station(old) "\{$kanal\} $channel $sendernummer"
					if {$::kanalext([lindex $::station(last) 2]) == 0} {
						catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $::station(last) 1]} resultat_v4l2ctl
					} else {
						if {$::kanalextfreq([lindex $::station(last) 2]) != 0} {
							catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$::kanalextfreq([lindex $::station(last) 2])} resultat_v4l2ctl
						}
						catch {exec {*}$::kanalext([lindex $::station(last) 2]) &}
						set resultat_v4l2ctl External
					}
					close $open_lastchannel
					after 1000 [list station_after_msg [lindex $::station(last) 2] $resultat_v4l2ctl]
				} else {
					set last_channel_conf "$::option(home)/config/lastchannel.conf"
					set fileId [open $last_channel_conf "w"]
					puts -nonewline $fileId "\{$::kanalid(1)\} $::kanalcall(1) 1"
					close $fileId
					set ::station(last) "\{$::kanalid(1)\} $::kanalcall(1) 1"
					set ::station(old) "\{$::kanalid(1)\} $::kanalcall(1) 1"
					if {$::kanalext([lindex $::station(last) 2]) == 0} {
						catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=[lindex $::station(last) 1]} resultat_v4l2ctl
					} else {
						if {$::kanalextfreq([lindex $::station(last) 2]) != 0} {
							catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$::kanalextfreq([lindex $::station(last) 2])} resultat_v4l2ctl
						}
						catch {exec {*}$::kanalext([lindex $::station(last) 2]) &}
						set resultat_v4l2ctl External
					}
					after 1000 [list station_after_msg [lindex $::station(last) 2] $resultat_v4l2ctl]
				}
			}
		}
		main_frontendChannelHandler sedit
		log_writeOutTv 0 "Exiting station editor."
	} else {
		log_writeOutTv 0 "Exiting station editor without any changes."
	}
	vid_wmCursor 1
	grab release .station
	destroy .station
}

proc station_editUiMenu {tree x y} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_editUi \033\[0m \{$tree\} \{$x\} \{$y\}"
	if {[winfo exists $tree.mCont] == 0} {
		menu $tree.mCont -tearoff 0
		$tree.mCont add command -label [mc "Station search"] -command [list station_searchUi $tree] -image $::icon_men(search) -compound left
		$tree.mCont add separator
		$tree.mCont add command -label [mc "Add"] -command [list station_itemAddEdit $tree 1] -compound left -image $::icon_men(item-add)
		$tree.mCont add command -label [mc "Delete"] -command [list station_itemDelete $tree] -compound left -image $::icon_men(item-remove)
		$tree.mCont add command -label [mc "Edit"] -command [list station_itemAddEdit $tree 2] -compound left -image $::icon_men(seditor)
		$tree.mCont add command -label [mc "Lock"] -command [list station_itemDeactivate $tree .station.top_buttons.b_station_activate 1] -compound left -image $::icon_men(locked)
		$tree.mCont add separator
		$tree.mCont add command -label [mc "Up"] -command [list station_itemMove $tree -1] -compound left -image $::icon_men(channel-prior)
		$tree.mCont add command -label [mc "Down"] -command [list station_itemMove $tree 1] -compound left -image $::icon_men(channel-next)
		$tree.mCont add separator
		$tree.mCont add command -label [mc "Preview"] -command [list station_editPreview $tree] -compound left -image $::icon_men(starttv)
	}
	log_writeOutTv 0 "Pop up context for station editor"
	if {[string trim [$tree selection]] == {}} {
		$tree.mCont entryconfigure 3 -state disabled
		$tree.mCont entryconfigure 4 -state disabled
		$tree.mCont entryconfigure 5 -state disabled
		$tree.mCont entryconfigure 7 -state disabled
		$tree.mCont entryconfigure 8 -state disabled
	} else {
		$tree.mCont entryconfigure 3 -state normal
		$tree.mCont entryconfigure 4 -state normal
		$tree.mCont entryconfigure 5 -state normal
		$tree.mCont entryconfigure 7 -state normal
		$tree.mCont entryconfigure 8 -state normal
	}
	tk_popup $tree.mCont $x $y
}

proc station_editUi {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_editUi \033\[0m"
	if {[winfo exists .tray] == 1} {
		if {[winfo ismapped .] == 0} {
			log_writeOutTv 1 "User attempted to start station editor while main is docked."
			log_writeOutTv 1 "Will undock main."
			 system_trayToggle 0
		}
	}
	
	if {[wm attributes . -fullscreen] == 1} {
		event generate . <<wmFull>>
	}
	
	# Setting up main Interface
	
	log_writeOutTv 0 "Starting Station Editor."
	
	if {[winfo exists .station] == 0 } {
		set w [toplevel .station]
		place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		set wfstation [ttk::frame $w.wfstation]
		set wfbottom [ttk::frame $w.bottom_buttons -style TLabelframe]
		set wftop [ttk::frame $w.top_buttons] ; place [ttk::label $wftop.bg -style Toolbutton] -relwidth 1 -relheight 1
		
		ttk::button $wftop.b_station_search -text [mc "Station search"] -style Toolbutton -command [list station_searchUi $wfstation.tv_station] -compound top -image $::icon_m(search)
		ttk::separator $wftop.sr_1 -orient vertical
		ttk::button $wftop.b_station_add -text [mc "Add"] -style Toolbutton -command [list station_itemAddEdit $wfstation.tv_station 1] -compound top -image $::icon_m(item-add)
		ttk::button $wftop.b_station_delete -text [mc "Delete"] -style Toolbutton -command [list station_itemDelete $wfstation.tv_station] -compound top -image $::icon_m(item-remove)
		ttk::button $wftop.b_station_activate -text [mc "Lock"] -style Toolbutton -command [list station_itemDeactivate $wfstation.tv_station $wftop.b_station_activate 1] -compound top -image $::icon_m(locked)
		ttk::button $wftop.b_station_edit -text [mc "Edit"] -style Toolbutton -command [list station_itemAddEdit $wfstation.tv_station 2] -compound top -image $::icon_m(seditor)
		ttk::separator $wftop.sr_2 -orient vertical
		ttk::button $wftop.b_station_up -text [mc "Up"] -style Toolbutton -command [list station_itemMove $wfstation.tv_station -1] -compound top -image $::icon_m(channel-prior)
		ttk::button $wftop.b_station_down -text [mc "Down"] -style Toolbutton -command [list station_itemMove $wfstation.tv_station 1] -compound top -image $::icon_m(channel-next)
		ttk::separator $wftop.sr_3 -orient vertical
		ttk::button $wftop.b_station_preview -text [mc "Preview"] -style Toolbutton -command [list station_editPreview $wfstation.tv_station] -compound top -image $::icon_m(starttv)
		ttk::treeview $wfstation.tv_station -yscrollcommand [list $wfstation.sb_station set] -columns {station frequency input external externalfreq} -show headings
		ttk::scrollbar $wfstation.sb_station -orient vertical -command [list $wfstation.tv_station yview]
		ttk::button $wfbottom.b_save -text [mc "Apply"] -command [list station_editSave $wfstation.tv_station] -compound left -image $::icon_s(dialog-ok-apply)
		ttk::button $wfbottom.b_exit -text [mc "Cancel"] -command [list station_editExit cancel] -compound left -image $::icon_s(dialog-cancel)
		
		grid $wftop -in $w -row 0 -column 0 -sticky ew
		grid $wfstation -in $w -row 1 -column 0 -sticky nesw
		grid $wfbottom -in $w -row 2 -column 0 -sticky ew -padx 3 -pady 3
		
		grid anchor $wfbottom e
		
		grid $wftop.b_station_search -in $wftop -row 0 -column 0 -pady 4 -padx 3
		grid $wftop.sr_1 -in $wftop -row 0 -column 1 -sticky ns
		grid $wftop.b_station_add -in $wftop -row 0 -column 2 -pady 2 -padx 3
		grid $wftop.b_station_delete -in $wftop -row 0 -column 3 -pady 2 -padx "0 3"
		grid $wftop.b_station_activate -in $wftop -row 0 -column 5 -pady 2 -padx "0 3" -sticky ew
		grid $wftop.b_station_edit -in $wftop -row 0 -column 4 -pady 2 -padx "0 3"
		grid $wftop.sr_2 -in $wftop -row 0 -column 6 -sticky ns
		grid $wftop.b_station_up -in $wftop -row 0 -column 7 -pady 2 -padx 3
		grid $wftop.b_station_down -in $wftop -row 0 -column 8 -pady 2 -padx "0 3"
		grid $wftop.sr_3 -in $wftop -row 0 -column 9 -sticky ns
		grid $wftop.b_station_preview -in $wftop -row 0 -column 10 -pady 2 -padx 3
		
		
		grid $wfstation.tv_station -in $wfstation -row 0 -column 0 -sticky nesw
		grid $wfstation.sb_station -in $wfstation -row 0 -column 1 -sticky ns
		
		grid $wfbottom.b_save -in $wfbottom -row 0 -column 0 -pady 7
		
		grid $wfbottom.b_exit -in $wfbottom -row 0 -column 1 -padx 3
		
		grid columnconfigure .station 0 -weight 1
		grid columnconfigure $wftop 5 -minsize [expr [font measure TkDefaultFont [mc "Unlock"]] + 12]
		grid columnconfigure $wfstation 0 -weight 1
		grid rowconfigure .station 1 -weight 1
		grid rowconfigure $wfstation 0 -weight 1
		
		autoscroll $wfstation.sb_station
		
		set font [ttk::style lookup [$wfstation.tv_station cget -style] -font]
		if {[string trim $font] == {}} {
			set font TkDefaultFont
			puts $::main(debug_msg) "\033\[0;1;33mDebug: station_editUi \033\[0;1;31m::font:: \033\[0m"
		}
		$wfstation.tv_station heading station -text [mc "Station"]
		$wfstation.tv_station heading frequency -text [mc "Frequency"]
		$wfstation.tv_station heading input -text [mc "Video input"]
		$wfstation.tv_station heading external -text [mc "External Tuner"]
		$wfstation.tv_station heading externalfreq -text [mc "Int Frequency"]
		$wfstation.tv_station column station -width [expr [font measure $font [mc "Station"]] + 150]
		$wfstation.tv_station column frequency -width [expr [font measure $font [mc "Frequency"]] + 20] -stretch 0 -anchor center
		$wfstation.tv_station column input -width [expr [font measure $font [mc "Video input"]] + 20] -stretch 0 -anchor center
		$wfstation.tv_station column external -width [expr [font measure $font [mc "External Tuner"]] + 200]
		$wfstation.tv_station column externalfreq -width [expr [font measure $font [mc "Int Frequency"]] + 20] -stretch 0 -anchor center
		$wfstation.tv_station tag configure disabled -foreground red
		set seeElem 0
		if {[file exists "$::option(home)/config/stations_$::option(frequency_table).conf"]} {
			set file "$::option(home)/config/stations_$::option(frequency_table).conf"
			set open_channels_file [open $file r]
			set i 1
			while {[gets $open_channels_file line]!=-1} {
				if {[string trim $line] == {} } continue
				if {[string match #* $line]} {
					set mapped [string map {"#" {}} $line]
					if {[llength $mapped] < 5} {
						if {[llength $mapped] == 2} {
							lassign $mapped kanal channel
							$wfstation.tv_station insert {} end -values [list "$kanal" [string trim $channel] $::option(video_input) 0 0] -tags disabled
						}
						if {[llength $mapped] == 3} {
							lassign $mapped kanal channel input
							$wfstation.tv_station insert {} end -values [list "$kanal" [string trim $channel] $input 0 0] -tags disabled
						}
						if {[llength $mapped] == 4} {
							lassign $mapped kanal channel input external
							$wfstation.tv_station insert {} end -values [list "$kanal" [string trim $channel] $input $external 0] -tags disabled
						}
					} else {
						lassign $mapped kanal channel input external externalfreq
						$wfstation.tv_station insert {} end -values [list "$kanal" [string trim $channel] $input $external $externalfreq] -tags disabled
					}
				} else {
					if {[llength $line] < 5} {
						if {[llength $line] == 2} {
							lassign $line kanal channel
							$wfstation.tv_station insert {} end -values [list "$kanal" [string trim $channel] $::option(video_input) 0 0]
						}
						if {[llength $line] == 3} {
							lassign $line kanal channel input
							$wfstation.tv_station insert {} end -values [list "$kanal" [string trim $channel] $input 0 0]
						}
						if {[llength $line] == 4} {
							lassign $line kanal channel input external
							$wfstation.tv_station insert {} end -values [list "$kanal" [string trim $channel] $input $external 0]
						}
					} else {
						lassign $line kanal channel input external externalfreq
						$wfstation.tv_station insert {} end -values [list "$kanal" [string trim $channel] $input $external $externalfreq]
					}
				}
				incr i
			}
			close $open_channels_file
			if {[info exists ::station(last)]} {
				foreach elem [$wfstation.tv_station children {}] {
					if {"[lindex [$wfstation.tv_station item $elem -values] 0]" == "[lindex $::station(last) 0]"} {
						$wfstation.tv_station selection set $elem
						set seeElem $elem
						break
					}
				}
			}
		}
		
		if {[string trim [auto_execok "ivtv-tune"]] == {} || [string trim [auto_execok "v4l2-ctl"]] == {}} {
			$wftop.b_station_search state disabled
			$wftop.b_station_preview state disabled
			log_writeOutTv 2 "Could not detect ivtv-tune or/and v4l2-ctl."
			log_writeOutTv 2 "Check the user guide about system requirements."
		}
		if {[string trim [auto_execok mplayer]] == {}} {
			$wftop.b_station_preview state disabled
			log_writeOutTv 2 "Could not detect MPlayer."
			log_writeOutTv 2 "Check the user guide about system requirements."
		}
		
		bind $wfstation.tv_station <B1-Motion> break
		bind $wfstation.tv_station <Motion> break
		bind $wfstation.tv_station <Double-ButtonPress-1> [list station_itemAddEdit $wfstation.tv_station 2]
		bind $wfstation.tv_station <ButtonPress-3> [list station_editUiMenu $wfstation.tv_station %X %Y]
		bind $wfstation.tv_station <Key-Delete> [list station_itemDelete $wfstation.tv_station]
		bind $wfstation.tv_station <<TreeviewSelect>> {station_editZap .station.wfstation.tv_station; station_itemDeactivate .station.wfstation.tv_station .station.top_buttons.b_station_activate 0}
		bind $w <Control-Key-x> [list station_editExit cancel]
		bind $w <<help>> [list info_helpHelp]
		
		wm title $w [mc "Station Editor"]
		wm protocol $w WM_DELETE_WINDOW [list station_editExit cancel]
		wm iconphoto $w $::icon_b(seditor)
		wm transient $w .
		if {$::option(tooltips) == 1} {
			if {$::option(tooltips_editor) == 1} {
				settooltip $wftop.b_station_search [mc "Perform an automatic station search"]
				settooltip $wftop.b_station_add [mc "Add a new television station"]
				settooltip $wftop.b_station_delete [mc "Delete selected television station"]
				settooltip $wftop.b_station_activate [mc "Lock or unlock selected station(s).
Locked stations will be displayed in red."]
				settooltip $wftop.b_station_edit [mc "Edit selected station"]
				settooltip $wftop.b_station_up [mc "Move selected item up"]
				settooltip $wftop.b_station_down [mc "Move selected item down"]
				settooltip $wftop.b_station_preview [mc "Preview for selected tv station"]
				settooltip $wfbottom.b_save [mc "Save station list and exit editor"]
				settooltip $wfbottom.b_exit [mc "Exit editor without any changes"]
			}
		}
		set status_vid_Playback [vid_callbackMplayerRemote alive]
		if {$status_vid_Playback != 1} {
			.station.top_buttons.b_station_preview state pressed
		}
		tkwait visibility $w
		if {$seeElem != 0} {
			after 100 [list $wfstation.tv_station see $seeElem]
		}
		vid_wmCursor 0
		grab $w
		wm minsize .station [winfo width .station] [winfo height .station]
	}
}
