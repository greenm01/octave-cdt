classdef scatteredInterpolant
  properties
    X
    Y
    V
    Method = "linear"
    ExtrapolationMethod = "nearest"
  endproperties

  methods
    function obj = scatteredInterpolant (X, Y, V, method, extrapolation_method)
      if (nargin < 3 || nargin > 5)
        print_usage ();
      endif
      obj.X = X(:);
      obj.Y = Y(:);
      obj.V = V(:);
      if (nargin >= 4 && ! isempty (method))
        obj.Method = method;
      endif
      if (nargin >= 5 && ! isempty (extrapolation_method))
        obj.ExtrapolationMethod = extrapolation_method;
      endif
    endfunction

    function out = subsref (obj, s)
      if (strcmp (s(1).type, "."))
        out = builtin ("subsref", obj, s);
      elseif (strcmp (s(1).type, "()"))
        args = s(1).subs;
        if (numel (args) == 1)
          P = args{1};
          if (columns (P) != 2)
            error ("scatteredInterpolant: single query argument must be an Nx2 matrix");
          endif
          out = eval_scattered (obj, P(:, 1), P(:, 2));
        elseif (numel (args) == 2)
          out = eval_scattered (obj, args{1}, args{2});
        else
          error ("scatteredInterpolant: expected one Nx2 query or X,Y query arrays");
        endif
        if (numel (s) > 1)
          out = subsref (out, s(2:end));
        endif
      else
        error ("scatteredInterpolant: unsupported indexing");
      endif
    endfunction
  endmethods
endclassdef

function out = eval_scattered (obj, Xq, Yq)
  method = lower (obj.Method);
  if (strcmp (method, "linear") || strcmp (method, "nearest"))
    out = griddata (obj.X, obj.Y, obj.V, Xq, Yq, method);
  else
    error (["scatteredInterpolant: unsupported method " method]);
  endif

  if (any (isnan (out(:))) && strcmpi (obj.ExtrapolationMethod, "nearest"))
    nearest = griddata (obj.X, obj.Y, obj.V, Xq, Yq, "nearest");
    out(isnan (out)) = nearest(isnan (out));
  endif
endfunction
