$fn=30;

/* [Global] */

// Render
Objects = "Box"; //  [Both, Box, Lid]
// Type of lid pattern
gPattern = "Diamond"; //  [Hex, Diamond, Solid, Fancy]
// Tolerance
gTol = 0.3;
// Wall Thickness
gWT = 1.6;

//  padded mini 8 in x, and 2 in y  to give it a lip
ArtifactsX = 29;
ArtifactsY = 23;
ArtifactsZ = 24;
ArtifactsOpening = 13;

TreasureR = 15;
TreasureX = (TreasureR * 2) * 0.866;  // fix later
TreasureY = 41;

BinSeperation = 2;

/* [Hidden] */
/* Private variables */

// Box Height

LidH = 2.2;
RailThick = 1.4;
RailWidth = LidH + RailThick;

function SumList(list, start, end) = (start == end) ? 0 : list[start] + SumList(list, start+1, end);
// Box Length
TotalX = ArtifactsX +TreasureX + 2*gWT + BinSeperation ;
// Box Width 10 mm pad between skill and level for finger slot
TotalY = 2*RailWidth + 5*ArtifactsY + 7*BinSeperation;
TotalZ = gWT + ArtifactsZ + LidH;


echo("Size: ",TotalX,TotalY, TotalZ);
   
// Height not counting the lid
AdjBoxHeight = TotalZ - LidH;

 module regular_polygon(order, r=1){
 	angles=[ for (i = [0:order-1]) i*(360/order) ];
 	coords=[ for (th=angles) [r*cos(th), r*sin(th)] ];
 	polygon(coords);
 }

module diamond_lattice(ipX, ipY, DSize, WSize)  {

    lOffset = DSize + WSize;

	difference()  {
		square([ipX, ipY]);
		for (x=[0:lOffset:ipX]) {
            for (y=[0:lOffset:ipY]){
  			   translate([x, y])  regular_polygon(4, r=DSize/2);
			   translate([x+lOffset/2, y+lOffset/2]) regular_polygon(4, r=DSize/2);
		    }
        }        
	}
}

module circle_lattice(ipX, ipY, Spacing=10, Walls=1.2)  {


   intersection() {
      square([ipX,ipY]); 
      union() {
	    for (x=[-Spacing:Spacing:ipX+Spacing]) {
           for (y=[-Spacing:Spacing:ipY+Spacing]){
	          difference()  {
			     translate([x+Spacing/2, y+Spacing/2]) circle(r=Spacing*0.75);
			     translate([x+Spacing/2, y+Spacing/2]) circle(r=(Spacing*0.75)-Walls);
		      }
           }   // end for y        
	    }  // end for x
      } // End union
   }
}

module football() {
    scale([0.7,0.7])
    intersection(){
        translate([-4,0]) circle(6);
        translate([4,0]) circle(6);
    }
}

module RCube(x,y,z,ipR=4) {
    translate([-x/2,-y/2,0]) hull(){
      translate([ipR,ipR,ipR]) sphere(ipR);
      translate([x-ipR,ipR,ipR]) sphere(ipR);
      translate([ipR,y-ipR,ipR]) sphere(ipR);
      translate([x-ipR,y-ipR,ipR]) sphere(ipR);
      translate([ipR,ipR,z-ipR]) sphere(ipR);
      translate([x-ipR,ipR,z-ipR]) sphere(ipR);
      translate([ipR,y-ipR,z-ipR]) sphere(ipR);
      translate([x-ipR,y-ipR,z-ipR]) sphere(ipR);
      }  
} 

module lid(ipPattern = "Hex", ipTol = 0.3){
  lAdjX = TotalX;
  lAdjY = TotalY-RailWidth*2-ipTol*2;  
  lAdjZ = LidH;
  CutX = lAdjX - 8;
  CutY = lAdjY - 8;
  lFingerX = 15;
  lFingerY = 16;  

  // main square with center removed for a pattern. 0.01 addition is a kludge to avoid a 2d surface remainging when substracting the lid from the box.
         difference() {
      translate([0,0,lAdjZ/2]) cube([lAdjX+0.01, lAdjY+0.01 , lAdjZ], center=true);

      translate([0,0,lAdjZ/2]) cube([CutX, CutY, lAdjZ], center = true);
      translate([TotalX/2-gWT/2,0,LidH/2])cube([gWT+0.01,TotalY-RailWidth,LidH],center=true);

     // make a slot for the latch can flex         
     translate([TotalX/2,TotalY/2-RailWidth-1.4,-1]) RCube(18,0.8,4,0.4);
     translate([TotalX/2,-TotalY/2+RailWidth+1.4,-1]) RCube(18,0.8,4,0.4);
  }
  
