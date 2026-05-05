#!/bin/sh

dest="/lord/prn"
prefix="systrum-st"

for show in plate lettering outline; do
	openscad \
		"${prefix}.scad" \
		--enable="textmetrics" \
		-o "${dest}/${prefix}.${show}.stl"\
		-D "show=\"${show}\""
done
