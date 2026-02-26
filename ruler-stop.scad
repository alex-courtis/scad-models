/* [Dimensions] */
x_ruler = 30; // [1:0.01:30]
z_ruler = 0.75; // [0.1:0.01:3]

dx_body = 3; // [1:0.01:30]
y_body = 25; // [1:0.01:30]
dz_body = 3; // [1:0.01:30]

y_stop = 5; // [0:0.1:10]
z_stop = 5; // [0:0.1:10]

/* [Tolerance] */

g_x = 0.02; // [0:0.01:1]
g_z = 0.02; // [0:0.01:1]

r_fillet = 0.05; // [0:0.01:1]

$fn = 200; // [0:1:500]

ruler = [x_ruler, y_body, z_ruler];
echo(ruler=ruler);

slot = ruler + [2 * g_x, 0, 2 * g_z];
echo(slot=slot);

body = ruler + [dx_body, 0, dz_body];
echo(body=body);

stop = [body[0], y_stop, z_stop];
echo(stop=stop);

module fillet(x_dir, y_dir) {
  #translate(v=[x_dir * slot[0] / 2, 0, y_dir * slot[2] / 2])
    rotate(a=90, v=[1, 0, 0])
      cylinder(r=r_fillet, h=y_body, center=true);
}

render() {
  difference() {
    color(c="steelblue")
      cube(body, center=true);

    color(c="orange")
      cube(slot, center=true);

    fillet(1, 1);
    fillet(1, -1);
    fillet(-1, -1);
    fillet(-1, 1);
  }

  dy_stop = body[1] / 2 - stop[1] / 2;
  dz_stop = body[2] / 2 + stop[2] / 2;

  translate(v=[0, dy_stop, dz_stop])
    color(c="gray")
      cube(stop, center=true);
}
