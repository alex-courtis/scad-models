r_outer = 28;
r_inner = 14;

r_bolt = 2.95;

l_connector = 20;

r_connector = 6.1;

// h = [30, 25, 25, 15, 15];
h = [15];

$fn = 400;

module cutouts(i) {
  dx = (r_inner + r_outer) / 2;
  shaft(i=i, l=r_outer * 2, r=r_connector, dx=dx);
  shaft(i=i, l=r_outer * 2, r=r_connector, dx=-dx);
}

module connectors(i) {
  dx = (r_inner + r_outer) / 2;
  shaft(i=i, l=l_connector, r=r_connector, dx=dx);
  shaft(i=i, l=l_connector, r=r_connector, dx=-dx);
}

module bolts(i) {
  dx = (r_inner + r_outer) / 2;
  shaft(i=i, l=l_connector, r=r_bolt, dx=dx);
  shaft(i=i, l=l_connector, r=r_bolt, dx=-dx);
}

module shaft(i, l, r, dx) {
  translate(v=[dx, 0, h[i] / 2]) {
    rotate(a=90, v=[1, 0, 0]) {
      cylinder(r=r, h=l, center=true);
    }
  }
}

module piece(i) {
  intersection() {
    difference() {
      union() {
        difference() {
          cylinder(r=r_outer, h=h[i]);
          cutouts(i);
        }
        // fill in bolt holes
        color(c="orange")
          connectors(i);
      }
      // middle hole
      cylinder(r=r_inner, h=h[i]);

      // bolt holes
      bolts(i);
    }

    // shave connectors
    cylinder(r=r_outer, h=h[i]);

    // half
    translate(v=[-r_outer, 0, 0])
      cube(size=[r_outer * 2, r_outer, h[i]]);
  }
}

render()for (i = [0:1:len(h) - 1]) {
  translate(v=[0, i * r_outer * 2.5, 0]) {
    piece(i);
  }
}
