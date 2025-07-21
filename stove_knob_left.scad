$fn = 400;

render()
  difference() {
    union() {
      cylinder(h=7.8, r=42.2 / 2);
      cylinder(h=7.8 + 3.21, r=20 / 2);
    }

    cylinder(h=7.8 + 3.21, r=6.4 / 2);

    cylinder(h=1.5, r=32.8 / 2);
  }
