function eddata = delsamps(data,samps)
%DELSAMPS Deletes samples (rows) from data matrices.
%  Inputs are the original data matrix (data) and
%  the row numbers of the samples to delete (samps).
%  The output is the edited data matrix (eddata).
%
%I/O: eddata = delsamps(data,samps); 
%
%  This function can also be used to delete variables
%  (columns) by operating on the matrix transpose, i.e.
%
%I/O: eddata = delsamps(data',vars)';
%
%See also: shuffle, specedit

%Copyright Eigenvector Research, Inc. 1996-98
%Modified 11/93, 1/96

[m,n]    = size(data);
[ms,ns]  = size(samps);
if ms>ns
  samps  = samps';
  ns     = ms;
end
samps    = sort(samps);
savsamps = 1:m;
savsamps(samps) = zeros(1,ns);
savsamps = find(savsamps ~= 0);
eddata   = data(savsamps,:);
