#       main_timeshift.tcl
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

proc timeshift {tbutton} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: timeshift \033\[0m \{$tbutton\}"
	set status_recordlinkread [catch {file readlink "$::option(where_is_home)/tmp/record_lockfile.tmp"} resultat_recordlinkread]
	if { $status_recordlinkread == 0 } {
		catch {exec ps -eo "%p"} read_ps
		set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
		if { $status_greppid_record == 0 } {
			log_writeOutTv 2 "There is a running recording (PID $resultat_recordlinkread)"
			log_writeOutTv 2 "Can't start timeshift."
			return
		}
	}
	catch {exec""}
	set status_timeslinkread [catch {file readlink "$::option(where_is_home)/tmp/timeshift_lockfile.tmp"} resultat_timeslinkread]
	if { $status_timeslinkread == 0 } {
		catch {exec ps -eo "%p"} read_ps
		set status_greppid_times [catch {agrep -w "$read_ps" $resultat_timeslinkread} resultat_greppid_times]
		if { $status_greppid_times == 0 } {
			log_writeOutTv 0 "Timeshift (PID: $resultat_timeslinkread) is running, will stop it."
			$tbutton state !pressed
			catch {exec kill $resultat_timeslinkread}
			after 2000 {catch {exec""}}
			catch {file delete "$::option(where_is_home)/tmp/timeshift_lockfile.tmp"}
			catch {timeshift_calcDF cancel}
			record_schedulerPreStop timeshift
			return
		}
	}
	log_writeOutTv 0 "Starting timeshift..."
	if {[file exists $::option(video_device)] == 0} {
		log_writeOutTv 2 "The Video Device $::option(video_device) does not exist."
		log_writeOutTv 2 "Have a look into the preferences and change it."
		return
	}
	record_schedulerPrestart timeshift
	$tbutton state pressed
	$tbutton state disabled
	bind .tv <<timeshift>> {}
	bind . <<timeshift>> {}
	timeshift_start_preRec $tbutton
}

proc timeshift_start_preRec {tbutton} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: timeshift_start_preRec \033\[0m \{$tbutton\}"
	if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"]} {
		catch {file delete -force "[subst $::option(timeshift_path)/timeshift.mpeg]"}
	}
	set status [tv_callbackMplayerRemote alive]
	if {$status != 1} {
		set ::timeshift(wait_id) [after 100 [list timeshift_Wait $tbutton]]
	} else {
		catch {exec ""}
		set rec_pid [exec "$::where_is/data/recorder.tcl" "[subst $::option(timeshift_path)/timeshift.mpeg]" $::option(video_device) infinite &]
		after 3000 [list timeshift_start_Rec 0 $rec_pid $tbutton]
	}
}

proc timeshift_Wait {tbutton} {
	set status [tv_callbackMplayerRemote alive]
	if {$status != 1} {
		set ::timeshift(wait_id) [after 100 [list timeshift_Wait $tbutton]]
	} else {
		catch {exec ""}
		set rec_pid [exec "$::where_is/data/recorder.tcl" "[subst $::option(timeshift_path)/timeshift.mpeg]" $::option(video_device) infinite &]
		after 3000 [list timeshift_start_Rec 0 $rec_pid $tbutton]
	}
}

proc timeshift_start_Rec {counter rec_pid tbutton} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: timeshift_start_Rec \033\[0m \{$counter\} \{$rec_pid\} \{$tbutton\}"
	if {$counter == 10} {
		log_writeOutTv 2 "Can't start timeshift. Tried for 30 seconds."
		catch {exec kill $rec_pid}
		catch {exec ""}
		if {[winfo exists .tv.l_anigif]} {
			launch_splashPlay cancel 0 0 0
			place forget .tv.l_anigif
			destroy .tv.l_anigif
		}
		record_scheduler_prestartCancel timeshift
		return
	}
	if {[file exists "[subst $::option(timeshift_path)/timeshift.mpeg]"] && [file size "[subst $::option(timeshift_path)/timeshift.mpeg]"] > 0} {
		catch {exec ln -f -s "$rec_pid" "$::option(where_is_home)/tmp/timeshift_lockfile.tmp"}
		log_writeOutTv 0 "Timeshift process PID $rec_pid"
		if {$::option(timeshift_df) != 0} {
			log_writeOutTv 1 "Starting to calculate free disk space for timeshift."
			after 60000 [list timeshift_calcDF 0]
		}
		set ::tv(current_rec_file) "[subst $::option(timeshift_path)/timeshift.mpeg]"
		record_schedulerRec timeshift
	} else {
		catch {exec kill $rec_pid}
		catch {exec ""}
		set rec_pid [exec "$::where_is/data/recorder.tcl" "[subst $::option(timeshift_path)/timeshift.mpeg]" $::option(video_device) infinite &]
		after 3000 [list timeshift_start_Rec [expr $counter + 1] $rec_pid $tbutton]
	}
}

