include <lib/geom.scad>
include <BOSL2/std.scad>

show_blade = false;
show_holder = false;
show_cover = true;
half_y = false;
half_z = false;
split_holder = false;

/* [Blade Dimensions] */
x_blade = 38.4; // [0:0.01:100]
a_blade = 90; // [0:0.01:90]
y_blade = 17.7; // [0:0.01:100]
z_blade_thick = 1.25; // [0:0.01:5]
z_blade_thin = 0.98; // [0:0.01:5]
y_blade_channel = 6.25; // [0:0.01:25]

/* [Blade Gaps] */
g_x_edge = 0; // [0:0.001:2]
g_y_channel = 0.075; // [0:0.001:2]
g_y_edge = 0.45; // [0:0.001:2]
g_z_thin = 0.01; // [0:0.001:2]
g_z_thick = 0.05; // [0:0.001:2]
g_cutout = 0.125; // [0:0.001:2]

/* [Blade Holes] */
x_cutout_mid = 2.1; // [0:0.01:100]
y_cutout_mid = 5.4; // [0:0.01:100]
dy_cutout_mid = 0; // [-10:0.001:10]

x_cutout_end = 4.5; // [0:0.01:25]
y_cutout_end = 3.1; // [0:0.01:25]

x_cutout_back = 0; // [0:0.01:25]
dx_cutout_back = [0, 0]; // [-25:0.01:25]
y_cutout_back = 0; // [0:0.01:25]

dx_cutout_hole1 = 0; // [-20:0.001:20]
dy_cutout_hole1 = 0; // [-10:0.001:20]
d_cutout_hole1 = 0; // [0:0.001:10]
d_cutout_drill_hole1 = 0; // [0:0.001:10]

dx_cutout_hole2 = 0; // [-10:0.001:20]
dy_cutout_hole2 = 0; // [-10:0.001:20]
d_cutout_hole2 = 0; // [0:0.001:10]
d_cutout_drill_hole2 = 0; // [0:0.001:10]

/* [Holder Dimensions] */
t_y = 4.6; // [0:0.01:50]
t_half_front = 0.45; // [0:0.01:10]
t_back = 4.8; // [0:0.01:10]
t_handle = 4.64; // [0:0.01:10]
ratio_rounding_body = 1; // [0:0.01:1]

/* [Nubs] */
t_nub = 0.40; // [0:0.001:2]
nub_mid = false;
nub_end = true;
nub_back = false;
nub_joined = true;
drill_holes = false;

/* [Handle] */
x_handle = 20; // [0:0.01:200]
y_handle = 100; // [0:0.01:200]

/* [Cover Dimensions] */
dx_cover = 2.5; // [0:0.01:10]
dy_cover = 5; // [0:0.01:10]
t_cover = 7.2; // [0:0.01:10]
z_blade_cover = 1.90; // [0:0.01:5]
ratio_rounding_cover = 0.5; // [0:0.01:1]

/* [Cover Gaps] */
g_x_cover = 0.5; // [0:0.01:10]
g_y_cover = 3; // [0:0.01:10]

/* [Cover Clip] */
y_cover_clip = 2; // [0:0.001:10]
dy_clip = 5.6; // [0:0.001:50]
dz_cover_clip = 0.8; // [0:0.001:10]

/* [Cover Split] */
y_cover_split = 12.0; // [0:0.001:100]
z_cover_split = 0.45; // [0:0.001:10]

/* [Pins] */
drill_pins = false;
d_pin = 2.08; // [0:0.001:5]
l_pin_handle = 14; // [0:0.001:100]
l_pin_body = 27; // [0:0.001:100]

$fn = 200;

body_holder = [
  x_blade,
  y_blade + t_y + g_y_edge - g_y_channel - (y_blade - y_blade_channel) / 2,
  z_blade_thick + 2 * (g_z_thick + t_half_front),
];
rounding_body = ratio_rounding_body * body_holder[2] / 2;
rounding_cover = ratio_rounding_cover * t_cover / 2;
v_holder = [0, body_holder[1] / 2 - y_blade_channel / 2 + g_y_channel, 0];

module blade(cutouts, mask) {
  dx_blade = (mask ? g_x_edge - g_y_edge / tan(a_blade) : 0);
  dy_blade = (mask ? g_y_edge : 0);

  x_front = x_blade + dx_blade * 2;
  x_back = x_blade - 2 * y_blade / tan(a_blade) + dx_blade * 2;

