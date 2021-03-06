#!/usr/bin/env tclsh

#       diag_runtime.tcl
#       © Copyright 2007-2013 Christian Rapp <christianrapp@users.sourceforge.net>
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

if {[catch {package require Tcl 8.5}]} { 
	catch {puts "Program error. You'll need Tcl version 8.5 or higher.

Found version: [info patchlevel]
Have a closer look to the user guide for the system requirements.
If you've installed more than one version of Tcl, the symlink tclsh
might not point to the correct location.
/usr/bin/tclsh is pointing to:
[file readlink /usr/bin/tclsh]
"
	}
exit 1
}

after 200

set dwhere_is "[file dirname [file dirname [file normalize [file join [info script] bogus]]]]"
set dwhere_is_home "$::env(HOME)"

source $dwhere_is/init.tcl

init_testRoot
init_source "$dwhere_is" "release_version.tcl"

# Start options for the program
array set start_options {--version 0 --help 0 --debug 0}
foreach argumente $argv {set start_options($argumente) 1}
if {[array size start_options] != 3} {
	puts "
TV-Viewer Diagnostic Routine [lindex $option(release_version) 0] Build [lindex $option(release_version) 1]
	
Unkown option(s): $argv

Possible options are:

  --version   Shows the version of the program and the compatibility.
  --help      Displays this help.
"
	exit 0
}

if {$start_options(--help)} {
	puts "
TV-Viewer Diagnostic Routine [lindex $option(release_version) 0] Build [lindex $option(release_version) 1]

Usage: diag_runtime.tcl \[OPTION\]

Possible options are:

  --version   Shows the version of the program and the compatibility.
  --help      Displays this help.
"
	exit 0
}

if {$start_options(--version)} {
	puts "
TV-Viewer Diagnostic Routine [lindex $option(release_version) 0] Build [lindex $option(release_version) 1]

This version is compatible with TV-Viewer [lindex $option(release_version) 0] Build [lindex $option(release_version) 1]
"
	exit 0
}

proc agrep {switch return_input input modifier} {
	foreach line [split "$input" \n] {
		if {"$switch" == "-m"} {
			if {[string match -nocase *$modifier "$line"] || [string match -nocase *$modifier* "$line"] || [string match -nocase $modifier* "$line"]} {
				lappend return_value "$line"
			}
		}
		if {"$switch" == "-w"} {
			if {[lsearch "$line" "$modifier"] != -1} {
				lappend return_value "$line"
			}
		}
	}
	if {[info exists return_value]} {
		if {[llength $return_value] > 1} {
			set return_value [join $return_value \n]
			return -code 0 "$return_value"
		} else {
			set return_value [join $return_value]
			return -code 0 "$return_value"
		}
	} else {
		if {$return_input} {
			return -code 1 "agrep could not find $modifier in $input"
		} else {
			return -code 1 "agrep could not find $modifier"
		}
	}
}

proc diag_writeOut {outfile msg} {
	puts $outfile "$msg"
	flush $outfile
	if {$::start_options(--debug)} {
		puts "$msg"
	}
}

proc diag_checkPkg {diag_file_append} {
	diag_writeOut $diag_file_append "
#######@@@ diag_checkPkg @@@#######"
	set insertLocal 1
	set insertGlob 1
	
	# Checking package Tk available and version
	set status_tk [catch {package require Tk} resultat_tk]
	diag_writeOut $diag_file_append "
***********************************************************************
Tk:
$resultat_tk"
	
	# Checking version of package Tcl.
	diag_writeOut $diag_file_append "
***********************************************************************
Tcl:
[info patchlevel]"
	
	foreach pa $::auto_path {
		if {[string match /usr/local/lib $pa]} {
			set insertLocal 0
		}
		if {[string match /usr/lib $pa]} {
			set insertGlob 0
		}
	}
	if {$insertLocal} {
		if {[file isdirectory /usr/local/lib]} {
			set ::auto_path [linsert $::auto_path 0 "/usr/local/lib"]
		}
	}
	if {$insertGlob} {
		if {[file isdirectory /usr/lib]} {
			set ::auto_path [linsert $::auto_path 0 "/usr/lib"]
		}
	}
	
	# Checking package tkimg available and version.
	set status_img [catch {package require Img} resultat_img]
	diag_writeOut $diag_file_append "
***********************************************************************
tkimg:
$resultat_img"
	
	# Checking package tkimg available and version.
	set status_tktray [catch {package require tktray} resultat_tktray]
	diag_writeOut $diag_file_append "
***********************************************************************
tktray:
$resultat_tktray"
}

