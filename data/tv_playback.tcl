#       tv_playback.tcl
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

proc tv_Playback {tv_bg tv_cont handler file} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_Playback \033\[0m \{$tv_bg\} \{$tv_cont\} \{$handler\} \{$file\}"
	array set vopt {
		x11 {-vo x11 -zoom}
		xv {-vo xv}
		xvmc {-vo xvmc:bobdeint -vc ffmpeg12mc}
		vdpau {-vo vdpau:deint=4 -vc ffmpeg12vdpau}
		gl {-vo gl}
		gl(fast) {-vo gl:yuv=2:force-pbo}
		{gl(fast ATI)} {-vo gl:yuv=2:force-pbo:ati-hack}
		gl(yuv) {-vo gl:yuv=3}
		gl2 {-vo gl2}
		gl2(yuv) {-vo gl2:yuv=3}
	}
	
	array set dopt {
		None {-vf }
		Lowpass5 {-vf pp=l5}
		Yadif {-vf yadif}
		Yadif(1) {-vf yadif=1}
		LinearBlend {-vf pp=lb}
		{Kernel deinterlacer} {-vf kerndeint=5}
	}
	
	array set copt {
		0 {}
		512 {-cache 512}
		1024 {-cache 1024}
		2048 {-cache 2048}
		4096 {-cache 4096}
		8192 {-cache 8192}
		16384 {-cache 16384}
	}
	
	array set cbopt {
		dr(0) {-nodr}
		dr(1) {-dr}
		double(0) {-nodouble}
		double(1) {-double}
		slice(0) {-noslices}
		slice(1) {-slices}
		fd(0) {}
		fd(1) {-framedrop}
		hfd(0) {}
		hfd(1) {-hardframedrop}
		autoq(0) {}
		autoq(1) {,pp -autoq 1}
		autoq(2) {,pp -autoq 2}
		autoq(3) {,pp -autoq 3}
		autoq(4) {,pp -autoq 4}
		autoq(5) {,pp -autoq 5}
		autoq(6) {,pp -autoq 6}
		softvol(0) {}
		softvol(1) {-softvol}
		monpixaspect(0) {-monitoraspect}
		monpixaspect(1) {-monitorpixelaspect}
		mplayconf(0) {}
		mplayconf(1) {-noconfig all}
		scrshot(0) {}
		scrshot(1) {screenshot,}
		threads(1) {}
		threads(2) {-lavdopts threads=2}
		threads(3) {-lavdopts threads=3}
		threads(4) {-lavdopts threads=4}
		threads(5) {-lavdopts threads=5}
		threads(6) {-lavdopts threads=6}
		threads(7) {-lavdopts threads=7}
		threads(8) {-lavdopts threads=8}
	}
	
	array set playdelay {
		0 2000
		512 2000
		1024 2000
		2048 2000
		4096 3000
		8192 8000
		16384 18000
	}
	
	bind . <<teleview>> {}
	bind .tv <<teleview>> {}
	
	if {$file == 0} {
		lappend mcommand {*}[auto_execok mplayer] -quiet -slave
	} else {
		lappend mcommand {*}[auto_execok mplayer] -quiet -slave -identify
	}
	
	lappend mcommand {*}$cbopt(mplayconf\($::option(player_mconfig)\))
	
	if {[string match *adaptor* $::option(player_vo)] == 1} {
		lappend mcommand -vo xv:[lindex $::option(player_vo) 1]
	} else {
		lappend mcommand {*}$vopt($::option(player_vo))
	}
	
	if {[string trim [lindex $::option(player_audio) 1]] != {} && [string is double [lindex $::option(player_audio) 1]]} {
		lappend mcommand -ao alsa:device=hw=[lindex $::option(player_audio) 1]
	} else {
		lappend mcommand -ao $::option(player_audio)
	}
	
	if {[string trim $cbopt(softvol\($::option(player_aud_softvol)\))] != {}} {
		lappend mcommand {*}$cbopt(softvol\($::option(player_aud_softvol)\))
	}
	
	lappend mcommand {*}$cbopt(threads\($::option(player_threads)\))
	
	if {[string trim $copt($::option(player_cache))] != {}} {
		lappend mcommand {*}$copt($::option(player_cache))
	}
	lappend mcommand {*}$cbopt(dr\($::option(player_dr)\))
	lappend mcommand {*}$cbopt(double\($::option(player_double)\))
	lappend mcommand {*}$cbopt(slice\($::option(player_slice)\))
	lappend mcommand {*}$cbopt(fd\($::option(player_fd)\))
	lappend mcommand {*}$cbopt(hfd\($::option(player_hfd)\))
	
	if {$::option(player_screens) == 1} {
		if {$::option(player_screens_value) == 0} {
			lappend mcommand -stop-xscreensaver
		} else {
			log_writeOutTv 1 "Using heartbeat hack to stop screensaver."
			set ::tv(screensaverId) [winfo id .]
			catch {exec xdg-screensaver suspend $::tv(screensaverId)}
			set ::data(heartbeat_id) [after 3000 tv_wmHeartbeatCmd 0]
		}
	} else {
		lappend mcommand -nostop-xscreensaver
	}
	set winid [expr [winfo id $tv_cont]]
	
	lappend mcommand -input conf="$::option(root)/shortcuts/input.conf" {*}{-osdlevel 0}
	
	lappend mcommand -nokeepaspect
	if {$::option(player_aspect) == 1} {
		if {$::option(player_aspect_monpix) == 0} {
			lappend mcommand $cbopt(monpixaspect\($::option(player_aspect_monpix)\)) $::option(player_monaspect_val)
		} else {
			lappend mcommand $cbopt(monpixaspect\($::option(player_aspect_monpix)\)) $::option(player_pixaspect_val)
		}
	}
	
	lappend mcommand -channels [lindex $::option(player_audio_channels) 0]
	
	if {[string trim $::option(player_additional_commands)] != {}} {
		lappend mcommand {*}$::option(player_additional_commands)
	}
	if {[string trim $::option(player_add_af_commands)] != {}} {
		lappend mcommand -af $::option(player_add_af_commands)
	}
	if {"$::option(player_vo)" == "vdpau" || "$::option(player_vo)" == "xvmc"} {
		log_writeOutTv 1 "Chosen video output driver $::option(player_vo)"
		log_writeOutTv 1 "When using this video output driver, additional video filter options are not available."
	} else {
		if {[string trim $dopt($::option(player_deint))] == {-vf}} {
			if {[string trim $::option(player_add_vf_commands)] != {}} {
				lappend mcommand {*}$dopt($::option(player_deint))$cbopt(scrshot\($::option(player_shot)\))$::option(player_add_vf_commands)$cbopt(autoq\($::option(player_autoq)\))
			} else {
				lappend mcommand {*}$dopt($::option(player_deint))[string map {{,} {}} $cbopt(scrshot\($::option(player_shot)\))]$cbopt(autoq\($::option(player_autoq)\))
			}
		} else {
			if {[string trim $cbopt(autoq\($::option(player_autoq)\))] != {}} {
				if {[string match *pp* "$dopt($::option(player_deint))"] == 1} {
					if {[string trim $::option(player_add_vf_commands)] != {}} {
						lappend mcommand {*}$dopt($::option(player_deint)),$::option(player_add_vf_commands),[string map {{,} {}} $cbopt(scrshot\($::option(player_shot)\))] {*}[lrange $cbopt(autoq\($::option(player_autoq)\)) end-1 end]
					} else {
						lappend mcommand {*}$dopt($::option(player_deint)),[string map {{,} {}} $cbopt(scrshot\($::option(player_shot)\))] {*}[lrange $cbopt(autoq\($::option(player_autoq)\)) end-1 end]
					}
				} else {
					if {[string trim $::option(player_add_vf_commands)] != {}} {
						lappend mcommand {*}$dopt($::option(player_deint)),$cbopt(scrshot\($::option(player_shot)\))$::option(player_add_vf_commands)$cbopt(autoq\($::option(player_autoq)\))
					} else {
						lappend mcommand {*}$dopt($::option(player_deint)),[string map {{,} {}} $cbopt(scrshot\($::option(player_shot)\))]$cbopt(autoq\($::option(player_autoq)\))
					}
				}
			} else {
				lappend mcommand {*}$dopt($::option(player_deint)),[string map {{,} {}} $cbopt(scrshot\($::option(player_shot)\))]
				if {[string trim $::option(player_add_vf_commands)] != {}} {
					append mcommand ,$::option(player_add_vf_commands)
				}
			}
		}
	}
	
	if {$file == 0} {
		lappend mcommand -wid $winid $::option(video_device)
		log_writeOutTv 0 "Starting tv playback..."
		log_writeOutMpl 0 "If playback is not starting see MPlayer logfile for details."
		log_writeOutMpl 1 "MPlayer command line:"
		log_writeOutMpl 1 "$mcommand"
		if {[winfo exists .station]} {
			.station.top_buttons.b_station_preview state pressed
			.top_buttons.button_starttv state pressed
		} else {
			.top_buttons.button_starttv state pressed
		}
		catch {place forget .tv.l_image}
		if {[winfo exists .tray] == 1} {
		catch {settooltip .tray [mc "TV-Viewer playing - %" [lindex $::station(last) 0]]}
		}
		if {[winfo exists .tv.l_anigif]} {
			launch_splashPlay cancel 0 0 0
			place forget .tv.l_anigif
			destroy .tv.l_anigif
		}
		set img_list [launch_splashAnigif "$::option(root)/icons/extras/BigBlackIceRoller.gif"]
		label .tv.l_anigif -image [lindex $img_list 0] -borderwidth 0 -background #000000
		place .tv.l_anigif -in .tv.bg -anchor center -relx 0.5 -rely 0.5
		set img_list_length [llength $img_list]
		after 0 [list launch_splashPlay $img_list $img_list_length 1 .tv.l_anigif]
		
		set ::data(mplayer) [open "|$mcommand" r+]
		fconfigure $::data(mplayer) -blocking 0 -buffering line
		fileevent $::data(mplayer) readable [list tv_callbackVidData]
		log_writeOutMpl 0 "MPlayer process id [pid $::data(mplayer)]"
		log_writeOutTv 0 "MPlayer process id [pid $::data(mplayer)]"
	} else {
		if {[file exists "$file"]} {
			lappend mcommand -wid $winid "$file"
			catch {place forget .tv.l_image}
			if {[winfo exists .tv.file_play_bar] == 0} {
				tv_PlaybackFileplaybar $tv_bg $tv_cont $handler "$file"
				if {"$handler" == "timeshift"} {
					bind .tv <<start>> {}
					tv_Playback $tv_bg $tv_cont $handler "$file"
					return
				}
			} else {
				log_writeOutTv 0 "Starting playback of $file."
				log_writeOutMpl 0 "If playback is not starting see MPlayer logfile for details."
				log_writeOutMpl 1 "MPlayer command line:"
				log_writeOutMpl 1 "$mcommand"
				if {[winfo exists .tv.l_anigif]} {
					launch_splashPlay cancel 0 0 0
					place forget .tv.l_anigif
					destroy .tv.l_anigif
				}
				set img_list [launch_splashAnigif "$::option(root)/icons/extras/BigBlackIceRoller.gif"]
				label .tv.l_anigif -image [lindex $img_list 0] -borderwidth 0 -background #000000
				place .tv.l_anigif -in .tv.bg -anchor center -relx 0.5 -rely 0.5
				set img_list_length [llength $img_list]
				after 0 [list launch_splashPlay $img_list $img_list_length 1 .tv.l_anigif]
				set ::tv(mcommand) $mcommand
				if {[info exists ::data(file_size)] == 0} {
					set delay $playdelay($::option(player_cache))
				} else {
					if {[expr $::data(file_size) * 1000] < $playdelay($::option(player_cache))} {
						set delay [expr $playdelay($::option(player_cache)) - ( $::data(file_size) * 1000)]
					} else {
						set delay 0
					}
				}
				log_writeOutTv 0 "Calculated delay to start file playback $delay\ms."
				after $delay {
					if {[wm attributes .tv -fullscreen] == 0} {
						if {[winfo exists .tv.file_play_bar]} {
							if {[string trim [grid info .tv.file_play_bar]] == {}} {
								grid .tv.file_play_bar -in .tv -row 1 -column 0 -sticky ew
							}
						}
					}
					if {[winfo exists .tv.file_play_bar]} {
						.tv.file_play_bar.b_play configure -command [list tv_seek 0 0]
						.top_buttons.button_timeshift state !disabled
						bind .tv <<timeshift>> [list timeshift .top_buttons.button_timeshift]
						bind . <<timeshift>> [list timeshift .top_buttons.button_timeshift]
						bind .tv <<forward_end>> {tv_seekInitiate "tv_seek 0 2"}
						bind .tv <<forward_10s>> {tv_seekInitiate "tv_seek 10 1"}
						bind .tv <<forward_1m>> {tv_seekInitiate "tv_seek 60 1"}
						bind .tv <<forward_10m>> {tv_seekInitiate "tv_seek 600 1"}
						bind .tv <<rewind_10s>> {tv_seekInitiate "tv_seek 10 -1"}
						bind .tv <<rewind_1m>> {tv_seekInitiate "tv_seek 60 -1"}
						bind .tv <<rewind_10m>> {tv_seekInitiate "tv_seek 600 -1"}
						bind .tv <<rewind_start>> {tv_seekInitiate "tv_seek 0 -2"}
						bind .tv <<start>> {}
						.tv.file_play_bar.b_pause state !disabled
						.tv.file_play_bar.b_play state disabled
						
						set ::data(mplayer) [open "|$::tv(mcommand)" r+]
						fconfigure $::data(mplayer) -blocking 0 -buffering line
						fileevent $::data(mplayer) readable [list tv_callbackVidData]
						log_writeOutMpl 0 "MPlayer process id [pid $::data(mplayer)]"
						log_writeOutTv 0 "MPlayer process id [pid $::data(mplayer)]"
					} else {
						log_writeOutTv 2 "Failed to start file playback."
						log_writeOutTv 2 "Fileplaybar does not exist. Report this incident!"
					}
				}
			}
		} else {
			log_writeOutTv 2 "Could not locate file for file playback."
			log_writeOutTv 2 "$file"
			return
		}
	}
	if {$::tv(stayontop) == 2} {
		wm attributes .tv -topmost 1
	}
}

