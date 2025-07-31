/* [Fixed] */

// parallel to board
magnet_h = 23.8 * 1;

// parallel to board
magnet_d = 12.8 * 1;

/* [Fitting] */

lip_h = 1.6; // [0:0.01:5]
lip_d = 1.6; // [0:0.01:5]

clip_thickness = 2.0; // [0:0.01:10]

/* [Size] */

// over/under the magnet
cutout_thickness = -0.8; // [-2:0.01:2]

// out from magnet
cutout_depth = 8; // [0:0.1:20]

/* [Cutouts] */

// left and right multiple of each cutout width
cutout_spacing = 1.2; // [0.1:0.05:5]

// left of cutouts
cutout_padding_l = 4; // [0:0.05:20]

// right of cutouts
cutout_padding_r = 4; // [0:0.05:20]

// width from left to right
cutout_widths_1 = [3, 8, 2, 4]; // [0:0.1:20]
cutout_widths_2 = [0, 0, 0, 0]; // [0:0.1:20]
cutout_widths_3 = [0, 0, 0, 0]; // [0:0.1:20]
cutout_widths_4 = [0, 0, 0, 0]; // [0:0.1:20]
cutout_widths_5 = [0, 0, 0, 0]; // [0:0.1:20]

// convenience multiplier to apply to actual measurements
cutout_multiplier = 1.0; // [1:0.01:5]

// customiser can't go higher than vector length 4
cutout_widths = (concat(cutout_widths_1, cutout_widths_2, cutout_widths_3, cutout_widths_4, cutout_widths_5)) * cutout_multiplier;

echo(cutout_widths=cutout_widths);

function calc_length(i = 0) =
  i < len(cutout_widths) && cutout_widths[i] > 0 ?
    cutout_widths[i] * (1 + cutout_spacing * 2) + calc_length(i + 1)
  : cutout_padding_l + cutout_padding_r;

length = calc_length();

module body() {

  translate(v=[length, 0, 0])
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

  // add a small amount for nicer scad and orcaslicer rendering; rounding error?
  h = magnet_h + clip_thickness * 2 + 1;

  translate(v=[x + s, h, magnet_d + cutout_thickness])
    rotate(a=90, v=[1, 0, 0])
      linear_extrude(height=h)
        square([cutout_widths[i], cutout_depth - cutout_thickness]);

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
