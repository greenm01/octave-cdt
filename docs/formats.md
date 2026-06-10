# Geometry Input Formats

There is no special Octave file format for CDT fixtures, and this package does
not invent one.

For examples and tests, use normal Octave data:

- one polygon ring as an `N x 2` numeric matrix;
- holes as a cell array of `N x 2` matrices;
- multipart polygon fixtures as one `N x 2` matrix with `NaN NaN` rows between rings.

The `NaN` separator convention is familiar in Octave geometry and mapping code.
Here the first ring is the outer contour, and each later ring is a hole.

The old `p2t` `.dat` files are only legacy source material. They are just
whitespace-delimited `x y` rows, with blank lines between rings. They carry no
metadata, no segment markers, and no Octave-specific meaning. For this package,
turn useful `.dat` examples into `.m` fixture functions instead.
