r_outer = 26;
r_inner = 14.25;

x_hole = 20;

r_bolt = 1.95;
l_bolt = 14;

r_head = 4.5;

h = [25, 25, 25, 20, 15];

function sumv(v, i = 0) = i < len(v) ? v[i] + sumv(v, i + 1) : 0;

echo(h_total=sumv(h));

$fn = 400;

module cutout(i) {
  shaft(
    x=r_head,
    dx=x_hole,
    y=r_outer,
    dy=l_bolt / 2,
    dz=h[i] / 2
  );
}

module bolt(i) {
  shaft(
    x=r_bolt,
    dx=x_hole,
    y=r_outer,
    dy=0,
    dz=h[i] / 2
  );
}

module shaft(x, y, dx, dy, dz) {
  translate(v=[dx, dy, dz]) {
    rotate(a=90, v=[-1, 0, 0]) {
      cylinder(r=x, h=y, center=false);
    }
  }
}

module half_piece(i) {
  intersection() {
    difference() {
      // body
      cylinder(r=r_outer, h=h[i]);

      // holes
      cutout(i);
      bolt(i);

      // middle
      cylinder(r=r_inner, h=h[i]);
    }

    cube(size=[r_outer, r_outer, h[i]]);
  }
}

render()for (i = [0:1:len(h) - 1]) {
  translate(v=[0, i * r_outer * 2.5, 0]) {
    half_piece(i);
    mirror(v=[1, 0, 0])
      half_piece(i);
  }
}
