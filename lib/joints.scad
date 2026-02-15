/**
Joints centred at the origin, shoulders along the y axis, length along the x axis measured to the midpoints of the shoulders.

|<------l1-------->|                       |<------l2-------->|
.                  .                       .                  .
.                  .                       .                  .
------------------------B-----------------------C--------------     ^
|                  .   /                   .   /              |     |
|                  .  /        y           .  /               |     |
|                  . /         ^           . /                |     |
|                  ./          |           ./                 |     |
|                  -           O-->x       -                  |     w
|                 /                       /                   |     |
|             |a1/                    |a2/                    |     |
|             | /                     | /                     |     |
|             |/                      |/                      |     |
--------------A-----------------------D------------------------     -

l is the sum of the (even) perpendiculars from AB to O and from CD to O.

a1 and a2 may be negative, with size less than 90.

When l1|l2 == 0, joint terminates at AB|CD, with no l_gap added.

Joint is cut at ratios from -z to +z, starting with waste when inner is set.

g_cheek / 2 is added to z waste and should be applied to the other joint.

g_shoulder is usually applied to shoulders AB CD, with half applied to inner shoulders.

r_edge is a sphere capped cylinder usually cut into all concave edges along xy and z.

d_dowel may be cut through the joint at origin.
*/

/* [Debug] */

// joint waste
show_waste_layers = false;

// joint h and v edge lines
show_waste_lines = false;

/* [Default Dimensions] */

// -x
l1 = 25; // [1:1:500]

// +x
l2 = 25; // [1:1:500]

// y
w = 20; // [1:1:500]

// z
t = 10; // [1:1:500]

/* [Halving - 0.4 Nozzle Cheek Facing Up] */
g_shoulder_halving = 0.004; // [0:0.001:2]
g_cheek_halving = 0.12; // [0:0.001:2]
r_edge_halving = 0.15; // [0:0.001:2]

/* [Mortise And Tenon - 0.4 Nozzle Cheeks Facing Side ] */
g_shoulder_mt = 0.07; // [0:0.001:2]
g_cheek_mt = 0.08; // [0:0.001:2]
g_side_mt = 0.03; // [0:0.001:2]
r_edge_mt = 0.35; // [0:0.001:2]

/* [Dovetail - 0.4 Nozzle Cheek Facing Up] */
a_tail = 10; // [1:0.5:30]
g_shoulder_dt = 0.035; // [0:0.001:2]
g_cheek_dt = 0.12; // [0:0.001:2]
g_pin_dt = 0.001; // [0:0.001:2]
r_edge_dt = 0.25; // [0:0.001:2]

/* [Dowels] */

// for printing z (up), 2.35, 0 for no dowel
d_dowel_v = 0; // [0:0.05:5]

// for printing x/y (across), 2.05, 0 for no dowel
d_dowel_h = 0; // [0:0.05:5]

/* [Tuning] */

$fn = 200; // [10:1:1000]

// accept large epsilon needed exposed joint when a != 0
eps_end = 2; // [0:1:100]

// spheres are slow to render
fn_edge_sphere = 30; // [20:1:200]

// keep this low as it can result in non-manfold problems when intersecting
fn_edge_line = 16; // [20:1:200]

COL = [
  ["orange", "wheat"], // 0
  ["navajowhite", "sienna"], // 1
  ["chocolate", "rosybrown"], // 2
  ["sandybrown", "brown"], // 3
  ["bisque", "darkgoldenrod"], // 4
  ["burlywood", "maroon"], // 5
  ["blanchedalmond", "peru"], // 6
  ["tan", "saddlebrown"], // 7
  ["lightsalmon", "indianred"], // 8
  ["coral", "firebrick"], // 9
  ["mistyrose", "orangered"], // 10
];

