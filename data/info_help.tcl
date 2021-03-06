#       info_help.tcl
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

proc info_helpHelp {} {
	#Open documentation using standard web browser
	puts $::main(debug_msg) "\033\[0;1;33mDebug: info_helpHelp \033\[0m"
	if {[wm attributes . -fullscreen] == 1} {
		event generate . <<wmFull>>
	}
	catch {exec sh -c "xdg-open http://tv-viewer.sourceforge.net/mediawiki/index.php/Documentation" &}
	log_writeOut ::log(tvAppend) 0 "Trying to open userguide with favorite browser using xdg-open..."
}

proc info_helpMplayerRev {first strg} {
	#Extract Mplayer revision and return 
	set rev [string range "$strg" [expr $first + 1] [expr $first + 5]]
	if {[string is integer $rev] == 0} {
		set first [string first r $strg [expr $first + 1]]
		if {$first == -1} {
			return -1
		}
		info_helpMplayerRev $first "$strg"
	} else {
		return $rev
	}
}

proc info_helpExitAbout {w} {
	#Close Info Interface
	puts $::main(debug_msg) "\033\[0;1;33mDebug: info_helpExitAbout \033\[0m \{$w\}"
	vid_wmCursor 1
	grab release $w
	destroy $w
}

proc info_helpWebpage {handler} {
	puts $::main(debug_msg) "\033\[0;1;33mDebug: info_helpHomepage \033\[0m \{$handler\}"
	#Open a URL in standard browser depending on handler 
	#handler 0 = homepage; 1 = forum; 2 = IRC
	array set webs {
		0 http://tv-viewer.sourceforge.net/mediawiki/index.php/Main_Page
		1 http://sourceforge.net/projects/tv-viewer/forums
		2 http://webchat.freenode.net/?channels=tv-viewer
	}
	array set websName {
		0 Homepage
		1 Forum
		2 IRC
	}
	log_writeOut ::log(tvAppend) 0 "Executing your favorite internet browser and open $websName($handler)"
	catch {exec sh -c "xdg-open $webs($handler)" &}
}

