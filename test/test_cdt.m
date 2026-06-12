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

pslg_points = [0 0; 4 0; 4 4; 0 4; 2 2];
pslg_boundary = [1 2; 2 3; 3 4; 4 1];
pslg_segments = [1 3];
[tri_pslg, vertices_pslg] = cdt_pointset_oct (pslg_points, pslg_boundary,
                                               pslg_segments);
assert (isequal (vertices_pslg, pslg_points));
assert (columns (tri_pslg), 3);
assert (rows (tri_pslg) > 0);
assert (abs (triangle_area_sum (tri_pslg, vertices_pslg) - 16) < 1e-9);

hole_points = [
  0 0
  10 0
  10 10
  0 10
  3 3
  7 3
  7 7
  3 7
];
hole_boundary = [
  1 2
  2 3
  3 4
  4 1
  5 6
  6 7
  7 8
  8 5
];
[tri_hole_pslg, vertices_hole_pslg] = cdt_pointset_oct (hole_points,
                                                        hole_boundary,
                                                        [], [5 5]);
assert (isequal (vertices_hole_pslg, hole_points));
assert (abs (triangle_area_sum (tri_hole_pslg, vertices_hole_pslg) - 84) < 1e-9);

dt = delaunayTriangulation (points, constraints);
assert (isequal (dt.Points, points));
assert (columns (dt.ConnectivityList), 3);
assert (isequal (dt(:, 1), dt.ConnectivityList(:, 1)));
assert (all (isInterior (dt)));
ti = pointLocation (dt, [5 5; 20 20]);
assert (! isnan (ti(1)));
assert (isnan (ti(2)));

cycle_points = [0 0; 10 0; 10 10; 0 10; 5 5; 20 20];
cycle_constraints = [1 2; 2 3; 3 4; 4 1];
dt_cycle = delaunayTriangulation (cycle_points, cycle_constraints);
assert (rows (dt_cycle.Points) == 5);
assert (rows (dt_cycle.ConnectivityList) > 0);
assert (max (dt_cycle.ConnectivityList(:)) <= rows (dt_cycle.Points));

dt_open = delaunayTriangulation (pslg_points, pslg_segments);
assert (isequal (dt_open.Points, pslg_points));
assert (columns (dt_open.ConnectivityList), 3);
assert (rows (dt_open.ConnectivityList) > 0);

dt2 = delaunayTriangulation (points);
assert (columns (dt2.ConnectivityList), 3);
assert (isequal (dt2(:, 2), dt2.ConnectivityList(:, 2)));


F = griddedInterpolant ([0 1; 0 1], [0 0; 1 1], [0 1; 2 3]);
assert (abs (F ([0.5 0.5]) - 1.5) < 1e-9);
assert (abs (F (0.5, 0.5) - 1.5) < 1e-9);

Fs = scatteredInterpolant ([0; 1; 0], [0; 0; 1], [0; 1; 2]);
assert (abs (Fs (0, 0) - 0) < 1e-9);

[idx, D] = knnsearch ([0 0; 2 0; 0 2], [0.1 0.1], "k", 2);
assert (isequal (idx, [1 2]));
assert (columns (D), 2);
searcher = KDTreeSearcher ([0 0; 2 0; 0 2], "distance", "euclidean");
idx2 = knnsearch (searcher, [1.9 0.1]);
assert (idx2 == 2);

tr = triangulation ([1 2 3; 1 3 4], [0 0; 1 0; 1 1; 0 1]);
assert (isequal (size (tr), [2 3]));
fb = freeBoundary (tr);
assert (rows (fb), 4);
ea = edgeAttachments (tr, [1 3; 1 2]);
assert (isequal (ea{1}, [1 2]));
assert (isequal (ea{2}, 1));
assert (columns (tr.circumcenter ()), 2);
assert (columns (tr.neighbors ()), 3);


dlg = uiprogressdlg ([], "Title", "ADMESH", "Message", "Testing", "Indeterminate", "on");
assert (isa (dlg, "octaveCdtProgressDialog"));
dlg.Value = 0.5;
close (dlg);


assert (insidepoly (0.5, 0.5, [0; 1; 1; 0; 0], [0; 0; 1; 1; 0]));
Dmask = bwdist ([false false false; false true false; false false false]);
assert (Dmask(2, 2) == 0);
assert (abs (Dmask(1, 1) - sqrt (2)) < 1e-12);
srow(1).x = [1; 2]; srow(1).y = [3; 4]; srow(2).x = 5; srow(2).y = 6;
tab = struct2table (srow, "AsArray", 1);
assert (iscell (tab.x));
assert (numel (tab.x) == 2);

Sdist = distFunSubroutine ([0.5; 2], [0.5; 2], [0; 1; 1; 0; 0], [0; 0; 1; 1; 0], [1; 2]);
assert (isfinite (Sdist(1)));
assert (isequal (strfind ([1 0 1 0 1], [0 1]), [2 4]));
[sx, sy] = SpacePolyPoints ([0; 10], [0; 0], [0; 10], [0; 5; 10]);
assert (isequal (sx, [0; 5; 10]));
assert (isequal (sy, [0; 0; 0]));

disp ("octave-cdt smoke tests passed");
