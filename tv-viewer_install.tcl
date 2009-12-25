#!/usr/bin/env tclsh

#       tv-viewer_install.tcl
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


set where_is "[file dirname [file normalize [info script]]]"
set target /usr/local/share
set printchan stdout

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

set option(release_version) {0.8.1 54 25.12.2009}
array set start_options {--uninstall 0 --target 0 --nodebug 0 --manpath 0 --nodepcheck 0 --help 0}
foreach command_argument $argv {
	if {[string first = $command_argument] == -1 } {
		set i [string first - $command_argument]
		set key $command_argument
		set start_options($key) 1
	} else {
		set i [string first = $command_argument]
		set key [string range $command_argument 0 [expr {$i-1}]]
		set value [string range $command_argument [expr {$i+1}] end]
		set start_options($key) 1
		set start_values($key) $value
	}
}
if {[array size start_options] != 6} {
	puts "
TV-Viewer [lindex $option(release_version) 0] Build [lindex $option(release_version) 1]
	
Unkown option(s): $argv

Possible options are:

  --uninstall     Uninstalls TV-Viewer.
  --nodebug       Do not print messages of progress to stdout.
  --nodepcheck    Skip dependencies ckeck.
  --target=PATH   Provide a path for installation (standard /usr/local/share).
  --manpath=PATH  Provide a path for man pages (standard /usr/local/share/man/man1).
 "
exit 0
}

if {$start_options(--help)} {
	puts "
TV-Viewer [lindex $option(release_version) 0] Build [lindex $option(release_version) 1]
	
Possible options are:

  --uninstall     Uninstalls TV-Viewer.
  --nodebug       Do not print messages of progress to stdout.
  --nodepcheck    Skip dependencies ckeck.
  --target=PATH   Provide a path for installation (standard /usr/local/share).
  --manpath=PATH  Provide a path for man pages (standard /usr/local/share/man/man1).
  --help          Show this help.
 "
exit 0
}

if {$start_options(--nodebug)} {
	set printchan [open /dev/null a]
	fconfigure $::printchan -blocking no -buffering line
}

if {$start_options(--target)} {
	puts $::printchan "
Target set to $start_values(--target)"
	set target $start_values(--target)
}

if {$start_options(--uninstall)} {
	puts $::printchan "

TV-Viewer will be uninstalled..."
after 1000
	if {[file isdirectory "$target/tv-viewer/"]} {
		set status_uninstall [catch {file delete -force -- pathname "$target/tv-viewer/"} resultat_uninstall]
		if { $status_uninstall != 0} {
			puts $::printchan "
Can't uninstall TV-Viewer.
Error message: $resultat_uninstall

Folder is owned by [file attributes $target/tv-viewer/ -owner].
You are $::tcl_platform(user).
"
			exit 1
		} else {
			catch {file delete -force "/usr/bin/tv-viewer" "/usr/bin/tv-viewer_lirc" "/usr/bin/tv-viewer_diag" "/usr/bin/tv-viewer_scheduler" "$target/applications/tv-viewer.desktop" "$target/pixmaps/tv-viewer.png" "/usr/local/man/man1/tv-viewer.1.gz"}
			
			puts $::printchan "
TV-Viewer has been uninstalled successfully.

Config directory is still present in your home
directory.

Please delete manually.
"
			exit 0
		}
	} else {
		puts $::printchan "
TV-Viewer is not installed!
"
		exit 1
	}
}

	puts $::printchan "\n \n #########################################################################"
	puts $::printchan " ####                                                                 ####"
	puts $::printchan " ####           Installation of TV-Viewer [lindex $option(release_version) 0] Build [lindex $option(release_version) 1]              ####"
	puts $::printchan " ####                                                                 ####"
	puts $::printchan " #########################################################################"

after 200

proc agrep {switch input modifier} {
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
		return -code 1 "agrep could not find $modifier in $input"
	}
}

