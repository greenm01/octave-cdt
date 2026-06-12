function area = triangle_area_sum (tri, vertices)
  area = 0;
  for i = 1:rows (tri)
    p = vertices(tri(i, :), :);
    area += abs (det ([p(2, :) - p(1, :); p(3, :) - p(1, :)])) / 2;
  endfor
endfunction
