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
// for pockets that are not straight down or not down to the floor, see flat_pocket
module flat_bin(grid_size, units, pocket = [], corner_radius = 3, rim_radius = 2.5, floor_radius = 2,
    blend_radius = 8) {
    height = fromGridfinityUnits(units);
    size = [grid_size.x * GRID_DIMENSIONS_MM.x, grid_size.y * GRID_DIMENSIONS_MM.y] - BASE_GAP_MM;

    difference() {
        union() {
            bin_render_base(new_bin(grid_size, height, include_lip = false));
            // Starts on top of the feet, so the square corners stay above the baseplate
            translate([0, 0, BASE_PROFILE_HEIGHT])
            linear_extrude(height - BASE_PROFILE_HEIGHT) square(size, center = true);
        }
        if (pocket != []) {
            assert(corner_radius > floor_radius, "corner_radius must be larger than floor_radius");
            assert(blend_radius > rim_radius, "blend_radius must be larger than rim_radius");
            flat_pocket(rounded_corners(pocket, corner_radius, blend_radius), height, height - BASE_HEIGHT,
                rim_radius, floor_radius);
        }
        children();
    }
}

// Test print of the bin top: a plate of the top depth of the bin children, only about wall wide around the
// pockets, moved down to z = 0. The pockets go through it, so it shows if the items fit the pocket outlines
// before the full bin. size is the bin size, from flat_bin
module fit_gauge(size, top, depth, wall = 5) {
    bottom = top - depth;
    // All the pockets in the plate, seen from above
    module pockets() projection() difference() {
        up(bottom) linear_extrude(depth) square(size - [1, 1], center = true);
        children();
    }
    down(bottom) intersection() {
        children();
        // The pockets grown by wall. minkowski(), because offset() makes duplicate points on outlines with
        // tiny zigzags
        up(bottom) linear_extrude(depth) minkowski() {
            pockets() children();
            circle(r = wall, $fn = 16);
        }
    }
}

// Steps of the rim roundover and of the floor fillet
POCKET_STEPS = 8;

// Pocket from the bin top at z = top, depth deep, with a rounded rim and a fillet at the floor.
// outline is one closed 2D path, for example from rounded_corners. The floor fillet shrinks it by
// floor_radius and the rim roundover grows it by rim_radius, so its outward corners need a larger radius
// than floor_radius and its inward corners a larger radius than rim_radius. The pocket is one closed
// surface through the outline grown or shrunk at each height, so it has no seams
module flat_pocket(outline, top, depth, rim_radius = 2.5, floor_radius = 2) {
    assert(depth >= rim_radius + floor_radius, "The pocket is too shallow for its rim and floor radii");
    // Without very short edges: growing or shrinking moves both ends of an edge along their corners, which can
    // turn a short edge around
    path = thinned(is_polygon_clockwise(outline) ? reverse(outline) : outline, 0.3);
    bottom = top - depth;
    // Levels as [growth, height], from above the top down to the floor
    levels = concat([[rim_radius, top + 1]],
        [for (s = [POCKET_STEPS : -1 : 0]) let (a = 90 * s / POCKET_STEPS)
            [rim_radius * (1 - cos(a)), top - rim_radius + rim_radius * sin(a)]],
        [for (s = [0 : POCKET_STEPS]) let (a = 90 * s / POCKET_STEPS)
            [-floor_radius * (1 - cos(a)), bottom + floor_radius - floor_radius * sin(a)]]);
    n = len(path);
    for (d = [rim_radius, -floor_radius]) let (moved = grown(path, d))
        assert([for (j = [0 : n - 1]) if ((moved[(j + 1) % n] - moved[j]) * (path[(j + 1) % n] - path[j]) <= 0) j]
            == [], str("The pocket outline has corners too tight to grow it by ", d));
    i = function(level, j) level * n + j % n;
    // Faces go clockwise, seen from outside the pocket
    polyhedron(points = [for (level = levels) each path3d(grown(path, level[0]), level[1])], faces = concat(
        [for (l = [0 : len(levels) - 2], j = [0 : n - 1]) each [
            [i(l, j), i(l, j + 1), i(l + 1, j + 1)], [i(l, j), i(l + 1, j + 1), i(l + 1, j)]]],
        [[for (j = [n - 1 : -1 : 0]) i(0, j)]],
        [[for (j = [0 : n - 1]) i(len(levels) - 1, j)]]));
}

// A closed path with only the points at least eps from the last point kept and from the first point
function thinned(path, eps) = let (n = len(path))
    [for (i = 0, last = path[0], take = true; i < n;
        take = i + 1 < n && norm(path[i + 1] - last) >= eps && norm(path[i + 1] - path[0]) >= eps,
        last = take ? path[i + 1] : last,
        i = i + 1)
        if (take) path[i]];

// A counterclockwise closed path grown by d, or shrunk with a negative d: each point moves along its corner
// bisector, so each edge moves d. Stays valid while d is smaller than the radius of each inward corner, or
// with a negative d, of each outward corner
function grown(path, d) = let (n = len(path)) [for (i = [0 : n - 1]) let (
    a = unit(path[i] - path[(i + n - 1) % n]),
    b = unit(path[(i + 1) % n] - path[i]),
    // Outward normals of both edges, and their bisector
    normal = unit([a.y, -a.x] + [b.y, -b.x]))
    path[i] + normal * d / (normal * [a.y, -a.x])];

