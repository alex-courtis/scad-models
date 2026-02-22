include <colours.scad>

// test brown pairs
for (i = [0:1:24 / 2 - 1]) {

  pair = brown_pair(i);

  dark = pair[0];
  light = pair[1];

  translate(v=[0, i * 20, 0]) {

    color(c=dark)
      cube([40, 20, 10]);

    translate(v=[-5, 5, 10])
      color(c="white")
        text(str(round(dark[1] * 1000) / 1000), halign="right", size=6);

    translate(v=[40, 0, 0]) {

      color(c=light)
        cube([40, 20, 10]);

      translate(v=[45, 5, 10])
        color(c="white")
          text(str(round(light[1] * 1000) / 1000), halign="left", size=6);
    }
  }
}

// test browns
translate(v=[150, 0, 0]) {
  for (i = [0:1:24 - 1]) {
    c = brown(i);
    dy = i * 20;

    translate(v=[0, dy, 0]) {
      color(c=c)
        cube([40, 20, 10]);

      translate(v=[45, 5, 10])
        color(c="white")
          text(str(round(c[1] * 1000) / 1000), halign="left", size=6);
    }
  }
}

// ordered by colour warmth
WARM_COLOURS = [
  "maroon",
  "darkred",
  "saddlebrown",
  "darkgoldenrod",
  "sienna",
  "brown",
  "firebrick",
  "chocolate",

  "goldenrod",
  "darkorange",
  "orangered",
  "red",
  "orange",
  "peru",
  "indianred",
  "tomato",

  "rosybrown",
  "coral",
  "sandybrown",
  "tan",
  "darksalmon",
  "burlywood",
  "salmon",
  "lightcoral",

  "lightsalmon",
  "wheat",
  "navajowhite",
  "moccasin",
  "peachpuff",
  "bisque",
  "blanchedalmond",
  "antiquewhite",

  "papayawhip",
  "mistyrose",
  "linen",
  "oldlace",
  "seashell",
  "floralwhite",
  "snow",
  "ivory",

  "lightyellow",
  "cornsilk",
  "beige",
  "lemonchiffon",
  "lightgoldenrodyellow",
  "palegoldenrod",
  "khaki",
  "greenyellow",

  "darkkhaki",
  "yellow",
  "gold",
  "yellowgreen",
  "olivedrab",
  "darkolivegreen",
  "olive",
  "darkgreen",
];

COL = [
  "maroon",
  "darkred",
  "firebrick",
  "brown",
  "indianred",
  "saddlebrown",
  "sienna",
  "chocolate",
  "darkorange",
  "orange",
  "peru",
  "darkgoldenrod",
  "goldenrod",
  "sandybrown",
  "rosybrown",
  "tan",
  "burlywood",
  "khaki",
  "palegoldenrod",
  "peachpuff",
  "wheat",
  "navajowhite",
  "moccasin",
  "bisque",
  "blanchedalmond",
  "lemonchiffon",
  "lightgoldenrodyellow",
  "cornsilk",
];

// test web
translate(v=[300, 0, 0]) {
  rows = ceil(len(COL) / 2);
  for (i = [0:1:len(COL) - 1]) {
    row = floor(i / rows);
    col = i % rows;
    c = COL[i];

    dy = col * 20;

    translate(v=[row * 40, dy, 0]) {

      color(c=c)
        cube([40, 20, 10]);

      color(c="white")
        translate(v=[row ? 45 : -5, 5, 0])
          text(c, halign=row ? "left" : "right", size=6);
    }
  }
}
