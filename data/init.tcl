#       init.tcl
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

proc init_pkgReq {nrlist} {
	array set pkg {
		0 "Tcl 8.5"
		1 "Tk 8.5"
		2 http
		3 msgcat
		4 sqlite3
	}
	foreach nr $nrlist {
		package require {*}$pkg($nr)
		if {$nr == 3} {
			namespace import msgcat::mc
		}
	}
}

proc init_testRoot {} {
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
}

proc init_tclKit {} {
	set ::option(tclkit) 0
	set ::option(tclkit_path) ""
	set status_link [catch {file link [info nameofexecutable]} result_link]
	if {$status_link == 0} {
		set nameofexec [lindex [file split [file link [info nameofexecutable]]] end]
	} else {
		set nameofexec [lindex [file split [info nameofexecutable]] end]
	}
	
	foreach path $::auto_path {
		if {[string match *$nameofexec* $path]} {
			set ::option(tclkit) 1
			set tclkit ""
			foreach elem [file split $path] {
				set tclkit [file join $tclkit $elem]
				if {[string match $nameofexec $elem]} {
					set ::option(tclkit_path) "$tclkit"
					break
				}
			}
			break
		}
	}
}

proc init_autoPath {} {
	set insertLocal 1
	set insertGlob 1
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
}

proc init_themes {} {
	#Source additional ttk themes, plastik and keramik
	source "$::option(root)/themes/plastik/plastik.tcl"
	source "$::option(root)/themes/keramik/keramik.tcl"
	
	ttk::style theme use $::option(use_theme)
	if {"$::option(use_theme)" == "clam"} {
		ttk::style configure TLabelframe -labeloutside false -labelmargins {10 0 0 0}
	}
}

proc init_langSupport {} {
	#Setting up language support.
	if {$::option(language_value) != 0} {
		msgcat::mclocale $::option(language_value)
	} else {
		msgcat::mclocale $::env(LANG)
	}
	if {[msgcat::mcload $::option(root)/msgs] != 1} {
		msgcat::mclocale en
		msgcat::mcload $::option(root)/msgs
		log_writeOut ::log(tvAppend) 1 "$::env(LANG) no translation found"
	}
}

proc init_lock {lockfile scriptfile appname} {
	if {[file isdirectory "$::option(home)"]} {
		set ::init(restartLock) 0
		set status_lock [catch {exec ln -s "[pid]" "$::option(home)/tmp/$lockfile"} resultat_lock]
		if { $status_lock != 0 } {
			set linkread [file readlink "$::option(home)/tmp/$lockfile"]
			catch {exec ps -eo "%p"} read_ps
			set status_greppid [catch {agrep -w "$read_ps" $linkread} resultat_greppid]
			if { $status_greppid != 0 } {
				catch {file delete "$::option(home)/tmp/$lockfile"}
				catch {exec ln -s "[pid]" "$::option(home)/tmp/$lockfile"}
			} else {
				catch {exec ps -p $linkread -o args=} readarg
				set status_grepargLink [catch {agrep -m "$readarg" "$appname"} resultat_greparg]
				set status_grepargDirect [catch {agrep -m "$readarg" "$scriptfile"} resultat_greparg]
				if {$status_grepargLink != 0 && $status_grepargDirect != 0} {
					catch {file delete "$::option(home)/tmp/$lockfile"}
					catch {exec ln -s "[pid]" "$::option(home)/tmp/$lockfile"}
				} else {
					if {"$appname" == "tv-viewer_scheduler"} {
						puts "
	An instance of the TV-Viewer Scheduler is already running"
					}
					if {"$appname" == "tv-viewer"} {
						puts "
	An instance of TV-Viewer is already running."
						#FIXME - This messageBox is really ugly - Will be changed in the future
						tk_messageBox -icon warning -title "Instance already running" -message "An instance of TV-Viewer is already running.
	Otherwise you have to delete the file
	$::option(home)/tmp/lockfile.tmp"
					}
					if {"$appname" == "tv-viewer_notifyd"} {
						puts "
	An instance of the TV-Viewer notification daemon is already running"
					}
					exit 1
				}
			}
		}
	} else {
		set ::init(restartLock) 1
	}
}

proc init_source {datadir loadlist} {
	set globIgnoreList {diag_runtime.tcl dbus_interface.tcl init.tcl lirc_emitter.tcl notifyd.tcl radio.tcl record_external.tcl recorder.tcl scheduler.tcl tv-viewer_main.tcl}
	set flist [lsort [glob "$datadir/*.tcl"]]
	foreach elem $flist {
		if {[lsearch $globIgnoreList [file tail $elem]] != -1} continue
		if {"$loadlist" == "all"} {
			source $elem
		} else {
			if {[lsearch $loadlist [file tail $elem]] != -1} {
				source $elem
			}
		}
	}
}
