#       main_newsreader.tcl
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

proc main_newsreaderCheckUpdate {} {
	puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Checking for news..."
	flush $::logf_tv_open_append
	if {[string match de* $::env(LANG)] != 1} {
		set status_http [catch {http::geturl "http://home.arcor.de/saedelaere/tv-viewerfiles/current_eng_neu.html"} get_news]
	} else {
		set status_http [catch {http::geturl "http://home.arcor.de/saedelaere/tv-viewerfiles/current_neu.html"} get_news]
	}
	set status_http [catch {http::geturl "http://home.arcor.de/saedelaere/tv-viewerfiles/underline_words.html"} get_tags]
	if {$status_http == 0} {
		if {[winfo exists .top_newsreader] == 0} {
			set get_current_news [http::data $get_news]
			set get_current_tags [http::data $get_tags]
			http::cleanup $get_news
			http::cleanup $get_tags
			set update_news [join [lrange [split $get_current_news "\n"] 0 end] "\n"]
			set word_tags [join [lrange [split $get_current_tags "\n"] 0 end] "\n"]
			catch {file delete "$::where_is_home/config/last_update.date"}
			set date_file [open "$::where_is_home/config/last_update.date" w]
			close $date_file
			
			set w [toplevel .top_newsreader -class "TV-Viewer"]
			
			place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
			
			set mf [ttk::frame $w.mf]
			set fb [ttk::frame $w.mf.btn \
			-relief groove \
			-borderwidth 2]
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
			if {[info exists ::query_auto_newsreader] == 1} {
				unset ::query_auto_newsreader
				if {[file exists "$::where_is_home/config/last_read.conf"]} {
					set open_last_read [open "$::where_is_home/config/last_read.conf" r]
					set open_last_read_content [read $open_last_read]
					close $open_last_read
					if {"$open_last_read_content" == "$update_news"} {
						puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] No newer messages."
						flush $::logf_tv_open_append
						destroy $w
					} else {
						puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Found newer messages."
						flush $::logf_tv_open_append
						file delete "$::where_is_home/config/last_read.conf"
						set open_last_write [open "$::where_is_home/config/last_read.conf" w]
						puts -nonewline $open_last_write "$update_news"
						close $open_last_write
						$mf.t_top_newsr insert end "$update_news\n"
						$mf.t_top_newsr tag configure new_day -underline on -font "TkTextFont [font actual TkTextFont -displayof $mf.t_top_newsr -size] bold"
						set search_index 0.0
						foreach tag_word [split $word_tags] {
							if {[string trim $tag_word] == {}} continue
							set index [$mf.t_top_newsr search -exact $tag_word $search_index end]
							set word_length [string length $tag_word]
							set index2 "$index + $word_length char"
							$mf.t_top_newsr tag add new_day "$index wordstart" "$index2"
						}
						$mf.t_top_newsr configure -state disabled
						tkwait visibility $w
					}
				} else {
					set open_last_write [open "$::where_is_home/config/last_read.conf" w]
					puts -nonewline $open_last_write "$update_news"
					close $open_last_write
					$mf.t_top_newsr insert end "$update_news\n"
					$mf.t_top_newsr tag configure new_day -underline on -font "TkTextFont [font actual TkTextFont -displayof $mf.t_top_newsr -size] bold"
					set search_index 0.0
					foreach tag_word [split $word_tags] {
						if {[string trim $tag_word] == {}} continue
						set index [$mf.t_top_newsr search -exact $tag_word $search_index end]
						set word_length [string length $tag_word]
						set index2 "$index + $word_length char"
						$mf.t_top_newsr tag add new_day "$index wordstart" "$index2"
					}
					$mf.t_top_newsr configure -state disabled
					tkwait visibility $w
				}
			} else {
				file delete "$::where_is_home/config/last_read.conf"
				set open_last_write [open "$::where_is_home/config/last_read.conf" w]
				puts -nonewline $open_last_write "$update_news"
				close $open_last_write
				$mf.t_top_newsr insert end "$update_news\n"
				$mf.t_top_newsr tag configure new_day -underline on -font "TkTextFont [font actual TkTextFont -displayof $mf.t_top_newsr -size] bold"
				set search_index 0.0
				foreach tag_word [split $word_tags] {
					if {[string trim $tag_word] == {}} continue
					set index [$mf.t_top_newsr search -exact $tag_word $search_index end]
					set word_length [string length $tag_word]
					set index2 "$index + $word_length char"
					$mf.t_top_newsr tag add new_day "$index wordstart" "$index2"
					
				}
				$mf.t_top_newsr configure -state disabled
				tkwait visibility $w
			}
		} else {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Newsreader already opened."
			flush $::logf_tv_open_append
			return
		}
	} else {
		puts $::logf_tv_open_append "# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Can't check for news.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Do you have an active internet connection?"
		flush $::logf_tv_open_append
		return
	}
	
	proc main_newsreaderHomepage {} {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Executing your favorite web browser."
		flush $::logf_tv_open_append
		if {[string match de* $::env(LANG)] != 1} {
			catch {exec xdg-open "http://home.arcor.de/saedelaere/index_eng.html" &}
		} else {
			catch {exec xdg-open "http://home.arcor.de/saedelaere/index.html" &}
		}
	}
	proc main_newsreaderExit {w} {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Closing Newsreader."
		flush $::logf_tv_open_append
		destroy $w
	}
}

proc main_newsreaderAutomaticUpdate {} {
	if !{[file exists "$::where_is_home/config/last_update.date"]} {
		set date_file [open "$::where_is_home/config/last_update.date" w]
		close $date_file
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Newsreader started.
# <*>\[[clock format [clock scan now] -format {%H:%M:%S}]\] Can not determine last check. Will check now."
		flush $::logf_tv_open_append
		set ::query_auto_newsreader 1
		main_newsreaderCheckUpdate
		return
	}
	set actual_date [clock scan [clock format [clock scan now] -format "%Y%m%d"]]
	set last_update [clock scan [clock format [file mtime "$::where_is_home/config/last_update.date"] -format "%Y%m%d"]]
	foreach {years months days} [main_newsreaderDifftimes $actual_date $last_update] {}
	puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Newsreader started.
# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Last check: [clock format $last_update -format "%d.%m.%Y"]
# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Offset: $years Years $months Months $days Days"
	flush $::logf_tv_open_append
	if { $years > 0 } {
		puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] $years Years since last check"
		flush $::logf_tv_open_append
		set ::query_auto_newsreader 1
		main_newsreaderCheckUpdate
		return
	} else {
		if { $months > 0 } {
			puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] $months Months since last check"
			flush $::logf_tv_open_append
			set ::query_auto_newsreader 1
			main_newsreaderCheckUpdate
			return
		} else {
			if { $days >= $::option(newsreader_interval) } {
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] $days Days since last check"
				flush $::logf_tv_open_append
				set ::query_auto_newsreader 1
				main_newsreaderCheckUpdate
				return
			} else {
				puts $::logf_tv_open_append "# \[[clock format [clock scan now] -format {%H:%M:%S}]\] Next automatic check in [expr $::option(newsreader_interval) - $days] day(s)"
				flush $::logf_tv_open_append
			}
		}
	}
}

proc main_newsreaderClockarith { seconds delta units } {
	set stamp [clock format $seconds -format "%Y%m%d"]
	if { $delta < 0 } {
		append stamp " " - [expr { - $delta }] " " $units
	} else {
		append stamp "+ " $delta " " $units
	}
	return [clock scan $stamp]
}

proc main_newsreaderDifftimes { s1 s2 } {

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
