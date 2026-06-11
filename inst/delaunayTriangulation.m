classdef delaunayTriangulation
  properties
    Points
    ConnectivityList
    Constraints
  endproperties

  methods
    function obj = delaunayTriangulation (points, constraints)
      if (nargin < 1 || nargin > 2)
        print_usage ();
      endif
      if (columns (points) != 2)
        error ("points must be an Nx2 numeric matrix");
      endif

      if (nargin < 2 || isempty (constraints))
        [clean_points, ~] = normalize_points (points);
        obj.Points = clean_points;
        obj.Constraints = zeros (0, 2);
        obj.ConnectivityList = delaunay (clean_points(:, 1), clean_points(:, 2));
      else
        if (columns (constraints) != 2)
          error ("constraints must be an Mx2 numeric matrix");
        endif
        [clean_points, index_map] = normalize_points (points);
        clean_constraints = normalize_constraints (constraints, index_map);
        obj.Constraints = clean_constraints;
        [tri, vertices] = cdt_pointset_oct (clean_points, clean_constraints);
        obj.Points = vertices;
        obj.ConnectivityList = tri;
      endif
    endfunction

    function out = subsref (obj, s)
      if (strcmp (s(1).type, "."))
        out = builtin ("subsref", obj, s);
      elseif (strcmp (s(1).type, "()"))
        out = obj.ConnectivityList(s(1).subs{:});
        if (numel (s) > 1)
          out = subsref (out, s(2:end));
        endif
      else
        error ("unsupported delaunayTriangulation indexing");
      endif
    endfunction
  endmethods
endclassdef


function [clean_points, index_map] = normalize_points (points)
  clean_points = zeros (0, columns (points));
  index_map = zeros (rows (points), 1);
  for i = 1:rows (points)
    found = 0;
    for j = 1:rows (clean_points)
      if (all (points(i, :) == clean_points(j, :)))
        found = j;
        break;
      endif
    endfor
    if (found == 0)
      clean_points(end + 1, :) = points(i, :);
      found = rows (clean_points);
    endif
    index_map(i) = found;
  endfor
endfunction

function constraints = normalize_constraints (constraints, index_map)
  if (isempty (constraints))
    constraints = zeros (0, 2);
    return;
  endif

  constraints = index_map(constraints);
  constraints = sort (constraints, 2);
  constraints(constraints(:, 1) == constraints(:, 2), :) = [];
  if (! isempty (constraints))
    constraints = unique (constraints, "rows");
  endif
endfunction
