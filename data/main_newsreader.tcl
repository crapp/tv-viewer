#       main_newsreader.tcl
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

proc main_newsreaderCheckUpdate {handler} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_newsreaderCheckUpdate \033\[0m"}
	log_writeOutTv 0 "Checking for news..."
	if {$::option(language_value) == 0} {
		set locale_split [string trim [lindex [split $::env(LANG) _] 0]]
		array set locales {
			en english
			de german
		}
		if {[string trim [array get locales $locale_split]] != {}} {
			set status_http [catch {http::geturl "http://home.arcor.de/saedelaere/tv-viewerfiles/newsreader_[string trim $locale_split].html"} get_news]
		} else {
			set status_http [catch {http::geturl "http://home.arcor.de/saedelaere/tv-viewerfiles/newsreader_en.html"} get_news]
		}
	} else {
		set status_http [catch {http::geturl "http://home.arcor.de/saedelaere/tv-viewerfiles/newsreader_$::option(language_value).html"} get_news]
	}
	if {$status_http == 0} {
		if {[::http::ncode $get_news] != 404} {
			set status $status_http
		} else {
			set status 1
		}
	} else {
		set status 1
	}
	set status_http [catch {http::geturl "http://home.arcor.de/saedelaere/tv-viewerfiles/underline_words.html"} get_tags]
	if {$status_http == 0} {
		if {[::http::ncode $get_tags] != 404} {
			set status [expr $status + $status_http]
		} else {
			set status 1
		}
	} else {
		set status 1
	}
	set status_http [catch {http::geturl "http://home.arcor.de/saedelaere/tv-viewerfiles/html_links.html"} get_links]
	if {$status_http == 0} {
		if {[::http::ncode $get_links] != 404} {
			set status [expr $status + $status_http]
		} else {
			set status 1
		}
	} else {
		set status 1
	}
	if {$status == 0} {
		if {[winfo exists .top_newsreader] == 0} {
			set get_current_news [http::data $get_news]
			set get_current_tags [http::data $get_tags]
			set get_current_links [http::data $get_links]
			http::cleanup $get_news
			http::cleanup $get_tags
			http::cleanup $get_links
			set update_news [join [lrange [split $get_current_news "\n"] 0 end] "\n"]
			set word_tags [join [lrange [split $get_current_tags "\n"] 0 end] "\n"]
			foreach line [split $get_current_links \n] {
				if {[string trim $line] == {}} continue
				if {[info exists hyperlinks] == 0} {
					set hyperlinks [dict create [lindex $line 0] "[lindex $line 1]"]
				} else {
					dict lappend hyperlinks [lindex $line 0] "[lindex $line 1]"
				}
			}
			catch {file delete "$::option(where_is_home)/config/last_update.date"}
			set date_file [open "$::option(where_is_home)/config/last_update.date" w]
			close $date_file
			
			set w [toplevel .top_newsreader -class "TV-Viewer"]
			
			place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
			
			set mf [ttk::frame $w.mf]
			set fb [ttk::frame $w.mf.btn -style TLabelframe]
			ttk::label $mf.l_top_newsr \
			-justify left
			text $mf.t_top_newsr \
			-yscrollcommand [list $mf.scrollb_newsr set] \
			-width 0 \
			-height 0
			ttk::scrollbar $mf.scrollb_newsr \
			-command [list $mf.t_top_newsr yview]
			ttk::button $fb.b_newsr_homepage \
			-text [mc "Homepage"] \
			-compound left \
			-image $::icon_s(internet) \
			-command main_newsreaderHomepage
			ttk::button $fb.b_newsr_ok \
			-text [mc "Exit"] \
			-compound left \
			-image $::icon_s(dialog-close) \
			-command [list main_newsreaderExit $w]
			
			grid $mf -in $w -row 0 -column 0
			grid $fb -in $mf -row 2 -column 0 \
			-sticky ew \
			-columnspan 2 \
			-pady 3 \
			-padx 3
			
			grid anchor $fb e
			
			grid $mf.l_top_newsr -in $mf -row 0 -column 0 \
			-sticky ew \
			-columnspan 2
			grid $mf.t_top_newsr -in $mf -row 1 -column 0 \
			-sticky nesw
			grid $mf.scrollb_newsr -in $mf -row 1 -column 1 \
			-sticky nesw
			grid $fb.b_newsr_homepage -in $fb -row 0 -column 0 \
			-pady 7
			grid $fb.b_newsr_ok -in $fb -row 0 -column 1 \
			-padx 3
			
			grid rowconfigure $mf 1 -weight 1 -minsize 350
			grid columnconfigure $mf 0 -weight 1 -minsize 515
			
			autoscroll $mf.scrollb_newsr
			
			wm title $w [mc "Newsreader"]
			wm protocol $w WM_DELETE_WINDOW [list main_newsreaderExit $w]
			wm resizable $w 0 0
			wm iconphoto $w $::icon_b(newsreader)
			
			if {$handler == 1} {
				if {[file exists "$::option(where_is_home)/config/last_read.conf"]} {
					set open_last_read [open "$::option(where_is_home)/config/last_read.conf" r]
					set open_last_read_content [read $open_last_read]
					close $open_last_read
					if {"$open_last_read_content" == "$update_news"} {
						log_writeOutTv 0 "No newer messages."
						destroy $w
					} else {
						log_writeOutTv 0 "Found newer messages."
						file delete "$::option(where_is_home)/config/last_read.conf"
						set open_last_write [open "$::option(where_is_home)/config/last_read.conf" w]
						puts -nonewline $open_last_write "$update_news"
						close $open_last_write
						$mf.t_top_newsr insert end "$update_news\n"
						main_newsreaderApplyTags $mf.t_top_newsr $word_tags $hyperlinks 0
						main_newsreaderApplyTags $mf.t_top_newsr $word_tags $hyperlinks 1
						$mf.t_top_newsr configure -state disabled
						tkwait visibility $w
					}
				} else {
					set open_last_write [open "$::option(where_is_home)/config/last_read.conf" w]
					puts -nonewline $open_last_write "$update_news"
					close $open_last_write
					$mf.t_top_newsr insert end "$update_news\n"
					main_newsreaderApplyTags $mf.t_top_newsr $word_tags $hyperlinks 0
					main_newsreaderApplyTags $mf.t_top_newsr $word_tags $hyperlinks 1
					$mf.t_top_newsr configure -state disabled
					tkwait visibility $w
				}
			} else {
				file delete "$::option(where_is_home)/config/last_read.conf"
				set open_last_write [open "$::option(where_is_home)/config/last_read.conf" w]
				puts -nonewline $open_last_write "$update_news"
				close $open_last_write
				$mf.t_top_newsr insert end "$update_news\n"
				main_newsreaderApplyTags $mf.t_top_newsr $word_tags $hyperlinks 0
				main_newsreaderApplyTags $mf.t_top_newsr $word_tags $hyperlinks 1
				$mf.t_top_newsr configure -state disabled
				tkwait visibility $w
			}
		} else {
			log_writeOutTv 1 "Newsreader already opened."
			return
		}
	} else {
		log_writeOutTv 2 "Can't check for news. Do you have an active internet connection?"
		return
	}
}

