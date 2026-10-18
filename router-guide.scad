include <BOSL2/std.scad>
include <lib/colours.scad>

// bottom half only
side = [180, 90, 12];

template = [side.x * 1.5, side.y * 2 * 1.5, 20];

// TODO channel width must be a consistent side_channel_t
side_eccentricity = 0.85;

fork_r = 50;
fork_eccentricity = 0.8;

side_rounding = side.z / 3;
side_channel_t = 4;

template_channel_t = 10;

// from side
channel_inset = 10;
channel_d = 6;

side_channel_bottom_l = side.x * 2 / 3;

$fn = 200;

module mask_channels(t, d) {

  module top() {
    or = side.x / 2 - channel_inset + t / 2;
    ir = or - t;
    back_half(s=side.x * 2) {
      scale(v=[1, side_eccentricity]) {
        tube(or=or, ir=ir, l=d);
      }
    }
  }

  module front() {
    l = side.y;
    translate(v=[side.x / 2 - channel_inset, -l / 2, 0])
      cuboid(size=[t, l, d]);
  }

  module back() {
    difference() {
      l = side.y - channel_inset - t;
      translate(v=[-side.x / 2 + channel_inset, -l / 2, 0])
        cuboid(size=[t, l, d]);

      x = fork_r * fork_eccentricity;;y = fork_r;
      translate(
        v=[
          -side.x / 2 + x / 2 + channel_inset - t / 2,
          -side.y + y / 2 + channel_inset - t / 2,
          0,
        ]
      )
        cuboid(size=[x, y, d]);
    }
  }

  module bottom() {
    dx = ( -side.x + side_channel_bottom_l) / 2;
    dy = -side.y + channel_inset + (t / fork_eccentricity - t) / 2;
    translate(v=[dx, dy, 0])
      // hack to make the channels line up
      cuboid(size=[side_channel_bottom_l, t / fork_eccentricity, d]);
  }

  module fork() {
    or = fork_r;
    // hack to make the channels line up
    ir = or - t / fork_eccentricity;
    inset = channel_inset - t / 2;
    dx = -side.x / 2 + or * fork_eccentricity + inset;
    dy = -side.y + or + inset;

    translate(v=[dx, dy, 0])
      front_half(s=side.x * 2)
        left_half(s=side.x * 2)
          scale(v=[fork_eccentricity, 1])
            tube(or=or, ir=ir, l=d);
  }

  translate(v=[0, 0, side.z - d / 2]) {
    top();
    front();
    bottom();
    back();
    fork();
  }
}

module side(t, rounding) {

  module body() {
    translate(v=[0, 0, side.z / 2]) {
      back_half(s=side.x * 2) {
        scale(v=[1, side_eccentricity]) {
          cyl(
            d=side.x, l=side.z,
            rounding=rounding,
          );
        }
      }

      translate(v=[0, -side.y / 2, 0])
        cuboid(
          size=[side.x, side.y, side.z],
          rounding=rounding,
          except=[BACK],
        );
    }
  }

  difference() {
    color(brown_pair(0)[0])
      body();
    color(c=brown_pair(0)[1])
      mask_channels(t=t, d=channel_d);
  }
}

module template() {

  difference() {
    color(brown_pair(3)[1])
      translate(v=[0, 0, template.z / 2])
        cuboid(size=template);

    color(brown_pair(3)[0])
      translate(v=[0, 0, template.z - side.z])
        side(t=0, rounding=0);

    color(c="red")
      translate(v=[0, 0, template.z - side.z])
        mask_channels(t=template_channel_t, d=template.z);
  }
}

render() {
  side(t=side_channel_t, rounding=side_rounding);

  translate(v=[0, 0, -150])
    template();
}
