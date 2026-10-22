include <BOSL2/std.scad>
include <lib/geom.scad>

debug_hull_children = false;
debug_points = false;
debug_cutouts = false;

// xy only, actual size changes with curved hulls
t_wall = 1.6;

base = [120, 120];

enable_surround = false;
gap_surround = 1;
rounding_surround = 5;
h_surround = 8;
t_surround = 2.0;

h_roof = 7;
rounding_roof = 3;

inset_bolt = 7.5;

w_nut = 7.0; // M4
// w_nut = 0.0; // M4
d_nut = w_nut * 2 / sqrt(3);
t_nut = 4;

d_bolt = 5.5;
// d_bolt = 9.5;

// all quads are conventionally clockwise and contain 4
// inset is from origin
// corner radii must be greater than t_wall * 2
// lower hulls down through all cross sections to lower, otherwise n - 1

d_fan = 116;
r_fan = d_fan / 2;

z_bot = -82;

cross_sections = [
  object(
    mid=object(
      circ=r_fan + t_wall,
      centre=[0, 0, 0],
      scal=[1, 1, 1],
    ),
    height=0,
    colour="yellow",
  ),
  object(
    corners=object(
      spheres=[30, 0, 25, 30],
      insets=[
        [-20, 10],
        [0, 0],
        [-40, -60],
        [-35, 10],
      ],
    ),
    height=40,
    colour="pink",
  ),
  object(
    mid=object(
      sph=30,
      centre=[-35 + (30 * 0.7 - 30), -95],
      scal=[0.7, 1, 1],
    ),
    height=130,
    colour="limegreen",
  ),
  object(
    mid=object(
      circ=0.001,
      centre=[-35 + (30 * 0.6 - 30), -95],
      scal=[1, 1, 1],
    ),
    height=160,
    colour="red",
  ),
];

// clockwise from edge
cutouts = [
  [0, 0, 0],
  [0, 0, 0],
  // [-160, -10, 30],
  [0, 0, 0],
  [0, 0, 0],
];
cutout_rounding = 3;

// clockwise signs for x/y cutout corners
sxy = [[1, 1], [1, -1], [-1, -1], [-1, 1]];

$fn = 200;

module dbg_hull_children(dbg = debug_hull_children) {
  if (dbg) #children(); else children();
}

module dbg_cutouts(dbg = debug_cutouts) {
  if (dbg) #children(); else children();
}

module cross_section(n, dt = 0) {
  sec = cross_sections[n];

  // some volume is needed for hull
  eps = 0.0001;

  module mid() {
    mid = sec.mid;
    dbg_hull_children() {
      translate(v=[0, 0, sec.height]) {
        translate(v=mid.centre) {
          scale(mid.scal ? mid.scal : [1, 1, 1]) {
            if (mid.sph) {
              sphere(r=mid.sph - dt);
            } else {
              cyl(r=mid.circ - dt, h=eps);
            }
          }
        }
      }
    }
  }

  module corners() {
    corners = sec.corners;
    for (i = [0:1:3]) {
      r_sphere = is_list(sec.corners.spheres) && sec.corners.spheres[i] > 0 ? sec.corners.spheres[i] - dt : undef;
      r_circle = is_list(sec.corners.circles) && sec.corners.circles[i] > 0 ? sec.corners.circles[i] - dt : undef;

      dbg_hull_children()
        translate(
          v=[
            sec.corners.insets[i][0],
            sec.corners.insets[i][1],
            sec.height,
          ]
        ) {
          if (r_sphere)
            sphere(r=r_sphere);
          if (r_circle)
            cyl(r=r_circle, h=eps);
        }
    }
  }

  if (sec.mid) {
    mid();
  } else if (sec.corners) {
    corners();
  }
}

module section(n, dt) {
  lower = is_num(cross_sections[n].lower) ? cross_sections[n].lower : n - 1;
  color(c=cross_sections[n].colour)
    hull() {
      for (m = [lower:1:n - 1])
        cross_section(n=m, dt=dt);
      cross_section(n=n, dt=dt);
    }
}

module sections(dt) {
  top_half(s=base.x * 3, z=cross_sections[0].height) {
    bottom_half(s=base.x * 3, z=cross_sections[len(cross_sections) - 1].height) {
      for (n = [1:1:len(cross_sections) - 1]) {
        section(n, dt);
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
    }

    cutouts();
  }
}

module base() {
  inner = [base.x + 2 * gap_surround, base.y + 2 * gap_surround, h_surround];
  outer = inner + [2 * t_surround, 2 * t_surround, 0];

  module mask_nuts_bolts() {
    for (a = [0, 90, 180, 270]) {
      rotate(a=a, v=[0, 0, 1]) {
        translate(v=[base.x / 2 - inset_bolt, base.y / 2 - inset_bolt, (h_roof) / 2]) {

          cyl(d=d_bolt, h=h_roof);

          translate(v=[0, 0, (h_roof - t_nut) / 2])
            rotate(a=-15, v=[0, 0, 1])
              cyl(d=d_nut, h=t_nut, $fn=6);
        }
      }
    }
  }

  module surround() {
    translate(v=[0, 0, -h_surround / 2]) {
      difference() {
        cuboid(
          size=outer,
          rounding=rounding_surround,
          except=[TOP, BOTTOM],
        );
        cuboid(
          size=inner,
          rounding=rounding_surround,
          except=[TOP, BOTTOM],
        );
      }
    }
  }

  module roof() {
    b = enable_surround ? [outer.x, outer.y, h_roof] : [base.x, base.y, h_roof];
    translate(v=[0, 0, h_roof / 2]) {
      cuboid(
        size=b,
        rounding=rounding_roof,
        except=[BOTTOM],
      );
    }
  }

  difference() {
    union() {
      if (enable_surround)
        color(c="green")
          surround();

      color(c="blue")
        roof();
    }

    section(n=1, dt=t_wall);

    mask_nuts_bolts();
  }
}

render() {
  back_half(s=cross_sections[len(cross_sections) - 1].height * 2, y=z_bot) {
    base();

    shroud();
  }

  if (debug_points) {
    // point_marker(P=[30, -60, 40], h=5, r=1, t="mem");

    for (i = [0:1:len(cross_sections) - 1])
      point_marker(P=[-100, 0, cross_sections[i].height], h=200, r=0.5, t=str(i), a_rot=90, v_rot=[0, 1, 0]);
  }
}
