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

      obj.Points = points;
      if (nargin < 2 || isempty (constraints))
        obj.Constraints = zeros (0, 2);
        obj.ConnectivityList = delaunay (points(:, 1), points(:, 2));
      else
        if (columns (constraints) != 2)
          error ("constraints must be an Mx2 numeric matrix");
        endif
        obj.Constraints = constraints;
        [tri, vertices] = cdt_pointset_oct (points, constraints);
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