proc main_newsreaderExit {w} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_newsreaderExit \033\[0m \{$w\}"}
	log_writeOutTv 0 "Closing Newsreader."
	destroy $w
}

proc main_newsreaderHomepage {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_newsreaderHomepage \033\[0m"}
	log_writeOutTv 0 "Executing your favorite web browser."
	if {[string match de* $::env(LANG)] != 1} {
		catch {exec xdg-open "http://home.arcor.de/saedelaere/index_eng.html" &}
	} else {
		catch {exec xdg-open "http://home.arcor.de/saedelaere/index.html" &}
	}
}

proc main_newsreaderApplyTags {textw word_tags hyperlinks handler} {
	if {$handler == 0} {
		$textw tag configure new_day -underline on -font "TkTextFont [font actual TkTextFont -displayof $textw -size] bold"
		set search_index 0.0
		foreach tag_word [split $word_tags] {
			if {[string trim $tag_word] == {}} continue
			set index [$textw search -exact $tag_word $search_index end]
			if {[string trim $index] == {}} continue
			set word_length [string length $tag_word]
			set index2 "$index + $word_length char"
			$textw tag add new_day "$index wordstart" "$index2"
		}
	}
	if {$handler == 1} {
		set hylink_enter "-foreground #0023FF -underline off"
		set hylink_leave "-foreground #0064FF -underline on"
		foreach {key elem} [dict get $hyperlinks] {
			$textw tag configure $key -foreground #0064FF -underline on
			$textw tag bind $key <Any-Enter> "$textw tag configure $key $hylink_enter; $textw configure -cursor hand1"
			$textw tag bind $key <Any-Leave> "$textw tag configure $key $hylink_leave; $textw configure -cursor {}"
			$textw tag bind $key <Button-1> "catch {exec xdg-open $elem &}"
		}
		set search_index 0.0
		foreach {key elem} [dict get $hyperlinks] {
			set index [$textw search -exact $key $search_index end]
			if {[string trim $index] == {}} continue
			$textw tag add $key "$index wordstar" $index
			$textw delete $index "$index wordend"
		}
	}
}

proc main_newsreaderAutomaticUpdate {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_newsreaderAutomaticUpdate \033\[0m"}
	if !{[file exists "$::option(where_is_home)/config/last_update.date"]} {
		set date_file [open "$::option(where_is_home)/config/last_update.date" w]
		close $date_file
		log_writeOutTv 1 "Newsreader started. Can not determine last check. Will check now."
		main_newsreaderCheckUpdate 1
		return
	}
	set actual_date [clock scan [clock format [clock scan now] -format "%Y%m%d"]]
	set last_update [clock scan [clock format [file mtime "$::option(where_is_home)/config/last_update.date"] -format "%Y%m%d"]]
	foreach {years months days} [main_newsreaderDifftimes $actual_date $last_update] {}
	log_writeOutTv 0 "Newsreader started"
	log_writeOutTv 0 "Last check: [clock format $last_update -format {%d.%m.%Y}]"
	log_writeOutTv 0 "Offset: $years Year(s) $months Month(s) $days Day(s)"
	if { $years > 0 } {
		log_writeOutTv 0 "$years Year(s) since last check"
		main_newsreaderCheckUpdate 1
		return
	} else {
		if { $months > 0 } {
			log_writeOutTv 0 "$months Month(s) since last check"
			main_newsreaderCheckUpdate 1
			return
		} else {
			if { $days >= $::option(newsreader_interval) } {
				log_writeOutTv 0 "$days Day(s) since last check"
				main_newsreaderCheckUpdate 1
				return
			} else {
				log_writeOutTv 0 "Next automatic check in [expr $::option(newsreader_interval) - $days] day(s)"
			}
		}
	}
}

proc main_newsreaderClockarith { seconds delta units } {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_newsreaderClockarith \033\[0m \{$seconds\} \{$delta\} \{$units\}"}
	set stamp [clock format $seconds -format "%Y%m%d"]
	if { $delta < 0 } {
		append stamp " " - [expr { - $delta }] " " $units
	} else {
		append stamp "+ " $delta " " $units
	}
	return [clock scan $stamp]
}

proc main_newsreaderDifftimes { s1 s2 } {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_newsreaderDifftimes \033\[0m \{$s1\} \{$s2\}"}

	set y1 [clock format $s1 -format %Y]
	set y2 [clock format $s2 -format %Y]
	set y [expr { $y1 - $y2 - 1 }]

	set s2new $s2
	set yOut $y

	set s [main_newsreaderClockarith $s2 $y years]
	while { $s <= $s1 } {
		set s2new $s
		set yOut $y
		incr y
		set s [main_newsreaderClockarith $s2 $y years]
	}
	set s2 $s2new

	set m 0
	set mOut 0
	set s [main_newsreaderClockarith $s2 $m months]
	while { $s <= $s1 } {
		set s2new $s
		set mOut $m
		incr m
		set s [main_newsreaderClockarith $s2 $m months]
	}
	set s2 $s2new

	set d [expr { ( ( $s2 - $s1 ) / 86400 ) - 1 }]
	set dOut $d
	set s [main_newsreaderClockarith $s2 $d days]
	while { $s <= $s1 } {
		set s2new $s
		set dOut $d
		incr d
		set s [main_newsreaderClockarith $s2 $d days]
	}
	set s2 $s2new

	return [list $yOut $mOut $dOut]
}
