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
	-o "${prefix}.wall.stl" \
	-D "model=\"glasses\"" \
	-D "part=\"wall\""
