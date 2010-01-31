#!/usr/bin/env tclsh

#       tv-viewer_install.tcl
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

set where_is "[file dirname [file dirname [file normalize [file join [info script] bogus]]]]"
set prefix /usr/local
set target $prefix
set printchan stdout
set option(release_version) {0.8.1.1 79 31.01.2010}

array set start_options {--uninstall 0 --target 0 --prefix 0 --nodebug 0 --manpath 0 --nodepcheck 0 --arch 0 --pixmap 0 --desktop 0 --lib 0 --help 0}
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
if {[array size start_options] != 11} {
	puts "
TV-Viewer [lindex $option(release_version) 0] Build [lindex $option(release_version) 1]
	
Unkown option(s): $argv

Possible options are:

  --uninstall     Uninstalls TV-Viewer.
  --nodebug       Do not print messages of progress to stdout.
  --nodepcheck    Skip dependencies ckeck.
  --prefix=PATH   Provide a path for installation (Standard /usr/local).
  --target=PATH   Use this if you want to use the installer in packages.
                  The installer will use a directory like this 
                  /Build_Dir/prefix/
                  E.g: /home/user/buildroot/build/\"prefix\"
  --manpath=PATH  Provide a path for man pages (Standard 
                  /\"prefix\"/share/man/man1).
  --arch=ARCH     Select your systems architecture (32 / 64) or, if omitted,
                  the installer will determine it.
  --lib           If omitted shared libs will go into /usr/local/lib/tcl$tcl_version
                  Otherwise into [tcl library]
  --pixmap=PATH   Provide a path for pixmaps (Standard
                  /\"prefix\"/share/pixmaps).
  --desktop=PATH  Provide a path for *.desktop files. (Standard
                  /\"prefix\"/share/applications).
  --help          Print help.
 "
exit 1
}

if {$start_options(--help)} {
	puts "
TV-Viewer [lindex $option(release_version) 0] Build [lindex $option(release_version) 1]
	
Possible options are:

  --uninstall     Uninstalls TV-Viewer.
  --nodebug       Do not print messages of progress to stdout.
  --nodepcheck    Skip dependencies ckeck.
  --prefix=PATH   Provide a path for installation (Standard /usr/local).
  --target=PATH   Use this if you want to use the installer in packages.
                  The installer will use a directory like this 
                  /Build_Dir/prefix/
                  E.g: /home/user/buildroot/build/\"prefix\"
  --manpath=PATH  Provide a path for man pages (Standard 
                  /\"prefix\"/share/man/man1).
  --arch=ARCH     Select your systems architecture (32 / 64) or, if omitted,
                  the installer will determine it.
  --lib           If omitted shared libs will go into /usr/local/lib/tcl$tcl_version
                  Otherwise into [tcl library]
  --pixmap=PATH   Provide a path for pixmaps (Standard
                  /\"prefix\"/share/pixmaps).
  --desktop=PATH  Provide a path for *.desktop files. (Standard
                  /\"prefix\"/share/applications).
  --help          Show this help.
 "
exit 0
}

if {$start_options(--prefix)} {
	puts $::printchan "
Prefix set to [file normalize $start_values(--prefix)]"
	set prefix [file normalize $start_values(--prefix)]
	set target "[file normalize $start_values(--prefix)]"
}

if {$start_options(--target)} {
	puts $::printchan "
Build target set to [file normalize $start_values(--target)]"
	set target "[file normalize $start_values(--target)]$target"
}

if {$start_options(--uninstall)} {
	puts $::printchan "

TV-Viewer will be uninstalled..."
after 1000
	if {[file isdirectory "$target/share/tv-viewer/"]} {
		set status_uninstall [catch {file delete -force -- pathname "$target/share/tv-viewer/"} resultat_uninstall]
		if { $status_uninstall != 0} {
			puts $::printchan "
Can't uninstall TV-Viewer.
Error message: $resultat_uninstall

Folder is owned by [file attributes $target/share/tv-viewer/ -owner].
You are $::tcl_platform(user).
"
			exit 1
		} else {
			catch {file delete -force "$target/bin/tv-viewer" "$target/bin/tv-viewer_lirc" "$target/bin/tv-viewer_recext" "$target/bin/tv-viewer_diag" "$target/bin/tv-viewer_scheduler"}
			if {$::start_options(--desktop)} {
				set desk_target "[file normalize $::start_values(--desktop)]"
			} else {
				set desk_target "$target/share/applications"
			}
			catch {file delete -force "$desk_target/tv-viewer.desktop"}
			if {$::start_options(--pixmap)} {
				set pixmap_target "[file normalize $::start_values(--pixmap)]"
			} else {
				set pixmap_target "$target/share/pixmaps"
			}
			catch {file delete -force "$pixmap_target/tv-viewer.png"}
			if {$::start_options(--manpath)} {
				set manpath_target "[file normalize $::start_values(--manpath)]"
			} else {
				set manpath_target "$target/share/man"
			}
			catch {file delete -force "$manpath_target/man1/tv-viewer.1.gz"}
			if {$::start_options(--lib)} {
				set libtarget "$target/lib/tcl$tcl_version/tktray1.2/"
			} else {
				set libtarget "$target/lib/tcl$tcl_version/tktray1.2/"
			}
			catch {file delete -force -- pathname $libtarget}
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

if {$start_options(--nodebug)} {
	set printchan [open /dev/null a]
}
fconfigure $::printchan -blocking no -buffering line

	puts $::printchan "\n \n #########################################################################"
	puts $::printchan " ####                                                                 ####"
	puts $::printchan " ####           Installation of TV-Viewer [lindex $option(release_version) 0] Build [lindex $option(release_version) 1]            ####"
	puts $::printchan " ####                                                                 ####"
	puts $::printchan " #########################################################################"

if {$start_options(--nodebug)} {
	set printchan stdout
}
fconfigure $::printchan -blocking no -buffering line

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

proc install_depCheck {where_is target prefix} {
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

proc install_createFolders {where_is target prefix} {
	if {[file isdirectory "$target/share/tv-viewer"]} {
		puts $::printchan "
Found a previous installation of TV-Viewer.
Erasing old files..."
		set status_file [catch {file delete -force -- pathname "$target/share/tv-viewer/"} resultat_file]
		if { $status_file != 0 } {
			puts $::printchan "
Can't erase folders.
Error message: $resultat_file

Folder is owned by [file attributes $target/share/tv-viewer/ -owner].
You are $::tcl_platform(user).
	"
			exit 1
		} else {
			catch {[file delete -force -- pathname $prefix/lib/tcl$::tcl_version/tktray1.2/]}
			file mkdir "$target/share/tv-viewer/" "$target/share/tv-viewer/data/" "$target/share/tv-viewer/extensions/" "$target/share/tv-viewer/extensions/autoscroll/" "$target/share/tv-viewer/extensions/callib/" "$target/share/tv-viewer/extensions/fsdialog/" "$target/share/tv-viewer/icons/" "$target/share/tv-viewer/icons/16x16/" "$target/share/tv-viewer/icons/22x22/" "$target/share/tv-viewer/icons/32x32/" "$target/share/tv-viewer/icons/extras/" "$target/share/tv-viewer/license/" "$target/share/tv-viewer/msgs/" "$target/share/tv-viewer/msgs/de/" "$target/share/tv-viewer/msgs/en/" "$target/share/tv-viewer/shortcuts" "$target/share/tv-viewer/themes/" "$target/share/tv-viewer/themes/plastik/" "$target/share/tv-viewer/themes/plastik/plastik/" "$target/share/tv-viewer/themes/keramik/" "$target/share/tv-viewer/themes/keramik/keramik/" "$target/share/tv-viewer/themes/keramik/keramik_alt/"
			puts $::printchan "
Creating folders..."
		}
	} else {
		set status_file [catch {file mkdir "$target/share/tv-viewer/" "$target/share/tv-viewer/data/" "$target/share/tv-viewer/extensions/" "$target/share/tv-viewer/extensions/autoscroll/" "$target/share/tv-viewer/extensions/callib/" "$target/share/tv-viewer/extensions/fsdialog/" "$target/share/tv-viewer/icons/" "$target/share/tv-viewer/icons/16x16/" "$target/share/tv-viewer/icons/22x22/" "$target/share/tv-viewer/icons/32x32/" "$target/share/tv-viewer/icons/extras/" "$target/share/tv-viewer/license/" "$target/share/tv-viewer/msgs/" "$target/share/tv-viewer/msgs/de/" "$target/share/tv-viewer/msgs/en/" "$target/share/tv-viewer/shortcuts" "$target/share/tv-viewer/themes/" "$target/share/tv-viewer/themes/plastik/" "$target/share/tv-viewer/themes/plastik/plastik/" "$target/share/tv-viewer/themes/keramik/" "$target/share/tv-viewer/themes/keramik/keramik/" "$target/share/tv-viewer/themes/keramik/keramik_alt/"} resultat_file]
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

proc install_checkScheduler {where_is target prefix} {
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

proc install_copyData {where_is target prefix} {
	set filelist [lsort [glob "$where_is/data/*"]]
	foreach dfile [split [file normalize [join $filelist \n]] \n] {
		set status_dfile [catch {file copy -force "$dfile" "$target/share/tv-viewer/data/"} resultat_dfile]
		if { $status_dfile != 0 } {
			puts $::printchan "
Could not copy file: $dfile

Error message: $resultat_dfile
"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/data/[lindex [file split $dfile] end]"
			if {[string match *diag_runtime* "$target/share/tv-viewer/data/[lindex [file split $dfile] end]"] || [string match *lirc_emitter* "$target/share/tv-viewer/data/[lindex [file split $dfile] end]"] || [string match *scheduler* "$target/share/tv-viewer/data/[lindex [file split $dfile] end]"] || [string match *recorder* "$target/share/tv-viewer/data/[lindex [file split $dfile] end]"] || [string match *record_external* "$target/share/tv-viewer/data/[lindex [file split $dfile] end]"] || [string match *tv-viewer_main* "$target/share/tv-viewer/data/[lindex [file split $dfile] end]"]} {
				set status_permissions_dfile [catch {file attributes "$target/share/tv-viewer/data/[lindex [file split $dfile] end]" -permissions rwxr-xr-x} resultat_permissions_dfile]
			} else {
				set status_permissions_dfile [catch {file attributes "$target/share/tv-viewer/data/[lindex [file split $dfile] end]" -permissions rw-r--r--} resultat_permissions_dfile]
			}
			if {$status_permissions_dfile != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/data/[lindex [file split $dfile] end]

Error message: $resultat_permissions_dfile"
				exit 1
			}
		}
	}
	
	if {$::start_options(--desktop)} {
		set desk_target "[file normalize $::start_values(--desktop)]"
		if {[file isdirectory "$desk_target"] == 0} {
			file mkdir "$desk_target"
		}
	} else {
		if {[file isdirectory "$target/share/applications"] == 0} {
			file mkdir "$target/share/applications"
		}
		set desk_target "$target/share/applications"
	}
	set status_desktop [catch {file copy -force "$where_is/data/tv-viewer.desktop" "$desk_target/"} result_desktop]
	if { $status_desktop != 0 } {
		puts $::printchan "
Could not copy file: $where_is/data/tv-viewer.desktop

Error message: $result_desktop
	"
		exit 1
	} else {
		puts $::printchan "$desk_target/tv-viewer.desktop"
		set status_permissions_desktop [catch {file attributes "$desk_target/tv-viewer.desktop" -permissions rw-r--r--} resultat_permissions_desktop]
		if {$status_permissions_desktop != 0} {
			puts $::printchan "
Could not change permissions for: $desk_target/tv-viewer.desktop

Error message: $resultat_permissions_desktop"
			exit 1
		}
	}
}

proc install_copyExtensions {where_is target prefix} {
	if {$::start_options(--arch)} {
		if {"$::start_values(--arch)" == "64"} {
			set installLib(64) 1
			set installLib(32) 0
		} else {
			set installLib(32) 1
			set installLib(64) 0
		}
		if {"$::start_values(--arch)" == "64" && "$::tcl_platform(machine)" != "x86_64"} {
			puts $::printchan "
\033\[0;1;31mWARNING\033\[0m"
			puts $::printchan "
You have chosen to install x86_64 shared libraries
on a $::tcl_platform(machine) machine.
"
			after 1800
		}
		if {"$::start_values(--arch)" != "64" && "$::tcl_platform(machine)" == "x86_64"} {
			puts $::printchan "
\033\[0;1;31mWARNING\033\[0m"
			puts $::printchan "
You have chosen to install $::tcl_platform(machine) shared libraries
on a x86_64 machine.
"
			after 1800
		}
	} else {
		if {"$::tcl_platform(machine)" == "x86_64"} {
			set installLib(64) 1
			set installLib(32) 0
		} else {
			set installLib(64) 0
			set installLib(32) 1
		}
	}
	
	if {$::start_options(--lib)} {
		set libtarget "$target/lib/tcl$::tcl_version"
		if {[file isdirectory $libtarget/tktray1.2] == 0} {
			file mkdir "$libtarget/tktray1.2"
		}
	} else {
		set libtarget "$target/lib/tcl$::tcl_version"
		if {[file isdirectory $libtarget/tktray1.2] == 0} {
			file mkdir "$libtarget/tktray1.2"
		}
	}
	
	if {$installLib(32)} {
		set filelist [lsort [glob "$where_is/extensions/tktray/32/*"]]
		foreach tfile32 [split [file normalize [join $filelist \n]] \n] {
			set status_tfile32 [catch {file copy -force "$tfile32" "$libtarget/tktray1.2/"} resultat_tfile32]
			if { $status_tfile32 != 0 } {
				puts $::printchan "
Could not copy file: $tfile32
	
Error message: $resultat_tfile32
		"
				exit 1
			} else {
				puts $::printchan "$libtarget/tktray1.2/[lindex [file split $tfile32] end]"
				set status_permissions_tfile32 [catch {file attributes "$libtarget/tktray1.2/[lindex [file split $tfile32] end]" -permissions rwxr-xr-x} resultat_permissions_tfile32]
				if {$status_permissions_tfile32 != 0} {
					puts $::printchan "
Could not change permissions for: $libtarget/tktray1.2/[lindex [file split $tfile32] end]
	
Error message: $resultat_permissions_tfile32"
					exit 1
				}
			}
		}
	}
	
	if {$installLib(64)} {
		set filelist [lsort [glob "$where_is/extensions/tktray/64/*"]]
		foreach tfile64 [split [file normalize [join $filelist \n]] \n] {
			set status_tfile64 [catch {file copy -force "$tfile64" "$libtarget/tktray1.2/"} resultat_tfile64]
			if { $status_tfile64 != 0 } {
				puts $::printchan "
Could not copy file: $tfile64

Error message: $resultat_tfile64
		"
				exit 1
			} else {
				puts $::printchan "$libtarget/tktray1.2/[lindex [file split $tfile64] end]"
				set status_permissions_tfile64 [catch {file attributes "$libtarget/tktray1.2/[lindex [file split $tfile64] end]" -permissions rwxr-xr-x} resultat_permissions_tfile64]
				if {$status_permissions_tfile64 != 0} {
					puts $::printchan "
Could not change permissions for: $libtarget/tktray1.2/[lindex [file split $tfile64] end]

Error message: $resultat_permissions_tfile64"
					exit 1
				}
			}
		}
	}
	
	set filelist [lsort [glob "$where_is/extensions/autoscroll/*"]]
	foreach aufile [split [file normalize [join $filelist \n]] \n] {
		set status_aufile [catch {file copy -force "$aufile" "$target/share/tv-viewer/extensions/autoscroll/"} resultat_aufile]
		if { $status_aufile != 0 } {
			puts $::printchan "
Could not copy file: $aufile

Error message: $resultat_aufile
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/extensions/autoscroll/[lindex [file split $aufile] end]"
			set status_permissions_aufile [catch {file attributes "$target/share/tv-viewer/extensions/autoscroll/[lindex [file split $aufile] end]" -permissions rwxr-xr-x} resultat_permissions_aufile]
			if {$status_permissions_aufile != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/extensions/autoscroll/[lindex [file split $aufile] end]

Error message: $resultat_permissions_aufile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob "$where_is/extensions/callib/*"]]
	foreach calfile [split [file normalize [join $filelist \n]] \n] {
		set status_calfile [catch {file copy -force "$calfile" "$target/share/tv-viewer/extensions/callib/"} resultat_calfile]
		if { $status_calfile != 0 } {
			puts $::printchan "
Could not copy file: $calfile

Error message: $resultat_calfile
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/extensions/callib/[lindex [file split $calfile] end]"
			set status_permissions_calfile [catch {file attributes "$target/share/tv-viewer/extensions/callib/[lindex [file split $calfile] end]" -permissions rwxr-xr-x} resultat_permissions_calfile]
			if {$status_permissions_calfile != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/extensions/callib/[lindex [file split $calfile] end]

Error message: $resultat_permissions_calfile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob "$where_is/extensions/fsdialog/*"]]
	foreach fsfile [split [file normalize [join $filelist \n]] \n] {
		set status_fsfile [catch {file copy -force "$fsfile" "$target/share/tv-viewer/extensions/fsdialog/"} resultat_fsfile]
		if { $status_fsfile != 0 } {
			puts $::printchan "
Could not copy file: $fsfile

Error message: $resultat_fsfile
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/extensions/fsdialog/[lindex [file split $fsfile] end]"
			set status_permissions_fsfile [catch {file attributes "$target/share/tv-viewer/extensions/fsdialog/[lindex [file split $fsfile] end]" -permissions rwxr-xr-x} resultat_permissions_fsfile]
			if {$status_permissions_fsfile != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/extensions/fsdialog/[lindex [file split $fsfile] end]

Error message: $resultat_permissions_fsfile"
				exit 1
			}
		}
	}
}

proc install_copyIcons {where_is target prefix} {
	set filelist [lsort [glob "$where_is/icons/16x16/*"]]
	foreach ifile [split [file normalize [join $filelist \n]] \n] {
		set status_ifile [catch {file copy -force "$ifile" "$target/share/tv-viewer/icons/16x16/"} resultat_ifile]
		if { $status_ifile != 0 } {
			puts $::printchan "
Could not copy file: $ifile

Error message: $resultat_ifile
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/icons/16x16/[lindex [file split $ifile] end]"
			set status_permissions_ifile [catch {file attributes "$target/share/tv-viewer/icons/16x16/[lindex [file split $ifile] end]" -permissions rw-r--r--} resultat_permissions_ifile]
			if {$status_permissions_ifile != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/icons/16x16/[lindex [file split $ifile] end]

Error message: $resultat_permissions_ifile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob "$where_is/icons/22x22/*"]]
	foreach ifile [split [file normalize [join $filelist \n]] \n] {
		set status_ifile [catch {file copy -force "$ifile" "$target/share/tv-viewer/icons/22x22/"} resultat_ifile]
		if { $status_ifile != 0 } {
			puts $::printchan "
Could not copy file: $ifile

Error message: $resultat_ifile
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/icons/22x22/[lindex [file split $ifile] end]"
			set status_permissions_ifile [catch {file attributes "$target/share/tv-viewer/icons/22x22/[lindex [file split $ifile] end]" -permissions rw-r--r--} resultat_permissions_ifile]
			if {$status_permissions_ifile != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/icons/22x22/[lindex [file split $ifile] end]

Error message: $resultat_permissions_ifile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob "$where_is/icons/32x32/*"]]
	foreach ifile [split [file normalize [join $filelist \n]] \n] {
		set status_ifile [catch {file copy -force "$ifile" "$target/share/tv-viewer/icons/32x32/"} resultat_ifile]
		if { $status_ifile != 0 } {
			puts $::printchan "
Could not copy file: $ifile

Error message: $resultat_ifile
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/icons/32x32/[lindex [file split $ifile] end]"
			set status_permissions_ifile [catch {file attributes "$target/share/tv-viewer/icons/32x32/[lindex [file split $ifile] end]" -permissions rw-r--r--} resultat_permissions_ifile]
			if {$status_permissions_ifile != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/icons/32x32/[lindex [file split $ifile] end]

Error message: $resultat_permissions_ifile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob "$where_is/icons/extras/*"]]
	foreach ifile [split [file normalize [join $filelist \n]] \n] {
		set status_ifile [catch {file copy -force "$ifile" "$target/share/tv-viewer/icons/extras/"} resultat_ifile]
		if { $status_ifile != 0 } {
			puts $::printchan "
Could not copy file: $ifile

Error message: $resultat_ifile
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/icons/extras/[lindex [file split $ifile] end]"
			set status_permissions_ifile [catch {file attributes "$target/share/tv-viewer/icons/extras/[lindex [file split $ifile] end]" -permissions rw-r--r--} resultat_permissions_ifile]
			if {$status_permissions_ifile != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/icons/extras/[lindex [file split $ifile] end]

Error message: $resultat_permissions_ifile"
				exit 1
			}
		}
	}

	if {$::start_options(--pixmap)} {
		set pixmap_target "[file normalize $::start_values(--pixmap)]"
		if {[file isdirectory "$pixmap_target"] == 0} {
			file mkdir "$pixmap_target"
		}
	} else {
		if {[file isdirectory "$target/share/pixmaps"] == 0} {
			file mkdir "$target/share/pixmaps"
		}
		set pixmap_target "$target/share/pixmaps"
	}
	set status_tvicon [catch {file copy -force "$where_is/icons/extras/tv-viewer_icon.png" "$pixmap_target/"} result_tvicon]
	if { $status_tvicon != 0 } {
		puts $::printchan "
Could not copy file: $where_is/icons/extras/tv-viewer_icon.png

Error message: $result_tvicon
	"
		exit 1
	} else {
		puts $::printchan "$pixmap_target/tv-viewer_icon.png"
		set status_permissions_tvicon [catch {file attributes "$pixmap_target/tv-viewer_icon.png" -permissions rw-r--r--} resultat_permissions_tvicon]
		if {$status_permissions_tvicon != 0} {
			puts $::printchan "
Could not change permissions for: $pixmap_target/tv-viewer_icon.png

Error message: $resultat_permissions_tvicon"
			exit 1
		}
		catch {file rename -force "$pixmap_target/tv-viewer_icon.png" "$pixmap_target/tv-viewer.png"}
	}
}

proc install_copyLicense {where_is target prefix} {
	set filelist [glob "$where_is/license/*"]
	foreach lfile $filelist {
		set status_file_lic [catch {file copy -force "$lfile" "$target/share/tv-viewer/license/"} resultat_file_lic]
		if { $status_file_lic != 0 } {
			puts $::printchan "
Could not copy file: $lfile

Error message: $resultat_file_lic
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/license/[lindex [file split $lfile] end]"
			set status_permissions_lfile [catch {file attributes "$target/share/tv-viewer/license/[lindex [file split $lfile] end]" -permissions rw-r--r--} resultat_permissions_lfile]
			if {$status_permissions_lfile != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/license/[lindex [file split $lfile] end]

Error message: $resultat_permissions_lfile"
				exit 1
			}
		}
	}
}

proc install_copyMan {where_is target prefix} {
	if {$::start_options(--manpath)} {
		set manpath "[file normalize $::start_values(--manpath)]"
	} else {
		set manpath "$prefix/share/man"
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

proc install_copyMsgs {where_is target prefix} {
	set filelist [lsort [glob -directory "$where_is/msgs" *.msg]]
	foreach mfile [split [file normalize [join $filelist \n]] \n] {
		set status_mfile [catch {file copy -force "$mfile" "$target/share/tv-viewer/msgs/"} resultat_mfile]
		if { $status_mfile != 0 } {
			puts $::printchan "
Could not copy file: $mfile

Error message: $resultat_mfile
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/msgs/[lindex [file split $mfile] end]"
			set status_permissions_mfile [catch {file attributes "$target/share/tv-viewer/msgs/[lindex [file split $mfile] end]" -permissions rw-r--r--} resultat_permissions_mfile]
			if {$status_permissions_mfile != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/msgs/[lindex [file split $mfile] end]

Error message: $resultat_permissions_mfile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob -directory "$where_is/msgs/de" *.de]]
	foreach defile [split [file normalize [join $filelist \n]] \n] {
		set status_defile [catch {file copy -force "$defile" "$target/share/tv-viewer/msgs/de/"} resultat_defile]
		if { $status_defile != 0 } {
			puts $::printchan "
	Could not copy file: $defile

	Error message: $resultat_defile
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/msgs/de/[lindex [file split $defile] end]"
			set status_permissions_defile [catch {file attributes "$target/share/tv-viewer/msgs/de/[lindex [file split $defile] end]" -permissions rw-r--r--} resultat_permissions_defile]
			if {$status_permissions_defile != 0} {
				puts $::printchan "
	Could not change permissions for: $target/share/tv-viewer/msgs/de/[lindex [file split $defile] end]

	Error message: $resultat_permissions_defile"
				exit 1
			}
		}
	}

	set filelist [lsort [glob -directory "$where_is/msgs/en" *.en]]
	foreach enfile [split [file normalize [join $filelist \n]] \n] {
		set status_enfile [catch {file copy -force "$enfile" "$target/share/tv-viewer/msgs/en/"} resultat_enfile]
		if { $status_enfile != 0 } {
			puts $::printchan "
	Could not copy file: $enfile

	Error message: $resultat_enfile
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/msgs/en/[lindex [file split $enfile] end]"
			set status_permissions_enfile [catch {file attributes "$target/share/tv-viewer/msgs/en/[lindex [file split $enfile] end]" -permissions rw-r--r--} resultat_permissions_enfile]
			if {$status_permissions_enfile != 0} {
				puts $::printchan "
	Could not change permissions for: $target/share/tv-viewer/msgs/en/[lindex [file split $enfile] end]

	Error message: $resultat_permissions_enfile"
				exit 1
			}
		}
	}
}

proc install_copyShortcuts {where_is target prefix} {
	set filelist [glob "$where_is/shortcuts/*"]
	foreach sfile $filelist {
		set status_file_cut [catch {file copy -force "$sfile" "$target/share/tv-viewer/shortcuts/"} resultat_file_cut]
		if { $status_file_cut != 0 } {
			puts $::printchan "
Could not copy file: $sfile

Error message: $resultat_file_cut
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/shortcuts/[lindex [file split $sfile] end]"
			set status_permissions_sfile [catch {file attributes "$target/share/tv-viewer/shortcuts/[lindex [file split $sfile] end]" -permissions rw-r--r--} resultat_permissions_sfile]
			if {$status_permissions_sfile != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/shortcuts/[lindex [file split $lfile] end]

Error message: $resultat_permissions_sfile"
				exit 1
			}
		}
	}
}

proc install_copyThemes {where_is target prefix} {
	set filelist [glob "$where_is/themes/plastik/*.tcl"]
	foreach plastik [split [file normalize [join $filelist \n]] \n] {
		set status_file_plastik [catch {file copy -force "$plastik" "$target/share/tv-viewer/themes/plastik/"} resultat_file_plastik]
		if { $status_file_plastik != 0 } {
			puts $::printchan "
Could not copy file: $plastik

Error message: $resultat_file_plastik
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/themes/plastik/[lindex [file split $plastik] end]"
			set status_permissions_plastik [catch {file attributes "$target/share/tv-viewer/themes/plastik/[lindex [file split $plastik] end]" -permissions rwxr-xr-x} resultat_permissions_plastik]
			if {$status_permissions_plastik != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/themes/plastik/[lindex [file split $plastik] end]

Error message: $resultat_permissions_plastik"
				exit 1
			}
		}
	}

	set filelist [glob "$where_is/themes/plastik/plastik/*.gif"]
	foreach plastik [split [file normalize [join $filelist \n]] \n] {
		set status_file_plastik [catch {file copy -force "$plastik" "$target/share/tv-viewer/themes/plastik/plastik/"} resultat_file_plastik]
		if { $status_file_plastik != 0 } {
			puts $::printchan "
Could not copy file: $plastik

Error message: $resultat_file_plastik
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/themes/plastik/[lindex [file split $plastik] end]"
			set status_permissions_plastik [catch {file attributes "$target/share/tv-viewer/themes/plastik/plastik/[lindex [file split $plastik] end]" -permissions rw-r--r--} resultat_permissions_plastik]
			if {$status_permissions_plastik != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/themes/plastik/plastik/[lindex [file split $plastik] end]

Error message: $resultat_permissions_plastik"
				exit 1
			}
		}
	}

	set filelist [glob "$where_is/themes/keramik/*.tcl"]
	foreach keramik [split [file normalize [join $filelist \n]] \n] {
		set status_file_keramik [catch {file copy -force "$keramik" "$target/share/tv-viewer/themes/keramik/"} resultat_file_keramik]
		if { $status_file_keramik != 0 } {
			puts $::printchan "
Could not copy file: $keramik

Error message: $resultat_file_keramik
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/themes/keramik/[lindex [file split $keramik] end]"
			set status_permissions_keramik [catch {file attributes "$target/share/tv-viewer/themes/keramik/[lindex [file split $keramik] end]" -permissions rwxr-xr-x} resultat_permissions_keramik]
			if {$status_permissions_keramik != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/themes/keramik/[lindex [file split $keramik] end]

Error message: $resultat_permissions_keramik"
				exit 1
			}
		}
	}

	set filelist [glob "$where_is/themes/keramik/keramik/*.gif"]
	foreach keramik [split [file normalize [join $filelist \n]] \n] {
		set status_file_keramik [catch {file copy -force "$keramik" "$target/share/tv-viewer/themes/keramik/keramik/"} resultat_file_keramik]
		if { $status_file_keramik != 0 } {
			puts $::printchan "
Could not copy file: $keramik

Error message: $resultat_file_keramik
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/themes/keramik/keramik/[lindex [file split $keramik] end]"
			set status_permissions_keramik [catch {file attributes "$target/share/tv-viewer/themes/keramik/keramik/[lindex [file split $keramik] end]" -permissions rwxr-xr-x} resultat_permissions_keramik]
			if {$status_permissions_keramik != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/themes/keramik/keramik/[lindex [file split $keramik] end]

Error message: $resultat_permissions_keramik"
				exit 1
			}
		}
	}

	set filelist [glob "$where_is/themes/keramik/keramik_alt/*.gif"]
	foreach keramik [split [file normalize [join $filelist \n]] \n] {
		set status_file_keramik [catch {file copy -force "$keramik" "$target/share/tv-viewer/themes/keramik/keramik_alt/"} resultat_file_keramik]
		if { $status_file_keramik != 0 } {
			puts $::printchan "
Could not copy file: $keramik

Error message: $resultat_file_keramik
	"
			exit 1
		} else {
			puts $::printchan "$target/share/tv-viewer/themes/keramik/keramik_alt/[lindex [file split $keramik] end]"
			set status_permissions_keramik [catch {file attributes "$target/share/tv-viewer/themes/keramik/keramik_alt/[lindex [file split $keramik] end]" -permissions rwxr-xr-x} resultat_permissions_keramik]
			if {$status_permissions_keramik != 0} {
				puts $::printchan "
Could not change permissions for: $target/share/tv-viewer/themes/keramik/keramik_alt/[lindex [file split $keramik] end]

Error message: $resultat_permissions_keramik"
				exit 1
			}
		}
	}
}

proc install_createSymbolic {where_is target prefix} {
	catch {file delete -force "$target/bin/tv-viewer" "$target/bin/tv-viewer_diag" "$target/bin/tv-viewer_lirc" "$target/bin/tv-viewer_recext" "$target/bin/tv-viewer_scheduler"}
	set binpath $target/bin
	set bintarget $prefix/share
	if {[file isdirectory "$binpath"] == 0} {
		file mkdir "$binpath"
	}
	catch {exec ln -s "$bintarget/tv-viewer/data/tv-viewer_main.tcl" "$binpath/tv-viewer"}
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
	catch {exec ln -s "$bintarget/tv-viewer/data/record_external.tcl" "$binpath/tv-viewer_recext"}
	set status_symbolic [catch {file link "$binpath/tv-viewer_recext"} resultat_symbolic]
	if { $status_symbolic != 0 } {
		puts $::printchan "
Could not create symbolic link 'tv-viewer_recext'.

Error message: $resultat_symbolic
	"
	exit 1
	} else {
		puts $::printchan "tv-viewer_recext"
	after 100
	}
	catch {exec ln -s "$bintarget/tv-viewer/data/scheduler.tcl" "$binpath/tv-viewer_scheduler"}
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
	install_depCheck "$where_is" "$target" "$prefix"
	after 1250
}

install_createFolders "$where_is" "$target" "$prefix"
after 1250

install_checkScheduler "$where_is" "$target" "$prefix"

puts $::printchan "
Processing data..."
after 1250
install_copyData "$where_is" "$target" "$prefix"

puts $::printchan "
Processing extensions..."
after 1250
install_copyExtensions "$where_is" "$target" "$prefix"

puts $::printchan "
Processing icons..."
after 1250
install_copyIcons "$where_is" "$target" "$prefix"

puts $::printchan "
Processing licenses..."
after 1250
install_copyLicense "$where_is" "$target" "$prefix"

puts $::printchan "
Processing manual page..."
after 1250
install_copyMan "$where_is" "$target" "$prefix"

puts $::printchan "
Processing translations..."
after 1250
install_copyMsgs "$where_is" "$target" "$prefix"

puts $::printchan "
Processing shortcuts..."
after 1250
install_copyShortcuts "$where_is" "$target" "$prefix"

puts $::printchan "
Processings themes..."
after 1250
install_copyThemes "$where_is" "$target" "$prefix"

if {$start_options(--nodebug)} {
	set printchan [open /dev/null a]
}
fconfigure $::printchan -blocking no -buffering line

puts $::printchan "
Creating symbolic links..."
after 500
install_createSymbolic "$where_is" "$target" "$prefix"

puts $::printchan "
Changed permissions for all files."
after 250

if {$start_options(--nodebug)} {
	puts stdout "
build all done..."
} else {
	puts $::printchan "

TV-Viewer successfully installed.

Use \"tv-viewer\" to start the application.
To see all possible command line options use
\"tv-viewer --help\".
To uninstall tv-viewer run as root
\"tv-viewer_install.tcl --uninstall\".

"
}

exit 0