proc install_depCheck {where_is target} {
	puts $::printchan "
Checking dependencies...
"
	after 100
	puts -nonewline $::printchan "Tk "
	set status_tk [catch {package require Tk} version_tk]
	set i 0
	while { $i != 3 } {
		puts -nonewline $::printchan "*"
		flush stdout
		after 100
		incr i
	}
	if {$status_tk == 0} {
		if {[package vsatisfies $version_tk 8.5]} {
			puts $::printchan "\033\[0;1;32m OK\033\[0m"
		} else {
			puts $::printchan "\033\[0;1;31m FAILED\033\[0m"
			puts $::printchan "
TV-Viewer needs Tk >= 8.5 found $version_tk.
See the README for system requirements.
Installer EXIT 1"
			exit 1
		}
	} else {
		puts $::printchan "\033\[0;1;31m FAILED\033\[0m"
		puts $::printchan "
TV-Viewer needs Tk >= 8.5
See the README for system requirements.
Installer EXIT 1"
		exit 1
	}
	
	set dependencies [dict create ivtv-tune ivtv-utils v4l2-ctl ivtv-utils mplayer MPlayer xdg-email xdg-utils xdg-open xdg-utils xdg-screensaver xdg-utils]
	
	foreach {key elem} [dict get $dependencies] {
		puts -nonewline $::printchan "$key "
		set i 0
		while { $i != 3 } {
			puts -nonewline $::printchan "*"
			flush stdout
			after 100
			incr i
		}
		if {[string trim [auto_execok $key]] != {}} {
			puts $::printchan "\033\[0;1;32m OK\033\[0m"
		} else {
			puts $::printchan "\033\[0;1;31m FAILED\033\[0m"
			puts $::printchan "
TV-Viewer needs $elem
See the README for system requirements.
Installer EXIT 1"
			exit 1
		}
	}
	
	puts $::printchan "
Checking for optional dependencies...
"
	set opt_dependencies [dict create irexec lirc]
	
	foreach {key elem} [dict get $opt_dependencies] {
		puts -nonewline $::printchan "$key "
		set i 0
		while { $i != 3 } {
			puts -nonewline $::printchan "*"
			flush stdout
			after 100
			incr i
		}
		if {[string trim [auto_execok $key]] != {}} {
			puts $::printchan "\033\[0;1;32m OK\033\[0m"
		} else {
			puts $::printchan "\033\[0;1;31m FAILED\033\[0m"
			puts $::printchan "
Could not detect lirc.
You won't be able to use a remote control.
"
			after 1250
		}
	}
	
	if {[package vsatisfies [info patchlevel] 8.6] == 0} {
		puts -nonewline $::printchan "tkimg "
		set i 0
		while { $i != 3 } {
			puts -nonewline $::printchan "*"
			flush stdout
			after 100
			incr i
		}
		set status_tkimg [catch {package require Img} tkimg_ver]
		if {$status_tkimg == 0} {
			puts $::printchan "\033\[0;1;32m OK\033\[0m"
		} else {
			puts $::printchan "\033\[0;1;31m FAILED\033\[0m"
			puts $::printchan "
Could not detect tkimg (libtk-img).
No support for high resolution PNG icons."
			after 1250
		}
	}
}

proc install_createFolders {where_is target} {
	if {[file isdirectory "$target/tv-viewer"]} {
		puts $::printchan "
Found a previous installation of TV-Viewer.
Erasing old files..."
		set status_file [catch {file delete -force -- pathname "$target/tv-viewer/"} resultat_file]
		if { $status_file != 0 } {
			puts $::printchan "
Can't erase folders.
Error message: $resultat_file

Folder is owned by [file attributes $target/tv-viewer/ -owner].
You are $::tcl_platform(user).
	"
			exit 1
		} else {
			file mkdir "$target/tv-viewer/" "$target/tv-viewer/data/" "$target/tv-viewer/extensions/" "$target/tv-viewer/extensions/autoscroll/" "$target/tv-viewer/extensions/callib/" "$target/tv-viewer/extensions/fsdialog/" "$target/tv-viewer/extensions/tktray/" "$target/tv-viewer/extensions/tktray/32/" "$target/tv-viewer/extensions/tktray/64/" "$target/tv-viewer/icons/" "$target/tv-viewer/icons/16x16/" "$target/tv-viewer/icons/22x22/" "$target/tv-viewer/icons/32x32/" "$target/tv-viewer/icons/extras/" "$target/tv-viewer/license/" "$target/tv-viewer/man/" "$target/tv-viewer/msgs/" "$target/tv-viewer/msgs/de/" "$target/tv-viewer/msgs/en/" "$target/tv-viewer/shortcuts" "$target/tv-viewer/themes/" "$target/tv-viewer/themes/plastik/" "$target/tv-viewer/themes/plastik/plastik/" "$target/tv-viewer/themes/keramik/" "$target/tv-viewer/themes/keramik/keramik/" "$target/tv-viewer/themes/keramik/keramik_alt/"
			puts $::printchan "
Creating folders..."
		}
	} else {
		set status_file [catch {file mkdir "$target/tv-viewer/" "$target/tv-viewer/data/" "$target/tv-viewer/extensions/" "$target/tv-viewer/extensions/autoscroll/" "$target/tv-viewer/extensions/callib/" "$target/tv-viewer/extensions/fsdialog/" "$target/tv-viewer/extensions/tktray/" "$target/tv-viewer/extensions/tktray/32/" "$target/tv-viewer/extensions/tktray/64/" "$target/tv-viewer/icons/" "$target/tv-viewer/icons/16x16/" "$target/tv-viewer/icons/22x22/" "$target/tv-viewer/icons/32x32/" "$target/tv-viewer/icons/extras/" "$target/tv-viewer/license/" "$target/tv-viewer/man/" "$target/tv-viewer/msgs/" "$target/tv-viewer/msgs/de/" "$target/tv-viewer/msgs/en/" "$target/tv-viewer/shortcuts" "$target/tv-viewer/themes/" "$target/tv-viewer/themes/plastik/" "$target/tv-viewer/themes/plastik/plastik/" "$target/tv-viewer/themes/keramik/" "$target/tv-viewer/themes/keramik/keramik/" "$target/tv-viewer/themes/keramik/keramik_alt/"} resultat_file]
		if { $status_file != 0 } {
			puts $::printchan "
Can't create necessary folders.
Error message: $resultat_file

You probably have to be root.
	"
			exit 1
		} else {
					puts $::printchan "
Creating folders..."
		}
	}
}

