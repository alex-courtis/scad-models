$fn = 400;

content = "17 Systrum St";
z_base = 2.4;
z_text = 0.8;
dz_text = 1.6;

dx_base = 16;
dy_base = 14;

d_hole_inner = 3;
d_hole_outer = 6.5;
z_hole = 1;

show_plate = true;
show_lettering = false;

font = "Hack Nerd Font Mono";
font_size = 26;

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

module plate() {
  translate(v=[0, 0, 0])
    translate(
      v=[
        text_metrics.position[0] - dx_base / 2,
        text_metrics.position[1] - dy_base / 2,
        0,
      ]
    )
      cube(
        [
          text_metrics.size[0] + dx_base,
          text_metrics.size[1] + dy_base,
          z_base,
        ],
        center=false
      );
}

module lettering() {
  translate(v=[0, 0, dz_text])
    linear_extrude(h=z_text, center=false)
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

render() {
  if (show_plate) {
    difference() {
      color(c="gray")
        plate();
      color(c="red")
        holes();
      color(c="orange")
        lettering();
    }
  }
  if (show_lettering) {
    color(c="white")
      lettering();
  }
}