/**
Build a generic joint centred at origin.
Entire body is z extruded and wasted out.
xy line segments capped with spheres specified by edge_lines_h are removed from each layer
z cylinders capped with spheres specified by edge_points_v are removed from waste and body layers
*/
module joint_build(
  t, // total z
  body, // poly to build
  waste, // poly to z waste
  ratios, // [0] or [1] for all or no waste, depending on inner
  inner, // true for waste at bottom
  g_cheek,
  r_edge,
  d_dowel,
  edge_lines_h, // y horizontal cutouts
  edge_points_v_body, // vertical shoulder cutouts
  edge_points_v_waste, // vertical blind edge cutouts
) {

  waste_scope =
    (ratios == [0] && !inner || ratios == [1] && inner) ? "all"
    : (ratios == [0] && inner || ratios == [1] && !inner) ? "none"
    : "layers";

  // remove inner horizontal edges
  // cut out a cylinder and cap with spheres
  module edge_line_(A, B) {
    if (A && B) {
      a = line_angle(A, B);
      h = line_distance(A, B);
      dx = (B[0] + A[0]) / 2;
      dy = (B[1] + A[1]) / 2;

      translate(v=[dx, dy, 0])
        rotate(a=a, v=[0, 0, 1])
          rotate(a=90, v=[0, 1, 0])
            cylinder(r=r_edge, h=h, center=true, $fn=fn_edge_line);

      translate(v=A)
        sphere(r=r_edge, $fn=fn_edge_sphere);
      translate(v=B)
        sphere(r=r_edge, $fn=fn_edge_sphere);
    }
  }
  module edge_line(A, B) if (show_waste_lines) #edge_line_(A, B); else edge_line_(A, B);

  // remove inner vertical edges
  // these will intersect with the spheres from the horizontals
  module edge_point_(P, h) {
    if (P) {
      translate(v=P, $fn=fn_edge_line)
        cylinder(r=r_edge, h=h);
      translate(v=P)
        sphere(r=r_edge, $fn=fn_edge_sphere);
      translate(v=[0, 0, h])
        translate(v=P)
          sphere(r=r_edge, $fn=fn_edge_sphere);
    }
  }
  module edge_point(P, h) if (show_waste_lines) #edge_point_(P, h); else edge_point_(P, h);

  // waste a layer of thickness h
  module waste_(h, center) {
    linear_extrude(h=h, center=center)
      polygon(waste);
  }
  module waste(h, center) if (show_waste_layers) #waste_(h, center); else waste_(h, center);

  // material/waste bottom up from origin
  module waste_layers() {
    im = inner ? 1 : -1;
    dzs = [
      -t / 2,
      for (i = [0:1:len(ratios) - 1]) -t / 2 + ratios[i] * t + (i % 2 == 0 ? im : -im) * g_cheek / 2,
      t / 2,
    ];

    // material/waste thicknesses
    zs = [
      for (i = [0:1:len(dzs) - 2]) dzs[i + 1] - dzs[i],
    ];

    for (i = [0:1:len(zs) - 1])
      translate(v=[0, 0, dzs[i]]) {

        wasting = inner && (i % 2 == 0) || !inner && (i % 2 == 1);

        // remove joint waste
        if (wasting)
          waste(h=zs[i], center=false);

        if (r_edge && edge_lines_h && i > 0)
          for (l = edge_lines_h)
            edge_line(l[0], l[1]);

        if (r_edge && edge_points_v_waste && wasting)
          for (p = edge_points_v_waste)
            edge_point(p, zs[i]);

        if (r_edge && edge_points_v_body && !wasting)
          for (p = edge_points_v_body)
            edge_point(p, zs[i]);
      }
  }

  module waste_all() {
    waste(h=t, center=true);

    if (r_edge && edge_points_v_waste)
      for (p = edge_points_v_waste)
        translate(v=[0, 0, -t / 2])
          edge_point(p, t);
  }

  module waste_none() {
    if (r_edge && edge_points_v_body)
      for (p = edge_points_v_body)
        translate(v=[0, 0, -t / 2])
          edge_point(p, t);
  }

  difference() {

    // entire body
    linear_extrude(h=t, center=true)
      polygon(body);

    // maybe waste
    if (waste_scope == "all") {
      waste_all();
    } else if (waste_scope == "layers") {
      waste_layers();
    } else {
      waste_none();
    }

    // centred dowel
    if (d_dowel) {
      cylinder(d=d_dowel, h=t, center=true);
    }
  }
}

