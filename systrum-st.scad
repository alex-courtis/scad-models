include <BOSL2/std.scad>

$fn = 400;

show = "all"; // ["all", "plate", "lettering", "outline"]
show_template = false;

shift_left_hole = false;
conical_hole = true;

content = "17 Systrum St";
z_base = 3.2;
z_text = 0.8;

dx_base = 16;
dy_base = 16;

dx_hole = 23.5;

d_hole_inner = 3.5;
d_hole_outer = 8;
z_hole = 2;

dx_left_hole = shift_left_hole ? -d_hole_inner / 2 : 0;
dy_left_hole = shift_left_hole ? d_hole_inner / 2 : 0;

font = "Inter:style=Bold";
font_size = 25;
font_spacing = 1.25;
t_outline = -0.8;

font_metrics = fontmetrics(font=font, size=font_size);
echo(font_metrics=font_metrics);

text_metrics = textmetrics(
  font=font,
  size=font_size,
  spacing=font_spacing,
  text=content,
  valign="center",
  halign="center"
);
echo(text_metrics=text_metrics);
echo(text_metrics_position=text_metrics.position);
echo(text_metrics_size=text_metrics.size);

base_b = [298.753, 47.2707, 3.2];
base_v = [-149.433, -23.6354, 0];

hole_v_left = [-125.741, 0, 0];
hole_v_right = [125.741, 0, 0];

module base() {
  b = [
    text_metrics.size[0] + dx_base,
    text_metrics.size[1] + dy_base,
    z_base,
  ];
  echo("base b", b);

  v = [
    text_metrics.position[0] - dx_base / 2,
    text_metrics.position[1] - dy_base / 2,
    0,
  ];
  echo("base v", v);

  translate(
    v=v,
  ) {
    cuboid(
      b,
      anchor=LEFT + FRONT + BOTTOM,
      rounding=d_hole_outer / 2,
      edges=[
        FRONT + LEFT,
        FRONT + RIGHT,
        BACK + LEFT,
        BACK + RIGHT,
      ]
    );
  }
}

module text_extrude(shell) {
  translate(v=[0, 0, z_base - z_text])
    linear_extrude(h=z_text, center=false)
      shell2d(shell ? -t_outline : -10)
        text(
          font=font,
          size=font_size,
          spacing=font_spacing,
          text=content,
          valign="center",
          halign="center",
        );
}

module holes() {
  x = (text_metrics.size[0] + dx_base) / 2 - dx_hole;
  y = (text_metrics.size[1] + dy_base) / 2;

  if (conical_hole) {
    v_left = [-x + dx_left_hole, dy_left_hole, 0];
    v_right = [x, 0, 0];

    translate(v=v_left)
      cylinder(h=z_base, d1=d_hole_inner, d2=d_hole_outer, center=false);

    translate(v=[x, 0, 0])
      cylinder(h=z_base, d1=d_hole_inner, d2=d_hole_outer, center=false);

    echo("hole v_left", v_left);
    echo("hole v_right", v_right);
  } else {

    h_outer = z_base - z_hole;

    translate(v=[-x, 0, 0]) {
      cylinder(h=h_outer, d=d_hole_inner, center=false);
      translate(v=[0, 0, h_outer])
        cylinder(h=z_hole, d=d_hole_outer, center=false);
    }

    translate(v=[x, 0, 0]) {
      cylinder(h=h_outer, d=d_hole_inner, center=false);
      translate(v=[0, 0, h_outer])
        cylinder(h=z_hole, d=d_hole_outer, center=false);
    }
  }
}

module plate() {
  difference() {
    color(c="red")
      base();

    color(c="orange")
      holes();

    lettering();

    outline();
  }
}

module outline() {
  color(c="black")
    text_extrude(shell=true);
}

module lettering() {
  color(c="green")
    difference() {
      text_extrude(shell=false);
      text_extrude(shell=true);
    }
}

render() {
  if (show == "plate" || show == "all") {
    plate();
  }
  if (show == "outline" || show == "all") {
    outline();
  }
  if (show == "lettering" || show == "all") {
    lettering();
  }

  // from previous models, line up holes
  if (show_template) {
    translate(v=base_v - [0, 0, z_base])
      cube(base_b);
    translate(v=hole_v_left)
      cylinder(d=d_hole_inner, h=z_base * 2);
    translate(v=hole_v_right)
      cylinder(d=d_hole_inner, h=z_base * 2);
  }
}
