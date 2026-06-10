function render_readme_hero (out_path)
  if (nargin < 1)
    root = fileparts (mfilename ("fullpath"));
    out_path = fullfile (root, "..", "docs", "assets", "dude-cdt.png");
  endif

  root = fileparts (mfilename ("fullpath"));
  addpath (fullfile (root, "..", "inst"));
  addpath (fullfile (root, "fixtures"));

  polygon = dude_with_holes_fixture ();
  [tri, vertices, boundary_edges] = cdt (polygon, [], [], ...
                                         struct ("keep_boundary_edges", true));
  vertices = rotate_180 (vertices);

  figure (1, "visible", "off");
  clf;
  cdt_plot (tri, vertices, "color", [0.05 0.22 0.85]);
  hold on;

  for i = 1:rows (boundary_edges)
    edge = boundary_edges(i, :);
    plot (vertices(edge, 1), vertices(edge, 2), "k-", "linewidth", 1.4);
  endfor

  plot (vertices(:, 1), vertices(:, 2), "r.", "markersize", 5);
  axis off;
  title ("Dude With Holes CDT");
  hold off;

  print ("-dpng", "-r180", out_path);
endfunction

function rotated = rotate_180 (points)
  center = [(min (points(:, 1)) + max (points(:, 1))) / 2, ...
            (min (points(:, 2)) + max (points(:, 2))) / 2];
  rotated = points;
  rotated(:, 1) = 2 * center(1) - points(:, 1);
  rotated(:, 2) = 2 * center(2) - points(:, 2);
endfunction

