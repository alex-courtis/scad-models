include <BOSL2/std.scad>

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

$fn = 200;

/* [What] */
test = "dovetail"; // ["none", "mt", "halving", "dovetail", "stool"]
model = 0; // [0:1:8]

/* [General Dimensions] */

// x
l1 = 12; // [0:1:500]
l2 = 12; // [0:1:500]
// y
w = 15; // [0:1:500]
// z
d = 10; // [0:1:500]

/* [Finishing] */

// 0 for no edges
r_edge = 0.20; // [0:0.001:2]

// 0 for no dowel
d_dowel = 2.30; // [0:0.05:5]

/* [Halving] */
a_halving = 0; // [-50:0.5:50]
g_shoulder_halving = 0.025; // [0:0.001:2]
g_cheek_halving = 0.1; // [0:0.001:2]

/* [Mortise And Tenon] */
a_mortise = -8; // [-50:0.5:50]
a_tenon = 8; // [-50:0.5:50]
g_shoulder_mt = 0.1; // [0:0.001:2]
g_cheek_mt = 0.1; // [0:0.001:2]
g_side_mt = 0.1; // [0:0.001:2]
l_tenon = 0; // [0:1:30]

/* [Dovetail] */
a_dt = 0; // [-50:0.5:50]
a_tail = 10; // [0:0.5:30]
g_shoulder_dt = 0.04; // [0:0.001:2]
g_cheek_dt = 0.08; // [0:0.001:2]
g_pin_dt = 0.003; // [0:0.001:2]
ratio_dt = 0.5; // [0:0.05:1]
l_tail = 0; // [0:1:30]
inner_dt = true;

/* [Tuning] */
show_wastes = false;
explode_z = 0; // [0:1:100]

// accept large epsilon needed exposed joint when a != 0
EPS_END = 2; // [0:1:100]

