#
# Tcl package index file
#
if {[package vcompare [info tclversion] 8.4] < 0} return

package ifneeded tktray 1.3.9 \
    [list load [file join $dir libtktray1.3.9.so] tktray]