proc timeshift_calcDF {cancel} {
	if {"$cancel" == "cancel"} {
		puts $::main(debug_msg) "\033\[0;1;33mDebug: timeshift_calcDF \033\[0;1;31m::cancel:: \033\[0m"
		catch {after cancel $::timeshif(df_id)}
		unset -nocomplain ::timeshif(df_id)
		return
	}
	if {[winfo exists .tv.file_play_bar.b_pause]} {
		catch {exec df "$::option(timeshift_path)/"} df_values
		foreach line [split $df_values "\n"] {
			if {[string is digit [lindex $line 3]]} {
				set remaining_space [expr int([lindex $line 3].0 / 1024)]
				if {$remaining_space <= $::option(timeshift_df)} {
					log_writeOutTv 2 "Remaining space <= $::option(timeshift_df)\MB will stop timeshift."
					timeshift .top_buttons.button_timeshift
					return
				}
			}
		}
		after 60000 [list timeshift_calcDF 0]
	}
}

proc timeshift_Save {tvw} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: timeshift_Save \033\[0m \{$tvw\}"
	set types {
	{{Video Files}      {.mpeg}       }
	}
	set infile "[lindex $::station(last) 0]_[clock format [clock seconds] -format {%d-%m-%Y}]_[clock format [clock seconds] -format {%H:%M}].mpeg" 
	if {[file exists "$::option(where_is_home)/tmp/timeshift.mpeg"]} {
		log_writeOutTv 0 "Found timeshift mpeg file, opening file save dialog."
		set ofile [ttk::getSaveFile -filetypes $types -defaultextension ".mpeg" -initialfile "$infile" -initialdir "$::option(rec_default_path)" -hidden 0 -title [mc "Choose name and location"] -parent $tvw]
		if {[string trim $ofile] != {}} {
			if {[file isdirectory [file dirname "$ofile"]]} {
				timeshift_CopyBar "$ofile"
			} else {
				log_writeOutTv 2 "Can not save timeshift video file."
				log_writeOutTv 2 "[file dirname $ofile]"
				log_writeOutTv 2 "Not a directory."
			}
		}
	} else {
		log_writeOutTv 2 "Can not find timeshift.mpeg in"
		log_writeOutTv 2 "$::option(where_is_home)/tmp/"
		log_writeOutTv 2 "File can not be saved"
	}
}

