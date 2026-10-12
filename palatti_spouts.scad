// Gridfinity holder for the Palatti Enso kettle spouts, laid out like Palatti's silicone spout case:
// the Still and Flex spouts side by side, a row of round pockets for the seals and flow restrictor
// inserts, and a pocket for the locking ring.
// Palatti publishes no part sizes. The spouts were traced from Palatti's photo of the case with the parts
// in it, scaled by the case size of 205 x 88 mm. Their centerlines are smoothing splines, and the pocket
// outlines below include a 2 mm gap around a ø 16.5 mm collar and the tube, with the same corner radii as
// rounded_corners. Compared with the case, the Still spout moves 5.5 mm and the locking ring 6 mm, so every
// pocket has a full wall and rim roundover.
// The layout is mirrored to match Palatti's photo of the empty case. A flat spout fits either way up

include <flat_bin.scad>

/* [Spouts] */
// Pocket depth. The spouts lie on their side, so this must be more than the collar diameter
spout_depth = 19; // .5

/* [Small parts] */
// Number of pockets for the seals (ø 14.5 mm) and the flow restrictor inserts (ø 15 mm)
small_parts = 5;
// Pocket diameter
small_diameter = 17.5; // .5
// Pocket depth. More than the parts are tall, the finger notches give grip
small_depth = 11; // .5

/* [Locking ring] */
locking_ring = true;
// Pocket diameter. The ring is about ø 23.5 mm
ring_diameter = 26; // .5
// Pocket depth
ring_depth = 10; // .5

/* [Finger notches] */
// Width of the notch at the outer side of each small part and ring pocket
notch_width = 12; // 1
// How far the notch goes past the pocket edge
notch_depth = 5; // 1

/* [Bin] */
gridx = 5;
gridy = 3;
// Height in 7 mm units. Use the same height for all bins in a drawer, so the tops are flush
gridz = 8;
// Smallest wall between two pockets, below the rim roundovers
wall = 1.5; // .5
// Smallest wall between a pocket and the outside, below the rim roundover
outer_wall = 2; // .5
// Roundover of the pocket rims. Must be smaller than the 8 mm inward corners of the spout pockets
rim_radius = 2.5; // .1
// Fillet between the pocket walls and the floors. Must be smaller than the 3 mm outward corners
floor_radius = 2; // .1
// Radius where a notch meets its pocket, seen from above. Must be larger than rim_radius
notch_blend = 4; // .5
// Make the parts instead of the bin, to preview the fit
show_items = false;
// Make only a plate from the bin top around the pockets, to test the fit before the full bin
test_fit = false;
// Depth of the test plate. Keep it below the depth of the shallowest pocket
test_depth = 6; // .5

/* [Hidden] */
$fa = 4;
$fs = 0.5;
// Sizes in the traced outlines, used for the preview and the checks
COLLAR_DIAMETER = 16.5;
STILL_TUBE = 9.8;
FLEX_TUBE = 7.7;
// Rough part heights, only for the preview
SMALL_HEIGHT = 9;
RING_HEIGHT = 8;
// Locking ring position, 6 mm lower than in the case
RING_CENTER = [33.1, -25.2];

// Case frame: +X along the case from the spout tips to the collars, the origin at the case center.
// Each centerline runs from the tip to the start of its collar, each collar from start to end, seal included.
// The Still spout is already moved. Made by scripts/palatti_outlines.py, change the sizes there
STILL_LINE = [[-58.58, 5.42], [-56.74, 4.75], [-54.86, 4.2], [-52.95, 3.77], [-51, 3.45], [-49.02, 3.21],
    [-47.02, 3.05], [-45.01, 2.96], [-42.97, 2.91], [-40.93, 2.9], [-38.89, 2.91], [-36.84, 2.94], [-34.8, 2.99],
    [-32.76, 3.06], [-30.72, 3.17], [-28.7, 3.32], [-26.68, 3.51], [-24.68, 3.76], [-22.7, 4.07], [-20.73, 4.44],
    [-18.78, 4.87], [-16.84, 5.36], [-14.92, 5.9], [-13.01, 6.49], [-11.12, 7.13], [-9.23, 7.82], [-7.36, 8.54],
    [-5.5, 9.3], [-3.64, 10.1], [-1.8, 10.92], [0.04, 11.77], [1.88, 12.65], [3.71, 13.54], [5.53, 14.45],
    [7.35, 15.38], [9.17, 16.31], [10.99, 17.25], [12.82, 18.18], [14.64, 19.11], [16.46, 20.03], [18.29, 20.94],
    [20.13, 21.82], [21.98, 22.67], [23.83, 23.49], [25.69, 24.28], [27.56, 25.02], [29.45, 25.72], [31.35, 26.36],
    [33.27, 26.95], [35.2, 27.47], [37.15, 27.93], [39.12, 28.31], [41.09, 28.6], [43.07, 28.78], [45.05, 28.85],
    [47.02, 28.8], [48.98, 28.6], [50.93, 28.25], [52.85, 27.73], [54.75, 27.05], [56.61, 26.23], [58.44, 25.28],
    [60.22, 24.2], [61.96, 23.03], [63.65, 21.76], [65.3, 20.7]];
