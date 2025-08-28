/* [Tray Parameters] */
// Tray Maker.  A text based way to create a custom tray/bin.
// an array of bin widths (ex: column widths).  This example will create first column 50mm wide, second 25mm, third 25mm.  If a 4th is desired enter [50,25,25,45].  Then 4th column will be 45mm wide.  Adding additional columns will require tray layout modifications to accommodate extra column.

// will be trimmed to match _tray_layout_01 length
_x_bin_widths_01 = [26.5, 26.5, 26.5, 26.5]; // [0:0.001:200]
_x_bin_widths_02 = [26.5, 26.5, 26.5, 26.5]; // [0:0.001:200]
_x_bin_widths_03 = [26.5, 26.5, 26.5, 26.5]; // [0:0.001:200]
_x_bin_widths_04 = [26.5, 26.5, 26.5, 26.5]; // [0:0.001:200]
_x_bin_widths_05 = [26.5, 26.5, 26.5, 26.5]; // [0:0.001:200]

// an integer for y bin length (ex: row height)
_y_bin_length = 26.5; // [0:0.01:200]
// depth of each bin
_z_depth = 12; // [0:0.01:200]
// thickness of walls separating bins.
_wall_width = 0.8; // [0:0.01:200]
// thickness of bottom of tray
_bottom_thickness = 1.2; // [0:0.01:200]

/* [Tray Layout] */
// tray layout, array of strings defining layout. More info in thing description about this parameter 
// number of tray rows (y) to use
_num_rows = 3; // [1:1:22]
// first defines the number of columns (x)
_tray_layout_01 = "|_|_|_|_|_|_|";
_tray_layout_02 = "|_|_|_|_|_|_|";
_tray_layout_03 = "|_|_|_|_|_|_|";
_tray_layout_04 = "|_|_|_|_|_|_|";
_tray_layout_05 = "|_|_|_|_|_|_|";
_tray_layout_06 = "|_|_|_|_|_|_|";
_tray_layout_07 = "|_|_|_|_|_|_|";
_tray_layout_08 = "|_|_|_|_|_|_|";
_tray_layout_09 = "|_|_|_|_|_|_|";
_tray_layout_10 = "|_|_|_|_|_|_|";
_tray_layout_11 = "|_|_|_|_|_|_|";
_tray_layout_12 = "|_|_|_|_|_|_|";
_tray_layout_13 = "|_|_|_|_|_|_|";
_tray_layout_14 = "|_|_|_|_|_|_|";
_tray_layout_15 = "|_|_|_|_|_|_|";
_tray_layout_16 = "|_|_|_|_|_|_|";
_tray_layout_17 = "|_|_|_|_|_|_|";
_tray_layout_18 = "|_|_|_|_|_|_|";
_tray_layout_19 = "|_|_|_|_|_|_|";
_tray_layout_20 = "|_|_|_|_|_|_|";
_tray_layout_21 = "|_|_|_|_|_|_|";
_tray_layout_22 = "|_|_|_|_|_|_|";

/* [Lid Parameters] */
// generate a lid (instead of the tray) that fits the defined tray
_generate_lid = false;
// thickness of lid top
_lid_thickness = 0.9; // [0:0.01:200]
// thickness of the lid's sides
_lid_wall_thickness = 1.5; // [0:0.01:200]
// the depth of the lid.  
_lid_depth = 15; // [0:0.01:200]
// with no fudge, the lid will be snug.  Depending on printer or preference provide negative to make tighter, positive to make looser. (ex: 0.2 will make a looser fitter lid)
_lid_fudge = 0.8; // [0:0.01:200]

/* [Hidden] */
// for use if using as library and able to view console output.
_grid_x = 3; // used to generate message for copy/paste.
_grid_y = 4; // used to generate message for copy/paste.

_x_bin_widths_all = concat(
  _x_bin_widths_01,
  _x_bin_widths_02,
  _x_bin_widths_03,
  _x_bin_widths_04,
  _x_bin_widths_05,
);
_x_bin_widths = [for (c = [0:1:len(_tray_layout_01) / 2 - 1]) _x_bin_widths_all[c]];
echo(_x_bin_widths=_x_bin_widths);

// all this fun stuff is because thingiverse customizer cannot accept an array of string values as input.  

_tray_layout_array =
concat(
  _tray_layout_01,
  _tray_layout_02,
  _tray_layout_03,
  _tray_layout_04,
  _tray_layout_05,
  _tray_layout_06,
  _tray_layout_07,
  _tray_layout_08,
  _tray_layout_09,
  _tray_layout_10,
  _tray_layout_11,
  _tray_layout_12,
  _tray_layout_13,
  _tray_layout_14,
  _tray_layout_15,
  _tray_layout_16,
  _tray_layout_17,
  _tray_layout_18,
  _tray_layout_19,
  _tray_layout_20,
  _tray_layout_21,
  _tray_layout_22
);
_tray_layout = [for (i = [0:_num_rows - 1]) _tray_layout_array[i]];
echo(_tray_layout=_tray_layout);
// end the special tray_layout handling for customizer.

