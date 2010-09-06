#!/usr/bin/env wish

#       tv-viewer_main.tcl
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

set option(root) "[file dirname [file dirname [file dirname [file normalize [file join [info script] bogus]]]]]"
set option(home) "$::env(HOME)/.tv-viewer"
set option(appname) tv-viewer_main
source $option(root)/data/release_version.tcl

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
		catch {file copy -force "$station_file" "$::option(home)/config/"}
	}
	set confFiles {tv-viewer scheduler scheduled_recordings}
	foreach conf $confFiles {
		if {[file exists "$::env(HOME)/.tv-viewer/backup_folder/$target\/config/$conf\.conf"] == 0} continue
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/$target\/config/$conf\.conf" "$::option(home)/config/"}
	}
	set logFiles {tvviewer scheduler videoplayer}
	foreach log $logFiles {
		if {[file exists "$::env(HOME)/.tv-viewer/backup_folder/$target\/log/$log\.log"] == 0} continue
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/$target\/log/$log\.log" "$::option(home)/log/"}
	}
	set new_version_file [open "$::option(home)/config/tv-viewer-[lindex $version 0]_build[lindex $version 1]\.ver" w]
	close $new_version_file
	puts "$messageFin"
}

set get_installed_version [glob -nocomplain "$::option(home)/config/tv-viewer-*.ver"]
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

#Source agrep, replaces unix grep command.
source $::option(root)/data/agrep.tcl
#Check whether or not tv-viewer is already running.
set status_lock [catch {exec ln -s "[pid]" "$::option(home)/tmp/lockfile.tmp"} resultat_lock]
if { $status_lock != 0 } {
	set linkread [file readlink "$::option(home)/tmp/lockfile.tmp"]
	catch {exec ps -eo "%p"} readpid
	set status_greppid [catch {agrep -w "$readpid" $linkread} resultat_greppid]
	if { $status_greppid != 0 } {
		catch {file delete "$::option(home)/tmp/lockfile.tmp"}
		catch {exec ln -s "[pid]" "$::option(home)/tmp/lockfile.tmp"}
	} else {
		catch {exec ps -p $linkread -o args=} readarg
		set status_grepargDirect [catch {agrep -m "$readarg" "tv-viewer_main.tcl"} resultat_greparg]
		set status_grepargLink [catch {agrep -m "$readarg" "tv-viewer"} resultat_greparg]
		if {$status_grepargDirect != 0 && $status_grepargLink != 0} {
			catch {file delete "$::option(home)/tmp/lockfile.tmp"}
			catch {exec ln -s "[pid]" "$::option(home)/tmp/lockfile.tmp"}
		} else {
			puts "
An instance of TV-Viewer is already running."
			#FIXME - This messageBox is really ugly - Will be changed in the future
			tk_messageBox -icon warning -title "Instance already running" -message "An instance of TV-Viewer is already running.
Otherwise you have to delete the file
$option(home)/.tv-viewer/tmp/lockfile.tmp"
			exit 0
		}
	}
}
unset -nocomplain status_lock resultat_lock linkread status_greppid resultat_greppid readpid status_greparg resultat_greparg readarg read_build

#~ Experimental support for QT and GTK theme.
#~ if {[file exists "/home/saedelaere/Downloads/aweelka-uTileQt-851071c/library/libtileqt0.6.so"]} {
	#~ set auto_path [linsert $auto_path 0 "/home/saedelaere/Downloads/aweelka-uTileQt-851071c/library"]
	#~ package require ttk::theme::tileqt