  // The Side triangles
  difference() {
    intersection () {
      union () {
          translate([-lAdjX/2,-lAdjY/2-LidH,LidH]) rotate([0,90,0]) linear_extrude(TotalX-2) polygon([[LidH,0],[LidH,LidH],[0,LidH]], paths=[[0,1,2]]);
          translate([-lAdjX/2,lAdjY/2,LidH]) rotate([0,90,0]) linear_extrude(TotalX-2) polygon([[0,0],[LidH,0],[LidH,LidH]], paths=[[0,1,2]]);
      }
      
      // check if this is real lid (ipTol>0) or negative lid (iptol = 0)
      // if real lid remove center for pattern and remove latches
      if (ipTol>0) 
         {cube([lAdjX, lAdjY + 2*LidH-0.2, lAdjZ*2], center=true);}
    }
       
    if (ipTol>0)
    {
        // cut out slots for the latch 
        translate([TotalX/2-7,lAdjY/2+RailWidth/2+ipTol,LidH/2]) scale([1.5,1,1]) rotate([0,0,45]) cube ([2+ipTol,2+ipTol,LidH+1],center=true);
          
        translate([TotalX/2-7,-lAdjY/2-RailWidth/2-ipTol,LidH/2]) scale([1.5,1,1]) rotate([0,0,45]) cube ([2+ipTol,2+ipTol,LidH+1],center=true);
  
        // trip the rail to ease going past the nub
        translate([TotalX/2,TotalY/2-LidH/2-ipTol,0]) cube([12,LidH,LidH*2],center=true); 
        translate([TotalX/2,-TotalY/2+LidH/2+ipTol,0]) cube([12,LidH,LidH*2],center=true); 
    }
    
  }
 
  // Finger slot
  difference () {
      translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
      translate([-CutX/2+lFingerX/2,0,20+LidH/2])sphere(20);     
  }

  // Diamond top
  if (ipPattern == "Diamond") 
    {
      difference (){ 
        translate([-CutX/2,-CutY/2,0]) linear_extrude(height = lAdjZ) diamond_lattice(CutX,CutY,7,2);
        translate([-CutX/2,-lFingerY/2,0]) cube([lFingerX, lFingerY, lAdjZ]); 
                }
    }
}

module artifact() {
    difference() {
        translate([0,0,TotalZ]) cube([ArtifactsX, ArtifactsY, 2*TotalZ], center=true);
        translate([ArtifactsX/2,ArtifactsY/2,TotalZ]) rotate([0,0,45])cube([5, 5, 2*TotalZ], center=true);
        translate([ArtifactsX/2,-ArtifactsY/2,TotalZ]) rotate([0,0,45])cube([5, 5, 2*TotalZ], center=true);
    }
}

module treasure() {
    offset = TreasureY/2 - TreasureR;
    hull(){
        translate([0,offset,0])linear_extrude(TotalZ) rotate([0,0,30])regular_polygon(6, r=TreasureR);
        translate([0,-offset,0])linear_extrude(TotalZ) rotate([0,0,30])regular_polygon(6, r=TreasureR);
    }
}

module box () {
//  Main Box
    
