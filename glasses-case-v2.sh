#!/bin/sh

dir="/lord/prn"
prefix="glasses-case-v2"
rev="$(git rev-parse --short @)"

rm -f "${dir}/${prefix}"*stl

off="show_lid=false;show_back=false;show_front=false;show_leather_wall_front=false;show_leather_wall_back=false;show_leather_side_left=false;show_leather_side_right=false;fold_leather=false"

for p in front back leather_wall_front leather_side_left; do
	openscad \
		"${prefix}.scad" \
		-o "${dir}/${prefix}.${rev}.${p}.stl" \
		-D "${off}" \
		-D "show_${p}=true"
done