/**
   Return poly ABCD
   d1 is perpendicular from AB to O
   d2 is perpendicular from CD to O
   undef when not a convex polygon
  
  
            B-----------------------C   ^
           /       |               /    |
          /        |              /     |
         /         |             /      y1
        /          |            /       |
       M-----------O-----------N       ---
      /            |          /         |
  |a1/             |      |a2/          y2
  | /              |      | /           |
  |/               |      |/            |
  A-----------------------D             -
*/
function skewed_rect(y1, y2, d1, d2, a1, a2) =
  assert(is_num(y1))
  assert(is_num(y2))
  assert(is_num(d1))
  assert(is_num(d2))

  assert(is_num(a1))
  assert(a1 < 90 && a1 > -90)

  assert(is_num(a2))
  assert(a2 < 90 && a2 > -90)

  let (
    dxA = y2 * tan(a1),
    dxB = y1 * tan(a1),
    dxC = y1 * tan(a2),
    dxD = y2 * tan(a2),
    Mx = d1 / cos(a1),
    Nx = d2 / cos(a2),
    Ax = -Mx - dxA,
    Bx = -Mx + dxB,
    Cx = Nx + dxC,
    Dx = Nx - dxD,
  ) Bx < Cx && Ax < Dx ?
    [
      [Ax, -y2],
      [Bx, y1],
      [Cx, y1],
      [Dx, -y2],
    ]
  : undef;

/**
Intersection point of two lines specified by point and angle
*/
function line_intersect(P1, a1, P2, a2) =
  assert(is_num(a1))
  assert(is_num(a2))
  assert(a1 != a2)

  let (
    // y = ax + c
    v1 = ( (a1 + 90) % 180 == 0),
    a = v1 ? undef : tan(a1),
    c = v1 ? undef : P1[1] - P1[0] * a,

    // y = bx + d
    v2 = ( (a2 + 90) % 180 == 0),
    b = tan(a2),
    d = P2[1] - P2[0] * b,

    // x = (d - c) / (a - b)
    x = v1 ?
      P1[0]
    : v2 ?
      P2[0]
    : (d - c) / (a - b),

    // y = a * x + c
    y = v1 ?
      (b * x + d)
    : (a * x + c),
  ) [
      x,
      y,
  ];

// distance between two points
function line_distance(A, B) = sqrt((B[0] - A[0]) ^ 2 + (B[1] - A[1]) ^ 2);

// angle from x axis between two points
function line_angle(A, B) = B[1] == A[1] ? 0 : atan((B[1] - A[1]) / (B[0] - A[0]));

function point_round(P) = [round(P[0]), round(P[1])];

// print with cheek facing up
module halving(
  l = w,
  l1 = l1,
  l2 = l2,
  w = w,
  t = t,
  a = 0,
  ratio = 1 / 2,
  ratios = undef, // overrides ratio
  g_shoulder = g_shoulder_halving, // one to each shoulder
  g_cheek = g_cheek_halving, // half to each cheek
  r_edge = r_edge_halving,
  d_dowel = d_dowel_v,
  inner = false,
) {
  assert(l > 0);
  assert(w > 0);
  assert(t > 0);
  assert(g_shoulder >= 0);
  assert(g_cheek >= 0);
  assert(r_edge >= 0);
  assert(d_dowel >= 0);

  body = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l1 ? (l / 2 + l1) : l / 2,
    d2=l2 ? (l / 2 + l2) : l / 2,
    a1=l1 ? 0 : a,
    a2=l2 ? 0 : a,
  );

  d1_waste =
    l1 == 0 ? l / 2 + eps_end
    : l / 2 + g_shoulder;

  d2_waste =
    l2 == 0 ? l / 2 + eps_end
    : l / 2 + g_shoulder;

  waste = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=d1_waste,
    d2=d2_waste,
    a1=a,
    a2=a,
  );

  edge_lines_h = [
    l1 ? [waste[0], waste[1]] : undef,
    l2 ? [waste[2], waste[3]] : undef,
  ];

  joint_build(
    t=t,
    body=body,
    waste=waste,
    ratios=ratios ? ratios : [ratio],
    g_cheek=g_cheek,
    r_edge=r_edge,
    d_dowel=d_dowel,
    inner=inner,
    edge_lines_h=edge_lines_h,
  );
}

