include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

$fn = 200;

// length of the parable surface
l_guide = 100; // [10:1:500]

// extends either side of the parable surface
l_hinge = 25; // [5:1:100]

// depth of the parable surface
d_guide = 30; // [5:1:50]

// total height of the plate inside and above the vise
h_plate = 120; // [10:1:500]

// thickness of the plate inside the vise
t_plate = 5; // [1:0.5:30]

// paring range up and down
a_paring_range = 20; // [0:1:90]

// model showing paring angle: positive is down
a_paring = 0; // [-45:1:45]

assert(a_paring <= a_paring_range);
assert(a_paring >= -a_paring_range);

// hinge pin diameter
d_pin = 3.75; // [1:0.01:10]

// hinge knuckle thickness
t_hinge = 2; // [0:0.01:5]

// knuckle diameter
d_knuckle = d_pin + t_hinge * 2;
echo(t_plate=t_plate);
echo(d_knuckle=d_knuckle);

assert(t_plate >= d_knuckle / 2);

// total segments on both sides of the hinge
segs_hinge = 5;

// gap between the bottom of the guide and the plate
gap_guide_bottom = 0.2; // [0:0.01:5]

// gap between the sides of the guide and the plate
gap_guide_sides = 0.2; // [0:0.01:5]

// gap between guide hinges and plate
gap_guide_hinge = 0.1; // [0:0.01:5]

// gap between each hinge knuckle
gap_hinge_knuckle = 0.2;

explode = false;

module cross_section_guide_outer() {
  difference() {
    cross_section_guide();
    square([d_guide, t_plate + gap_guide_hinge]);
  }
}
module cross_section_guide() {
  polygon(
    [
      [d_guide, 0],
      [0, 0],
      [d_guide * cos(90 - a_paring_range), d_guide * sin(90 - a_paring_range)],
      [d_guide, 0],
    ]
  );
}

module part_guide_surface() {
  color(c="cornflowerblue")
    linear_extrude(h=l_guide, center=true)
      cross_section_guide();
}

module part_guide_outer() {
  color(c="cadetblue")
    linear_extrude(h=l_hinge, center=true)
      cross_section_guide_outer();
}

module part_guide_hinge() {
  color(c="aqua")
    knuckle_hinge(
      length=l_hinge,
      segs=segs_hinge,
      offset=t_plate / 2,
      arm_height=t_plate / 2 - 0.00000001, // cannot be exactly half a knuckle
      arm_angle=90 - a_paring_range,
      gap=gap_hinge_knuckle,
      knuckle_diam=t_plate,
      pin_diam=d_pin,
      clear_top=false,
      teardrop=true,
      spin=180,
      inner=false,
      anchor=CENTER,
      orient=LEFT,
    );
}

module part_guide() {
  part_guide_surface();
  translate(v=[0, 0, (l_hinge + l_guide) / 2]) {
    part_guide_outer();
    rotate(a=-a_paring_range)
      part_guide_hinge();
  }
  translate(v=[0, 0, -(l_hinge + l_guide) / 2])
    part_guide_outer();
}

module part_plate_hinge(inner, length, offset) {
  a = asin((d_knuckle / 2) / sqrt(offset ^ 2 + t_plate ^ 2)) + atan(offset / t_plate);

  knuckle_hinge(
    length=length,
    segs=segs_hinge,
    offset=offset,
    arm_height=0,
    arm_angle=a,
    gap=gap_hinge_knuckle,
    knuckle_diam=d_knuckle,
    pin_diam=d_pin,
    clear_top=true,
    teardrop=true,
    spin=180,
    inner=inner,
    anchor=RIGHT,
    orient=LEFT,
  );
}

// hinges far from origin, built at origin then flipped for simplicity
module plate_half() {
  z_plate = l_guide / 2 + l_hinge;

  z_hinge = l_hinge - gap_guide_sides; // side gap removed

  x_cutout = d_guide + gap_guide_bottom;

  offset_hinge = d_knuckle / 2;

  zflip(z=z_plate / 2) {
    difference() {
      color(c="chocolate")
        cube(size=[h_plate, t_plate, z_plate], center=false);

      color(c="maroon")
        translate(v=[0, 0, z_hinge])
          cube(size=[x_cutout, t_plate, z_plate], center=false);

      color(c="rosybrown")
        cube([offset_hinge, t_plate, z_hinge]);
    }

    color(c="goldenrod")
      part_plate_hinge(inner=false, length=z_hinge, offset=offset_hinge);
  }
}

module plate() {
  plate_half();
  zflip() plate_half();
}

render() {
  plate();
  rotate(a=a_paring + a_paring_range)
  part_guide();
}
