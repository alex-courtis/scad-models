include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

/*
Surface depth cannot be greater than 30:
- short chisels
- deep joints

h_plate should be <=20:
- racking of piece

Range ~15:
- 5-7 rake generally for tables and chairs
- 12-15 chair legs

Surface must firmly contact piece. Tolerance offset may be necessary.

Surface must be rigid across entire length. Consider resting on vise:
- mid fitting to set angle
- firmly lock down ends once in place
- twisting is a problem
*/

/* [Paring Surface Dimensions] */

// length of the paring surface
l_surf = 150; // [10:1:500]

// width of the paring surface
w_surf = 35; // [5:1:100]

// back of the paring surface
chamfer_surf = 2.0; // [0:0.05:10]

// thickness of the paring surface
t_surf = 4; // [1:0.5:20]

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
d_plate_pin_stop = 3.95; // [1:0.01:10]

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
a_display = -20; // [-45:1:45]

explode = 0; // [0:1:100]
halves = false;
show_plate = false;
show_arms = false;
show_surf = false;
show_fitting_lower = false;
show_fitting_upper = false;
show_slide = true;

$fn = 200; // [40:1:1000]

// see fig1
module cross_section(part, d_pin, dx_epsilon_brace = 0) {
  a = 90 - a_range;

  // surface points clockwise from origin
  Ax = w_surf * cos(a);
  Ay = w_surf * sin(a);

  Bx = Ax + t_surf / sin(a);
  By = Ay;

  Fx = t_surf / sin(a);
  Fy = 0;

  // brace points clockwise from origin
  // Bx
  // By
  Cx = h_arm;
  Cy = Ay;
  Dx = h_arm;
  Dy = t_plate + gap_arm_plate;
  Ex = Fx + t_plate / tan(a) + gap_arm_plate / tan(a); // push out both gaps
  Ey = t_plate + gap_arm_plate;

  // arm points clockwise from origin
  Gx = Ex - Fx;
  Gy = Ey;
  // Ax
  // Ay
  // Bx
  // By
  // Ex
  // Ey

  path_surf = [
    [0, 0],
    [Ax, Ay],
    [Bx, By],
    [Fx, Fy],
  ];

  path_brace = [
    [Bx + dx_epsilon_brace, By],
    [Cx, Cy],
    [Dx, Dy],
    [Ex + dx_epsilon_brace, Ey],
  ];

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
    Fx + (Ey + d_surf_pin) / tan(a) + (d_surf_pin / 2) / sin(a),
    Ey + d_surf_pin,
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
            cross_section(part="brace", dx_epsilon_brace=-0.0001);

      color(c="steelblue")
        translate(v=[0, 0, l_surf / 6 - t_brace * 2 / 3])
          linear_extrude(h=t_brace, center=false)
            cross_section(part="brace", dx_epsilon_brace=-0.0001);
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
            cross_section(part="brace", dx_epsilon_brace=-0.0001);

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

    color(c="goldenrod")
      plate_hinge(length=z_hinge, offset=offset_hinge_knuckle);
  }
}

module fitting_lower() {
  d_thread = 4.00;
  d_pin = 4.15;

  h = t_plate;

  // dx_body = -h * 0.34;
  dx_body = -h * 0.12;
  // dy_body = h * 0.0;
  dy_body = h * 0.08;

  t = 8 - gap_hinge_knuckle;
  l = 23.5 + dx_body; // to centre of pin

  translate(v=[h_plate - d_plate_pin_horiz, t_plate / 2, 0]) {
    difference() {
      union() {
        color(c="lawngreen") hull() {
            cylinder(d=h, h=t, center=true);
            translate(v=[dx_body, dy_body, 0])
              cylinder(d=h, h=t, center=true);
          }

        color(c="darkgreen")
          translate(v=[dx_body, l / 2 + dy_body, 0])
            cube(size=[h, l, t], center=true);
      }

      color(c="red")
        cylinder(d=d_pin, h=t, center=true);

      #color(c="pink")
        translate(v=[dx_body, l / 2 + dy_body, 0])
          rotate(a=90, v=[1, 0, 0])
            cylinder(d=d_thread, h=l, center=true);
    }
  }
}

module fitting_upper() {
  d_bolt = 4.20;
  d_pin = 4.25;

  t = 12.5;
  h = (7 - 2.5) * 2;
  l = 12.5;

  h_bolt = h / 2;

  difference() {
    union() {
      color(c="darkkhaki")
        cylinder(d=h, h=t, center=true);

      color(c="yellow")
        translate(v=[-h / 2, l / 2, 0])
          cube(size=[h, l, t], center=true);
    }

    color(c="red")
      cylinder(d=d_pin, h=t, center=true);

    color(c="pink")
      translate(v=[-h_bolt, l - d_bolt, 0])
        rotate(a=90, v=[0, 1, 0])
          cylinder(d=d_pin, h=h, center=true);
  }
}

