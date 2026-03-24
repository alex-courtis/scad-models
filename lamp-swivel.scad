include <BOSL2/std.scad>
include <lib/geom.scad>

$fn = 400;

// approximate width of the arm
w_arm = 13.8;

// drilled into arm
d_arm_hole = 6;

// up channel
t_spacer = 9.5;

// space for spring clip
dt_spacer_lower = 1.5;

// circle from centre of hole
dl_spacer_inner = 1.5;

// to outside channel, from hole centre
l_spacer_outer = 8;

// across channel
w_spacer_inner = 10.5;

// across channel
w_spacer_inner_lower = 11.25;

// of the joiner
t_joiner = 7;

// not including shoulders
t_washer = 12;

// in addition to t_washer
t_washer_shoulder = w_arm / 2;

// outer of arm
w_washer_channel = 13.2;

// mating surface of the joiner and washers
d_washer_joiner = 24;

// joiner washers to plate
dl_joiner = 28;

// extension of the washers
d_washer_extension = w_washer_channel;

// extension of the washers, centre to centre
dl_washer_extension = 30;

// bolt's washer in joiner
d_inset_washer = 13.5;

// bolt's washer in joiner
t_inset_washer = 1.5;

// hole to hole
l_joiner = 30;

// gap in lower washer
dl_washer_lower = 13;

// across arm width
w_plate = w_arm + 2 * t_washer;

// lamp bolt
d_lamp_bolt = 5.9;

module spacer_cross(lower) {
  difference() {
    union() {
      translate(v=[-(l_spacer_outer - dl_spacer_inner) / 2, 0, 0])
        square([l_spacer_outer + dl_spacer_inner, t_spacer], center=true);

      translate(v=[dl_spacer_inner, 0])
        circle(d=t_spacer);
    }

    if (lower)
      translate(v=[0, (t_spacer - dt_spacer_lower) / 2])
        square([2 * l_spacer_outer, dt_spacer_lower], center=true);

    circle(d=d_arm_hole);
  }
}

module joiner_cross() {

  difference() {
    hull() {
      circle(d=d_washer_joiner);

      translate(v=[l_joiner, 0])
        circle(d=d_washer_joiner);

      translate(v=[l_joiner, l_joiner])
        circle(d=d_washer_joiner);
    }

    circle(d=d_arm_hole);

    translate(v=[l_joiner, 0])
      circle(d=d_arm_hole);

    translate(v=[l_joiner, l_joiner])
      circle(d=d_arm_hole);
  }
}

module joiner_washer_mask_cross() {

  translate(v=[0, 0])
    circle(d=d_inset_washer);

  translate(v=[l_joiner, 0])
    circle(d=d_inset_washer);

  translate(v=[l_joiner, l_joiner])
    circle(d=d_inset_washer);
}

module arm_washer_cross() {
  difference() {
    hull() {
      circle(d=d_washer_joiner);
      translate(v=[dl_washer_extension, 0, 0])
        circle(d=d_washer_extension);
    }
    circle(d=d_arm_hole);
  }
}

module spacer_upper() {
  color(c="darkgreen")
    linear_extrude(h=w_spacer_inner, center=false)
      spacer_cross();
}

module spacer_lower() {
  color(c="lightgreen")
    linear_extrude(h=w_spacer_inner_lower, center=false)
      spacer_cross(lower=true);
}

module arm_washer() {
  difference() {
    linear_extrude(h=t_washer + t_washer_shoulder, center=false)
      arm_washer_cross();

    translate(v=[0, 0, t_washer + t_washer_shoulder / 2])
      cube([d_washer_joiner + d_washer_extension + dl_washer_extension, w_washer_channel, t_washer_shoulder], center=true);

    translate(v=[dl_washer_extension - d_washer_extension / 2, -d_washer_extension, t_washer])
      cube([d_washer_extension, d_washer_extension * 2, t_washer_shoulder]);
  }
}

module arm_washer_upper() {
  color(c="orange")
    arm_washer();
}

module arm_washer_lower() {
  color(c="yellow")
    difference() {
      arm_washer();
      translate(v=[-d_washer_joiner * 1.5 + dl_washer_lower, 0, t_washer])
        cube([d_washer_joiner, d_washer_joiner, t_washer_shoulder]);
    }
}

module joiner() {
  color(c="pink") {
    difference() {
      linear_extrude(h=t_joiner, center=false)
        joiner_cross();

      translate(v=[0, 0, t_joiner - t_inset_washer])
        linear_extrude(h=t_inset_washer, center=false)
          joiner_washer_mask_cross();
    }
  }
}

module plate_cross() {
  difference() {
    hull() {
      circle(d=d_washer_joiner);

      translate(v=[l_joiner, 0])
        circle(d=d_washer_joiner);
    }

    circle(d=d_arm_hole);
  }
}

module plate() {
  color(c="gray")
    difference() {
      linear_extrude(h=w_plate)
        plate_cross();

      translate(v=[l_joiner - d_washer_joiner / 3, 0, w_plate / 2]) {
        rotate(a=90, v=[1, 0, 0]) {
          cylinder(h=d_washer_joiner, d=d_lamp_bolt, center=true);

          translate(v=[0, 0, (d_washer_joiner - t_inset_washer)/2])
            cylinder(d=d_inset_washer, h=t_inset_washer, center = true);

          translate(v=[0, 0, -(d_washer_joiner - t_inset_washer)/2])
            cylinder(d=d_inset_washer, h=t_inset_washer, center = true);
        }
      }
    }
}

render() {
  translate(v=[0, 60, 0])
    spacer_upper();

  translate(v=[60, 60, 0])
    spacer_lower();

  translate(v=[60, -60, 0])
    arm_washer_upper();

  translate(v=[60, -120, 0])
    mirror(v=[0, 1, 0])
      arm_washer_upper();

  translate(v=[0, -60, 0])
    arm_washer_lower();

  translate(v=[0, -120, 0])
    mirror(v=[0, 1, 0])
      arm_washer_lower();

  translate(v=[60, 0, 0])
    joiner();

  translate(v=[0, 0, 0])
    plate();

  translate(v=[-60, 0, 0])
    joiner();
}
