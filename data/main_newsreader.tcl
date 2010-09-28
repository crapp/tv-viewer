#       main_newsreader.tcl
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

proc main_newsreaderCheckUpdate {handler} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_newsreaderCheckUpdate \033\[0m"}
	#handler 0 == check for updates; 1 == autocheck for updates.
	log_writeOutTv 0 "Checking for news..."
	if {$::option(language_value) == 0} {
		set locale_split [string trim [lindex [split $::env(LANG) _] 0]]
		array set locales {
			en english
			de german
		}
		if {[string trim [array get locales $locale_split]] != {}} {
			set status_http [catch {http::geturl "http://tv-viewer.sourceforge.net/newsreader/newsreader_[string trim $locale_split].html"} get_news]
			set lang $locale_split
		} else {
			set status_http [catch {http::geturl "http://tv-viewer.sourceforge.net/newsreader/newsreader_en.html"} get_news]
			set lang en
		}
	} else {
		set status_http [catch {http::geturl "http://tv-viewer.sourceforge.net/newsreader/newsreader_$::option(language_value).html"} get_news]
		set lang $::option(language_value)
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
	set status_http [catch {http::geturl "http://tv-viewer.sourceforge.net/newsreader/underline_words.html"} get_tags]
	if {$status_http == 0} {
		if {[::http::ncode $get_tags] != 404} {
			set status [expr $status + $status_http]
		} else {
			set status 1
		}
	} else {
		set status 1
	}
	set status_http [catch {http::geturl "http://tv-viewer.sourceforge.net/newsreader/html_links.html"} get_links]
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
				if {[string match "*_$lang *" $line]} {
					if {[info exists hyperlinks] == 0} {
						set hyperlinks [dict create [lindex $line 0] "[lindex $line 1]"]
					} else {
						dict lappend hyperlinks [lindex $line 0] "[lindex $line 1]"
					}
				}
			}
			catch {file delete "$::option(home)/config/last_update.date"}
			set date_file [open "$::option(home)/config/last_update.date" w]
			close $date_file
			
			set w [toplevel .top_newsreader]
			place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
			
			set mf [ttk::frame $w.mf]
			set fb [ttk::frame $w.mf.btn -style TLabelframe]
			ttk::label $mf.l_top_newsr -justify left
			text $mf.t_top_newsr -yscrollcommand [list $mf.scrollb_newsr set] -width 0 -height 0
			ttk::scrollbar $mf.scrollb_newsr -command [list $mf.t_top_newsr yview]
			ttk::button $fb.b_newsr_homepage -text [mc "Homepage"] -compound left -image $::icon_s(internet) -command main_newsreaderHomepage
			ttk::button $fb.b_newsr_ok -text [mc "Exit"] -compound left -image $::icon_s(dialog-close) -command [list main_newsreaderExit $w]
			
			grid $mf -in $w -row 0 -column 0
			grid $fb -in $mf -row 2 -column 0 -sticky ew -columnspan 2 -pady 3 -padx 3
			
			grid anchor $fb e
			
			grid $mf.l_top_newsr -in $mf -row 0 -column 0 -sticky ew -columnspan 2
			grid $mf.t_top_newsr -in $mf -row 1 -column 0 -sticky nesw
			grid $mf.scrollb_newsr -in $mf -row 1 -column 1 -sticky nesw
			grid $fb.b_newsr_homepage -in $fb -row 0 -column 0 -pady 7
			grid $fb.b_newsr_ok -in $fb -row 0 -column 1 -padx 3
			
			grid rowconfigure $mf 1 -weight 1 -minsize 350
			grid columnconfigure $mf 0 -weight 1 -minsize 515
			
			autoscroll $mf.scrollb_newsr
			
			bind .top_newsreader <Key-x> {puts [.top_newsreader.mf.t_top_newsr tag ranges _hylinkSF_bazaar_de]}
			bind .top_newsreader <Key-c> {puts [.top_newsreader.mf.t_top_newsr mark current]}
			bind .top_newsreader <Key-v> {puts [.top_newsreader.mf.t_top_newsrmark mark insert]}
			
			wm title $w [mc "Newsreader"]
			wm protocol $w WM_DELETE_WINDOW [list main_newsreaderExit $w]
			wm resizable $w 0 0
			wm iconphoto $w $::icon_b(newsreader)
			
			if {$handler == 1} {
				if {[file exists "$::option(home)/config/last_read.conf"]} {
					set open_last_read [open "$::option(home)/config/last_read.conf" r]
					set open_last_read_content [read $open_last_read]
					close $open_last_read
					if {"$open_last_read_content" == "$update_news"} {
						log_writeOutTv 0 "No newer messages."
						destroy $w
					} else {
						log_writeOutTv 0 "Found newer messages."
						file delete "$::option(home)/config/last_read.conf"
						set open_last_write [open "$::option(home)/config/last_read.conf" w]
						puts -nonewline $open_last_write "$update_news"
						close $open_last_write
						$mf.t_top_newsr insert end "$update_news\n"
						main_newsreaderApplyTags $mf.t_top_newsr $word_tags $hyperlinks 0
						main_newsreaderApplyTags $mf.t_top_newsr $word_tags $hyperlinks 1
						$mf.t_top_newsr configure -state disabled
						tkwait visibility $w
					}
				} else {
					set open_last_write [open "$::option(home)/config/last_read.conf" w]
					puts -nonewline $open_last_write "$update_news"
					close $open_last_write
					$mf.t_top_newsr insert end "$update_news\n"
					main_newsreaderApplyTags $mf.t_top_newsr $word_tags $hyperlinks 0
					main_newsreaderApplyTags $mf.t_top_newsr $word_tags $hyperlinks 1
					$mf.t_top_newsr configure -state disabled
					tkwait visibility $w
				}
			} else {
				file delete "$::option(home)/config/last_read.conf"
				set open_last_write [open "$::option(home)/config/last_read.conf" w]
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
	catch {exec sh -c "xdg-open http://tv-viewer.sourceforge.net/mediawiki/index.php/Main_Page" &}
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
		set hylink_enter "-foreground #0023FF -underline on"
		set hylink_leave "-foreground #0064FF -underline on"
		set search_index 0.0
		foreach {key elem} [dict get $hyperlinks] {
			set index [$textw search -all -exact -- $key $search_index end]
			puts "index $index key $key"
			if {[string trim $index] == {}} continue
			if {[llength $index] > 1} {
				set index [lreverse $index]
				set i 0
				foreach id $index {
					if {[info exists tagIds]} {
						if {[lsearch $tagIds $id] != -1} {
							continue
						} else {
							unset -nocomplain tagIds
						}
					}
					if {[lindex $index [expr $i + 1]] != {}} {
						foreach lid [lrange $index $i end] {
							if {[$textw index "$lid linestart"] == [$textw index "$id linestart"]} {
								lappend tagIds $lid
							}
						}
						puts "tagIds $tagIds"
						if {[llength $tagIds] > 1} {
							for {set forI 0} {$forI < [expr [llength $tagIds] -1]} {incr forI} {
								set wordIndex [$textw index "[lindex $tagIds $forI] wordstart"]
								set wordNextIndex [$textw index "$wordIndex -2c wordstart"]
								puts "forI $forI"
								if {$wordNextIndex == [$textw index "[lindex $tagIds [expr $forI + 1]] wordstart"]} {
									puts [list $wordNextIndex [$textw index "[lindex $tagIds [expr $forI + 1]] wordstart"]]
									if {[info exists tagFusion] == 0} {
										lappend tagFusion [lindex $tagIds $forI]
									}
									lappend tagFusion [lindex $tagIds [expr $forI + 1]]
								}
							}
							puts "tagFusion $tagFusion"
							set tagStart [$textw index "[lindex $tagFusion end] wordstart"]
							set tagEnd [lindex $tagFusion 0]
							puts "tagStart $tagStart tagEnd $tagEnd"
							$textw tag configure [subst $key]($i) -foreground #0064FF -underline on
							$textw tag bind [subst $key]($i) <Any-Enter> "$textw tag configure [subst $key]($i) $hylink_enter; $textw configure -cursor hand1"
							$textw tag bind [subst $key]($i) <Any-Leave> "$textw tag configure [subst $key]($i) $hylink_leave; $textw configure -cursor {}"
							$textw tag bind [subst $key]($i) <Button-1> "catch {exec xdg-open $elem &}"
							$textw tag add [subst $key]($i) $tagStart $tagEnd
							set delI 0
							foreach delTag $tagFusion {
								puts "delTag $delTag"
								if {$delI == 0} {
									$textw delete $delTag "$delTag wordend"
									incr delI
									continue
								}
								$textw delete $delTag "$delTag wordend"
								incr delI
							}
						}
					}
					set tagStart [$textw index "$id wordstart"]
					set tagEnd $id
					puts "tagStart $tagStart tagEnd $tagEnd"
					$textw tag configure [subst $key]($i) -foreground #0064FF -underline on
					$textw tag bind [subst $key]($i) <Any-Enter> "$textw tag configure [subst $key]($i) $hylink_enter; $textw configure -cursor hand1"
					$textw tag bind [subst $key]($i) <Any-Leave> "$textw tag configure [subst $key]($i) $hylink_leave; $textw configure -cursor {}"
					$textw tag bind [subst $key]($i) <Button-1> "catch {exec xdg-open $elem &}"
					$textw tag add [subst $key]($i) $tagStart $tagEnd
					$textw delete $id "$id wordend"
					incr i
				}
			} else {
				$textw tag configure $key -foreground #0064FF -underline on
				$textw tag bind $key <Any-Enter> "$textw tag configure $key $hylink_enter; $textw configure -cursor hand1"
				$textw tag bind $key <Any-Leave> "$textw tag configure $key $hylink_leave; $textw configure -cursor {}"
				$textw tag bind $key <Button-1> "catch {exec xdg-open $elem &}"
				$textw tag add $key "$index wordstar" $index
				$textw delete $index "$index wordend"
			}
		}
	}
}

proc main_newsreaderAutomaticUpdate {} {
	catch {puts $::main(debug_msg) "\033\[0;1;33mDebug: main_newsreaderAutomaticUpdate \033\[0m"}
	if !{[file exists "$::option(home)/config/last_update.date"]} {
		set date_file [open "$::option(home)/config/last_update.date" w]
		close $date_file
		log_writeOutTv 1 "Newsreader started. Can not determine last check. Will check now."
		main_newsreaderCheckUpdate 1
		return
	}
	set actual_date [clock scan [clock format [clock scan now] -format "%Y%m%d"]]
	set last_update [clock scan [clock format [file mtime "$::option(home)/config/last_update.date"] -format "%Y%m%d"]]
	foreach {years months days} [difftime $actual_date $last_update] {}
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