STILL_COLLAR = [[65.3, 20.7], [79.7, 9.4]];
STILL_POCKET = [[57.67, 13.86], [57.9, 13.55], [58.32, 13.14], [72.59, 1.95], [72.91, 1.73], [73.44, 1.48],
    [74.01, 1.34], [74.6, 1.32], [75.18, 1.41], [75.56, 1.53], [75.91, 1.7], [76.39, 2.04], [76.8, 2.46],
    [85.87, 14.03], [86.07, 14.36], [86.28, 14.91], [86.36, 15.3], [86.38, 15.88], [86.3, 16.47], [86.09, 17.02],
    [85.79, 17.52], [85.39, 17.95], [71.27, 29.04], [70.94, 29.27], [70.59, 29.45], [70.03, 29.62], [69.44, 29.68],
    [69.05, 29.66], [67.88, 29.48], [66.87, 29.45], [65.85, 29.54], [64.86, 29.77], [63.91, 30.12], [63.45, 30.34],
    [61.7, 31.35], [59.84, 32.33], [57.49, 33.38], [54.74, 34.36], [52.27, 35.01], [50.1, 35.4], [47.62, 35.67],
    [45.16, 35.75], [42.46, 35.65], [40.16, 35.43], [38.06, 35.12], [35.79, 34.69], [33.65, 34.2], [31.42, 33.6],
    [29.29, 32.95], [27.2, 32.24], [25.03, 31.44], [23.04, 30.65], [21.1, 29.83], [17.12, 28.02], [15.22, 27.11],
    [11.49, 25.25], [4.2, 21.51], [0.68, 19.74], [-2.85, 18.04], [-4.7, 17.18], [-8.22, 15.64], [-11.58, 14.31],
    [-13.31, 13.68], [-15.05, 13.09], [-16.98, 12.49], [-18.52, 12.05], [-20.25, 11.61], [-22.24, 11.18],
    [-23.99, 10.85], [-25.76, 10.58], [-27.33, 10.38], [-29.37, 10.19], [-33.13, 9.95], [-36.93, 9.84],
    [-40.89, 9.8], [-44.66, 9.85], [-46.46, 9.93], [-48.18, 10.07], [-49.84, 10.26], [-51.84, 10.6],
    [-53.39, 10.96], [-54.85, 11.4], [-56.46, 11.98], [-57.25, 12.19], [-57.88, 12.28], [-58.5, 12.32],
    [-59.14, 12.3], [-59.68, 12.23], [-60.28, 12.1], [-60.9, 11.92], [-61.55, 11.64], [-62.12, 11.34],
    [-62.58, 11.04], [-63.14, 10.6], [-63.6, 10.15], [-64, 9.69], [-64.37, 9.17], [-64.65, 8.69], [-64.96, 8.05],
    [-65.17, 7.45], [-65.33, 6.85], [-65.43, 6.22], [-65.48, 5.51], [-65.45, 4.87], [-65.36, 4.16], [-65.21, 3.54],
    [-64.98, 2.86], [-64.72, 2.28], [-64.36, 1.66], [-63.99, 1.14], [-63.52, 0.61], [-62.97, 0.11], [-62.48, -0.26],
    [-62.02, -0.56], [-61.54, -0.81], [-61.04, -1.02], [-58.75, -1.85], [-56.29, -2.55], [-54.16, -3.02],
    [-51.79, -3.41], [-49.52, -3.67], [-47.4, -3.84], [-45.3, -3.94], [-40.96, -4], [-36.66, -3.96],
    [-32.37, -3.83], [-30.31, -3.72], [-28.18, -3.56], [-25.98, -3.35], [-23.88, -3.09], [-21.68, -2.76],
    [-19.41, -2.33], [-17.27, -1.86], [-15, -1.29], [-12.84, -0.68], [-10.77, -0.03], [-8.79, 0.64], [-6.87, 1.33],
    [-4.83, 2.12], [-2.75, 2.97], [-0.8, 3.81], [3.02, 5.55], [8.67, 8.31], [19.57, 13.87], [23.12, 15.6],
    [26.5, 17.13], [29.94, 18.54], [31.65, 19.18], [33.36, 19.76], [35.31, 20.35], [36.76, 20.75], [38.44, 21.14],
    [40.45, 21.53], [42.12, 21.76], [43.75, 21.9], [45.33, 21.94], [46.86, 21.88], [48.33, 21.7], [49.74, 21.42],
    [51.1, 21.03], [52.46, 20.52], [53.15, 20.2], [53.61, 19.94], [54.48, 19.32], [55.27, 18.59], [55.94, 17.77],
    [56.51, 16.86], [56.94, 15.89], [57.39, 14.38]];
