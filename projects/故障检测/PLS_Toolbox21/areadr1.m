function [out] = areadr1(file,nline,nvar);
%AREADR1 reads ascii text and converts to a data matrix.
%  Input is (file) an ascii string containing the file name
%  to be read, (nline) the number of rows to skip before reading
%  and (nvar) the number of columns common to the input data and
%  the output data matrix (out).
%
%Warning: conversion may not be successful for files from
%  other platforms.
%
%I/O: out = areadr1(file,nline,nvar);
%
%See also: AREADR2, AREADR3, AREADR4

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
  no         = na/nvar;
  if (no-floor(no))~=0
    disp('Error-Number of columns nvar does')
	disp(' not appear to be correct for file')
	disp(file)
  elseif count<1
    disp('Conversion does not appear to be successful')
  else
    for i=1:no
      jj       = (i-1)*nvar;
      j        = [jj+1:jj+nvar];
      out(i,:) = a(j,1)';
    end
  end
end
fclose(fid);
