function idx = strfind (haystack, needle)
  if ((isnumeric (haystack) || islogical (haystack)) && (isnumeric (needle) || islogical (needle)))
    haystack = haystack(:).';
    needle = needle(:).';
    n = numel (needle);
    idx = [];
    if (n == 0 || numel (haystack) < n)
      return;
    endif
    for i = 1:(numel (haystack) - n + 1)
      if (isequal (haystack(i:i+n-1), needle))
        idx(end + 1) = i;
      endif
    endfor
  else
    idx = builtin ("strfind", haystack, needle);
  endif
endfunction
