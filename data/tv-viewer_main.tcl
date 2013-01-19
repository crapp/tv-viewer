#!/usr/bin/env wish

#       tv-viewer_main.tcl
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

proc startupCpF {version read_version read_build} {
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
	set confFiles {tv-viewer key-sequences}
	foreach conf $confFiles {
		if {[file exists "$::env(HOME)/.tv-viewer/backup_folder/$target\/config/$conf\.conf"] == 0} continue
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/$target\/config/$conf\.conf" "$::option(home)/config/"}
	}
	set dbFiles {tv-viewer}
	foreach db $dbFiles {
		if {[file exists "$::env(HOME)/.tv-viewer/backup_folder/$target\/config/$db\.sqlite"] == 0} continue
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/$target\/config/$db\.sqlite" "$::option(home)/config/"}
	}
	set logFiles {tvviewer scheduler videoplayer}
	foreach log $logFiles {
		if {[file exists "$::env(HOME)/.tv-viewer/backup_folder/$target\/log/$log\.log"] == 0} continue
		catch {file copy -force "$::env(HOME)/.tv-viewer/backup_folder/$target\/log/$log\.log" "$::option(home)/log/"}
	}
	set new_version_file [open "$::option(home)/config/tv-viewer-[lindex $version 0]_build[lindex $version 1]\.ver" w]
	close $new_version_file
	set ::init(restartLock) 1
	set ::main(upgrade) 1
	puts "$messageFin"
}

proc startupCheckVer {} {
	set ::main(upgrade) 0
	set get_installed_version [glob -nocomplain "$::option(home)/config/tv-viewer-*.ver"]
	if {[string trim $get_installed_version] != {}} {
		set normalized_version_file [file normalize "$get_installed_version"]
		set status_regexp_version [regexp {tv-viewer-([\d.ab]+)\_build} "$normalized_version_file" <-> read_version]
		if {$status_regexp_version == 1} {
			set status_regexp_version2 [regexp {_build([\d]+)\.ver} "$normalized_version_file" <-> read_build]
			if {[package vcompare [lindex $::option(release_version) 0] $read_version] != 0} {
				puts "
You've installed a new version of TV-Viewer."
	#			Upgrade or downgrade?
				if {[package vcompare [lindex $::option(release_version) 0] $read_version] == -1} {
	#				Downgrade
					puts "This is a downgrade!"
					startupCpF "$::option(release_version)" $read_version $read_build
				}
				if {[package vcompare [lindex $::option(release_version) 0] $read_version] == 1} {
	#			Upgrade
					puts "This is an upgrade."
					startupCpF "$::option(release_version)" $read_version $read_build
				}
			} else {
				if {[lindex $::option(release_version) 1] != $read_build} {
					puts "
You've installed a new version of TV-Viewer."
					if {[lindex $::option(release_version) 1] < $read_build} {
						puts "This is a downgrade!"
						startupCpF "$::option(release_version)" $read_version $read_build
					}
					if {[lindex $::option(release_version) 1] > $read_build} {
						puts "This is an upgrade."
						startupCpF "$::option(release_version)" $read_version $read_build
					}
				}
			}
		} else {
			# Check for old version system.
			set status_regexp_version [regexp {tv-viewer-([\d.ab]+)\.ver} "$normalized_version_file" <-> read_version]
			if {[package vcompare [lindex $::option(release_version) 0] $read_version] != 0} {
				puts "
You've installed a new version of TV-Viewer."
	#			Upgrade or downgrade?
				if {[package vcompare [lindex $::option(release_version) 0] $read_version] == -1} {
	#				Downgrade
					puts "This is a downgrade!"
					startupCpF "$::option(release_version)" $read_version nobuild
				}
				if {[package vcompare [lindex $::option(release_version) 0] $read_version] == 1} {
	#				Upgrade
					puts "This is an upgrade."
					startupCpF "$::option(release_version)" $read_version nobuild
				}
			} else {
				#This must be a new version because of new build concept.
				puts "
You've installed a new version of TV-Viewer."
				puts "This is an upgrade."
				startupCpF "$::option(release_version)" $read_version nobuild
			}
		}
	} else {
		puts "
You've installed a new version of TV-Viewer."
		if {[file isdirectory "$::env(HOME)/.tv-viewer/"]} {
			puts "Old version could not be recognized."
			startupCpF "$::option(release_version)" unknown unknown
		} else {
			file mkdir "$::env(HOME)/.tv-viewer/" "$::env(HOME)/.tv-viewer/config/" "$::env(HOME)/.tv-viewer/tmp/" "$::env(HOME)/.tv-viewer/log/"
			set new_version_file [open "$::env(HOME)/.tv-viewer/config/tv-viewer-[lindex $::option(release_version) 0]_build[lindex $::option(release_version) 1]\.ver" w]
			close $new_version_file
			set ::main(upgrade) 1
		}
	}
	if {$::init(restartLock)} {
		#restart init_lock because there was no config directory or config \
		was rewritten because of up-, downgrade
		init_lock "lockfile.tmp" "tv-viewer_main.tcl" "tv-viewer"
	}
}

wm withdraw .

set option(root) "[file dirname [file dirname [file dirname [file normalize [file join [info script] bogus]]]]]"
set option(home) "$::env(HOME)/.tv-viewer"
set option(appname) tv-viewer_main

source $::option(root)/data/init.tcl

init_pkgReq [list 2 3 4]
init_testRoot
# source agrep here because we need to check lockfile before sourcing \
  all files
source $::option(root)/data/agrep.tcl
init_lock "lockfile.tmp" "tv-viewer_main.tcl" "tv-viewer"
init_autoPath
init_tclKit
init_source "$::option(root)/data" "all"

startupCheckVer
#Source autoscroll function for scrollbars and load package autoscroll
source $::option(root)/extensions/autoscroll/autoscroll.tcl
package require autoscroll
namespace import ::autoscroll::autoscroll
#Source calendar widget
source $::option(root)/extensions/callib/callib.tcl
set ::auto_path [linsert $::auto_path 0 "$::option(root)/extensions/fsdialog"]
start_options
#It is time to load all config values
process_configRead
process_configMem
log_viewerPrepareFileSocket tvviewer.log ::log(tvAppend) log_size_tvviewer
log_viewerPrepareFileSocket videoplayer.log ::log(mplAppend) log_size_mplay
log_writeOut ::log(tvAppend) 0 "TV-Viewer process PID [pid]"
if {$::option(show_splash) == 1} {
	after 10 {launch_splash_screen}
}

init_themes
init_langSupport

# Process key file now because we need language support.
process_KeyFile 1
#Create all icons for app.
create_icons
#Tell tk to use new error handler
interp bgerror {} [namespace which error_interpUi]
#Execute reading of station list
process_StationFile ::log(tvAppend)
#Connect to database
db_interfaceInit
puts "This is TV-Viewer [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1] ..."
#FIXME cding into the users home directory is a hack so the screenshots can be saved somewhere.
cd "$::env(HOME)"
#Launching main ui and all things that need to be done now...
main_frontendUi


#~ Experimental support for QT and GTK theme.
#~ if {[file exists "/home/saedelaere/Downloads/aweelka-uTileQt-851071c/library/libtileqt0.6.so"]} {
	#~ set auto_path [linsert $auto_path 0 "/home/saedelaere/Downloads/aweelka-uTileQt-851071c/library"]
	#~ package require ttk::theme::tileqt
#~ }
#~ package require ttk::theme::tileqt
#~ set auto_path [linsert $auto_path 0 "/home/saedelaere/Downloads/tile-themes/tile-gtk/library"]
#~ package require ttk::theme::tilegtk
