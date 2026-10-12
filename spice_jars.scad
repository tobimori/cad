// Gridfinity holder for a row of spice jars, tilted so the lids face up toward the front of the drawer
// Jars: Modulor "Glastiegel braun transparent R3-Gewinde" with a Bakelite lid (ApoGlas specs)
//   120 ml, 58 R3 thread: ø 61.5 mm, 65.5 mm high with the lid
//   60 ml, 51 R3 thread: ø 53.1 mm, 55.7 mm high with the lid

include <flat_bin.scad>

/* [Jar] */
// Diameter of the glass
jar_diameter = 61.5; // .5
// Height with the lid on
jar_height = 65.5; // .5
// Height of the lid. It must stay above the bin, so you can grip the jar
lid_height = 14; // .5
// Extra pocket diameter. Sellers list this jar at 61 to 62 mm, and printed holes come out a bit small
clearance = 3; // .5

/* [Bin] */
gridx = 5;
gridy = 2;
// Height in 7 mm units. Use the same height for all bins in a drawer, so the tops are flush
gridz = 8;
// Number of jars in the row
jars = 3;
// Tilt of the jars from vertical, with the lid toward the front. More tilt makes the jars reach higher
tilt = 15; // [0:5:60]
// Height from the baseplate to the top of the drawer wall, or to whatever is above the drawer
drawer_height = 90;
// Wall between the jars
wall = 2; // .5
// Roundover of the pocket rims
rim_radius = 2.5; // .1
// Fillet at the pocket bottom
floor_radius = 2; // .1
// Make the jars instead of the bin, to preview the fit
show_items = false;

/* [Hidden] */
$fa = 4;
$fs = 0.25;

height = fromGridfinityUnits(gridz);
size = [gridx * GRID_DIMENSIONS_MM.x, gridy * GRID_DIMENSIONS_MM.y] - BASE_GAP_MM;
radius = (jar_diameter + clearance) / 2;
pitch = 2 * radius + wall;
// Lowest point of the pockets, 1 mm above the base
lowest = BASE_HEIGHT + 1;
// Length along the jar axis where the front of the pocket comes out of the top
front_length = (height - lowest) / cos(tilt);
// Center of the pocket bottom, placed so the pocket footprint is centered front to back
bottom = [0, front_length * sin(tilt) / 2, lowest + radius * sin(tilt)];
footprint = 2 * radius * cos(tilt) + front_length * sin(tilt);
top_of_jars = bottom.z + jar_height * cos(tilt) + radius * sin(tilt);

assert(jars * 2 * radius + (jars - 1) * wall <= size.x - 2,
    "The jars do not fit side by side, use a bigger gridx or fewer jars");
assert(footprint <= size.y - 2, "The pockets do not fit front to back, use a bigger gridy");
// The rim roundover needs a wall behind the pocket bottom
assert(bottom.z + radius * sin(tilt) <= height - rim_radius,
    "The pocket bottom reaches the rim, use a bigger gridz or less tilt");
assert(top_of_jars <= drawer_height - 2, str("The jars reach ", top_of_jars, " mm, use less tilt"));
assert(front_length <= jar_height - lid_height, "The bin covers the lids, use a smaller gridz");
echo(str("The jars reach ", top_of_jars, " mm above the drawer floor"));

module each_column() {
    for (i = [0 : jars - 1]) translate([(i - (jars - 1) / 2) * pitch, 0, 0]) children();
}

// Moves to the bottom center of each jar, with the jar axis along +Z
module each_jar() {
    each_column() translate(bottom) rotate([tilt, 0, 0]) children();
}

// Cylinder with a rounded bottom edge
module rounded_cylinder(r, h, edge) {
    rotate_extrude() union() {
        square([r - edge, h]);
        translate([0, edge]) square([r, h - edge]);
        translate([r - edge, edge]) circle(edge);
    }
}

// Rounds the rim where a tilted pocket meets the flat top. A horizontal slice of the tilted
// cylinder is an ellipse, so hull neighbor slices, each grown by the quarter circle profile
module rim_roundover() {
    steps = 8;
    function grow(i) = rim_radius - sqrt(rim_radius ^ 2 - (rim_radius * i / steps) ^ 2);
    module slice(z, d) {
        translate([0, bottom.y - (z - bottom.z) * tan(tilt), z])
        linear_extrude(0.01)
        scale([1, (radius / cos(tilt) + d) / (radius + d)]) circle(radius + d);
    }
    for (i = [0 : steps - 1]) hull() {
        slice(height - rim_radius * (1 - i / steps), grow(i));
        slice(height - rim_radius * (1 - (i + 1) / steps), grow(i + 1));
    }
    hull() {
        slice(height, rim_radius);
        slice(height + 1, rim_radius);
    }
}

if (show_items)
    // Molded glass has a rounded base edge
    each_jar() rounded_cylinder(jar_diameter / 2, jar_height, 3);
else
    flat_bin([gridx, gridy], gridz) {
        // Long enough to come out of the top
        each_jar() rounded_cylinder(radius, front_length + 10, floor_radius);
        each_column() rim_roundover();
    }
