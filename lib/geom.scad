test_geom = false;

// distance between two points
function line_distance(A, B = [0, 0]) = sqrt((B[0] - A[0]) ^ 2 + (B[1] - A[1]) ^ 2);

// angle from x axis between two points
function line_angle(A, B) = B[1] == A[1] ? 0 : atan((B[1] - A[1]) / (B[0] - A[0]));

// round a point
function point_round(P) = [round(P[0]), round(P[1])];

// multiply a point by a scalar
function point_multiply(V, n) = [V[0] * n, V[1] * n];

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
    c1 = M + point_multiply(n, h / n_),

    // solution 2
    c2 = M - point_multiply(n, h / n_),
  ) [c1, c2];

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
