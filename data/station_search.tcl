#       station_search.tcl
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

proc station_searchUi {tree} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_searchUi \033\[0m \{$tree\}"
	if {[winfo exists .station.top_searchUi]} return
	log_writeOutTv 0 "Building station search gui."
	set wtop [toplevel .station.top_searchUi]
	
	place [ttk::frame $wtop.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
	
	set mf [ttk::frame $wtop.f_main]
	set bf [ttk::frame $wtop.f_button -style TLabelframe]
	
	ttk::labelframe $mf.lf_search \
	-text [mc "Station search options"]
	
	ttk::checkbutton $mf.cb_lf_search_append \
	-text [mc "Append stations to existing list"] \
	-variable search(append)
	
	ttk::checkbutton $mf.cb_lf_search_full \
	-text [mc "Perform a full frequency sweep"] \
	-variable search(full) \
	-command [list station_searchFull $mf]
	
	ttk::menubutton $mf.mb_lf_search_full_dist \
	-menu $mf.mbFull_dist \
	-textvariable search(mbFull_dist)
	menu $mf.mbFull_dist \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))
	
	ttk::menubutton $mf.mb_lf_search_full_time \
	-menu $mf.mbFull_time \
	-textvariable search(mbFull_time)
	menu $mf.mbFull_time \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))
	
	ttk::button $bf.b_ok \
	-text [mc "Start"] \
	-compound left \
	-image $::icon_s(dialog-ok-apply) \
	-command "grab release $wtop; destroy $wtop; grab .station; wm protocol .station WM_DELETE_WINDOW station_editExit; wm resizable .station 1 1; station_searchRequires $tree"
	
	ttk::button $bf.b_cancel \
	-text [mc "Cancel"] \
	-compound left \
	-image $::icon_s(dialog-cancel) \
	-command "unset -nocomplain ::search(mbVinput) ::search(mbVinput_nr); grab release $wtop; destroy $wtop; grab .station; wm protocol .station WM_DELETE_WINDOW station_editExit; wm resizable .station 1 1"
	
	grid columnconfigure $wtop 0 -weight 1
	grid columnconfigure $mf 0 -weight 1
	grid columnconfigure $bf 0 -weight 1 -minsize 150
	grid rowconfigure $wtop 0 -weight 1
	
	grid $mf -in $wtop -row 0 -column 0 \
	-sticky nesw
	grid $bf -in $wtop -row 1 -column 0 \
	-sticky ew \
	-padx 3 \
	-pady 3
	
	grid anchor $bf e
	
	grid $mf.lf_search -in $mf -row 0 -column 0 \
	-sticky ew \
	-padx 3 \
	-pady "5 0"
	grid $mf.cb_lf_search_append -in $mf.lf_search -row 0 -column 0 \
	-columnspan 2 \
	-sticky w \
	-padx 3 \
	-pady "0 3"
	grid $mf.cb_lf_search_full -in $mf.lf_search -row 1 -column 0 \
	-columnspan 2 \
	-sticky w \
	-padx 3 \
	-pady "0 3"
	grid $mf.mb_lf_search_full_dist -in $mf.lf_search -row 2 -column 0 \
	-sticky ew \
	-padx 3 \
	-pady "0 3"
	grid $mf.mb_lf_search_full_time -in $mf.lf_search -row 2 -column 1 \
	-sticky ew \
	-padx "0 3" \
	-pady "0 3"
	
	grid $bf.b_ok -in $bf -row 0 -column 0 \
	-sticky e \
	-pady 7
	grid $bf.b_cancel -in $bf -row 0 -column 1 \
	-padx 3 \
	-pady 7
	
	wm resizable $wtop 0 0
	wm title $wtop [mc "Station search options"]
	wm protocol $wtop WM_DELETE_WINDOW "unset -nocomplain ::search(mbVinput) ::search(mbVinput_nr); grab release $wtop; destroy $wtop; grab .station; wm protocol .station WM_DELETE_WINDOW station_editExit; wm resizable .station 1 1"
	wm protocol .station WM_DELETE_WINDOW " "
	wm resizable .station 0 0
	wm iconphoto $wtop $::icon_b(seditor)
	wm transient $wtop .station
	
	proc station_searchFull {mf} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: station_searchFull \033\[0m \{$mf\}"
		if {$::search(full) == 1} {
			$mf.mb_lf_search_full_dist state !disabled
			$mf.mb_lf_search_full_time state !disabled
		} else {
			$mf.mb_lf_search_full_dist state disabled
			$mf.mb_lf_search_full_time state disabled
		}
	}
	
	catch {exec v4l2-ctl --device=$::option(video_device) -n} read_vinputs
	set status_vid_inputs [catch {agrep -m "$read_vinputs" name} resultat_vid_inputs]
	if {$status_vid_inputs == 0} {
		set i 0
		foreach vi [split $resultat_vid_inputs \n] {
			set vinput($i) "[string trimleft [string range $vi [string first : $vi] end] {: }]"
			incr i
		}
	} else {
		log_writeOutTv 2 "Can't find any video inputs, please check the preferences (analog section)."
		foreach window [winfo children .station.top_searchUi] {
			destroy $window
		}
		destroy .station.top_searchUi
		return
	}
	set dists {0.250 0.500 1.0}
	foreach fdists [split $dists] {
		$mf.mbFull_dist add radiobutton \
		-variable search(mbFull_dist) \
		-label $fdists
	}
	set times {100 200 500 800 1000}
	foreach ftimes [split $times] {
		$mf.mbFull_time add radiobutton \
		-variable search(mbFull_time) \
		-label $ftimes
	}
	if {$::option(tooltips) == 1} {
		if {$::option(tooltips_editor) == 1} {
			settooltip $mf.cb_lf_search_append [mc "Append stations to existing list.
Otherwise the existing list will be deleted."]
			settooltip $mf.cb_lf_search_full [mc "Perform a full frequency sweep.
Otherwise TV-Viewer checks all channels for the chosen
frequency table.
Note: A full frequency sweep may find many duplicates."]
			settooltip $mf.mb_lf_search_full_dist [mc "Choose the frequency increase factor for full frequency sweep.
Note: The lower this factor the more duplicates will be found and
the search takes more time."]
			settooltip $mf.mb_lf_search_full_time [mc "Time in milliseconds to wait for the driver to respond.
The lower this value the faster the full frequency sweep will be.
Note: If this value is too small the driver will possibly not have
enough time to report if there is a signal on the current frequency.
As a result not all stations will be found."]
			settooltip $bf.b_ok [mc "Start station search."]
		} else {
			settooltip $mf.cb_lf_search_append {}
			settooltip $mf.cb_lf_search_full {}
			settooltip $mf.mb_lf_search_full_dist {}
			settooltip $mf.mb_lf_search_full_time {}
			settooltip $bf.b_ok {}
		}
	} else {
		settooltip $mf.cb_lf_search_append {}
		settooltip $mf.cb_lf_search_full {}
		settooltip $mf.mb_lf_search_full_dist {}
		settooltip $mf.mb_lf_search_full_time {}
		settooltip $bf.b_ok {}
	}
	
	set ::search(append) 1
	set ::search(full) 0
	set ::search(mbVinput) $vinput(0)
	set ::search(mbVinput_nr) 0
	set ::search(mbFull_dist) 1.0
	set ::search(mbFull_time) 500
	
	station_searchFull $mf
	
	grab release .station
	tkwait visibility $wtop
	grab $wtop
}

proc station_searchVideoNumber {vinput_nr} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_searchRequires \033\[0m \{$vinput_nr\}"
	set ::search(mbVinput_nr) $vinput_nr
}

proc station_searchRequires {tree} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_searchRequires \033\[0m \{$tree\}"
	set status_tv_playback [tv_callbackMplayerRemote alive]
	if {$status_tv_playback != 1} {
		tv_playbackStop 0 pic
	}
	log_writeOutTv 0 "Launching station search."
	set wtop [toplevel .station.top_search]
	
	place [ttk::frame $wtop.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
	
	set mf [ttk::frame $wtop.f_main]
	
	$mf configure -cursor watch
	
	ttk::label $mf.l_search_msg \
	-text [mc "Station search in progress.
Please wait..."] \
	-compound left \
	-image $::icon_m(dialog-information)
	
	ttk::progressbar $mf.pgb_search \
	-orient horizontal \
	-mode determinate \
	-variable choice(pgb_search)
	
	ttk::label $mf.l_search_status
	
	ttk::button $mf.b_search_abort \
	-text [mc "Cancel"] \
	-compound left \
	-image $::icon_s(dialog-cancel) \
	-command "station_search 0 cancel 0 0 0 0; grab release $wtop; destroy $wtop; grab .station; wm protocol .station WM_DELETE_WINDOW station_editExit; wm resizable .station 1 1"
	
	grid columnconfigure $wtop 0 -minsize 280
	grid columnconfigure $mf 0 -weight 1
	
	grid $mf -in $wtop -row 0 -column 0 \
	-sticky nesw
	
	grid $mf.l_search_msg -in $mf -row 0 -column 0 \
	-sticky w \
	-padx 5 \
	-pady 5
	grid $mf.pgb_search -in $mf -row 1 -column 0 \
	-sticky ew \
	-padx 10 \
	-pady "10 5"
	grid $mf.l_search_status -in $mf -row 2 -column 0 \
	-sticky ew \
	-padx 10 \
	-pady "0 10"
	grid $mf.b_search_abort -in $mf -row 3 -column 0 \
	-sticky e \
	-padx 10 \
	-pady "5 3"
	
	wm resizable $wtop 0 0
	wm title $wtop [mc "Station search"]
	wm protocol $wtop WM_DELETE_WINDOW " "
	wm protocol .station WM_DELETE_WINDOW " "
	wm resizable .station 0 0
	wm iconphoto $wtop $::icon_b(seditor)
	wm transient $wtop .station
	
	proc station_searchLoopInput {counter tree input} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: station_searchLoopInput \033\[0m \{$counter\} \{$tree\} \{$input\}"
		catch {exec v4l2-ctl --device=$::option(video_device) --get-input} read_vinput
		set status_get_input [catch {agrep -m "$read_vinput" video} resultat_get_input]
		if {$status_get_input == 0} {
			if {[lindex $resultat_get_input 3] == $input} {
				if {$::search(full) == 0} {
					set status_get_channels [catch {exec ivtv-tune --device=$::option(video_device) --freqtable=$::option(frequency_table) -l} resultat_get_channels]
					set i 1
					foreach line [split $resultat_get_channels \n] {
						if {[string match Channels* $line]} continue
						foreach {channel frequency} [split $line] {
							set ::searchchannel($i) $channel
							set ::searchfreq($i) $frequency
						}
						set max_channels $i
						incr i
					}
					foreach pair [split $resultat_get_channels \n] {
						if {[string match Channels* $pair]} continue
						dict set ::freq_chan_pairs {*}[scan $pair {%s %s}]
					}
					set pgb_incr [expr 100.0 / $max_channels]
					catch {exec ivtv-tune --device=$::option(video_device) --freqtable=$::option(frequency_table) --channel=$::searchchannel(1)}
					after 700 [list station_search $max_channels $counter 0 0 $pgb_incr $tree]
					log_writeOutTv 0 "Now entering station search progress loop."
					return
				} else {
					catch {exec v4l2-ctl --device=$::option(video_device) --all} resultat_get_freqrange
					foreach line [split $resultat_get_freqrange "\n"] {
						if {[string match {Frequency range*} [string trim $line]] == 1} {
							set search_range_min [expr int([lindex [string trim $line] 3])]
							set search_range_max [expr int([lindex [string trim $line] 6])]
							set pgb_incr [expr (100.0 / ($search_range_max - $search_range_min))]
							if {[string is digit $search_range_min] == 0 || [string is digit $search_range_max] == 0} {
								log_writeOutTv 2 "Fatal, could not read frequency range."
								log_writeOutTv 2 "$line"
								return
							}
							set search_range_min "$search_range_min.250"
							catch {exec v4l2-ctl --device=$::option(video_device)  --set-freq=$search_range_min}
							after 700 [list station_search 0 0 $search_range_min $search_range_max $pgb_incr $tree]
							log_writeOutTv 0 "Now entering station search progress loop."
							return
						}
					}
				}
			} else {
				catch {exec v4l2-ctl --device=$::option(video_device) --set-input=$input}
				after 1000 [list station_searchLoopInput $counter $tree $::search(mbVinput_nr)]
			}
		}
	}
	
	set ::choice(pgb_search) 0
	
	if {$::search(append) == 0} {
		$tree delete [$tree children {}]
	}
	
	set counter 1
	grab release .station
	tkwait visibility $wtop
	grab $wtop
	after 500 {catch {exec v4l2-ctl --device=$::option(video_device) --set-input=$::search(mbVinput_nr)}}
	after 1000 [list station_searchLoopInput $counter $tree $::search(mbVinput_nr)]
}

proc station_search {max_channels counter freq search_range_max pgb_incr tree} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_search \033\[0m \{$max_channels\} \{$counter\} \{$freq\} \{$search_range_max\} \{$pgb_incr\} \{$tree\}"
	if {"$counter" == "cancel"} {
		if {[info exists ::station(search_id)]} {
			catch {after cancel $::station(search_id)}
			unset -nocomplain ::station(search_id)
		}
		return
	}
	if {$::search(full) == 0} {
		if {$counter <= $max_channels} {
			set ::choice(pgb_search) [expr $::choice(pgb_search) + $pgb_incr]
			.station.top_search.f_main.l_search_status configure -text [mc "Channel: %" $::searchchannel($counter)]
			catch {exec v4l2-ctl --device=$::option(video_device) -T} read_signal
			set status_grepvidstd [catch {agrep -m "$read_signal" signal} read_signal_strength]
			regexp {^(\d+).*$} [string trim [lindex $read_signal_strength end]] -> regexp_signal_strength
			if {$regexp_signal_strength >= 25 } {
				set status_dict [catch {dict get $::freq_chan_pairs $::searchchannel($counter)} resultat_dict]
				if { $status_dict == 0 } {
					set trimmed_resultat_dict [string trim $resultat_dict]
					$tree insert {} end -values [list Station($::searchchannel($counter)) $trimmed_resultat_dict $::search(mbVinput_nr)]
					$tree see [lindex [$tree children {}] end]
					log_writeOutTv 0 "Signal detected on $trimmed_resultat_dict MHz."
				} else {
					log_writeOutTv 2 "Fatal, could not find Frequency for $::searchchannel($counter)."
				}
			}
			incr counter
			catch {exec ivtv-tune --device=$::option(video_device) --freqtable=$::option(frequency_table) --channel=$::searchchannel($counter)}
			set ::station(search_id) [after 700 [list station_search $max_channels $counter $freq $search_range_max $pgb_incr $tree]]
		} else {
			array unset ::searchchannel
			array unset ::searchfreq
			unset -nocomplain ::search(mbVinput_nr)
			unset -nocomplain ::freq_chan_pairs
			set ::choice(pgb_search) 100
			.station.top_search.f_main.l_search_msg configure -text [mc "Station search finished!"]
			.station.top_search.f_main.b_search_abort state disabled
			after 3000 {grab release .station.top_search
			destroy .station.top_search
			grab .station
			wm protocol .station WM_DELETE_WINDOW station_editExit
			wm resizable .station 1 1}
		}
	} else {
		if {$freq <= $search_range_max} {
			set ::choice(pgb_search) [expr $::choice(pgb_search) + $pgb_incr]
			.station.top_search.f_main.l_search_status configure -text [mc "Frequency: %" $freq]
			catch {exec v4l2-ctl --device=$::option(video_device) -T} read_signal
			set status_grepvidstd [catch {agrep -m "$read_signal" signal} read_signal_strength]
			regexp {^(\d+).*$} [string trim [lindex $read_signal_strength end]] -> regexp_signal_strength
			if {$regexp_signal_strength >= 25 } {
				set splitf [split $freq "."]
				if {[string length [lindex $splitf 1]] == 1} {
					set freq "[lindex $splitf 0].[lindex $splitf 1]00"
				}
				if {[string length [lindex $splitf 1]] == 2} {
					set freq "[lindex $splitf 0].[lindex $splitf 1]0"
				}
				$tree insert {} end -values [list Station($freq) $freq $::search(mbVinput_nr)]
				$tree see [lindex [$tree children {}] end]
				log_writeOutTv 0 "Signal detected on $freq MHz."
			}
			set freq [expr $freq + $::search(mbFull_dist)]
			catch {exec v4l2-ctl --device=$::option(video_device) --set-freq=$freq}
			set ::station(search_id) [after $::search(mbFull_time) [list station_search $max_channels $counter $freq $search_range_max $pgb_incr $tree]]
		} else {
			unset -nocomplain ::search(mbVinput_nr)
			set ::choice(pgb_search) 100
			.station.top_search.f_main.l_search_msg configure -text [mc "Station search finished!"]
			.station.top_search.f_main.b_search_abort state disabled
			after 3000 {grab release .station.top_search
			destroy .station.top_search
			grab .station
			wm protocol .station WM_DELETE_WINDOW station_editExit
			wm resizable .station 1 1}
		}
	}
}
