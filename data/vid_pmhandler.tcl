#       vid_pmhandler.tcl
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

proc vid_pmhandlerButton {bListTop bListChan bListPlay} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_pmhandlerButton \033\[0m \{$bListTop\} \{$bListChan\} \{$bListPlay\}"
	
	#A list of all buttons that need to be manipulated because of playback mode changes or other events
	array set butTop {
		1 .ftoolb_Top.bTimeshift 
		2 .ftoolb_Top.bRecord
		3 .ftoolb_Top.bEpg
		4 .ftoolb_Top.bRadio
		5 .ftoolb_Top.bTv
	}
	array set butChan {
		1 .fstations.ftoolb_ChanCtrl.bChanDown
		2 .fstations.ftoolb_ChanCtrl.bChanUp
		3 .fstations.ftoolb_ChanCtrl.bChanJump
	}
	array set butPlay {
		1 .ftoolb_Play.bPlay
		2 .ftoolb_Play.bPause
		3 .ftoolb_Play.bStop
		4 .ftoolb_Play.bRewStart
		5 .ftoolb_Play.mbRewChoose
		6 .ftoolb_Play.bRewSmall
		7 .ftoolb_Play.bForwSmall
		8 .ftoolb_Play.mbForwChoose
		9 .ftoolb_Play.bForwEnd
		10 .ftoolb_Play.bSave
	}
	if {[lindex $bListTop 0] != 100} {
		foreach but $bListTop {
			set arrayid [lindex $but 0]
			$butTop($arrayid) state [lindex $but 1]
		}
	}
	if {[lindex $bListChan 0] != 100} {
		foreach but $bListChan {
			set arrayid [lindex $but 0]
			$butChan($arrayid) state [lindex $but 1]
		}
	}
	if {[lindex $bListPlay 0] != 100} {
		foreach but $bListPlay {
			set arrayid [lindex $but 0]
			$butPlay($arrayid) state [lindex $but 1]
		}
	}
}

proc vid_pmhandlerMenuTv {tv tvCont} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_pmhandlerMenuTv \033\[0m \{$tv\} \{$tvCont\}"
	set mTv .foptions_bar.mbTvviewer.mTvviewer
	set mTvcont .fvidBg.mContext
	if {[lindex $tv 0] != 100} {
		foreach entry $tv {
			$mTv entryconfigure [lindex $entry 0] -state [lindex $entry 1]
		}
	}
	if {[lindex $tvCont 0] != 100} {
		foreach entry $tvCont {
			$mTvcont entryconfigure [lindex $entry 0] -state [lindex $entry 1]
		}
	}
}

proc vid_pmhandlerMenuNav {nav navCont} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_pmhandlerMenuNav \033\[0m \{$nav\} \{$navCont\}"
	set mNav .foptions_bar.mbNavigation.mNavigation
	set mNavcont .fvidBg.mContext.mNavigation
	if {[lindex $nav 0] != 100} {
		foreach entry $nav {
			$mNav entryconfigure [lindex $entry 0] -state [lindex $entry 1]
		}
	}
	if {[lindex $navCont 0] != 100} {
		foreach entry $navCont {
			$mNavcont entryconfigure [lindex $entry 0] -state [lindex $entry 1]
		}
	}
}

proc vid_pmhandlerMenuView {view viewCont} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_pmhandlerMenuView \033\[0m \{$view\} \{$viewCont\}"
	set mView .foptions_bar.mbView.mView
	set mViewcont .fvidBg.mContext.mView
	if {[lindex $view 0] != 100} {
		foreach entry $view {
			$mView entryconfigure [lindex $entry 0] -state [lindex $entry 1]
		}
	}
	if {[lindex $viewCont 0] != 100} {
		foreach entry $viewCont {
			$mViewcont entryconfigure [lindex $entry 0] -state [lindex $entry 1]
		}
	}
}

proc vid_pmhandlerMenuAud {aud audCont} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_pmhandlerMenuAud \{$aud\} \{$audCont\}"
	set mAud .foptions_bar.mbAudio.mAudio
	set mAudcont .fvidBg.mContext.mAudio
	if {[lindex $aud 0] != 100} {
		foreach entry $aud {
			$mAud entryconfigure [lindex $entry 0] -state [lindex $entry 1]
		}
	}
	if {[lindex $audCont 0] != 100} {
		foreach entry $audCont {
			$mAudCont entryconfigure [lindex $entry 0] -state [lindex $entry 1]
		}
	}
}

proc vid_pmhandlerMenuHelp {help} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_pmhandlerMenuHelp \033\[0m \{$help\}"
	set mHelp .foptions_bar.mbHelp.mHelp
	if {[lindex $help 0] != 100} {
		foreach entry $help {
			$mHelp entryconfigure [lindex $entry 0] -state [lindex $entry 1]
		}
	}
}

proc vid_pmhandlerMenuTray {tray} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: vid_pmhandlerMenuTray \033\[0m \{$tray\}"
	set mTray .tray.mTray
	if {[winfo exists $mTray]} {
		if {[lindex $tray 0] != 100} {
			foreach entry $tray {
				$mTray entryconfigure [lindex $entry 0] -state [lindex $entry 1]
			}
		}
	}
}