proc install_checkScheduler {where_is target} {
	set status_schedlinkread [catch {file readlink "$::env(HOME)/.tv-viewer/tmp/scheduler_lockfile.tmp"} resultat_schedlinkread]
	if {$status_schedlinkread == 0} {
		catch {exec ps -eo "%p"} read_ps
		set status_greppid_sched [catch {agrep -w "$read_ps" $resultat_schedlinkread} resultat_greppid_sched]
		if { $status_greppid_sched == 0 } {
			puts $::printchan "
Scheduler is running, will stop it."
			after 1000
			catch {exec kill $resultat_schedlinkread}
			catch {file delete "$::option(where_is_home)/tmp/scheduler_lockfile.tmp"}
		}
	}
}

proc install_copyData {where_is target} {
	set filelist [lsort [glob "$where_is/data/*"]]
	foreach dfile [split [file normalize [join $filelist \n]] \n] {
		set status_dfile [catch {file copy -force "$dfile" "$target/tv-viewer/data/"} resultat_dfile]
		if { $status_dfile != 0 } {
			puts $::printchan "
Could not copy file: $dfile

Error message: $resultat_dfile
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/data/[lindex [file split $dfile] end]"
			if {[string match *diag_runtime* "$target/tv-viewer/data/[lindex [file split $dfile] end]"] || [string match *lirc_emitter* "$target/tv-viewer/data/[lindex [file split $dfile] end]"] || [string match *record_scheduler* "$target/tv-viewer/data/[lindex [file split $dfile] end]"] || [string match *recorder* "$target/tv-viewer/data/[lindex [file split $dfile] end]"] || [string match *tv-viewer_main* "$target/tv-viewer/data/[lindex [file split $dfile] end]"]} {
				set status_permissions_dfile [catch {file attributes "$target/tv-viewer/data/[lindex [file split $dfile] end]" -permissions rwxr-xr-x} resultat_permissions_dfile]
			} else {
				set status_permissions_dfile [catch {file attributes "$target/tv-viewer/data/[lindex [file split $dfile] end]" -permissions rw-r--r--} resultat_permissions_dfile]
			}
			if {$status_permissions_dfile != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/data/[lindex [file split $dfile] end]

Error message: $resultat_permissions_dfile"
				exit 1
			}
		}
	}
	
	if {[file isdirectory "$target/applications"] == 0} {
		file mkdir "$target/applications"
	}
	set status_desktop [catch {file copy -force "$where_is/data/tv-viewer.desktop" "$target/applications/"} result_desktop]
	if { $status_desktop != 0 } {
		puts $::printchan "
Could not copy file: $where_is/data/tv-viewer.desktop

Error message: $result_desktop
	"
		exit 1
	} else {
		puts $::printchan "$target/applications/tv-viewer.desktop"
		set status_permissions_desktop [catch {file attributes "$target/applications/tv-viewer.desktop" -permissions rw-r--r--} resultat_permissions_desktop]
		if {$status_permissions_desktop != 0} {
			puts $::printchan "
Could not change permissions for: $target/applications/tv-viewer.desktop

Error message: $resultat_permissions_desktop"
			exit 1
		}
	}
}

