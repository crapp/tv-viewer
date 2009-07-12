namespace import -force msgcat::mcset

set lang de

foreach files [glob -directory "$::where_is/msgs/de" *.de] {
	source "$files"
}
