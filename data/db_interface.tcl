#       db_interface.tcl
#       © Copyright 2007-2012 Christian Rapp <christianrapp@users.sourceforge.net>
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

proc db_interfaceInit {} {
	# init connection to DB. Creates necessary tables if needed.
	puts $::main(debug_msg) "\033\[0;1;33mDebug: db_interfaceInit \033\[0m"
	if {![file exists $::option(home)/config/tv-viewer.sqlite]} {
		sqlite3 database $::option(home)/config/tv-viewer.sqlite
		database eval {CREATE TABLE "RECORDINGS" ("ID" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , "STATION" TEXT NOT NULL , "DATETIME" INTEGER NOT NULL , "DURATION" INTEGER NOT NULL , "RERUN" INTEGER NOT NULL , "RERUNS" INTEGER NOT NULL , "RESOLUTION" TEXT NOT NULL , "OUTPUT" TEXT NOT NULL , "RUNNING" INTEGER NOT NULL  DEFAULT 0, "TIMESTAMP" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)}
	} else {
		sqlite3 database $::option(home)/config/tv-viewer.sqlite
	}
}

proc db_interfaceClose {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: db_interfaceClose \033\[0m"
	database close
}

proc db_interfaceGetActiveRec {} {
	#returns active recording as a list
	puts $::main(debug_msg) "\033\[0;1;33mDebug: db_interfaceGetActiveRec \033\[0m"
	set activerec ""
	if {[database exists {SELECT 1 FROM RECORDINGS WHERE RUNNING = 1}]} {
		set count [database eval {SELECT COUNT(ID) FROM RECORDINGS WHERE RUNNING = 1}]
		puts "count: $count"
		if {$count == 1} {
			set activerec [database eval {SELECT * FROM RECORDINGS WHERE RUNNING = 1}]
		} else {
			puts "Found more than one running recording. Report this incident"
		}
	}
	puts "activerec: $activerec"
	return $activerec
}
