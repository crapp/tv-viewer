namespace import -force msgcat::mcset

set lang en

foreach files [glob -directory "$::option(root)/msgs/en" *.en] {
	source "$files"
}
