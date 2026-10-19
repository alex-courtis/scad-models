include <BOSL2/std.scad>
include <lib/geom.scad>

debug_corners = false;
debug_points = false;
debug_cutouts = false;
debug_no_round = false;

// xy only, actual size changes with curved hulls
t_wall = 1.6;
t_bracket = 6;
t_surround = 2.0;

gap_surround = 1;
r_surround = 6 + t_surround + gap_surround;
l_surround = 8;

base = [120, 120];

inset_bolt = 7.5;

// w_nut = 7.0; // M4
w_nut = 0.0; // M4
d_nut = w_nut * 2 / sqrt(3);
t_nut = 3;

// TODO M4
// d_bolt = 5.5;
d_bolt = 9;
l_bolt = 25; //t_bracket;

// all quads are clockwise
// inset is from corner
// corner radii must be greater than t_wall * 2
// lower hulls down through all cross sections to lower, otherwise n - 1

inset_surround = t_surround + gap_surround;

cross_sections = [
  object(
    corner_circle=[r_surround, r_surround, r_surround, r_surround],
    inset=[
      [inset_surround, inset_surround],
      [inset_surround, inset_surround],
      [inset_surround, inset_surround],
      [inset_surround, inset_surround],
    ],
    height=-l_surround,
  ),
  object(
    corner_sphere=[r_surround, r_surround, r_surround, r_surround],
    inset=[
      [inset_surround, inset_surround],
      [inset_surround, inset_surround],
      [inset_surround, inset_surround],
      [inset_surround, inset_surround],
    ],
    height=0,
  ),
  object(
    corner_circle=[0, 0, 0, 0],
    corner_sphere=[5, 5, 5, 5],
    inset=[
      [-40, -20],
      [-65, 20],
      [20, 20],
      [20, -20],
    ],
    height=32.5,
    // lower=0,
  ),
  object(
    corner_sphere=[5, 5, 5, 5],
    inset=[
      [-65, -40],
      [-65, 30],
      [20, 30],
      [20, -40],
    ],
    height=32.5 + 32.5,
  ),
  object(
    corner_circle=[5, 5, 5, 5],
    inset=[
      [-65, -40 - (100 / 32.5) * 20],
      [-65, 30],
      [20, 30],
      [20, -40 - (100 / 32.5) * 20],
    ],
    height=32.5 + 32.5 + 100,
  ),
];

// clockwise from edge
cutouts = [
  [0, 0, 0],
  [-base.x - 20 + 5 + 8, -10, 32.5],
  // [0, 0, 0],
  [0, 0, 0],
  [0, 0, 0],
];
cutout_rounding = 3;

// clockwise signs for x/y corners
sxy = [[1, 1], [1, -1], [-1, -1], [-1, 1]];

$fn = 200;

module dbg_corners(dbg = debug_corners) {
  if (dbg) #children(); else children();
}

module dbg_cutouts(dbg = debug_cutouts) {
  if (dbg) #children(); else children();
}

module cross_section(n, dt = 0) {
  sec = cross_sections[n];

  // some volume is needed for hull
  eps = 0.0001;

  for (i = [0:1:3]) {
    r_sphere = is_list(sec.corner_sphere) && sec.corner_sphere[i] > 0 ? sec.corner_sphere[i] - dt : undef;
    r_circle = is_list(sec.corner_circle) && sec.corner_circle[i] > 0 ? sec.corner_circle[i] - dt : undef;

    dbg_corners()
      translate(
        v=[
          sxy[i].x * (base.x / 2 + sec.inset[i][0] - dt),
          sxy[i].y * (base.y / 2 + sec.inset[i][1] - dt),
          sec.height,
        ]
      ) {
        if (debug_no_round || (!r_sphere && !r_circle)) {
          cube(size=[eps, eps, eps], center=true);
        } else {
          if (r_sphere) {
            translate(v=[sxy[i].x * -r_sphere, sxy[i].y * -r_sphere, 0])
              sphere(r=r_sphere);
          }
          if (r_circle) {
            translate(v=[sxy[i].x * -r_circle, sxy[i].y * -r_circle, 0])
              cyl(r=r_circle, h=eps);
          }
        }
      }
  }
}

module bracket() {
  translate(v=[base.x / 2, base.y / 2, (t_bracket) / 2])
    cuboid(
      size=[inset_bolt * 4, inset_bolt * 4, t_bracket],
      rounding=inset_bolt,
      edges=[FRONT + LEFT],
    );
}

module brackets() {
  difference() {
    for (a = [0, 90, 180, 270])
      rotate(a=a, v=[0, 0, 1])
        bracket();

    nut_bolts();
  }
}

module nut_bolt() {
  module nut() {
    translate(v=[-inset_bolt, -inset_bolt, 0])
      rotate(a=-15, v=[0, 0, 1])
        cyl(d=d_nut, h=t_nut, $fn=6);
  }

  translate(v=[base.x / 2, base.y / 2, (t_bracket) / 2]) {

    translate(v=[-inset_bolt, -inset_bolt, 0])
      cyl(d=d_bolt, h=t_bracket);

    translate(v=[0, 0, (t_bracket - t_nut) / 2]) {
      nut();
      translate(v=[-w_nut / 4, -w_nut / 4, 0])
        nut();
    }
  }
}

module nut_bolts() {
  for (a = [0, 90, 180, 270])
    rotate(a=a, v=[0, 0, 1])
      nut_bolt();
}

module sections(dt) {
  top_half(s=base.x * 2, z=cross_sections[0].height) {
    bottom_half(s=base.x * 2, z=cross_sections[len(cross_sections) - 1].height) {
      for (n = [1:1:len(cross_sections) - 1]) {
        lower = is_num(cross_sections[n].lower) ? cross_sections[n].lower : n - 1;
        hull() {
          for (m = [lower:1:n - 1])
            cross_section(n=m, dt=dt);
          cross_section(n=n, dt=dt);
        }
      }
    }
  }
}

module cutouts() {
  height = cross_sections[len(cross_sections) - 1].height;

  dbg_cutouts() {
    for (i = [0:1:3]) {
      if (cutouts[i] != [0, 0, 0]) {
        translate(
          v=[
            sxy[i].x * base.x + cutouts[i].x,
            sxy[i].y * base.y + cutouts[i].y,
            0,
          ]
        ) {
          translate(v=[0, 0, cutouts[i].z + height / 2])
            cuboid(
              size=[base.x, base.y, height],
              rounding=cutout_rounding,
            );

          translate(v=[sxy[i].x * -base.x / 2, 0, height])
            rotate(a=sxy[i].x == 1 ? 180 : 0, v=[0, 0, 1])
              rotate(a=-90, v=[1, 0, 0])
                rounding_edge_mask(l=base.y, r=cutout_rounding);

          translate(v=[0, sxy[i].y * -base.y / 2, height])
            rotate(a=sxy[i].y * -90, v=[0, 0, 1])
              rotate(a=-90, v=[1, 0, 0])
                rounding_edge_mask(l=base.y, r=cutout_rounding);
        }
      }
    }
  }
}

module shroud() {
  difference() {
    union() {
      difference() {
        sections(dt=0);

        sections(dt=t_wall);
      }

      intersection() {
        brackets();

        sections(dt=0);
      }
    }

    cutouts();
  }
}

render() {
  shroud();

  if (debug_points) {
    point_marker(P=[30, -60, 40], h=5, r=1, t="mem");

    for (i = [0:1:len(cross_sections) - 1]) {
      point_marker(P=[-100, 0, cross_sections[i].height], h=200, r=0.5, t=str(i), a_rot=90, v_rot=[0, 1, 0]);
    }
  }
}
