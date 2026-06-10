function plot_fixture_boundary (polygon, varargin)
  rings = split_fixture_rings (polygon);

  for i = 1:numel (rings)
    ring = rings{i};
    plot ([ring(:, 1); ring(1, 1)], [ring(:, 2); ring(1, 2)], varargin{:});
  endfor
endfunction

function rings = split_fixture_rings (polygon)
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

