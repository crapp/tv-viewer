#!/usr/bin/env wish

#       recorder.tcl
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

#make sure main windows is invisible, we use a special toplevel
wm geometry . 1x1+3000+3000
wm overrideredirect . 1
wm transient .

set option(root) "[file dirname [file dirname [file dirname [file normalize [file join [info script] bogus]]]]]"
set option(home) "$::env(HOME)/.tv-viewer"
set option(appname) tv-viewer_notifyd

source $option(root)/data/agrep.tcl
set status_lock [catch {exec ln -s "[pid]" "$::option(home)/tmp/notifyd_lockfile.tmp"} resultat_lock]
if { $status_lock != 0 } {
	set linkread [file readlink "$::option(home)/tmp/notifyd_lockfile.tmp"]
	catch {exec ps -eo "%p"} read_ps
	set status_greppid [catch {agrep -w "$read_ps" $linkread} resultat_greppid]
	if { $status_greppid != 0 } {
		catch {file delete "$::option(home)/tmp/notifyd_lockfile.tmp"}
		catch {exec ln -s "[pid]" "$::option(home)/tmp/notifyd_lockfile.tmp"}
	} else {
		catch {exec ps -p $linkread -o args=} readarg
		set status_grepargLink [catch {agrep -m "$readarg" "tv-viewer_notifyd"} resultat_greparg]
		set status_grepargDirect [catch {agrep -m "$readarg" "notifyd.tcl"} resultat_greparg]
		if {$status_grepargLink != 0 && $status_grepargDirect != 0} {
			catch {file delete "$::option(home)/tmp/notifyd_lockfile.tmp"}
			catch {exec ln -s "[pid]" "$::option(home)/tmp/notifyd_lockfile.tmp"}
		} else {
			puts "
An instance of the TV-Viewer notification daemon is already running."
			exit 1
		}
	}
}
unset -nocomplain status_lock resultat_lock linkread status_greppid resultat_greppid

package require msgcat
namespace import msgcat::mc

source $option(root)/data/process_config.tcl
source $option(root)/themes/plastik/plastik.tcl
source $option(root)/themes/keramik/keramik.tcl
source $option(root)/data/monitor.tcl
#~ source $option(root)/data/error_interp.tcl
source $option(root)/data/command_socket.tcl

process_configRead
ttk::style theme use $::option(use_theme)
if {"$::option(use_theme)" == "clam"} {
	ttk::style configure TLabelframe -labeloutside false -labelmargins {10 0 0 0}
}
#Setting up language support.
if {$::option(language_value) != 0} {
	msgcat::mclocale $::option(language_value)
} else {
	msgcat::mclocale $::env(LANG)
}
if {[msgcat::mcload $::option(root)/msgs] != 1} {
	msgcat::mclocale en
	msgcat::mcload $::option(root)/msgs
}
command_socket

set icon(tv-viewer) [image create photo -file "$option(root)/icons/extras/systray_icon48.gif"]

set notifyId 0

