function [out,line] = areadr3(file,nline,nrow);
%AREADR3 reads ascii text and converts to a data matrix
%  Input is (file) an ascii string containing the file name
%  to be read, (nline) the number of rows to skip before reading
%  and (nrow) the number of rows common to the input data and
%  the output data matrix (out).
%
%Warning: conversion may not be successful for files from
%  other platforms
%
%I/O: out = areadr3(file,nline,nrow);
%
%See also: AREADR1, AREADR2, AREADR4

%Copyright Eigenvector Research, Inc. 1996-98

[fid,message] = fopen(file,'r');
if fid<0
  disp(message)
else
  for i=1:nline
    line     = fgets(fid);
  end
  [a,count]  = fscanf(fid,'%g',[inf]);
  [na,ma]    = size(a);
  no         = na/nrow;
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
end
fclose(fid);
