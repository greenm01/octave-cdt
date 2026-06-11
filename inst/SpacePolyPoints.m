function [x, y] = SpacePolyPoints (px, py, s, s_query)
  if (nargin != 4)
    print_usage ();
  endif

  px = px(:);
  py = py(:);
  s = s(:);
  s_query = s_query(:);

  if (numel (px) != numel (py) || numel (px) != numel (s))
    error ("SpacePolyPoints: px, py, and s must have the same length");
  endif

  x = interp1 (s, px, s_query, "linear");
  y = interp1 (s, py, s_query, "linear");

  if (any (isnan (x)) || any (isnan (y)))
    x_nearest = interp1 (s, px, s_query, "nearest", "extrap");
    y_nearest = interp1 (s, py, s_query, "nearest", "extrap");
    x(isnan (x)) = x_nearest(isnan (x));
    y(isnan (y)) = y_nearest(isnan (y));
  endif
endfunction