proc notifydUi {ic pos timeout actId actTxt header msg args} {
	#ic = image id -- pos = position of notification window -- timeout = timeout for notification window -- actId = action id -- actTxt = action text -- header = news header -- msg = news body -- args = remaining arguments
	set actTxt [mc "$actTxt"]
	set header [mc "$header"]
	if {[llength $args] > 0} {
		set msg [mc "$msg" {*}$args]
	} else {
		set msg [mc "$msg"]
	}
	
	if {[winfo exists .topNotify_[expr $::notifyId - 2]]} {
		set id [expr $::notifyId - 2]
		after cancel ::afterId($id)
		destroy .topNotify_$id
	}
	set top [toplevel .topNotify_$::notifyId -bd 1 -relief raised]
	place [ttk::frame $top.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
	set fMain [ttk::frame $top.f_notifyMain]
	set fBut [ttk::frame $top.f_notifyBut]
	ttk::label $fMain.l_notifyIc
	ttk::label $fMain.l_notifyHeader -text "$header" -font "TkTextFont [font actual TkTextFont -displayof $top -size] bold"
	ttk::label $fMain.l_notifyMsg -text "$msg"
	ttk::button $fBut.b_notifyAction -text Action
	ttk::button $fBut.b_notifyOk -text Ok -command "after cancel ::afterId($::notifyId) ; destroy .topNotify_$::notifyId"
	
	grid $fMain -in $top -row 0 -column 0 -sticky nesw
	grid $fBut -in $top -row 1 -column 0 -sticky ew -padx 3 -pady "0 3"
	
	grid $fMain.l_notifyIc -in $fMain -row 0 -column 0 -sticky nw -rowspan 2 -padx 8 -pady 8
	grid $fMain.l_notifyHeader -in $fMain -row 0 -column 1 -sticky w -padx "0 8" -pady 8
	grid $fMain.l_notifyMsg -in $fMain -row 1 -column 1 -sticky w -padx "0 8" -pady "0 8"
	
	
	if {$actId != 0} {
		grid $fBut.b_notifyAction -in $fBut -row 0 -column 0 -padx 2
		grid $fBut.b_notifyOk -in $fBut -row 0 -column 1 -padx 2
	} else {
		grid $fBut.b_notifyOk -in $fBut -row 0 -column 0 -padx 2
	}
	
	grid columnconfigure $top 0 -minsize 350
	
	grid anchor $fBut e
	
	wm resizable $top 0 0
	wm transient $top .
	wm overrideredirect $top 1
	wm withdraw $top
	
	#1 - topright
	array set location {
		1 "wm geometry .topNotify_$::notifyId [winfo reqwidth .topNotify_$::notifyId]\x[winfo reqheight .topNotify_$::notifyId]\+[expr [winfo screenwidth .topNotify_$::notifyId] - ([winfo reqwidth .topNotify_$::notifyId] + 15)]\+50"
		2 "wm geometry .topNotify_$::notifyId [winfo reqwidth .topNotify_$::notifyId]\x[winfo reqheight .topNotify_$::notifyId]\+[expr [winfo screenwidth .topNotify_$::notifyId] - ([winfo reqwidth .topNotify_$::notifyId] + 15)]\+[expr [winfo screenheight .topNotify_$::notifyId] - ([winfo reqheight .topNotify_$::notifyId] - 15) - 50]"
		3 "wm geometry .topNotify_$::notifyId [winfo reqwidth .topNotify_$::notifyId]\x[winfo reqheight .topNotify_$::notifyId]\+15\+[expr [winfo screenheight .topNotify_$::notifyId] - ([winfo reqheight .topNotify_$::notifyId] - 15) - 50]"
		4 "wm geometry .topNotify_$::notifyId [winfo reqwidth .topNotify_$::notifyId]\x[winfo reqheight .topNotify_$::notifyId]\+15\+50"
	}
	#1 - topright
	array set movelocation {
		1 "wm geometry .topNotify_[expr $::notifyId - 1] [winfo reqwidth .topNotify_[expr $::notifyId - 1]]\x[winfo reqheight .topNotify_[expr $::notifyId - 1]]\+[expr [winfo screenwidth .topNotify_[expr $::notifyId - 1]] - ([winfo reqwidth .topNotify_[expr $::notifyId - 1]] + 15)]\+[expr [lindex [split [winfo geometry .topNotify_[expr $::notifyId - 1]] +] end] + [winfo reqheight .topNotify_[expr $::notifyId - 1]] + 2]"
		2 "wm geometry .topNotify_[expr $::notifyId - 1] [winfo reqwidth .topNotify_[expr $::notifyId - 1]]\x[winfo reqheight .topNotify_[expr $::notifyId - 1]]\+[expr [winfo screenwidth .topNotify_[expr $::notifyId - 1]] - ([winfo reqwidth .topNotify_[expr $::notifyId - 1]] + 15)]\+[expr [lindex [split [winfo geometry .topNotify_[expr $::notifyId - 1]] +] end] - [winfo reqheight .topNotify_[expr $::notifyId - 1]] - 2]"
		3 "wm geometry .topNotify_[expr $::notifyId - 1] [winfo reqwidth .topNotify_[expr $::notifyId - 1]]\x[winfo reqheight .topNotify_[expr $::notifyId - 1]]\+15\+[expr [lindex [split [winfo geometry .topNotify_[expr $::notifyId - 1]] +] end] - [winfo reqheight .topNotify_[expr $::notifyId - 1]] - 2]"
		4 "wm geometry .topNotify_[expr $::notifyId - 1] [winfo reqwidth .topNotify_[expr $::notifyId - 1]]\x[winfo reqheight .topNotify_[expr $::notifyId - 1]]\+15\+[expr [lindex [split [winfo geometry .topNotify_[expr $::notifyId - 1]] +] end] + [winfo reqheight .topNotify_[expr $::notifyId - 1]] + 2]"
	}
	
	array set image {
		1 tv-viewer
	}
	
	#~ array set actionTxt {
		#~ 1 "Start TV-Viewer"
		#~ 2 "Start Newsreader"
	#~ }
	
	$fMain.l_notifyIc configure -image $::icon($image($ic))
	if {$actId != 0} {
		$fBut.b_notifyAction configure -text $actTxt
		$fBut.b_notifyAction configure -command [list notifydAction $fBut.b_notifyAction $actId]
	}
	
	update idletasks
	{*}[subst $location($pos)]
	if {[winfo exists .topNotify_[expr $::notifyId - 1]]} {
		{*}[subst $movelocation($pos)]
	}
	wm deiconify $top
	wm attributes $top -topmost 1
	set ::afterId($::notifyId) [after [expr $timeout * 1000] [list destroy .topNotify_$::notifyId]]
}

proc notifydAction {btn actId} {
	array set actionCmd {
		1 {exec "$::option(root)/data/tv-viewer_main.tcl" &}
		2 {command_WritePipe 0 "tv-viewer_main main_newsreaderUiPre"}
	}
	if {$actId == 1} {
		{*}[subst $actionCmd($actId)]
	} else {
		{*}$actionCmd($actId)
	}
	catch {after cancel ::afterId($::notifyId)}
	destroy .topNotify_$::notifyId
	after 5000 {
		set status_main [monitor_partRunning 1]
		set status_scheduler [monitor_partRunning 2]
		set status_recorder [monitor_partRunning 3]
		if {[lindex $status_main 0] == 0 && [lindex $status_scheduler 0] == 0 && [lindex $status_recorder 0] == 0} {
			#make sure we quit when no other part of tv-viewer is running
			notifydExit
		}
	}
}

proc notifydMsgs {} {
	# Do not start this proc. It is just for the translation engine so the strings get into the translation files.
	[mc "Start Newsreader"]
	[mc "News"]
	[mc "There are News about TV-Viewer"]
	[mc "Start TV-Viewer"]
	[mc "Recording started"]
	[mc "Recording of job % started successfully" $foo]
	[mc "Recording finished"]
	[mc "Recording of job % has been finished" $foo]
}

proc notifydId {} {
	set ::notifyId [expr $::notifyId + 1]
}

proc notifydExit {} {
	catch {close $::data(comsocketRead)}
	catch {close $::data(comsocketWrite)}
	catch {file delete "$::option(home)/tmp/notifyd_lockfile.tmp"}
	catch {file delete "$::option(home)/tmp/ComSocketNotify"}
	exit 0
}
