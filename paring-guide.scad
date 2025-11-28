include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

$fn = 200;

// length of the parable surface
l_guide = 150; // [10:1:500]

// depth of the parable surface
d_guide = 30; // [5:1:50]

// paring range up and down
a_paring_range = 20; // [0:1:90]

// model showing paring angle: positive is down
a_paring = 0; // [-45:1:45]

assert(a_paring <= a_paring_range);
assert(a_paring >= -a_paring_range);

// thickness of the back inside the vise, knuckle diameter of hinges
t_back = 6; // [1:0.5:30]

// total height of the back inside and above the vise
h_back = 120; // [10:1:500]

// extends either side of the parable surface
l_hinge = 25; // [5:1:100]

// gap between the bottom of the guide and the back
gap_guide_bottom = 0.1; // [0:0.01:5]

// gap between the sides of the guide and the back
gap_guide_sides = 0.1; // [0:0.01:5]

// gap between guide hinges and back
gap_guide_hinge = 0.1; // [0:0.01:5]

// gap between each hinge knuckle
gap_hinge_knuckle = 0.2;

// hinge pin diameter
d_pin = 3.75; // [1:0.01:10]

// hinge knuckle thickness
t_hinge = 2;

// knuckle diameter
d_knuckle = d_pin + t_hinge * 2;
echo(t_back=t_back);
echo(d_knuckle=d_knuckle);

// total segments on both sides of the hinge
segs_hinge = 5;

explode = false;

module cross_section_guide_outer() {
  difference() {
    cross_section_guide();
    square([d_guide, t_back + gap_guide_hinge]);
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
      offset=t_back / 2,
      arm_height=t_back / 2 - 0.00000001, // cannot be exactly half a knuckle
      arm_angle=90 - a_paring_range,
      gap=gap_hinge_knuckle,
      knuckle_diam=t_back,
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
    // rotate(a=90-a_paring_range)
    rotate(a=-a_paring_range)
      part_guide_hinge();
  }
  translate(v=[0, 0, -(l_hinge + l_guide) / 2])
    part_guide_outer();
}

module part_back_hinge(inner) {
  a = 2 * atan((d_knuckle / 2) / t_back);

  color(c="orange")
    knuckle_hinge(
      length=l_hinge,
      segs=segs_hinge,
      offset=d_knuckle / 2,
      arm_height=0,
      arm_angle=a,
      gap=gap_hinge_knuckle,
      knuckle_diam=d_knuckle,
      pin_diam=d_pin,
      clear_top=true,
      teardrop=true,
      spin=180,
      inner=inner,
      anchor=CENTER,
      orient=LEFT,
    );
}

module part_back() {
  x_back = h_back;
  y_back = t_back;
  z_back = l_guide + 2 * l_hinge;

  x_cutout = d_guide + gap_guide_bottom;
  y_cutout = t_back;
  z_cutout = l_guide + gap_guide_sides * 2;

  dx_cutout = -x_back / 2 + x_cutout / 2;

  dx_hinge = -x_back / 2;
  dz_hinge = (z_back - l_hinge) / 2;

  translate(v=[x_back / 2, y_back / 2, 0]) {
    difference() {
      // back
      color(c="chocolate")
        cube(size=[x_back, y_back, z_back], center=true);

      // cutout the guide
      color(c="maroon")
        translate(v=[dx_cutout, 0, 0])
          cube(size=[x_cutout, y_cutout, z_cutout], center=true);

      // cutout hinges with extra clearance
      // TODO cut this out with an angle to match the guide
      // maybe swung down to range angle with a longer arm height
      color(c="black")
        translate(v=[dx_hinge, 0, dz_hinge])
          bounding_box()
            part_back_hinge(inner=false);
      color(c="black")
        translate(v=[dx_hinge, 0, -dz_hinge])
          bounding_box()
            part_back_hinge(inner=false);
    }

    // hinges
    translate(v=[dx_hinge, 0, dz_hinge])
      part_back_hinge(inner=true);
    translate(v=[dx_hinge, 0, -dz_hinge])
      part_back_hinge(inner=true);
  }
}

render() {
  part_back();
  rotate(a=a_paring + a_paring_range)
    part_guide();
}
