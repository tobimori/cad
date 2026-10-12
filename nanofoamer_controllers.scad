// Gridfinity holder for the 3 magnetic flow controllers of the Subminimal NanoFoamer PRO. Each controller
// stands on its long edge in its own slot, shaped like its side view: a wedge from the thick end down to
// the thin end. The middle one is turned around, so the curved sides of two controllers nest. The slots are
// less deep than the controllers are wide, so their tops stand out to pinch them.
// The side view is traced from a photo with a ruler

include <flat_bin.scad>

/* [Flow controllers] */
controllers = 3; // [1:3]
// Length of a flow controller
controller_length = 66; // .5
// Height of the thick end, seen from the side
controller_thickness = 18.3; // .1
// Width, which is the height when the controller stands on its edge
controller_width = 26; // .5
// Gap around each controller
clearance = 0.75; // .05
// Slot depth. Less than controller_width, so the controllers stand out to pinch them
depth = 16; // .5

/* [Bin] */
gridx = 2;
gridy = 2;
// Height in 7 mm units. Use the same height for all bins in a drawer, so the tops are flush
gridz = 8;
// Smallest wall between two slots, below the rim roundovers
wall = 1.5; // .5
// Smallest wall between a slot and the outside, below the rim roundover
outer_wall = 2; // .5
// Radius of the slot corners, seen from above. Must be larger than floor_radius
corner_radius = 3; // .5
// Roundover of the slot rims
rim_radius = 2.5; // .1
// Fillet between the slot walls and the floor
floor_radius = 2; // .1
// Make the controllers instead of the bin, to preview the fit
show_items = false;
// Make only a plate from the bin top around the pockets, to test the fit before the full bin
test_fit = false;
// Depth of the test plate
test_depth = 6; // .5

/* [Hidden] */
$fa = 4;
$fs = 0.5;
// Side view of the top edge as [distance from the thick end, height], for a controller 66 mm long and
// 18.3 mm thick. The bottom edge is straight
TRACE = [[0, 15], [2, 17.4], [5, 18.3], [7.6, 18.1], [10.7, 17.7], [13.9, 17], [17, 16], [20.2, 14.8],
    [23.4, 13.5], [26.5, 12.2], [29.7, 10.9], [32.9, 9.5], [36, 8.4], [39.2, 7.5], [42.3, 6.6], [45.5, 6],
    [51.8, 5.2], [55, 5], [66, 5]];

top = fromGridfinityUnits(gridz);
size = [gridx * GRID_DIMENSIONS_MM.x, gridy * GRID_DIMENSIONS_MM.y] - BASE_GAP_MM;
room = size - 2 * [1, 1] * (outer_wall + rim_radius);
// Distance between two slot outlines, so the rims leave a wall between them
spacing = wall + 2 * rim_radius;

// Side view of a controller, grown by gap, with the bottom edge at y = 0 and the thick end at x = 0
function side(gap) = let (
    scale = [controller_length / 66, controller_thickness / 18.3],
    trace = [for (p = TRACE) v_mul(p, scale)],
    // A smooth curve through the traced points up to the straight thin end, so the slot has no facets. It
    // starts straight up from the thick end and ends level, so it meets both without a corner
    curve = list_head(trace),
    tangents = [for (i = idx(curve)) i == 0 ? [0, 1] : i == len(curve) - 1 ? [1, 0]
        : unit(curve[i + 1] - curve[i - 1])],
    edge = concat(smooth_path(curve, tangents = tangents, splinesteps = 8), [last(trace)]),
    outline = concat([[0, 0], [controller_length, 0]], reverse(edge)),
    // Round the corners at the bottom edge, both corners at the thin end share its height
    thin = min(corner_radius, last(edge).y / 2 - 0.05),
    radii = [for (i = idx(outline)) i == 0 ? corner_radius : i == 1 || i == 2 ? thin : 0])
    grown(round_corners(outline, radius = radii, closed = true), gap);

// Height of the top edge at x, grown by the gap
function height_at(x) = lookup(x / controller_length * 66, TRACE) * controller_thickness / 18.3;
// Distance between the bottom edges of two nested controllers, the second one turned around. Measured
// straight across, which is shorter than the real distance on the slopes, so the spacing gets 10 % more
nest = max([for (x = [0 : 1 : controller_length]) height_at(x) + height_at(controller_length - x)])
    + 2 * clearance + 1.1 * spacing;
// Slot positions as [bottom edge y, turned around]: the first two nest, the third stands back to back
// with the second
layout = [[0, false], [nest, true], [nest + 2 * clearance + spacing, false]];
slots = [for (i = [0 : controllers - 1]) let (s = layout[i])
    s[1] ? move([controller_length, s[0]], p = zrot(180, p = side(clearance))) : move([0, s[0]], p = side(clearance))];
// Center all slots in the bin
bounds = pointlist_bounds(flatten(slots));
shift = -(bounds[0] + bounds[1]) / 2;
echo(str("The slots need ", bounds[1] - bounds[0], " mm, the bin has room for ", room, " mm"));
assert(bounds[1].x - bounds[0].x <= room.x, "The slots are too long, use a bigger gridx");
assert(bounds[1].y - bounds[0].y <= room.y, "The slots are too wide, use a bigger gridy");
assert(depth < controller_width, "The controllers must stand out of the slots to pinch them");

module bin() {
    flat_bin([gridx, gridy], gridz)
        for (slot = slots)
            flat_pocket(move(shift, p = slot), top, depth, rim_radius, floor_radius);
}

if (show_items)
    for (i = [0 : controllers - 1]) let (s = layout[i])
        translate(point3d(shift + [s[1] ? controller_length : 0, s[0]], top - depth)) zrot(s[1] ? 180 : 0)
        linear_extrude(controller_width) polygon(side(0));
else if (test_fit)
    fit_gauge(size, top, test_depth) bin();
else
    bin();
