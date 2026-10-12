// Gridfinity holder for a stack of AeroPress paper filters

include <flat_bin.scad>

/* [Filter] */
// Filter diameter in mm. XL filters need a 3x3 bin
filter_diameter = 63.5; // [63.5:Standard (Original, Go, Clear), 73:XL]
// Extra pocket diameter, some packs measure up to 65 mm
play = 3; // .5

/* [Bin] */
gridx = 2;
gridy = 2;
// Height in 7 mm units. Use the same height for all bins in a drawer, so the tops are flush
gridz = 8;
// Finger notch toward the front right corner
notch_width = 30;
// How far the notch goes past the pocket edge
notch_depth = 12;
// Radius of the pocket corners, seen from above. Must be larger than floor_radius
corner_radius = 3; // .5
// Roundover of the pocket rim
rim_radius = 2.5; // .1
// Fillet between the pocket wall and the floor
floor_radius = 2; // .1
// Radius where the notch meets the pocket, seen from above
blend_radius = 8; // .5

/* [Hidden] */
$fa = 4;
$fs = 0.25;

pocket_radius = (filter_diameter + play) / 2;
// The notch points at a corner, its round end must stay 2 mm inside the outer wall
notch_reach = (pocket_radius + notch_depth - notch_width / 2) / sqrt(2) + notch_width / 2;
assert(notch_reach <= min(gridx, gridy) * 21 - 0.25 - 2,
    "The notch cuts through the wall, use a bigger grid");

notch = zrot(-45, p = finger_notch(pocket_radius, notch_width, notch_depth));
flat_bin([gridx, gridy], gridz, [circle(r = pocket_radius), notch], corner_radius, rim_radius, floor_radius,
    blend_radius);
