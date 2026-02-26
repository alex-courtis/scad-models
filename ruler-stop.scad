/* [Dimensions] */
x_ruler = 30; // [1:0.01:30]
z_ruler = 0.75; // [0.1:0.01:3]

dx_body = 1.6; // [1:0.01:30]
y_body = 25; // [1:0.01:30]
dz_body = 1.6; // [1:0.01:30]

y_stop = 6; // [0:0.1:10]
z_stop = 8; // [0:0.1:10]

/* [Tolerance] */

g_x = 0.02; // [0:0.01:1]
g_z = 0.02; // [0:0.01:1]

r_fillet_slot = 0.05; // [0:0.01:1]
r_fillet_stop = 0.15; // [0:0.01:1]

d_filament = 0.4; // [0.2:0.2:0.8]
t_layer = 0.2; // [0.05:0.01:2]

$fn = 200; // [0:1:500]

ruler = [
  x_ruler,
  round_num(y_body, t_layer),
  z_ruler,
];
echo(ruler=ruler);

slot = ruler + [
  2 * g_x,
  0,
  2 * g_z,
];
echo(slot=slot);

body = slot + [
  dx_body * 2,
  0,
  dz_body * 2,
];
echo(body=body);

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
  #translate(v=[0, body[1] / 2 - stop[1], body[2] / 2])
    rotate(a=90, v=[0, 1, 0])
      cylinder(r=r_fillet_stop, h=stop[0], center=true);
}

module fillet_ruler(x_dir, y_dir) {
  #translate(v=[x_dir * slot[0] / 2, 0, y_dir * slot[2] / 2])
    rotate(a=90, v=[1, 0, 0])
      cylinder(r=r_fillet_slot, h=y_body, center=true);
}

module body() {
  difference() {
    color(c="steelblue")
      cube(body, center=true);

    color(c="orange")
      cube(slot, center=true);
  }

  dy_stop = body[1] / 2 - stop[1] / 2;
  dz_stop = body[2] / 2 + stop[2] / 2;

  translate(v=[0, dy_stop, dz_stop])
    color(c="gray")
      cube(stop, center=true);
}

render() {
  difference() {
    body();

    fillet_ruler(1, 1);
    fillet_ruler(1, -1);
    fillet_ruler(-1, -1);
    fillet_ruler(-1, 1);

    fillet_stop();
  }
}
