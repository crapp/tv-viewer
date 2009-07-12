#       station_after_msg.tcl
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

proc station_after_msg {var0 var1} {
	if {$::option(osd_enabled) == 1} {
		if {[winfo exists .tv] == 1} {
			if {[wm attributes .tv -fullscreen] == 0 && [lindex $::option(osd_station_w) 0] == 1} {
				after 0 [list tv_osd osd_station_w 2000 "$::kanalid($var0)"]
			}
			if {[wm attributes .tv -fullscreen] == 1 && [lindex $::option(osd_station_f) 0] == 1} {
				after 0 [list tv_osd osd_station_f 2000 "$::kanalid($var0)"]
			}
		}
	}
	if {[winfo exists .tv] == 1} {
		wm title .tv "TV - $::kanalid($var0)"
	}
	if {[winfo exists .tray]} {
		set status_tv [tv_playerMplayerRemote alive]
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
				puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Tried to tune station $::kanalid($var0)
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] No signal detected on $::kanalcall($var0) Mhz (Input $::kanalinput($var0))."
				flush $::logf_tv_open_append
			} else {
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Tuning station $::kanalid($var0) on [lrange $var1 end-1 end] (Input $::kanalinput($var0))."
				flush $::logf_tv_open_append
			}
		} else {
			puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Tried to tune $::kanalid($var0) (Input $::kanalinput($var0))
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Error message: $read_signal_strength"
			flush $::logf_tv_open_append
		}
	} else {
		puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Tried to tune $::kanalid($var0) (Input $::kanalinput($var0))
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Error message: $read_signal_strength"
		flush $::logf_tv_open_append
	}
}
