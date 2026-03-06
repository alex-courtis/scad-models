l_switch = 61.5;
w_switch = 30.5;
d_switch = 22;

t = 1.6;

l = 82 + 2 * t;
w = w_switch + t;
d = d_switch + t;

d_cable = 8;
w_cable = (w - t + d_cable) / 2;

module side() {
  translate(v=[0, d / 2 - t / 2, w / 2 - t / 2])
    rotate(a=90, v=[0, 1, 0])
      linear_extrude(h=t, center=true)
        polygon(
          [
            [0, 0],
            [w - t, 0],
            [w - t, -d / 2 + 0],
            [0, -d + t],
          ]
        );
}

render() {

  color(c="orange")
    cube([l_switch, d_switch, w_switch], center=true);

  color(c="green") {
    difference() {
      translate(v=[0, t / 2, t / 2])
        cube([l, d, w], center=true);

      cube([l, d - t, w - t], center=true);

      translate(v=[(l - d_cable) / 2 - t, t / 2, (w_cable - w_switch) / 2])
        cube([d_cable, d, w_cable], center=true);

      translate(v=[-(l - d_cable) / 2 + t, t / 2, (w_cable - w_switch) / 2])
        cube([d_cable, d, w_cable], center=true);
    }
  }

  color(c="pink") {
    translate(v=[l / 2 - t / 2, 0, 0])
      side();

    translate(v=[-l / 2 + t / 2, 0, 0])
      side();
  }
}
