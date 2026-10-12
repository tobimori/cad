// Gridfinity holder for the EDEKA zuhause nutmeg grater, lying on its round side with the flat back up, just
// below the bin top. Below its widest part, the pocket follows the grater shape with a small gap, so the
// grater sits in a cradle and does not slide or turn. Above it, the walls go straight up along the grater
// outline, so it lifts out. In the middle, the walls flare out smoothly at both sides, so fingers slide down
// and pinch the grater at its widest.
// The grater is, from the lid end: a rubber lid with a flat face, a cone and a narrow collar at the tip, all
// round with a flat back. A rubber loop to hang the grater hinges at the flat back edge of the lid face, and
// sticks out past the lid face, flush with the flat back. It lies in a shallow recess at the bin top.
// Sizes are from photos with a ruler. Measure the diameters with a paper strip: wrap it once around,
// mark the overlap, diameter = length / pi

include <flat_bin.scad>

/* [Grater] */
// Length from the lid face to the tip
grater_length = 155.5; // .5
// Diameter of the lid at the face, the widest part
lid_diameter = 45.5; // .1
// Diameter of the lid at the cone. The lid gets a bit narrower toward the cone
lid_back_diameter = 43; // .1
// Length of the lid, from the lid face to the cone
lid_length = 13; // .5
// Radius of the rounded edge around the lid face
lid_edge_radius = 1; // .5
// Diameter of the cone at the lid
cone_diameter = 35.5; // .1
// Diameter of the cone at the tip collar
cone_tip_diameter = 20.5; // .1
// Diameter of the collar at the tip
collar_diameter = 18; // .1
// Length of the collar at the tip
collar_length = 12; // .5
// Radius of the other rounded edges
edge_radius = 1; // .5
// Height of the lid top above the flat back
lid_height = 37.5; // .5
// Height of the tip collar top above the flat back
tip_height = 14.5; // .5
// Size of the hanging loop: width, how far it reaches past the lid face, thickness
loop_size = [28, 16, 3]; // .5

/* [Fit] */
// Gap around the grater, on the radius. About 0.5 for a snug fit with measured sizes, more for photo sizes
clearance = 1.5; // .1
// Gap at each end
end_clearance = 2; // .5
// How far the flat back and the loop are below the bin top
sink = 0.5; // .5

/* [Finger flare] */
// Distance from the lid face to the flare center
flare_position = 80; // 1
// Length of the flare along the grater, at the bin top
flare_length = 44; // 1
// How far the walls flare out at each side, at the bin top. From there they slope down to the axis
flare_width = 14; // .5

/* [Bin] */
gridx = 5;
gridy = 2;
// Height in 7 mm units. Use the same height for all bins in a drawer, so the tops are flush
gridz = 8;
// Smallest wall between the pocket and the outside, below the rim roundover
outer_wall = 2; // .5
// Roundover of the pocket rim
rim_radius = 2.5; // .1
// Make the grater instead of the bin, to preview the fit
show_items = false;
// Make only a short slice of the lid end and of the tip end, to test the fit before the full bin
test_fit = false;
// Length of each test slice past the lid or the cone end, and floor below the cradle
test_length = 10; // 1
test_floor = 2; // .5
// Height of the test slices above the widest part of the grater. The cradle below it sets the fit
test_above = 2; // .5

/* [Hidden] */
$fa = 4;
$fs = 0.5;

top = fromGridfinityUnits(gridz);
size = [gridx * GRID_DIMENSIONS_MM.x, gridy * GRID_DIMENSIONS_MM.y] - BASE_GAP_MM;
room = size - 2 * [1, 1] * (outer_wall + rim_radius);
// Height of the pocket axis at the lid face. The grater rests in the bottom of the cradle, clearance lower,
// with the flat back sink below the bin top
axis = top - sink - back(0) + clearance;
// Lid face position, so the loop and the grater are centered together
lid_end = -(grater_length - loop_size.y) / 2;
// Depth of the loop recess, below the bin top
loop_depth = sink + loop_size.z + clearance;
assert(axis - lid_diameter / 2 - clearance >= BASE_HEIGHT + 1, "The cradle is deeper than the bin");
assert(loop_depth >= rim_radius + 1, "The loop recess is too shallow for the rim, use a larger sink");
assert(grater_length + loop_size.y + 2 * end_clearance <= room.x, "The grater is too long, use a bigger gridx");
assert(lid_diameter + 2 * clearance <= room.y, "The grater is too wide, use a bigger gridy");
// Widest pocket half at the flare, from the cone radius at the flare center
flare_reach = clearance + flare_width + rim_radius
    + lookup(flare_position, [[lid_length, cone_diameter / 2], [grater_length, cone_tip_diameter / 2]]);
assert(flare_reach <= size.y / 2 - outer_wall, "The flare cuts through the wall, use a smaller flare_width");

// Distance from the grater axis to the flat back at x. The back is flat from the lid to the tip
function back(x) = lerp(lid_height - lid_diameter / 2, tip_height - collar_diameter / 2,
    constrain(x / grater_length, 0, 1));

