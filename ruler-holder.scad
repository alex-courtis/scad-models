include <BOSL2/std.scad>
include <lib/geom.scad>

/* [Inner Dimensions] */
t = 4;

// capped by right isosceles triangles
w = 34;

l = 280;

/* [Magnet Dimensions] */

t_magnet = 3 + 0.2;
w_magnet = 15 + 0.2;
l_magnet = 25 + 0.2;

/* [Outer Dimensions] */

dt = t_magnet + 0.8 * 2;
dw = dt;
dl = 2;

l_cutout = 120;

$fn = 200; // [0:1:500]

module outer_cross() {
  square([t + 2 * dt, w + 2 * dw], center=true);
}

module inner_cross() {
  end = [
    [-t / 2, 0],
    [t / 2, 0],
    [0, t / 2],
  ];

  square([t, w - t], center=true);

  translate(v=[0, -w / 2 + t / 2])
    mirror(v=[0, 1])
      polygon(end);

  translate(v=[0, w / 2 - t / 2])
    polygon(end);
}

module holder_body() {
  difference() {
    color(c="steelblue")
      translate(v=[0, 0, dl / 2])
        linear_extrude(h=l + dl, center=true)
          outer_cross();

    color(c="orange")
      linear_extrude(h=l, center=true)
        inner_cross();
  }
}

module holder_cutout_mask() {
  translate(v=[0, w / 2 + dw, (l_cutout - l) / 2])
    linear_extrude(h=l_cutout, center=true)
      outer_cross();
}

module magnets_mask() {
  color(c="red")
    translate(v=[0, w / 2 + dw - w_magnet / 2, l / 2 - l_magnet])
      magnet_mask();

  color(c="pink")
    translate(v=[0, dt, -l / 2 + l_magnet])
      magnet_mask();
}

module magnet_mask() {
  translate(v=[(t + dt) / 2, 0])
    cube([t_magnet, w + dw * 2, l_magnet], center=true);
}

render() {
  // front_half(s=l * 2, y=-90)
  // back_half(s=l * 2, y=90)
  rotate(a=90, v=[1, 0, 0])
    difference() {
      holder_body();
      holder_cutout_mask();
      magnets_mask();
    }
}
