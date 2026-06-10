function [tri, vertices, boundary_edges] = cdt (outer, holes, steiner, options)
  if (nargin < 1 || nargin > 4)
    print_usage ();
  endif

  split_outer = false;
  if ((nargin < 2 || isempty (holes)) && has_nan_separator (outer))
    rings = split_nan_rings (outer);
    outer = rings{1};
    holes = rings(2:end);
    split_outer = true;
  endif

  if ((nargin < 2 && ! split_outer) || isempty (holes))
    holes = {};
  elseif (isnumeric (holes) && has_nan_separator (holes))
    rings = split_nan_rings (holes);
    holes = rings;
  elseif (isnumeric (holes))
    holes = {holes};
  endif

  if (nargin < 3 || isempty (steiner))
    steiner = zeros (0, 2);
  endif

  if (nargin < 4 || isempty (options))
    options = struct ();
  endif

  epsilon = get_option (options, "epsilon", 1e-9);
  clean_input = get_option (options, "clean_input", true);
  validate = get_option (options, "validate", true);
  keep_boundary_edges = get_option (options, "keep_boundary_edges", nargout >= 3);
  mode = get_option (options, "mode", "checked");

  [tri, vertices, boundary_edges] = cdt_oct (outer, holes, steiner, epsilon,
                                             clean_input, validate,
                                             keep_boundary_edges, mode);
endfunction

function tf = has_nan_separator (points)
  tf = isnumeric (points) && columns (points) == 2 && any (all (isnan (points), 2));
endfunction

function rings = split_nan_rings (points)
  if (! isnumeric (points) || columns (points) != 2)
    error ("NaN-separated polygon input must be an Nx2 numeric matrix");
  endif

  separators = find (all (isnan (points), 2));
  starts = [1; separators + 1];
  stops = [separators - 1; rows(points)];
  rings = {};

  for i = 1:numel (starts)
    if (starts(i) <= stops(i))
      ring = points(starts(i):stops(i), :);
      if (! isempty (ring))
        rings{end + 1} = ring;
      endif
    endif
  endfor

  if (isempty (rings))
    error ("NaN-separated polygon input contains no rings");
  endif
endfunction

function value = get_option (options, name, default_value)
  if (isfield (options, name))
    value = options.(name);
  else
    value = default_value;
  endif
endfunction
