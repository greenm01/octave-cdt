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

disp ("octave-cdt smoke tests passed");
