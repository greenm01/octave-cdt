function n = triangulation_neighbors (tri)
  n = NaN (rows (tri), 3);
  edge_keys = containers.Map ("KeyType", "char", "ValueType", "any");
  local_edges = [2 3; 3 1; 1 2];

  for t = 1:rows (tri)
    for e = 1:3
      pair = sort (tri(t, local_edges(e, :)));
      key = sprintf ("%d_%d", pair(1), pair(2));
      if (isKey (edge_keys, key))
        prev = edge_keys(key);
        n(t, e) = prev(1);
        n(prev(1), prev(2)) = t;
      else
        edge_keys(key) = [t, e];
      endif
    endfor
  endfor
endfunction