proc install_copyExtensions {where_is target} {
	set filelist [lsort [glob "$where_is/extensions/tktray/32/*"]]
	foreach tfile32 [split [file normalize [join $filelist \n]] \n] {
		set status_tfile32 [catch {file copy -force "$tfile32" "$target/tv-viewer/extensions/tktray/32/"} resultat_tfile32]
		if { $status_tfile32 != 0 } {
			puts $::printchan "
Could not copy file: $tfile32

Error message: $resultat_tfile32
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/extensions/tktray/32/[lindex [file split $tfile32] end]"
			set status_permissions_tfile32 [catch {file attributes "$target/tv-viewer/extensions/tktray/32/[lindex [file split $tfile32] end]" -permissions rwxr-xr-x} resultat_permissions_tfile32]
			if {$status_permissions_tfile32 != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/extensions/tktray/32/[lindex [file split $tfile32] end]

Error message: $resultat_permissions_tfile32"
				exit 1
			}
		}
	}

	set filelist [lsort [glob "$where_is/extensions/tktray/64/*"]]
	foreach tfile64 [split [file normalize [join $filelist \n]] \n] {
		set status_tfile64 [catch {file copy -force "$tfile64" "$target/tv-viewer/extensions/tktray/64/"} resultat_tfile64]
		if { $status_tfile64 != 0 } {
			puts $::printchan "
Could not copy file: $tfile64

Error message: $resultat_tfile64
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/extensions/tktray/64/[lindex [file split $tfile64] end]"
			set status_permissions_tfile64 [catch {file attributes "$target/tv-viewer/extensions/tktray/64/[lindex [file split $tfile64] end]" -permissions rwxr-xr-x} resultat_permissions_tfile64]
			if {$status_permissions_tfile64 != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/extensions/tktray/64/[lindex [file split $tfile64] end]

Error message: $resultat_permissions_tfile64"
				exit 1
			}
		}
	}

	set filelist [lsort [glob "$where_is/extensions/autoscroll/*"]]
	foreach aufile [split [file normalize [join $filelist \n]] \n] {
		set status_aufile [catch {file copy -force "$aufile" "$target/tv-viewer/extensions/autoscroll/"} resultat_aufile]
		if { $status_aufile != 0 } {
			puts $::printchan "
Could not copy file: $aufile

Error message: $resultat_aufile
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/extensions/autoscroll/[lindex [file split $aufile] end]"
			set status_permissions_aufile [catch {file attributes "$target/tv-viewer/extensions/autoscroll/[lindex [file split $aufile] end]" -permissions rwxr-xr-x} resultat_permissions_aufile]
			if {$status_permissions_aufile != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/extensions/autoscroll/[lindex [file split $aufile] end]

Error message: $resultat_permissions_aufile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob "$where_is/extensions/callib/*"]]
	foreach calfile [split [file normalize [join $filelist \n]] \n] {
		set status_calfile [catch {file copy -force "$calfile" "$target/tv-viewer/extensions/callib/"} resultat_calfile]
		if { $status_calfile != 0 } {
			puts $::printchan "
Could not copy file: $calfile

Error message: $resultat_calfile
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/extensions/callib/[lindex [file split $calfile] end]"
			set status_permissions_calfile [catch {file attributes "$target/tv-viewer/extensions/callib/[lindex [file split $calfile] end]" -permissions rwxr-xr-x} resultat_permissions_calfile]
			if {$status_permissions_calfile != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/extensions/callib/[lindex [file split $calfile] end]

Error message: $resultat_permissions_calfile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob "$where_is/extensions/fsdialog/*"]]
	foreach fsfile [split [file normalize [join $filelist \n]] \n] {
		set status_fsfile [catch {file copy -force "$fsfile" "$target/tv-viewer/extensions/fsdialog/"} resultat_fsfile]
		if { $status_fsfile != 0 } {
			puts $::printchan "
Could not copy file: $fsfile

Error message: $resultat_fsfile
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/extensions/fsdialog/[lindex [file split $fsfile] end]"
			set status_permissions_fsfile [catch {file attributes "$target/tv-viewer/extensions/fsdialog/[lindex [file split $fsfile] end]" -permissions rwxr-xr-x} resultat_permissions_fsfile]
			if {$status_permissions_fsfile != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/extensions/fsdialog/[lindex [file split $fsfile] end]

Error message: $resultat_permissions_fsfile"
				exit 1
			}
		}
	}
}

proc install_copyIcons {where_is target} {
	set filelist [lsort [glob "$where_is/icons/16x16/*"]]
	foreach ifile [split [file normalize [join $filelist \n]] \n] {
		set status_ifile [catch {file copy -force "$ifile" "$target/tv-viewer/icons/16x16/"} resultat_ifile]
		if { $status_ifile != 0 } {
			puts $::printchan "
Could not copy file: $ifile

Error message: $resultat_ifile
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/icons/16x16/[lindex [file split $ifile] end]"
			set status_permissions_ifile [catch {file attributes "$target/tv-viewer/icons/16x16/[lindex [file split $ifile] end]" -permissions rw-r--r--} resultat_permissions_ifile]
			if {$status_permissions_ifile != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/icons/16x16/[lindex [file split $ifile] end]

Error message: $resultat_permissions_ifile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob "$where_is/icons/22x22/*"]]
	foreach ifile [split [file normalize [join $filelist \n]] \n] {
		set status_ifile [catch {file copy -force "$ifile" "$target/tv-viewer/icons/22x22/"} resultat_ifile]
		if { $status_ifile != 0 } {
			puts $::printchan "
Could not copy file: $ifile

Error message: $resultat_ifile
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/icons/22x22/[lindex [file split $ifile] end]"
			set status_permissions_ifile [catch {file attributes "$target/tv-viewer/icons/22x22/[lindex [file split $ifile] end]" -permissions rw-r--r--} resultat_permissions_ifile]
			if {$status_permissions_ifile != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/icons/22x22/[lindex [file split $ifile] end]

Error message: $resultat_permissions_ifile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob "$where_is/icons/32x32/*"]]
	foreach ifile [split [file normalize [join $filelist \n]] \n] {
		set status_ifile [catch {file copy -force "$ifile" "$target/tv-viewer/icons/32x32/"} resultat_ifile]
		if { $status_ifile != 0 } {
			puts $::printchan "
Could not copy file: $ifile

Error message: $resultat_ifile
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/icons/32x32/[lindex [file split $ifile] end]"
			set status_permissions_ifile [catch {file attributes "$target/tv-viewer/icons/32x32/[lindex [file split $ifile] end]" -permissions rw-r--r--} resultat_permissions_ifile]
			if {$status_permissions_ifile != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/icons/32x32/[lindex [file split $ifile] end]

Error message: $resultat_permissions_ifile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob "$where_is/icons/extras/*"]]
	foreach ifile [split [file normalize [join $filelist \n]] \n] {
		set status_ifile [catch {file copy -force "$ifile" "$target/tv-viewer/icons/extras/"} resultat_ifile]
		if { $status_ifile != 0 } {
			puts $::printchan "
Could not copy file: $ifile

Error message: $resultat_ifile
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/icons/extras/[lindex [file split $ifile] end]"
			set status_permissions_ifile [catch {file attributes "$target/tv-viewer/icons/extras/[lindex [file split $ifile] end]" -permissions rw-r--r--} resultat_permissions_ifile]
			if {$status_permissions_ifile != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/icons/extras/[lindex [file split $ifile] end]

Error message: $resultat_permissions_ifile"
				exit 1
			}
		}
	}

	if {[file isdirectory "$target/pixmaps"] == 0} {
		file mkdir "$target/pixmaps"
	}
	set status_tvicon [catch {file copy -force "$where_is/icons/extras/tv-viewer_icon.png" "$target/pixmaps/"} result_tvicon]
	if { $status_tvicon != 0 } {
		puts $::printchan "
Could not copy file: $where_is/icons/extras/tv-viewer_icon.png

Error message: $result_tvicon
	"
		exit 1
	} else {
		puts $::printchan "$target/pixmaps/tv-viewer_icon.png"
		set status_permissions_tvicon [catch {file attributes "$target/pixmaps/tv-viewer_icon.png" -permissions rw-r--r--} resultat_permissions_tvicon]
		if {$status_permissions_tvicon != 0} {
			puts $::printchan "
Could not change permissions for: $target/pixmaps/tv-viewer_icon.png

Error message: $resultat_permissions_tvicon"
			exit 1
		}
		catch {file rename -force "$target/pixmaps/tv-viewer_icon.png" "$target/pixmaps/tv-viewer.png"}
	}
}

proc install_copyLicense {where_is target} {
	set filelist [glob "$where_is/license/*"]
	foreach lfile $filelist {
		set status_file_lic [catch {file copy -force "$lfile" "$target/tv-viewer/license/"} resultat_file_lic]
		if { $status_file_lic != 0 } {
			puts $::printchan "
Could not copy file: $lfile

Error message: $resultat_file_lic
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/license/[lindex [file split $lfile] end]"
			set status_permissions_lfile [catch {file attributes "$target/tv-viewer/license/[lindex [file split $lfile] end]" -permissions rw-r--r--} resultat_permissions_lfile]
			if {$status_permissions_lfile != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/license/[lindex [file split $lfile] end]

Error message: $resultat_permissions_lfile"
				exit 1
			}
		}
	}
}

proc install_copyMan {where_is target} {
	if {$::start_options(--manpath)} {
		set manpath $::start_values(--manpath)
	} else {
		set manpath /usr/local/man
	}
	if {[file isdirectory "$manpath"] == 0} {
		file mkdir "$manpath"
	}
	if {[file isdirectory "$manpath/man1"] == 0} {
		file mkdir "$manpath/man1"
	}
	set status_file_man [catch {file copy -force "$where_is/man/tv-viewer.1.gz" "$manpath/man1/"} resultat_file_man]
	if { $status_file_man != 0 } {
		puts $::printchan "
Could not copy file: $where_is/man/tv-viewer.1.gz

Error message: $resultat_file_man
"
		exit 1
	}
	puts $::printchan "$manpath/man1/tv-viewer.1.gz"
}

proc install_copyMsgs {where_is target} {
	set filelist [lsort [glob -directory "$where_is/msgs" *.msg]]
	foreach mfile [split [file normalize [join $filelist \n]] \n] {
		set status_mfile [catch {file copy -force "$mfile" "$target/tv-viewer/msgs/"} resultat_mfile]
		if { $status_mfile != 0 } {
			puts $::printchan "
Could not copy file: $mfile

Error message: $resultat_mfile
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/msgs/[lindex [file split $mfile] end]"
			set status_permissions_mfile [catch {file attributes "$target/tv-viewer/msgs/[lindex [file split $mfile] end]" -permissions rw-r--r--} resultat_permissions_mfile]
			if {$status_permissions_mfile != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/msgs/[lindex [file split $mfile] end]

Error message: $resultat_permissions_mfile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob -directory "$where_is/msgs/de" *.de]]
	foreach defile [split [file normalize [join $filelist \n]] \n] {
		set status_defile [catch {file copy -force "$defile" "$target/tv-viewer/msgs/de/"} resultat_defile]
		if { $status_defile != 0 } {
			puts $::printchan "
	Could not copy file: $defile

	Error message: $resultat_defile
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/msgs/de/[lindex [file split $defile] end]"
			set status_permissions_defile [catch {file attributes "$target/tv-viewer/msgs/de/[lindex [file split $defile] end]" -permissions rw-r--r--} resultat_permissions_defile]
			if {$status_permissions_defile != 0} {
				puts $::printchan "
	Could not change permissions for: $target/tv-viewer/msgs/de/[lindex [file split $defile] end]

	Error message: $resultat_permissions_defile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob -directory "$where_is/msgs/en" *.en]]
	foreach enfile [split [file normalize [join $filelist \n]] \n] {
		set status_enfile [catch {file copy -force "$enfile" "$target/tv-viewer/msgs/en/"} resultat_enfile]
		if { $status_enfile != 0 } {
			puts $::printchan "
	Could not copy file: $enfile

	Error message: $resultat_enfile
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/msgs/en/[lindex [file split $enfile] end]"
			set status_permissions_enfile [catch {file attributes "$target/tv-viewer/msgs/en/[lindex [file split $enfile] end]" -permissions rw-r--r--} resultat_permissions_enfile]
			if {$status_permissions_enfile != 0} {
				puts $::printchan "
	Could not change permissions for: $target/tv-viewer/msgs/en/[lindex [file split $enfile] end]

	Error message: $resultat_permissions_enfile"
				exit 1
			}
		}
	}
}

proc install_copyShortcuts {where_is target} {
	set filelist [glob "$where_is/shortcuts/*"]
	foreach sfile $filelist {
		set status_file_cut [catch {file copy -force "$sfile" "$target/tv-viewer/shortcuts/"} resultat_file_cut]
		if { $status_file_cut != 0 } {
			puts $::printchan "
Could not copy file: $sfile

Error message: $resultat_file_cut
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/shortcuts/[lindex [file split $sfile] end]"
			set status_permissions_sfile [catch {file attributes "$target/tv-viewer/shortcuts/[lindex [file split $sfile] end]" -permissions rw-r--r--} resultat_permissions_sfile]
			if {$status_permissions_sfile != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/shortcuts/[lindex [file split $lfile] end]

Error message: $resultat_permissions_sfile"
				exit 1
			}
		}
	}
}

proc install_copyThemes {where_is target} {
	set filelist [glob "$where_is/themes/plastik/*.tcl"]
	foreach plastik [split [file normalize [join $filelist \n]] \n] {
		set status_file_plastik [catch {file copy -force "$plastik" "$target/tv-viewer/themes/plastik/"} resultat_file_plastik]
		if { $status_file_plastik != 0 } {
			puts $::printchan "
Could not copy file: $plastik

Error message: $resultat_file_plastik
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/themes/plastik/[lindex [file split $plastik] end]"
			set status_permissions_plastik [catch {file attributes "$target/tv-viewer/themes/plastik/[lindex [file split $plastik] end]" -permissions rwxr-xr-x} resultat_permissions_plastik]
			if {$status_permissions_plastik != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/themes/plastik/[lindex [file split $plastik] end]

Error message: $resultat_permissions_plastik"
				exit 1
			}
		}
	}

	set filelist [glob "$where_is/themes/plastik/plastik/*.gif"]
	foreach plastik [split [file normalize [join $filelist \n]] \n] {
		set status_file_plastik [catch {file copy -force "$plastik" "$target/tv-viewer/themes/plastik/plastik/"} resultat_file_plastik]
		if { $status_file_plastik != 0 } {
			puts $::printchan "
Could not copy file: $plastik

Error message: $resultat_file_plastik
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/themes/plastik/[lindex [file split $plastik] end]"
			set status_permissions_plastik [catch {file attributes "$target/tv-viewer/themes/plastik/plastik/[lindex [file split $plastik] end]" -permissions rw-r--r--} resultat_permissions_plastik]
			if {$status_permissions_plastik != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/themes/plastik/plastik/[lindex [file split $plastik] end]

Error message: $resultat_permissions_plastik"
				exit 1
			}
		}
	}

	set filelist [glob "$where_is/themes/keramik/*.tcl"]
	foreach keramik [split [file normalize [join $filelist \n]] \n] {
		set status_file_keramik [catch {file copy -force "$keramik" "$target/tv-viewer/themes/keramik/"} resultat_file_keramik]
		if { $status_file_keramik != 0 } {
			puts $::printchan "
Could not copy file: $keramik

Error message: $resultat_file_keramik
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/themes/keramik/[lindex [file split $keramik] end]"
			set status_permissions_keramik [catch {file attributes "$target/tv-viewer/themes/keramik/[lindex [file split $keramik] end]" -permissions rwxr-xr-x} resultat_permissions_keramik]
			if {$status_permissions_keramik != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/themes/keramik/[lindex [file split $keramik] end]

Error message: $resultat_permissions_keramik"
				exit 1
			}
		}
	}

	set filelist [glob "$where_is/themes/keramik/keramik/*.gif"]
	foreach keramik [split [file normalize [join $filelist \n]] \n] {
		set status_file_keramik [catch {file copy -force "$keramik" "$target/tv-viewer/themes/keramik/keramik/"} resultat_file_keramik]
		if { $status_file_keramik != 0 } {
			puts $::printchan "
Could not copy file: $keramik

Error message: $resultat_file_keramik
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/themes/keramik/keramik/[lindex [file split $keramik] end]"
			set status_permissions_keramik [catch {file attributes "$target/tv-viewer/themes/keramik/keramik/[lindex [file split $keramik] end]" -permissions rwxr-xr-x} resultat_permissions_keramik]
			if {$status_permissions_keramik != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/themes/keramik/keramik/[lindex [file split $keramik] end]

Error message: $resultat_permissions_keramik"
				exit 1
			}
		}
	}

	set filelist [glob "$where_is/themes/keramik/keramik_alt/*.gif"]
	foreach keramik [split [file normalize [join $filelist \n]] \n] {
		set status_file_keramik [catch {file copy -force "$keramik" "$target/tv-viewer/themes/keramik/keramik_alt/"} resultat_file_keramik]
		if { $status_file_keramik != 0 } {
			puts $::printchan "
Could not copy file: $keramik

Error message: $resultat_file_keramik
	"
			exit 1
		} else {
			puts $::printchan "$target/tv-viewer/themes/keramik/keramik_alt/[lindex [file split $keramik] end]"
			set status_permissions_keramik [catch {file attributes "$target/tv-viewer/themes/keramik/keramik_alt/[lindex [file split $keramik] end]" -permissions rwxr-xr-x} resultat_permissions_keramik]
			if {$status_permissions_keramik != 0} {
				puts $::printchan "
Could not change permissions for: $target/tv-viewer/themes/keramik/keramik_alt/[lindex [file split $keramik] end]

Error message: $resultat_permissions_keramik"
				exit 1
			}
		}
	}
}

proc install_createSymbolic {where_is target} {
	catch {file delete -force "/usr/bin/tv-viewer" "/usr/bin/tv-viewer_diag" "/usr/bin/tv-viewer_lirc" "/usr/bin/tv-viewer_scheduler"}
	if {"$target" != "/usr/local/share"} {
		set binpath "[file dirname $target]/bin"
		if {[file isdirectory "$binpath"] == 0} {
			file mkdir "$binpath"
		}
		set bintarget /usr/share
	} else {
		set binpath /usr/bin
		set bintarget $target
	}
	#~ set status_symbolic [catch {file link -symbolic "$binpath/tv-viewer" "$bintarget/tv-viewer/data/tv-viewer_main.sh"} resultat_symbolic]
	catch {exec ln -s "$bintarget/tv-viewer/data/tv-viewer_main.sh" "$binpath/tv-viewer"}
	set status_symbolic [catch {file link "$binpath/tv-viewer"} resultat_symbolic]
	if { $status_symbolic != 0 } {
		puts $::printchan "
Could not create symbolic link 'tv-viewer'.

Error message: $resultat_symbolic
	"
	exit 1
	} else {
		puts $::printchan "tv-viewer"
	after 100
	}
	#~ set status_symbolic [catch {file link -symbolic "$binpath/tv-viewer_diag" "$bintarget/tv-viewer/data/diag_runtime.tcl"} resultat_symbolic]
	catch {exec ln -s "$bintarget/tv-viewer/data/diag_runtime.tcl" "$binpath/tv-viewer_diag"}
	set status_symbolic [catch {file link "$binpath/tv-viewer_diag"} resultat_symbolic]
	if { $status_symbolic != 0 } {
		puts $::printchan "
Could not create symbolic link 'tv-viewer_diag'.

Error message: $resultat_symbolic
	"
	exit 1
	} else {
		puts $::printchan "tv-viewer_diag"
	after 100
	}
	#~ set status_symbolic [catch {file link -symbolic "$binpath/tv-viewer_lirc" "$bintarget/tv-viewer/data/lirc_emitter.tcl"} resultat_symbolic]
	catch {exec ln -s "$bintarget/tv-viewer/data/lirc_emitter.tcl" "$binpath/tv-viewer_lirc"}
	set status_symbolic [catch {file link "$binpath/tv-viewer_lirc"} resultat_symbolic]
	if { $status_symbolic != 0 } {
		puts $::printchan "
Could not create symbolic link 'tv-viewer_lirc'.

Error message: $resultat_symbolic
	"
	exit 1
	} else {
		puts $::printchan "tv-viewer_lirc"
	after 100
	}
	#~ set status_symbolic [catch {file link -symbolic "$binpath/tv-viewer_scheduler" "$bintarget/tv-viewer/data/record_scheduler.tcl"} resultat_symbolic]
	catch {exec ln -s "$bintarget/tv-viewer/data/record_scheduler.tcl" "$binpath/tv-viewer_scheduler"}
	set status_symbolic [catch {file link "$binpath/tv-viewer_scheduler"} resultat_symbolic]
	if { $status_symbolic != 0 } {
		puts $::printchan "
Could not create symbolic link 'tv-viewer_scheduler'.

Error message: $resultat_symbolic
	"
	exit 1
	} else {
		puts $::printchan "tv-viewer_scheduler"
	after 100
	}
}

if {$start_options(--nodepcheck) == 0} {
	install_depCheck "$where_is" "$target"
	after 1250
}

install_createFolders "$where_is" "$target"
after 1250

install_checkScheduler "$where_is" "$target"

puts $::printchan "
Processing data..."
after 1250
install_copyData "$where_is" "$target"

puts $::printchan "
Processing extensions..."
after 1250
install_copyExtensions "$where_is" "$target"

puts $::printchan "
Processing icons..."
after 1250
install_copyIcons "$where_is" "$target"

puts $::printchan "
Processing licenses..."
after 1250
install_copyLicense "$where_is" "$target"

puts $::printchan "
Processing manual page..."
after 1250
install_copyMan "$where_is" "$target"

puts $::printchan "
Processing translations..."
after 1250
install_copyMsgs "$where_is" "$target"

puts $::printchan "
Processing shortcuts..."
after 1250
install_copyShortcuts "$where_is" "$target"

puts $::printchan "
Processings themes..."
after 1250
install_copyThemes "$where_is" "$target"

puts $::printchan "
Creating symbolic links..."
after 500
install_createSymbolic "$where_is" "$target"

puts $::printchan "
Changed permissions for all files."
after 250

puts $::printchan "

TV-Viewer successfully installed.

Use \"tv-viewer\" to start the application.
To see all possible command line options use
\"tv-viewer --help\".
To uninstall tv-viewer run as root
\"tv-viewer_install.tcl --uninstall\".

"


   #~ 1. proc xcopy {src dest recurse {pattern *}} {
   #~ 2. file mkdir $dest
   #~ 3. foreach file [glob -nocomplain [file join $src $pattern]] {
   #~ 4. set base [file tail $file]
   #~ 5. set sub [file join $dest $base]
   #~ 6.  
   #~ 7. # Exclude CVS, SCCS, ... automatically, and possibly the temp
   #~ 8. # hierarchy itself too.
   #~ 9.  
  #~ 10. if {0 == [string compare CVS $base]} {continue}
  #~ 11. if {0 == [string compare SCCS $base]} {continue}
  #~ 12. if {0 == [string compare BitKeeper $base]} {continue}
  #~ 13. # if {[string match ${package_name}-* $base]} {continue}
  #~ 14. if {[string match *~ $base]} {continue}
  #~ 15.  
  #~ 16. if {[file isdirectory $file]} then {
  #~ 17. if {$recurse} {
  #~ 18. file mkdir $sub
  #~ 19. xcopy $file $sub $recurse $pattern
  #~ 20. }
  #~ 21. } else {
  #~ 22. puts -nonewline stdout . ; flush stdout
  #~ 23. file copy -force $file $sub
  #~ 24. }
  #~ 25. }
  #~ 26. }

exit 0
