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

package require http
package require msgcat
namespace import msgcat::mc
#~ Experimental support for QT and GTK theme.
#~ package require ttk::theme::tileqt
#~ set auto_path [linsert $auto_path 0 "/home/saedelaere/Downloads/tile-themes/tile-gtk/library"]
#~ package require ttk::theme::tilegtk


wm withdraw .

if {[file type [info script]] == "link" } {
	set where_is [file dirname [file dirname [file normalize [file readlink [info script]]]]]
} else {
	set where_is [file dirname [file dirname [file normalize [info script]]]]
}
#~ Test starting with symlink.
#~ [file dirname [file dirname [file normalize [file join [info script] bogus]]]]

set where_is_home "$::env(HOME)/.tv-viewer"

if {"$::tcl_platform(machine)" == "x86_64"} {
	catch {load $where_is/extensions/tktray/64/libtktray1.1.so} load_lib_tray
	puts "loading $::tcl_platform(machine) library"
	if {[string length [string trim $load_lib_tray]] > 1} {
		puts "ERROR:
$load_lib_tray"
	}
} else {
	catch {load $where_is/extensions/tktray/32/libtktray1.1.so} load_lib_tray
	puts "loading $::tcl_platform(machine) library"
	if {[string length [string trim $load_lib_tray]] > 1} {
		puts "ERROR:
$load_lib_tray"
	}
}

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

set option(release_version) "0.8.1b1.20"

puts "This is TV-Viewer $option(release_version) ..."

set get_installed_version [glob -nocomplain "$::where_is_home/config/tv-viewer-*.ver"]
if {[string trim $get_installed_version] != {}} {
	set normalized_version_file [file normalize "$get_installed_version"]
	set status_regexp_version [regexp {tv-viewer-([\d.ab]+)\.ver} "$normalized_version_file" <-> read_version]
	if {[package vcompare $option(release_version) $read_version] != 0} {
		puts "
You've installed a new version of TV-Viewer."
#		Upgrade or downgrade?
		if {[package vcompare $option(release_version) $read_version] == -1} {
#			Downgrade
			puts "This seems to be a downgrade!"
			if {[file isdirectory "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version/"]} {file delete -force -- pathname "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version/"}
			file mkdir "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version/"
			catch {exec sh -c "mv $::env(HOME)/.tv-viewer/log/ $::env(HOME)/.tv-viewer/config/ $::env(HOME)/.tv-viewer/tmp/ $::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version/"}
			file mkdir "$::env(HOME)/.tv-viewer/config/" "$::env(HOME)/.tv-viewer/tmp/" "$::env(HOME)/.tv-viewer/log/"
			set get_channels [glob -nocomplain "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/config/stations_*.conf"]
			foreach {station_file} [split "$get_channels"] {
				catch {file copy -force "$station_file" "$where_is_home/config/"}
			}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/config/tv-viewer.conf" "$where_is_home/config/"}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/log/scheduler.log" "$where_is_home/log/"}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/log/videoplayer.log" "$where_is_home/log/"}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/log/tvviewer.log" "$where_is_home/log/"}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/config/scheduler.conf" "$where_is_home/config/"}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/config/scheduled_recordings.conf" "$where_is_home/config/"}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/config/last_read.conf" "$where_is_home/config/"}
			set new_version_file [open "$where_is_home/config/tv-viewer-$option(release_version)\.ver" w]
			close $new_version_file
			puts "Config files from TV-Viewer $read_version can be found in:
$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version/"
		}
		if {[package vcompare $option(release_version) $read_version] == 1} {
#			Upgrade
			puts "This seems to be an upgrade."
			if {[file isdirectory "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version/"]} {file delete -force -- pathname "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version/"}
			file mkdir "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version/"
			catch {exec sh -c "mv $::env(HOME)/.tv-viewer/log/ $::env(HOME)/.tv-viewer/config/ $::env(HOME)/.tv-viewer/tmp/ $::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version/"}
			file mkdir "$::env(HOME)/.tv-viewer/config/" "$::env(HOME)/.tv-viewer/tmp/" "$::env(HOME)/.tv-viewer/log/"
			set get_channels [glob -nocomplain "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/config/stations_*.conf"]
			foreach {station_file} [split "$get_channels"] {
				catch {file copy -force "$station_file" "$where_is_home/config/"}
			}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/config/tv-viewer.conf" "$where_is_home/config/"}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/log/scheduler.log" "$where_is_home/log/"}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/log/videoplayer.log" "$where_is_home/log/"}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/log/tvviewer.log" "$where_is_home/log/"}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/config/scheduler.conf" "$where_is_home/config/"}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/config/scheduled_recordings.conf" "$where_is_home/config/"}
			catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version\/config/last_read.conf" "$where_is_home/config/"}
			set new_version_file [open "$where_is_home/config/tv-viewer-$option(release_version)\.ver" w]
			close $new_version_file
			puts "Config files from TV-Viewer $read_version can be found in:
$::env(HOME)/.tv-viewer/backup_folder/tv-viewer$read_version/"
		}
	}
} else {
	puts "
You've installed a new version of TV-Viewer."
	if {[file isdirectory "$::env(HOME)/.tv-viewer/"]} {
		puts "Old version could not be recognized."
		if {[file isdirectory "$::env(HOME)/.tv-viewer/backup_folder/unknown_version/"]} {file delete -force -- pathname "$::env(HOME)/.tv-viewer/backup_folder/unknown_version/"}
		file mkdir "$::env(HOME)/.tv-viewer/backup_folder/unknown_version/"
		catch {exec sh -c "mv $::env(HOME)/.tv-viewer/log/ $::env(HOME)/.tv-viewer/config/ $::env(HOME)/.tv-viewer/tmp/ $::env(HOME)/.tv-viewer/backup_folder/unknown_version/"}
		file mkdir "$::env(HOME)/.tv-viewer/config/" "$::env(HOME)/.tv-viewer/tmp/" "$::env(HOME)/.tv-viewer/log/"
		set get_channels [glob -nocomplain "$::env(HOME)/.tv-viewer/backup_folder/unknown_version/config/stations_*.conf"]
		foreach {station_file} [split "$get_channels"] {
			catch {file copy -force "$station_file" "$where_is_home/config/"}
		}
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/unknown_version/config/tv-viewer.conf" "$where_is_home/config/"}
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/unknown_version/log/scheduler.log" "$where_is_home/log/"}
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/unknown_version/log/videoplayer.log" "$where_is_home/log/"}
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/unknown_version/log/tvviewer.log" "$where_is_home/log/"}
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/unknown_version/config/scheduler.conf" "$where_is_home/config/"}
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/unknown_version/config/scheduled_recordings.conf" "$where_is_home/config/"}
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/unknown_version/config/last_read.conf" "$where_is_home/config/"}
		puts "Config files from unknown version can be found in:
$::env(HOME)/.tv-viewer/backup_folder/unknown_version/"
	} else {
		file mkdir "$::env(HOME)/.tv-viewer/" "$::env(HOME)/.tv-viewer/config/" "$::env(HOME)/.tv-viewer/tmp/" "$::env(HOME)/.tv-viewer/log/"
		set new_version_file [open "$where_is_home/config/tv-viewer-$option(release_version)\.ver" w]
		close $new_version_file
	}
}

#source agrep, replaces unix grep command.
source $::where_is/data/agrep.tcl
#check whether or not tv-viewer is already running.
set status_lock [catch {exec ln -s "[pid]" "$::where_is_home/tmp/lockfile.tmp"} resultat_lock]
if { $status_lock != 0 } {
	set linkread [file readlink "$::where_is_home/tmp/lockfile.tmp"]
	catch {exec ps -eo "%p"} readpid
	set status_greppid [catch {agrep -w "$readpid" $linkread} resultat_greppid]
	if { $status_greppid != 0 } {
		catch {file delete "$::where_is_home/tmp/lockfile.tmp"}
		catch {exec ln -s "[pid]" "$::where_is_home/tmp/lockfile.tmp"}
	} else {
		puts "
An instance of TV-Viewer is already running."
		exit 0
	}
}
unset -nocomplain status_lock resultat_lock linkread status_greppid resultat_greppid
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
