function S = structrows(L,in)
% STRUCTROWS Selects rows of a table from XLS2STRUCT
%
% S = STRUCTROWS(L,IN) selects the rows in IN from the structure L and
% outputs them in the structure S.


f = fieldnames(L);
for i = 1:length(f)
  v = L.(f{i});
  S.(f{i}) = v(in);
end