// print with vertical cheeks
// set l2 for a tee bridle
module tenon(
  l = w, // of the mortise
  l1 = l1,
  l2 = 0,
  w = w,
  t = t,
  a = 0,
  l_tenon = undef, // length of the tenon, < l for blind, > l for exposed, ignored when l2 > 0
  ratio = 1 / 3, // of the tenon, centred
  ratios = undef, // overrides ratio
  g_shoulder = g_shoulder_mt, // one to each shoulder, half to blind end
  g_cheek = g_cheek_mt, // half to each cheek
  r_edge = r_edge_mt,
  d_dowel = d_dowel_h,
  inner = true,
) {
  assert(l > 0);
  assert(w > 0);
  assert(t > 0);
  assert(g_shoulder >= 0);
  assert(g_cheek >= 0);
  assert(r_edge >= 0);
  assert(d_dowel >= 0);

  blind = l_tenon && l_tenon < l && l2 == 0;
  exposed = l_tenon && l_tenon > l && l2 == 0;

  d1_body = l / 2 + l1;
  d2_body =
    exposed ? l_tenon - l / 2
    : blind ? l_tenon - l / 2 - g_shoulder / 2
    : l / 2 + l2;

  body = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=d1_body,
    d2=d2_body,
    a1=l1 ? 0 : a,
    a2=(blind || exposed || !l2) ? a : 0,
  );

  d1_waste =
    l1 == 0 ? d1_body + eps_end
    : l / 2 + g_shoulder;

  d2_waste =
    exposed ? d2_body + eps_end
    : l2 == 0 ? d2_body + eps_end
    : l / 2 + g_shoulder;

  waste = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=d1_waste,
    d2=d2_waste,
    a1=a,
    a2=a,
  );

  edge_lines_h = [
    l1 ? [waste[0], waste[1]] : undef,
    l2 ? [waste[2], waste[3]] : undef,
  ];

  joint_build(
    t=t,
    body=body,
    waste=waste,
    ratios=ratios ? ratios : [(1 - ratio) / 2, (1 + ratio) / 2],
    g_cheek=g_cheek,
    r_edge=r_edge,
    d_dowel=d_dowel,
    inner=inner,
    edge_lines_h=edge_lines_h,
  );
}

// print with vertical slot
// remove l1 or l2 for a corner bridle
module mortise(
  l = w, // of the tenon
  l1 = l1,
  l2 = l2,
  w = w,
  t = t,
  a = 0,
  l_tenon = undef, // length of the tenon, set to less than w for blind
  ratio = 1 / 3, // of the slot, centred
  ratios = undef, // overrides ratio
  g_shoulder = g_shoulder_mt, // half to blind end
  g_cheek = g_cheek_mt, // half to each cheek
  g_side = g_side_mt, // one to each side
  r_edge = r_edge_mt,
  d_dowel = d_dowel_h,
  inner = false,
) {
  assert(l > 0);
  assert(w > 0);
  assert(t > 0);
  assert(g_shoulder >= 0);
  assert(g_cheek >= 0);
  assert(g_side >= 0);
  assert(r_edge >= 0);
  assert(d_dowel >= 0);

  blind = l_tenon && l_tenon < w;

  body = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l1 ? (l / 2 + l1) : l / 2,
    d2=l2 ? (l / 2 + l2) : l / 2,
    a1=l1 ? 0 : a,
    a2=l2 ? 0 : a,
  );

  d1_waste =
    l1 == 0 ? l / 2 + eps_end
    : l / 2 + g_side;

  d2_waste =
    l2 == 0 ? l / 2 + eps_end
    : l / 2 + g_side;

  // full g_shoulder on shoulders, half on blind
  waste = skewed_rect(
    y1=w / 2,
    y2=blind ? l_tenon - w / 2 + g_shoulder / 2 : w / 2,
    d1=d1_waste,
    d2=d2_waste,
    a1=a,
    a2=a,
  );

  edge_lines_h = [
    l1 ? [waste[0], waste[1]] : undef,
    l2 ? [waste[2], waste[3]] : undef,
    blind ? [waste[0], waste[3]] : undef,
  ];

  edge_points_v_waste = [
    (blind && l1) ? waste[0] : undef,
    (blind && l2) ? waste[3] : undef,
  ];

  joint_build(
    t=t,
    body=body,
    waste=waste,
    ratios=ratios ? ratios : [(1 - ratio) / 2, (1 + ratio) / 2],
    g_cheek=g_cheek,
    r_edge=r_edge,
    d_dowel=d_dowel,
    inner=inner,
    edge_lines_h=edge_lines_h,
    edge_points_v_waste=edge_points_v_waste,
  );
}

