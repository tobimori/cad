// Preview of bins side by side in a drawer, not for printing. Export the bins to out/ first

// [STL file, grid size, grid position of the front left base]
bins = [
    ["out/cafec_abaca_cup1.stl", [3, 3], [0, 0]],
    ["out/aeropress_filters.stl", [2, 2], [3, 1]],
    ["out/spice_jars.stl", [5, 2], [0, 3]],
];

// The bin STLs are centered on the origin
for (bin = bins)
    translate(42 * (bin[2] + bin[1] / 2)) import(bin[0]);
