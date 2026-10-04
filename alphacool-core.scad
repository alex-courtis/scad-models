include <BOSL2/std.scad>

face = [47.7, 28.3, 2.7];
body = [44.3, 25, 14];
t_rib = 0.9;

dx_rib_x = 3; // from body
l_rib_x = 1;

dy_rib_y = 3.5; // from body
l_rib_y = 0.85;

w_clip = 6;
t_clip = 1.8;
clip_poly = [
  // from body side
  [5, 0],
  [11.5, 0],
  [8.5, t_clip],
];

t_clip_socket = (t_clip - l_rib_y) * 2 / 3;

gap_front_x = l_rib_y;

z_front = 4.25;
dxy_front = 5.0; // from face
rounding_front = 1.6;

gap_sleeve_x = t_clip;

z_sleeve = 6;
dxy_sleeve = 1; // from front
rounding_sleeve = rounding_front;

$fn = 200;

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
  front = [body.x + dxy_front * 2, body.y + dxy_front * 2, z_front];
  front_inner = [body.x + 2 * gap_front_x, body.y + 2 * l_rib_x, front.z];

  sleeve = [front.x, front.y, z_sleeve];
  sleeve_inner = [body.x + 2 * gap_sleeve_x, body.y + 2 * l_rib_x, sleeve.z];

  module mask_clip_socket() {
    for (i = [-1, 1])
      translate(v=[i * (front_inner.x + t_clip_socket) / 2, 0, 0])
        cuboid(size=[t_clip_socket, w_clip, front.z + sleeve.z]);
  }

  color(c="firebrick") {
    translate(v=[0, 0, body.z - front.z / 2]) {
      difference() {
        cuboid(
          size=front,
          rounding=rounding_front,
          except=BOTTOM,
        );
        cuboid(
          size=front_inner,
        );
        mask_clip_socket();
      }
    }
  }

  color(c="tomato") {
    translate(v=[0, 0, ( -sleeve.z) / 2 + body.z - front.z]) {
      difference() {
        cuboid(
          size=sleeve,
          rounding=rounding_sleeve,
          except=[TOP, BOTTOM],
        );
        cuboid(
          size=sleeve_inner,
          chamfer=(sleeve_inner.x - front_inner.x) / 2,
          edges=[
            TOP + LEFT,
            TOP + RIGHT,
          ],
        );
        mask_clip_socket();
      }
    }
  }
}

render() {
  // intersection() 
  {
    // model();
    shroud();
  }
}
