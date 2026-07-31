#!/bin/sh

prefix="glasses-case-v1"

rm -f ${prefix}*stl

openscad \
	"${prefix}.scad" \
	-o "${prefix}.front.stl" \
	-D "model=\"front\""

openscad \
	"${prefix}.scad" \
	-o "${prefix}.back.stl" \
	-D "model=\"back\""

openscad \
	"${prefix}.scad" \
	-o "${prefix}.lid.stl" \
	-D "model=\"lid\""

openscad \
	"${prefix}.scad" \
	-o "${prefix}.lid_insert.stl" \
	-D "model=\"lid_insert\""