proc tv_PlaybackFileplaybar {tv_bg tv_cont handler file} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_PlaybackFilePlaybar \{$tv_bg\} \{$tv_cont\} \{$handler\} \{$file\}"
	set tv_bar [ttk::frame .tv.file_play_bar] ; place [ttk::label $tv_bar.bg -style Toolbutton] -relwidth 1 -relheight 1
	ttk::button $tv_bar.b_play \
	-style Toolbutton \
	-image $::icon_m(playback-start) \
	-takefocus 0 \
	-command {event generate .tv <<start>>}
	ttk::button $tv_bar.b_pause \
	-style Toolbutton \
	-image $::icon_m(playback-pause) \
	-takefocus 0 \
	-command {event generate .tv <<pause>>}
	ttk::button $tv_bar.b_stop \
	-style Toolbutton \
	-image $::icon_m(playback-stop) \
	-takefocus 0 \
	-command {event generate .tv <<stop>>}
	ttk::separator $tv_bar.sep_1 \
	-orient vertical
	ttk::button $tv_bar.b_rewind_start \
	-style Toolbutton \
	-image $::icon_m(rewind-first) \
	-takefocus 0 \
	-command {event generate .tv <<rewind_start>>}
	ttk::button $tv_bar.b_rewind_small \
	-style Toolbutton \
	-image $::icon_m(rewind-small) \
	-takefocus 0 \
	-command {event generate .tv <<rewind_10s>>}
	ttk::menubutton $tv_bar.b_rew_choose \
	-style Toolbutton \
	-image $::icon_e(arrow-d) \
	-takefocus 0 \
	-menu $tv_bar.mbRewind
	ttk::button $tv_bar.b_forward_small \
	-style Toolbutton \
	-image $::icon_m(forward-small) \
	-takefocus 0 \
	-command {event generate .tv <<forward_10s>>}
	ttk::menubutton $tv_bar.b_forw_choose \
	-style Toolbutton \
	-image $::icon_e(arrow-d) \
	-takefocus 0 \
	-menu $tv_bar.mbForward
	ttk::button $tv_bar.b_forward_end \
	-style Toolbutton \
	-image $::icon_m(forward-last) \
	-takefocus 0 \
	-command {event generate .tv <<forward_end>>}
	ttk::separator $tv_bar.sep_2 \
	-orient vertical
	ttk::button $tv_bar.b_fullscreen \
	-style Toolbutton \
	-image $::icon_m(fullscreen) \
	-takefocus 0 \
	-command [list tv_wmFullscreen .tv $tv_cont $tv_bg]
	ttk::button $tv_bar.b_save \
	-style Toolbutton \
	-image $::icon_m(floppy) \
	-takefocus 0 \
	-state disabled \
	-command [list timeshift_Save .tv]
	label $tv_bar.l_time \
	-width 20 \
	-background black \
	-foreground white \
	-anchor center \
	-textvariable choice(label_file_time)

	menu $tv_bar.mbRewind \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))
	menu $tv_bar.mbForward \
	-tearoff 0 \
	-background $::option(theme_$::option(use_theme))

	$tv_bar.mbRewind add checkbutton \
	-label [mc "-10 seconds"] \
	-accelerator [mc "Left"] \
	-command [list tv_seekSwitch $tv_bar -1 -10s tv(check_rew_10s)] \
	-variable tv(check_rew_10s)
	$tv_bar.mbRewind add checkbutton \
	-label [mc "-1 minute"] \
	-accelerator [mc "Shift+Left"] \
	-command [list tv_seekSwitch $tv_bar -1 -1m tv(check_rew_1m)] \
	-variable tv(check_rew_1m)
	$tv_bar.mbRewind add checkbutton \
	-label [mc "-10 minutes"] \
	-accelerator [mc "Ctrl+Shift+Left"] \
	-command [list tv_seekSwitch $tv_bar -1 -10m tv(check_rew_10m)] \
	-variable tv(check_rew_10m)
	$tv_bar.mbForward add checkbutton \
	-label [mc "+10 seconds"] \
	-accelerator [mc "Right"] \
	-command [list tv_seekSwitch $tv_bar 1 +10s tv(check_fow_10s)] \
	-variable tv(check_fow_10s)
	$tv_bar.mbForward add checkbutton \
	-label [mc "+1 minute"] \
	-accelerator [mc "Shift+Right"] \
	-command [list tv_seekSwitch $tv_bar 1 +1m tv(check_fow_1m)] \
	-variable tv(check_fow_1m)
	$tv_bar.mbForward add checkbutton \
	-label [mc "+10 minutes"] \
	-accelerator [mc "Ctrl+Shift+Right"] \
	-command [list tv_seekSwitch $tv_bar 1 +10m tv(check_fow_10m)] \
	-variable tv(check_fow_10m)
	
	
	grid $tv_bar.b_play -in $tv_bar -row 0 -column 0 \
	-pady 2 \
	-padx "2 0"
	grid $tv_bar.b_pause -in $tv_bar -row 0 -column 1 \
	-pady 2 \
	-padx "2 0"
	grid $tv_bar.b_stop -in $tv_bar -row 0 -column 2 \
	-pady 2 \
	-padx "2 0"
	grid $tv_bar.sep_1 -in $tv_bar -row 0 -column 3 \
	-sticky ns \
	-padx "2 0"
	grid $tv_bar.b_rewind_start -in $tv_bar -row 0 -column 4 \
	-pady 2 \
	-padx "2 0"
	grid $tv_bar.b_rew_choose -in $tv_bar -row 0 -column 5 \
	-sticky ns \
	-pady 2 \
	-padx "1 0"
	grid $tv_bar.b_rewind_small -in $tv_bar -row 0 -column 6 \
	-pady 2 \
	-padx "1 0"
	grid $tv_bar.b_forward_small -in $tv_bar -row 0 -column 7 \
	-pady 2 \
	-padx "1 0"
	grid $tv_bar.b_forw_choose -in $tv_bar -row 0 -column 8 \
	-sticky ns \
	-pady 2 \
	-padx "1 0"
	grid $tv_bar.b_forward_end -in $tv_bar -row 0 -column 9 \
	-pady 2 \
	-padx "1 0"
	grid $tv_bar.sep_2 -in $tv_bar -row 0 -column 10 \
	-sticky ns \
	-padx "2 0"
	grid $tv_bar.b_fullscreen -in $tv_bar -row 0 -column 11 \
	-pady 2 \
	-padx "2 0"
	grid $tv_bar.b_save -in $tv_bar -row 0 -column 12 \
	-pady 2 \
	-padx "2 0"
	grid $tv_bar.l_time -in $tv_bar -row 0 -column 13 \
	-sticky nse \
	-padx "0 2" \
	-pady 2
	
	grid columnconfigure $tv_bar 13 -weight 1
	
	if {"$handler" != "timeshift"} {
		catch {launch_splashPlay cancel 0 0 0}
		catch {place forget .tv.l_anigif}
		catch {destroy .tv.l_anigif}
	}
	
	$tv_bar.l_time configure -background black -foreground white -relief sunken -borderwidth 2
	set ::choice(label_file_time) "00:00:00"
	if {$::tv(check_fow_1m) == 0 && $::tv(check_fow_10m) == 0} {
		set ::tv(check_fow_10s) 1
		$tv_bar.b_forward_small configure -command {event generate .tv <<forward_10s>>}
	} else {
		if {$::tv(check_fow_1m) == 1} {
			$tv_bar.b_forward_small configure -command {event generate .tv <<forward_1m>>}
		}
		if {$::tv(check_fow_10m) == 1} {
			$tv_bar.b_forward_small configure -command {event generate .tv <<forward_10m>>}
		}
	}
	if {$::tv(check_rew_1m) == 0 && $::tv(check_rew_10m) == 0} {
		set ::tv(check_rew_10s) 1
		$tv_bar.b_rewind_small configure -command {event generate .tv <<rewind_10s>>}
	} else {
		if {$::tv(check_rew_1m) == 1} {
			$tv_bar.b_rewind_small configure -command {event generate .tv <<rewind_1m>>}
		}
		if {$::tv(check_rew_10m) == 1} {
			$tv_bar.b_rewind_small configure -command {event generate .tv <<rewind_10m>>}
		}
	}
	.tv.file_play_bar.b_pause state disabled
	
	if {$::option(tooltips_player) == 1} {
		settooltip $tv_bar.b_play [mc "Start playback"]
		settooltip $tv_bar.b_pause [mc "Pause playback"]
		settooltip $tv_bar.b_stop [mc "Stop playback"]
		settooltip $tv_bar.b_rewind_start [mc "Jump to the beginning"]
		settooltip $tv_bar.b_rewind_small [mc "Seek back"]
		settooltip $tv_bar.b_rew_choose [mc "Choose amount of seek back"]
		settooltip $tv_bar.b_forward_small [mc "Seek forward"]
		settooltip $tv_bar.b_forw_choose [mc "Choose amount of seek forward"]
		settooltip $tv_bar.b_forward_end [mc "Jump to the end"]
		settooltip $tv_bar.b_fullscreen [mc "Toggle fullscreen"]
		settooltip $tv_bar.l_time [mc "Current position / File length"]
	} else {
		settooltip $tv_bar.b_play {}
		settooltip $tv_bar.b_pause {}
		settooltip $tv_bar.b_stop {}
		settooltip $tv_bar.b_rewind_start {}
		settooltip $tv_bar.b_rewind_small {}
		settooltip $tv_bar.b_rew_choose {}
		settooltip $tv_bar.b_forward_small {}
		settooltip $tv_bar.b_forw_choose {}
		settooltip $tv_bar.b_forward_end {}
		settooltip $tv_bar.b_fullscreen {}
		settooltip $tv_bar.l_time {}
	}
	
	if {[wm attributes .tv -fullscreen] == 1} {
		bind $tv_cont <Motion> {
			tv_wmCursorHide .tv.bg.w 0
			tv_wmCursorPlaybar %Y
			tv_slistCursor %X %Y
		}
		bind $tv_bg <Motion> {
			tv_wmCursorHide .tv.bg 0
			tv_wmCursorPlaybar %Y
			tv_slistCursor %X %Y
		}
	} else {
		if {"$handler" != "timeshift"} {
			grid .tv.file_play_bar -in .tv -row 1 -column 0 -sticky ew
		}
	}
}

