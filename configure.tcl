#!/usr/bin/env tclsh

#       configure.tcl
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
set eprefix $prefix
set bindir $eprefix/bin
set libdir $eprefix/lib
set datadir $prefix/share
set mandir $prefix/man
set docdir $prefix/doc/tv-viewer
set printchan stdout
set option(release_version) {0.8.1.1 81 19.03.2010}

array set start_options {--help 0 --version 0 --quiet 0 --prefix 0 --exec-prefix 0 --nodebug 0 --bindir 0 --libdir 0 --datadir 0 --mandir 0 --docdir 0 --arch 0}
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
if {[array size start_options] != 12} {
	puts "
`configure' configures TV-Viewer [lindex $option(release_version) 0] Build [lindex $option(release_version) 1] to adapt to many kinds of systems.
	
Unkown option(s): $argv

Usage: ./configure [OPTION]... [VAR=VALUE]...

To assign environment variables (e.g., CC, CFLAGS...), specify them as
VAR=VALUE.  See below for descriptions of some of the useful variables.

Defaults for the options are specified in brackets.

Configuration:
  --help          print this help and exit
  --version       display version information and exit
  --quiet         do not print messages of progress to stdout

Installation directories:
  --prefix=PREFIX         install architecture-independent files in PREFIX 
                          [/usr/local]
  --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX 
                          [PREFIX]

By default, `./install' will install all the files in
`/usr/local/bin', `/usr/local/lib' etc.  You can specify
an installation prefix other than `/usr/local' using `--prefix',
for instance `--prefix=$HOME'.

For better control, use the options below.

Fine tuning of the installation directories:
  --bindir=DIR            user executables [EPREFIX/bin]
  --libdir=DIR            object code libraries [EPREFIX/lib]
  --datadir=DIR           read-only architecture-independent data [PREFIX/share]
  --mandir=DIR            man documentation [PREFIX/man]
  --docdir=DIR            documentation root [PREFIX/doc/tv-viewer]

Optional Features:
  --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
  --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
  --arch=ARCH             Select your systems architecture (32 / 64) or, if omitted,
                          the installer will determine it.

Use these variables to override the choices made by `configure'.
"
exit 1
}

if {$start_options(--help)} {
	puts "
`configure' configures TV-Viewer [lindex $option(release_version) 0] Build [lindex $option(release_version) 1] to adapt to many kinds of systems.

Usage: ./configure [OPTION]... [VAR=VALUE]...

To assign environment variables (e.g., CC, CFLAGS...), specify them as
VAR=VALUE.  See below for descriptions of some of the useful variables.

Defaults for the options are specified in brackets.

Configuration:
  --help          print this help and exit
  --version       display version information and exit
  --quiet         do not print messages of progress to stdout

Installation directories:
  --prefix=PREFIX         install architecture-independent files in PREFIX 
                          [/usr/local]
  --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX 
                          [PREFIX]

By default, `./install' will install all the files in
`/usr/local/bin', `/usr/local/lib' etc.  You can specify
an installation prefix other than `/usr/local' using `--prefix',
for instance `--prefix=$HOME'.

For better control, use the options below.

Fine tuning of the installation directories:
  --bindir=DIR            user executables [EPREFIX/bin]
  --libdir=DIR            object code libraries [EPREFIX/lib]
  --datadir=DIR           read-only architecture-independent data [PREFIX/share]
  --mandir=DIR            man documentation [PREFIX/man]
  --docdir=DIR            documentation root [PREFIX/doc/tv-viewer]

Optional Features:
  --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
  --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
  --arch=ARCH             Select your systems architecture (32 / 64) or, if omitted,
                          the installer will determine it.

Use these variables to override the choices made by `configure'.
 "
exit 0
}

if {$start_options(--prefix)} {
	puts $::printchan "
Prefix set to [file normalize $start_values(--prefix)]"
	set prefix "[file normalize $start_values(--prefix)]"
	set target "[file normalize $start_values(--prefix)]"
}

if {$start_options(--target)} {
	puts $::printchan "
Build target set to [file normalize $start_values(--target)]"
	set target "[file normalize $start_values(--target)]$target"
}

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

proc configure_welcomeMsg {} {
	if {$::start_options(--nodebug)} {
		set ::printchan [open /dev/null a]
	}
	fconfigure $::printchan -blocking no -buffering line
	
	puts $::printchan "

           Configuring build environment for TV-Viewer [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]
"
	
	if {$::start_options(--nodebug)} {
		set ::printchan stdout
	}
	fconfigure $::printchan -blocking no -buffering line
}

proc configure_depCheck {where_is target prefix} {
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

configure_welcomeMsg
after 500

if {$start_options(--nodepcheck) == 0} {
	configure_depCheck "$where_is" "$target" "$prefix"
	after 1250
}
