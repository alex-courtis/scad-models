include <BOSL2/std.scad>

/* model */
face = [47.7, 28.3, 2.7];
body = [44.3, 25, 14];
t_rib = 0.9;

dx_rib_x = 3; // from body
l_rib_x = 1;

dy_rib_y = 3.5; // from body
l_rib_y = 0.85;

w_clip = 6;
t_clip = 1.8;
clip_poly = [
  // from body side
  [5, 0],
  [11.5, 0],
  [8.5, t_clip],
];

/* shroud */

t_clip_socket = (t_clip - l_rib_y) * 2 / 3;

z_front = 4.25;
dxy_front = 6.0; // from face
rounding_front = 3;

gap_sleeve_x = t_clip;

z_sleeve = 18;
rounding_sleeve = rounding_front;

/* stem */

stem = [20, 40, 14];
rounding_stem = rounding_front;

t_wall_stem = 2.4;

/* bracket */

bracket = [body.x + dxy_front * 2, 13.5 + 2 + 3, 29];
dy_nut_bolt = 8 + 2; // from top of bracket
dz_nut = 11; // from front of bracket

y_bracket_channel = 7;

rounding_bracket = 0;

d_bolt = 5.15;
chamfer_bolt = 2;

w_nut = 7.9; // M5
d_nut = w_nut * 2 / sqrt(3) * 1.015;
t_nut = 3.9;

/* nubs */

t_nub = 2.0;
w_nub = 3.0;
l_nub_rat = 0.5; // of channel
n_nubs = 4;

$fn = 200;

module model() {

  translate(v=[0, 0, body.z / 2]) {
    color(c="orange")
      cube(size=body, center=true);
    translate(v=[0, 0, (body.z + face.z) / 2]) {
      color(c="pink")
        cube(size=face, center=true);
    }

    color(c="green") {
      for (i = [-1, 1], j = [-1, 1]) {
        translate(v=[i * ( ( -body.x + t_rib) / 2 + dx_rib_x), j * ( -body.y - l_rib_x) / 2, 0])
          cube(size=[t_rib, l_rib_x, body.z], center=true);
      }
    }

    color(c="blue") {
      for (i = [-1, 1], j = [-1, 1]) {
        translate(v=[i * ( -body.x - l_rib_y) / 2, j * ( ( -body.y + t_rib) / 2 + dy_rib_y), 0])
          cube(size=[l_rib_y, t_rib, body.z], center=true);
      }
    }
  }

  color(c="violet") {
    for (i = [-1, 1]) {
      translate(v=[-i * body.x / 2, 0, 0])
        rotate(a=i * 90, v=[0, 0, 1])
          rotate(a=-90, v=[0, 1, 0])
            linear_extrude(h=w_clip, center=true)
              polygon(clip_poly);
    }
  }
}

module shroud() {
  front = [body.x + dxy_front * 2, body.y + dxy_front * 2, z_front];
  front_inner = [body.x + 2 * l_rib_y, body.y + 2 * l_rib_x, front.z];

  sleeve = [front.x, front.y, z_sleeve];
  sleeve_inner = [body.x + 2 * gap_sleeve_x, body.y + 2 * l_rib_x, sleeve.z];

  channel_stem = [stem.x - 2 * t_wall_stem, stem.y + (sleeve.y - sleeve_inner.y) / 2 + bracket.y / 2, stem.z - t_wall_stem];
  dy_channel_stem = channel_stem.y / 2 + sleeve_inner.y / 2;

  channel_bracket = [bracket.x, y_bracket_channel, bracket.z - dz_nut - t_nut / 2]; // hex side t is major radius R

  dy_stem = sleeve.y / 2 + stem.y / 2;

  dy_bracket = sleeve.y / 2 + stem.y + bracket.y / 2;

  dy_bolt = dy_bracket + bracket.y / 2 - dy_nut_bolt;

  module mask_clip_socket() {
    for (i = [-1, 1])
      translate(v=[i * (front_inner.x + t_clip_socket) / 2, 0, 0])
        cuboid(size=[t_clip_socket, w_clip, 2 * (front.z + sleeve.z)]);
  }

  module mask_channel_stem() {
    translate(v=[0, dy_channel_stem, channel_stem.z / 2])
      cuboid(
        size=channel_stem,
        chamfer=channel_stem.x / 2,
        edges=[
          TOP + LEFT,
          TOP + RIGHT,
        ],
      );
  }

  module mask_channel_bracket() {
    translate(v=[0, dy_bracket, channel_bracket.z / 2])
      cuboid(
        size=channel_bracket,
        chamfer=channel_bracket.y / 2,
        edges=[
          TOP + FRONT,
          TOP + BACK,
        ],
      );
  }

  module mask_bolt() {
    translate(v=[0, dy_bolt, 0]) {
      cylinder(d=d_bolt, h=bracket.z);

      translate(v=[0, 0, bracket.z - chamfer_bolt])
        cylinder(d1=d_bolt, d2=d_bolt + chamfer_bolt * 2, h=chamfer_bolt);
    }
  }

  module mask_nut() {
    translate(v=[0, dy_bolt, -dz_nut])
      cylinder(d=d_nut, h=bracket.z, $fn=6);
  }

  module front() {
    translate(v=[0, 0, z_sleeve + z_front / 2]) {
      difference() {
        cuboid(
          size=front,
          rounding=rounding_front,
          except=BOTTOM,
        );
        cuboid(
          size=front_inner,
        );
      }
    }
  }

  module sleeve() {
    translate(v=[0, 0, sleeve.z / 2]) {
      difference() {
        cuboid(
          size=sleeve,
          rounding=rounding_sleeve,
          except=[TOP, BOTTOM],
        );
        cuboid(
          size=sleeve_inner,
          chamfer=(sleeve_inner.x - front_inner.x) / 2,
          edges=[
            TOP + LEFT,
            TOP + RIGHT,
          ],
        );
      }
    }
  }

  module stem() {

    translate(v=[0, dy_stem, stem.z / 2]) {
      difference() {
        cuboid(
          size=stem,
          rounding=rounding_stem,
          edges=[
            TOP + LEFT,
            TOP + RIGHT,
          ],
        );
      }
    }
  }

  module bracket() {
    translate(v=[0, dy_bracket, bracket.z / 2])
      cuboid(
        size=bracket,
        rounding=rounding_bracket,
        except=[
          BOTTOM,
        ],
      );
  }

  module nubs_stem() {
    nub = [channel_stem.x * l_nub_rat, w_nub, t_nub];
    dx_nub = (nub.x - channel_stem.x) / 2;
    dy_nub = (channel_stem.y - bracket.y / 2 - nub.y) / (n_nubs - 1);

    for (i = [0:n_nubs - 1])
      translate(
        v=[
          i % 2 == 0 ? dx_nub : -dx_nub,
          sleeve_inner.y / 2 + nub.y / 2 + i * dy_nub,
          nub.z / 2,
        ]
      )
        cuboid(size=nub);
  }

  translate(v=[0, 0, body.z - z_front - z_sleeve]) {
    difference() {
      union() {
        color(c="firebrick")
          front();

        color(c="tomato")
          sleeve();

        color(c="orangered")
          stem();

        color(c="chocolate")
          bracket();
      }

      color(c="limegreen")
        mask_bolt();

      color(c="purple")
        mask_nut();

      color(c="blue")
        mask_clip_socket();

      color(c="pink")
        mask_channel_stem();

      color(c="blue")
        mask_channel_bracket();
    }

    color(c="violet")
      nubs_stem();
  }
}

render() {
  // intersection() 
  {
    // model();
    shroud();
  }
}
