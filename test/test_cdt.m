outer = [0 0; 1 0; 1 1; 0 1];
[tri, vertices, boundary_edges] = cdt (outer, {}, [], struct ("keep_boundary_edges", true));

assert (rows (vertices), 4);
assert (columns (vertices), 2);
assert (rows (tri), 2);
assert (columns (tri), 3);
assert (all (tri(:) >= 1));
assert (all (tri(:) <= rows (vertices)));
assert (rows (boundary_edges), 4);
assert (columns (boundary_edges), 2);

polygon = [
  0 0
  5 0
  5 5
  0 5
  NaN NaN
  1 1
  1 2
  2 2
  2 1
];
[tri, vertices] = cdt (polygon);

assert (rows (vertices), 8);
assert (columns (vertices), 2);
assert (columns (tri), 3);
assert (all (tri(:) >= 1));
assert (all (tri(:) <= rows (vertices)));

outer = [0 0; 4 0; 4 4; 0 4];
hole = [1 1; 1 2; 2 2; 2 1];
[tri, vertices] = cdt (outer, {hole});

assert (rows (vertices), 8);
assert (columns (vertices), 2);
assert (columns (tri), 3);
assert (all (tri(:) >= 1));
assert (all (tri(:) <= rows (vertices)));

addpath (fullfile (fileparts (mfilename ("fullpath")), "..", "examples", "fixtures"));

fixture = star_fixture ();
[tri, vertices] = cdt (fixture);
assert (columns (tri), 3);
assert (rows (tri) > 0);
assert (all (tri(:) >= 1));
assert (all (tri(:) <= rows (vertices)));

fixture = dude_with_holes_fixture ();
[tri, vertices] = cdt (fixture);
assert (columns (tri), 3);
assert (rows (tri) > 0);
assert (all (tri(:) >= 1));
assert (all (tri(:) <= rows (vertices)));


PTS.Poly(1).x = [0; 4; 4; 0; 0];
PTS.Poly(1).y = [0; 0; 4; 4; 0];
PTS.Poly(2).x = [1; 1; 2; 2; 1];
PTS.Poly(2).y = [1; 2; 2; 1; 1];
X = [0.5; 1.5; 3.0; 5.0];
Y = [0.5; 1.5; 3.0; 0.5];
IN = cdt_points_in_domain (X, Y, PTS);
assert (isequal (IN, logical ([1; 0; 1; 0])));

IN2 = PointsInDomain (X, Y, PTS);
assert (isequal (IN2, IN));

points = [0 0; 10 0; 10 10; 0 10; 5 4];
constraints = [1 2; 2 3; 3 4; 4 1];
[tri_ps, vertices_ps] = cdt_pointset_oct (points, constraints);
assert (isequal (vertices_ps, points));
assert (columns (tri_ps), 3);
assert (rows (tri_ps) > 0);

dt = delaunayTriangulation (points, constraints);
assert (isequal (dt.Points, points));
assert (columns (dt.ConnectivityList), 3);
assert (isequal (dt(:, 1), dt.ConnectivityList(:, 1)));
assert (all (isInterior (dt)));
ti = pointLocation (dt, [5 5; 20 20]);
assert (! isnan (ti(1)));
assert (isnan (ti(2)));

dt2 = delaunayTriangulation (points);
assert (columns (dt2.ConnectivityList), 3);
assert (isequal (dt2(:, 2), dt2.ConnectivityList(:, 2)));

disp ("octave-cdt smoke tests passed");