proc info_helpAbout {} {
	#Creates an Info Frontend 
	puts $::main(debug_msg) "\033\[0;1;33mDebug: info_helpAbout \033\[0m"
	if {[winfo exists .top_about] == 0} {
		
		log_writeOut ::log(tvAppend) 0 "Launching info screen..."
		
		set w [toplevel .top_about]
		place [ttk::frame $w.bgcolor] -x 0 -y 0 -relwidth 1 -relheight 1
		set mf [ttk::frame $w.mf]
		set btnf [ttk::frame $mf.btnf -style TLabelframe]
		
		set t [image create photo]
		set small_icon [image create photo]
		$t copy $::icon_e(tv-viewer_icon)
		$small_icon copy $::icon_e(tv-viewer_icon)
		$small_icon blank
		$small_icon copy $t -shrink -subsample [expr round(1./0.33)]
		image delete $t
		
		ttk::label $mf.l_about_top -text [mc "TV-Viewer % Build %" [lindex $::option(release_version) 0] [lindex $::option(release_version) 1]] -image $small_icon -compound left -font "systemfont 14 bold"
		ttk::notebook $mf.nb
		ttk::button $btnf.b_about_exit -text [mc "Exit"] -command [list info_helpExitAbout $w] -compound left -image $::icon_s(dialog-close)
		
		set nb1 [ttk::frame $mf.nb.f_info]
		set linkf [ttk::frame $nb1.link_frame]
		$mf.nb add $nb1 -text [mc "Info"] -padding 2
		ttk::label $nb1.l_desc -text [mc "A small and simple frontend to watch and record television"] -justify center -font "systemfont 12 bold"
		ttk::label $linkf.l_homepage -text [mc "Homepage"]
		ttk::button $linkf.b_homepage -text "http://tv-viewer.sourceforge.net" -command [list info_helpWebpage 0]  -style Toolbutton
		ttk::label $linkf.l_forum -text [mc "Forum"]
		ttk::button $linkf.b_forum -text "http://sourceforge.net/.../forums" -command [list info_helpWebpage 1] -style Toolbutton
		ttk::label $linkf.l_irc -text [mc "IRC channel"]
		ttk::button $linkf.b_irc -text "http://webchat.freenode.net/" -command [list info_helpWebpage 2] -style Toolbutton
		ttk::label $nb1.l_version
		ttk::label $nb1.l_copy -text [mc "© Copyright 2007 - 2013
Christian Rapp"] -justify center
		
		set nb2 [ttk::frame $mf.nb.f_credits]
		$mf.nb add $nb2 -text [mc "Credits"] -padding 2
		text $nb2.t_credits -yscrollcommand [list $nb2.scrollb_credits set] -width 0 -height 0 -bd 0 -relief flat -highlightthickness 0 -insertwidth 0
		ttk::scrollbar $nb2.scrollb_credits -command [list $nb2.t_credits yview]
		
		set nb3 [ttk::frame $mf.nb.f_license]
		$mf.nb add $nb3 -text [mc "License"] -padding 2
		text $nb3.t_license -yscrollcommand [list $nb3.scrollb_license set] -width 0 -height 0 -bd 0 -relief flat -highlightthickness 0 -insertwidth 0
		ttk::scrollbar $nb3.scrollb_license -command [list $nb3.t_license yview]
		
		set nb4 [ttk::frame $mf.nb.f_changelog]
		$mf.nb add $nb4 -text [mc "Changelog"] -padding 2
		text $nb4.t_changelog -yscrollcommand [list $nb4.scrollb_changelog set] -width 0 -height 0 -bd 0 -relief flat -highlightthickness 0 -insertwidth 0
		ttk::scrollbar $nb4.scrollb_changelog -command [list $nb4.t_changelog yview]
		
		
		grid $mf -in $w -row 0 -column 0
		grid $mf.l_about_top -in $mf -row 0 -column 0 -sticky ew
		grid $mf.nb -in $mf -row 1 -column 0 -sticky nesw -padx 2
		grid $btnf -in $mf -row 2 -column 0 -sticky ew -padx 3 -pady 3
		grid $btnf.b_about_exit -in $btnf -row 0 -column 0 -pady 7 -padx 3
		grid anchor $btnf e
		grid anchor $nb1 center
		grid $nb1.l_desc -in $nb1 -row 0 -column 0 -pady 10
		
		grid $linkf -in $nb1 -row 1 -column 0 -pady "0 10"
		grid $linkf.l_homepage -in $linkf -row 0 -column 0 -sticky w -pady "0 3" -padx "0 3"
		grid $linkf.b_homepage -in $linkf -row 0 -column 1 -sticky w -pady "0 3"
		grid $linkf.l_forum -in $linkf -row 1 -column 0 -sticky w -pady "0 3" -padx "0 3"
		grid $linkf.b_forum -in $linkf -row 1 -column 1 -sticky w -pady "0 3"
		grid $linkf.l_irc -in $linkf -row 2 -column 0 -sticky w -pady "0 3" -padx "0 3"
		grid $linkf.b_irc -in $linkf -row 2 -column 1 -sticky w
		
		grid $nb1.l_version -in $nb1 -row 2 -column 0 -pady "0 10"
		grid $nb1.l_copy -in $nb1 -row 3 -column 0 -pady "0 10"
		grid $nb2.t_credits -in $nb2 -row 0 -column 0 -sticky nesw
		grid $nb2.scrollb_credits -in $nb2 -row 0 -column 1 -sticky ns -pady 10
		grid $nb3.t_license -in $nb3 -row 0 -column 0 -sticky nesw
		grid $nb3.scrollb_license -in $nb3 -row 0 -column 1 -sticky ns -pady 10
		grid $nb4.t_changelog -in $nb4 -row 0 -column 0 -sticky nesw
		grid $nb4.scrollb_changelog -in $nb4 -row 0 -column 1 -sticky ns -pady 10
		
		grid rowconfigure $mf 1 -minsize 250
		grid rowconfigure $nb2 0 -weight 1
		grid rowconfigure $nb3 0 -weight 1
		grid rowconfigure $nb4 0 -weight 1
		grid columnconfigure $mf 0 -minsize 560
		grid columnconfigure $nb2 0 -weight 1
		grid columnconfigure $nb3 0 -weight 1
		grid columnconfigure $nb4 0 -weight 1
		
		# Additional Code
		
		wm resizable $w 0 0
		wm title $w [mc "About TV-Viewer"]
		wm protocol $w WM_DELETE_WINDOW [list info_helpExitAbout $w]
		wm iconphoto $w $::icon_b(help-about)
		wm transient $w .
		
		if {[string trim [auto_execok mplayer]] != {}} {
			catch {exec [auto_execok mplayer] -noconfig all} mplayer_ver
			set agrep_mpl_ver [catch {agrep -m "$mplayer_ver" "MPlayer"} resultat_mpl_ver]
			if {$agrep_mpl_ver == 0} {
				set first [string first $resultat_mpl_ver r]
				set revision [info_helpMplayerRev $first "$resultat_mpl_ver"]
				if {$revision != -1} {
					log_writeOut ::log(tvAppend) 0 "Found MPlayer: SVN r$revision"
					$nb1.l_version configure -text "Version: [lindex $::option(release_version) 0] (Bazaar r[lindex $::option(release_version) 1]), running on Tcl/Tk [info patchlevel]
Build date: [lindex $::option(release_version) 2]
Backend: MPlayer SVN r$revision"
				} else {
					log_writeOut ::log(tvAppend) 1 "Found MPlayer, but could not read SVN revision."
					log_writeOut ::log(tvAppend) 1 "$resultat_mpl_ver"
					$nb1.l_version configure -text "Version: [lindex $::option(release_version) 0] (Bazaar r[lindex $::option(release_version) 1]), running on Tcl/Tk [info patchlevel]
Build date: [lindex $::option(release_version) 2]
Backend: MPlayer SVN rUNKNOWN"
				}
			} else {
				log_writeOut ::log(tvAppend) 1 "Found MPlayer, but could not detect Version"
				log_writeOut ::log(tvAppend) 1 "$resultat_mpl_ver"
				$nb1.l_version configure -text "Version: [lindex $::option(release_version) 0] (Bazaar r[lindex $::option(release_version) 1]), running on Tcl/Tk [info patchlevel]
Build date: [lindex $::option(release_version) 2]
Backend: MPlayer SVN rUNKNOWN"
			}
		}
		
		$nb2.t_credits insert end "Developers:" big
		$nb2.t_credits insert end "\n
Christian Rapp - Main developer"
		$nb2.t_credits insert end "\n<christianrapp@users.sourceforge.net>" saed
		$nb2.t_credits insert end "\n\n"
		$nb2.t_credits insert end "Translators:" big
		$nb2.t_credits insert end "\n
da  Jes Nissen <jesdnissen@gmail.com>"
		$nb2.t_credits insert end "\n
de  Christian Rapp <christianrapp@users.sourceforge.net>"
		$nb2.t_credits insert end "\n
en  Christian Rapp <christianrapp@users.sourceforge.net>
    Matthias Klostermair"
		$nb2.t_credits insert end "\n\n"
		$nb2.t_credits insert end "Participants:" big
		$nb2.t_credits insert end "\n
Martin Dauskardt, Matthias Klostermair, Thorsten Droege.

Thank you for your help!"
		
		$nb2.t_credits tag configure big -font "TkTextFont 12 bold"
		$nb2.t_credits tag configure underline -underline on
		
		set hylink_enter "-foreground #0023FF -underline off"
		set hylink_leave "-foreground #0064FF -underline on"
		$nb2.t_credits tag configure saed -foreground #0064FF -underline on
		$nb2.t_credits tag bind saed <Any-Enter> "$nb2.t_credits tag configure saed $hylink_enter; $nb2.t_credits configure -cursor hand1"
		$nb2.t_credits tag bind saed <Any-Leave> "$nb2.t_credits tag configure saed $hylink_leave; $nb2.t_credits configure -cursor {}"
		$nb2.t_credits tag bind saed <Button-1> {catch {exec sh -c "xdg-email christianrapp@users.sourceforge.net" &}}
		$nb2.t_credits configure -state disabled
		
		$nb3.t_license insert end "TV-Viewer is distributed under the terms of the " 
		$nb3.t_license insert end "GNU General Public License" link_gpl2
		$nb3.t_license insert end "\nas published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version.
The Icons, distributed with TV-Viewer, are covered by "
		$nb3.t_license insert end "different licenses" link_icons
		$nb3.t_license insert end "\n"
		$nb3.t_license insert end "\ntktray" big
		$nb3.t_license insert end "\n\nThe shared library "
		$nb3.t_license insert end "libtktray1.3.9.so" link_tktray
		$nb3.t_license insert end " is copyrighted by Anton Kovalenko
under the BSD license."
		$nb3.t_license insert end "\n"
		$nb3.t_license insert end "\ncallib" big
		$nb3.t_license insert end "\n\ncallib is a "
		$nb3.t_license insert end "calendar widget" link_callib
		$nb3.t_license insert end " of which TV-Viewer makes us of.
It is copyrighted by Jaafar Mejri."
		$nb3.t_license insert end "\n"
		$nb3.t_license insert end "\nautoscroll" big
		$nb3.t_license insert end "\n\nautoscroll is part of tklib. The library was originally
written by Kevin B Kenny. For copyright infos see "
		$nb3.t_license insert end "license terms" link_autoscr
		$nb3.t_license insert end "\n"
		$nb3.t_license insert end "\nfsdialog" big
		$nb3.t_license insert end "\n\n"
		$nb3.t_license insert end "fsdialog" link_fsdialog
		$nb3.t_license insert end " is freely redistributable and copyrighted by Schelte Bron."
		$nb3.t_license insert end "\n"
		
		$nb3.t_license tag configure big -font "TkTextFont 12 bold"
		
		$nb3.t_license tag configure link_gpl2 -foreground #0064FF -underline on
		$nb3.t_license tag bind link_gpl2 <Any-Enter> "$nb3.t_license tag configure link_gpl2 $hylink_enter; $nb3.t_license configure -cursor hand1"
		$nb3.t_license tag bind link_gpl2 <Any-Leave> "$nb3.t_license tag configure link_gpl2 $hylink_leave; $nb3.t_license configure -cursor {}"
		$nb3.t_license tag bind link_gpl2 <Button-1> {catch {exec sh -c "xdg-open http://www.gnu.org/licenses/gpl-2.0.html" &}}
		
		$nb3.t_license tag configure link_icons -foreground #0064FF -underline on
		$nb3.t_license tag bind link_icons <Any-Enter> "$nb3.t_license tag configure link_icons $hylink_enter; $nb3.t_license configure -cursor hand1"
		$nb3.t_license tag bind link_icons <Any-Leave> "$nb3.t_license tag configure link_icons $hylink_leave; $nb3.t_license configure -cursor {}"
		$nb3.t_license tag bind link_icons <Button-1> {catch {exec sh -c "xdg-open $::option(root)/license/icons_license.txt" &}}
		
		$nb3.t_license tag configure link_tktray -foreground #0064FF -underline on
		$nb3.t_license tag bind link_tktray <Any-Enter> "$nb3.t_license tag configure link_tktray $hylink_enter; $nb3.t_license configure -cursor hand1"
		$nb3.t_license tag bind link_tktray <Any-Leave> "$nb3.t_license tag configure link_tktray $hylink_leave; $nb3.t_license configure -cursor {}"
		$nb3.t_license tag bind link_tktray <Button-1> {catch {exec sh -c "xdg-open http://sw4me.com/wiki/Tktray" &}}
		
		$nb3.t_license tag configure link_callib -foreground #0064FF -underline on
		$nb3.t_license tag bind link_callib <Any-Enter> "$nb3.t_license tag configure link_callib $hylink_enter; $nb3.t_license configure -cursor hand1"
		$nb3.t_license tag bind link_callib <Any-Leave> "$nb3.t_license tag configure link_callib $hylink_leave; $nb3.t_license configure -cursor {}"
		$nb3.t_license tag bind link_callib <Button-1> {catch {exec sh -c "xdg-open http://wiki.tcl.tk/13497" &}}
		
		$nb3.t_license tag configure link_autoscr -foreground #0064FF -underline on
		$nb3.t_license tag bind link_autoscr <Any-Enter> "$nb3.t_license tag configure link_autoscr $hylink_enter; $nb3.t_license configure -cursor hand1"
		$nb3.t_license tag bind link_autoscr <Any-Leave> "$nb3.t_license tag configure link_autoscr $hylink_leave; $nb3.t_license configure -cursor {}"
		$nb3.t_license tag bind link_autoscr <Button-1> {catch {exec sh -c "xdg-open $::option(root)/extensions/autoscroll/license.terms" &}}
		
		$nb3.t_license tag configure link_fsdialog -foreground #0064FF -underline on
		$nb3.t_license tag bind link_fsdialog <Any-Enter> "$nb3.t_license tag configure link_fsdialog $hylink_enter; $nb3.t_license configure -cursor hand1"
		$nb3.t_license tag bind link_fsdialog <Any-Leave> "$nb3.t_license tag configure link_fsdialog $hylink_leave; $nb3.t_license configure -cursor {}"
		$nb3.t_license tag bind link_fsdialog <Button-1> {catch {exec sh -c "xdg-open http://wiki.tcl.tk/15897" &}}
		$nb3.t_license configure -state disabled
		
		$nb4.t_changelog insert end "The changelog of TV-Viewer is now managed by bazaar,"
		$nb4.t_changelog insert end "\nhosted on "
		$nb4.t_changelog insert end "sourceforge.net" link_sourceforge_bazaar
		$nb4.t_changelog insert end "\n\nThe older, no longer maintained, version of the changelog can be found "
		$nb4.t_changelog insert end "\non the "
		$nb4.t_changelog insert end "homepage" link_changelog
		$nb4.t_changelog insert end "."
		
		$nb4.t_changelog tag configure link_sourceforge_bazaar -foreground #0064FF -underline on
		$nb4.t_changelog tag bind link_sourceforge_bazaar <Any-Enter> "$nb4.t_changelog tag configure link_sourceforge_bazaar $hylink_enter; $nb4.t_changelog configure -cursor hand1"
		$nb4.t_changelog tag bind link_sourceforge_bazaar <Any-Leave> "$nb4.t_changelog tag configure link_sourceforge_bazaar $hylink_leave; $nb4.t_changelog configure -cursor {}"
		$nb4.t_changelog tag bind link_sourceforge_bazaar <Button-1> {catch {exec sh -c "xdg-open http://tv-viewer.bzr.sourceforge.net/bzr/tv-viewer/trunk/changes" &}}
		
		$nb4.t_changelog tag configure link_changelog -foreground #0064FF -underline on
		$nb4.t_changelog tag bind link_changelog <Any-Enter> "$nb4.t_changelog tag configure link_changelog $hylink_enter; $nb4.t_changelog configure -cursor hand1"
		$nb4.t_changelog tag bind link_changelog <Any-Leave> "$nb4.t_changelog tag configure link_changelog $hylink_leave; $nb4.t_changelog configure -cursor {}"
		$nb4.t_changelog tag bind link_changelog <Button-1> {catch {exec sh -c "xdg-open http://home.arcor.de/saedelaere/tv-viewerfiles/CHANGELOG" &}}
		
		$nb4.t_changelog configure -state disabled
		
		tkwait visibility $w
		vid_wmCursor 0
		grab $w
	}
}