proc diag_checkVer {diag_file_append} {
	diag_writeOut $diag_file_append "
#######@@@ diag_checkVer @@@#######"
	# Checking version of tv-viewer.
	set resultat_get_installed_version [glob -nocomplain "$::dwhere_is_home/.tv-viewer/config/tv-viewer-*.ver"]
	if {[string trim $resultat_get_installed_version] != {}} {
		set normalized_version_file [file normalize "$resultat_get_installed_version"]
		set status_regexp_version [regexp {tv-viewer-([\d.ab]+)\_build} "$normalized_version_file" <-> read_version]
		if {$status_regexp_version == 1} {
			set status_regexp_version2 [regexp {_build([\d]+)\.ver} "$normalized_version_file" <-> read_build]
			set version "$read_version Build $read_build"
		} else {
			set status_regexp_version [regexp {tv-viewer-([\d.ab]+)\.ver} "$normalized_version_file" <-> read_version]
			set version "$read_version Build UNKNOWN"
		}
	} else {
		set version UNKNOW
	}
	catch {diag_writeOut $diag_file_append "
***********************************************************************
Checkversion:
$version"
	}
}

proc diag_checkMachineDistri {diag_file_append} {
	diag_writeOut $diag_file_append "
#######@@@ diag_checkMachineDistri @@@#######"
	# On which machine are we running.
	set kernelcheck [catch {exec uname -r} resultat_kernelcheck]
	diag_writeOut $diag_file_append "
***********************************************************************
Kernelcheck:
$resultat_kernelcheck"
	
	# On which machine are we running.
	set archcheck [catch {exec uname -m} resultat_archcheck]
	diag_writeOut $diag_file_append "
***********************************************************************
Processor architecture:
$resultat_archcheck"
	
	# Trying to read distribution and version.
	set districheck [catch {exec sh -c "cat /etc/*release"} resultat_districheck]
	diag_writeOut $diag_file_append "
***********************************************************************
Districheck:
$resultat_districheck"
}

proc diag_checkInstallation {diag_file_append} {
	diag_writeOut $diag_file_append "
#######@@@ diag_checkInstallation @@@#######"
	# Checking symbolic link tv-viewer. Pointing correct?
	set linkcheck [catch {file readlink [auto_execok tv-viewer]} resultat_linkcheck]
	diag_writeOut $diag_file_append "
***********************************************************************
Linkcheck(main):
$resultat_linkcheck"
	set linkcheck [catch {file readlink [auto_execok tv-viewer_diag]} resultat_linkcheck]
	diag_writeOut $diag_file_append "
***********************************************************************
Linkcheck(diag):
$resultat_linkcheck"
	set linkcheck [catch {file readlink [auto_execok tv-viewer_lirc]} resultat_linkcheck]
	diag_writeOut $diag_file_append "
***********************************************************************
Linkcheck(lirc):
$resultat_linkcheck"
	set linkcheck [catch {file readlink [auto_execok tv-viewer_scheduler]} resultat_linkcheck]
	diag_writeOut $diag_file_append "
***********************************************************************
Linkcheck(scheduler):
$resultat_linkcheck"
	set linkcheck [catch {file readlink [auto_execok tv-viewer_recext]} resultat_linkcheck]
	diag_writeOut $diag_file_append "
***********************************************************************
Linkcheck(recext):
$resultat_linkcheck"
}

