/* [Fixed] */

// parallel to board
magnet_h = 23.5 * 1;

// parallel to board
magnet_d = 13.0 * 1;

/* [Fitting] */

lip_h = 1.6; // [0:0.1:5]
lip_d = 1.6; // [0:0.1:5]

clip_thickness = 4.0; // [0:0.1:5]

/* [Size] */

// over the magnet
cutout_thickness = 0.8; // [0:0.1:2]

// out from magnet including cutout thickness
cutout_depth = 5; // [0:1:20]

/* [Cutouts] */

// left and right multiple of each cutout width
cutout_spacing = 1; // [0.1:0.1:5]

// left of cutouts
cutout_padding_l = 4; // [0:0.1:20]

// right of cutouts
cutout_padding_r = 4; // [0:0.1:20]

// width from left to right
cutout_widths_1 = [3, 8, 2, 4]; // [0:0.1:20]
cutout_widths_2 = [0, 0, 0, 0]; // [0:0.1:20]
cutout_widths_3 = [0, 0, 0, 0]; // [0:0.1:20]
cutout_widths_4 = [0, 0, 0, 0]; // [0:0.1:20]

// customiser can't go higher than vector length 4
cutout_widths = concat(cutout_widths_1, cutout_widths_2, cutout_widths_3, cutout_widths_4);

function calc_length(i = 0) =
  i < len(cutout_widths) && cutout_widths[i] > 0 ?
    cutout_widths[i] * (1 + cutout_spacing * 2) + calc_length(i + 1)
  : cutout_padding_l + cutout_padding_r;

length = calc_length();

module body() {

  translate(v=[length, 0, -magnet_d])
    rotate(a=270, v=[0, 1, 0])
      linear_extrude(height=length) {
        difference() {

          // outer shell
          square(
            [
              magnet_d + cutout_depth,
              magnet_h + clip_thickness * 2,
            ], center=false
          );

          // magnet channel
          translate(v=[0, clip_thickness])
            square(
              [
                magnet_d,
                magnet_h,
              ], center=false
            );
        }

        // bottom lip
        translate(v=[0, clip_thickness])
          polygon(
            [
              [0, 0],
              [0, lip_h],
              [lip_d, 0],
            ]
          );

        // top lip
        translate(v=[0, magnet_h + clip_thickness])
          polygon(
            [
              [0, 0],
              [0, -lip_h],
              [lip_d, 0],
            ]
          );
      }
}

module cutouts(i = 0, x = cutout_padding_l) {
  w = cutout_widths[i];
  s = w * cutout_spacing;
  echo(i=i, w=w, x=x, s=s);

  translate(v=[x + s, 0, cutout_thickness])
    cube(
      [
        cutout_widths[i],
        magnet_h + clip_thickness * 2,
        cutout_depth - cutout_thickness,
      ]
    );

  if (i + 1 < len(cutout_widths) && cutout_widths[i + 1] > 0) {
    cutouts(i + 1, x + w + s * 2);
  }
}

render() {
  difference() {
    color(c="green")
      body();

    color(c="red")
      cutouts();
  }
}
