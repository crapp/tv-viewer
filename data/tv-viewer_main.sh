#!/usr/bin/env wish

#       tv-viewer_main.sh
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

if {[catch {package require Tcl 8.5}]} {
	catch {puts "Program error. You'll need Tcl version 8.5 or higher.

Found version: [info patchlevel]
Have a closer look to the user guide for the system requirements.
If you've installed more than one version of Tcl, the symlink wish
might not point to the correct location.
/usr/bin/wish is pointing to:
[file readlink /usr/bin/wish]
"
}
	exit 1
}

set status_tk [catch {package require Tk 8.5} resultat_tk]
if { $status_tk != 0 } {
	puts "Runtime error. There is a missing dependency.
Please install the package tk >= 8.5

Error message:
$resultat_tk

Have a closer look to the user guide for the system requirements.
If you've installed more than one version of Tk, the symlink wish
might not point to the correct location.
/usr/bin/wish is pointing to:
[file readlink /usr/bin/wish]
"
	exit 1
}

unset -nocomplain status_tk resultat_tk

package require http
package require msgcat
namespace import msgcat::mc

wm withdraw .

if {[file type [info script]] == "link" } {
	set where_is [file dirname [file dirname [file normalize [file readlink [info script]]]]]
} else {
	set where_is [file dirname [file dirname [file normalize [info script]]]]
}
#~ Test starting with symlink.
#~ [file dirname [file dirname [file normalize [file join [info script] bogus]]]]

set option(where_is_home) "$::env(HOME)/.tv-viewer"

set ::option(appname) tv-viewer_main

set root_test "/usr/bin/tv-viewer.tst"
set root_test_open [catch {open $root_test w}]
catch {close $root_test_open}
if {[file exists "/usr/bin/tv-viewer.tst"]} {
	file delete -force "/usr/bin/tv-viewer.tst"
	if { "$::tcl_platform(user)" == "root" } {
		puts "
You are running tv-viewer as root.
This is not recommended!"
		exit 1
	}
}
unset -nocomplain root_test root_test_open

set option(release_version) {0.8.1 52 24.12.2009}

puts "This is TV-Viewer [lindex $option(release_version) 0] Build [lindex $option(release_version) 1] ..."

proc main_startupCf {version read_version read_build} {
	if {[string is integer $read_build]} {
		set target "tv-viewer$read_version\_build$read_build"
		set messageFin "Config files from TV-Viewer $read_version Build $read_build can be found in:
$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\_build$read_build/"
	}
	if {"$read_build" == "nobuild"} {
		set target "tv-viewer$read_version"
		set messageFin "Config files from TV-Viewer $read_version can be found in:
$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/"
	}
	if {"$read_build" == "unknown"} {
		set target "unknown_version"
		set messageFin "Config files from TV-Viewer unknown version can be found in:
$::env(HOME)/.tv-viewer/backup_folder/unknown_version/"
	}
	if {[file isdirectory "$::env(HOME)/.tv-viewer/backup_folder/$target\/"]} {file delete -force -- pathname "$::env(HOME)/.tv-viewer/backup_folder/$target\/"}
	file mkdir "$::env(HOME)/.tv-viewer/backup_folder/$target\/"
	catch {exec sh -c "mv $::env(HOME)/.tv-viewer/log/ $::env(HOME)/.tv-viewer/config/ $::env(HOME)/.tv-viewer/tmp/ $::env(HOME)/.tv-viewer/backup_folder/$target\/"}
	file mkdir "$::env(HOME)/.tv-viewer/config/" "$::env(HOME)/.tv-viewer/tmp/" "$::env(HOME)/.tv-viewer/log/"
	set get_channels [glob -nocomplain "$::env(HOME)/.tv-viewer/backup_folder/$target\/config/stations_*.conf"]
	foreach {station_file} [split "$get_channels"] {
		catch {file copy -force "$station_file" "$::option(where_is_home)/config/"}
	}
	set confFiles {tv-viewer scheduler scheduled_recordings last_read}
	foreach conf $confFiles {
		if {[file exists "$::env(HOME)/.tv-viewer/backup_folder/$target\/config/$conf\.conf"] == 0} continue
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/$target\/config/$conf\.conf" "$::option(where_is_home)/config/"}
	}
	set logFiles {tvviewer scheduler videoplayer}
	foreach log $logFiles {
		if {[file exists "$::env(HOME)/.tv-viewer/backup_folder/$target\/log/$log\.log"] == 0} continue
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/$target\/log/$log\.log" "$::option(where_is_home)/log/"}
	}
	set new_version_file [open "$::option(where_is_home)/config/tv-viewer-[lindex $version 0]_build[lindex $version 1]\.ver" w]
	close $new_version_file
	puts "$messageFin"
}

