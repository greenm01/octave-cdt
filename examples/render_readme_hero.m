function render_readme_hero (out_path)
  if (nargin < 1)
    root = fileparts (mfilename ("fullpath"));
    out_path = fullfile (root, "..", "docs", "assets", "dude-cdt-holes.png");
  endif

  root = fileparts (mfilename ("fullpath"));
  addpath (fullfile (root, "..", "inst"));
  addpath (fullfile (root, "fixtures"));

  polygon = dude_with_holes_fixture ();
  [tri, vertices, boundary_edges] = cdt (polygon, [], [], ...
                                         struct ("keep_boundary_edges", true));
  vertices = rotate_180 (vertices);
  display_polygon = rotate_polygon_180 (polygon);
  outer_count = first_ring_count (polygon);

  figure (1, "visible", "off");
  clf;
  cdt_plot (tri, vertices, "color", [0.58 0.68 0.95]);
  hold on;
  fill_holes (display_polygon, [1.0 0.08 0.08]);

  for i = 1:rows (boundary_edges)
    edge = boundary_edges(i, :);
    if (all (edge <= outer_count))
      plot (vertices(edge, 1), vertices(edge, 2), "k-", "linewidth", 1.4);
    else
      plot (vertices(edge, 1), vertices(edge, 2), "b-", "linewidth", 2.0);
    endif
  endfor

  plot (vertices(:, 1), vertices(:, 2), "r.", "markersize", 4);
  axis off;
  title ("Dude With Holes CDT");
  hold off;

  print ("-dpng", "-r180", out_path);
endfunction

function fill_holes (polygon, color)
  rings = split_rings (polygon);

  for i = 2:numel (rings)
    ring = rings{i};
    fill (ring(:, 1), ring(:, 2), color, "edgecolor", "none");
  endfor
endfunction

function rings = split_rings (polygon)
  separators = find (all (isnan (polygon), 2));
  starts = [1; separators + 1];
  stops = [separators - 1; rows(polygon)];
  rings = {};

  for i = 1:numel (starts)
    if (starts(i) <= stops(i))
      rings{end + 1} = polygon(starts(i):stops(i), :);
    endif
  endfor
endfunction

function n = first_ring_count (polygon)
  sep = find (all (isnan (polygon), 2), 1);
  if (isempty (sep))
    n = rows (polygon);
  else
    n = sep - 1;
  endif
endfunction

function rotated = rotate_polygon_180 (polygon)
  points = polygon(! all (isnan (polygon), 2), :);
  center = [(min (points(:, 1)) + max (points(:, 1))) / 2, ...
            (min (points(:, 2)) + max (points(:, 2))) / 2];
  rotated = polygon;
  rows_to_rotate = ! all (isnan (polygon), 2);
  rotated(rows_to_rotate, 1) = 2 * center(1) - polygon(rows_to_rotate, 1);
  rotated(rows_to_rotate, 2) = 2 * center(2) - polygon(rows_to_rotate, 2);
endfunction

function rotated = rotate_180 (points)
  center = [(min (points(:, 1)) + max (points(:, 1))) / 2, ...
            (min (points(:, 2)) + max (points(:, 2))) / 2];
  rotated = points;
  rotated(:, 1) = 2 * center(1) - points(:, 1);
  rotated(:, 2) = 2 * center(2) - points(:, 2);
endfunction
