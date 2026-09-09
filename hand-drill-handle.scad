include <BOSL2/std.scad>

d_base = 22.5;
d_end = 40;
l_end = 30;

h_shaft = 17;
h_collar = 4.5;
h_thread = 9; // 25.5;// total

l_handle = h_shaft + h_collar + h_thread + l_end;

d_shaft = 3.3;
d_collar = 9.9;
d_thread = d_collar;

$fn = 200;

render() {
  difference() {
    union() {
      color(c="chocolate")
        translate(v=[0, 0, l_handle])
          top_half()
            sphere(d=d_end);

      color(c="tan")
        cylinder(d1=d_base, d2=d_base, h=l_handle, center=false);

      color(c="burlywood")
        translate(v=[0, 0, l_handle - d_end / 2])
          cylinder(d1=d_base, d2=d_end, h=d_end / 2, center=false);
    }

    color(c="blue")
      translate(v=[0, 0, h_thread + h_collar])
        cylinder(d=d_shaft, h=h_shaft, center=false);

    translate(v=[0, 0, h_thread]) {
      color(c="orange")
        cylinder(d=d_thread, h=h_collar, center=false);

      color(c="red")
        translate(v=[0, 0, h_collar])
          cylinder(d1=d_collar, d2=d_shaft, h=(d_collar - d_shaft) / 2, center=false);
    }

    color(c="pink")
      cylinder(d=d_thread, h=h_thread, center=false);
  }
}