proc tv_playbackStop {com handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: tv_playbackStop \033\[0m \{$com\} \{$handler\}"
	if {[info exists ::data(mplayer)] == 0} {return 1}
	if {[string trim $::data(mplayer)] != {}} {
		catch {puts -nonewline $::data(mplayer) "quit 0 \n"}
		flush $::data(mplayer)
	} else {
		return 1
	}
	if {[info exists ::option(cursor_id\(.tv.bg\))] == 1} {
		foreach id [split $::option(cursor_id\(.tv.bg\))] {
			after cancel $id
		}
		unset -nocomplain ::option(cursor_id\(.tv.bg\))
	}
	if {[info exists ::option(cursor_id\(.tv.bg.w\))] == 1} {
		foreach id [split $::option(cursor_id\(.tv.bg.w\))] {
			after cancel $id
		}
		unset -nocomplain ::option(cursor_id\(.tv.bg.w\))
	}
	if {[winfo exists .tv.l_anigif]} {
		catch {launch_splashPlay cancel 0 0 0}
		catch {place forget .tv.l_anigif}
		catch {destroy .tv.l_anigif}
	}
	if {"$handler" == "pic"} {
		place forget .tv.bg.w
		place .tv.l_image -relx 0.5 -rely 0.5 -anchor center
		bind .tv.bg.w <Configure> {}
	} else {
		place forget .tv.bg.w
		bind .tv.bg.w <Configure> {}
	}
	if {[winfo exists .station]} {
		.station.top_buttons.b_station_preview state !pressed
	} else {
		.top_buttons.button_starttv state !pressed
	}
	if {$::option(player_screens_value) == 1} {
		tv_wmHeartbeatCmd cancel
	}
	tv_fileComputePos cancel
	if {$com == 0} {
		if {[winfo exists .tv.file_play_bar]} {
			destroy .tv.file_play_bar
		}
		tv_fileComputeSize cancel
	} else {
		if {[winfo exists .tv.file_play_bar]} {
			.tv.file_play_bar.b_play state !disabled
			.tv.file_play_bar.b_pause state disabled
			.tv.file_play_bar.b_play configure -command {tv_Playback .tv.bg .tv.bg.w 0 "$::tv(current_rec_file)"}
			bind .tv <<start>> {tv_Playback .tv.bg .tv.bg.w 0 "$::tv(current_rec_file)"}
		}
	}
	log_writeOutTv 0 "Stopping playback"
}
