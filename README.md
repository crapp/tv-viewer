<pre>
 _______     __ __     ___                        
|_   _\ \   / / \ \   / (_) _____      _____ _ __ 
  | |  \ \ / /___\ \ / /| |/ _ \ \ /\ / / _ \ '__|
  | |   \ V /_____\ V / | |  __/\ V  V /  __/ |   
  |_|    \_/       \_/  |_|\___| \_/\_/ \___|_|   
</pre>  
--------------------------------------------------


About
-----
TV-Viewer is a small application to watch and record TV.
It is independent from a special Desktop Environment like KDE or Gnome,
because it uses the Tk toolkit.


Requirements
------------
In order to install and use the program you'll need:
 * Tcl and Tk >= 8.5
 * sqlite3 and sqlite3 Tcl bindings
 * ivtv-tune and v4l2-ctl (ivtv-utils).
 * Mplayer >= 1.0rc2 (A most recent version of mplayer is recommended)
 * xdg-utils

It is recommended to install,
 * tkimg (If you use Tcl/Tk < 8.6)
as well.


Optional Features
-----------------

TV-Viewer comes with some optional features. You may choose if you want 
them to be installed or not.

* tktray -   A Tk library to dock Tk to the system tray. (default: enabled)
             Depends on glibc; libxdmcp; libxau; libxcb; libx11
             These dependencies should be installed by default on every linux
             distribution.
* tclkit -   Install TV-Viewer using a tclkit. (default: disabled)
             A tclkit provides a complete TCL/TK environment. You may use
             this if your distribution does not ship an appropriate version
             of Tcl/Tk. Download the tclkit from tv-viewer.sourceforge.net
             and place it in extensions/tclkit/

Use the following switch if you want to enable or disable one of these features

    --enable-FEATURE=ARG (e.g. --enable-tktray=yes/no ; --enable-tclkit=yes/no)

with the configure.tcl script.


Installation
------------
Installing TV-Viewer is done by the following 2 commands:

    $ ./configure.tcl (configures build environment and creates install.tcl)
    % ./install.tcl (you may need root privileges)
For more configuration details run 

    $ ./configure.tcl --help

If there are any errors during installation, check your build environment and 
the file "./config.log". Otherwise contact us and/or have a look at the manual.
http://tv-viewer.sourceforge.net


Uninstall
---------

You can uninstall TV-Viewer with the installation script. This will
delete all program files but your configuration will still be present
("~/.tv-viewer/").

    % ./install.tcl --uninstal (You may need root privileges)


Usage
-----
To run TV-Viewer just type

    % tv-viewer

on a console.
There are several command line options. Run

    % tv-viewer --help

for details.
For basic usage informations have a look at the man page.

    % man tv-viewer


License
-------
TV-Viewer is distributed under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version. A copy of this license
can be found in 

    license/license_gpl-2.0.txt

The icons, distributed with TV-Viewer, are covered by different licenses. See 

    license/icons_license.txt

tktray:

The shared library libtktray1.3.9.so is copyrighted by Anton Kovalenko under the BSD
license.

http://sw4me.com/wiki/Tktray

callib:

Callib is a calendar widget of which TV-Viewer makes us of. It is copyrighted by Jaafar Mejri.

http://wiki.tcl.tk/13497

autoscroll:

Autoscroll is part of tklib. The library was originally written by Kevin B Kenny.
For copyright infos see 

    extensions/autoscroll/license.terms

fsdialog:

Copyright (C) Schelte Bron. Freely redistributable.

http://wiki.tcl.tk/15897

## Ideas, questions, patches and bug reports ##

Project site https://github.com/crapp/tv-viewer

Homepage http://tv-viewer.sourceforge.net


Copyright 2007-2015 Christian Rapp
0x2a(at)posteo(dot)org
