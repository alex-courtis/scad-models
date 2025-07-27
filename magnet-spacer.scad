/* [Fixed] */

// height of the holder
magnet_h = 25;

// depth to the board
magnet_d = 13.5;

/* [Fitting] */

lip_h = 1.6; // [0:0.1:2]
lip_d = 1.6; // [0:0.1:2]

clip_thickness = 1.6; // [0:0.1:2]

/* [Size] */

// over the magnet
cutout_thickness = 0.8; // [0:0.1:2]

// out from magnet including cutout thickness
cutout_depth = 5; // [0:1:20]

/* [Cutouts] */

// left and right multiple of each cutout width
cutout_spacing = 1; // [0.1:0.1:5]

// before cutouts
cutout_padding_l = 4; // [0:0.1:20]

// before cutouts
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

module clips() {
  difference() {

    // outer shell
    color(c="blue")
      linear_extrude(height=magnet_d)
        square(
          size=[
            length,
            magnet_h + 2 * clip_thickness,
          ], center=false
        );

    // inner channel
    color(c="green")
      translate(
        v=[
          0,
          clip_thickness,
          0,
        ]
      )
        linear_extrude(height=magnet_d - lip_d)
          square(
            size=[
              length,
              magnet_h,
            ], center=false
          );

    // lip
    color(c="yellow")
      translate(
        v=[
          0,
          clip_thickness + lip_h,
          magnet_d - lip_d,
        ]
      )
        linear_extrude(height=lip_d)
          square(
            size=[
              length,
              magnet_h - lip_h * 2,
            ], center=false
          );
  }
}

module body() {

  color(c="orange")
    linear_extrude(height=cutout_depth)
      square(
        size=[
          length,
          magnet_h + 2 * clip_thickness,
        ], center=false
      );
}

module cutouts(i = 0, x = cutout_padding_l) {
  w = cutout_widths[i];
  s = w * cutout_spacing;
  echo(i=i, w=w, x=x, s=s);

  translate(v=[x + s, 0, 0])
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
    union() {
      translate(v=[0, 0, cutout_depth])
        clips();

      body();
    }

    cutouts();
  }
}
