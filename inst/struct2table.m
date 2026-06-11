function out = struct2table (s, varargin)
  if (! isstruct (s))
    error ("struct2table: input must be a struct");
  endif
  fields = fieldnames (s);
  out = struct ();
  for f = 1:numel (fields)
    name = fields{f};
    values = cell (numel (s), 1);
    for i = 1:numel (s)
      values{i} = s(i).(name);
    endfor
    out.(name) = values;
  endfor
endfunction
