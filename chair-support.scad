r_outer = 26;
r_inner = 14.10;

x_hole = 19;

r_bolt = 1.965;
l_bolt = 14.5;

w_nut = 7;
d_nut = w_nut * 2 / sqrt(3); // M4
d_nut_adjusted = d_nut * 1.015;
r_nut = d_nut_adjusted / 2;

r_head = 4.65;

h = [25, 25, 25, 20, 15];

function sumv(v, i = 0) = i < len(v) ? v[i] + sumv(v, i + 1) : 0;

echo(d_nut=d_nut);
echo(d_nut_adjusted=d_nut_adjusted);
echo(r_rut=r_nut);

echo(h_total=sumv(h));

$fn = 400;

module captive_nut(i) {
  shaft(
    x=r_nut,
    dx=x_hole,
    y=r_outer,
    dy=l_bolt / 2,
    dz=h[i] / 2,
    fn=6,
  );
}

module bolt_head(i) {
  shaft(
    x=r_head,
    dx=x_hole,
    y=r_outer,
    dy=l_bolt / 2,
    dz=h[i] / 2
  );
}

module bolt_shaft(i) {
  shaft(
    x=r_bolt,
    dx=x_hole,
    y=r_outer,
    dy=0,
    dz=h[i] / 2
  );
}

module shaft(x, y, dx, dy, dz, fn = $fn) {
  translate(v=[dx, dy, dz]) {
    rotate(a=90, v=[-1, 0, 0]) {
      rotate(a=30, v=[0, 0, 1]) // align the nut for better printing
        cylinder(r=x, h=y, center=false, $fn=fn);
    }
  }
}

module half_piece(i, nut) {
  intersection() {
    difference() {
      // body
      cylinder(r=r_outer, h=h[i]);

      // bolt hole
      bolt_shaft(i);

      if (nut) {
        captive_nut(i);
      } else {
        bolt_head(i);
      }

      // middle
      cylinder(r=r_inner, h=h[i]);
    }

    cube(size=[r_outer, r_outer, h[i]]);
  }
}

render()for (i = [0:1:len(h) - 1]) {
  translate(v=[0, i * r_outer * 2.5, 0]) {
    half_piece(i=i, nut=true);
    mirror(v=[1, 0, 0])
      half_piece(i, nut=false);
  }
}
