function in = insidepoly (X, Y, xv, yv)
  [in, on] = inpolygon (X, Y, xv, yv);
  in = in | on;
endfunction