proc timeshift_CopyBar {ofile} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: timeshift_CopyBar \033\[0m \{$ofile\}"
	set wtop [toplevel .tv.top_cp_progress]
	
	place [ttk::frame $wtop.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
	
	set mf [ttk::frame $wtop.f_main]
	set bf [ttk::frame $wtop.f_button -style TLabelframe]
	
	ttk::label $mf.l_info \
	-text [mc "Copying timeshift video file.
Please wait..."] \
	-compound left \
	-image $::icon_m(dialog-information)
	
	ttk::progressbar $mf.pb_progcp \
	-orient horizontal \
	-mode determinate \
	-variable timeshift(pgp)
	
	ttk::label $mf.l_inf_progre \
	-textvariable timeshift(lProgress)
	
	ttk::button $bf.b_cancel \
	-text [mc "Cancel"] \
	-compound left \
	-image $::icon_s(dialog-cancel)
	
	grid $mf -in $wtop -row 0 -column 0 \
	-sticky nesw
	grid $bf -in $wtop -row 1 -column 0 \
	-sticky ew \
	-padx 3 \
	-pady 3
	
	grid anchor $bf e
	
	grid $mf.l_info -in $mf -row 0 -column 0 \
	-sticky w \
	-padx 5 \
	-pady 5
	grid $mf.pb_progcp -in $mf -row 1 -column 0 \
	-sticky ew \
	-padx 10 \
	-pady "10 5"
	grid $mf.l_inf_progre -in $mf -row 2 -column 0 \
	-padx "10 0" \
	-pady "0 5"
	
	grid $bf.b_cancel -in $bf -row 0 -column 0 \
	-padx 3 \
	-pady 7
	
	grid rowconfigure $wtop {0 1} -weight 1
	
	grid columnconfigure $wtop 0 -weight 1 -minsize 250
	grid columnconfigure $mf 0 -weight 1
	
	wm resizable $wtop 0 0
	wm title $wtop [mc "Copying...       %%%" 0]
	wm protocol $wtop WM_DELETE_WINDOW " "
	wm protocol . WM_DELETE_WINDOW " "
	wm protocol .tv WM_DELETE_WINDOW " "
	wm iconphoto $wtop $::icon_b(floppy)
	wm transient $wtop .tv
	
	
	set sfile "$::option(where_is_home)/tmp/timeshift.mpeg"
	set file_size [file size $sfile]
	set file_size_s [format %.2f [expr ($file_size / 1073741824.0)]]
	set ::timeshift(lProgress) "0 / $file_size_s GB"
	set old_size 0
	set counter 0
	set increment  [expr $file_size.0 / 100]
	set ::timeshift(pgp) 0
	
	catch {exec cp -f "$sfile" "$ofile" &} cp_pid
	log_writeOutTv 0 "Copying timeshift video file. Copy process PID: $cp_pid"
	set ::timeshift(cp_id) [after 0 [list timeshift_CopyBarProgr "$sfile" "$ofile" $counter $file_size $old_size $file_size_s $cp_pid $increment]]
	$bf.b_cancel configure -command [list timeshift_CopyBarProgr cancel $cp_pid 0 0 0 0 0 0]
	
	tkwait visibility $wtop
	grab $wtop
}

proc timeshift_CopyBarProgr {sfile ofile counter file_size old_size file_size_s cp_pid increment} {
	if {"$sfile" == "cancel"} {
		catch {after cancel $::timeshift(cp_id)}
		unset -nocomplain ::timeshift(cp_id)
		catch {exec kill $ofile}
		if {$::option(systray_close) == 1} {
			wm protocol . WM_DELETE_WINDOW {main_systemTrayTogglePre}
		} else {
			wm protocol . WM_DELETE_WINDOW {main_frontendExitViewer}
		}
		wm protocol .tv WM_DELETE_WINDOW {main_frontendExitViewer}
		grab release .tv.top_cp_progress
		destroy .tv.top_cp_progress
		return
	}
	catch {exec ps -eo "%p"} readpid_cp
	set status_greppid_cp [catch {agrep -w "$readpid_cp" $cp_pid} resul_greppid_cp]
	if {$status_greppid_cp == 0} {
		if {[file exists $ofile]} {
			if {[file size $ofile] > [expr $old_size + $increment]} {
				set file_size_o [format %.2f [expr ([file size $ofile] / 1073741824.0)]]
				set ::timeshift(lProgress) "$file_size_o / $file_size_s GB"
				set count_up [expr (([file size $ofile] - $old_size) / $increment)]
				set counter [expr $counter + $count_up]
				set ::timeshift(pgp) $counter
				wm title .tv.top_cp_progress [mc "Copying...       %%%" [format %.2f $counter]]
				set old_size [file size $ofile]
				set ::timeshift(cp_id) [after 50 [list timeshift_CopyBarProgr $sfile $ofile $counter $file_size $old_size $file_size_s $cp_pid $increment]]
			} else {
				set ::timeshift(cp_id) [after 50 [list timeshift_CopyBarProgr $sfile $ofile $counter $file_size $old_size $file_size_s $cp_pid $increment]]
			}
		} else {
			set ::timeshift(cp_id) [after 50 [list timeshift_CopyBarProgr $sfile $ofile $counter $file_size $old_size $file_size_s $cp_pid $increment]]
		}
	} else {
		wm title .tv.top_cp_progress [mc "Copying...       finished"]
		set ::timeshift(lProgress) "$file_size_s / $file_size_s GB"
		set ::timeshift(pgp) 100
		log_writeOutTv 0 "Timesift video file copied. Output file:
$ofile"
		after 2000 {
			if {$::option(systray_close) == 1} {
				wm protocol . WM_DELETE_WINDOW {main_systemTrayTogglePre}
			} else {
				wm protocol . WM_DELETE_WINDOW {main_frontendExitViewer}
			}
			wm protocol .tv WM_DELETE_WINDOW {main_frontendExitViewer}
			grab release .tv.top_cp_progress
			destroy .tv.top_cp_progress
		}
	}
}