set get_installed_version [glob -nocomplain "$::option(where_is_home)/config/tv-viewer-*.ver"]
if {[string trim $get_installed_version] != {}} {
	set normalized_version_file [file normalize "$get_installed_version"]
	set status_regexp_version [regexp {tv-viewer-([\d.ab]+)\_build} "$normalized_version_file" <-> read_version]
	if {$status_regexp_version == 1} {
		set status_regexp_version2 [regexp {_build([\d]+)\.ver} "$normalized_version_file" <-> read_build]
		if {[package vcompare [lindex $option(release_version) 0] $read_version] != 0} {
			puts "
You've installed a new version of TV-Viewer."
#			Upgrade or downgrade?
			if {[package vcompare [lindex $option(release_version) 0] $read_version] == -1} {
#				Downgrade
				puts "This seems to be a downgrade!"
				main_startupCf "$option(release_version)" $read_version $read_build
			}
			if {[package vcompare [lindex $option(release_version) 0] $read_version] == 1} {
#			Upgrade
				puts "This seems to be an upgrade."
				main_startupCf "$option(release_version)" $read_version $read_build
			}
		} else {
			if {[lindex $option(release_version) 1] != $read_build} {
				puts "
You've installed a new version of TV-Viewer."
				if {[lindex $option(release_version) 1] < $read_build} {
					puts "This seems to be a downgrade!"
					main_startupCf "$option(release_version)" $read_version $read_build
				}
				if {[lindex $option(release_version) 1] > $read_build} {
					puts "This seems to be an upgrade."
					main_startupCf "$option(release_version)" $read_version $read_build
				}
			}
		}
	} else {
		# Check for old version system.
		set status_regexp_version [regexp {tv-viewer-([\d.ab]+)\.ver} "$normalized_version_file" <-> read_version]
		if {[package vcompare [lindex $option(release_version) 0] $read_version] != 0} {
			puts "
You've installed a new version of TV-Viewer."
#			Upgrade or downgrade?
			if {[package vcompare [lindex $option(release_version) 0] $read_version] == -1} {
#				Downgrade
				puts "This seems to be a downgrade!"
				main_startupCf "$option(release_version)" $read_version nobuild
			}
			if {[package vcompare [lindex $option(release_version) 0] $read_version] == 1} {
#				Upgrade
				puts "This seems to be an upgrade."
				main_startupCf "$option(release_version)" $read_version nobuild
			}
		} else {
			#This must be a new version because of new build concept.
			puts "
You've installed a new version of TV-Viewer."
			puts "This seems to be an upgrade."
			main_startupCf "$option(release_version)" $read_version nobuild
		}
	}
} else {
	puts "
You've installed a new version of TV-Viewer."
	if {[file isdirectory "$::env(HOME)/.tv-viewer/"]} {
		puts "Old version could not be recognized."
		main_startupCf "$option(release_version)" unknown unknown
	} else {
		file mkdir "$::env(HOME)/.tv-viewer/" "$::env(HOME)/.tv-viewer/config/" "$::env(HOME)/.tv-viewer/tmp/" "$::env(HOME)/.tv-viewer/log/"
		set new_version_file [open "$::env(HOME)/.tv-viewer/config/tv-viewer-[lindex $option(release_version) 0]_build[lindex $option(release_version) 1]\.ver" w]
		close $new_version_file
	}
}
unset -nocomplain get_installed_version normalized_version_file status_regexp_version status_regexp_version2 new_version_file read_version

#source agrep, replaces unix grep command.
source $::where_is/data/agrep.tcl
#check whether or not tv-viewer is already running.
set status_lock [catch {exec ln -s "[pid]" "$::option(where_is_home)/tmp/lockfile.tmp"} resultat_lock]
if { $status_lock != 0 } {
	set linkread [file readlink "$::option(where_is_home)/tmp/lockfile.tmp"]
	catch {exec ps -eo "%p"} readpid
	set status_greppid [catch {agrep -w "$readpid" $linkread} resultat_greppid]
	if { $status_greppid != 0 } {
		catch {file delete "$::option(where_is_home)/tmp/lockfile.tmp"}
		catch {exec ln -s "[pid]" "$::option(where_is_home)/tmp/lockfile.tmp"}
	} else {
		puts "
An instance of TV-Viewer is already running."
		exit 0
	}
}
unset -nocomplain status_lock resultat_lock linkread status_greppid resultat_greppid readpid read_build

#~ Experimental support for QT and GTK theme.
#~ if {[file exists "/home/saedelaere/Downloads/tile-qt/library/libtileqt0.6.so"]} {
	#~ set auto_path [linsert $auto_path 0 "/home/saedelaere/Downloads/tile-qt/library"]
	#~ package require ttk::theme::tileqt
