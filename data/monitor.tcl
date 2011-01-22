#       monitor.tcl
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

proc monitor_partRunning {handler} {
	# handler: 1 main - 2 scheduler - 3 recording - 4 timeshift - 5 notifyd
	# check if main is running
	if {$handler == 1} {
		set status_mainlinkread [catch {file readlink "$::option(home)/tmp/lockfile.tmp"} resultat_mainlinkread]
		if {$status_mainlinkread == 0} {
			catch {exec ps -eo "%p"} read_ps
			set status_greppid_main [catch {agrep -w "$read_ps" $resultat_mainlinkread} resultat_greppid_main]
			if {$status_greppid_main == 0} {
				catch {exec ps -p $resultat_mainlinkread -o args=} readarg
				set status_grepargDirect [catch {agrep -m "$readarg" "tv-viewer_main.tcl"} resultat_greparg]
				set status_grepargLink [catch {agrep -m "$readarg" "tv-viewer"} resultat_greparg]
				if {$status_grepargDirect == 0 || $status_grepargLink == 0} {
					# running
					return [list 1 $resultat_mainlinkread]
				} else {
					return 0
				}
			} else {
				return 0
			}
		} else {
			return 0
		}
	}
	
	# check if scheduler is running
	if {$handler == 2} {
		set status_schedlinkread [catch {file readlink "$::option(home)/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
		if { $status_schedlinkread == 0 } {
			catch {exec ps -eo "%p"} read_ps
			set status_greppid_sched [catch {agrep -w "$read_ps" $resultat_schedlinkread} resultat_greppid_sched]
			if { $status_greppid_sched == 0 } {
				catch {exec ps -p $resultat_schedlinkread -o args=} readarg
				set status_grepargLink [catch {agrep -m "$readarg" "tv-viewer_scheduler"} resultat_greparg]
				set status_grepargDirect [catch {agrep -m "$readarg" "scheduler.tcl"} resultat_greparg]
				if {$status_grepargLink == 0 || $status_grepargDirect == 0} {
					# running
					return [list 1 $resultat_schedlinkread]
				} else {
					return 0
				}
			} else {
				return 0
			}
		} else {
			return 0
		}
	}
	
	# check if there is a running recording 
	if {$handler == 3} {
		set status_recordlinkread [catch {file readlink "$::option(home)/tmp/record_lockfile.tmp"} resultat_recordlinkread]
		if { $status_recordlinkread == 0 } {
			catch {exec ps -eo "%p"} read_ps
			set status_greppid_record [catch {agrep -w "$read_ps" $resultat_recordlinkread} resultat_greppid_record]
			if { $status_greppid_record == 0 } {
				catch {exec ps -p $resultat_recordlinkread -o args=} readarg
				set status_greparg [catch {agrep -m "$readarg" "recorder.tcl"} resultat_greparg]
				if {$status_greparg == 0} {
					# running
					return [list 1 $resultat_recordlinkread]
				} else {
					return 0
				}
			} else {
				return 0
			}
		} else {
			return 0
		}
	}
	
	# check if there is a running timeshift
	if {$handler == 4} {
		set status_timeslinkread [catch {file readlink "$::option(home)/tmp/timeshift_lockfile.tmp"} resultat_timeslinkread]
		if { $status_timeslinkread == 0 } {
			catch {exec ps -eo "%p"} read_ps
			set status_greppid_times [catch {agrep -w "$read_ps" $resultat_timeslinkread} resultat_greppid_times]
			if { $status_greppid_times == 0 } {
				catch {exec ps -p $resultat_timeslinkread -o args=} readarg
				set status_greparg [catch {agrep -m "$readarg" "recorder.tcl"} resultat_greparg]
				if {$status_greparg == 0} {
					# running
					return [list 1 $resultat_timeslinkread]
				} else {
					return 0
				}
			} else {
				return 0
			}
		} else {
			return 0
		}
	}
	
	# check if notification daemon is running
	if {$handler == 5} {
		set status_notifylinkread [catch {file readlink "$::option(home)/tmp/notifyd_lockfile.tmp"} resultat_notifylinkread]
		if { $status_notifylinkread == 0 } {
			catch {exec ps -eo "%p"} read_ps
			set status_greppid_notify [catch {agrep -w "$read_ps" $resultat_notifylinkread} resultat_greppid_notify]
			if { $status_greppid_notify == 0 } {
				catch {exec ps -p $resultat_notifylinkread -o args=} readarg
				set status_greparg [catch {agrep -m "$readarg" "notifyd.tcl"} resultat_greparg]
				if {$status_greparg == 0} {
					# running
					return [list 1 $resultat_notifylinkread]
				} else {
					return 0
				}
			} else {
				return 0
			}
		} else {
			return 0
		}
	}
}