// Tray layout explained: each row start with and end with | (a pipe)
// alternate placing | or _ or use space for none
// | represent separations on the row _ is the bottom edge of the cell.
// if grid is x cell = 3 and y cells = 2, and want each cell separate:
// [
//    "|_|_|_|",
//    "|_|_|_|"
// ]
// if instead, the last row should be "merged":
// [
//    "|_|_|_|",
//    "|_ _ _|"
// ]
//_tray_layout = 
//[
//    "| | |_|",
//    "|_|_|_|",
//    "|_| |_|",
//    "|_|_|_|"
//];

// sum vector values
function sumv(v, i, s = 0) = (i == s ? v[i] : v[i] + sumv(v, i - 1, s));
// output example line for tray layout.
function outv(i) = (i == 0 ? "|" : str(outv(i - 1), "_|"));

rows = len(_tray_layout);
echo(rows=rows);
cols = (len(_tray_layout[0]) - 1) / 2;
echo(cols=cols);

x_size_tray = sumv(_x_bin_widths, len(_x_bin_widths) - 1, 0) + ( (len(_x_bin_widths) + 1) * _wall_width);
echo(x_size_tray=x_size_tray);
y_size_tray = (rows * _y_bin_length) + ( (rows + 1) * _wall_width);
echo(y_size_tray=y_size_tray);

// this module can be used as part of a library.
module tray(
  tray_layout = ["|_|", "|_|"],
  x_bin_widths = [35],
  y_bin_length = 25,
  z_depth = 20,
  wall_width = 1.2,
  bottom_thickness = 1.2,
  grid_x = 4, // only used to generate example array
  grid_y = 3 // only used to generate example array
) {

  rows = len(tray_layout);
  cols = (len(tray_layout[0]) - 1) / 2;
  tray_string_len = len(tray_layout[0]);
  x_widths = concat([0], x_bin_widths);

  // generate and output example for tray_layout... copy paste for ease.

  for (r = [0:grid_y - 1]) {
    echo(outv(grid_x));
  }

  // layout initial box with compartments.
  mirror([0, 1, 0]) // do to application of logic, need to mirror through y axis.
  {
    difference() {
      union() {
        for (r = [0:rows - 1], c = [1:cols]) {

          translate(
            [
              sumv(x_widths, c - 1, 0) + ( (c - 1) * wall_width),
              (y_bin_length * r) + (r * wall_width),
              0,
            ]
          )
            difference() {

              cube(
                [
                  x_widths[c] + (wall_width * 2),
                  y_bin_length + (wall_width * 2),
                  z_depth + bottom_thickness,
                ]
              );
              translate([wall_width, wall_width, bottom_thickness])
                cube(
                  [
                    x_widths[c],
                    y_bin_length,
                    z_depth + bottom_thickness,
                  ]
                );
            }
        }
      }

      // remove appropriate walls.
      for (r = [0:rows - 1], c = [1:tray_string_len - 2])
      // assume first and last postion are |
      {
        if (c % 2 == 1) {
          // bottom wall
          if (r - 1 != len(tray_layout))
          // assume bottom wall exists for final row.
          {
            if (tray_layout[r][c] == " ") {
              // remove this wall.

              x_width_ref = (c - 1) / 2;
              translate(
                [
                  sumv(x_widths, x_width_ref, 0) + wall_width + (x_width_ref * wall_width),
                  ( (r + 1) * y_bin_length) + (r * wall_width) + wall_width,
                  0,
                ]
              )
                // nudge to cover entire wall, and mov to correct z.
                translate([0, -0.1, bottom_thickness])
                  cube(
                    [
                      x_bin_widths[x_width_ref],
                      wall_width + .2,
                      z_depth + bottom_thickness,
                    ]
                  );
            }
          }
        } else {
          // side wall
          if (tray_layout[r][c] == " ") {
            // remove this wall.

            x_width_ref = (c / 2);
            translate(
              [
                sumv(x_widths, x_width_ref, 0) + (x_width_ref * wall_width),
                ( (r) * y_bin_length) + (r * wall_width) + wall_width,
                0,
              ]
            )
              // nudge to cover entire wall, and mov to correct z. 
              translate([-0.1, 0, bottom_thickness])
                cube(
                  [
                    wall_width + .2,
                    y_bin_length,
                    z_depth + bottom_thickness,
                  ]
                );

            // remove remaining peg if entire intersection should be removed

            if (
              tray_layout[r - 1][c] == " " && tray_layout[r - 1][c - 1] == " " && tray_layout[r - 1][c - 1] == " "
            ) {

              translate(
                [
                  sumv(x_widths, x_width_ref, 0) + (x_width_ref * wall_width),
                  ( (r) * y_bin_length) + (r * wall_width),
                  0,
                ]
              )
                translate([-0.1, -.1, bottom_thickness])
                  cube(
                    [
                      wall_width + .2,
                      wall_width + .2,
                      z_depth + bottom_thickness,
                    ]
                  );
            }
          }
        }
      }
    }
  }
  // end mirror
}

