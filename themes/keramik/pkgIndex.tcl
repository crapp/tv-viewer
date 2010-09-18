# pkgIndex.tcl for additional tile pixmap themes.
#
# We don't provide the package is the image subdirectory isn't present,
# or we don't have the right version of Tcl/Tk
#
# To use this automatically within tile, the tile-using application should
# use tile::availableThemes and tile::setTheme 
#
# $Id: pkgIndex.tcl,v 1.12 2010/09/05 13:59:44 sbron Exp $

if {![file isdirectory [file join $dir keramik]]} { return }
if {![package vsatisfies [package provide Tcl] 8.4]} { return }

package ifneeded ttk::theme::keramik 0.6.2 \
    [list source [file join $dir keramik.tcl]]
package ifneeded ttk::theme::keramik_alt 0.6.2 \
    [list source [file join $dir keramik.tcl]]
