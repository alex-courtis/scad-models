include <BOSL2/std.scad>

$fn = 400;

show = "all"; // ["all", "plate", "lettering", "outline"]

shift_left_hole = false;
conical_hole = true;

content = "17 Systrum St";
z_base = 3.2;
z_text = 0.8;

dx_base = 11;
dy_base = 11;

d_hole_inner = 3.5;
d_hole_outer = 8;
z_hole = 2;

dx_left_hole = shift_left_hole ? -d_hole_inner / 2 : 0;
dy_left_hole = shift_left_hole ? d_hole_inner / 2 : 0;

// TODO variable width font
font = "Hack Nerd Font Mono:style=Bold";
font_size = 27;
t_outline = -0.8;

font_metrics = fontmetrics(font=font, size=font_size);
echo(font_metrics=font_metrics);

text_metrics = textmetrics(
  font=font,
  size=font_size,
  text=content,
  valign="center",
  halign="center"
);
echo(text_metrics=text_metrics);
echo(text_metrics_position=text_metrics.position);
echo(text_metrics_size=text_metrics.size);

module base() {
  translate(v=[0, 0, 0])
    translate(
      v=[
        text_metrics.position[0] - dx_base / 2,
        text_metrics.position[1] - dy_base / 2,
        0,
      ]
    ) {
      cuboid(
        [
          text_metrics.size[0] + dx_base,
          text_metrics.size[1] + dy_base,
          z_base,
        ],
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
          text=content,
          valign="center",
          halign="center",
        );
}

module holes() {
  y = (text_metrics.size[1] + dy_base) / 2;
  x = (text_metrics.size[0] + dx_base) / 2 - y;

  if (conical_hole) {

    translate(v=[-x + dx_left_hole, dy_left_hole, 0])
      cylinder(h=z_base, d1=d_hole_inner, d2=d_hole_outer, center=false);

    translate(v=[x, 0, 0])
      cylinder(h=z_base, d1=d_hole_inner, d2=d_hole_outer, center=false);
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
}
