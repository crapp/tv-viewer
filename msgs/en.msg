namespace import -force msgcat::mcset

set lang en

foreach files [glob -directory "$::where_is/msgs/en" *.en] {
	source "$files"
}