  poly_blade = [
    [-x_front / 2, -y_blade / 2 + dy_blade],
    [-x_back / 2, y_blade / 2 + dy_blade],
    [x_back / 2, y_blade / 2 + dy_blade],
    [x_front / 2, -y_blade / 2 + dy_blade],
  ];

  channel = [
    x_blade,
    y_blade_channel - (mask ? 2 * g_y_channel : 0),
    z_blade_thick - (mask ? 2 * g_z_thin : 0), // use entire thickness to avoid non-manifold
  ];

  nub_mask = [
    x_blade,
    y_blade,
    z_blade_thin + g_z_thin * 2 - t_nub * 2,
  ];

  module cutout_end_mask(dir) {
    rect = [
      x_cutout_end - y_cutout_end / 2,
      y_cutout_end - (mask ? 2 * g_cutout : 0),
      z_blade_thick,
    ];

    translate(v=[(x_blade - rect[0]) / 2 * dir, 0, 0])
      cube(rect, center=true);

    translate(v=[(x_blade / 2 - rect[0]) * dir, 0, 0])
      cylinder(d=rect[1], h=rect[2], center=true);
  }

  module cutout_mid_mask() {
    rect = [
      x_cutout_mid - (mask ? 2 * g_cutout : 0),
      y_cutout_mid - x_cutout_mid,
      z_blade_thick,
    ];

    translate(v=[0, dy_cutout_mid, 0]) {
      cube(rect, center=true);

      translate(v=[0, rect[1] / 2, 0])
        cylinder(d=rect[0], h=rect[2], center=true);

      translate(v=[0, -rect[1] / 2, 0])
        cylinder(d=rect[0], h=rect[2], center=true);
    }
  }

  module cutout_hole1_mask() {
    if (d_cutout_hole1) {
      translate(v=[dx_cutout_hole1, dy_cutout_hole1, 0])
        cylinder(d=mask ? d_cutout_drill_hole1 : d_cutout_hole1, h=t_back, center=true);
    }
  }

  module cutout_hole2_mask() {
    if (d_cutout_hole2) {
      translate(v=[dx_cutout_hole2, dy_cutout_hole2, 0])
        cylinder(d=mask ? d_cutout_drill_hole2 : d_cutout_hole2, h=t_back, center=true);
    }
  }

  module cutout_back_mask(n) {
    if (x_cutout_back) {
      rect = [
        x_cutout_back - (mask ? 2 * g_cutout : 0),
        y_cutout_back - x_cutout_back / 2 + g_y_edge,
        z_blade_thick,
      ];

      translate(v=[dx_cutout_back[n], y_blade / 2 + g_y_edge, 0]) {
        translate(v=[0, -rect[1] / 2, 0])
          cube(rect, center=true);

        translate(v=[0, -rect[1], 0])
          cylinder(d=rect[0], h=rect[2], center=true);
      }
    }
  }

  difference() {
    linear_extrude(h=z_blade_thick + (mask ? 2 * g_z_thick : 0), center=true)
      polygon(poly_blade);

    translate(v=[0, 0, (z_blade_thick + z_blade_thin) / 2])
      cube(channel, center=true);

    translate(v=[0, 0, -(z_blade_thick + z_blade_thin) / 2])
      cube(channel, center=true);

    if (cutouts) {
      difference() {
        union() {
          if (!mask || nub_end) {
            cutout_end_mask(dir=1);
            cutout_end_mask(dir=-1);
          }

          if (!mask || nub_mid) {
            cutout_mid_mask();
          }

          if (!mask) {
            cutout_hole1_mask();
            cutout_hole2_mask();
          }

          if (!mask || nub_back) {
            cutout_back_mask(0);
            cutout_back_mask(1);
          }
        }

        // cut off nubs
        if (mask && !nub_joined)
          cube(nub_mask, center=true);
      }
    }
  }

  if (mask && drill_holes) {
    cutout_hole1_mask();
    cutout_hole2_mask();
  }
}

module body_holder_prismoid() {
  rotate(a=90, v=[-1, 0, 0])
    diff()
      prismoid(
        [body_holder[0], body_holder[2]],
        [body_holder[0], t_back],
        h=body_holder[1],
        anchor=CENTER,
      ) {
        if (rounding_body > 0) {
          edge_profile(
            [
              TOP + FRONT,
              TOP + BACK,
              BOT + FRONT,
              BOT + BACK,
            ], excess=10, convexity=20
          ) {
            mask2d_roundover(h=rounding_body, mask_angle=$edge_angle);
          }
        }
      }
}

module holder(blade_cutout = true, pins = true) {