/**
|<-------l1-------->|
.                   .   
.                   .   
R---------------------------B-----------------------F-------------C   ^
|                   .      /                     --J----/        /    |
|                   .     /              -------/ /             /     |
|                   .    /       -------/        /             /      |
|                   .   S-------/               /             /       |
|                   .  /                       /             /        |
|                   . /                       /             /         |
|                   ./                       /             /          |
|                   -                  O    /             /           w
|                  /                       /             /            |
|                 /                       /             /             |
|                /                       /             /              |
|               T-----\                 /             /               |
|              /       ------\         /             /                |
|           |a/               ------\ /             /                 |
|           |/                       K-----\       /                  |
Q-----------A-----------------------E-------------D                   -

a_dov is BCS and TDA
blind: ends at JK otherwise CD
g_shoulder AB, half JK when blind 
*/
module dove_tail(
  l = w, // of the socket
  l1 = l1,
  w = w,
  t = t,
  a = 0, // RBA
  a_tail = a_tail, // BSC
  l_tail = undef, // length of the tail, < l for blind, ignored when > l
  ratio = 1 / 2, // undef or 0 for no vertical waste
  g_shoulder = g_shoulder_dt, // one to each shoulder, half to blind end
  g_cheek = g_cheek_dt, // half to each cheek
  r_edge = r_edge_dt,
  d_dowel = d_dowel_v,
  inner = true,
) {
  assert(l > 0);
  assert(w > 0);
  assert(t > 0);
  assert(a_tail > 0);
  assert(g_shoulder >= 0);
  assert(g_cheek >= 0);
  assert(r_edge >= 0);
  assert(d_dowel >= 0);

  blind = l_tail && l_tail > 0 && l_tail < l;
  tail_only = l1 == 0;

  QRBA = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l / 2 + l1,
    d2=-l / 2 - g_shoulder,
    a1=0,
    a2=a,
  );
  Q = QRBA[0];
  R = QRBA[1];

  ABCD = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l / 2 + (tail_only ? 0 : g_shoulder),
    d2=l / 2,
    a1=a,
    a2=a,
  );
  A = ABCD[0];
  B = ABCD[1];
  C = ABCD[2];
  D = ABCD[3];

  // AB <-> C
  S = line_intersect(P1=B, a1=90 - a, P2=C, a2=a_tail);
  // AB <-> D
  T = line_intersect(P1=A, a1=90 - a, P2=D, a2=-a_tail);

  ABFE =
    blind ? skewed_rect(
        y1=w / 2,
        y2=w / 2,
        d1=l / 2 + g_shoulder,
        d2=l_tail - l / 2 - g_shoulder / 2,
        a1=a,
        a2=a,
      )
    : [];
  F = ABFE[2];
  E = ABFE[3];

  // EF <-> C
  J = blind ? line_intersect(P1=F, a1=90 - a, P2=C, a2=a_tail) : undef;
  // EF <-> D
  K = blind ? line_intersect(P1=E, a1=90 - a, P2=D, a2=-a_tail) : undef;

  body =
    tail_only ?
      [S, blind ? J : C, blind ? K : D, T]
    : [A, Q, R, B, S, blind ? J : C, blind ? K : D, T];

  waste = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l / 2 + (tail_only ? eps_end : g_shoulder),
    d2=l / 2 + g_shoulder + eps_end,
    a1=a,
    a2=a,
  );

  edge_lines_h = tail_only ? undef : [[S, T]];

  edge_points_v_body = tail_only ? undef : [S, T];

  joint_build(
    t=t,
    body=body,
    waste=waste,
    ratios=[ratio],
    g_cheek=g_cheek,
    r_edge=r_edge,
    d_dowel=d_dowel,
    inner=inner,
    edge_lines_h=edge_lines_h,
    edge_points_v_body=edge_points_v_body,
  );
}

