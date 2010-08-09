#       config_video.tcl
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

proc option_screen_3 {} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: option_screen_3 \033\[0m"
	
	# Setting up the interface
	
	foreach tab [split [.config_wizard.frame_configoptions.nb tabs]] {
		.config_wizard.frame_configoptions.nb hide $tab
	}
	
	if {[winfo exists .config_wizard.frame_configoptions.nb.f_video]} {
		if {[winfo exists .config_wizard.frame_configoptions.nb.f_video_error]} {
			.config_wizard.frame_configoptions.nb add $::window(video_nb1)
			.config_wizard.frame_configoptions.nb add $::window(video_nb2)
			.config_wizard.frame_configoptions.nb select $::window(video_nb2)
			.config_wizard.frame_configoptions.nb tab $::window(video_nb1) -state disabled
			.config_wizard.frame_buttons.b_default configure -command {}
		} else {
			.config_wizard.frame_configoptions.nb add $::window(video_nb1)
			.config_wizard.frame_configoptions.nb select $::window(video_nb1)
			.config_wizard.frame_buttons.b_default configure -command [list stnd_opt3 $::window(video_nb1)]
			bind $::window(video_nb1_cont) <Map> {
				$::window(video_nb1_cont) itemconfigure cont_video_nb1 -width [winfo width $::window(video_nb1_cont)] -height [winfo reqheight $::window(video_nb1_cont).f_video2]
				$::window(video_nb1_cont) configure -scrollregion [$::window(video_nb1_cont) bbox all]
				$::window(video_nb1_cont) yview moveto 0
			}
		}
	} else {
		log_writeOutTv 0 "Setting up video section in preferences."
		set w .config_wizard.frame_configoptions.nb
		
		set ::window(video_nb1) [ttk::frame $w.f_video]
		$w add $::window(video_nb1) -text [mc "Video Settings"] -padding 2
		set ::window(video_nb1_cont) [canvas $::window(video_nb1).c_cont -yscrollcommand [list $::window(video_nb1).scrollb_cont set] -highlightthickness 0]
		ttk::scrollbar $::window(video_nb1).scrollb_cont -command [list $::window(video_nb1).c_cont yview]
		$::window(video_nb1_cont) create window 0 0 -window [ttk::frame $::window(video_nb1_cont).f_video2] -anchor w -tags cont_video_nb1
		set frame_nb1  "$::window(video_nb1_cont).f_video2"
		
		ttk::labelframe $frame_nb1.lf_mplayer -text [mc "Video"]
		ttk::label $frame_nb1.l_lf_vo -text [mc "Video output driver"]
		ttk::menubutton $frame_nb1.mb_lf_vo -menu $::window(video_nb1).mbVo -textvariable choice(mbVo)
		menu $::window(video_nb1).mbVo -tearoff 0 -background $::option(theme_$::option(use_theme))
		ttk::label $frame_nb1.l_lf_deint -text [mc "Deinterlacing filter"]
		ttk::menubutton $frame_nb1.mb_lf_deint -menu $::window(video_nb1).mbDeint -textvariable choice(mbDeint)
		menu $::window(video_nb1).mbDeint -tearoff 0 -background $::option(theme_$::option(use_theme))
		ttk::label $frame_nb1.l_lf_autoq -text [mc "Postprocessing level"]
		spinbox $frame_nb1.sb_lf_autoq -from 0 -to 6 -state readonly -textvariable choice(sb_autoq)
		ttk::label $frame_nb1.l_lf_cache -text [mc "Cache size (kb)"]
		ttk::menubutton $frame_nb1.mb_lf_cache -menu $::window(video_nb1).mbCache -textvariable choice(mbCache)
		menu $::window(video_nb1).mbCache -tearoff 0 -background $::option(theme_$::option(use_theme))
		ttk::label $frame_nb1.l_lf_threads -text [mc "Threads for decoding"]
		spinbox $frame_nb1.sb_lf_threads -state readonly -from 1 -to 8 -textvariable choice(sb_threads)
		
		ttk::separator $frame_nb1.sp_lf_mplayer -orient horizontal
		
		ttk::checkbutton $frame_nb1.cb_lf_dr -text [mc "Direct Rendering"] -variable choice(cb_dr)
		ttk::checkbutton $frame_nb1.cb_lf_double -text [mc "Double Buffering"] -variable choice(cb_double)
		ttk::checkbutton $frame_nb1.cb_lf_slice -text [mc "Slice Mode"] -variable choice(cb_slice)
		ttk::checkbutton $frame_nb1.cb_lf_framedrop -text [mc "Framedrop"] -variable choice(cb_framedrop) -command [list config_videoFramedrop 0]
		ttk::checkbutton $frame_nb1.cb_lf_hframedrop -text [mc "Hard Framedrop"] -variable choice(cb_hframedrop) -command [list config_videoFramedrop 1]
		ttk::checkbutton $frame_nb1.cb_lf_screensaver -text [mc "Disable Screensaver"] -variable choice(cb_lf_screensaver) -command [list config_videoScreensaver $frame_nb1]
		ttk::labelframe $frame_nb1.lf_screensaver -labelwidget $frame_nb1.cb_lf_screensaver
		ttk::radiobutton $frame_nb1.rb_lf_mplayer_screens -text [mc "Use MPlayer"] -variable choice(rb_screensaver) -value 0
		ttk::radiobutton $frame_nb1.rb_lf_heartbeat_screens -text [mc "Use Heartbeat function"] -variable choice(rb_screensaver) -value 1
		
		grid columnconfigure $::window(video_nb1) 0 -weight 1
		grid columnconfigure $frame_nb1 0 -weight 1
		grid columnconfigure $frame_nb1.lf_mplayer {1} -weight 1
		
		grid rowconfigure $::window(video_nb1) 0 -weight 1
		
		grid $::window(video_nb1_cont) -in $::window(video_nb1) -row 0 -column 0 -sticky nesw
		grid $::window(video_nb1).scrollb_cont -in $::window(video_nb1) -row 0 -column 1 -sticky ns
		
		grid $frame_nb1.lf_mplayer -in $frame_nb1 -row 0 -column 0 -sticky ew -padx 5 -pady "5 0"
		grid $frame_nb1.l_lf_vo -in $frame_nb1.lf_mplayer -row 0 -column 0 -sticky w -padx 7 -pady "3 0"
		grid $frame_nb1.mb_lf_vo -in $frame_nb1.lf_mplayer -row 0 -column 1 -sticky ew -padx "7" -pady "3 0"
		grid $frame_nb1.l_lf_deint -in $frame_nb1.lf_mplayer -row 1 -column 0 -sticky w -padx 7 -pady "3 0"
		grid $frame_nb1.mb_lf_deint -in $frame_nb1.lf_mplayer -row 1 -column 1 -sticky ew -padx "7" -pady "3 0"
		grid $frame_nb1.l_lf_autoq -in $frame_nb1.lf_mplayer -row 2 -column 0 -sticky w -padx 7 -pady "3 0"
		grid $frame_nb1.sb_lf_autoq -in $frame_nb1.lf_mplayer -row 2 -column 1 -sticky ew -padx "7" -pady "3 0"
		grid $frame_nb1.l_lf_cache -in $frame_nb1.lf_mplayer -row 3 -column 0 -sticky w -padx 7 -pady "3 0"
		grid $frame_nb1.mb_lf_cache -in $frame_nb1.lf_mplayer -row 3 -column 1 -sticky ew -padx "7" -pady "3 0"
		grid $frame_nb1.l_lf_threads -in $frame_nb1.lf_mplayer -row 4 -column 0 -sticky w -padx 7 -pady "3 0"
		grid $frame_nb1.sb_lf_threads -in $frame_nb1.lf_mplayer -row 4 -column 1 -sticky ew -padx "7" -pady "3 0"
		grid $frame_nb1.sp_lf_mplayer -in $frame_nb1.lf_mplayer -row 5 -column 0 -sticky ew -padx 7 -pady "5 0" -columnspan 2
		grid $frame_nb1.cb_lf_dr -in $frame_nb1.lf_mplayer -row 6 -column 0 -sticky w -padx 7 -pady "5 0"
		grid $frame_nb1.cb_lf_double -in $frame_nb1.lf_mplayer -row 6 -column 1 -sticky w -padx "7 0" -pady "5 0"
		grid $frame_nb1.cb_lf_slice -in $frame_nb1.lf_mplayer -row 7 -column 0 -sticky w -padx "7 0" -pady "3 0"
		grid $frame_nb1.cb_lf_framedrop -in $frame_nb1.lf_mplayer -row 8 -column 0 -sticky w -padx "7 0" -pady "5 0"
		grid $frame_nb1.cb_lf_hframedrop -in $frame_nb1.lf_mplayer -row 8 -column 1 -sticky w -padx "7" -pady "5 0"
		grid $frame_nb1.lf_screensaver -in $frame_nb1 -row 1 -column 0 -sticky ew -padx 5 -pady "5"
		grid $frame_nb1.rb_lf_mplayer_screens -in $frame_nb1.lf_screensaver -row 0 -column 0 -sticky w -padx "7 0" -pady "5 0"
		grid $frame_nb1.rb_lf_heartbeat_screens -in $frame_nb1.lf_screensaver -row 0 -column 1 -sticky w -padx "7 0" -pady "5 0"
		
		#Additional Code
		if {[string trim [auto_execok mplayer]] == {}} {
			log_writeOutTv 2 "Could not detect MPlayer."
			log_writeOutTv 2 "Please check the system requirements!"
			$w tab $::window(video_nb1) -state disabled
			set ::window(video_nb2) [ttk::frame $w.f_video_error]
			$w add $::window(video_nb2) -text [mc "Error"]
			ttk::labelframe $::window(video_nb2).lf_video_error -text [mc "Missing requirements"]
			ttk::label $::window(video_nb2).l_error -text [mc "Could not detect all necessary tools to run TV-Viewer"] -compound left -image $::icon_m(dialog-warning)
			ttk::label $::window(video_nb2).l_error_mplayer -text "MPlayer >= 1.0rc2" -justify left
			ttk::label $::window(video_nb2).l_error_mplayer_img -justify left -image $::icon_s(dialog-error)
			
			grid $::window(video_nb2).l_error -in $::window(video_nb2) -row 0 -column 0 -pady 10
			grid $::window(video_nb2).lf_video_error -in $::window(video_nb2) -row 1 -column 0 -pady 10 -padx 5 -sticky ew
			grid $::window(video_nb2).l_error_mplayer -in $::window(video_nb2).lf_video_error -row 0 -column 0 -pady 5 -padx "7 0"
			grid $::window(video_nb2).l_error_mplayer_img -in $::window(video_nb2).lf_video_error -row 0 -column 1 -pady 5 -padx "7 0"
			
			grid columnconfigure $::window(video_nb2) 0 -weight 1
			
			.config_wizard.frame_buttons.b_default configure -command {}
			.config_wizard.frame_buttons.button_save state disabled
		} else {
			catch {exec mplayer} mplayer_ver
			set agrep_mpl_ver [catch {agrep -m "$mplayer_ver" "MPlayer"} resultat_mpl_ver]
			if {$agrep_mpl_ver == 0} {
				set first [string first $resultat_mpl_ver r]
				set revision [info_helpMplayerRev $first "$resultat_mpl_ver"]
				if {$revision != -1} {
					log_writeOutTv 0 "Found MPlayer: SVN r$revision"
				} else {
					log_writeOutTv 1 "Found MPlayer, but could not read SVN revision."
					log_writeOutTv 1 "$resultat_mpl_ver"
				}
			} else {
				log_writeOutTv 1 "Found MPlayer, but could not detect Version"
				log_writeOutTv 1 "$resultat_mpl_ver"
			}
			
			.config_wizard.frame_buttons.b_default configure -command [list stnd_opt3 $frame_nb1]
			
			foreach scrollw [winfo children $::window(video_nb1_cont).f_video2] {
			bind $scrollw <Button-4> {config_videoMousew 120}
			bind $scrollw <Button-5> {config_videoMousew -120}
			}
			bind $::window(video_nb1_cont).f_video2  <Button-4> {config_videoMousew 120}
			bind $::window(video_nb1_cont).f_video2  <Button-5> {config_videoMousew -120}
			
			proc config_videoScreensaver {w} {
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_videoScreensaver \033\[0m \{$w\}"
				if {$::choice(cb_lf_screensaver) == 0} {
					$w.rb_lf_mplayer_screens state disabled
					$w.rb_lf_heartbeat_screens state disabled
				} else {
					$w.rb_lf_mplayer_screens state !disabled
					$w.rb_lf_heartbeat_screens state !disabled
				}
			}
			
			proc config_videoFramedrop {com} {
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_videoFramedrop \033\[0m \{$com\}"
				if {$com == 0 && $::choice(cb_framedrop) == 1} {
					set ::choice(cb_hframedrop) 0
					return
				}
				if {$com == 1 && $::choice(cb_hframedrop) == 1} {
					set ::choice(cb_framedrop) 0
					return
				}
			}
			
			proc config_videoMousew {delta} {
				puts $::main(debug_msg) "\033\[0;1;33mDebug: config_videoMousew \033\[0m \{$delta\}"
				$::window(video_nb1_cont) yview scroll [expr {-$delta/120}] units
			}
			
			proc default_opt3 {w} {
				puts $::main(debug_msg) "\033\[0;1;33mDebug: default_opt3 \033\[0m \{$w\}"
				log_writeOutTv 0 "Starting to collect data for video section."
				set vo [list x11 xv xvmc vdpau gl gl(fast) {gl(fast ATI)} gl(yuv) gl2 gl2(yuv)]
				set deint [list None Lowpass5 Yadif Yadif(1) LinearBlend {Kernel deinterlacer}]
				set cache {0 512 1024 2048 4096 8192 16384}
				
				foreach velem [split [join $vo \n] \n] {
					$w.mbVo add radiobutton -label $velem -variable choice(mbVo)
				}
				
				catch {exec sh -c "xvinfo"} read_xvinfo
				set status_grep_xv [catch {agrep -w "$read_xvinfo" Adaptor} resultat_grep_xv]
				if {$status_grep_xv == 0} {
					set test " [lindex $resultat_grep_xv 2]" 
					set i 2
					foreach line [split $resultat_grep_xv \n] {
						$w.mbVo insert $i radiobutton -label "xv adaptor=[string trim [lindex $resultat_grep_xv 1] #:] - [lindex $resultat_grep_xv 2]" -variable choice(mbVo)
						incr i
						log_writeOutTv 0 "xvinfo reports found adaptor: [lindex $resultat_grep_xv 2]"
					}
				}
				
				if {[info exists ::option(player_vo)]} {
					set ::choice(mbVo) $::option(player_vo)
				} else {
					set ::choice(mbVo) $::stnd_opt(player_vo)
				}
				
				foreach delem [split [join $deint \n] \n] {
					$w.mbDeint add radiobutton -label $delem -variable choice(mbDeint)
				}
				
				if {[info exists ::option(player_deint)]} {
					set ::choice(mbDeint) $::option(player_deint)
				} else {
					set ::choice(mbDeint) $::stnd_opt(player_deint)
				}
				
				if {[info exists ::option(player_autoq)]} {
					set ::choice(sb_autoq) $::option(player_autoq)
				} else {
					set ::choice(sb_autoq) $::stnd_opt(player_autoq)
				}
				
				foreach celem [split $cache] {
					$w.mbCache add radiobutton -label $celem -variable choice(mbCache)
				}
				
				if {[info exists ::option(player_cache)]} {
					set ::choice(mbCache) $::option(player_cache)
				} else {
					set ::choice(mbCache) $::stnd_opt(player_cache)
				}
				
				if {[info exists ::option(player_threads)]} {
					set ::choice(sb_threads) $::option(player_threads)
				} else {
					set ::choice(sb_threads) $::stnd_opt(player_threads)
				}
				
				if {[info exists ::option(player_dr)]} {
					set ::choice(cb_dr) $::option(player_dr)
				} else {
					set ::choice(cb_dr) $::stnd_opt(player_dr)
				}
				
				if {[info exists ::option(player_double)]} {
					set ::choice(cb_double) $::option(player_double)
				} else {
					set ::choice(cb_double) $::stnd_opt(player_double)
				}
				
				if {[info exists ::option(player_slice)]} {
					set ::choice(cb_slice) $::option(player_slice)
				} else {
					set ::choice(cb_slice) $::stnd_opt(player_slice)
				}
				
				if {[info exists ::option(player_fd)]} {
					set ::choice(cb_framedrop) $::option(player_fd)
				}
				if {[info exists ::option(player_hfd)]} {
					set ::choice(cb_hframedrop) $::option(player_hfd)
				}
				if {[info exists ::option(player_fd)] == 0 && [info exists ::option(player_hfd)] == 0} {
					set ::choice(cb_framedrop) $::stnd_opt(player_fd)
				}
				
				if {[info exists ::option(player_screens)]} {
					set ::choice(cb_lf_screensaver) $::option(player_screens)
				} else {
					set ::choice(cb_lf_screensaver) $::stnd_opt(player_screens)
				}
				
				if {[info exists ::option(player_screens_value)]} {
					set ::choice(rb_screensaver) $::option(player_screens_value)
				} else {
					set ::choice(rb_screensaver) $::stnd_opt(player_screens_value)
				}
				config_videoScreensaver $::window(video_nb1_cont).f_video2
				
				if {$::option(tooltips) == 1} {
					if {$::option(tooltips_wizard) == 1} {
						set frame_nb1  "$::window(video_nb1_cont).f_video2"
						settooltip $::window(video_nb1_cont).f_video2.mb_lf_vo [mc "Select the video ouput driver.
xv should provide the best performance."]
						settooltip $::window(video_nb1_cont).f_video2.mb_lf_deint [mc "Select the deinterlace filter."]
						settooltip $::window(video_nb1_cont).f_video2.sb_lf_autoq [mc "Changes the level of postprocesseing.
A value of 0 deactivates postprocessing."]
						settooltip $::window(video_nb1_cont).f_video2.mb_lf_cache [mc "Specify how much memory (in kBytes) should be used for TV playback.
The lower this value is the faster you may switch between stations.
But a low value could cause other problems.
A value of 0 will deactivate cache use."]
						settooltip $frame_nb1.sb_lf_threads [mc "Sets the number of threads for decoding."]
						settooltip $::window(video_nb1_cont).f_video2.cb_lf_dr [mc "If checked, enables direct rendering. This is not supported
for all video ouput drivers."]
						settooltip $::window(video_nb1_cont).f_video2.cb_lf_double [mc "Double buffering fixes flicker by storing two frames in memory
and displaying one, while decoding another."]
						settooltip $::window(video_nb1_cont).f_video2.cb_lf_slice [mc "Enable / Disable drawing video by 16-pixel height slices/bands.
May help in better video playback."]
						settooltip $::window(video_nb1_cont).f_video2.cb_lf_framedrop [mc "Skip displaying some frames to maintain A/V sync."]
						settooltip $::window(video_nb1_cont).f_video2.cb_lf_hframedrop [mc "More intense frame dropping. May lead to image distortion."]
						settooltip $::window(video_nb1_cont).f_video2.cb_lf_screensaver [mc "Enable / Disable screensaver while playback."]
						settooltip $::window(video_nb1_cont).f_video2.rb_lf_mplayer_screens [mc "Use MPlayer to deactivate the screensaver."]
						settooltip $::window(video_nb1_cont).f_video2.rb_lf_heartbeat_screens [mc "If MPlayer can't deactivate your screensaver, use this heartbeat hack."]
					} else {
						set frame_nb1  "$::window(video_nb1_cont).f_video2"
						settooltip $::window(video_nb1_cont).f_video2.mb_lf_vo {}
						settooltip $::window(video_nb1_cont).f_video2.mb_lf_deint {}
						settooltip $::window(video_nb1_cont).f_video2.sb_lf_autoq {}
						settooltip $::window(video_nb1_cont).f_video2.mb_lf_cache {}
						settooltip $frame_nb1.sb_lf_threads {}
						settooltip $::window(video_nb1_cont).f_video2.cb_lf_dr {}
						settooltip $::window(video_nb1_cont).f_video2.cb_lf_double {}
						settooltip $::window(video_nb1_cont).f_video2.cb_lf_slice {}
						settooltip $::window(video_nb1_cont).f_video2.cb_lf_framedrop {}
						settooltip $::window(video_nb1_cont).f_video2.cb_lf_hframedrop {}
						settooltip $::window(video_nb1_cont).f_video2.cb_lf_screensaver {}
						settooltip $::window(video_nb1_cont).f_video2.rb_lf_mplayer_screens {}
						settooltip $::window(video_nb1_cont).f_video2.rb_lf_heartbeat_screens {}
					}
				}
			}
			
			proc stnd_opt3 {w} {
				puts $::main(debug_msg) "\033\[0;1;33mDebug: stnd_opt3 \033\[0m \{$w\}"
				log_writeOutTv 1 "Setting video options to default."
				set ::choice(mbVo) $::stnd_opt(player_vo)
				set ::choice(mbDeint) $::stnd_opt(player_deint)
				set ::choice(sb_autoq) $::stnd_opt(player_autoq)
				set ::choice(mbCache) $::stnd_opt(player_cache)
				set ::choice(sb_threads) $::stnd_opt(player_threads)
				set ::choice(cb_dr) $::stnd_opt(player_dr)
				set ::choice(cb_double) $::stnd_opt(player_double)
				set ::choice(cb_slice) $::stnd_opt(player_slice)
				set ::choice(cb_framedrop) $::stnd_opt(player_fd)
				set ::choice(cb_lf_screensaver) $::stnd_opt(player_screens)
				set ::choice(rb_screensaver) $::stnd_opt(player_screens_value)
				config_videoScreensaver $::window(video_nb1_cont).f_video2
			}
			default_opt3 $::window(video_nb1)
		}
	}
}
