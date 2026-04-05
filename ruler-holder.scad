include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4; // [0.2:0.2:0.8]

/* [Inner Dimensions] */
inner = [
  4,
  325,
  32,
];

inner_chamfer = inner[0] / 4;

/* [Magnet Dimensions] */
magnet = [
  5.0,
  15.0,
  25.0,
];

/* [Outer Dimensions] */
t_wall = d_filament * 3;

l_cutout = 116;

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

dl_enclosure_mid = outer[1] / 2 - l_cutout - enclosure[1] / 2;
dl_enclosure_end = -(outer[1] - enclosure[1]) / 2 + hollow[0] + t_wall;

$fn = 200; // [0:1:500]

module magnet_boxes(size) {
  translate(v=[(enclosure[0] + inner[0]) / 2, 0, 0]) {
    translate(v=[0, dl_enclosure_end, 0])
      cube(size, center=true);
    translate(v=[0, dl_enclosure_mid, 0])
      cube(size, center=true);
  }
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
  closed = [outer[0], hollow[0] + t_wall];
  open = [outer[0], outer[2] - closed[1]];

  translate(
    v=[
      0,
      outer[1] / 2 - l_cutout,
      (outer[2] - closed[1]) / 2,
    ]
  )
    rotate(a=-90, v=[1, 0, 0])
      prismoid(
        size1=closed,
        size2=open,
        shift=[0, (open[1] - closed[1]) / 2],
        h=l_cutout,
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
  difference() {
    union() {
      color(c="steelblue")
        body();

      color(c="gray")
        magnet_boxes(enclosure);
    }

    color(c="red")
      magnet_boxes(magnet + [0, 0, outer[2]]);

    color(c="pink")
      cutout_mask();
  }
}
