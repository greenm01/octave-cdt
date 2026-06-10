# Geometry Input Formats

There is no single Octave fixture-file standard for constrained Delaunay
triangulation inputs.

For Octave-facing examples and tests, prefer normal Octave values and `.m`
fixture functions:

- one polygon ring as an `N x 2` numeric matrix;
- holes as a cell array of `N x 2` matrices;
- multipart polygon fixtures as one `N x 2` matrix with `NaN NaN` separator rows.

The `NaN` separator convention matches common Octave geometry and mapping
practice for multipart polygon/polyline data. In this package, the first ring is
treated as the outer contour and later rings are holes.

The old p2t `.dat` fixtures are useful as legacy source data, but they should
not be promoted as the public format. They are just whitespace-delimited `x y`
rows with blank lines between rings, with no metadata or segment markers. For
this Octave package, port them to `.m` fixture functions instead.
