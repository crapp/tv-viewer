#       main_timeshift.tcl
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
	catch {exec ""}
	set rec_pid [exec "$::where_is/data/recorder.tcl" "[subst $::option(timeshift_path)/timeshift.mpeg]" $::option(video_device) infinite &]
	after 3000 [list timeshift_start_Rec 0 $rec_pid $tbutton]
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
	if {[file size "[subst $::option(timeshift_path)/timeshift.mpeg]"] > 0} {
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
	set infile "[lindex $::station(last) 0]_[clock format [clock seconds] -format {%d.%m.%Y}].mpeg" 
	if {[file exists $::option(where_is_home)/tmp/timeshift.mpeg]} {
		log_writeOutTv 0 "Found timeshift mpeg file, opening file dialog."
		set ofile [ttk::getSaveFile -filetypes $types -defaultextension ".mpeg" -initialfile "$infile" -initialdir "$::option(rec_default_path)" -hidden 0 -title [mc "Choose name and location"] -parent $tvw]
		if {[string trim $ofile] != {}} {
			if {[file isdirectory [file dirname "$ofile"]]} {
				file copy -force "$::option(where_is_home)/tmp/timeshift.mpeg" "$ofile"
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
