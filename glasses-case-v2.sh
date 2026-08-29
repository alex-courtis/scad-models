#!/bin/sh

dir="/lord/prn"
prefix="glasses-case-v2"
rev="$(git rev-parse --short @)"

rm -f "${dir}/${prefix}"*stl

params_off="$(grep '^show_' "${prefix}.scad" | sed -E 's/true/false/g')"

for p in $(echo "${params_off}" | sed -E 's/ =.*;$//g'); do
	n="$(echo "${p}" | sed -E 's/show_//g')"
	openscad \
		"${prefix}.scad" \
		-o "${dir}/${prefix}.${rev}.${n}.stl" \
		-D "${params_off}" \
		-D "fold=false" \
		-D "${p}=true"
	done