  handle = [x_handle, y_handle + rounding_body - x_handle / 2, t_handle];

  rounding_handle = t_handle * ratio_rounding_body / 2;

  module pin_chamfer() {
    translate(v=[-d_pin / 4, 0, 0])
      rotate(a=90, v=[0, 1, 0])
        cylinder(d1=d_pin, d2=d_pin * 5 / 4, h=d_pin / 2, center=true);
  }

  difference() {
    union() {

      translate(v=v_holder) {

        translate(
          v=[
            0,
            handle[1] / 2 + body_holder[1] / 2 - rounding_body,
            0,
          ]
        ) {

          color(c="lightgreen")
            translate(v=[0, handle[1] / 2, 0])
              cyl(h=handle[2], d=x_handle, center=true, rounding=rounding_handle);

          color(c="green")
            cuboid(
              handle,
              rounding=rounding_handle,
              except=[
                FRONT,
                BACK,
              ]
            );
        }

        color(c="slateblue")
          body_holder_prismoid();
      }
    }

    if (pins && drill_pins) {
      color(c="orange") {
        translate(v=v_holder + [0, body_holder[1] / 2 - t_y / 2, 0]) {
          // body
          rotate(a=90, v=[0, 1, 0])
            cylinder(d=d_pin, h=l_pin_body, center=true);

          pin_chamfer();
          mirror(v=[1, 0, 0])
            pin_chamfer();

          // end
          translate(v=[0, y_handle - 2 * d_pin, 0]) {
            rotate(a=90, v=[0, 1, 0])
              cylinder(d=d_pin, h=l_pin_handle, center=true);

            pin_chamfer();
            mirror(v=[1, 0, 0])
              pin_chamfer();
          }

          // mid
          translate(v=[0, y_handle / 2, 0]) {
            rotate(a=90, v=[0, 1, 0])
              cylinder(d=d_pin, h=l_pin_handle, center=true);

            pin_chamfer();
            mirror(v=[1, 0, 0])
              pin_chamfer();
          }
        }
      }
    }

    if (blade_cutout)
      color(c="pink")
        blade(cutouts=true, mask=true);
  }
}

module cover() {
  body = [
    x_blade + dx_cover * 2,
    y_blade + dy_cover + dy_clip,
    t_cover,
  ];

  difference() {
    color(c="slategray")
      translate(v=[0, -dy_cover / 2 + dy_clip / 2, 0])
        cuboid(
          body,
          rounding=rounding_cover,
          except=[BACK],
        );

    color(c="salmon")
      cube(
        [
          x_blade + g_x_cover * 2,
          y_blade + g_y_cover * 2,
          z_blade_cover,
        ], center=true
      );

    color(c="red") {
      translate(v=[g_x_cover, 0, 0])
        holder(blade_cutout=false, pins=false);
      translate(v=[-g_x_cover, 0, 0])
        holder(blade_cutout=false, pins=false);
    }

    color(c="saddlebrown")
      translate(v=[0, body[1] / 2 - dy_cover / 2 + dy_clip / 2 - y_cover_clip / 2, 0])
        cube(
          [
            body[0] - 2 * dx_cover + g_x_cover * 2,
            y_cover_clip,
            t_back - dz_cover_clip,
          ], center=true
        );

    color(c="chocolate")
      translate(v=[0, body[1] / 2 - dy_cover / 2 + dy_clip / 2 - y_cover_split / 2, 0])
        cube(
          [
            body[0],
            y_cover_split,
            z_cover_split,
          ], center=true
        );

    color(c="indigo")
      translate(v=[0, body[1] / 2 - dy_cover / 2 + dy_clip / 2 - y_cover_split, 0])
        rotate(a=90, v=[0, 1, 0])
          cylinder(d=z_cover_split * 3, h=body[0], center=true);
  }
}

render() {
  if (show_blade)
    color(c="orange")
      blade(cutouts=true, mask=false);

  if (show_holder)
    if (half_z)
      bottom_half(z=0, s=300)
        holder();
    else if (half_y)
      left_half(x=0, s=300)
        holder();
    else if (split_holder) {
      translate(v=[-10, 0, 0])
        left_half(x=0, s=300)
          holder();
      translate(v=[10, 0, 0])
        right_half(x=0, s=300)
          holder();
    }
    else
      holder();

  if (show_cover)
    if (half_z)
      bottom_half(z=0, s=300)
        cover();
    else if (half_y)
      left_half(x=0, s=300)
        cover();
    else
      cover();
}
