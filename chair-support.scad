r_outer = 28;
r_inner = 14.25;

r_bolt = 1.95;
l_bolt = 14;

l_connector = 14;

r_connector = 4.5;

h = [35, 27.5, 17.5, 15, 12.5];

function sumv(v, i = 0) = i < len(v) ? v[i] + sumv(v, i + 1) : 0;

echo(h_total=sumv(h));

$fn = 400;

module cutout(i) {
  shaft(
    x=r_connector,
    dx=(r_inner + r_outer) / 2,
    y=r_outer,
    dy=l_bolt / 2,
    dz=h[i] / 2
  );
}

module bolt(i) {
  shaft(
    x=r_bolt,
    dx=(r_inner + r_outer) / 2,
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
