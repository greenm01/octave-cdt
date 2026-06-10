function IN = cdt_points_in_domain (X, Y, PTS)
  if (nargin != 3)
    print_usage ();
  endif

  if (! isfield (PTS, "Poly") || isempty (PTS.Poly))
    error ("PTS must contain a nonempty Poly field");
  endif

  [outer, holes] = rings_from_pts (PTS);
  [tri, vertices] = cdt (outer, holes);

  original_size = size (X);
  query = [X(:), Y(:)];
  ti = tsearchn (vertices, tri, query);
  IN = reshape (! isnan (ti), original_size);
endfunction

function [outer, holes] = rings_from_pts (PTS)
  nsegments = numel (PTS.Poly);
  outer = clean_ring ([PTS.Poly(1).x(:), PTS.Poly(1).y(:)]);
  holes = {};

  for k = 2:nsegments
    ring = clean_ring ([PTS.Poly(k).x(:), PTS.Poly(k).y(:)]);
    if (! isempty (ring))
      holes{end + 1} = ring;
    endif
  endfor
endfunction

function ring = clean_ring (ring)
  if (isempty (ring))
    return;
  endif

  finite_rows = all (isfinite (ring), 2);
  ring = ring(finite_rows, :);
  if (rows (ring) >= 2 && all (abs (ring(1, :) - ring(end, :)) <= 1e-12))
    ring = ring(1:end-1, :);
  endif
endfunction