#~ }
#~ package require ttk::theme::tileqt
#~ set auto_path [linsert $auto_path 0 "/home/saedelaere/Downloads/tile-themes/tile-gtk/library"]
#~ package require ttk::theme::tilegtk
set insertLocal 1
set insertGlob 1
foreach pa $auto_path {
	if {[string match /usr/local/lib $pa]} {
		set insertLocal 0
	}
	if {[string match /usr/lib $pa]} {
		set insertGlob 0
	}
}
if {$insertLocal} {
	if {[file isdirectory /usr/local/lib]} {
		set auto_path [linsert $auto_path 0 "/usr/local/lib"]
	}
}
if {$insertGlob} {
	if {[file isdirectory /usr/lib]} {
		set auto_path [linsert $auto_path 0 "/usr/lib"]
	}
}
unset -nocomplain insertLocal insertGlob pa
puts "loading shared libraries"
set status_tray [catch {package require tktray 1.3.9} result_tktray]
if {$status_tray == 1} {
	puts "
ERROR:  $result_tktray
"
}
#Source autoscroll function for scrollbars and load package autoscroll
source $::option(root)/extensions/autoscroll/autoscroll.tcl
package require autoscroll
namespace import ::autoscroll::autoscroll
#Source calendar widget
source $::option(root)/extensions/callib/callib.tcl
#Append fsdialog to auto_path
set auto_path [linsert $auto_path 0 "$::option(root)/extensions/fsdialog"]
#Source read_config to read all config values
source $::option(root)/data/process_config.tcl
#Source all key sequences
source $::option(root)/data/process_key_file.tcl
#Source start options
source $::option(root)/data/main_command_line_options.tcl
start_options
#It is time to load all config values
process_configRead
process_configMem
process_KeyFile
#Sourcing logfile and launching log process
source $::option(root)/data/log_viewer.tcl
log_viewerCheck
log_writeOutTv 0 "TV-Viewer process PID [pid]"
#Source splash screen
source $::option(root)/data/launch_splash.tcl
#Launching splash screen if wanted.
if {$::option(show_splash) == 1} {
	launch_splash_screen
}
#Source additional ttk themes, plastik and keramik
source "$option(root)/themes/plastik/plastik.tcl"
source "$option(root)/themes/keramik/keramik.tcl"

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
if {[msgcat::mcload $option(root)/msgs] != 1} {
	msgcat::mclocale en
	msgcat::mcload $option(root)/msgs
	puts "$::env(LANG) no translation found"
}
#Source monitor procs
source $::option(root)/data/monitor.tcl
#Source create icons
source $::option(root)/data/create_icons.tcl
#Create all icons for app.
create_icons
#Source error event handler
source $::option(root)/data/error_interp.tcl
#Tell tk to use new error handler
interp bgerror {} [namespace which error_interpUi]


#Source station after message.
source $::option(root)/data/station_after_msg.tcl
#Source alle related functions for station changing.
source $::option(root)/data/chan_zapper.tcl
#Source reading station list
source $::option(root)/data/process_station_file.tcl
#Execute reading of station list
process_StationFile
#Source stream and picqual related stuff.
source $::option(root)/data/main_picqual_stream.tcl
#Source video related functions
source $::option(root)/data/vid_audio.tcl
source $::option(root)/data/vid_callback.tcl
source $::option(root)/data/vid_file_calc.tcl
source $::option(root)/data/vid_playback.tcl
source $::option(root)/data/vid_pmhandler.tcl
source $::option(root)/data/vid_seek.tcl
source $::option(root)/data/vid_slist.tcl
source $::option(root)/data/vid_wm.tcl
#Source tv osd
source $::option(root)/data/vid_osd.tcl
#Source functions to calculate difftime
source $::option(root)/data/difftime.tcl
#Source newsreader ui and update checker.
source $::option(root)/data/main_newsreader.tcl
#Source system tray.
source $::option(root)/data/system_tray.tcl
#Source info toplevel and user guide.
source $::option(root)/data/info_help.tcl
#Source key sequences
source $::option(root)/data/key_sequences.tcl
#Source tooltip
source $::option(root)/data/tooltip.tcl
#Source menu creating procs
source $::option(root)/data/main_menu.tcl
#Source main ui and related functions
source $::option(root)/data/main_frontend.tcl
#Source command socket
source $::option(root)/data/command_socket.tcl
#Source color management toplevel and related functions.
source $::option(root)/data/colorm.tcl
#Source diagnostic routine frontend.
source $::option(root)/data/diag_frontend.tcl
#Source functions to create events and bindings
source $::option(root)/data/event_bind.tcl
#Source station item related stuff.
source $::option(root)/data/station_item.tcl
#Source station editor
source $::option(root)/data/station_edit.tcl
#Source station search
source $::option(root)/data/station_search.tcl
#Source record wizard
source $::option(root)/data/record_wizard.tcl
#Source direct record function
source $::option(root)/data/record_handler.tcl
#Source adding a new recording
source $::option(root)/data/record_add_edit.tcl
#Source remote functions for scheduler
source $::option(root)/data/record_linker.tcl
#Source timeshift
source $::option(root)/data/timeshift.tcl
#Source read and set config values for config-wizard.
source $::option(root)/data/process_config_wizard.tcl
#Source main ui config
source $::option(root)/data/config_wizard.tcl
#Source general options
source $::option(root)/data/config_general.tcl
#Source config options analog
source $::option(root)/data/config_analog.tcl
#Source config options dvb
source $::option(root)/data/config_dvb.tcl
#Source config options video
source $::option(root)/data/config_video.tcl
#Source config options audio
source $::option(root)/data/config_audio.tcl
#Source config options radio
source $::option(root)/data/config_radio.tcl
#Source config options interface
source $::option(root)/data/config_interface.tcl
#Source config options record
source $::option(root)/data/config_record.tcl
#Source config options advanced
source $::option(root)/data/config_advanced.tcl
#Source font chooser dialog
source $::option(root)/data/font_chooser.tcl

#Launching main ui and all things that need to be done now...

cd "$::env(HOME)"

main_frontendUi
