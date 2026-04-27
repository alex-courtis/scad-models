#!/bin/sh

prefix="bench-dogs"

# rm -f ${prefix}*stl

openscad \
	"${prefix}.scad" \
	-o "${prefix}.padding.stl" \
	-D 'show="padding"'

openscad \
	"${prefix}.scad" \
	-o "${prefix}.core.stl" \
	-D 'show="core"'