// Side view of the upper half as [distance from the lid face, radius], from the lid face to the tip, larger
// by gap and end_gap
function profile(gap, end_gap) = let (
    // The lid face edge, a quarter circle from the face to the widest part
    lid = [for (a = [180 : -15 : 90]) lid_edge_radius * [1 + cos(a), sin(a)] + [0, lid_diameter / 2 - lid_edge_radius]])
    concat(
        // The lid face edge moves toward the lid face by the end gap, the steps after it toward the tip by the gap
        // The widest part stays in place, so the gap along the lid side stays the same
        [for (p = lid) p + [-end_gap, gap]], end_gap > 0 ? [[lid_edge_radius, lid_diameter / 2 + gap]] : [], [
        [lid_length + gap, lid_back_diameter / 2 + gap],
        [lid_length + gap, cone_diameter / 2 + gap],
        // Steps in move toward the tip by the gap
        [grater_length - collar_length + gap, cone_tip_diameter / 2 + gap],
        [grater_length - collar_length + gap, collar_diameter / 2 + gap],
        [grater_length + end_gap, collar_diameter / 2 + gap],
    ]);

// A profile with rounded edges, closed along the axis. Corners on the axis and the small turns of the lid edge
// stay sharp, short edges like the step to the tip collar get smaller radii, so both corners fit
function rounded(outline) = let (
    half = concat([[outline[0].x, 0]], outline, [[last(outline).x, 0]]),
    n = len(half),
    edge = function(i, j) max(0, norm(half[j] - half[i]) / 2 - 0.01),
    turn = function(i) vector_angle(half[i] - half[(i + n - 1) % n], half[(i + 1) % n] - half[i]),
    radii = [for (i = idx(half)) i == 0 || i == n - 1 || turn(i) < 30 ? 0
        : min(edge_radius, edge(i - 1, i), edge(i, (i + 1) % n))])
    round_corners(half, radius = radii, closed = true);

// How far the walls flare out at x, at the bin top. Zero with zero slope at both ends of the flare
function flare(x) = abs(x - flare_position) < flare_length / 2
    ? flare_width * cos(180 * (x - flare_position) / flare_length) ^ 2 : 0;

// Tilt of the grater axis: the flat back is level, so the axis rises toward the tip
tilt = atan((back(0) - back(grater_length)) / grater_length);

// The hanging loop, out from the lid face toward -X: a rounded triangle with a hole, wide at the hinge
module loop() {
    end = loop_size.y - loop_size.x / 3;
    module outline(start, inset)
        hull() {
            translate([-start, -loop_size.x / 2 + inset]) square([0.01, loop_size.x - 2 * inset]);
            translate([-end, 0]) circle(r = loop_size.x / 3 - inset);
        }
    linear_extrude(loop_size.z) difference() {
        // Starts at the hinge
        intersection() {
            outline(-lid_edge_radius, 0);
            translate([-loop_size.y, -loop_size.x / 2]) square([loop_size.y, loop_size.x]);
        }
        offset(r = 2) outline(2, 6);
    }
}

// Solid of revolution along +X from the lid face at x = 0
module revolved(outline) {
    yrot(90) rotate_extrude() polygon([for (p = rounded(outline)) [p.y, p.x]]);
}

// Top view of the loop recess, from past the loop end into the grater pocket. Its outer corners round like
// the loop end
function loop_recess() = let (
    x = [-loop_size.y - end_clearance, 6],
    round = loop_size.x / 3 + clearance)
    move([lid_end + (x[0] + x[1]) / 2, 0],
        p = rect([x[1] - x[0], loop_size.x + 2 * clearance], rounding = [3, round, round, 3]));

module bin() {
    flat_bin([gridx, gridy], gridz) {
        translate([lid_end, 0, axis])
            cradle_pocket([for (p = rounded(profile(clearance, end_clearance))) if (p.y > 0.001) p], top - axis,
                rim_radius, flare = function(x) flare(x), tilt = tilt);
        flat_pocket(loop_recess(), top, loop_depth, rim_radius, 1);
    }
}

if (show_items)
    // Rests in the bottom of the cradle with the flat back level, so the axis rises toward the tip
    translate([lid_end, 0, axis - clearance]) {
        intersection() {
            yrot(-tilt) revolved(profile(0, 0));
            translate([-1, -lid_diameter, -lid_diameter])
                cube([grater_length + 2, 2 * lid_diameter, lid_diameter + back(0)]);
        }
        up(back(0) - loop_size.z) loop();
    }
else if (test_fit) {
    // Each slice keeps the end wall, the cradle and the walls beside it, on a thin floor
    bottom = axis - lid_diameter / 2 - clearance - test_floor;
    width = lid_diameter + 2 * (clearance + outer_wall + rim_radius);
    slices = [[-size.x / 2, lid_end + lid_length + test_length],
        [lid_end + grater_length - collar_length - test_length, size.x / 2]];
    down(bottom) intersection() {
        bin();
        for (x = slices) translate([x[0], -width / 2, bottom])
            cube([x[1] - x[0], width, axis + grater_length * sin(tilt) + test_above - bottom]);
    }
} else
    bin();