#~ }
#~ package require ttk::theme::tileqt
#~ set auto_path [linsert $auto_path 0 "/home/saedelaere/Downloads/tile-themes/tile-gtk/library"]
#~ package require ttk::theme::tilegtk
if {"$::tcl_platform(machine)" == "x86_64"} {
	set auto_path [linsert $auto_path 0 "$::where_is/extensions/tktray/64"]
	set status_tray [catch {package require tktray} result_tkray]
	puts "loading $::tcl_platform(machine) shared libraries"
	if {$status_tray == 1} {
		puts "ERROR:
$result_tktray"
	}
} else {
	set auto_path [linsert $auto_path 0 "$::where_is/extensions/tktray/32"]
	set status_tray [catch {package require tktray} result_tkray]
	puts "loading $::tcl_platform(machine) shared libraries"
	if {$status_tray == 1} {
		puts "ERROR:
$result_tktray"
	}
}
#source autoscroll function for scrollbars and load package autoscroll
source $::where_is/extensions/autoscroll/autoscroll.tcl
package require autoscroll
namespace import ::autoscroll::autoscroll
#source calendar widget
source $::where_is/extensions/callib/callib.tcl
#append fsdialog to auto_path
set auto_path [linsert $auto_path 0 "$::where_is/extensions/fsdialog"]
#source read_config to read all config values
source $::where_is/data/main_read_config.tcl
#source start options
source $::where_is/data/main_command_line_options.tcl
start_options
#It is time to load all config values
main_readConfig
#source additional ttk themes, plastik and keramik
source "$where_is/themes/plastik/plastik.tcl"
source "$where_is/themes/keramik/keramik.tcl"
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
if {[msgcat::mcload $where_is/msgs] != 1} {
	msgcat::mclocale en
	msgcat::mcload $where_is/msgs
	puts "$::env(LANG) no translation found"
}
#Sourcing logfile and launching log process
source $::where_is/data/log_viewer.tcl
log_viewerCheck
log_writeOutTv 0 "TV-Viewer process PID [pid]"
#source create icons
source $::where_is/data/create_icons.tcl
#create all icons for app.
create_icons
#source splash screen
source $::where_is/data/launch_splash.tcl
#launching splash screen if wanted.
if {$::option(show_splash) == 1} {
	launch_splash_screen
}
#source station after message.
source $::where_is/data/station_after_msg.tcl
#source alle related functions for station changing.
source $::where_is/data/main_station_zap.tcl
#source reading station list
source $::where_is/data/main_read_station_file.tcl
#execute reading of station list
main_readStationFile
#source stream and picqual related stuff.
source $::where_is/data/main_picqual_stream.tcl
#source tv player and related functions
source $::where_is/data/tv_callback.tcl
source $::where_is/data/tv_file_calc.tcl
source $::where_is/data/tv_player.tcl
source $::where_is/data/tv_playback.tcl
source $::where_is/data/tv_seek.tcl
source $::where_is/data/tv_slist.tcl
source $::where_is/data/tv_wm.tcl
#source tv osd
source $::where_is/data/tv_osd.tcl
#source newsreader ui and update checker.
source $::where_is/data/main_newsreader.tcl
#source system tray.
source $::where_is/data/main_system_tray.tcl
#source info toplevel and user guide.
source $::where_is/data/info_help.tcl
#source key sequences
source $::where_is/data/key_sequences.tcl
#source tooltip
source $::where_is/data/tooltip.tcl
#source main ui and related functions
source $::where_is/data/main_frontend.tcl
#source command socket
source $::where_is/data/command_socket.tcl
#source color management toplevel and related functions.
source $::where_is/data/colorm.tcl
#source station item related stuff.
source $::where_is/data/station_item.tcl
#source station editor
source $::where_is/data/station_edit.tcl
#source station search
source $::where_is/data/station_search.tcl
#source record wizard
source $::where_is/data/record_wizard.tcl
#source direct record function
source $::where_is/data/record_handler.tcl
#source adding a new recording
source $::where_is/data/record_add_edit.tcl
#source remote functions for scheduler
source $::where_is/data/record_scheduler_remote.tcl
#source timeshift
source $::where_is/data/main_timeshift.tcl
#source read and set config values for config-wizard.
source $::where_is/data/config_wizard_read_settings.tcl
#source main ui config
source $::where_is/data/config_wizard.tcl
#source general options
source $::where_is/data/config_general.tcl
#source config options analog
source $::where_is/data/config_analog.tcl
#source config options dvb
source $::where_is/data/config_dvb.tcl
#source config options video
source $::where_is/data/config_video.tcl
#source config options audio
source $::where_is/data/config_audio.tcl
#source config options radio
source $::where_is/data/config_radio.tcl
#source config options interface
source $::where_is/data/config_interface.tcl
#source config options record
source $::where_is/data/config_record.tcl
#source config options advanced
source $::where_is/data/config_advanced.tcl
#source font chooser dialog
source $::where_is/data/font_chooser.tcl

#launching main ui and all things that need to be done now...

cd "$::env(HOME)"

main_frontendUiTvviewer
