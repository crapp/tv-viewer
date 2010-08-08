#       vid_Playback.tcl
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

proc vid_Playback {tv_bg tv_cont handler file} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_Playback \033\[0m \{$tv_bg\} \{$tv_cont\} \{$handler\} \{$file\}"
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
		autosync(0) {}
		autosync(1) {-autosync 100}
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
	
	if {$file == 0} {
		lappend mcommand {*}[auto_execok mplayer] -noquiet -slave -nofs
	} else {
		lappend mcommand {*}[auto_execok mplayer] -noquiet -slave -identify -nofs
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
	
	if {[string trim $cbopt(autosync\($::option(player_audio_autosync)\))] != {}} {
		lappend mcommand {*}$cbopt(autosync\($::option(player_audio_autosync)\))
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
			set ::vid(screensaverId) [winfo id .]
			catch {exec xdg-screensaver suspend $::vid(screensaverId)}
			set ::data(heartbeat_id) [after 3000 vid_wmHeartbeatCmd 0]
		}
	} else {
		lappend mcommand -nostop-xscreensaver
	}
	set winid [expr [winfo id $tv_cont]]
	
	lappend mcommand -nomouseinput -input nodefault-bindings:conf=/dev/null {*}{-osdlevel 0} -nosub -noautosub
	
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
			.ftoolb_Top.bTv state pressed
		} else {
			.ftoolb_Top.bTv state pressed
		}
		catch {place forget .ftvBg.l_bgImage}
		if {[winfo exists .tray] == 1} {
		catch {settooltip .tray [mc "TV-Viewer playing - %" [lindex $::station(last) 0]]}
		}
		if {[winfo exists .ftvBg.l_anigif]} {
			launch_splashPlay cancel 0 0 0
			place forget .ftvBg.l_anigif
			destroy .ftvBg.l_anigif
		}
		set img_list [launch_splashAnigif "$::option(root)/icons/extras/BigBlackIceRoller.gif"]
		label .ftvBg.l_anigif -image [lindex $img_list 0] -borderwidth 0 -background #000000
		place .ftvBg.l_anigif -in .ftvBg -anchor center -relx 0.5 -rely 0.5
		set img_list_length [llength $img_list]
		after 0 [list launch_splashPlay $img_list $img_list_length 1 .ftvBg.l_anigif]
		
		set ::vid(pbMode) 0
		set ::main(label_file_time) "--:-- / --:--"
		
		.ftoolb_Play.bPause state disabled
		.ftoolb_Play.bPlay state disabled
		.ftoolb_Play.bStop state disabled
		.ftoolb_Play.bRewStart state disabled
		.ftoolb_Play.bRewSmall state disabled
		.ftoolb_Play.mbRewChoose state disabled
		.ftoolb_Play.bForwSmall state disabled
		.ftoolb_Play.mbForwChoose state disabled
		.ftoolb_Play.bForwEnd state disabled
		.ftoolb_Play.bSave state disabled
		
		set ::data(mplayer) [open "|$mcommand" r+]
		fconfigure $::data(mplayer) -blocking 0 -buffering line
		fileevent $::data(mplayer) readable [list vid_callbackVidData]
		log_writeOutMpl 0 "MPlayer process id [pid $::data(mplayer)]"
		log_writeOutTv 0 "MPlayer process id [pid $::data(mplayer)]"
	} else {
		if {[file exists "$file"]} {
			lappend mcommand -wid $winid "$file"
			catch {place forget .ftvBg.l_bgImage}
			#~ if {[winfo exists .tv.file_play_bar] == 0} {
				#FIXME Why restart this proc when old fileplaybar does not exist
				#~ vid_PlaybackFileplaybar $tv_bg $tv_cont $handler "$file"
				#~ if {"$handler" == "timeshift"} {
					#~ bind . <<start>> {}
					#~ vid_Playback $tv_bg $tv_cont $handler "$file"
					#~ return
				#~ }
			#~ } else {
				log_writeOutTv 0 "Starting playback of $file."
				log_writeOutMpl 0 "If playback is not starting see MPlayer logfile for details."
				log_writeOutMpl 1 "MPlayer command line:"
				log_writeOutMpl 1 "$mcommand"
				if {[winfo exists .ftvBg.l_anigif]} {
					launch_splashPlay cancel 0 0 0
					place forget .ftvBg.l_anigif
					destroy .ftvBg.l_anigif
				}
				set img_list [launch_splashAnigif "$::option(root)/icons/extras/BigBlackIceRoller.gif"]
				label .ftvBg.l_anigif -image [lindex $img_list 0] -borderwidth 0 -background #000000
				place .ftvBg.l_anigif -in .ftvBg -anchor center -relx 0.5 -rely 0.5
				set img_list_length [llength $img_list]
				after 0 [list launch_splashPlay $img_list $img_list_length 1 .ftvBg.l_anigif]
				set ::vid(mcommand) $mcommand
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
					.ftoolb_Play.bPlay configure -command [list vid_seek 0 0]
					.ftoolb_Top.bTimeshift state !disabled
					bind . <<timeshift>> [list timeshift .ftoolb_Top.bTimeshift]
					bind . <<forward_end>> {vid_seekInitiate "vid_seek 0 2"}
					bind . <<forward_10s>> {vid_seekInitiate "vid_seek 10 1"}
					bind . <<forward_1m>> {vid_seekInitiate "vid_seek 60 1"}
					bind . <<forward_10m>> {vid_seekInitiate "vid_seek 600 1"}
					bind . <<rewind_10s>> {vid_seekInitiate "vid_seek 10 -1"}
					bind . <<rewind_1m>> {vid_seekInitiate "vid_seek 60 -1"}
					bind . <<rewind_10m>> {vid_seekInitiate "vid_seek 600 -1"}
					bind . <<rewind_start>> {vid_seekInitiate "vid_seek 0 -2"}
					bind . <<start>> {}
					.ftoolb_Play.bPause state !disabled
					.ftoolb_Play.bPlay state disabled
					.ftoolb_Play.bStop state !disabled
					.ftoolb_Play.bRewStart state !disabled
					.ftoolb_Play.bRewSmall state !disabled
					.ftoolb_Play.mbRewChoose state !disabled
					.ftoolb_Play.bForwSmall state !disabled
					.ftoolb_Play.mbForwChoose state !disabled
					.ftoolb_Play.bForwEnd state !disabled
					
					set ::data(mplayer) [open "|$::vid(mcommand)" r+]
					fconfigure $::data(mplayer) -blocking 0 -buffering line
					fileevent $::data(mplayer) readable [list vid_callbackVidData]
					log_writeOutMpl 0 "MPlayer process id [pid $::data(mplayer)]"
					log_writeOutTv 0 "MPlayer process id [pid $::data(mplayer)]"
				}
			#~ }
			set ::vid(pbMode) 1
		} else {
			log_writeOutTv 2 "Could not locate file for file playback."
			log_writeOutTv 2 "$file"
			return
		}
	}
	if {$::vid(stayontop) == 2} {
		wm attributes . -topmost 1
	}
}

