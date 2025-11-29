include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

/* [Paring Surface Dimensions] */

// length of the parable surface
l_surf = 100; // [10:1:500]

// depth of the parable surface
d_surf = 30; // [5:1:50]

/* [Plate Dimensions] */

// extends either side of the parable surface
l_hinge = 25; // [5:1:100]

// total height of the plate inside and above the vise
h_plate = 120; // [10:1:500]

// thickness of the plate inside the vise
t_plate = 5; // [1:0.5:30]

/* [Capabilities] */

// paring range up and down
a_range = 20; // [0:1:90]

/* [Hinges] */

// hinge pin diameter
d_hinge_pin = 3.75; // [1:0.01:10]

// hinge knuckle thickness
t_hinge = 2; // [0:0.01:5]

// knuckle diameter
d_knuckle = d_hinge_pin + t_hinge * 2;
echo(t_plate=t_plate);
echo(d_hinge_pin=d_hinge_pin);
echo(t_hinge=t_hinge);
echo(d_knuckle=d_knuckle);

assert(t_plate >= d_knuckle / 2);

// total segments on both sides of the hinge
segs_hinge = 5; // [3:2:11]

/* [Supports] */
d_plate_pin = 3.75; // [1:0.01:10]

/* [Tolerances] */

// vertical gap between the plate and the swing
gap_swing_bottom = 0.2; // [0:0.01:5]

// horizontal gap between the plate and the swing
gap_swing_sides = 0.2; // [0:0.01:5]

// gap between the arm surface and the plate
gap_arm_hinge = 0.1; // [0:0.01:5]

// gap between each hinge knuckle
gap_hinge_knuckle = 0.2;

/* [Dev] */

// model showing paring angle, positive is down
a_swing = 0; // [-45:1:45]

// separate pieces
explode = false;

// half pieces
halves = false;

assert(a_swing <= a_range);
assert(a_swing >= -a_range);

$fn = 200;

module cross_section_arms() {
  difference() {
    cross_section_surf();
    square([d_surf, t_plate + gap_arm_hinge]);
  }
}
module cross_section_surf() {
  polygon(
    [
      [d_surf, 0],
      [0, 0],
      [d_surf * cos(90 - a_range), d_surf * sin(90 - a_range)],
      [d_surf, 0],
    ]
  );
}

module surf_half() {
  color(c="cornflowerblue")
    linear_extrude(h=l_surf / 2, center=false)
      cross_section_surf();
}

module surf() {
  surf_half();
  if (!halves)
    zflip() surf_half();
}

module arms_outer() {
  linear_extrude(h=l_hinge, center=false)
    cross_section_arms();
}

module arms_hinge(length) {
  knuckle_hinge(
    length=length,
    segs=segs_hinge,
    offset=d_knuckle / 2 + d_surf / 2,
    arm_height=0,
    arm_angle=90,
    gap=gap_hinge_knuckle,
    knuckle_diam=d_knuckle,
    pin_diam=d_hinge_pin,
    clear_top=true,
    teardrop=BACK,
    spin=0,
    inner=true,
    anchor=LEFT,
    orient=LEFT,
    clearance=0,
  );
}

module arms_half() {
  z_arms = l_surf / 2;

  dz_hinge = gap_swing_sides;
  z_hinge = l_hinge - dz_hinge; // side gap removed

  color(c="cadetblue")
    translate(v=[0, 0, z_arms])
      arms_outer();

  color(c="skyblue")
    translate(v=[0, 0, z_arms + dz_hinge])
      rotate(a=90 - a_range)
        arms_hinge(length=z_hinge);
}

module arms() {
  arms_half();
  if (!halves)
    zflip() arms_half();
}

module plate_hinge(length, offset) {
  a = asin((d_knuckle / 2) / sqrt(offset ^ 2 + t_plate ^ 2)) + atan(offset / t_plate);
  echo(arm_angle_plate_hinge=a);

  knuckle_hinge(
    length=length,
    segs=segs_hinge,
    offset=offset,
    arm_height=0,
    arm_angle=a,
    gap=gap_hinge_knuckle,
    knuckle_diam=d_knuckle,
    pin_diam=d_hinge_pin,
    clear_top=true,
    teardrop=UP,
    spin=180,
    inner=false,
    anchor=RIGHT,
    orient=LEFT,
    clearance=0,
  );
}

module arms_hinge_mask(z_hinge) {

  z = (z_hinge + 1 * gap_hinge_knuckle) / segs_hinge + gap_hinge_knuckle;

  for (i = [2:2:segs_hinge]) {
    translate(v=[gap_swing_sides, 0, (i - 1) * z - i * gap_hinge_knuckle + z / 2])
      rotate(a=-a_range)
        cube(size=[d_knuckle, d_knuckle * 2, z], center=true);
  }
}

module plate_pins_mask(z_hinge) {
  translate(v=[d_knuckle * 1.5, t_plate / 2, z_hinge / 2])
    rotate(a=90, v=[0, 1, 0])
      cylinder(d=d_plate_pin, h=h_plate);

  translate(v=[d_surf * 1.5, t_plate / 2, 0])
    cylinder(d=d_plate_pin, h=h_plate);
}

// hinges far from origin, built at origin then flipped for simplicity
module plate_half() {
  z_plate = l_surf / 2 + l_hinge;

  z_hinge = l_hinge - gap_swing_sides; // side gap removed

  x_cutout = d_surf + gap_swing_bottom;

  offset_hinge = d_knuckle / 2;

  zflip(z=z_plate / 2) {
    difference() {
      // color(c="chocolate")
      cube(size=[h_plate, t_plate, z_plate], center=false);

      color(c="maroon")
        translate(v=[0, 0, z_hinge])
          cube(size=[x_cutout, t_plate, z_plate], center=false);

      color(c="rosybrown")
        cube([offset_hinge, t_plate, z_hinge]);

      color(c="brown")
        arms_hinge_mask(z_hinge=z_hinge);

      color(c="red")
        plate_pins_mask(z_hinge=z_hinge);
    }

    color(c="goldenrod")
      plate_hinge(length=z_hinge, offset=offset_hinge);
  }
}

module plate() {
  plate_half();
  if (!halves)
    zflip() plate_half();
}

render() {
  translate(v=[0, explode ? -50 : 0, 0])
    plate();
  rotate(a=a_swing + a_range) {
    surf();
    translate(v=[explode ? -50 : 0, 0, 0])
      arms();
  }
}
