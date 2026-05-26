#!/bin/sh

prefix="leather-frame"

rm -f ${prefix}*stl

openscad \
	"${prefix}.scad" \
	-o "${prefix}.side.stl" \
	-D "model=\"glasses\"" \
	-D "part=\"side\""

openscad \
	"${prefix}.scad" \
	-o "${prefix}.wall_left.stl" \
	-D "model=\"glasses\"" \
	-D "part=\"wall_left\""

openscad \
	"${prefix}.scad" \
	-o "${prefix}.wall_right.stl" \
	-D "model=\"glasses\"" \
	-D "part=\"wall_right\""

