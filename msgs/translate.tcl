#!/usr/bin/env tclsh

#       translate.tcl
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

##############################################
# This is a translation engine for TV-Viewer.
# Gui support is planned for the future.
##############################################

package require msgcat

proc translate {files} {
	if {[file exists "$::msgsDir/$::start_value(--lang).msg"]} {
		source "$::msgsDir/$::start_value(--lang).msg";# use existing translations
	} else {
		set file($::start_value(--lang)) [open "$::msgsDir/$::start_value(--lang).msg" w]
		close $file($::start_value(--lang))
		source "$::msgsDir/$::start_value(--lang).msg"
	}
	set amountFile 0
	set amountString 0
	puts -nonewline "processing data files "
	flush stdout
	foreach myFile $files {
		# read source file
		set myFd [open $myFile r]
		set myC [read $myFd]
		close $myFd
		# add file names in list
		lappend ::myList "# $myFile"
		# find namespace
		set myNs [lindex [regexp -inline -line -all -- {^namespace\s+eval\s+[[:graph:]]+\s} $myC] end]
		if {$myNs eq {}} {set myNs {namespace eval ::}}
		# find existing translations and add them to the list
		foreach myMc [regexp -inline -all -- {(\[mc\s.*\]){1,1}?} $myC] {
			lappend ::myList [lindex [string trim $myMc {[]}] 1]
		}
		puts -nonewline "*"
		flush stdout
		after 5
		incr amountFile
	}
	# use a dict to eliminate duplicate entries
	set myListDict [dict create]
	foreach elem $::myList {
		dict set myListDict $elem {}
	}
	set myListReworked [dict keys $myListDict]
	# create english and choosen translation
	foreach myMc $myListReworked {
		if {[string match #* $myMc]} {
			append myEn "\n$myMc\n\n"
			append myLc "\n$myMc\n\n"
			continue
		}
		if {[string match "*%*" $myMc]} {
			set doRegsub 1
			if {[string match "*%%F*" $myMc] || [string match "*%%S*" $myMc]} {
				append myEn "mcset en {$myMc}\n"
				set doRegsub 0
			}
			if {[string match "*%%%*" $myMc]} {
				append myEn "mcset en {$myMc} {[regsub -all %%% $myMc %s%%]}\n"
				set doRegsub 0
			}
			if {$doRegsub} {
				append myEn "mcset en {$myMc} {[regsub -all % $myMc %s]}\n"
			}
		} else {
			append myEn "mcset en {$myMc}\n"
		}
		{*}$myNs "set ::my \[[list ::msgcat::mc $myMc]\]"
		if {[string match "*%*" $::my] && [string match "*%s*" $::my] != 1} {
			set doRegsub 1
			if {[string match "*%%F*" $::my] || [string match "*%%S*" $::my]} {
				append myLc "mcset $::start_value(--lang) {$myMc} {$::my}\n"
				set doRegsub 0
			}
			if {[string match "*%%%*" $::my]} {
				append myLc "mcset $::start_value(--lang) {$myMc} {[regsub -all %%% $::my %s%%]}\n"
				set doRegsub 0
			}
			if {$doRegsub} {
				append myLc "mcset $::start_value(--lang) {$myMc} {[regsub -all % $::my %s]}\n"
			}
		} else {
			append myLc "mcset $::start_value(--lang) {$myMc} {$::my}\n"
		}
		puts -nonewline "*"
		flush stdout
		after 5
		incr amountString
	}
	# write translation files
	if {$::start_option(--langEn)} {
		set msgFileEn [open "$::msgsDir/en.msg" w]
		set transEn "# en.msg
namespace import -force msgcat::mcset\n";# original texts are in english
		append transEn $myEn
		append transEn "\n"
		append transEn "# Need to source msg files from fsdialog because this is an external project"
		append transEn "\nsource \"$::root/extensions/fsdialog/en.msg\"";# need to source msg files from fsdialog
		puts $msgFileEn $transEn
		close $msgFileEn
	}
	set msgFile($::start_value(--lang)) [open "$::msgsDir/$::start_value(--lang).msg" w]
	set transLc "# $::start_value(--lang).msg
namespace import -force msgcat::mcset\n";# translation into choosen language
	append transLc $myLc
	append transLc "\n"
	if {[file exists "$::root/extensions/fsdialog/$::start_value(--lang).msg"]} {
		append transLc "# Need to source msg files from fsdialog because this is an external project"
		append transLc "\nsource \"$::root/extensions/fsdialog/$::start_value(--lang).msg\""
	} else {
		puts "there is no \"$::start_value(--lang)\" translation file available for fsdialog
consider creating one and place it into extensions/fsdialog."
	}
	puts $msgFile($::start_value(--lang)) $transLc
	close $msgFile($::start_value(--lang))
	puts "\nfinished"
	puts "processed $amountFile files with $amountString text strings"
	puts "please edit \"$::start_value(--lang).msg\" manually and provide translations,
when finished send this file to the developers"
	exit 0
}

set root [file dirname [file dirname [file dirname [file normalize [file join [info script] bogus]]]]]
set msgsDir [file dirname [file dirname [file normalize [file join [info script] bogus]]]]

array set start_option {--help 0 --lang 0 --langEn 0}
	foreach command_argument $::argv {
		if {[string first = $command_argument] == -1 } {
			set i [string first - $command_argument]
			set key $command_argument
			set start_option($key) 1
		} else {
			set i [string first = $command_argument]
			set key [string range $command_argument 0 [expr {$i-1}]]
			set value [string range $command_argument [expr {$i+1}] end]
			set start_option($key) 1
			set start_value($key) $value
		}
	}
if {[array size ::start_option] != 3} {
	puts "TV-Viewer translation engine version 0.1

Received unknown option $argv

Usage: translate.tcl \[OPTION...\]

  --help                show this help

 Translate:
  --lang=LANGUAGE CODE  provide a language code (--lang=es spanish translation)
  --langEn              create english translation file. only needed if code has been changed
"
	exit 1
}

if {$start_option(--help)} {
	puts "TV-Viewer translation engine version 0.1
Usage: translate.tcl \[OPTION...\]

  --help                show this help
 
 Translate:
  --lang=LANGUAGE CODE  provide a language code (--lang=es spanish translation)
  --langEn              create english translation file. only needed if code has been changed
"
	exit 0
}

if {$start_option(--langEn)} {
	puts -nonewline "A new english translation file is only needed if new text strings have been added to the code.
	
Do you want to continue \[Y/n\]? "
	set in [gets stdin]
	if {"$in" != "Y"} {
		exit 0
	} else {
		puts "creating translation file for language code \"en\""
	}
}

if {$start_option(--lang) == 0} {
	puts "TV-Viewer translation engine version 0.1

No language code provided

Usage: translate.tcl \[OPTION...\]

  --help                show this help

 Translate:
  --lang=LANGUAGE CODE  provide a language code (--lang=es spanish translation)
  --langEn              create english translation file. only needed if code has been changed
"
	exit 1
} else {
	set start_value(--lang) [string map {{ } {}} $start_value(--lang)]
	puts "creating translation file for language code \"$start_value(--lang)\""
}

if {[file isdirectory "$root/data"] == 0} {
	puts "this file must be located in the tv-viewer folder"
	exit 1
}

# take all files in the data folder and callib.tcl
set files [glob -directory "$root/data" *.tcl]
lappend files "$root/extensions/callib/callib.tcl"
set files [lsort $files]

translate $files