/**
|<------l1--->|                                 |<----l2----->|
.             .                                 .             .
.             .                                 .             .
B-------------C---------------------------------D-------------E     ^
|              \                               /              |     |
|               \                             /               |     |
|                J---------------------------K                |     |
|                 \                         /                 |     |
|                  \           O           /                  |     w
|                   \                     /                   |     |
|                    W                   V                    |     |
|                     \                 /                     |     |
|                      \               /                      |     |
A-------------R---------S-------------T---------U-------------F     -
*/

module dove_socket(
  l = w,
  l1 = l1,
  l2 = l2,
  w = w,
  t = t,
  a = 0,
  a_tail = a_tail,
  l_tail = undef, // length of the tail, < w for blind, ignored when > w
  ratio = 1 / 2, // undef or 0 for all vertical waste
  g_shoulder = g_shoulder_dt, // one to each shoulder, half to blind end
  g_cheek = g_cheek_dt, // half to each cheek
  g_pin = g_pin_dt, // one to each pin
  r_edge = r_edge_dt,
  d_dowel = d_dowel_v,
  inner = false,
) {
  assert(l > 0);
  assert(w > 0);
  assert(t > 0);
  assert(a_tail > 0);
  assert(g_shoulder >= 0);
  assert(g_cheek >= 0);
  assert(g_pin >= 0);
  assert(r_edge >= 0);
  assert(d_dowel >= 0);

  blind = l_tail && l_tail > 0 && l_tail < w;

  ABEF = [
    [-l / 2 - l1, -w / 2],
    [-l / 2 - l1, w / 2],
    [l / 2 + l2, w / 2],
    [l / 2 + l2, -w / 2],
  ];
  A = ABEF[0];
  B = ABEF[1];
  E = ABEF[2];
  F = ABEF[3];

  // no gap for RCDU
  RCDU_no_gap = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l / 2,
    d2=l / 2,
    a1=-a,
    a2=-a,
  );
  C_no_gap = RCDU_no_gap[1];
  D_no_gap = RCDU_no_gap[2];

  // DT <-> O
  V = line_intersect(P1=D_no_gap, a1=90 + a - a_tail, P2=[0, 0], a2=-a_tail + a);
  dOV = sqrt(V[0] ^ 2 + V[1] ^ 2) + g_pin;

  // CS <-> O
  W = line_intersect(P1=C_no_gap, a1=90 + a + a_tail, P2=[0, 0], a2=a_tail + a);
  dOW = sqrt(W[0] ^ 2 + W[1] ^ 2) + g_pin;

  SJKT = skewed_rect(
    y1=blind ? (l_tail - w / 2) + g_shoulder / 2 : w / 2,
    y2=w / 2,
    d1=dOW,
    d2=dOV,
    a1=-a - a_tail,
    a2=-a + a_tail,
  );
  S = SJKT[0];
  J = SJKT[1];
  K = SJKT[2];
  T = SJKT[3];

  body = [A, B, E, F];

  waste = [S, J, K, T];

  edge_lines_h = [
    [S, J],
    [K, T],
    blind ? [J, K] : undef,
  ];

  edge_points_v_waste = blind ? [J, K] : undef;

  joint_build(
    t=t,
    body=body,
    waste=waste,
    ratios=[ratio],
    g_cheek=g_cheek,
    r_edge=r_edge,
    d_dowel=d_dowel,
    inner=inner,
    edge_lines_h=edge_lines_h,
    edge_points_v_waste=edge_points_v_waste,
  );
}
