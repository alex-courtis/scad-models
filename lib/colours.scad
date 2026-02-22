function zero_to_one(n) = min(max(n, 0), 1);

// 24 shades of brown, dark to light
function brown(i) =
  let (
    n = 24, // [4:2:200]
    g_min = 0.15, // [0:0.01:0.5]
    g_max = 0.75, // [0.5:0.01:1]
    dg = 0.056, // [0:0.001:0.5]
    dr = 0.033, // [0:0.001:0.5]
    db = 0.056, // [0:0.001:0.5]

    // green is linear
    g = g_min + i * (g_max - g_min) / (n - 1),

    // skew odds by green alternating sign
    dgreen = (i + 1) % 4 == 0 ?
      -dg
    : (i + 1) % 2 == 0 ?
      dg
    : 0,

    // skew odd/even by red for dark
    dred = i % 2 == 0 ?
      -dr
    : dr,

    // skew odd/even by blue for light
    dblue = i % 2 == 0 ?
      -db
    : db
  )

  (g < 0.5) ?

    // dark half: red twice green, no blue
    [
      zero_to_one(g * 2 + dred),
      zero_to_one(g + dgreen),
      0,
    ]

    // light half, all red with blue 0 to 1
  : [
    1,
    zero_to_one(g + dgreen),
    zero_to_one((g - 0.5) * 2 + dblue),
  ];

// 12 pairs dark/light brown
// consecutive pairs contrast well
function brown_pair(i) =
  let (
    n = 24, // [4:2:200]
    row = i % 2 == 0 ?
      i / 2
    : floor((n / 2 - i) / 2) + i,
  ) [brown(row), brown(n / 2 + row)];