module plate() {
  plate_half();
  if (!halves)
    zflip() plate_half();
}

module slide() {
  d_pin_slide = 4;
  d_pin_tray = 3.7;
  l_pin = 70;

  d_thread = 4.1;
  d_thread_cutout = d_thread - 0.35;

  h_head = 2;
  d_head = 7.3;
  d_head_cutout = d_head - 0.2;

  h_nut = 4.9;
  ds_nut = 6.85;
  d_nut = ds_nut * 2 / sqrt(3);

  w_screw_captive = 10;
  l_screw_captive = 15;

  t_slide = 8.0;
  t_lower = 2.0;

  // gaps are removed from tray
  x_gap = 0.25;
  y_wall = 4.6;
  z_gap = 1;
  z_wall = 3.6;

  w_slide_outer = l_pin - 2;
  w_slide_inner = 30;

  // l_slide_outer = l_surf + l_arm * 2;
  l_slide_outer = 70;
  l_slide_inner = l_slide_outer - 2 * z_wall - 2 * z_gap;

  xs = t_slide;
  ys = w_slide_inner;
  dys = ys / 2;
  zs = l_slide_inner;
  dzs = z_wall + z_gap;

  xo = t_slide + t_lower;
  yo = w_slide_outer;
  zo = l_slide_outer;

  xi = xs + x_gap;
  yi = w_slide_outer - y_wall * 2;
  dyi = y_wall;
  zi = l_slide_outer - z_wall * 2 + z_gap * 2;
  dzi = (zo - zi) / 2;

  module slide_pins() {
    translate(v=[xs / 2, 0, 0]) {
      rotate(a=-90, v=[1, 0, 0])
        cylinder(d=d_pin_tray, h=yo - y_wall / 3, center=false);

      translate(v=[0, dys, 0])
        rotate(a=-90, v=[1, 0, 0])
          cylinder(d=d_pin_slide, h=w_slide_inner, center=false);
    }
  }

  difference() {
    union() {
      color(c="yellow") {
        difference() {
          translate(v=[0, dys, dzs])
            cube(size=[xs, ys, zs], center=false);

          // slide screw
          translate(v=[xs / 2, dys, zo / 2])
            rotate(a=-90, v=[1, 0, 0])
              cylinder(d=d_thread, h=ys, center=false);

          // nut
          translate(v=[xs / 2, dys + ys / 2 - h_nut / 2, zo / 2])
            rotate(a=-90, v=[1, 0, 0])
              cylinder(d=d_nut, h=h_nut, center=false, $fn=6);

          // nut cutout
          translate(v=[0, dys + ys / 2 - h_nut / 2, zo / 2 - ds_nut / 2])
            cube(size=[xs / 2, h_nut, ds_nut], center=false);
        }
      }

      color(c="orange") {
        difference() {
          union() {
            cube(size=[xo, yo, zo], center=false);
            translate(v=[0, -w_screw_captive, (zo - l_screw_captive) / 2])
              cube(size=[xo, w_screw_captive, l_screw_captive], center=false);
          }
          translate(v=[0, dyi, dzi])
            cube(size=[xi, yi, zi], center=false);

          // slide screw
          translate(v=[xs / 2, -w_screw_captive, zo / 2]) {

            // bolt shaft
            rotate(a=-90, v=[1, 0, 0])
              cylinder(d=d_thread, h=y_wall + w_screw_captive, center=false);

            // shaft cutout
            translate(v=[-d_thread, 0, -d_thread_cutout / 2])
              cube(size=[d_thread, y_wall + w_screw_captive, d_thread_cutout], center=false);

            // bolt head
            translate(v=[-d_head, w_screw_captive / 2, -d_head_cutout / 2])
              cube(size=[d_head_cutout, h_head, d_head_cutout], center=false);

            // head cutout
            translate(v=[0, w_screw_captive / 2, 0])
              rotate(a=-90, v=[1, 0, 0])
                cylinder(d=d_head, h=h_head, center=false);
          }
        }
      }
    }

    translate(v=[0, 0, dzs + d_pin_tray])
      slide_pins();
    translate(v=[0, 0, l_slide_outer - (dzs + d_pin_tray)])
      slide_pins();
  }
}

module assemble() {
  a = min(max(a_display, -a_range), a_range) + a_range;

  if (show_plate) plate();
  translate(v=[-explode, 0, 0]) rotate(a=a) if (show_surf) surf();
  translate(v=[0, explode, 0]) rotate(a=a) if (show_arms) arms();
  translate(v=[0, -explode, 0]) if (show_fitting_upper) fitting_upper();
  translate(v=[0, -explode, 0]) if (show_fitting_lower) fitting_lower();
  if (show_slide) slide();
}

render() assemble();
