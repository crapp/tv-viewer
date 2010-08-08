#       station_after_msg.tcl
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

proc station_after_msg {var0 var1} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: station_after_msg \033\[0m \{$var0\} \{$var1\}"
	if {$::option(osd_enabled) == 1} {
		if {[wm attributes . -fullscreen] == 0 && [lindex $::option(osd_station_w) 0] == 1} {
			after 0 [list vid_osd osd_station_w 2000 "$::kanalid($var0)"]
		}
		if {[wm attributes . -fullscreen] == 1 && [lindex $::option(osd_station_f) 0] == 1} {
			after 0 [list vid_osd osd_station_f 2000 "$::kanalid($var0)"]
		}
}
	.ftoolb_Disp.lDispText configure -text [mc "Now playing %" $::kanalid($var0)]
	#~ wm title . "TV-Viewer [lindex $::option(release_version) 0] - "
	if {[winfo exists .tray]} {
		set status_tv [vid_callbackMplayerRemote alive]
		if {$status_tv != 1} {
			settooltip .tray [mc "TV-Viewer playing - %" [lindex $::station(last) 0]]
		}
	}
	catch {exec v4l2-ctl --device=$::option(video_device) -T} read_signal
	set status_grepvidstd [catch {agrep -m "$read_signal" signal} read_signal_strength]
	if {$status_grepvidstd == 0} {
		regexp {^(\d+).*$} [string trim [lindex $read_signal_strength end]] -> regexp_signal_strength
		if {[string is digit $regexp_signal_strength]} {
			if {$regexp_signal_strength < 25 } {
				log_writeOutTv 1 "Tried to tune station $::kanalid($var0)"
				log_writeOutTv 1 "No signal detected on $::kanalcall($var0) Mhz (Input $::kanalinput($var0))."
			} else {
				log_writeOutTv 0 "Tuning station $::kanalid($var0) on [lrange $var1 end-1 end] (Input $::kanalinput($var0))."
			}
		} else {
			log_writeOutTv 2 "Tried to tune $::kanalid($var0) (Input $::kanalinput($var0))"
			log_writeOutTv 2 "Error message: $read_signal_strength"
		}
	} else {
		log_writeOutTv 2 "Tried to tune $::kanalid($var0) (Input $::kanalinput($var0))"
		log_writeOutTv 2 "Error message: $read_signal_strength"
	}
}
