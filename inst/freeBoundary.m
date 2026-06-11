function fb = freeBoundary (tr)
  if (! isa (tr, "triangulation"))
    error ("freeBoundary: expected a triangulation object");
  endif
  tri = tr.ConnectivityList;
  all_edges = [tri(:, [1 2]); tri(:, [2 3]); tri(:, [3 1])];
  all_edges = sort (all_edges, 2);
  [u, ~, ic] = unique (all_edges, "rows");
  counts = accumarray (ic, 1);
  fb = u(counts == 1, :);
endfunction
