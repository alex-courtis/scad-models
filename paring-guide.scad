include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

$fn = 200;

clearance_guide_back = 0.2;
clearance_guide_body = 0.2;
clearance_guide_back_bottom = 1;

l_hinge = 40;
segs_hinge = 5;
gap_hinge = 0.2; // [0:0.01:3]
d_pin = 3.80; // [1:0.01:10]
dd_pin_back = 0.2;
r_knuckle = (3.8 + 2 + 2) / 2;
echo(r_knuckle=r_knuckle);

// POC: 64.5 * 2 wood block
l_back = 2 * 64.5 + 2 * l_hinge;
h_back = 120;
t_back = d_pin * 2;
dh_hinge_back = 0.8;
echo(l_back=l_back);
echo(h_back=h_back);
echo(t_back=t_back);

l_body = l_back;
t_body = 5;
// POC: 35.3 x 35.3 wood block
h_body = 35.3 + t_body; // below hinge centre
d_body = 35.3 + t_body;
dd_hinge_body = 2;

l_guide = l_body - 2 * l_hinge;
h_guide = h_body - t_body;
d_guide = d_body - t_body;
echo(l_guide=l_guide);
echo(h_guide=h_guide);
echo(d_guide=d_guide);

module hinge_back(length, flat, inner, offset, clear_top) {
  // this will be completely clipped away, leaving a flat bottom; cannot be exactly r_knuckle
  arm_height = flat ? t_back : 0;

  // from the centre
  clip = flat ? t_back : undef;

  knuckle_hinge(
    length=length,
    segs=segs_hinge,
    offset=offset,
    inner=inner,
    arm_height=arm_height,
    arm_angle=90,
    gap=gap_hinge,
    // seg_ratio=1,
    knuckle_diam=r_knuckle * 2,
    pin_diam=d_pin,
    // fill=true,
    clear_top=clear_top,
    // round_bot=0,
    // round_top=0,
    // pin_fn,
    // clearance=0,
    teardrop=true,
    // in_place=false,
    clip=clip,
    // tap_depth,
    // screw_head,
    // screw_tolerance="close",
    // knuckle_clearance,
    anchor=CENTER,
    orient=RIGHT,
    // spin,
  );
}

module part_back() {

  x_hinge = r_knuckle + dh_hinge_back;
  x_back = h_back - x_hinge;
  y = t_back;
  z = l_back;

  color(c="darkgreen")
    translate(v=[0, 0, l_hinge / 2])
      rotate(a=180)
        hinge_back(length=l_hinge, flat=true, inner=true, offset=x_hinge, clear_top=true);

  color(c="darkolivegreen")
    translate(v=[0, 0, z - l_hinge / 2])
      rotate(a=180)
        hinge_back(length=l_hinge, flat=true, inner=true, offset=x_hinge, clear_top=true);

  color(c="lightgreen")
    difference() {
      translate(v=[x_hinge, 0, 0])
        cube(size=[x_back, y, z], center=false);
      translate(v=[clearance_guide_back_bottom, 0, 0])
        part_guide(dxyz=clearance_guide_back);
      #translate(v=[45, d_pin + dd_pin_back, 0])
        cylinder(r=(d_pin + dd_pin_back) / 2, h=z);
      translate(v=[105, d_pin + dd_pin_back, 0])
        #cylinder(r=(d_pin + dd_pin_back) / 2, h=z);
    }
}

module part_body() {
  x = h_body + r_knuckle;
  y_hinge = r_knuckle + dd_hinge_body;
  y_body = d_body - y_hinge;
  z = l_body;

  color(c="fuchsia")
    translate(v=[0, 0, l_hinge / 2])
      rotate(a=270)
        hinge_back(length=l_hinge, flat=false, inner=false, offset=y_hinge, clear_top=false);

  color(c="orchid")
    translate(v=[0, 0, z - l_hinge / 2])
      rotate(a=270)
        hinge_back(length=l_hinge, flat=false, inner=false, offset=y_hinge, clear_top=false);

  color(c="purple")
    difference() {
      translate(v=[-r_knuckle, y_hinge, 0])
        cube(size=[x, y_body, z], center=false);

      // clear the guide itself
      part_guide(dxyz=clearance_guide_body);

      // clear the guide above the hinge and behind
      translate(v=[-h_guide + t_body, r_knuckle, 0])
        part_guide(dxyz=clearance_guide_body);
    }
}

module part_guide(dxyz = 0) {
  x = h_body - t_body + dxyz * 2;
  y = d_body - t_body + dxyz * 2;
  z = l_body - 2 * l_hinge + dxyz * 2;
  dz = (l_body - z) / 2;

  color(c="brown")
    translate(v=[0, 0, dz])
      cube(size=[x, y, z], center=false);
}

render() {
  part_back();
  rotate(a=5) {
    // part_body();
    part_guide();
  }
}
