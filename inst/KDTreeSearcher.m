classdef KDTreeSearcher
  properties
    X
    Distance = "euclidean"
  endproperties

  methods
    function obj = KDTreeSearcher (X, varargin)
      if (nargin < 1)
        print_usage ();
      endif
      obj.X = X;
      for i = 1:2:numel (varargin)
        name = lower (varargin{i});
        value = varargin{i + 1};
        if (strcmp (name, "distance"))
          obj.Distance = value;
        else
          error (["KDTreeSearcher: unsupported option " name]);
        endif
      endfor
      if (! strcmpi (obj.Distance, "euclidean"))
        error ("KDTreeSearcher: only euclidean distance is supported by this compatibility shim");
      endif
    endfunction
  endmethods
endclassdef
