function S = distFunSubroutine (X, Y, u, v, id)
  if (nargin != 5)
    print_usage ();
  endif

  original_size = size (X);
  X = X(:);
  Y = Y(:);
  u = u(:);
  v = v(:);
  id = id(:);
  n = numel (u);
  S = inf (numel (X), 1);

  for k = 1:numel (X)
    i = round (id(k));
    if (i < 1 || i > n)
      continue;
    endif

    candidates = [i, wrap_index(i + 1, n); wrap_index(i - 1, n), i];
    best = inf;
    for c = 1:2
      a = candidates(c, 1);
      b = candidates(c, 2);
      ax = u(a); ay = v(a);
      bx = u(b); by = v(b);
      dx = bx - ax;
      dy = by - ay;
      len2 = dx * dx + dy * dy;
      if (len2 <= eps)
        continue;
      endif
      t = ((X(k) - ax) * dx + (Y(k) - ay) * dy) / len2;
      if (t > eps && t < 1)
        px = ax + t * dx;
        py = ay + t * dy;
        best = min (best, hypot (px - X(k), py - Y(k)));
      endif
    endfor
    S(k) = best;
  endfor

  S = reshape (S, original_size);
endfunction

function idx = wrap_index (idx, n)
  if (idx < 1)
    idx = n - 1;
  elseif (idx > n)
    idx = 1;
  endif
endfunction
