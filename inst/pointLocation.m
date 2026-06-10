function ti = pointLocation (dt, query)
  if (! isa (dt, "delaunayTriangulation"))
    error ("pointLocation currently supports octave-cdt delaunayTriangulation objects only");
  endif
  if (columns (query) != 2)
    error ("query must be an Nx2 numeric matrix");
  endif
  ti = tsearchn (dt.Points, dt.ConnectivityList, query);
endfunction
