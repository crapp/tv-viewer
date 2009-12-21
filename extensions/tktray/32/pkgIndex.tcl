#
# Tcl package index file
#
if {[package vcompare [info tclversion] 8.5] < 0} return

package ifneeded tktray 1.2 \
    [list load [file join $dir libtktray1.2.so] tktray]
