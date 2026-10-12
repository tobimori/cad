// Solid Gridfinity bins with a flat top, in the style of Scott Yu-Jan's drawer bins.
// Square and sharp outside, so bins side by side read as one surface with thin seams.
// Soft inside: the pocket has a rounded rim and a fillet at the floor.
// Uses gridfinity-rebuilt-openscad 2.0.0 for the spec base and BOSL2 v2.0.769 for the rounding, both in lib/.
// Include this file, BOSL2 needs its global settings in the main file

include <lib/BOSL2/std.scad>
include <lib/BOSL2/rounding.scad>
include <lib/gridfinity-rebuilt-openscad/src/core/standard.scad>
use <lib/gridfinity-rebuilt-openscad/src/core/bin.scad>
use <lib/gridfinity-rebuilt-openscad/src/core/gridfinity-rebuilt-utility.scad>

// Bin of grid_size bases and units * 7 mm height, with a pocket from the top down to the floor
// at BASE_HEIGHT. pocket is a list of closed 2D paths that overlap into one shape, centered on the bin.
// corner_radius rounds the outward pocket corners as seen from above, blend_radius the inward
// corners, for example where a finger notch meets the pocket. Children are cut from the bin too,
// for pockets that are not straight down
module flat_bin(grid_size, units, pocket = [], corner_radius = 3, rim_radius = 2.5, floor_radius = 2,
    blend_radius = 8) {
    // The floor fillet shrinks the outline by floor_radius, which would collapse smaller corners
    assert(corner_radius > floor_radius, "corner_radius must be larger than floor_radius");
    height = fromGridfinityUnits(units);
    size = [grid_size.x * GRID_DIMENSIONS_MM.x, grid_size.y * GRID_DIMENSIONS_MM.y] - BASE_GAP_MM;

    difference() {
        union() {
            bin_render_base(new_bin(grid_size, height, include_lip = false));
            // Starts on top of the feet, so the square corners stay above the baseplate
            translate([0, 0, BASE_PROFILE_HEIGHT])
            linear_extrude(height - BASE_PROFILE_HEIGHT) square(size, center = true);
        }
        if (pocket != [])
            translate([0, 0, BASE_HEIGHT])
            offset_sweep(rounded_corners(pocket, corner_radius, blend_radius), height = height - BASE_HEIGHT,
                bottom = os_circle(r = floor_radius), top = os_circle(r = -rim_radius, extra = 1));
        children();
    }
}

// Joins 2D paths into one path, rounds its inward corners with blend and its outward corners with r.
// Blending first keeps the outline smooth, the other order leaves small kinks next to the blends
function rounded_corners(paths, r, blend) =
    let(rounded = offset(offset(offset(offset(union(paths),
        r = blend, closed = true), r = -blend, closed = true), delta = -r, closed = true), r = r, closed = true))
    assert(len(rounded) == 1, "The pocket must be one connected shape")
    rounded[0];

// Round finger notch on the +X axis, width across, that goes depth past a pocket edge at x = edge.
// A plain circle, so rounded_corners only has to blend two arcs where it meets a round pocket
function finger_notch(edge, width, depth) =
    assert(depth < width, "The notch must be wider than it is deep, or it does not reach the pocket")
    move([edge + depth - width / 2, 0], p = circle(d = width));