// Height levels of the cradle pocket walls and rim roundover, and fill steps of its top outline
CRADLE_WALL_LEVELS = 16;
CRADLE_RIM_LEVELS = 8;
CRADLE_FILL_STEPS = 150;

// Pocket for an item that lies on its side, round around its axis along +X, with the axis at z = 0 and the
// bin top at z = height. profile is the side view of its upper half as [x, radius] from one end to the other,
// with the gap and without points on the axis. The pocket is one closed surface: at each profile point, a
// cross section goes from the +Y top down the rim roundover and the wall, around the cradle below the axis,
// and up the -Y side. The walls go straight up from the widest part of the cross section to below the rim,
// and flare out by flare(x) toward the top. The top outline gets its inner corners filled, so the rim
// roundover can follow it. tilt raises the axis toward +X, and the walls stay vertical
module cradle_pocket(profile, height, rim_radius = 2.5, flare = function(x) 0, tilt = 0) {
    // Pieces of at most 0.5 mm, so the flare and the corner fill are smooth
    points = concat([for (i = [0 : len(profile) - 2]) let (p = profile[i], q = profile[i + 1],
        n = ceil(norm(q - p) / 0.5)) for (j = [0 : n - 1]) lerp(p, q, j / n)], [last(profile)]);
    top = cradle_filled([for (p = points) [p.x * cos(tilt), p.y + flare(p.x)]], CRADLE_FILL_STEPS);
    normal = cradle_normals(top);
    width = [for (w = cradle_rim_radii(top)) max(0, min(rim_radius, w - 0.2))];
    walls = height - rim_radius;
    steps = ceil(180 / $fa);
    side = function(k) let (p = points[k], rim = normal[k] * width[k], h = p.x * sin(tilt)) concat(
        [[each top[k] + rim, height + 1]],
        [for (s = [CRADLE_RIM_LEVELS : -1 : 1]) let (a = 90 * s / CRADLE_RIM_LEVELS)
            [each top[k] + rim * (1 - cos(a)), walls + rim_radius * sin(a)]],
        // The flare starts and ends with vertical walls, so it meets the cradle and the rim without a crease
        [for (m = [CRADLE_WALL_LEVELS : -1 : 0]) let (t = m / CRADLE_WALL_LEVELS)
            [each lerp([p.x * cos(tilt), p.y], top[k], (1 - cos(180 * t)) / 2), h + t * (walls - h)]]);
    // The cross section of the item, tilted
    cradle = function(k) let (p = points[k]) [for (j = [1 : steps - 1]) let (a = -180 * j / steps)
        [p.x * cos(tilt) - p.y * sin(a) * sin(tilt), p.y * cos(a), p.x * sin(tilt) + p.y * sin(a) * cos(tilt)]];
    sections = [for (k = idx(points)) let (s = side(k)) concat(s, cradle(k), reverse([for (q = s) [q.x, -q.y, q.z]]))];
    n = len(sections);
    m = len(sections[0]);
    // Index of the +Y point at the widest part, where the cradle starts
    h = len(side(0)) - 1;
    i = function(k, j) k * m + j;
    // Faces go clockwise, seen from outside the pocket
    end = function(k) concat(
        [for (j = [0 : h - 1]) [i(k, j), i(k, j + 1), i(k, m - 2 - j), i(k, m - 1 - j)]],
        [[for (j = [h : m - 1 - h]) i(k, j)]]);
    polyhedron(points = [for (section = sections) each section], faces = concat(
        [for (k = [0 : n - 2], j = [0 : m - 2]) each [
            [i(k, j), i(k + 1, j + 1), i(k + 1, j)], [i(k, j), i(k, j + 1), i(k + 1, j + 1)]]],
        [concat([for (k = [0 : n - 1]) i(k, 0)], [for (k = [n - 1 : -1 : 0]) i(k, m - 1)])],
        [for (face = end(0)) reverse(face)],
        end(n - 1)));
}

// Neighbors of each point of the +Y half of a top view outline, which continues mirrored at both ends
function cradle_neighbors(top, k) = let (mirror = function(p) [p.x, -p.y])
    [k == 0 ? mirror(top[0]) : top[k - 1], k == len(top) - 1 ? mirror(top[k]) : top[k + 1]];

// Outward normal at each point of the +Y half of a top view outline
function cradle_normals(top) = [for (k = idx(top)) let (n = cradle_neighbors(top, k), a = unit(top[k] - n[0]),
    b = unit(n[1] - top[k])) unit([-a.y, a.x] + [-b.y, b.x])];

// A top view outline with its inner corners filled: steps toward the middle of the neighbors, outward only.
// Each step widens the fill, so inner corners get a radius larger than the rim roundover
function cradle_filled(top, steps) = steps == 0 ? top : let (normal = cradle_normals(top))
    cradle_filled([for (k = idx(top)) let (n = cradle_neighbors(top, k), middle = (n[0] + n[1]) / 2)
        (middle - top[k]) * normal[k] > 0 ? middle : top[k]], steps - 1);

// Radius of each inner corner of the +Y half of a top view outline, INF at outer corners and straight parts.
// The rim roundover gets narrower at inner corners tighter than its radius, so it does not fold over itself
function cradle_rim_radii(top) = [for (k = idx(top)) let (n = cradle_neighbors(top, k), p = n[0], q = top[k],
    r = n[1], turn = cross(q - p, r - q))
    turn > 0 ? norm(q - p) * norm(r - q) * norm(r - p) / (2 * turn) : INF];

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
