#!/bin/sh

dest="/lord/prn"
prefix="bench-dogs"

# rm -f ${prefix}*stl

openscad \
	"${prefix}.scad" \
	-o "${dest}/${prefix}.padding.stl" \
	-D 'model="dogs"' \
	-D 'show="padding"'

openscad \
	"${prefix}.scad" \
	-o "${dest}/${prefix}.core.stl" \
	-D 'model="dogs"' \
	-D 'show="core"'

openscad \
	"${prefix}.scad" \
	-o "${dest}/${prefix}.core.stl" \
	-D 'model="helping_hands"'

