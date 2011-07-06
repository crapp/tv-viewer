#       dbus_interface.tcl
#       © Copyright 2007-2011 Christian Rapp <christianrapp@users.sourceforge.net>
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

#code in this file is not used currently. most likely we will create a dbus interface so tv-viewer can be controlled with it.

proc dbus_interfaceStart {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: dbus_interfaceStart \033\[0m"}
	set status_present [catch {package present dbus-tcl 1.0} result_present]
	if {$status_present == 1} {
		catch {log_writeOut ::log(tvAppend) 0 "Loading shared library dbus-tcl"}
		set status_dbus [catch {package require dbus-tcl 1.0} result_dbustcl]
		if {$status_dbus == 1} {
			if {"$::option(appname)" == "tv-viewer_main"} {
				log_writeOut ::log(tvAppend) 2 "Can not load shared library dbus-tcl"
				log_writeOut ::log(tvAppend) 2 "$result_dbustcl"
				log_writeOut ::log(tvAppend) 2 "Deactivate D-Bus in the interface section of the preferences"
				status_feedbWarn 1 [mc "Can not load shared library dbus-tcl"]
			}
			if {"$::option(appname)" == "tv-viewer_scheduler"} {
				log_writeOut ::log(schedAppend) 2 "Can not load shared library dbus-tcl"
				log_writeOut ::log(schedAppend) 2 "$result_dbustcl"
				log_writeOut ::log(schedAppend) 2 "Deactivate D-Bus in the interface section of the preferences"
			}
			return 1
		}
		# connecting to dbus 
		catch {dbus connect}
		# filter for signals from org.freedesktop.Notifications
		catch {dbus filter add -type signal -path /org/freedesktop/Notifications -interface org.freedesktop.Notifications}
		# listen on mentioned interface and invoke script when there is something going on
		catch {dbus listen /org/freedesktop/Notifications org.freedesktop.Notifications.ActionInvoked dbus_interfaceAction}
		# introspect dbus interfaces
		#~ puts [dbus call -dest org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.DBus.Introspectable Introspect]
		set ::dbus(notification_id) 0
		return 0
	}
	return 0
}

proc dbus_interfaceNotification {icon summary body action hints timeout} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: dbus_interfaceNotification \033\[0m \{$icon\} \{$summary\} \{$body\} \{$action\} \{$hints\} \{$timeout\}"}
	if {$::option(dbusInt) == 1} {
		# make sure dbus is up and running
		set dbusok [dbus_interfaceStart]
		if {$dbusok == 0} {
			catch {dbus call -dest org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus ListNames} names
			if {[lsearch -exact $names org.freedesktop.Notifications] != -1} {
				# make sure last notifications gets closed
				if {$::dbus(notification_id) != 0} {
					catch {dbus call -signature u -dest org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.Notifications CloseNotification $::dbus(notification_id)}
				}
				# send notification
				catch {dbus call -signature susssasa{sv}i -dest org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.Notifications Notify "TV-Viewer" $::dbus(notification_id) $icon "$summary" "$body" "$action" "$hints" $timeout} ::dbus(notification_id)
				if {[string is digit $::dbus(notification_id)] == 0} {
					set ::dbus(notification_id) 0
				}
			} else {
				if {"$::option(appname)" == "tv-viewer_main"} {
					log_writeOut ::log(tvAppend) 2 "Can not access D-Bus notification interface"
					log_writeOut ::log(tvAppend) 2 "$names"
				}
				if {"$::option(appname)" == "tv-viewer_scheduler"} {
					log_writeOut ::log(schedAppend) 2 "Can not access D-Bus notification interface"
					log_writeOut ::log(schedAppend) 2 "$names"
				}
			}
		}
	} else {
		if {"$::option(appname)" == "tv-viewer_main"} {
			log_writeOut ::log(tvAppend) 1 "D-Bus Interface is deactivated"
		}
		if {"$::option(appname)" == "tv-viewer_scheduler"} {
			log_writeOut ::log(schedAppend) 1 "D-Bus Interface is deactivated"
		}
	}
}

proc dbus_interfaceAction {dbusinfo id action} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: dbus_interfaceAction \033\[0m \{$dbusinfo\} \{$id\} \{$action\}"}
	#FIXME Make TV-Viewer react on actions from dbus.
	#~ puts "dbusinfo $dbusinfo"
	#~ puts "id $id"
	#~ puts "action $action"
	#~ puts "::dbus(notification_id) $::dbus(notification_id)"
	if {$id == $::dbus(notification_id)} {
		if {"[string trim $action]" == "tvviewerStart"} {
			if {[file exists $::option(root)/tv-viewer_main.tcl]} {
				exec $::option(root)/tv-viewer_main.tcl &
			}
			if {[file exists $::option(root)/data/tv-viewer_main.tcl]} {
				exec $::option(root)/data/tv-viewer_main.tcl &
			}
		}
		if {"$action" == "tvviewerNewsreader"} {
			set update_news [dict get $::newsreader news content]
			set word_tags [dict get $::newsreader news tags]
			set hyperlinks [dict get $::newsreader news hyperlinks]
			main_newsreaderUi $update_news $word_tags $hyperlinks
			dbus call -signature u -dest org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.Notifications CloseNotification $::dbus(notification_id)
		}
	}
}
