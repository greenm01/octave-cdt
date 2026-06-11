function out = edgeAttachments (tr, edges)
  if (! isa (tr, "triangulation"))
    error ("edgeAttachments: expected a triangulation object");
  endif
  if (columns (edges) != 2)
    error ("edgeAttachments: edges must be an Nx2 matrix");
  endif

  tri = tr.ConnectivityList;
  out = cell (rows (edges), 1);
  local_edges = [1 2; 2 3; 3 1];
  for i = 1:rows (edges)
    target = sort (edges(i, :));
    attached = [];
    for t = 1:rows (tri)
      for e = 1:3
        pair = sort (tri(t, local_edges(e, :)));
        if (pair(1) == target(1) && pair(2) == target(2))
          attached(end + 1) = t;
          break;
        endif
      endfor
    endfor
    out{i} = attached;
  endfor
endfunction
