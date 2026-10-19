include <BOSL2/std.scad>
include <lib/geom.scad>

debug_hull_children = false;
debug_points = false;
debug_cutouts = false;
debug_no_round = false;

// xy only, actual size changes with curved hulls
t_wall = 1.6;

base = [120, 120];

gap_surround = 1;
rounding_surround = 5;
h_surround = 8;
t_surround = 2.0;

h_roof = 6;

inset_bolt = 7.5;

w_nut = 7.0; // M4
// w_nut = 0.0; // M4
d_nut = w_nut * 2 / sqrt(3);
t_nut = 4;

d_bolt = 5.5;

// all quads are clockwise
// inset is from corner
// corner radii must be greater than t_wall * 2
// lower hulls down through all cross sections to lower, otherwise n - 1

inset_surround = t_surround + gap_surround;

cross_sections = [
  object(
    mid=object(
      circ=base.x / 2 + t_surround + gap_surround,
      // sph=base.x / 2 + t_surround + gap_surround,
      centre=[0, 0, 0],
    ),
    height=0,
    colour="yellow",
  ),
  object(
    corners=object(
      circles=[0, 0, 0, 0],
      spheres=[5, 5, 5, 5],
      insets=[
        [-40, -20],
        [-65, 20],
        [20, 20],
        [20, -20],
      ],
    ),
    height=32.5,
    // lower=0,
    colour="pink",
  ),
  object(
    corners=object(
      spheres=[5, 5, 5, 5],
      insets=[
        [-65, -40],
        [-65, 30],
        [20, 30],
        [20, -40],
      ],
    ),
    height=32.5 + 32.5,
    colour="orange",
  ),
  object(
    corners=object(
      circles=[5, 5, 5, 5],
      insets=[
        [-65, -40 - (100 / 32.5) * 20],
        [-65, 30],
        [20, 30],
        [20, -40 - (100 / 32.5) * 20],
      ],
    ),
    height=32.5 + 32.5 + 100,
    colour="limegreen",
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
      translate(v=mid.centre) {
        if (mid.sph) {
          sphere(r=mid.circ - dt);
        } else {
          cyl(r=mid.circ - dt, h=eps);
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
            sxy[i].x * (base.x / 2 + sec.corners.insets[i][0] - dt),
            sxy[i].y * (base.y / 2 + sec.corners.insets[i][1] - dt),
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
  top_half(s=base.x * 2, z=cross_sections[0].height) {
    bottom_half(s=base.x * 2, z=cross_sections[len(cross_sections) - 1].height) {
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
    #for(a=[0, 90, 180, 270]) {
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
    translate(v=[0, 0, h_roof / 2]) {
      cuboid(
        size=[outer.x, outer.y, h_roof],
        rounding=rounding_surround,
        except=[BOTTOM],
      );
    }
  }

  difference() {
    union() {
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
  base();

  shroud();

  if (debug_points) {
    // point_marker(P=[30, -60, 40], h=5, r=1, t="mem");

    for (i = [0:1:len(cross_sections) - 1])
      point_marker(P=[-100, 0, cross_sections[i].height], h=200, r=0.5, t=str(i), a_rot=90, v_rot=[0, 1, 0]);
  }
}
