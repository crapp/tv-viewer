#       diag_frontend.tcl
#       © Copyright 2007-2010 Christian Rapp <saedelaere@arcor.de>
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

proc diag_Ui {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: diag_Ui \033\[0m"
	if {[winfo exists .top_diagnostic] == 0} {
		
		set wtop [toplevel .top_diagnostic]
		
		place [ttk::frame $wtop.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		
		set mf [ttk::frame $wtop.f_main]
		
		set fbottom [ttk::frame $wtop.f_bottom -style TLabelframe]
		
		ttk::label $mf.l_diagnostic_msg \
		-text [mc "Diagnostic Routine is checking your system.
Please wait..."] \
		-compound left \
		-image $::icon_m(dialog-information)
		
		ttk::progressbar $mf.pgb_diagnostic \
		-orient horizontal \
		-mode indeterminate \
		-variable choice(pgb_diagnostic)
		
		ttk::button $fbottom.b_close \
		-command {diag_UiExit} \
		-text [mc "Exit"] \
		-compound left \
		-image $::icon_s(dialog-close)
		
		text $mf.t_diagtext \
		-width 0 \
		-height 0 \
		-bd 0 \
		-relief flat \
		-highlightthickness 0
		
		grid columnconfigure $mf 0 -weight 1 -minsize 350
		
		grid $mf -in $wtop -row 0 -column 0 \
		-sticky nesw
		
		grid $mf.l_diagnostic_msg -in $mf -row 0 -column 0 \
		-padx 5 \
		-pady 5 \
		-sticky w
		grid $mf.pgb_diagnostic -in $mf -row 1 -column 0 \
		-sticky ew \
		-padx 10 \
		-pady 10
		
		wm resizable $wtop 0 0
		wm title $wtop [mc "Diagnostic Routine"]
		wm protocol $wtop WM_DELETE_WINDOW " "
		wm iconphoto $wtop $::icon_e(tv-viewer_icon)
		wm transient $wtop .
		if {$::option(systray_close) == 1} {
			wm protocol . WM_DELETE_WINDOW {  }
		}
		tkwait visibility $wtop
		grab $wtop
		
		$mf.pgb_diagnostic start 10
		
		tv_playbackStop 0 pic
		
		catch {exec "$::where_is/data/diag_runtime.tcl" &} diag_pid
		set ::diag(wait_id) [after 500 [list diag_checkRunning $diag_pid 0]]
	}
}

proc diag_RunFinished {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: diag_RunFinished \033\[0m \{$handler\}"
	if {$handler == 0} {
		diag_checkRunning 0 cancel
	}
	if {[winfo exists .top_diagnostic]} {
		
		grid rowconfigure .top_diagnostic.f_main {2} -weight 1 -minsize 150
		
		grid .top_diagnostic.f_main.t_diagtext -in .top_diagnostic.f_main -row 2 -column 0 \
		-sticky nesw \
		-padx 5 \
		-pady "0 5"
		
		grid .top_diagnostic.f_bottom -in .top_diagnostic -row 1 -column 0 \
		-sticky ew \
		-padx 3 \
		-pady 3
		grid anchor .top_diagnostic.f_bottom e
		
		grid .top_diagnostic.f_bottom.b_close -in .top_diagnostic.f_bottom -row 0 -column 0 \
		-padx 3 \
		-pady 7
		
		set hylink_enter "-foreground #0023FF -underline off"
		set hylink_leave "-foreground #0064FF -underline on"
		.top_diagnostic.f_main.t_diagtext tag configure hyper -underline on -foreground #0064FF
		.top_diagnostic.f_main.t_diagtext tag configure hyper_file -underline on -foreground #0064FF
		.top_diagnostic.f_main.t_diagtext tag bind hyper <Any-Enter> ".top_diagnostic.f_main.t_diagtext tag configure hyper $hylink_enter; .top_diagnostic.f_main.t_diagtext configure -cursor hand1"
		.top_diagnostic.f_main.t_diagtext tag bind hyper_file <Any-Enter> ".top_diagnostic.f_main.t_diagtext tag configure hyper_file $hylink_enter; .top_diagnostic.f_main.t_diagtext configure -cursor hand1"
		.top_diagnostic.f_main.t_diagtext tag bind hyper <Any-Leave> ".top_diagnostic.f_main.t_diagtext tag configure hyper $hylink_leave; .top_diagnostic.f_main.t_diagtext configure -cursor arrow"
		.top_diagnostic.f_main.t_diagtext tag bind hyper_file <Any-Leave> ".top_diagnostic.f_main.t_diagtext tag configure hyper_file $hylink_leave; .top_diagnostic.f_main.t_diagtext configure -cursor arrow"
		.top_diagnostic.f_main.t_diagtext tag bind hyper <Button-1> {catch {exec sh -c "xdg-open http://sourceforge.net/tracker2/?group_id=238442" &}}
		.top_diagnostic.f_main.t_diagtext tag bind hyper_file <Button-1> {catch {exec sh -c "xdg-open $::env(HOME)/tv-viewer_diag.out" &}}
		
		.top_diagnostic.f_main.pgb_diagnostic stop
		.top_diagnostic.f_main.pgb_diagnostic configure -mode determinate
		.top_diagnostic.f_main.pgb_diagnostic configure -value 100
		if {$handler == 0} {
			log_writeOutTv 0 "Diagnostic routine finished"
			.top_diagnostic.f_main.l_diagnostic_msg configure -text [mc "Diagnostic Routine finished"]
			
			.top_diagnostic.f_main.t_diagtext insert end [mc "Generated file:"]
			.top_diagnostic.f_main.t_diagtext insert end "\n
$::env(HOME)/tv-viewer_diag.out" hyper_file
			.top_diagnostic.f_main.t_diagtext insert end "\n\n"
			.top_diagnostic.f_main.t_diagtext insert end [mc "Create a bug report on "]
			.top_diagnostic.f_main.t_diagtext insert end "sourceforge.net" hyper
			.top_diagnostic.f_main.t_diagtext insert end "\n"
			.top_diagnostic.f_main.t_diagtext insert end [mc "and attach the generated file."]
			.top_diagnostic.f_main.t_diagtext configure -state disabled
		} else {
			log_writeOutTv 2 "Diagnostic routine crashed"
			.top_diagnostic.f_main.l_diagnostic_msg configure -text [mc "Diagnostic Routine crashed"] -image $::icon_m(dialog-warning)
			.top_diagnostic.f_main.t_diagtext insert end [mc "Generated file:"]
			.top_diagnostic.f_main.t_diagtext insert end "\n
$::env(HOME)/tv-viewer_diag.out" hyper_file
			.top_diagnostic.f_main.t_diagtext insert end "\n\n"
			.top_diagnostic.f_main.t_diagtext insert end [mc "Create a bug report on "]
			.top_diagnostic.f_main.t_diagtext insert end "sourceforge.net" hyper
			.top_diagnostic.f_main.t_diagtext insert end "\n"
			.top_diagnostic.f_main.t_diagtext insert end [mc "and attach the generated file."]
			.top_diagnostic.f_main.t_diagtext configure -state disabled
		}
		wm protocol .top_diagnostic WM_DELETE_WINDOW "diag_UiExit"
	}
}

proc diag_UiExit {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: diag_UiExit \033\[0m"
	grab release .top_diagnostic
	if {$::option(systray_close) == 1} {
		wm protocol . WM_DELETE_WINDOW {main_systemTrayTogglePre}
	}
	destroy .top_diagnostic
}

proc diag_checkRunning {diag_pid counter} {
	if {"$counter" == "cancel"} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: diag_checkRunning \033\[0;1;31m::cancel:: \033\[0m"
		catch {after cancel $::diag(wait_id)}
		unset -nocomplain ::diag(wait_id)
		return
	}
	catch {exec ps -eo "%p"} readpid
	set status [catch {agrep -w "$readpid" $diag_pid} result]
	if {$status == 1} {
		unset -nocomplain ::diag(wait_id)
		diag_RunFinished 1
	} else {
		incr counter
		set ::diag(wait_id) [after 1000 [list diag_checkRunning $diag_pid $counter]]
	}
}
