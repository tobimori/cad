// Gridfinity holder for CAFEC Abaca cone filters, 1-2 cup size (AC1-100W, Cup1, V60 01 size)
// The filters lie flat in a pocket of their shape: a quarter circle with the crimped seam along one edge

include <flat_bin.scad>

/* [Filter] */
// Length of a straight edge of the flat filter, from the tip to the rim. CAFEC lists about 101 mm
filter_edge = 101;
// Width of the crimped seam strip along one edge. CAFEC lists about 7 mm
seam_width = 7;
// Gap around the filter
clearance = 2; // .5

/* [Bin] */
gridx = 3;
gridy = 3;
// Height in 7 mm units. Use the same height for all bins in a drawer, so the tops are flush
gridz = 8;
// Finger notch at the middle of the curved edge
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

// Tip at the origin, fold along +Y, seam below +X. Grown with sharp corners, flat_bin rounds them
filter = offset(
    concat([[0, -seam_width], [filter_edge, -seam_width]], arc(r = filter_edge, angle = [0, 90])),
    delta = clearance, closed = true);
notch = zrot(45, p = finger_notch(filter_edge + clearance, notch_width, notch_depth));
// Center the filter bounding box in the bin, with the curved edge toward the front right
pocket = zrot(-90, p = move(-[filter_edge / 2, (filter_edge - seam_width) / 2], p = [filter, notch]));

flat_bin([gridx, gridy], gridz, pocket, corner_radius, rim_radius, floor_radius, blend_radius);