module tray_lid(
  // generate a lid for the defined tray.
  lid_thickness = 1.2,
  lid_wall_thickness = 1.5,
  lid_depth = 15,
  lid_fudge = 0,
  // --- following defines the tray this lid will fit---
  tray_layout = ["|_|", "|_|"],
  x_bin_widths = [35],
  y_bin_length = 25,
  z_depth = 20,
  wall_width = 1.2,
  bottom_thickness = 1.2
) {
  rows = len(tray_layout);
  cols = (len(tray_layout[0]) - 1) / 2;
  tray_string_len = len(tray_layout[0]);

  x_size_tray = sumv(x_bin_widths, len(x_bin_widths) - 1, 0) + ( (len(x_bin_widths) + 1) * wall_width);
  y_size_tray = (rows * y_bin_length) + ( (rows + 1) * wall_width);

  // 0.8 is a good looseness for a lid (at least for my printrbot), fudging this can make tighter or looser.
  x_inner_lid = x_size_tray + lid_fudge;
  y_inner_lid = y_size_tray + lid_fudge;

  x_lid_outer = x_inner_lid + (lid_wall_thickness * 2);
  y_lid_outer = y_inner_lid + (lid_wall_thickness * 2);
  z_lid_total_h = lid_depth + lid_thickness;
  difference() {
    cube([x_lid_outer, y_lid_outer, z_lid_total_h]);
    translate([lid_wall_thickness, lid_wall_thickness, lid_thickness])
      cube([x_inner_lid, y_inner_lid, z_lid_total_h]);
  }
}

// if this is used as a library the "tray_layout" should be like the following: 
//_tray_layout = 
//[
//    "| | |_|",
//    "|_|_|_|",
//    "|_| |_|",
//    "|_|_|_|"
//];

if (_generate_lid) {
  tray_lid(
    _lid_thickness,
    _lid_wall_thickness,
    _lid_depth,
    _lid_fudge,
    _tray_layout,
    _x_bin_widths,
    _y_bin_length,
    _z_depth,
    _wall_width,
    _bottom_thickness
  );
} else if (true) {
  tray(
    _tray_layout,
    _x_bin_widths,
    _y_bin_length,
    _z_depth,
    _wall_width,
    _bottom_thickness,
    _grid_x,
    _grid_y
  );
}

// knife-tray-back-2, comment out tray call above
render() if (false) {
  difference() {
    tray(
      _tray_layout,
      _x_bin_widths,
      _y_bin_length,
      _z_depth,
      _wall_width,
      _bottom_thickness,
      _grid_x,
      _grid_y
    );

    // cut out col 4 walls to a height of a third
    translate(
      v=[
        3 * (_x_bin_widths[0] + _wall_width),
        -y_size_tray,
        _bottom_thickness + _z_depth / 3,
      ]
    )
      cube(
        [
          _x_bin_widths[0] + _wall_width * 2,
          y_size_tray,
          _z_depth * 2 / 3,
        ]
      );

    // cut out row 4 walls to a height of a third
    translate(
      v=[
        -0.01,
        -10 * (_y_bin_length + _wall_width),
        _bottom_thickness + _z_depth / 3,
      ]
    )
      cube(
        [
          x_size_tray + 0.02,
          (_y_bin_length + _wall_width) * 3 - _wall_width,
          _z_depth * 2 / 3,
        ]
      );
  }

  // add col 5 left cross members to a height of a third, small epsilon for compounded rounding
  translate(
    v=[
      4 * (_x_bin_widths[0] + _wall_width) + _wall_width,
      -y_size_tray,
      _bottom_thickness,
    ]
  )
    cube(
      [
        _wall_width,
        y_size_tray,
        _z_depth * 1 / 3,
      ]
    );
}

// knife-tray-front-2, comment out tray call above
render() if (false) {
  difference() {
    tray(
      _tray_layout,
      _x_bin_widths,
      _y_bin_length,
      _z_depth,
      _wall_width,
      _bottom_thickness,
      _grid_x,
      _grid_y
    );

    // cut out col 4 walls to a height of a third
    translate(
      v=[
        3 * (_x_bin_widths[0] + _wall_width),
        -y_size_tray,
        _bottom_thickness + _z_depth / 3,
      ]
    )
      cube(
        [
          _x_bin_widths[0] + _wall_width * 2,
          y_size_tray,
          _z_depth * 2 / 3,
        ]
      );
  }

  // add col 5 right cross members to a height of a third
  translate(
    v=[
      5 * (_x_bin_widths[0] + _wall_width),
      -y_size_tray,
      _bottom_thickness,
    ]
  )
    cube(
      [
        _wall_width,
        y_size_tray,
        _z_depth * 1 / 3,
      ]
    );
}
