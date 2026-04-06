include <BOSL2/std.scad>
include <lib/geom.scad>

d_filament = 0.4; // [0.2:0.2:0.8]

/* [Inner Dimensions] */
inner = [
  4.6,
  325,
  32,
];

inner_chamfer = inner.x * 0.275;

/* [Magnet Dimensions] */
magnet = [
  5.0,
  15.3,
  25.0,
];

/* [Outer Dimensions] */
t_wall = d_filament * 3;

l_cutout = 116;

outer = inner + [
  (magnet.x + t_wall * 2) * 2,
  t_wall,
  t_wall * 2,
];

hollow = [
  (outer.x - inner.x) / 2 - t_wall,
  outer.y - t_wall,
  outer.z - t_wall * 2,
];

enclosure = [
  magnet.x + t_wall * 2,
  magnet.y + t_wall * 2,
  outer.z - t_wall * 2,
];

dl_enclosure_mid = outer.y / 2 - l_cutout - enclosure.y / 2;
dl_enclosure_end = -(outer.y - enclosure.y) / 2 + hollow.x + t_wall;

l_socket = enclosure.y;

$fn = 200; // [0:1:500]

module magnet_boxes(size) {
  translate(v=[(enclosure.x + inner.x) / 2, 0, 0]) {
    translate(v=[0, dl_enclosure_end, 0])
      cube(size, center=true);
    translate(v=[0, dl_enclosure_mid, 0])
      cube(size, center=true);
  }
}

module hollow_mask() {
  translate(v=[(outer.x - hollow.x) / 2, t_wall / 2, 0])
    cuboid(
      hollow,
      chamfer=hollow.x,
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
  x = outer.x;

  y = l_socket;

  z1 = hollow.x + t_wall;
  z2 = outer.z - z1;

  translate(
    v=[
      0,
      outer.y / 2 - l_cutout + y,
      (outer.z - z1) / 2,
    ]
  ) {
    rotate(a=-90, v=[1, 0, 0])
      prismoid(
        size1=[x, z1],
        size2=[x, z2],
        shift=[0, (z2 - z1) / 2],
        h=l_cutout - y,
      );

    translate(v=[0, -y / 2, 0])
      cube([x, y, z1], center=true);
  }
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

module socket() {
  x = hollow.x;
  y = l_socket;
  z1 = hollow.x;
  z2 = outer.z - x - t_wall * 2;

  tri_top = [y, x];
  tri_bot = [y, 0];

  bot = [x, y, z2];

  brace = [x, y / 3, z1 + z2];

  dx = (outer.x - x) / 2;
  dy = (outer.y + y) / 2 - l_cutout;
  dz_triangle = outer.z / 2 - z1 - t_wall;

  translate(v=[dx, dy, 0]) {

    translate(v=[0, 0, -z1 / 2])
      cuboid(bot);

    translate(v=[0, -bot.y / 2 - brace.y / 2, 0])
      cuboid(brace);

    translate(v=[0, 0, dz_triangle]) {
      rotate(a=90)
        diff()
          prismoid(
            size1=tri_top,
            size2=tri_bot,
            shift=[0, -tri_top.y / 2],
            h=z1,
          ) {
            edge_profile([TOP + FRONT]) {
              mask2d_chamfer(h=t_wall, mask_angle=179.9);
            }
          }
    }
  }
}

module sockets() {
  socket();

  mirror(v=[1, 0, 0])
    socket();
}

render() {
  // back_half(s=300)
  difference() {
    union() {
      difference() {
        union() {
          color(c="steelblue")
            body();

          color(c="gray")
            magnet_boxes(enclosure);
        }

        color(c="pink")
          cutout_mask();
      }

      color(c="lightgray")
        sockets();
    }

    color(c="red")
      magnet_boxes(magnet + [0, 0, outer.z]);
  }
}
