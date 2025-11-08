x_base = 19; // [10:0.5:100]
z_base = 13; // [10:0.5:100]

// ratio, overhangs end
x_clip = 0; // [-0.5:0.01:0.5]

// inside of clip
r_inner = 3.5; // [1:0.1:50]

cutout_outer = 40; // [0:1:90]
cutout_inner = 45; // [0:1:90]

t_base = 1.6; // [0.4:0.1:10]
t_clip = 1.6; // [0.4:0.1:10]

h_overhang_back = 0; // [0.0:0.1:10]
h_overhang_front = 0; // [0.0:0.1:10]
t_overhang = 1.2; // [0.4:0.1:10]

$fn = 200; // [0:5:1000]

r = r_inner + t_clip;

render() {
  linear_extrude(height=z_base) {
    // base
    square([x_base, t_base]);

    // back overhang, optional
    if (h_overhang_back > 0) {
      translate(v=[-t_overhang, -h_overhang_back]) {
        square([t_overhang, h_overhang_back + t_base]);
      }
    }

    // front overhang, optional
    if (h_overhang_front > 0) {
      translate(v=[x_base, -h_overhang_front]) {
        square([t_overhang, h_overhang_front + t_base]);
      }
    }

    // clip
    translate(
      v=[
        x_base / 2 + x_base * x_clip,
        r + (t_base > t_clip ? t_base - t_clip : 0),
        0,
      ]
    ) {
      difference() {
        circle(r=r);
        circle(r=r - t_clip);

        // double radius arc triangle up
        xo = 2 * r * cos(cutout_outer);
        yo = 2 * r * sin(cutout_outer);
        polygon(
          [
            [0, 0],
            [xo, yo],
            [2 * r, 0],
            [0, 0],
          ]
        );

        // double radius arc triangle down
        xi = 2 * r * cos(cutout_inner);
        yi = -2 * r * sin(cutout_inner);
        polygon(
          [
            [0, 0],
            [xi, yi],
            [2 * r, 0],
            [0, 0],
          ]
        );
      }
    }
  }
}
