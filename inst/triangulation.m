classdef triangulation
  properties
    ConnectivityList
    Points
  endproperties

  methods
    function obj = triangulation (tri, varargin)
      if (nargin < 2 || nargin > 3)
        print_usage ();
      endif
      obj.ConnectivityList = tri;
      if (nargin == 2)
        obj.Points = varargin{1};
      else
        obj.Points = [varargin{1}(:), varargin{2}(:)];
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
        error ("triangulation: unsupported indexing");
      endif
    endfunction

    function varargout = size (obj, varargin)
      if (nargout <= 1)
        varargout{1} = size (obj.ConnectivityList, varargin{:});
      else
        [varargout{1:nargout}] = size (obj.ConnectivityList, varargin{:});
      endif
    endfunction

    function n = neighbors (obj)
      n = triangulation_neighbors (obj.ConnectivityList);
    endfunction

    function cc = circumcenter (obj)
      tri = obj.ConnectivityList;
      p = obj.Points;
      cc = zeros (rows (tri), 2);
      for i = 1:rows (tri)
        a = p(tri(i, 1), :);
        b = p(tri(i, 2), :);
        c = p(tri(i, 3), :);
        d = 2 * (a(1) * (b(2) - c(2)) + b(1) * (c(2) - a(2)) + c(1) * (a(2) - b(2)));
        if (abs (d) < eps)
          cc(i, :) = (a + b + c) / 3;
        else
          aa = sum (a .^ 2);
          bb = sum (b .^ 2);
          cc2 = sum (c .^ 2);
          ux = (aa * (b(2) - c(2)) + bb * (c(2) - a(2)) + cc2 * (a(2) - b(2))) / d;
          uy = (aa * (c(1) - b(1)) + bb * (a(1) - c(1)) + cc2 * (b(1) - a(1))) / d;
          cc(i, :) = [ux, uy];
        endif
      endfor
    endfunction
  endmethods
endclassdef
