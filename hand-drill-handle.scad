include <BOSL2/std.scad>

d_base = 25;
d_end = 40;
l_end = 30;

h_shaft = 15;
h_collar = 4.5;
h_thread = 9; // 25.5;// total

l_handle = h_shaft + h_collar + h_thread + l_end;

d_shaft = 3;
d_collar = 9.5;
d_thread = 9.4;

$fn = 200;

render() {
  difference() {
    union() {
      color(c="chocolate")
        translate(v=[0, 0, l_handle])
          top_half()
            sphere(d=d_end);
      color(c="tan")
        cylinder(d1=d_base, d2=d_end, h=l_handle, center=false);
    }
    color(c="blue")
      cylinder(d=d_shaft, h=h_thread + h_collar + h_shaft, center=false);
    #color(c="orange")
      cylinder(d=d_thread, h=h_thread + h_collar, center=false);

    translate(v=[0, 0, h_collar + h_thread])
      color(c="red")
        cylinder(d1=d_collar, d2=d_shaft, h=(d_collar - d_shaft) / 2, center=false);
  }
}
