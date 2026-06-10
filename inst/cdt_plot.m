function h = cdt_plot (tri, vertices, varargin)
  if (nargin < 2)
    print_usage ();
  endif

  h = triplot (tri, vertices(:, 1), vertices(:, 2), varargin{:});
  axis equal;
endfunction

