include <BOSL2/std.scad>

face = [47.7, 28.3, 2.7];
body = [44.3, 25, 14];
t_rib = 0.9;

dx_rib_x = 3; // from body
l_rib_x = 1;

dy_rib_y = 3.5; // from body
l_rib_y = 0.85;

w_clip = 6;
clip_poly = [
  // from body side
  [5, 0],
  [11.5, 0],
  [8.5, 1.8],
];

gap_shroud_x = 1.50;
gap_shroud_y = l_rib_x;

z_front = 4.0;
dxy_front = 5.0; // from face
rounding_front = 1.6;

z_shroud = 6;
dxy_shroud = 3.5; // from face
rounding_shroud = rounding_front;

$fn = 200;

front = [body.x + dxy_front * 2, body.y + dxy_front * 2, z_front];
front_inner = [body.x + 2 * gap_shroud_x, body.y + 2 * l_rib_x, front.z];

shroud = [front.x, front.y, z_shroud];
shroud_inner = [shroud.x - 2 * dxy_shroud, shroud.y - 2 * dxy_shroud, shroud.z];

module model() {

  translate(v=[0, 0, body.z / 2]) {
    color(c="orange")
      cube(size=body, center=true);
    translate(v=[0, 0, (body.z + face.z) / 2]) {
      color(c="pink")
        cube(size=face, center=true);
    }

    color(c="green") {
      for (i = [-1, 1], j = [-1, 1]) {
        translate(v=[i * ( ( -body.x + t_rib) / 2 + dx_rib_x), j * ( -body.y - l_rib_x) / 2, 0])
          cube(size=[t_rib, l_rib_x, body.z], center=true);
      }
    }

    color(c="blue") {
      for (i = [-1, 1], j = [-1, 1]) {
        translate(v=[i * ( -body.x - l_rib_y) / 2, j * ( ( -body.y + t_rib) / 2 + dy_rib_y), 0])
          cube(size=[l_rib_y, t_rib, body.z], center=true);
      }
    }
  }

  color(c="violet") {
    for (i = [-1, 1]) {
      translate(v=[-i * body.x / 2, 0, 0])
        rotate(a=i * 90, v=[0, 0, 1])
          rotate(a=-90, v=[0, 1, 0])
            linear_extrude(h=w_clip, center=true)
              polygon(clip_poly);
    }
  }
}

module shroud() {
  translate(v=[0, 0, body.z - front.z / 2]) {
    color(c="firebrick") {
      difference() {
        cuboid(
          size=front,
          rounding=rounding_front,
          except=BOTTOM,
        );
        cuboid(
          size=front_inner,
        );
      }
    }
  }
  translate(v=[0, 0, ( -shroud.z) / 2 + body.z - front.z])
    color(c="tomato")
      difference() {
        cuboid(
          size=shroud,
          rounding=rounding_shroud,
          except=[TOP, BOTTOM],
        );
        cuboid(
          size=shroud_inner,
          chamfer=min((shroud_inner.x - front_inner.x), (shroud_inner.y - front_inner.y)) / 2,
          except=[BOTTOM],
        );
      }
}

render() {
  // intersection() 
  {
    // model();
    shroud();
  }
}
