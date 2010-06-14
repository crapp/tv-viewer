#!/usr/bin/env tclsh

#       configure.tcl
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
set bintarget $prefix/share/tv-viewer
set libdir $eprefix/lib
set datadir $prefix/share
set mandir $prefix/share/man
set docdir $prefix/doc/tv-viewer
set arch 32
set tktray 1
set printchan stdout
set option(release_version) {0.8.2a1 92 14.06.2010}

array set start_options {--help 0 --version 0 --quiet 0 --nodepcheck 0 --prefix 0 --exec-prefix 0 --bindir 0 --bintarget 0 --libdir 0 --datadir 0 --mandir 0 --docdir 0 --enable-tktray 0 --host 0}
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
if {[array size start_options] != 14} {
	puts "
`configure' configures TV-Viewer [lindex $option(release_version) 0] Build [lindex $option(release_version) 1] to adapt to many kinds of systems.
	
Unkown option(s): $argv

Usage: ./configure \[OPTION\]... \[VAR=VALUE\]...

To assign environment variables (e.g., CC, CFLAGS...), specify them as
VAR=VALUE.  See below for descriptions of some of the useful variables.

Defaults for the options are specified in brackets.

Configuration:
  --help          print this help and exit
  --version       display version information and exit
  --nodepcheck    skip configure dependency check
  --quiet         do not print all messages to stdout

Installation directories:
  --prefix=PREFIX         install architecture-independent files in PREFIX 
                          \[/usr/local\]
  --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX 
                          \[PREFIX\]

By default, `./install.tcl' will install all the files in
`/usr/local/bin', `/usr/local/lib' etc.  You can specify
an installation prefix other than `/usr/local' using `--prefix',
for instance `--prefix=\$HOME'.

For better control, use the options below.

Fine tuning of the installation directories:
  --bindir=DIR            user executables \[EPREFIX/bin\]
  --bintarget=DIR         symbolic links point to \[PREFIX/share/tv-viewer\]
  --libdir=DIR            object code libraries \[EPREFIX/lib\]
  --datadir=DIR           read-only architecture-independent data \[PREFIX/share\]
  --mandir=DIR            man documentation \[PREFIX/share/man\]
  --docdir=DIR            documentation root \[PREFIX/doc/tv-viewer\]

Optional Features:
  --enable-FEATURE=ARG    include FEATURE \[ARG=yes||no\]
  --host=HOST             build program to run on HOST (i686, x86_64) 
                         \[autodetect\]

Use these variables to override the choices made by `configure'.
"
exit 1
}

if {$start_options(--help)} {
	puts "
`configure' configures TV-Viewer [lindex $option(release_version) 0] Build [lindex $option(release_version) 1] to adapt to many kinds of systems.

Usage: ./configure \[OPTION\]... \[VAR=VALUE\]...

To assign environment variables (e.g., CC, CFLAGS...), specify them as
VAR=VALUE.  See below for descriptions of some of the useful variables.

Defaults for the options are specified in brackets.

Configuration:
  --help          print this help and exit
  --version       display version information and exit
  --nodepcheck    skip configure dependency check
  --quiet         do not print all messages to stdout

Installation directories:
  --prefix=PREFIX         install architecture-independent files in PREFIX 
                          \[/usr/local\]
  --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX 
                          \[PREFIX\]

By default, `./install.tcl' will install all the files in
`/usr/local/bin', `/usr/local/lib' etc.  You can specify
an installation prefix other than `/usr/local' using `--prefix',
for instance `--prefix=\$HOME'.

For better control, use the options below.

Fine tuning of the installation directories:
  --bindir=DIR            user executables \[EPREFIX/bin\]
  --bintarget=DIR         symbolic links point to \[PREFIX/share/tv-viewer\]
  --libdir=DIR            object code libraries \[EPREFIX/lib\]
  --datadir=DIR           read-only architecture-independent data \[PREFIX/share\]
  --mandir=DIR            man documentation \[PREFIX/share/man\]
  --docdir=DIR            documentation root \[PREFIX/doc/tv-viewer\]

Optional Features:
  --enable-FEATURE=ARG    include FEATURE \[ARG=yes||no\]
  --host=HOST             build program to run on HOST (i686, x86_64) 
                         \[autodetect\]

Use these variables to override the choices made by `configure'.
 "
exit 0
}
if {$start_options(--version)} {
	puts "
tv-viewer configure tcl script version [lindex $option(release_version) 0]"
	puts "
© Copyright 2007-2010 Christian Rapp <christianrapp@users.sourceforge.net>

This script is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
       
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
MA 02110-1301, USA."
	exit 0
}

