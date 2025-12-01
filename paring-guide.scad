include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

/* [Paring Surface Dimensions] */

// length of the parable surface
l_surf = 100; // [10:1:500]

// width of the parable surface
w_surf = 30; // [5:1:100]

// radius of the rear smoothing of the parable surface
r_surf = 2; // [0:0.05:10]

// thickness of the parable surface
t_surf = 10; // [1:0.5:20]

/* [Plate Dimensions] */

// extends either side of the parable surface
l_arm = 25; // [5:1:100]

// total height of the plate inside and above the vise
w_plate = 120; // [10:1:500]

// thickness of the plate inside the vise
t_plate = 7; // [1:0.5:30]

// thickness of the arms under the plate
t_arm = 5; // [1:0.1:30]

/* [Capabilities] */

// paring range up and down
a_range = 20; // [0:1:45]

/* [Hinges] */

// hinge pin diameter
d_hinge_pin = 3.85; // [1:0.01:10]

// hinge knuckle thickness: radius beyond pin
t_hinge_knuckle = 3; // [0:0.01:5]

// knuckle diameter
d_knuckle = d_hinge_pin + t_hinge_knuckle * 2;
echo(t_plate=t_plate);
echo(d_hinge_pin=d_hinge_pin);
echo(t_hinge_knuckle=t_hinge_knuckle);
echo(d_knuckle=d_knuckle);

assert(t_plate >= d_knuckle / 2);

// total segments on both sides of the hinge
n_hinge_segs = 5; // [2:1:11]

/* [Supports] */
// d_arm_pin = 4.00; // [1:0.01:10]
d_arm_pin = 8.000000; // [1:0.01:10]

// d_surf_pin = 3.95; // [1:0.01:10]
d_surf_pin = 1.000000; // [1:0.01:10]

d_plate_pin = 3.90; // [1:0.01:10]

/* [Tolerances] */

// vertical gap between the plate and parable surface
gap_plate_surf = 0.2; // [0:0.01:5]

// horizontal gap between the plate and parable surface
gap_plate_sides = 0.2; // [0:0.01:5]

// gap between the arm surface and the plate
gap_arm_plate = 0.1; // [0:0.01:5]

// gap between each hinge knuckle
gap_hinge_knuckle = 0.2; // [0:0.01:5]

// gap between plate hinge bottom and arm hinge arms
gap_hinge_arms_plate = 0.5; // [0:0.01:5]

/* [Dev] */

// model showing paring angle, positive is down
a_display = -35; // [-90:1:90]

// separate pieces
explode = 0; // [0:1:100]

// half pieces
halves = false;

$fn = 200;

module cross_section(part) {
  a = 90 - a_range;

  // surface points clockwise from origin
  Ax = w_surf * cos(a);
  Ay = w_surf * sin(a);
  Bx = Ax + t_surf * sin(a);
  By = Ay - t_surf * cos(a);
  Cx = t_surf / sin(a);
  Cy = 0;

  path_surf = [
    [0, 0],
    [Ax, Ay],
    [Bx, By],
    [Cx, Cy],
  ];

  // arm points clockwise from closest to origin
  Tx = t_plate / tan(a);
  Ty = t_plate;
  // A
  // B
  Ux = Bx;
  Uy = t_plate;

  path_arm = [
    [Tx, Ty + gap_arm_plate],
    [Ax, Ay],
    [Bx, By],
    [Ux, Uy + gap_arm_plate],
  ];

  if (part == "surf") {
    // round the back corner
    polygon(round_corners(path_surf, radius=[0, r_surf, 0, 0], method="circle"));
  } else if (part == "arm") {
    // round the bottom and back corners
    polygon(round_corners(path_arm, radius=[0, r_surf, 0, 0], method="circle"));
  }
}

module surf_half() {
  difference() {
    union() {
      color(c="cornflowerblue")
        linear_extrude(h=l_surf / 2, center=false)
          cross_section(part="surf");

      // braces to meet arm and at thirds 
      color(c="blue") {
        translate(v=[0, 0, l_surf / 2 - t_arm])
          linear_extrude(h=t_arm, center=false)
            cross_section(part="arm");
        translate(v=[0, 0, l_surf / 6 - t_arm * 2 / 3])
          linear_extrude(h=t_arm, center=false)
            cross_section(part="arm");
      }
    }
    arm_pins_mask(d_pin=d_surf_pin);
  }
}

module surf() {
  surf_half();
  if (!halves)
    zflip() surf_half();
}

