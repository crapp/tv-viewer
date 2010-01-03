namespace import -force msgcat::mcset

set lang de

foreach files [glob -directory "$::option(root)/msgs/de" *.de] {
	source "$files"
}
