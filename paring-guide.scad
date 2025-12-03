include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

/*
TODO
braces are separating from plate
h_surf_arms
fitting cutout size and shape
fitting upper
fitting lower
*/

/* [Paring Surface Dimensions] */

// length of the paring surface
l_surf = 150; // [10:1:500]

// width of the paring surface
w_surf = 30; // [5:1:100]

// back of the paring surface
chamfer_surf = 1.5; // [0:0.05:10]

// thickness of the paring surface
t_surf = 6; // [1:0.5:20]

/* [Plate Dimensions] */

// extends either side of the paring surface
l_arm = 25; // [5:1:100]

// total height of the plate inside and above the vise
w_plate = 120; // [10:1:500]

// thickness of the plate inside the vise
t_plate = 7; // [1:0.5:30]

// thickness of the arms under the plate
t_brace = 5; // [1:0.1:30]

// height of the plate above the vise
h_plate = 30; // [15:1:200]

// height of the arms; must be above h_plate
h_arm = 24; // [1:1:20]

/* [Capabilities] */

// paring range up and down
a_range = 20; // [0:1:45]

/* [Pins] */

// hinge pin diameter - arms and plate
d_hinge_pin = 3.85; // [1:0.01:10]

// horizontal pins in arms
d_arm_pin = 4.00; // [1:0.01:10]

// horizontal pins below surface
d_surf_pin = 3.85; // [1:0.01:10]

// vertical pin through plate to hinges, d_knuckle from top, inside of hinge from sides
d_plate_pin_vert = 3.95; // [1:0.01:10]

// horizontal pin through plate for screw fitting
d_plate_pin_horiz = 4.00; // [1:0.01:10]

// vise stop pin, inset from sides twice this
d_plate_pin_stop = 3.90; // [1:0.01:10]

d_max_arm_surf_pin = max(d_arm_pin, d_surf_pin);
echo(d_max_arm_surf_pin=d_max_arm_surf_pin);

/* [Hinges] */

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

/* [Tolerances] */

// height of the surface above the arms
h_surf_arms = 0.8; // [0:0.01:5]

// horizontal gap between the plate and paring surface
gap_plate_sides = 0.4; // [0:0.01:5]

// gap between the arm surface and the plate
gap_arm_plate = 0.25; // [0:0.01:5]

// gap between each hinge knuckle
gap_hinge_knuckle = 0.2; // [0:0.01:5]

// gap between plate hinge bottom and arm hinge arms
gap_hinge_arms_plate = 0.5; // [0:0.01:5]

/* [Dev] */

// model showing paring angle, positive is down
a_display = -35; // [-90:1:90]

explode = 0; // [0:1:100]
halves = false;
show_plate = true;
show_arms = true;
show_surf = true;

$fn = 200; // [40:1:1000]

// see fig1
module cross_section(part, d_pin) {
  a = 90 - a_range;

  // surface points clockwise from origin
  Ax = w_surf * cos(a);
  Ay = w_surf * sin(a);

  Bx = Ax + t_surf / sin(a);
  By = Ay;

  Fx = t_surf / sin(a);
  Fy = 0;

  path_surf = [
    [0, 0],
    [Ax, Ay],
    [Bx, By],
    [Fx, Fy],
  ];

  Cx = h_arm;
  Cy = Ay;
  Dx = h_arm;
  Dy = t_plate + gap_arm_plate;
  Ex = Fx + t_plate / tan(a) + gap_arm_plate / tan(a); // push out both gaps
  Ey = t_plate + gap_arm_plate;

  path_brace = [
    [Bx, By],
    [Cx, Cy],
    [Dx, Dy],
    [Ex, Ey],
  ];

  Gx = Ex - Fx;
  Gy = Ey;

  path_arm = [
    [Gx, Gy],
    [Ax, Ay],
    [Bx, By],
    [Ex, Ey],
  ];

  centre_pin_lower = [
    Cx - d_max_arm_surf_pin,
    Cy - d_max_arm_surf_pin,
  ];

  // kiss the bottom plate surface
  centre_pin_upper = [
    Fx + (Ey + d_max_arm_surf_pin) / tan(a) + (d_max_arm_surf_pin / 2) / sin(a),
    Ey + d_max_arm_surf_pin,
  ];

  if (part == "surf") {
    // chamfer the top edges
    polygon(
      round_corners(
        path_surf,
        width=[0, chamfer_surf, 0, 0],
        method="chamfer"
      )
    );
  } else if (part == "brace") {
    // chamfer the bottom edges
    polygon(
      round_corners(
        path_brace,
        width=[0, chamfer_surf, 0, 0],
        method="chamfer"
      )
    );
  } else if (part == "arm") {
    // chamfer the top edges
    polygon(
      round_corners(
        path_arm, width=[0, chamfer_surf, 0, 0],
        method="chamfer"
      )
    );
  } else if (part == "pin_lower") {
    translate(v=centre_pin_lower)
      circle(d=d_pin);
  } else if (part == "pin_upper") {
    translate(v=centre_pin_upper)
      circle(d=d_pin);
  }
}

