test_geom = false;

// distance between two points
function line_distance(A, B = [0, 0]) = sqrt((B[0] - A[0]) ^ 2 + (B[1] - A[1]) ^ 2);

// angle from x axis between two points
function line_angle(A, B) = B[1] == A[1] ? 0 : atan((B[1] - A[1]) / (B[0] - A[0]));

// round a point
function point_round(P) = [round(P[0]), round(P[1])];

// multiply scalar elements in two vectors
function vector_multiply_vector(v1, v2) = [for (i = [0:1:len(v1) - 1]) (v1[i] * v2[i])];

// multiply vector contents by a scalar
function vector_multiply_scalar(v, n) = [for (i = [0:1:len(v) - 1]) v[i] * n];

// add a scalar to vector contents
function vector_add_scalar(v, n) = [for (i = [0:1:len(v) - 1]) v[i] + n];

// sum of contents
function vector_sum(v, i = 0) = i < len(v) ? v[i] + vector_sum(v, i + 1) : 0;

// round all elements in a vecton to nearest
function vector_round_nearest(v, dv) = [ for (i = [0:1:len(v) - 1]) round(v[i] / dv[i]) * dv[i], ];

// round a number to nearest
function round_nearest(n, dn) = round(n / dn) * dn;

// chord straight length
function chord_len(a, r) = r * 2 * sin(a/2);

// chord angle from radius
function chord_angle(c, r) = 2 * asin(c / (2 * r));

// radius from chord
function chord_radius(a, c) = c / (2 * sin(a/2));

// arc from radius
function arc_len(a, r) = 2 * r * sin(a / 2);

// arc angle from radius
function arc_angle(l, r) = l * 360 / (2 * PI * r);

// radius from arc
function arc_radius(a, l) = l * 360 / (2 * PI * a);

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

// Intersection point of two lines specified by point and angle
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

// Centre of a circle given a chord and radius
// https://math.stackexchange.com/questions/1781438/finding-the-center-of-a-circle-given-two-points-and-a-radius-algebraically
function circle_centre(A, B, r) =
  let (
    // midpoint
    M = (A + B) / 2,

    // chord vector
    t = B - A,

    // chord vector length
    t_ = line_distance(t, [0, 0]),

    // normal vector of the chord
    n = [B[1] - A[1], A[0] - B[0]],

    // normal vector length
    n_ = line_distance(n),

    // distance of midpoint to centre
    h = sqrt(r ^ 2 - t_ ^ 2 / 4),

    // solution 1
    c1 = M + vector_multiply_scalar(n, h / n_),

    // solution 2
    c2 = M - vector_multiply_scalar(n, h / n_),
  ) [c1, c2];

// white cylinder marking a point, text size based on r
module point_marker(P, r, h, t) {
  color(c="white") {
    translate(v=P) {
      cylinder(h=h, r=r, center=false);

      translate(v=[0, 0, h])
        linear_extrude(h=r)
          text(size=r * 10, text=t);
    }
  }
}

if (test_geom) {
  echo("TEST circle_centre");

  c_actual = circle_centre([1, 2], [3, 1], 2);
  echo(c_actual=c_actual);

  c_expect = [
    [
      2 - sqrt(11) / (2 * sqrt(5)),
      3 / 2 - sqrt(11) / sqrt(5),
    ],
    [
      2 + sqrt(11) / (2 * sqrt(5)),
      3 / 2 + sqrt(11) / sqrt(5),
    ],
  ];
  echo(c_expect=c_expect);

  assert(c_actual == c_expect);
}
