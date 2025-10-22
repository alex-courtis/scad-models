x_base = 19; // [10:1:100]
z_base = 12.5; // [10:1:100]

// ratio, overhangs end
x_clip = 0.4; // [0:0.01:1]

// inside of clip
d = 4.0; // [5:1:50]

cutout_outer = 45; // [0:1:90]
cutout_inner = 60; // [0:1:90]

t_base = 1.6; // [0.4:0.1:10]
t_clip = 1.6; // [0.4:0.1:10]

$fn = 200; // [0:5:1000]

r = d + t_clip;

render() {
  linear_extrude(height=z_base) {
    // base
    square([x_base, t_base]);

    // clip
    translate(
      v=[
        x_base * x_clip,
        r + (t_base > t_clip ? t_base - t_clip : 0),
        0,
      ]
    ) {
      difference() {
        circle(r=r);
        circle(r=r - t_clip);

        // arc triangle + square up
        xo = r * cos(cutout_outer);
        yo = r * sin(cutout_outer);
        polygon(
          [
            [0, 0],
            [xo, yo],
            [r, yo],
            [r, 0],
            [0, 0],
          ]
        );

        // arc triangle + square down
        xi = r * cos(cutout_inner);
        yi = -r * sin(cutout_inner);
        polygon(
          [
            [0, 0],
            [xi, yi],
            [r, yi],
            [r, 0],
            [0, 0],
          ]
        );
      }
    }
  }
}