  difference() {   
     union(){
        // main box 
        translate ([0,0,AdjBoxHeight/2]) cube([TotalX,TotalY,AdjBoxHeight], center = true);
        // add backstop
        translate([TotalX/2-1/2,0,TotalZ-LidH/2])cube([1,TotalY-RailWidth,LidH],center=true);
     }

    // limit backdrop
     translate([TotalX/2,0,AdjBoxHeight+5])cube([4,TotalY-16,10],center=true);

    // Artifact slots
     translate([-TotalX/2+ArtifactsX/2+gWT, 2 * (ArtifactsY + BinSeperation),gWT]) artifact();
        translate([-TotalX/2,  2 * (ArtifactsY + BinSeperation),0]) scale([1,1.2,1])cylinder(h=2*TotalZ, r=6, center = true);
     translate([-TotalX/2+ArtifactsX/2+gWT, 1 * (ArtifactsY + BinSeperation),gWT]) artifact();
          translate([-TotalX/2, 1 * (ArtifactsY + BinSeperation),0])scale([1,1.2,1])cylinder(h=2*TotalZ, r=6, center = true);
     translate([-TotalX/2+ArtifactsX/2+gWT, 0,gWT]) artifact();
          translate([-TotalX/2, 0,0]) scale([1,1.2,1]) cylinder(h=2*TotalZ, r=6, center = true);
     translate([-TotalX/2+ArtifactsX/2+gWT, -1 * (ArtifactsY + BinSeperation),gWT]) artifact();
          translate([-TotalX/2, -1 * (ArtifactsY + BinSeperation),0])scale([1,1.2,1])cylinder(h=2*TotalZ, r=6, center = true);
     translate([-TotalX/2+ArtifactsX/2+gWT, -2 * (ArtifactsY + BinSeperation),gWT]) artifact();
          translate([-TotalX/2, -2 * (ArtifactsY + BinSeperation),0])scale([1,1.2,1])cylinder(h=2*TotalZ, r=6, center = true);
     
    // treasure slots
    translate([TotalX/2-TreasureX/2-gWT, 1 * (TreasureY + BinSeperation),gWT]) treasure();
       translate([TotalX/2, 1 * (TreasureY + BinSeperation),0]) scale([1,1.5,1])cylinder(h=2*TotalZ, r=6, center = true);
    translate([TotalX/2-TreasureX/2-gWT, 0,gWT]) treasure();
       translate([TotalX/2, 0,0]) scale([1,1.5,1])cylinder(h=2*TotalZ, r=6, center = true);
    translate([TotalX/2-TreasureX/2-gWT, -1 * (TreasureY + BinSeperation),gWT]) treasure();
       translate([TotalX/2, -1 * (TreasureY + BinSeperation),0]) scale([1,1.5,1])cylinder(h=2*TotalZ, r=6, center = true);
  }

  // top rails
  difference() {
      union() {
          translate([0,-TotalY/2+RailWidth/2,AdjBoxHeight+LidH/2]) cube([TotalX,RailWidth,LidH],center = true);  
          translate([0,TotalY/2-RailWidth/2,AdjBoxHeight+LidH/2]) cube([TotalX,RailWidth,LidH],center = true);
           }
       
      // Trim each rail top to a 45 degree angle     
      translate([0,-TotalY/2,AdjBoxHeight+RailWidth]) rotate([45,0,0]) cube([TotalX,RailWidth+0.7,RailWidth+0.7], center=true); 
      translate([0,TotalY/2,AdjBoxHeight+RailWidth])  rotate([45,0,0]) cube([TotalX,RailWidth+0.7,RailWidth+0.7], center=true);  

      // Substract the lid from the rails
      translate([0,0,AdjBoxHeight]) lid(ipPattern = "Solid",ipTol =0);      
  }  
  

  
  // create the latches 
    translate([TotalX/2-7,TotalY/2-0.1-RailWidth/2,TotalZ-LidH/2]) scale([1.5,1,1]) difference(){
      rotate([0,0,45]) cube ([2,2,LidH+1],center=true);
      translate([0,2,0]) cube ([4,4,LidH+2],center=true);
      translate([0,-2,0])cube([2,2,LidH+2], center=true);
      }  
    translate([TotalX/2-7,-TotalY/2+0.1+RailWidth/2,TotalZ-LidH/2]) scale([1.5,1,1]) difference(){
      rotate([0,0,45]) cube ([2,2,LidH+1],center=true);
      translate([0,-2,0]) cube ([4,4,LidH+2],center=true);
      translate([0,2,0])cube([2,2,LidH+2], center=true);
      }

  
} 

// Production Box
if ((Objects == "Both") || (Objects == "Box")){
  intersection() {
     box();
     RCube(TotalX,TotalY,TotalZ,1);
  }
}

// Production Lid
if (Objects == "Both"){
  translate([-TotalX - 10,0,0]) lid(ipPattern = gPattern, ipTol = gTol);
}

// Production Lid
if (Objects == "Lid"){
  lid(ipPattern = gPattern, ipTol = gTol);
}