module surf_half() {
  difference() {
    union() {
      color(c="cornflowerblue")
        linear_extrude(h=l_surf / 2, center=false)
          cross_section(part="surf");

      // braces to meet arm with thirds cutout
      color(c="turquoise")
        translate(v=[0, 0, l_surf / 2 - t_brace])
          linear_extrude(h=t_brace, center=false)
            cross_section(part="brace");

      color(c="steelblue")
        translate(v=[0, 0, l_surf / 6 - t_brace * 2 / 3])
          linear_extrude(h=t_brace, center=false)
            cross_section(part="brace");
    }

    color(c="pink")
      linear_extrude(h=l_surf / 2, center=false)
        cross_section(part="pin_upper", d_pin=d_surf_pin);

    color(c="red")
      linear_extrude(h=l_surf / 2, center=false)
        cross_section(part="pin_lower", d_pin=d_surf_pin);
  }
}

module surf() {
  surf_half();
  if (!halves)
    zflip() surf_half();
}

module arms_hinge(length) {
  mirror(v=[0, 1, 0])
    knuckle_hinge(
      length=length,
      segs=n_hinge_segs,
      offset=d_knuckle / 2,
      arm_height=d_knuckle,
      arm_angle=90 - a_range,
      gap=gap_hinge_knuckle,
      knuckle_diam=d_knuckle,
      pin_diam=d_hinge_pin,
      clear_top=true,
      teardrop=false,
      spin=0,
      inner=true,
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
      color(c="blue")
        translate(v=[0, 0, z_arms])
          linear_extrude(h=l_arm, center=false)
            cross_section(part="arm");

      color(c="cadetblue")
        translate(v=[0, 0, z_arms])
          linear_extrude(h=l_arm, center=false)
            cross_section(part="brace");

      color(c="skyblue")
        translate(v=[0, 0, z_arms + dz_hinge])
          rotate(a=-a_range)
            arms_hinge(length=z_hinge);
    }

    color(c="pink")
      translate(v=[0, 0, z_arms])
        linear_extrude(h=z_arms / 2, center=false)
          cross_section(part="pin_lower", d_pin=d_arm_pin);

    color(c="maroon")
      translate(v=[0, 0, z_arms])
        linear_extrude(h=z_arms / 2, center=false)
          cross_section(part="pin_upper", d_pin=d_arm_pin);
  }
}

module arms() {
  arm_half();
  if (!halves)
    zflip() arm_half();
}

module plate_hinge(length, offset) {
  mirror(v=[0, 1, 0])
    knuckle_hinge(
      length=length,
      segs=n_hinge_segs,
      offset=offset,
      arm_height=t_plate - d_knuckle / 2,
      arm_angle=90,
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

module plate_pins_mask(z_hinge, z_plate) {
  // vertical pins
  translate(v=[d_knuckle, t_plate / 2, z_hinge - d_plate_pin_vert / 2])
    rotate(a=90, v=[0, 1, 0])
      cylinder(d=d_plate_pin_vert, h=w_plate);

  // vise stop
  translate(v=[h_plate - d_plate_pin_stop, t_plate, d_plate_pin_stop * 2.5])
    rotate(a=90, v=[1, 0, 0])
      cylinder(d=d_plate_pin_stop, h=t_plate);

  // cutout for screw fitting
  translate(v=[h_plate - d_plate_pin_horiz * 3.0, 0, z_plate - d_plate_pin_horiz])
    cube(size=[d_plate_pin_horiz * 4.0, t_plate, d_plate_pin_horiz], center=false);

  // horizontaly through the for screw fitting
  translate(v=[h_plate - d_plate_pin_horiz, t_plate / 2, -l_arm])
    cylinder(d=d_plate_pin_horiz, h=l_surf + l_arm);
}

// hinges far from origin, built at origin then flipped for simplicity
module plate_half() {
  z_plate = l_surf / 2 + l_arm;

  z_hinge = l_arm - gap_plate_sides; // side gap removed

  x_cutout = t_surf * 1.6; // + gap_plate_surf;

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
        plate_pins_mask(z_hinge=z_hinge, z_plate);
    }

    // color(c="goldenrod")
    //   plate_hinge(length=z_hinge, offset=offset_hinge_knuckle);
  }
}

module plate() {
  plate_half();
  if (!halves)
    zflip() plate_half();
}

module assemble() {
  a = min(max(a_display, -a_range), a_range) + a_range;

  translate(v=[0, -explode, 0]) if (show_plate) plate();
  rotate(a=a) {
    translate(v=[explode, 0, 0]) if (show_surf) surf();
    translate(v=[-explode, 0, 0]) if (show_arms) arms();
  }
}

render() assemble();
