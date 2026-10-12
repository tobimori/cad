"""Makes the spout centerlines and pocket outlines in palatti_spouts.scad.

The tube centerlines and collars were traced from Palatti's photo of the case with the parts in it, scaled
by the case size of 205 x 88 mm, in the case frame: +X from the spout tips to the collars, the origin at
the case center. OpenSCAD offset() fails on these outlines, so they are made here with shapely.
Prints the STILL_LINE ... FLEX_POCKET block to paste into palatti_spouts.scad:

    uv run --with numpy --with scipy --with shapely python scripts/palatti_outlines.py
"""
import numpy as np
from scipy.interpolate import splprep, splev
from shapely.geometry import LineString, Polygon

STILL_TUBE = [[-64.0, 0.3], [-60.6, -1.7], [-56.7, -2.4], [-52.7, -2.4], [-48.7, -2.3], [-44.7, -2.3],
    [-40.7, -2.3], [-36.7, -2.3], [-32.7, -2.2], [-28.7, -1.8], [-24.7, -1.1], [-20.9, -0.0], [-17.1, 1.4],
    [-13.5, 3.0], [-9.8, 4.5], [-6.3, 6.4], [-2.6, 8.0], [1.0, 9.6], [4.7, 11.3], [8.3, 13.0], [11.9, 14.6],
    [15.5, 16.4], [19.2, 17.9], [22.8, 19.6], [26.5, 21.1], [30.3, 22.4], [34.2, 23.4], [38.2, 23.7],
    [42.2, 23.5], [46.1, 22.6], [49.8, 21.0], [53.2, 19.0], [56.8, 17.3], [59.8, 15.2]]
FLEX_TUBE = [[-81.3, -16.7], [-79.4, -20.2], [-77.5, -23.8], [-75.3, -27.1], [-71.9, -29.2], [-68.3, -31.0],
    [-64.6, -32.3], [-60.7, -33.2], [-56.7, -33.5], [-52.7, -33.7], [-48.7, -33.3], [-44.8, -32.4],
    [-41.0, -31.1], [-37.4, -29.4], [-33.9, -27.5], [-30.2, -26.0], [-26.6, -24.3], [-23.0, -22.5],
    [-19.4, -20.8], [-15.8, -19.0], [-12.2, -17.3], [-8.6, -15.5], [-5.2, -13.5], [-1.5, -12.0], [2.2, -10.3],
    [5.8, -8.6], [9.4, -6.9], [13.0, -5.2], [16.6, -3.5], [20.3, -1.9], [24.1, -0.6], [28.0, 0.4], [31.9, 0.8],
    [35.9, 0.8], [39.9, 0.5], [43.8, -0.3], [47.6, -1.6], [51.2, -3.3], [54.5, -5.5], [57.6, -8.1],
    [61.6, -11.1]]
# Collar start and end, seal included
COLLAR = {"still": ([59.8, 15.2], [74.2, 3.9]), "flex": ([61.6, -11.1], [76.7, -27.5])}
# The Still spout moves, so every pocket has a full wall and rim roundover
SHIFT = {"still": (5.5, 5.5), "flex": (0, 0)}
TUBE = {"still": 9.8, "flex": 7.7}
# Collar diameter, gap around the parts, radius of the inward and the outward corners
COLLAR_D, CLEAR, BLEND, CORNER = 16.5, 2.0, 8.0, 3.0
Q = 24  # Segments per quarter circle
WIDTH = 116  # Longest line of the block


def centerline(points):
    p = np.array(points).T
    # Smoothing spline: the traced points are about 4 mm apart with about 0.3 mm noise
    tck, u = splprep(p, s=len(points) * 0.3 ** 2)
    length = np.sum(np.linalg.norm(np.diff(p, axis=1), axis=0))
    x, y = splev(np.linspace(0, 1, int(length / 2) + 1), tck)
    return np.stack([x, y], -1)


def spout(name, points):
    shift = np.array(SHIFT[name])
    line = centerline(np.array(points) + shift)
    a, b = np.array(COLLAR[name][0]) + shift, np.array(COLLAR[name][1]) + shift
    # The spline must end on the collar start, so the tube meets the collar on its axis
    line[-1] = a
    axis = (b - a) / np.linalg.norm(b - a)
    side = np.array([-axis[1], axis[0]]) * (COLLAR_D / 2 + CLEAR)
    a2, b2 = a - axis * CLEAR, b + axis * CLEAR
    collar = Polygon([a2 + side, b2 + side, b2 - side, a2 - side])
    tube = LineString(line).buffer(TUBE[name] / 2 + CLEAR, quad_segs=Q)
    shape = collar.union(tube)
    shape = shape.buffer(BLEND, quad_segs=Q).buffer(-BLEND, quad_segs=Q)
    shape = shape.buffer(-CORNER, quad_segs=Q, join_style="mitre").buffer(CORNER, quad_segs=Q)
    shape = shape.simplify(0.02)
    assert shape.is_valid and shape.geom_type == "Polygon", f"The {name} outline is broken"
    outline = np.array(shape.exterior.coords)[:-1]
    # Counterclockwise, as BOSL2 expects for a positive area
    if not shape.exterior.is_ccw:
        outline = outline[::-1]
    return line, [a, b], outline


def number(v):
    return f"{round(float(v), 2):g}" if abs(v) >= 0.005 else "0"


def constant(name, points):
    items = [f"[{number(x)}, {number(y)}]" for x, y in points]
    lines, line = [], f"{name} = ["
    for i, item in enumerate(items):
        item += "];" if i == len(items) - 1 else ","
        if len(line) + 1 + len(item) > WIDTH and not line.endswith("["):
            lines.append(line)
            line = "    " + item
        else:
            line += ("" if line.endswith("[") else " ") + item
    return "\n".join(lines + [line])


for name, points in (("still", STILL_TUBE), ("flex", FLEX_TUBE)):
    line, collar, outline = spout(name, points)
    for kind, values in (("LINE", line), ("COLLAR", collar), ("POCKET", outline)):
        print(constant(f"{name.upper()}_{kind}", values))
