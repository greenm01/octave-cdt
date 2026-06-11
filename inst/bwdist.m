function D = bwdist (BW)
  if (nargin != 1)
    print_usage ();
  endif
  BW = logical (BW);
  [target_y, target_x] = find (BW);
  D = inf (size (BW));
  if (isempty (target_x))
    return;
  endif
  for y = 1:rows (BW)
    for x = 1:columns (BW)
      dx = target_x - x;
      dy = target_y - y;
      D(y, x) = sqrt (min (dx .^ 2 + dy .^ 2));
    endfor
  endfor
endfunction