if {$start_options(--prefix)} {
	set prefix [file normalize "$start_values(--prefix)"]
	set eprefix $prefix
	set bindir $eprefix/bin
	set bintarget $prefix/share/tv-viewer
	set libdir $eprefix/lib
	set datadir $prefix/share
	set mandir $prefix/share/man
	set docdir $prefix/doc/tv-viewer
}
if {$start_options(--exec-prefix)} {
	set eprefix [file normalize "$start_values(--eprefix)"]
	set bindir $eprefix/bin
	set libdir $eprefix/lib
}
if {$start_options(--bindir)} {
	set bindir [file normalize "$start_values(--bindir)"]
}
if {$start_options(--bintarget)} {
	set bintarget [file normalize "$start_values(--bintarget)"]
}
if {$start_options(--libdir)} {
	set libdir [file normalize "$start_values(--libdir)"]
}
if {$start_options(--datadir)} {
	set datadir [file normalize "$start_values(--datadir)"]
}
if {$start_options(--mandir)} {
	set mandir [file normalize "$start_values(--mandir)"]
}
if {$start_options(--docdir)} {
	set docdir [file normalize "$start_values(--docdir)"]
}
if {$start_options(--enable-tktray)} {
	if {"$start_values(--enable-tktray)" == "yes"} {
		set tktray 1
	}
	if {"$start_values(--enable-tktray)" == "no"} {
		set tktray 0
	}
}
if {$start_options(--host)} {
	if {"$start_values(--host)" == "i686"} {
		set arch 32
	}
	if {"$start_values(--host)" == "x86_64"} {
		set arch 64
	}
} else {
	if {"$::tcl_platform(machine)" == "x86_64"} {
		set arch 64
	} else {
		set arch 32
	}
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
	puts $::printchan "
Configuring build environment for TV-Viewer [lindex $::option(release_version) 0] Build [lindex $::option(release_version) 1]
"
}

proc configure_depCheck {where_is prefix eprefix bindir bintarget libdir datadir mandir docdir arch tktray log} {
	puts $::printchan "
checking dependencies
"
	puts $log "
## ---------- ##
## Core tests ##
## ---------- ##
"
	
	after 50
	puts -nonewline $::printchan "Tk "
	set status_tk [catch {package require Tk} version_tk]
	set i 0
	while { $i != 3 } {
		puts -nonewline $::printchan "*"
		flush stdout
		after 50
		incr i
	}
	if {$status_tk == 0} {
		if {[package vsatisfies $version_tk 8.5]} {
			puts $::printchan "\033\[0;1;32m OK\033\[0m"
			puts $log "Tk $version_tk"
		} else {
			puts $log "Tk $version_tk FAILED "
			puts $::printchan "\033\[0;1;31m FAILED\033\[0m"
			puts $::printchan "
TV-Viewer needs Tk >= 8.5 found $version_tk
see the README for system requirements
EXIT 1"
			exit 1
		}
	} else {
		puts $log "Tk FAILED " 
		puts $::printchan "\033\[0;1;31m FAILED\033\[0m"
		puts $::printchan "
TV-Viewer needs Tk >= 8.5
see the README for system requirements
EXIT 1"
		exit 1
	}
	
	set dependencies [dict create ivtv-tune ivtv-utils v4l2-ctl ivtv-utils mplayer MPlayer xdg-email xdg-utils xdg-open xdg-utils xdg-screensaver xdg-utils]
	
	foreach {key elem} [dict get $dependencies] {
		puts -nonewline $::printchan "$key "
		set i 0
		while { $i != 3 } {
			puts -nonewline $::printchan "*"
			flush stdout
			after 50
			incr i
		}
		if {[string trim [auto_execok $key]] != {}} {
			puts $log "[auto_execok $key]"
			puts $::printchan "\033\[0;1;32m OK\033\[0m"
		} else {
			puts $::printchan "\033\[0;1;31m FAILED\033\[0m"
			puts $log "$key FAILED"
			puts $::printchan "
TV-Viewer needs $elem
see the README for system requirements
EXIT 1"
			exit 1
		}
	}
	
	puts $::printchan "
checking for optional dependencies
"
	set opt_dependencies [dict create irexec lirc]
	
	foreach {key elem} [dict get $opt_dependencies] {
		puts -nonewline $::printchan "$key "
		set i 0
		while { $i != 3 } {
			puts -nonewline $::printchan "*"
			flush stdout
			after 50
			incr i
		}
		if {[string trim [auto_execok $key]] != {}} {
			puts $log "[auto_execok $key]"
			puts $::printchan "\033\[0;1;32m OK\033\[0m"
		} else {
			puts $::printchan "\033\[0;1;31m FAILED\033\[0m"
			puts $log "$key FAILED"
			puts $::printchan "
could not detect lirc
you won't be able to use a remote control
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
			after 50
			incr i
		}
		set status_tkimg [catch {package require Img} tkimg_ver]
		if {$status_tkimg == 0} {
			puts $log "tkimg $tkimg_ver OK"
			puts $::printchan "\033\[0;1;32m OK\033\[0m"
		} else {
			puts $::printchan "\033\[0;1;31m FAILED\033\[0m"
			puts $log "tkimg FAILED"
			puts $::printchan "
could not detect tkimg (libtk-img)
no support for high resolution PNG icons"
			after 1250
		}
	}
}

