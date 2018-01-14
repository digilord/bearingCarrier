$fn=100;
material_thickness=5;
use <obiscad/attach.scad>;
use <obiscad/bevel.scad>;

module m5_bolt_hole_unthreaded(distance_from_center=10, position_angle=90, depth=5, hole=true){
    // All measurements are in millimeters
    m5=5;
    // Plot the location of the three M5 holes ~18mm on center
    // x = r * cos(a)
    // y = r * sin(a)
    // (r=1 in a unit circle)
    r=distance_from_center;
    x=r * cos(position_angle);
    y=r * sin(position_angle);
    translate([x,y,0]){
        if(!hole){
            difference(){
                cylinder(h=depth,r=(m5/2 + 0.1));
                cylinder(h=depth,r=(m5/2 - 0.1));
            };
        } else {
            cylinder(h=depth,r=(m5/2 + 0.1));
        };
    };
};

module holes_for_carrier(hole=true,material_thickness=5){
    m5_bolt_hole_unthreaded(distance_from_center=18, position_angle=0, depth=material_thickness);
    m5_bolt_hole_unthreaded(distance_from_center=18, position_angle=120, depth=material_thickness);
    m5_bolt_hole_unthreaded(distance_from_center=18, position_angle=240, depth=material_thickness);
    if(!hole){
        difference(){
            cylinder(h=material_thickness,r=6.5); // Center rod clearence.
            cylinder(h=material_thickness,r=6); // Center rod clearence.
        };
    } else {
        cylinder(h=material_thickness,r=6.5); // Center rod clearence.
    }
};

// body
// Body Top
module pristine_body_top(){
  union(){
    cylinder(h=material_thickness, r=26);
    translate([13.50,0,2.5]){
        cube([30,52,5],true);
    };
    translate([30,0,2.5]){
        cube([8,52,5],true);
    };
  };

};

module body_top(){
    difference(){
        pristine_body_top();
        holes_for_carrier(hole=true);
    };
};

// Pedestal
// 31w x 56l
module pedestal(){
    rotate(a=90,v=[0,1,0]){
        translate([-2.5,0,32]){
            cube([32,52,5],true);
        }
    }
}

//-- Parts parameters
th = 2;
bsize = [52,52,th];
size = [bsize[0],th,52];

module buttresses(th=3,bsize=[30,30,3],size=[30,3,20],rotate_array=[0,0,90]){
  ec3 = [ [0, th/2, th/2],  [1,0,0], 0];
  en3 = [ ec3[0],           [0,1,1], 0];
  translate([1.2,0,4.0])rotate(rotate_array)bconcave_corner_attach(ec3,en3,l=bsize[0]/2,cr=12,cres=0);
}

module front_buttresses(){
  translate([29.78,24.75,-0.47])buttresses(size=[25,2.5,25],bsize=[5,2.5,15]);
  translate([29.78,-24.75,-0.47])buttresses(size=[25,2.5,25],bsize=[5,2.5,15]);
}
module rear_buttresses(){
  rotate([180,0,0])translate([0,0,-5.04])front_buttresses();
}

module model_body(){
  difference(){
    translate([0,0,-2]){
      pristine_body_top();
      pedestal();
      front_buttresses();
      rear_buttresses();
    }
    // -14.75 is (32-2.5)/2 inverted
    // The thickness is so high so as to punch holes
    // through the entire cube that the model lives in
    translate([0,0,-14.75])holes_for_carrier(hole=true,material_thickness=32);
  }
}

module Right_triangle(side1,side2,corner_radius,triangle_height){
  translate([corner_radius,corner_radius,0]){
    hull(){
      cylinder(r=corner_radius,h=triangle_height);
          translate([side1-corner_radius*2,0,0])cylinder(r=corner_radius,h=triangle_height);
          translate([0,side2-corner_radius*2,0])cylinder(r=corner_radius,h=triangle_height);
      }
    }
}
//Right_triangle(100,100,5,10);

module rounded_cube(xdim,ydim,zdim,rdim){
    hull(){
      translate([rdim,rdim,0])cylinder(r=rdim,h=zdim);
      translate([xdim-rdim,rdim,0])cylinder(r=rdim,h=zdim);

      translate([rdim,ydim-rdim,0])cylinder(r=rdim,h=zdim);
      translate([xdim-rdim,ydim-rdim,0])cylinder(r=rdim,h=zdim);
    }
}

//rounded_cube(20,20,10,3);


module equ_triangle(side_length, corner_radius, triangle_height){
  rotate([0,0,180])hull(){
    cylinder(r=corner_radius, h=triangle_height);
    rotate([0,0,60])translate([side_length-corner_radius*2,0,0])cylinder(r=corner_radius, h=triangle_height);
    rotate([0,0,120])translate([side_length-corner_radius*2,0,0])cylinder(r=corner_radius, h=triangle_height);
  }
}


module holes_for_pedestal(hole_size=2.65,depth=26){
  color("white"){
    x=15;
    y=18;
    z=10;
    translate([x,y,-z]) rotate(a=90,v=[0,1,0])cylinder(h=depth,r=hole_size);
    translate([x,-y,-z])rotate(a=90,v=[0,1,0])cylinder(h=depth,r=hole_size);
    translate([x,y,z])  rotate(a=90,v=[0,1,0])cylinder(h=depth,r=hole_size);
    translate([x,-y,z]) rotate(a=90,v=[0,1,0])cylinder(h=depth,r=hole_size);
  }
}

// Spliting this out as I want the holes I'm poking in the pedestal go through any extra structure is here
//body_top();
difference(){
  model_body();
  holes_for_pedestal();
  /* translate([10,10,25])printing_foot(height=3); */
}

bottom_of_model=34;
hole_size=7;
pad_height=0.5;
translate([bottom_of_model, 29, 20])printing_foot(height=pad_height,hole_size=hole_size);
translate([bottom_of_model, 29,-20])printing_foot(height=pad_height,hole_size=hole_size);
translate([bottom_of_model,-29, 20])printing_foot(height=pad_height,hole_size=hole_size);
translate([bottom_of_model,-29,-20])printing_foot(height=pad_height,hole_size=hole_size);


module printing_foot(height=2, hole_size=3.0){
  color("Orange")rotate([0,90,0])cylinder(h=height, r=hole_size);
}