proc diag_checkHardware {diag_file_append} {
	diag_writeOut $diag_file_append "
#######@@@ diag_checkHardware @@@#######"
	# Here we beginn with checking some Hardware values.
	# Output of lsmod. Are the ivtv moduls loaded?
	catch {exec sh -c "lsmod"} read_lsmod
	set modcheck [catch {agrep -m 0 "$read_lsmod" ivtv} resultat_modcheck]
	diag_writeOut $diag_file_append "
***********************************************************************
Modcheck:
$resultat_modcheck"
	set modcheck2 [catch {agrep -m 0 "$read_lsmod" pvrusb2} resultat_modcheck2]
	diag_writeOut $diag_file_append "
***********************************************************************
Modcheck(pvrusb2):
$resultat_modcheck2"
	set modcheck3 [catch {agrep -m 0 "$read_lsmod" cx18} resultat_modcheck3]
	diag_writeOut $diag_file_append "
***********************************************************************
Modcheck(cx18):
$resultat_modcheck3"
	
	# Output of dmesg. TV-Card initialized correct by the driver?
	catch {exec sh -c "dmesg"} read_dmesg
	set dmesgcheck [catch {agrep -m 0 "$read_dmesg" ivtv} resultat_dmesgcheck]
	diag_writeOut $diag_file_append "
***********************************************************************
Dmesgcheck(ivtv):
$resultat_dmesgcheck"
	set dmesgcheck2 [catch {agrep -m 0 "$read_dmesg" pvrusb2} resultat_dmesgcheck2]
	diag_writeOut $diag_file_append "
***********************************************************************
Dmesgcheck(pvrusb2):
$resultat_dmesgcheck2"
	set dmesgcheck3 [catch {agrep -m 0 "$read_dmesg" cx18} resultat_dmesgcheck3]
	diag_writeOut $diag_file_append "
***********************************************************************
Dmesgcheck(cx18):
$resultat_dmesgcheck3"
	
	# Output of lspci. Which tv-card is recognized?
	set lspci [auto_execok lspci]
	if {[string trim $lspci] != {}} {
		diag_writeOut $diag_file_append "
***********************************************************************
Lspcicheck:"
		catch {exec sh -c "$lspci -v"} resultat_lspcicheck
		#checkFor 0 == check for Multimedia; 1 == check for Syubsystem:
		set checkFor 0
		foreach line [split $resultat_lspcicheck \n] {
			if {$checkFor == 0} {
				if {[string match *Multimedia* $line]} {
					diag_writeOut $diag_file_append "
$line"
					set checkFor 1
				}
			} else {
				if {[string match *Subsystem:* $line]} {
					diag_writeOut $diag_file_append "$line"
					set checkFor 0
				}
			}
		}
	} else {
		diag_writeOut $diag_file_append "
***********************************************************************
Lspcicheck:
Could not detect lspci."
	}
	
	# Output of lsusb. In case you have a supported usb device.
	set lsusbcheck [catch {exec sh -c "lsusb"} resultat_lsusbcheck]
	diag_writeOut $diag_file_append "
***********************************************************************
Lsusbcheck:
$resultat_lsusbcheck"
}