proc configure_writeInstaller {where_is prefix eprefix bindir bintarget libdir datadir mandir docdir arch tktray log} {
	puts $::printchan "
configuring TV-Viewer:
prefix        $prefix
eprefix       $eprefix
bindir        $bindir
bintarget     $bintarget
libdir        $libdir
datadir       $datadir
mandir        $mandir
docdir        $docdir

tktray        $tktray
architecture  ${arch}bit
"
	puts $log "
## ------------------- ##
## Writing install.tcl ##
## ------------------- ##

prefix        $prefix
eprefix       $eprefix
bindir        $bindir
bintarget     $bintarget
libdir        $libdir
datadir       $datadir
mandir        $mandir
docdir        $docdir

tktray        $tktray
architecture  ${arch}bit"
	after 250
	if {[file exists $where_is/installer.tcl]} {
		puts $::printchan "
deleting old installer"
		file delete -force $where_is/installer.tcl
	}
	set stat_in [catch {set inst_in [open "$where_is/install.tcl.in" r]} result_in]
	if {$stat_in != 0} {
		puts $log "
fatal, can not open install.tcl.in
$result_in
EXIT 1"
		puts "
fatal error, can not open install.tcl.in
$result_in"
		exit 1
	}
	set stat_out [catch {set inst_out [open "$where_is/install.tcl" w+]} result_out]
	if {$stat_out != 0} {
		puts $log "
fatal, can not write install.tcl
$result_out
EXIT 1"
		puts "
fatal error, can not write install.tcl
$result_out"
		exit 1
	}
	
	set conf_vars {prefix eprefix bindir bintarget libdir datadir mandir docdir arch tktray}
		while {[gets $inst_in line]!=-1} {
		foreach var $conf_vars {
			set line [string map [list "$var FOO" "$var \{[set $var]\}"] "$line"]
			if {[string match "*set $var [set $var]*" "$line"]} {
				break
			}
		}
		if {[string match *##@@install_steps* "$line"]} {
			set line "	install_steps \$where_is \$prefix \$eprefix \$bindir \$bintarget \$libdir \$datadir \$mandir \$docdir \$arch \$tktray" 
		}
		if {[string match *##@@install_uninstall* "$line"]} {
			set line "	install_uninstall \$where_is \$prefix \$eprefix \$bindir \$bintarget \$libdir \$datadir \$mandir \$docdir \$arch \$tktray"
		}
		if {[string match "*#install.tcl.in @@*" "$line"]} {
			set line "#!/usr/bin/env tclsh" 
		}
		puts $inst_out "$line"
		flush $inst_out
	}
	file attributes "$where_is/install.tcl" -permissions a+x
	puts $log "
configure.tcl done
exit 0"
	puts $::printchan "
configure: creating ./config.log
configure: creating ./install.tcl"

if {$::start_options(--quiet) == 0} {
	puts $::printchan "
run
% ./install.tcl 
as root to install TV-Viewer
"
	}
	exit 0
}

set status_log [catch {set log [open "$where_is/config.log" w+]} result_log]
if {$status_log != 0} {
	puts "
fatal, can not write log file

$result_log"

	exit 1
}

puts $log "
This file contains any messages produced while running configure.tcl,
to aid debugging if configure.tcl makes a mistake.

It was created by tv-viewer configure [lindex $option(release_version) 0]
Invocation command line was

$ ./configure.tcl $argv"

puts $log "
## -------- ##
## Platform ##
## -------- ##

user     = $::tcl_platform(user)
uname -m = $::tcl_platform(machine)
uname -r = $::tcl_platform(osVersion)
uname -s = $::tcl_platform(os)"

puts $log "
auto_path:"
foreach pa $auto_path {
	puts $log "$pa"
}

puts $log "
PATH:"
foreach pa [split $::env(PATH) :] {
	puts $log "$pa"
}

configure_welcomeMsg
after 500

if {$start_options(--nodepcheck) == 0} {
	configure_depCheck "$where_is" "$prefix" "$eprefix" "$bindir" "$bintarget" "$libdir" "$datadir" "$mandir" "$docdir" "$arch" "$tktray" "$log"
	after 1250
}

configure_writeInstaller "$where_is" "$prefix" "$eprefix" "$bindir" "$bintarget" "$libdir" "$datadir" "$mandir" "$docdir" "$arch" "$tktray" "$log"

exit 0
