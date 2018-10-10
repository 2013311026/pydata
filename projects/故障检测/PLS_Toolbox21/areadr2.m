function [out] = areadr2(file,strng,nvar);
%AREADR2 reads ascii text and converts to a data matrix.
%  Input is (file) an ascii string containing the file name
%  to be read, (strng) the last few characters before the first
%  number to be read (used to skip header information) and
%  (nvar) the number of columns common to the input data and
%  the output data matrix (out).
%
%Warning: conversion may not be successful for files from
%  other platforms.
%
%I/O: out = areadr2(file,strng,nvar);
%
%See also: AREADR1, AREADR3, AREADR4

%Copyright Eigenvector Research, Inc. 1996-98
%Modified BMW 11/2000

[fid,message] = fopen(file,'r');
if fid<0
  error(message)
end
j           = [];
while isempty(j)
  line        = fgets(fid);
  k = findstr(strng,line)
  if ~isempty(k)
	ftell(fid), k
    j = ftell(fid) - length(line) + length(strng) + k - 1;
  end
end
status      = fseek(fid,j,'bof');
if status<0
  [message,errnum] = ferror(fid);
  error(message)
end
[a,count]    = fscanf(fid,'%g',[inf]);
[na,ma]      = size(a);
no           = na/nvar;
if (no-floor(no))~=0
  s = ['Error-Number of columns nvar does'];
  s = [s,' not appear to be correct for file ',file];
  error(s)
elseif count<1
  disp('Conversion does not appear to be successful')
else
  for i=1:no
    jj       = (i-1)*nvar;
    j        = [jj+1:jj+nvar];
    out(i,:) = a(j,1)';
  end
end
fclose(fid);