module arm_pins_mask(z_hinge, d_pin) {
  // TODO: pin for lever
  // TODO: make these line up
  rotate(a=-a_range) {
    translate(v=[d_pin, w_surf - d_pin, 0])
      cylinder(d=d_pin, h=l_surf);
    translate(v=[d_pin, w_surf / 2, 0])
      cylinder(d=d_pin, h=l_surf);
  }
}

module arms_hinge(length, inner = true) {
  knuckle_hinge(
    length=length,
    segs=n_hinge_segs,
    offset=d_knuckle / 2 + w_surf / 2,
    arm_height=0,
    arm_angle=90,
    gap=gap_hinge_knuckle,
    knuckle_diam=d_knuckle,
    pin_diam=d_hinge_pin,
    clear_top=true,
    teardrop=BACK,
    spin=0,
    inner=inner,
    anchor=LEFT,
    orient=LEFT,
    clearance=0,
  );
}

module arm_half() {
  z_arms = l_surf / 2;

  dz_hinge = gap_plate_sides;
  z_hinge = l_arm - dz_hinge; // side gap removed

  difference() {
    union() {
      color(c="cadetblue")
        translate(v=[0, 0, z_arms])
          linear_extrude(h=l_arm, center=false)
            cross_section(part="arm");

      color(c="skyblue")
        translate(v=[0, 0, z_arms + dz_hinge])
          rotate(a=90 - a_range)
            arms_hinge(length=z_hinge);
    }

    color(c="red")
      arm_pins_mask(z_hinge=z_hinge, d_pin=d_arm_pin);
  }
}

module arms() {
  arm_half();
  if (!halves)
    zflip() arm_half();
}

module plate_hinge(length, offset) {
  a = asin((d_knuckle / 2) / sqrt(offset ^ 2 + t_plate ^ 2)) + atan(offset / t_plate);
  echo(arm_angle_plate_hinge=a);

  mirror(v=[0, 1, 0])
    knuckle_hinge(
      length=length,
      segs=n_hinge_segs,
      offset=offset,
      arm_height=0,
      arm_angle=a,
      gap=gap_hinge_knuckle,
      knuckle_diam=d_knuckle,
      pin_diam=d_hinge_pin,
      clear_top=true,
      teardrop=UP,
      spin=0,
      inner=false,
      anchor=LEFT,
      orient=LEFT,
      clearance=0,
    );
}

module arms_hinge_mask(z_hinge) {

  z = (z_hinge + 1 * gap_hinge_knuckle) / n_hinge_segs + gap_hinge_knuckle;

  for (i = [1 + n_hinge_segs % 2:2:n_hinge_segs]) {
    translate(v=[gap_hinge_arms_plate, 0, (i - 1) * z - i * gap_hinge_knuckle + z / 2])
      rotate(a=-a_range)
        cube(size=[d_knuckle, w_plate * 2, z], center=true);
  }
}

module plate_pins_mask(z_hinge) {
  translate(v=[d_knuckle * 2, t_plate / 2, z_hinge / 2])
    rotate(a=90, v=[0, 1, 0])
      cylinder(d=d_plate_pin, h=w_plate);

  translate(v=[w_surf * 1.5, t_plate / 2, -l_arm])
    cylinder(d=d_plate_pin, h=l_surf + l_arm);
}

// hinges far from origin, built at origin then flipped for simplicity
module plate_half() {
  z_plate = l_surf / 2 + l_arm;

  z_hinge = l_arm - gap_plate_sides; // side gap removed

  // TODO cut exactly
  x_cutout = t_surf * 1.8; // + gap_plate_surf;

  offset_hinge_knuckle = d_knuckle / 2;

  zflip(z=z_plate / 2) {
    difference() {
      color(c="chocolate")
        cube(size=[w_plate, t_plate, z_plate], center=false);

      color(c="maroon")
        translate(v=[0, 0, z_hinge])
          cube(size=[x_cutout, t_plate, z_plate], center=false);

      color(c="rosybrown")
        cube([offset_hinge_knuckle, t_plate, z_hinge]);

      color(c="brown")
        arms_hinge_mask(z_hinge=z_hinge);

      color(c="red")
        plate_pins_mask(z_hinge=z_hinge);
    }

    color(c="goldenrod")
      plate_hinge(length=z_hinge, offset=offset_hinge_knuckle);
  }
}

module plate() {
  plate_half();
  if (!halves)
    zflip() plate_half();
}

render() {
  a = min(max(a_display, -a_range), a_range) + a_range;

  translate(v=[0, -explode, 0])
    plate();
  rotate(a=a) {
    translate(v=[explode, 0, 0])
      surf();
    translate(v=[-explode, 0, 0])
      arms();
  }
}
