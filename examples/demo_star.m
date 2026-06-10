root = fileparts (mfilename ("fullpath"));
addpath (fullfile (root, "..", "inst"));
addpath (fullfile (root, "fixtures"));

outer = star_fixture ();
[tri, vertices] = cdt (outer);

figure (1);
clf;
cdt_plot (tri, vertices, "color", [0.1 0.25 0.85]);
hold on;
plot_fixture_boundary (outer, "k-", "linewidth", 2);
plot (outer(:, 1), outer(:, 2), "r.", "markersize", 8);
title ("Star CDT");
hold off;
