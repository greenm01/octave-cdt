function e = edges (tr)
  if (! isa (tr, "triangulation"))
    error ("edges: expected a triangulation object");
  endif
  tri = tr.ConnectivityList;
  e = unique (sort ([tri(:, [1 2]); tri(:, [2 3]); tri(:, [3 1])], 2), "rows");
endfunction
