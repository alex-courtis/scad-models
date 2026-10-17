include <BOSL2/std.scad>
include <lib/geom.scad>

debug_corners = false;
debug_points = false;
debug_cutouts = false;

base = [120, 120];

// xy only, actual size changes with curved hulls
t_wall = 1.6;
t_bracket = 10;

inset_bolt = 7.5;

w_nut = 0; //7.0; // M4
d_nut = w_nut * 2 / sqrt(3);
t_nut = 3;

// TODO M4
d_bolt = 9; //5.5;
l_bolt = 25; //t_bracket;

// all quads are clockwise
// inset is from corner
// corner radii must be greater than t_wall * 2
// lower hulls down through all cross sections to lower, otherwise n - 1

cross_sections = [
  object(
    corner_circle=[inset_bolt, inset_bolt, inset_bolt, inset_bolt],
    inset=[
      [0, 0],
      [0, 0],
      [0, 0],
      [0, 0],
    ],
    height=0,
  ),
  object(
    corner_circle=[5, 5, 0, 0],
    corner_sphere=[0, 0, 5, 5],
    inset=[
      [-20, -20],
      [-65, 10],
      [20, 10],
      [20, -20],
    ],
    // lower=0,
    height=35,
  ),
  object(
    corner_circle=[5, 5, 5, 5],
    inset=[
      [-65, -40],
      [-65, 20],
      [20, 20],
      [20, -40],
    ],
    // lower=0,
    height=35 + 35, // - 2,
  ),
  object(
    corner_circle=[5, 5, 5, 5],
    inset=[
      [-65, -40],
      [-65, 20],
      [20, 20],
      [20, -40],
    ],
    height=20 + 35 + 35 - 2,
  ),
];

// clockwise from edge
cutouts = [
  [0, 0, 0],
  [0, 0, 0],
  // [-100, -30, 80],
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
        if (r_sphere) {
          translate(v=[sxy[i].x * -r_sphere, sxy[i].y * -r_sphere, 0])
            sphere(r=r_sphere);
        } else if (r_circle) {
          translate(v=[sxy[i].x * -r_circle, sxy[i].y * -r_circle, 0])
            cyl(r=r_circle, h=eps);
        } else {
          cube(size=[eps, eps, eps], center=true);
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
  for (a = [0, 90, 180, 270])
    rotate(a=a, v=[0, 0, 1])
      bracket();
}

module nut_bolt() {
  translate(v=[base.x / 2, base.y / 2, (t_bracket) / 2]) {

    translate(v=[-inset_bolt, -inset_bolt, (l_bolt - t_bracket) / 2])
      cyl(d=d_bolt, h=l_bolt);

    translate(v=[0, 0, (t_bracket - t_nut) / 2]) {
      translate(v=[-inset_bolt, -inset_bolt, 0])
        rotate(a=15, v=[0, 0, 1])
          cyl(d=d_nut, h=t_nut, $fn=6);

      translate(v=[-inset_bolt - d_nut * sqrt(2) / 4, -inset_bolt - d_nut * sqrt(2) / 4, 0])
        rotate(a=-45, v=[0, 0, 1])
          cuboid(size=[d_nut, d_nut, t_nut]);
    }
  }
}

module nut_bolts() {
  for (a = [0, 90, 180, 270])
    rotate(a=a, v=[0, 0, 1])
      nut_bolt();
}

module sections(dt) {
  top_half(s=base.x * 2, z=0) {
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

    nut_bolts();

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
