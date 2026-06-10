function run_fixture (name, polygon)
  [tri, vertices] = cdt (polygon);
  printf ("%s: %d vertices, %d triangles\n", name, rows (vertices), rows (tri));
endfunction