FLEX_LINE = [[-81.33, -16.4], [-80.58, -18.53], [-79.68, -20.51], [-78.64, -22.33], [-77.47, -24.01],
    [-76.18, -25.55], [-74.77, -26.94], [-73.27, -28.19], [-71.66, -29.3], [-69.98, -30.28], [-68.22, -31.13],
    [-66.39, -31.85], [-64.51, -32.44], [-62.59, -32.91], [-60.62, -33.25], [-58.63, -33.48], [-56.62, -33.6],
    [-54.6, -33.6], [-52.58, -33.49], [-50.57, -33.28], [-48.57, -32.96], [-46.61, -32.54], [-44.67, -32.03],
    [-42.75, -31.44], [-40.85, -30.78], [-38.97, -30.06], [-37.1, -29.29], [-35.25, -28.49], [-33.42, -27.66],
    [-31.59, -26.81], [-29.77, -25.96], [-27.95, -25.1], [-26.14, -24.25], [-24.33, -23.39], [-22.53, -22.54],
    [-20.73, -21.67], [-18.94, -20.8], [-17.15, -19.92], [-15.36, -19.03], [-13.57, -18.13], [-11.78, -17.21],
    [-10, -16.28], [-8.21, -15.34], [-6.42, -14.39], [-4.63, -13.44], [-2.84, -12.48], [-1.04, -11.53],
    [0.76, -10.59], [2.56, -9.66], [4.37, -8.75], [6.19, -7.85], [8.02, -6.98], [9.85, -6.14], [11.7, -5.33],
    [13.55, -4.55], [15.42, -3.81], [17.3, -3.11], [19.19, -2.45], [21.1, -1.85], [23.02, -1.3], [24.95, -0.81],
    [26.91, -0.38], [28.87, -0.02], [30.84, 0.26], [32.81, 0.46], [34.79, 0.57], [36.76, 0.59], [38.72, 0.49],
    [40.67, 0.29], [42.61, -0.03], [44.52, -0.48], [46.42, -1.06], [48.28, -1.76], [50.11, -2.58], [51.91, -3.53],
    [53.65, -4.59], [55.35, -5.77], [57, -7.06], [58.58, -8.46], [60.1, -9.96], [61.6, -11.1]];
