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
        [ok, tri, vertices] = triangulate_closed_cycles (clean_points, clean_constraints);
        if (ok)
          obj.Points = vertices;
          obj.ConnectivityList = tri;
        else
          boundary_constraints = convex_hull_constraints (clean_points);
          interior_constraints = remove_boundary_constraints (clean_constraints,
                                                              boundary_constraints);
          [tri, vertices] = cdt_pointset_oct (clean_points, boundary_constraints,
                                              interior_constraints);
          obj.Points = vertices;
          obj.ConnectivityList = tri;
        endif
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

function [ok, tri, vertices] = triangulate_closed_cycles (points, constraints)
  ok = false;
  tri = zeros (0, 3);
  vertices = points;

  if (isempty (constraints))
    return;
  endif

  cycles = constraints_to_cycles (constraints, rows (points));
  if (isempty (cycles))
    return;
  endif

  used = false (rows (points), 1);
  areas = zeros (numel (cycles), 1);
  for i = 1:numel (cycles)
    cycle = cycles{i};
    used(cycle) = true;
    areas(i) = signed_area (points(cycle, :));
  endfor

  [~, outer_pos] = max (abs (areas));
  outer_idx = cycles{outer_pos};
  if (signed_area (points(outer_idx, :)) < 0)
    outer_idx = flipud (outer_idx(:));
  else
    outer_idx = outer_idx(:);
  endif

  holes = {};
  for i = 1:numel (cycles)
    if (i == outer_pos)
      continue;
    endif
    hole_idx = cycles{i};
    if (signed_area (points(hole_idx, :)) > 0)
      hole_idx = flipud (hole_idx(:));
    else
      hole_idx = hole_idx(:);
    endif
    holes{end + 1} = points(hole_idx, :);
  endfor

  steiner_idx = find (! used);
  steiner_idx = filter_steiner_in_domain (points, steiner_idx, outer_idx, cycles, outer_pos);
  keep_idx = find (used);
  keep_idx = [keep_idx(:); steiner_idx(:)];
  keep_idx = sort (keep_idx);
  vertices = points(keep_idx, :);

  options = struct ("epsilon", 1e-9,
                    "clean_input", false,
                    "validate", false,
                    "keep_boundary_edges", false,
                    "mode", "checked");
  try
    [raw_tri, raw_vertices] = cdt (points(outer_idx, :), holes,
                                   points(steiner_idx, :), options);
  catch
    return;
  end_try_catch

  map = map_vertices_to_points (raw_vertices, points);
  if (any (map == 0))
    return;
  endif

  local_map = zeros (rows (points), 1);
  local_map(keep_idx) = (1:numel (keep_idx))';
  tri = local_map(map(raw_tri));
  if (any (tri(:) == 0))
    return;
  endif
  ok = true;
endfunction

function keep = filter_steiner_in_domain (points, steiner_idx, outer_idx, cycles, outer_pos)
  if (isempty (steiner_idx))
    keep = steiner_idx;
    return;
  endif

  query = points(steiner_idx, :);
  outer = points(outer_idx, :);
  [in, on] = inpolygon (query(:, 1), query(:, 2), outer(:, 1), outer(:, 2));
  mask = in | on;

  for i = 1:numel (cycles)
    if (i == outer_pos)
      continue;
    endif
    hole = points(cycles{i}, :);
    [in_hole, on_hole] = inpolygon (query(:, 1), query(:, 2), hole(:, 1), hole(:, 2));
    mask = mask & ! (in_hole | on_hole);
  endfor

  keep = steiner_idx(mask);
endfunction

function cycles = constraints_to_cycles (constraints, point_count)
  cycles = {};
  degree = zeros (point_count, 1);
  adj = cell (point_count, 1);

  for i = 1:rows (constraints)
    a = constraints(i, 1);
    b = constraints(i, 2);
    if (a < 1 || b < 1 || a > point_count || b > point_count || a == b)
      cycles = {};
      return;
    endif
    degree(a) += 1;
    degree(b) += 1;
    adj{a}(end + 1) = b;
    adj{b}(end + 1) = a;
  endfor

  touched = find (degree > 0);
  if (any (degree(touched) != 2))
    cycles = {};
    return;
  endif

  visited = false (point_count, 1);
  for start = touched(:)'
    if (visited(start))
      continue;
    endif

    cycle = [];
    prev = 0;
    cur = start;
    while (true)
      if (visited(cur))
        if (cur == start && numel (cycle) >= 3)
          break;
        endif
        cycles = {};
        return;
      endif

      visited(cur) = true;
      cycle(end + 1, 1) = cur;
      nexts = adj{cur};
      if (nexts(1) == prev)
        next = nexts(2);
      else
        next = nexts(1);
      endif
      prev = cur;
      cur = next;
    endwhile

    cycles{end + 1} = cycle;
  endfor
endfunction

function area = signed_area (ring)
  x = ring(:, 1);
  y = ring(:, 2);
  x2 = [x(2:end); x(1)];
  y2 = [y(2:end); y(1)];
  area = 0.5 * sum (x .* y2 - x2 .* y);
endfunction

function map = map_vertices_to_points (vertices, points)
  map = zeros (rows (vertices), 1);
  for i = 1:rows (vertices)
    for j = 1:rows (points)
      if (all (abs (vertices(i, :) - points(j, :)) <= 1e-8))
        map(i) = j;
        break;
      endif
    endfor
  endfor
endfunction

function constraints = normalize_constraints (constraints, index_map)
  if (isempty (constraints))
    constraints = zeros (0, 2);
    return;
  endif

  constraints = reshape (index_map(constraints), size (constraints));
  constraints = sort (constraints, 2);
  constraints(constraints(:, 1) == constraints(:, 2), :) = [];
  if (! isempty (constraints))
    constraints = unique (constraints, "rows");
  endif
endfunction

function constraints = convex_hull_constraints (points)
  if (rows (points) < 3)
    constraints = zeros (0, 2);
    return;
  endif

  hull = convhull (points(:, 1), points(:, 2));
  hull = hull(:);
  if (! isempty (hull) && hull(end) == hull(1))
    hull = hull(1:end - 1);
  endif

  if (numel (hull) < 3)
    constraints = zeros (0, 2);
    return;
  endif

  constraints = [hull, hull([2:end, 1])];
endfunction

function constraints = remove_boundary_constraints (constraints, boundary_constraints)
  if (isempty (constraints) || isempty (boundary_constraints))
    return;
  endif

  [on_boundary, ~] = ismember (sort (constraints, 2),
                               sort (boundary_constraints, 2), "rows");
  constraints = constraints(! on_boundary, :);
endfunction