proc diag_checkConfig {diag_file_append} {
	diag_writeOut $diag_file_append "
#######@@@ diag_checkConfig @@@#######"
	# Checking tv-viewer config directory.
	set dircheck [catch {exec sh -c "ls $::env(HOME)/.tv-viewer/*"} resultat_dircheck]
	diag_writeOut $diag_file_append "
***********************************************************************
Dircheck(/home/.tv-viewer):
$resultat_dircheck"
	
	# Reading configuration file of tv-viewer.
	if {[file exists "$::dwhere_is_home/.tv-viewer/config/tv-viewer.conf"]} {
				diag_writeOut $diag_file_append "
***********************************************************************
Configuration:"
		set open_config_file [open "$::dwhere_is_home/.tv-viewer/config/tv-viewer.conf" r]
		while {[gets $open_config_file line]!=-1} {
			if {[string match #* $line] || [string trim $line] == {} } {
				diag_writeOut $diag_file_append "$line"
			} else {
				if {[catch {array set ::option $line}]} {
					diag_writeOut $diag_file_append "Config file line incorrect: $line"
				} else {
					diag_writeOut $diag_file_append "$line"
				}
			}
		}
		close $open_config_file
	} else {
		diag_writeOut $diag_file_append "
***********************************************************************
Configuration:
No config file"
	}
	
	# Reading lastchannel file.
	if {[file exists "$::env(HOME)/.tv-viewer/config/lastchannel.conf"]} {
		set lastcheck [catch {exec cat "$::env(HOME)/.tv-viewer/config/lastchannel.conf"} resultat_lastcheck]
		diag_writeOut $diag_file_append "
***********************************************************************
lastchannel:
$resultat_lastcheck"
	}
	
	# Reading record config.
	if {[file exists "$::env(HOME)/.tv-viewer/config/scheduled_recordings.conf"]} {
		catch {exec cat "$::env(HOME)/.tv-viewer/config/scheduled_recordings.conf"} resultat_scheduled_recordings
		diag_writeOut $diag_file_append "
***********************************************************************
Record_conf:
$resultat_scheduled_recordings"
	}
	
	# Looking for a actual recording
	if {[file exists "$::env(HOME)/.tv-viewer/config/current_rec.conf"]} {
		catch {exec cat "$::env(HOME)/.tv-viewer/config/current_rec.conf"} resultat_current_rec
		diag_writeOut $diag_file_append "
***********************************************************************
Actual recording:
$resultat_current_rec"
	}
	
	# Looking for actual recording
	if {[file exists "$::env(HOME)/.tv-viewer/config/tv-viewer_mem.conf"]} {
		catch {exec cat "$::env(HOME)/.tv-viewer/config/tv-viewer_mem.conf"} resultat_mem
		diag_writeOut $diag_file_append "
***********************************************************************
tv-viewer_mem:
$resultat_mem"
	}
	
	# Reading .lircrc
	if {[file exists "$::env(HOME)/.lircrc"]} {
		catch {exec cat "$::env(HOME)/.lircrc"} resultat_lircrc
		diag_writeOut $diag_file_append "
***********************************************************************
.lircrc:
$resultat_lircrc"
	}
}

proc diag_checkDevice {diag_file_append} {
	diag_writeOut $diag_file_append "
#######@@@ diag_checkDevice @@@#######"
	# List all video devices.
	catch {exec sh -c "ls /dev/video*"} resultat_videodevicels
	diag_writeOut $diag_file_append "
***********************************************************************
VideoDeviceLS:
$resultat_videodevicels"
	
	# Does the device node from the configuration file exist?
	# Trying to read tv-card values using v4l2-ctl.
	if {[info exists ::option(video_device)] == 1 } {
		if {[file exists $::option(video_device)]} {
			diag_writeOut $diag_file_append "
***********************************************************************
VideoDeviceConfig:
Video device exists."
			set v4l2checkall [catch {exec v4l2-ctl -d $::option(video_device) --all} resultat_v4l2checkall]
			diag_writeOut $diag_file_append "
***********************************************************************
V4l2checkall:
$resultat_v4l2checkall"
			set v4l2checkl [catch {exec v4l2-ctl -d $::option(video_device) -l} resultat_v4l2checkl]
			diag_writeOut $diag_file_append "
***********************************************************************
V4l2checkl:
$resultat_v4l2checkl"
		} else {
			diag_writeOut $diag_file_append "
***********************************************************************
Device:
Video device does not exist."
		}
	} else {
		set v4l2checkall [catch {exec v4l2-ctl --all} resultat_v4l2checkall]
		diag_writeOut $diag_file_append "
***********************************************************************
V4l2checkallNOCONFIG:
$resultat_v4l2checkall"
		set v4l2checkl [catch {exec v4l2-ctl -l} resultat_v4l2checkl]
		diag_writeOut $diag_file_append "
***********************************************************************
V4l2checklNOCONFIG:
$resultat_v4l2checkl"
	}
}

proc diag_checkStation {diag_file_append} {
	diag_writeOut $diag_file_append "
#######@@@ diag_checkStation @@@#######"
	# Reading the stations list.
	if {[info exists ::option(frequency_table)] == 1 } {
		if {[file exists "$::env(HOME)/.tv-viewer/config/stations_$::option(frequency_table).conf"]} {
			set stationscheck [catch {exec cat "$::env(HOME)/.tv-viewer/config/stations_$::option(frequency_table).conf"} resultat_stationscheck]
			diag_writeOut $diag_file_append "
***********************************************************************
StationlistFreqTableConfig:
$resultat_stationscheck"
		}
	}
	
	# If there is more than one stations list they will be read in now.
	catch {exec sh -c "ls $::env(HOME)/.tv-viewer/config/stations*.conf"} resultat_stationlists
	if {[llength $resultat_stationlists] > 1} {
		foreach slists $resultat_stationlists {
			if {[info exists ::option(frequency_table)] == 1 } {
				if {[string match *$::option(frequency_table)* $slists]} continue
			}
			set slistName [file rootname [file tail $slists]]
			set slist($slistName) $slists
			set slistsread($slistName) [catch {exec cat $slist($slistName)} resultat_slistsread($slistName)]
			diag_writeOut $diag_file_append "
***********************************************************************
Stationlist($slistName):
$resultat_slistsread($slistName)"
		}
	}
}

proc diag_checkDep {diag_file_append} {
	diag_writeOut $diag_file_append "
#######@@@ diag_checkDep @@@#######"
	# Are the ivtv utilities installed?
	diag_writeOut $diag_file_append "
***********************************************************************
Tunecheck:
[auto_execok ivtv-tune]
v4l2check:
[auto_execok v4l2-ctl]"
	
	# Searching for xdg-utils
	diag_writeOut $diag_file_append "
***********************************************************************
xdg-utils:
[auto_execok xdg-open]"
	
	# Is MPlayer installed
	diag_writeOut $diag_file_append "
***********************************************************************
MPlayer:
[auto_execok mplayer]"
	if {[string trim [auto_execok mplayer]] != {}} {
		catch {exec [auto_execok mplayer] -noconfig all} mplayer_ver
		diag_writeOut $diag_file_append "Mplayer_ver:
$mplayer_ver"
		catch {exec [auto_execok mplayer] -noconfig all -vo help} mplayer_vo
		diag_writeOut $diag_file_append "Mplayer_vo:
$mplayer_vo"
		diag_writeOut $diag_file_append "
Mplayer_config:"
		if {[string trim [auto_execok find]] != {}} {
			catch {exec [auto_execok find] /etc /home -name mplayer.conf 2>/dev/null} mplayer_conf
			if {[string trim $mplayer_conf] != {}} {
				set no_conf 1
				foreach f [split $mplayer_conf \n] {
					if {[string match *child* [string trim [lindex $f 0]]] || [string trim $f] == {}} continue
					set fh [open $f r]
					set fh_content [read $fh]
					diag_writeOut $diag_file_append "
$f"
					diag_writeOut $diag_file_append "$fh_content"
					set no_conf 0
					close $fh
				}
				if {$no_conf} {
					diag_writeOut $diag_file_append "
No mplayer configuration files found."
				}
			} else {
				diag_writeOut $diag_file_append "
No mplayer configuration files found."
			}
		}
	}
}

proc diag_checkLog {diag_file_append} {
	diag_writeOut $diag_file_append "
#######@@@ diag_checkLog @@@#######"
	# read tvviewer log and append content
	if {[file exists "$::env(HOME)/.tv-viewer/log/tvviewer.log"]} {
		set open_LogTV [open "$::env(HOME)/.tv-viewer/log/tvviewer.log" r]
		set logfileTV [read $open_LogTV]
		close $open_LogTV
		diag_writeOut $diag_file_append "
***********************************************************************
Logfile TV-Viewer:
$logfileTV

***********************************************************************"
	}
	# read videoplayer log and append content
	if {[file exists "$::env(HOME)/.tv-viewer/log/videoplayer.log"]} {
		set open_LogVideo [open "$::env(HOME)/.tv-viewer/log/videoplayer.log" r]
		set logfileVideo [read $open_LogVideo]
		close $open_LogVideo
		diag_writeOut $diag_file_append "
***********************************************************************
Logfile Videoplayer:
$logfileVideo

***********************************************************************"
	}
	# read scheduler log and append content
	if {[file exists "$::env(HOME)/.tv-viewer/log/scheduler.log"]} {
		set open_LogSched [open "$::env(HOME)/.tv-viewer/log/scheduler.log" r]
		set logfileSched [read $open_LogSched]
		close $open_LogSched
		diag_writeOut $diag_file_append "
***********************************************************************
Logfile Scheduler
$logfileSched

***********************************************************************"
	}
}

proc diag_exit {diag_file_append} {
	# Program collected all necessary data.
	diag_writeOut $diag_file_append "


Diagnostic routine for TV-Viewer is finished.

Ouput has been stored in:
$::dwhere_is_home/tv-viewer_diag.out

File a bug report on 
http://sourceforge.net/tracker2/?group_id=238442&atid=1106486
and attach the created file.
"
	if {[file isdirectory "$::env(HOME)/.tv-viewer/tmp/"]} {
		catch {exec mkfifo "$::env(HOME)/.tv-viewer/tmp/ComSocketMain"}
		set comsocket [open "$::env(HOME)/.tv-viewer/tmp/ComSocketMain" r+]
		fconfigure $comsocket -blocking 0 -buffering line
		puts -nonewline $comsocket "tv-viewer_main diag_RunFinished 0 \n"
		flush $comsocket
		exit 0
	} else {
		close $diag_file_append
		exit 0
	}
}

puts "
TV-Viewer Diagnostic Routine [lindex $option(release_version) 0] Build [lindex $option(release_version) 1]

Now collecting relevant data. Results can be found in:
$::dwhere_is_home/tv-viewer_diag.out"

set actual_date [clock format [clock scan now] -format "%d.%m.%Y %H:%M:%S"]

set diag_file [open "$::dwhere_is_home/tv-viewer_diag.out" w]

#Opening output file
diag_writeOut $diag_file "TV-Viewer Diagnostic routine Version [lindex $option(release_version) 0] Build [lindex $option(release_version) 1] -- Created: $actual_date

This file is generated by 'tv-viewer_diag.tcl'.
The data that was collected helps the developers to find bugs and to 
provide specific help for users.
If you don't want to send some parts of this file just delete them.

File a bug report on 
http://sourceforge.net/tracker2/?group_id=238442&atid=1106486
and attach this file, or contact the author.
"

close $diag_file
set diag_file_append [open "$::dwhere_is_home/tv-viewer_diag.out" a]

diag_checkPkg $diag_file_append
after 200
diag_checkVer $diag_file_append
after 200
diag_checkMachineDistri $diag_file_append
after 200
diag_checkInstallation $diag_file_append
after 200
diag_checkHardware $diag_file_append
after 200
diag_checkConfig $diag_file_append
after 200
diag_checkDevice $diag_file_append
after 200
diag_checkStation $diag_file_append
after 200
diag_checkDep $diag_file_append
after 200
diag_checkLog $diag_file_append
after 200
diag_exit $diag_file_append
