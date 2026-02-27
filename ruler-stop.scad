/* [Dimensions] */
w_ruler = 15; // [1:0.01:60]
t_ruler = 0.5; // [0.1:0.01:3]

dx_body = 4.0; // [1:0.01:30]

// bottom side only
dy_body = 1.6; // [1:0.01:30]

z_body = 25; // [1:0.01:30]

y_stop = 8; // [0:0.1:10]
z_stop = 6; // [0:0.1:10]

/* [Screw] */

// default M3
w_nut = 5.5; // [1:0.1:10]

// nut hole width multiplier
w_nut_multiplier = 0.96; // [0.1:0.001:2]

nut_inset_diameter = w_nut * w_nut_multiplier * 2 / sqrt(3);
echo(nut_inset_diameter=nut_inset_diameter);

// nut depth, default 2.5mm M3
t_nut = 2.75; // [0:0.01:20]

t_flange = 1.2; // [0.2:0.2:20]

d_bolt = 2.9; // [1:0.05:10]

/* [Tolerance] */

g_x = 0.12; // [0:0.01:5]
g_y = 0.16; // [0:0.01:1]

r_fillet_slot = 0.16; // [0:0.01:1]
r_fillet_stop = 0.15; // [0:0.01:1]

d_filament = 0.4; // [0.2:0.2:0.8]
t_layer = 0.2; // [0.05:0.01:2]

$fn = 200; // [0:1:500]

ruler = [
  w_ruler,
  t_ruler,
  round_num(z_body, t_layer),
];
echo(ruler=ruler);

slot = ruler + [
  2 * g_x,
  2 * g_y,
  0,
];
echo(slot=slot);

body = slot + [
  dx_body * 2,
  dy_body * 2,
  0,
];
echo(body=body);

top = [body[0], round_num(t_flange + t_nut/2, d_filament), body[2]];
echo(top=top);

// round stop z to account for gaps
stop = [
  body[0],
  round_num(y_stop, t_layer),
  round_num(z_stop + body[2], d_filament) - body[2],
];
echo(stop=stop);

function round_num(n, dn) =
  round(n / dn) * dn;

function round_vec(v, dv) =
  [
    for (i = [0:1:len(v) - 1]) round(v[i] / dv[i]) * dv[i],
  ];

module fillet_stop() {
  #translate(v=[0, body[1] / 2, +stop[2] - body[2] / 2])
    rotate(a=90, v=[0, 1, 0])
      cylinder(r=r_fillet_stop, h=stop[0], center=true);
}

module fillet_ruler(x_dir, y_dir) {
  #translate(v=[x_dir * slot[0] / 2, y_dir * slot[1] / 2, 0])
    cylinder(r=r_fillet_slot, h=z_body, center=true);
}

module body() {
  difference() {
    union() {
      color(c="steelblue")
        cube(body, center=true);

      translate(v=[0, -body[1] / 2 - top[1] / 2, 0])
        color(c="lightblue")
          cube(top, center=true);
    }

    color(c="orange")
      cube(slot, center=true);
  }

  dy_stop = stop[1] / 2 + body[1] / 2;
  dz_stop = stop[2] / 2 - body[2] / 2;

  translate(v=[0, dy_stop, dz_stop])
    color(c="gray")
      cube(stop, center=true);
}

module nut() {

  h = body[1] + top[1] * 2;

  color(c="green")
    translate(v=[0, t_flange, 0])
      rotate(a=90, v=[1, 0, 0])
        rotate(a=90, v=[0, 0, 1])
          cylinder(d=nut_inset_diameter, h=h, $fn=6, center=true);
}

module bolt() {
  color(c="red")
    rotate(a=90, v=[1, 0, 0])
      cylinder(d=d_bolt, h=100, center=true);
}

render() {
  difference() {
    body();

    fillet_ruler(1, 1);
    fillet_ruler(1, -1);
    fillet_ruler(-1, -1);
    fillet_ruler(-1, 1);

    fillet_stop();

    nut();

    bolt();
  }
}
