#!/bin/sh

for s in ${*}; do
	for p in knob indicator; do
		printf "\n------------------------%s------------------------\n" "${s}.${p}.stl"
		openscad-nightly vol.scad -p vol.json -P "${s}" -o "${s}.${p}.stl" -D "piece=\"${p}\""
	done
done