proc vid_playbackStop {com handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_playbackStop \033\[0m \{$com\} \{$handler\}"
	if {[info exists ::data(mplayer)] == 0} {return 1}
	if {[string trim $::data(mplayer)] != {}} {
		catch {puts -nonewline $::data(mplayer) "quit 0 \n"}
		flush $::data(mplayer)
	} else {
		return 1
	}
	#FIXME Fix and test the window names for canceling hiding cursor?!
	if {[info exists ::option(cursor_id\(.ftvBg\))] == 1} {
		foreach id [split $::option(cursor_id\(.ftvBg\))] {
			after cancel $id
		}
		unset -nocomplain ::option(cursor_id\(.ftvBg\))
	}
	if {[info exists ::option(cursor_id\(.ftvBg.cont\))] == 1} {
		foreach id [split $::option(cursor_id\(.ftvBg.cont\))] {
			after cancel $id
		}
		unset -nocomplain ::option(cursor_id\(.ftvBg.cont\))
	}
	if {[winfo exists .ftvBg.l_anigif]} {
		catch {launch_splashPlay cancel 0 0 0}
		catch {place forget .ftvBg.l_anigif}
		catch {destroy .ftvBg.l_anigif}
	}
	if {"$handler" == "pic"} {
		place forget .ftvBg.cont
		place .ftvBg.l_bgImage -relx 0.5 -rely 0.5 -anchor center
		bind .ftvBg.cont <Configure> {}
	} else {
		place forget .ftvBg.cont
		bind .ftvBg.cont <Configure> {}
	}
	if {[winfo exists .station]} {
		.station.top_buttons.b_station_preview state !pressed
		.ftoolb_Top.bTv state !pressed
	} else {
		.ftoolb_Top.bTv state !pressed
	}
	if {$::option(player_screens_value) == 1} {
		vid_wmHeartbeatCmd cancel
	}
	vid_fileComputePos cancel
	if {$com == 0} {
		vid_fileComputeSize cancel
	} else {
		if {$::vid(pbMode) == 1} {
			.ftoolb_Play.bPlay state !disabled
			.ftoolb_Play.bPause state disabled
			.ftoolb_Play.bPlay configure -command {vid_Playback .ftvBg .ftvBg.cont 0 "$::vid(current_rec_file)"}
			bind . <<start>> {vid_Playback .ftvBg .ftvBg.cont 0 "$::vid(current_rec_file)"}
		}
	}
	log_writeOutTv 0 "Stopping playback"
}
