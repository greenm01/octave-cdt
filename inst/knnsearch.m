function [idx, D] = knnsearch (X, Y, varargin)
  if (nargin < 2)
    print_usage ();
  endif

  if (isa (X, "KDTreeSearcher"))
    searcher = X;
    X = searcher.X;
  endif

  if (! isnumeric (X) || ! isnumeric (Y) || columns (X) != columns (Y))
    error ("knnsearch: X and Y must be numeric matrices with the same column count");
  endif

  k = 1;
  for i = 1:2:numel (varargin)
    name = lower (varargin{i});
    value = varargin{i + 1};
    if (strcmp (name, "k"))
      k = value;
    elseif (strcmp (name, "distance"))
      if (! strcmpi (value, "euclidean"))
        error ("knnsearch: only euclidean distance is supported by this compatibility shim");
      endif
    else
      error (["knnsearch: unsupported option " name]);
    endif
  endfor

  k = min (k, rows (X));
  idx = zeros (rows (Y), k);
  D = zeros (rows (Y), k);

  for q = 1:rows (Y)
    diff = X - Y(q, :);
    dist = sqrt (sum (diff .^ 2, 2));
    [sorted_dist, order] = sort (dist);
    idx(q, :) = order(1:k).';
    D(q, :) = sorted_dist(1:k).';
  endfor
endfunction