/**
Render a generic joint centred at origin.
Entire body is z extruded and wasted out.
xy line segments capped with spheres specified by edge_lines_h are removed from each layer
z cylinders capped with spheres specified by edge_points_v are removed from waste and body layers
*/
module joint_render(
  d, // total z
  body, // poly to render
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
  // accept that a small epsilon is needed to ensure the sphere intersects with the cylinder cleanly
  module edge_line(l) {
    #if(l[0] && l[1]) {
      extrude_from_to(pt1=l[0], pt2=l[1])
        circle(r=r_edge);
      translate(v=l[0])
        sphere(r=r_edge * 1.005);
      translate(v=l[1])
        sphere(r=r_edge * 1.005);
    }
  }

  // remove inner vertical edges
  // these will intersect with the spheres from the horizontals
  module edge_point(p, h) {
    #if(p) {
      translate(v=p)
        cylinder(r=r_edge, h=h);
      translate(v=p)
        sphere(r=r_edge);
      translate(v=[0, 0, h])
        translate(v=p)
          sphere(r=r_edge);
    }
  }

  module waste(h, center) {
    if (show_wastes)
      #linear_extrude(h=h, center=center)
        polygon(waste);
    else
      linear_extrude(h=h, center=center)
        polygon(waste);
  }

  // material/waste bottom up from origin
  module waste_layers() {
    im = inner ? 1 : -1;
    dzs = [
      -d / 2,
      for (i = [0:1:len(ratios) - 1]) -d / 2 + ratios[i] * d + (i % 2 == 0 ? im : -im) * g_cheek / 2,
      d / 2,
    ];

    // material/waste heights
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
            edge_line(l=l);

        if (r_edge && edge_points_v_waste && wasting)
          for (p = edge_points_v_waste)
            edge_point(p=p, h=zs[i]);

        if (r_edge && edge_points_v_body && !wasting)
          for (p = edge_points_v_body)
            edge_point(p=p, h=zs[i]);
      }
  }

  difference() {

    // entire body
    linear_extrude(h=d, center=true)
      polygon(body);

    // maybe waste
    if (waste_scope == "all") {
      waste(h=d, center=true);
    } else if (waste_scope == "layers") {
      waste_layers();
    }

    // centred dowel
    if (d_dowel) {
      cylinder(d=d_dowel, h=d, center=true);
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

// print with cheek facing up
module halving(
  l = w,
  l1 = l1,
  l2 = l2,
  w = w,
  d = d,
  a = 0,
  ratio = 1 / 2,
  ratios = undef, // overrides ratio
  g_shoulder = g_shoulder_halving, // one to each shoulder
  g_cheek = g_cheek_halving, // half to each cheek
  r_edge = r_edge,
  d_dowel = d_dowel,
  inner = false,
) {

  // when not l1 or l2, body extends to the side of the joint, without g_shoulder
  body = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l1 ? (l / 2 + l1) : l / 2,
    d2=l2 ? (l / 2 + l2) : l / 2,
    a1=l1 ? 0 : a,
    a2=l2 ? 0 : a,
  );

  waste = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l / 2 + g_shoulder,
    d2=l / 2 + g_shoulder,
    a1=a,
    a2=a,
  );

  edge_lines_h = [
    l1 ? [waste[0], waste[1]] : undef,
    l2 ? [waste[2], waste[3]] : undef,
  ];

  joint_render(
    d=d,
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
  l = w, // depth of the slot
  l1 = l1,
  l2 = 0,
  w = w,
  d = d,
  a = a_tenon,
  l_tenon = l_tenon, // length of the tenon, < l for blind, > l for exposed, ignored when l2 > 0
  ratio = 1 / 3, // of the tenon, centred
  ratios = undef, // overrides ratio
  g_shoulder = g_shoulder_mt, // one to each shoulder, half to blind end
  g_cheek = g_cheek_mt, // half to each cheek
  r_edge = r_edge,
  d_dowel = d_dowel,
  inner = true,
) {
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
    l1 == 0 ? d1_body + EPS_END
    : l / 2 + g_shoulder;

  d2_waste =
    exposed ? d2_body + EPS_END
    : l2 == 0 ? d2_body + EPS_END
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

  joint_render(
    d=d,
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
  l = w, // width of the tenon
  l1 = l1,
  l2 = l2,
  w = w,
  d = d,
  a = a_mortise,
  l_tenon = l_tenon, // length of the tenon, set to less than w for blind
  ratio = 1 / 3, // of the slot, centred
  ratios = undef, // overrides ratio
  g_shoulder = g_shoulder_mt, // half to blind end
  g_cheek = g_cheek_mt, // half to each cheek
  g_side = g_side_mt, // one to each side
  r_edge = r_edge,
  d_dowel = d_dowel,
  inner = false,
) {
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
    l1 == 0 ? l / 2 + EPS_END
    : l / 2 + g_side;

  d2_waste =
    l2 == 0 ? l/2 + EPS_END
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

  joint_render(
    d=d,
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
  l = w, // depth of the socket
  l1 = l1,
  w = w,
  d = d,
  a = a_dt, // RBA
  a_tail = a_tail, // BSC
  l_tail = l_tail, // length of the tail, < l for blind, ignored when > l
  ratio = ratio_dt, // undef or 0 for no vertical waste
  g_shoulder = g_shoulder_dt, // one to each shoulder, half to blind end
  g_cheek = g_cheek_dt, // half to each cheek
  r_edge = r_edge,
  d_dowel = d_dowel,
  inner = inner_dt,
) {
  blind = l_tail && l_tail > 0 && l_tail < l;

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
  B = QRBA[2];
  A = QRBA[3];

  ABCD = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l / 2 + g_shoulder,
    d2=l / 2,
    a1=a,
    a2=a,
  );
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
    blind ?
      [A, Q, R, B, S, J, K, T]
    : [A, Q, R, B, S, C, D, T];

  waste = skewed_rect(
    y1=w / 2,
    y2=w / 2,
    d1=l / 2 + g_shoulder,
    d2=l / 2 + g_shoulder + EPS_END,
    a1=a,
    a2=a,
  );

  joint_render(
    d=d,
    body=body,
    waste=waste,
    ratios=[ratio],
    g_cheek=g_cheek,
    r_edge=r_edge,
    d_dowel=d_dowel,
    inner=inner,
    edge_lines_h=[[S, T]],
    edge_points_v_body=[S, T],
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
  l1 = l1, // l1 and l2 must be nonzero
  l2 = l2,
  w = w,
  d = d,
  a = a_dt,
  a_tail = a_tail,
  l_tail = l_tail, // length of the tail, < w for blind, ignored when > w
  ratio = ratio_dt, // undef or 0 for no vertical waste
  g_shoulder = g_shoulder_dt, // one to each shoulder, half to blind end
  g_cheek = g_cheek_dt, // half to each cheek
  g_pin = g_pin_dt, // one to each pin
  r_edge = r_edge,
  d_dowel = d_dowel,
  inner = !inner_dt,
) {
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

  joint_render(
    d=d,
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

render() {
  if (test == "halving") {
    halving_test();
  } else if (test == "dovetail") {
    dove_test();
  } else if (test == "stool") {
    stool();
  } else if (test == "mt") {
    mt_test();
  }
}

module dove_test() {

  a = a_dt + 7;
  a_tail = a_tail + 3;

  l_socket = w + 3;
  w_socket = w - 1;

  l1_tail = l1;
  l_tail = w_socket * 5 / 7;

  l1_socket = l1 / 2;
  l2_socket = l2 / 2;

  dx = l1_socket + l2_socket + l_socket;

  all = model == 0;

  if (all || model == 1) {
    translate(v=[0 * dx, 0, 0]) {
      color(c="orange")
        translate(v=[0, 0, explode_z])
          rotate(a=90 + a_dt)
            dove_tail(a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail);

      color(c="wheat")
        dove_socket(a_tail=a_tail, l=l_socket, w=w_socket, l1=l1_socket, l2=l2_socket);
    }
  }

  if (all || model == 2)
    translate(v=[1 * dx, 0, 0]) {
      color(c="burlywood")
        translate(v=[0, 0, explode_z])
          rotate(a=90 + a)
            dove_tail(a=a, a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail);

      color(c="sienna")
        dove_socket(a=a, a_tail=a_tail, l=l_socket, w=w_socket, l1=l1_socket, l2=l2_socket);
    }

  if (all || model == 3)
    translate(v=[2 * dx, 0, 0]) {
      color(c="chocolate")
        translate(v=[0, 0, explode_z])
          rotate(a=90 + a_dt)
            dove_tail(a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail, l_tail=l_tail);

      color(c="rosybrown")
        dove_socket(a_tail=a_tail, l=l_socket, w=w_socket, l_tail=l_tail, l1=l1_socket, l2=l2_socket);
    }

  if (all || model == 4)
    translate(v=[3 * dx, 0, 0]) {
      color(c="wheat")
        translate(v=[0, 0, explode_z])
          rotate(a=90 + a)
            dove_tail(a=a, a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail, l_tail=l_tail);

      color(c="maroon")
        dove_socket(a=a, a_tail=a_tail, l=l_socket, w=w_socket, l_tail=l_tail, l1=l1_socket, l2=l2_socket);
    }

  if (all || model == 5)
    translate(v=[4 * dx, 0, 0]) {
      ratio = 0;
      d_dowel = 0;
      color(c="sandybrown")
        translate(v=[0, 0, explode_z])
          rotate(a=90 + a_dt)
            dove_tail(a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail, l_tail=l_tail, ratio=0, d_dowel=d_dowel);

      color(c="brown")
        dove_socket(a_tail=a_tail, l=l_socket, w=w_socket, l_tail=l_tail, ratio=0, d_dowel=d_dowel, l1=l1_socket, l2=l2_socket);
    }

  if (all || model == 6)
    translate(v=[5 * dx, 0, 0]) {
      ratio = 0;
      d_dowel = 0;
      color(c="bisque")
        translate(v=[0, 0, explode_z])
          rotate(a=90 + a)
            dove_tail(a=a, a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail, l_tail=l_tail, ratio=ratio, d_dowel=d_dowel);

      color(c="darkgoldenrod")
        dove_socket(a=a, a_tail=a_tail, l=l_socket, w=w_socket, l_tail=l_tail, ratio=ratio, l1=l1_socket, l2=l2_socket);
    }

  if (all || model == 7)
    translate(v=[4 * dx, 30, 0]) {
      ratio = 0;
      d = 60;
      w_socket = w_socket / 2;
      l_tail = w_socket / 2;
      d_dowel = 0;
      color(c="sandybrown")
        translate(v=[0, 0, explode_z])
          rotate(a=90 + a_dt)
            dove_tail(a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail, l_tail=l_tail, ratio=ratio, d_dowel=d_dowel, d=d);

      color(c="brown")
        dove_socket(a_tail=a_tail, l=l_socket, w=w_socket, l_tail=l_tail, ratio=ratio, d_dowel=d_dowel, d=d, l1=l1_socket, l2=l2_socket);
    }

  if (all || model == 8)
    translate(v=[5 * dx, 60, 0]) {
      ratio = 0;
      d = 60;
      w_socket = w_socket / 2;
      l_tail = w_socket / 2;
      d_dowel = 0;
      color(c="bisque")
        translate(v=[0, 0, explode_z])
          rotate(a=90 + a)
            dove_tail(a=a, a_tail=a_tail, l=w_socket, w=l_socket, l1=l1_tail, l_tail=l_tail, ratio=ratio, d_dowel=d_dowel, d=d);

      color(c="darkgoldenrod")
        dove_socket(a=a, a_tail=a_tail, l=l_socket, w=w_socket, l_tail=l_tail, ratio=ratio, d_dowel=d_dowel, d=d, l1=l1_socket, l2=l2_socket);
    }
}

module halving_test() {
  a = 8;

  color(c="sienna")
    halving(
      a=a,
    );

  color(c="orange")
    rotate(a=90 - a)
      halving(
        a=-a,
        inner=true,
      );
}

module mt_test() {
  all = model == 0;

  w_tenon = w;
  d_tenon = d;

  w_mortise = w;
  l_mortise = w;

  dx = 50;

  if (all || model == 1) {
    color(c="sienna")
      translate(v=[0, 0, explode_z])
        tenon(
          w=w_tenon,
          d=d_tenon,
          l=w_mortise,
          l1=l1,
          l2=0
        );
    color(c="orange")
      rotate(a=90 + a_mortise)
        mortise(
          w=w_mortise,
          d=d_tenon,
          l=l_mortise,
          l1=l1,
          l2=l2
        );
  }

  if (all || model == 2) {
    translate(v=[1 * dx, 0, 0]) {
      color(c="sienna")
        translate(v=[0, 0, explode_z])
          tenon(
            w=w_tenon,
            d=d_tenon,
            l=w_mortise,
            l1=0,
            l2=l2
          );
      color(c="orange")
        rotate(a=90 + a_mortise)
          mortise(
            w=w_mortise,
            d=d_tenon,
            l=l_mortise,
            l1=l1,
            l2=l2
          );
    }
  }

  if (all || model == 3) {
    translate(v=[2 * dx, 0, 0]) {
      color(c="tan")
        translate(v=[0, 0, explode_z])
          tenon(
            w=w_tenon,
            d=d_tenon,
            l=w_mortise,
            l1=l1,
            l2=l2,
          );
      color(c="chocolate")
        rotate(a=90 + a_mortise)
          mortise(
            w=w_mortise,
            d=d_tenon,
            l=l_mortise,
            l1=l1,
            l2=0
          );
    }
  }

  if (all || model == 4) {
    translate(v=[3 * dx, 0, 0]) {
      color(c="tan")
        translate(v=[0, 0, explode_z])
          tenon(
            w=w_tenon,
            d=d_tenon,
            l=w_mortise,
            l1=l1,
            l2=l2,
          );
      color(c="chocolate")
        rotate(a=90 + a_mortise)
          mortise(
            w=w_mortise,
            d=d_tenon,
            l=l_mortise,
            l1=0,
            l2=l2,
          );
    }
  }

  if (all || model == 5) {
    translate(v=[4 * dx, 0, 0]) {
      color(c="sandybrown")
        translate(v=[0, 0, explode_z])
          tenon(
            w=w_tenon,
            d=d_tenon,
            l=w_mortise,
            l1=l1,
            l2=0,
            l_tenon=10,
          );
      color(c="brown")
        rotate(a=90 + a_mortise)
          mortise(
            w=w_mortise,
            d=d_tenon,
            l=l_mortise,
            l1=0,
            l2=l2,
            l_tenon=10,
          );
    }
  }

  if (all || model == 6) {
    translate(v=[5 * dx, 0, 0]) {
      color(c="sandybrown")
        translate(v=[0, 0, explode_z])
          tenon(
            w=w_tenon,
            d=d_tenon,
            l=w_mortise,
            l1=l1,
            l2=0,
            l_tenon=10,
          );
      color(c="brown")
        rotate(a=90 + a_mortise)
          mortise(
            w=w_mortise,
            d=d_tenon,
            l=l_mortise,
            l1=l1,
            l2=0,
            l_tenon=10,
          );
    }
  }
}

module stool() {
  w_cross = 25;
  d_cross = 17;

  w_leg = 22;
  d_leg = d_cross;
  d1_leg_cap = 2;
  dx_leg_cap = w_cross - 5.5;

  a_tenon = 8;
  a_cross = 8;

  l12_halving = 5;
  l1_tenon = 8;
  l2_tenon = 5;
  l2_leg = 75;
  l1_mortise = 5;

  d_top = 125;
  h_top = 2.6;

  d_dowel = d_dowel;

  show_leg = true;
  show_top = true;
  show_half1 = true;
  show_half2 = true;
  show_half3 = true;
  show_half4 = true;
  dowels = true;

  dx = d_cross / 2 + l12_halving + w_leg / 2 + l1_tenon;

  module leg(a, blind, l1 = 0, ratio = 1 / 3, ratios = undef) {

    rotate(-90 - a) {
      difference() {
        mortise(a=-a, w=w_leg, d=d_cross, l=w_cross, l1=l1, l2=l2_leg + w_cross / 2, l_tenon=blind, ratio=ratio, ratios=ratios);

        translate(v=[l2_leg + w_cross, 0, 0])
          rotate(a)
            cube([w_cross, w_leg * 2, d_cross], center=true);
      }
    }
  }

  module half1() {

    // cross
    color(c="peru")
      rotate(a=-90, v=[1, 0, 0])
        halving(a=a_cross, d=w_cross, w=d_cross, l=d_cross, l1=l12_halving, l2=l12_halving, inner=false);

    // normal leg
    translate(v=[dx, 0, 0]) {
      color(c="chocolate")
        tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=-a_tenon);
    }

    // tee leg
    translate(v=[-dx, 0, 0]) {
      color(c="saddlebrown")
        mirror(v=[1, 0, 0])
          tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=l2_tenon);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=a_tenon);
    }
  }

  module half2() {

    // cross
    color(c="burlywood")
      rotate(a=90, v=[1, 0, 0])
        halving(a=a_cross, w=d_cross, d=w_cross, l=d_cross, l1=l12_halving, l2=l12_halving);

    // mortise leg
    translate(v=[dx, 0, 0]) {
      color(c="sienna")
        tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0);

      if (show_leg)
        color(c="orange")
          leg(a=-a_tenon);
    }

    // blind leg
    translate(v=[-dx, 0, 0]) {
      color(c="rosybrown")
        mirror(v=[1, 0, 0])
          tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0, l_tenon=w_leg * 0.75);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=a_tenon, blind=w_leg * 0.75);
    }
  }

  module half3() {

    // cross
    color(c="peru")
      rotate(a=-90, v=[1, 0, 0])
        halving(a=a_cross, d=w_cross, w=d_cross, l=d_cross, l1=l12_halving, l2=l12_halving, inner=false);

    // fat tenon leg
    translate(v=[dx, 0, 0]) {
      color(c="chocolate")
        tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0, ratio=1 / 2);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=-a_tenon, ratio=1 / 2);
    }

    // full blind leg
    translate(v=[-dx, 0, 0]) {
      color(c="saddlebrown")
        mirror(v=[1, 0, 0])
          tenon(a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0, l_tenon=w_leg * 0.75);

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(a=a_tenon, blind=w_leg * 0.75);
    }
  }

  module half4() {

    // cross
    color(c="burlywood")
      rotate(a=90, v=[1, 0, 0])
        halving(a=a_cross, w=d_cross, d=w_cross, l=d_cross, l1=l12_halving, l2=l12_halving);

    // double mortise leg
    translate(v=[dx, 0, 0]) {
      color(c="sienna")
        tenon(
          a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0,
          ratios=[1 / 5, 2 / 5, 3 / 5, 4 / 5],
        );

      if (show_leg)
        color(c="orange")
          leg(
            a=-a_tenon,
            ratios=[1 / 5, 2 / 5, 3 / 5, 4 / 5],
          );
    }

    // double tenon leg
    translate(v=[-dx, 0, 0]) {
      color(c="rosybrown")
        mirror(v=[1, 0, 0])
          tenon(
            a=-a_tenon, w=w_cross, d=d_cross, l=w_leg, l1=l1_tenon, l2=0, l_tenon=w_leg * 1.75,
            ratios=[1 / 5, 2 / 5, 3 / 5, 4 / 5],
          );

      if (show_leg)
        color(c="orange")
          translate(v=[0, 0, 0])
            leg(
              a=a_tenon,
              ratios=[1 / 5, 2 / 5, 3 / 5, 4 / 5],
            );
    }
  }

  difference() {
    union() {

      // top
      if (show_top) {
        color(c="wheat")
          translate(v=[0, (w_cross + h_top) / 2 + g_cheek_halving, 0])
            rotate(a=90, v=[1, 0, 0])
              cylinder(d=d_top, h=h_top, center=true);
      }
      if (show_half1)
        half1();

      if (show_half2)
        rotate(a=-90 - a_cross, v=[0, 1, 0])
          half2();

      if (show_half3)
        translate(v=[0, 70, 0])
          mirror(v=[0, 1, 0])
            half3();

      if (show_half4)
        translate(v=[0, 70, 0])
          mirror(v=[0, 1, 0])
            rotate(a=-90 - a_cross, v=[0, 1, 0])
              half4();
    }

    // dowels
    if (dowels) {
      x_dowel = d_cross / 2 + l12_halving + l1_tenon + w_leg / 2;
      l_dowel = w_cross * 1.5;

      rotate(a=90, v=[1, 0, 0]) {
        translate(v=[x_dowel, 0, 0])
          cylinder(d=d_dowel, h=l_dowel, center=true);

        translate(v=[-x_dowel, 0, 0])
          cylinder(d=d_dowel, h=l_dowel, center=true);

        rotate(a=a_cross)
          translate(v=[0, x_dowel, 0])
            cylinder(d=d_dowel, h=l_dowel, center=true);

        rotate(a=a_cross)
          translate(v=[0, -x_dowel, 0])
            cylinder(d=d_dowel, h=l_dowel, center=true);
      }
    }
  }
}
