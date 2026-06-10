function in = isInterior (dt)
  if (! isa (dt, "delaunayTriangulation"))
    error ("isInterior currently supports octave-cdt delaunayTriangulation objects only");
  endif
  in = true (rows (dt.ConnectivityList), 1);
endfunction
