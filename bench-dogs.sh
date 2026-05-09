#!/bin/sh

dest="/lord/prn"
prefix="bench-dogs"

openscad \
	"${prefix}.scad" \
	-o "${dest}/${prefix}.dogs.padding.stl" \
	-D 'model="dogs"' \
	-D 'show="padding"'

openscad \
	"${prefix}.scad" \
	-o "${dest}/${prefix}.dogs.core.stl" \
	-D 'model="dogs"' \
	-D 'show="core"'

openscad \
	"${prefix}.scad" \
	-o "${dest}/${prefix}.helping_hands.stl" \
	-D 'model="helping_hands"'

