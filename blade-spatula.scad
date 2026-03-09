include <lib/geom.scad>
include <BOSL2/std.scad>

show_blade = false;
show_holder = true;
show_cover = true;
half_y = true;
half_z = false;

x_blade = 38.4; // [0:0.01:100]
y_blade = 17.7; // [0:0.01:100]
z_blade_thick = 1.25; // [0:0.01:5]
z_blade_thin = 0.98; // [0:0.01:5]

x_handle = 20; // [0:0.01:200]
y_handle = 100; // [0:0.01:200]

dx_cover = 3; // [0:0.01:10]
y_cover_end = 3; // [0:0.01:10]
dy_cover = -1; // [-10:0.01:10]
g_x_cover = 1; // [0:0.01:10]
g_y_cover = 0.5; // [0:0.01:10]
z_blade_cover = 1.30; // [0:0.01:5]

y_blade_channel = 6.25; // [0:0.01:25]

x_cutout_mid = 2.1; // [0:0.01:100]
y_cutout_mid = 5.4; // [0:0.01:100]
dy_cutout_mid = 0; // [-10:0.001:10]

x_cutout_end = 4.5; // [0:0.01:25]
y_cutout_end = 3.1; // [0:0.01:25]

g_y_channel = 0.075; // [0:0.001:2]
g_y_edge = 0.45; // [0:0.001:2]
g_z_thin = 0.01; // [0:0.001:2]
g_z_thick = 0.05; // [0:0.001:2]
g_cutout = 0.125; // [0:0.001:2]

t_nub = 0.40; // [0:0.001:2]
nub_mid = false;
nub_end = true;
nub_joined = true;

d_pin = 2.08; // [0:0.001:5]
l_pin_handle = 14; // [0:0.001:50]
l_pin_body = 27; // [0:0.001:50]

t_y = 4.6; // [0:0.01:5]
t_half_front = 0.45; // [0:0.01:10]
t_back = 4.8; // [0:0.01:10]
t_handle = 4.64; // [0:0.01:10]

ratio_rounding = 1; // [0:0.01:1]

$fn = 200;

body_holder = [
  x_blade,
  y_blade + t_y + g_y_edge - g_y_channel - (y_blade - y_blade_channel) / 2,
  z_blade_thick + 2 * (g_z_thick + t_half_front),
];
rounding_body = ratio_rounding * body_holder[2] / 2;
v_holder = [0, body_holder[1] / 2 - y_blade_channel / 2 + g_y_channel, 0];

module blade(cutouts, mask) {
  body = [
    x_blade,
    y_blade + (mask ? 2 * g_y_edge : 0),
    z_blade_thick + (mask ? 2 * g_z_thick : 0),
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

  difference() {
    cube(body, center=true);

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
        }

        // cut off nubs
        if (mask && !nub_joined)
          cube(nub_mask, center=true);
      }
    }
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

module holder() {

  handle = [x_handle, y_handle + rounding_body, t_handle];

  rounding_handle = t_handle * ratio_rounding / 2;

  difference() {
    union() {

      translate(v=v_holder) {

        color(c="green")
          translate(
            v=[
              0,
              handle[1] / 2 + body_holder[1] / 2 - rounding_body,
              0,
            ]
          )
            cuboid(
              handle,
              rounding=rounding_handle,
              except=[
                FRONT,
              ]
            );

        color(c="slateblue")
          body_holder_prismoid();
      }
    }

    color(c="red") {
      translate(v=v_holder + [0, body_holder[1] / 2 - t_y / 2, 0]) {
        rotate(a=90, v=[0, 1, 0])
          cylinder(d=d_pin, h=l_pin_body, center=true);

        translate(v=[0, y_handle - 2 * d_pin, 0])
          rotate(a=90, v=[0, 1, 0])
            cylinder(d=d_pin, h=l_pin_handle, center=true);

        translate(v=[0, y_handle / 2, 0])
          rotate(a=90, v=[0, 1, 0])
            cylinder(d=d_pin, h=l_pin_handle, center=true);
      }
    }

    color(c="pink")
      blade(cutouts=true, mask=true);
  }
}

module cover() {
  body = [
    x_blade + (dx_cover + g_x_cover) * 2,
    y_blade + y_cover_end - g_y_cover,
    t_handle,
  ];

  difference() {
    color(c="slategray")
      translate(v=[0, -body[1] / 2 + y_blade / 2 + dy_cover, 0])
        cuboid(
          body,
          rounding=rounding_body,
          except=[BACK],
        );

    color(c="salmon")
      translate(v=[0, 0, 0])
        cube(
          [
            x_blade + g_x_cover * 2,
            y_blade + g_y_cover * 2,
            z_blade_cover,
          ], center=true
        );

    color(c="red") {
      translate(v=v_holder + [g_x_cover, -g_y_cover, 0])
        body_holder_prismoid();
      translate(v=v_holder + [-g_x_cover, -g_y_cover, 0])
        body_holder_prismoid();
    }
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