FLEX_COLLAR = [[61.6, -11.1], [76.7, -27.5]];
FLEX_POCKET = [[68.48, -33.71], [68.77, -33.98], [69.25, -34.31], [69.61, -34.47], [70.18, -34.63], [70.76, -34.67],
    [71.15, -34.64], [71.54, -34.55], [71.9, -34.42], [72.25, -34.24], [72.72, -33.88], [83.53, -23.92],
    [83.78, -23.62], [83.99, -23.29], [84.22, -22.75], [84.31, -22.37], [84.36, -21.78], [84.28, -21.2],
    [84.1, -20.64], [83.92, -20.29], [83.69, -19.97], [69.08, -4.09], [68.79, -3.82], [68.48, -3.59], [68.13, -3.4],
    [67.76, -3.26], [67.38, -3.16], [66.99, -3.12], [66.6, -3.13], [65.52, -3.31], [65, -3.36], [64.47, -3.37],
    [63.42, -3.29], [62.4, -3.08], [61.41, -2.73], [60.93, -2.51], [60.03, -1.98], [58.72, -0.98], [56.96, 0.24],
    [54.6, 1.66], [52.77, 2.63], [50.76, 3.54], [48.08, 4.55], [45.94, 5.19], [43.48, 5.75], [41.19, 6.12],
    [39.07, 6.33], [37.06, 6.43], [34.68, 6.42], [32.19, 6.28], [29.95, 6.05], [27.86, 5.74], [25.8, 5.36],
    [23.47, 4.85], [21.45, 4.33], [19.45, 3.76], [17.25, 3.06], [15.29, 2.39], [13.29, 1.64], [11.35, 0.87],
    [9.3, 0.01], [7.38, -0.84], [3.6, -2.61], [-1.97, -5.42], [-12.73, -11.11], [-18, -13.81], [-25.07, -17.26],
    [-35.89, -22.35], [-39.46, -23.93], [-41.22, -24.66], [-42.97, -25.32], [-44.71, -25.92], [-46.43, -26.44],
    [-48.15, -26.88], [-49.85, -27.24], [-51.13, -27.44], [-52.83, -27.64], [-54.97, -27.75], [-56.67, -27.74],
    [-57.9, -27.67], [-59.54, -27.49], [-61.63, -27.12], [-62.68, -26.86], [-64.18, -26.41], [-65.6, -25.87],
    [-66.14, -25.63], [-67.51, -24.95], [-68.79, -24.18], [-69.98, -23.31], [-71.09, -22.35], [-72.11, -21.3],
    [-73.04, -20.15], [-73.48, -19.51], [-74.29, -18.16], [-75.01, -16.66], [-75.99, -14.03], [-76.26, -13.49],
    [-76.62, -12.95], [-77.19, -12.28], [-77.59, -11.91], [-77.98, -11.61], [-78.74, -11.16], [-79.24, -10.94],
    [-79.69, -10.79], [-80.34, -10.64], [-80.94, -10.57], [-81.61, -10.56], [-82.34, -10.64], [-82.99, -10.79],
    [-83.56, -10.99], [-84.16, -11.28], [-84.79, -11.68], [-85.3, -12.1], [-85.72, -12.54], [-86.13, -13.06],
    [-86.53, -13.71], [-86.83, -14.39], [-87.02, -15.03], [-87.13, -15.62], [-87.18, -16.29], [-87.15, -17.05],
    [-87.01, -17.81], [-86.84, -18.38], [-86.08, -20.53], [-84.95, -23.04], [-83.66, -25.34], [-82.19, -27.46],
    [-80.57, -29.41], [-78.8, -31.17], [-76.7, -32.92], [-74.7, -34.3], [-72.61, -35.5], [-70.46, -36.53],
    [-68.11, -37.44], [-65.81, -38.14], [-63.69, -38.65], [-61.72, -39], [-59.22, -39.3], [-56.59, -39.45],
    [-54.36, -39.44], [-52.03, -39.31], [-49.71, -39.06], [-47.38, -38.68], [-45.18, -38.21], [-42.92, -37.61],
    [-40.78, -36.95], [-38.8, -36.26], [-36.85, -35.51], [-34.73, -34.64], [-30.94, -32.96], [-21.81, -28.67],
    [-16.34, -26.04], [-12.69, -24.24], [-9.04, -22.38], [1.66, -16.72], [5.19, -14.89], [8.78, -13.1],
    [12.2, -11.5], [14.08, -10.67], [17.44, -9.3], [19.18, -8.65], [20.93, -8.04], [22.89, -7.42], [24.66, -6.92],
    [26.43, -6.47], [28.2, -6.09], [29.66, -5.82], [31.38, -5.57], [33.45, -5.36], [34.77, -5.29], [36.42, -5.27],
    [38.5, -5.36], [39.64, -5.48], [41.2, -5.73], [43.25, -6.21], [44.77, -6.69], [45.81, -7.08], [47.32, -7.74],
    [48.97, -8.61], [49.81, -9.21], [50.57, -9.9], [50.92, -10.29], [51.53, -11.12], [52.03, -12.02],
    [52.23, -12.49], [52.55, -13.47], [52.73, -14.49], [52.8, -15.76], [52.91, -16.34], [53.13, -16.88],
    [53.34, -17.22], [53.58, -17.53]];

