include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4; // [0.2:0.2:0.8]

/* [Inner Dimensions] */
inner = [
  4,
  280,
  32,
];

inner_chamfer = inner[0] / 4;

/* [Magnet Dimensions] */
magnet = [
  4.9,
  15,
  25,
];

/* [Outer Dimensions] */
t_wall = d_filament * 2;

l_cutout = 120;

outer = inner + [
  (magnet[0] + t_wall * 2) * 2,
  t_wall,
  t_wall * 2,
];

hollow = [
  (outer[0] - inner[0]) / 2 - t_wall,
  outer[1] - t_wall,
  outer[2] - t_wall * 2,
];

enclosure = [
  magnet[0] + t_wall * 2,
  magnet[1] + t_wall * 2,
  outer[2] - t_wall * 2,
];

dl_enclosure_mid = 0;
dl_enclosure_end = -(outer[1] - enclosure[1]) / 2 + t_wall + enclosure[1];

$fn = 200; // [0:1:500]

module magnet_box(size) {
  translate(v=[(enclosure[0] + inner[0]) / 2, 0, 0]) {
    translate(v=[0, dl_enclosure_end, 0])
      cube(size, center=true);
    translate(v=[0, dl_enclosure_mid, 0])
      cube(size, center=true);
  }
}

module magnet_boxes(size) {
  magnet_box(size);
  mirror(v=[1, 0, 0])
    magnet_box(size);
}

module hollow_mask() {
  translate(v=[(outer[0] - hollow[0]) / 2, t_wall / 2, 0])
    cuboid(
      hollow,
      chamfer=hollow[0],
      edges=[LEFT],
      except=[BACK],
    );
}

module inner_mask() {
  translate(v=[0, t_wall / 2, 0])
    cuboid(
      inner,
      chamfer=inner_chamfer,
      except=[BACK],
    );
}

module cutout_mask() {
  translate(v=[0, outer[1] - l_cutout, outer[2] / 2])
    cuboid(
      outer
    );
}

module body() {

  difference() {
    cuboid(
      outer,
      chamfer=t_wall / 2,
    );

    inner_mask();

    hollow_mask();

    mirror(v=[1, 0, 0])
      hollow_mask();
  }
}

render() {
  front_half(y=30, s=outer[1] * 2)
    back_half(y=-20, s=outer[1] * 2)
      difference() {
        union() {
          color(c="steelblue")
            body();
          color(c="gray")
            magnet_boxes(enclosure);
        }

        color(c="red")
          magnet_boxes(magnet);

        color(c="pink")
          translate(v=[0, 0, magnet[2]])
            magnet_boxes(magnet);

        color(c="maroon")
          cutout_mask();
      }
}
