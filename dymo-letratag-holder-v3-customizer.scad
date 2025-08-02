/** *** ***** ******* ***********
//
// Dymo LetraTag Holder
// Version 1 - 19.09.2020 
// CC-BY-NC-SA 2020 by oli@huf.org (ohuf@Thingiverse)
//
// www.thingiverse.com/thing:4601782


(Deutscher Text: Siehe unten...)


This is a customizable holder for DYMO's LetraTag label  cartridges


Enjoy, have fun remixing and let me know when you've made one, and what for!


-- --- ----- ------- -----------
[DE:]
// xDE

Ein "Customizable" Halter für DYMO's LetraTag label-Kassetten.

Wenn du einen hergestellt hast, lass es mich über "I Made One" wissen!

Konstruiert in OpenSCAD: viel Spaß beim Remixen!



// 
// License: CC-BY-NC-SA : oli@huf.org
// read all about it here: http://creativecommons.org/licenses/by-nc-sa/4.0/
//
 ** *** ***** ******* ***********/


$fn=250;

dt1=0.01;
dt2=dt1*2;
prt_delta=0.4;

b_x=55; // [0:0.1:100]
b_y=17;	// [0:0.1:100]
b_z=23;	// [0:0.1:100]

// notch_x=10;

notch_z=9;	// [0:0.1:100]

notch_dy=2;	// [0:0.1:100]

// notch_dz=3;

mat=0.8;	// [0:0.01:100]

// How many do we need?
anzahl=12;	// [1:1:100]

magnet_r = 5;	// [0:0.1:100]

magnet_z = 3;	// [0:0.1:100]

magnet_wall_thickness = 0.8; // [0:0.1:5]

module body() {
	for(i = [0:anzahl-1]) {
		translate([0, i*(b_y+mat), 0])
			difference() {
				union() {
					difference() {
						cube([b_x+mat*2, b_y+mat*2, b_z+mat]);

						union() {
							translate([mat, mat, mat+dt1])
								cube([b_x, b_y, b_z]);
							translate([-dt1, -dt1, -dt1])
								cube([20+dt2, b_y+2*mat+dt2, 20+dt2]);
							//		translate([notch_x, -dt1, notch_z])
							//			color("red")
							//			cube([20, notch_dy+mat, notch_dz]);
							//		//vertical notch:
							//		translate([20, -dt1, notch_z])
							//			color("red")
							//			cube([notch_dy+mat, notch_dz,20 ]);
						}
					}
					slope();
				}
				union() {
					//vertical notch:
					translate([20, -dt1, notch_z])
						color("red")
						cube([notch_dy+mat, b_y+2*mat+dt2, 20 ]);
					// horizontal notch?
					//			translate([notch_x, -dt1, notch_z])
					//				color("red")
					//				cube([20, notch_dy+mat, notch_dz]);
				}
			}
	}
}

module slope() {
	translate([0,b_y+2*mat, 0])
		rotate([90,0,0])
		translate([20+mat, 20+mat, 0])
		difference() {
			cylinder(r=20+mat, h=b_y+2*mat);
			union() {
				translate([0, 0, mat])
					cylinder(r=20, h=b_y);
				translate([-20-mat, 0, -dt1])
					cube([50, 50, b_y+2*mat+dt2]);
				translate([0, -20-mat, -dt1])
					cube([50, 50, b_y+2*mat+dt2]);
			}
		}

}


render()
	difference() {
		union() {
			body();

			color(c="green")
				translate(v=[
						20, 0, -magnet_z + mat - magnet_wall_thickness,
				])
				cube([
						b_x + mat * 2 - 20,
						anzahl * (b_y + mat) + mat,
						magnet_z - mat + magnet_wall_thickness,
				]);
		}

		for(i = [0:anzahl-1]) {
			color(c="red")
				translate(v=[
						b_x / 2 + magnet_r / 2,
						b_y / 2 + mat + i * (b_y + mat),
						mat - magnet_z + dt1,
				])
				cylinder(r = magnet_r, h = magnet_z + dt1);
		}
	}
