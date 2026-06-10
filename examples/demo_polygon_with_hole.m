root = fileparts (mfilename ("fullpath"));
addpath (fullfile (root, "..", "inst"));
addpath (fullfile (root, "fixtures"));

polygon = dude_with_holes_fixture ();
[tri, vertices, boundary_edges] = cdt (polygon, [], [], struct ("keep_boundary_edges", true));

figure (1);
clf;
cdt_plot (tri, vertices, "color", [0.1 0.25 0.85]);
hold on;

for i = 1:rows (boundary_edges)
  edge = boundary_edges(i, :);
  plot (vertices(edge, 1), vertices(edge, 2), "k-", "linewidth", 2);
endfor

plot (vertices(:, 1), vertices(:, 2), "r.", "markersize", 6);
title ("Dude With Holes CDT");
hold off;
