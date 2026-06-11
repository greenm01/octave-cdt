classdef octaveCdtProgressDialog
  properties
    Title = ""
    Message = ""
    Indeterminate = "off"
    Value = 0
  endproperties

  methods
    function obj = octaveCdtProgressDialog (varargin)
      args = varargin;
      if (! isempty (args) && ! ischar (args{1}) && ! isstring (args{1}))
        args = args(2:end);
      endif
      for i = 1:2:numel (args)
        name = char (args{i});
        value = args{i + 1};
        switch (lower (name))
          case "title"
            obj.Title = value;
          case "message"
            obj.Message = value;
          case "indeterminate"
            obj.Indeterminate = value;
          case "value"
            obj.Value = value;
        endswitch
      endfor
    endfunction

    function close (obj)
      %#ok<INUSD>
    endfunction
  endmethods
endclassdef
