// Gridfinity holder for the Codale coffee paper presser, lying on its side, so it fits under a 90 mm drawer.
// The presser is two cones of 20 fins, joined at the widest ring, with a stem and a ball handle on the top
// cone. Below the axis, the pocket follows the presser shape with a small gap, so it sits in a cradle and does
// not roll. Above the axis, the walls go straight up, and flare out beside the widest ring, so fingers reach
// it. The upper half stands out of the bin, to lift it out.
// Sizes are from Codale: 77 mm wide and 93 mm high. The others are from Codale's side photo, scaled to them

include <flat_bin.scad>

/* [Presser] */
// Diameter of the widest ring
presser_diameter = 77; // .5
// Height from the bottom to the top of the ball
presser_height = 93; // .5
// Height of the widest ring above the bottom
widest_height = 40; // .5
// Radius of the rounded fin edges at the widest ring, seen from the side. Both cones are straight up to it
ridge_radius = 8; // .5
// Diameter of the flat bottom, where the fins end
bottom_diameter = 31.5; // .5
// Height of the top of the upper cone, where the stem starts
plate_height = 59.5; // .5
// Diameter of the top of the upper cone, around the stem
plate_diameter = 8; // .5
stem_diameter = 4; // .1
ball_diameter = 12.5; // .1
// Radius of the rounded bottom edge and the stem ends. Must be larger than clearance
edge_radius = 2; // .5

/* [Fit] */
// Gap around the presser
clearance = 1.5; // .1
// Floor below the cradle
floor_thickness = 1.5; // .5
// Height from the baseplate to the top of the drawer wall, or to whatever is above the drawer
drawer_height = 90; // 1

/* [Finger flare] */
// Length of the flare along the axis, centered on the widest ring, at the bin top
flare_length = 40; // 1
// How far the walls flare out at each side, at the bin top
flare_width = 12; // .5

/* [Bin] */
gridx = 3;
gridy = 3;
// Height in 7 mm units. Use the same height for all bins in a drawer, so the tops are flush
gridz = 8;
// Smallest wall between the pocket and the outside, below the rim roundover
outer_wall = 2; // .5
// Roundover of the pocket rim
rim_radius = 2.5; // .1
// Make the presser instead of the bin, to preview the fit
show_items = false;
// Make only a plate from the bin top around the pocket, to test the fit before the full bin. Lay the presser
// on its side and put the plate over it
test_fit = false;
// How far the test plate goes below the presser axis
test_below = 2; // .5

/* [Hidden] */
$fa = 4;
$fs = 0.5;
FINS = 20;
// Thickness of a fin, for the preview
FIN_THICKNESS = 1.5;

top = fromGridfinityUnits(gridz);
size = [gridx * GRID_DIMENSIONS_MM.x, gridy * GRID_DIMENSIONS_MM.y] - BASE_GAP_MM;
room = size - 2 * [1, 1] * (outer_wall + rim_radius);
// Height of the presser axis, resting on the bottom of the cradle
axis = BASE_HEIGHT + floor_thickness + presser_diameter / 2;
// Bottom of the presser, so the presser is centered along the bin
bottom = -presser_height / 2;
assert(edge_radius > clearance, "edge_radius must be larger than clearance");
assert(presser_height + 2 * clearance <= room.x, "The presser is too long, use a bigger gridx");
assert(presser_diameter + 2 * clearance <= room.y, "The presser is too wide, use a bigger gridy");
assert(axis + presser_diameter / 2 <= drawer_height - 2, "The presser does not fit under the drawer");
assert(presser_diameter / 2 + clearance + flare_width + rim_radius <= size.y / 2 - outer_wall,
    "The flare cuts through the wall, use a smaller flare_width");

// Side view of the upper half as [height above the bottom, radius], from the bottom to the top of the ball,
// closed along the axis, with rounded edges
function profile() = let (
    base = [0, bottom_diameter / 2],
    plate = [plate_height, plate_diameter / 2],
    // The fin edge: straight cones from the bottom and from the top plate, tangent to the round ridge
    ridge = [widest_height, presser_diameter / 2 - ridge_radius],
    outer = function(points) points[0].y > points[1].y ? points[0] : points[1],
    from = outer(circle_point_tangents(r = ridge_radius, cp = ridge, pt = base)),
    to = outer(circle_point_tangents(r = ridge_radius, cp = ridge, pt = plate)),
    angles = [atan2(from.y - ridge.y, from.x - ridge.x), atan2(to.y - ridge.y, to.x - ridge.x)],
    steps = ceil((angles[0] - angles[1]) / $fa),
    fins = concat([base], [for (i = [0 : steps]) ridge + ridge_radius
        * [cos(lerp(angles[0], angles[1], i / steps)), sin(lerp(angles[0], angles[1], i / steps))]], [plate]),
    ball = ball_diameter / 2,
    center = presser_height - ball,
    // Where the stem meets the ball
    neck = asin(stem_diameter / ball_diameter),
    path = concat([[0, 0]], fins, [
        [plate_height + edge_radius, stem_diameter / 2],
        [center - ball * cos(neck), stem_diameter / 2]],
        // The arc starts a bit past the stem, so the rounded corner at the stem end fits
        [for (a = [150 - neck : -10 : 1]) [center + ball * cos(a), ball * sin(a)]],
        [[presser_height, 0]]),
    // Round the bottom edge and both stem ends. They need a larger radius than the gap, so the grown profile
    // stays valid
    corners = [1, len(fins) + 1, len(fins) + 2],
    radii = [for (i = idx(path)) in_list(i, corners) ? edge_radius : 0])
    round_corners(path, radius = radii, closed = true);

// The presser upper half grown by gap, without the points on the axis
function grown_profile(gap) = let (path = profile())
    [for (p = reverse(grown(reverse(path), gap))) if (p.y > 0.001) p];

// How far the walls flare out at x, at the bin top. Zero with zero slope at both ends of the flare
function flare(x) = abs(x - widest_height) < flare_length / 2
    ? flare_width * cos(180 * (x - widest_height) / flare_length) ^ 2 : 0;

module presser() {
    yrot(90) {
        // Fins up to the top plate, around a hub
        intersection() {
            rotate_extrude() polygon([for (p = profile()) [p.y, p.x]]);
            union() {
                for (i = [0 : FINS - 1]) zrot(360 * i / FINS)
                    translate([0, -FIN_THICKNESS / 2, 0]) cube([presser_diameter, FIN_THICKNESS, plate_height]);
                cylinder(d = bottom_diameter, h = plate_height);
            }
        }
        // Top plate, stem and ball
        intersection() {
            rotate_extrude() polygon([for (p = profile()) [p.y, p.x]]);
            up(plate_height - 1) cylinder(d = presser_diameter, h = presser_height);
        }
    }
}

module bin() {
    flat_bin([gridx, gridy], gridz) translate([bottom, 0, axis + clearance])
        cradle_pocket(grown_profile(clearance), top - axis - clearance, rim_radius, flare = function(x) flare(x));
}

if (show_items)
    // Rests on the widest ring in the bottom of the cradle
    translate([bottom, 0, axis]) presser();
else if (test_fit)
    fit_gauge(size, top, top - axis + test_below) bin();
else
    bin();