top = fromGridfinityUnits(gridz);
size = [gridx * GRID_DIMENSIONS_MM.x, gridy * GRID_DIMENSIONS_MM.y] - BASE_GAP_MM;
// Distance between two pocket outlines, so the rims leave a wall between them
spacing = wall + 2 * rim_radius;
spout_points = concat(STILL_POCKET, FLEX_POCKET);

// The row of small parts starts at the left end of the spouts and sits one spacing above the Still pocket
small_pitch = small_diameter + spacing;
small_x = [for (i = [0 : small_parts - 1]) min([for (p = spout_points) p.x]) + small_diameter / 2 + i * small_pitch];
small_reach = small_diameter / 2 + spacing;
small_y = max([for (p = STILL_POCKET) if (p.x >= small_x[0] - small_reach && p.x <= last(small_x) + small_reach) p.y])
    + spacing + small_diameter / 2;
small_centers = [for (x = small_x) [x, small_y]];

// Round pocket at center with a finger notch toward angle, away from the spouts
function notched(center, diameter, angle) = rounded_corners(move(center, p = [circle(d = diameter),
    zrot(angle, p = finger_notch(diameter / 2, notch_width, notch_depth))]), 3, notch_blend);
small_pockets = [for (c = small_centers) notched(c, small_diameter, 90)];
ring_pocket = locking_ring ? notched(RING_CENTER, ring_diameter, -90) : [];

// Center all pockets in the bin
content = pointlist_bounds(concat(spout_points, flatten(small_pockets), ring_pocket));
shift = -(content[0] + content[1]) / 2;
room = size - 2 * [1, 1] * (outer_wall + rim_radius);
echo(str("The pockets need ", content[1] - content[0], " mm, the bin has room for ", room, " mm"));
assert(content[1].x - content[0].x <= room.x, "The pockets are too wide, use a bigger gridx");
assert(content[1].y - content[0].y <= room.y, "The pockets are too deep, use a bigger gridy");
assert(spout_depth > COLLAR_DIAMETER, "The spout pocket must be deeper than the collar diameter");
assert(rim_radius < 8 && floor_radius < 3, "The roundovers must be smaller than the spout pocket corners");
assert(notch_blend > rim_radius, "notch_blend must be larger than rim_radius");
assert(small_depth > SMALL_HEIGHT && ring_depth > RING_HEIGHT, "The parts must sit below the bin top");
assert(test_depth < min(spout_depth, small_depth, ring_depth), "The test plate must be shallower than the pockets");

// Pockets and parts are placed in the case frame, then centered and mirrored like the photo of the empty case
module layout() {
    xflip() translate(point3d(shift)) children();
}

module spout(line, collar, tube) {
    // The tube starts on the collar axis, both rest on the pocket floor
    z = top - spout_depth + COLLAR_DIAMETER / 2;
    path_sweep(circle(d = tube), path3d(line, z));
    translate(point3d(collar[0], z)) rot(from = UP, to = point3d(unit(collar[1] - collar[0])))
        cylinder(d = COLLAR_DIAMETER, h = norm(collar[1] - collar[0]));
}

if (show_items)
    layout() {
        spout(STILL_LINE, STILL_COLLAR, STILL_TUBE);
        spout(FLEX_LINE, FLEX_COLLAR, FLEX_TUBE);
        for (c = small_centers)
            translate(point3d(c, top - small_depth))
            tube(od = small_diameter - 2.5, wall = 1.5, h = SMALL_HEIGHT, anchor = BOTTOM);
        if (locking_ring)
            translate(point3d(RING_CENTER, top - ring_depth))
            tube(od = ring_diameter - 2.5, wall = 4, h = RING_HEIGHT, anchor = BOTTOM);
    }
else if (test_fit)
    fit_gauge(size, top, test_depth) bin();
else
    bin();

module bin()
    flat_bin([gridx, gridy], gridz) layout() {
        for (pocket = [STILL_POCKET, FLEX_POCKET])
            flat_pocket(pocket, top, spout_depth, rim_radius, floor_radius);
        for (pocket = small_pockets)
            flat_pocket(pocket, top, small_depth, rim_radius, floor_radius);
        if (locking_ring)
            flat_pocket(ring_pocket, top, ring_depth, rim_radius, floor_radius);
    }
