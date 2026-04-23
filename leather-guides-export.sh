#!/bin/sh

prefix="leather-guides"

rm -f ${prefix}*stl

openscad \
	"${prefix}.scad" \
	-o "${prefix}.straight-body.stl" \
	-D "show_awl_guide_circle=false" \
	-D "show_awl_guide_straight=true" \
	-D "render_text=true" &

openscad \
	"${prefix}.scad" \
	-o "${prefix}.straight-text.stl" \
	-D "show_awl_guide_circle=false" \
	-D "show_awl_guide_straight=true" \
	-D "render_text=true"  \
	-D "show_text_only=true"&

for d in 20 22.5 25 27.5 30 35 40 45 50 55 60 70 80 90 100; do
	openscad \
		"${prefix}.scad" \
		-o "${prefix}.${d}-body.stl" \
		-D "d_circle_hole=${d}" \
		-D "show_awl_guide_circle=true" \
		-D "show_awl_guide_straight=false" \
		-D "render_text=true" &

	openscad \
		"${prefix}.scad" \
		-o "${prefix}.${d}-text.stl" \
		-D "d_circle_hole=${d}" \
		-D "show_awl_guide_circle=true" \
		-D "show_awl_guide_straight=false" \
		-D "render_text=true" \
		-D "show_text_only=true" &

	done

