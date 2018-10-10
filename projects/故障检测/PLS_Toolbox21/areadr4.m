function [out] = areadr4(file,strng,nrow);
%AREADR4 reads ascii text and converts to a data matrix
%  Input is (file) an ascii string containing the file name
%  to be read, (strng) the last few characters before the first
%  number to be read (used to skip header information) and
%  (nrow) the number of rows common to the input data and
%  the output data matrix (out).
%
%Warning: conversion may not be successful for files from
%  other platforms.
%
%I/O: out = areadr4(file,strng,nrow);
%
%See also: AREADR1, AREADR2, AREADR3

%Copyright Eigenvector Research, Inc. 1996-2000
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
no           = na/nrow;
if (no-floor(no))~=0
  s = ['Error-Number of columns nvar does'];
  s = [s,' not appear to be correct for file ',file];
  error(s)
elseif count<1
  disp('Conversion does not appear to be successful')
else
  for i=1:nrow
    jj       = (i-1)*no;
    j        = [jj+1:jj+no];
    out(i,:) = a(j,1)';
  end
end
fclose(fid);
