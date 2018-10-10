function xclputdata(filename,datarange,xmat)
%XCLPUTDATA places a MATLAB matrix in an Excel spreadsheet
%  Inputs are (filename) a text string containing the
%  file name of the OPEN Excel spreadsheet, (datarange)
%  a text string containing the range in the spreadsheet
%  to place the data matrix in row/column format, and (xmat)
%  a Matlab matrix to be placed into the Excel spreadsheet. 
%  The size of Excel data range (datarange) must match the
%  dimensions of the matrix (xmat).
%
%Note: This function only works on a PC and the spreadsheet
%  must be open. For Mac see XLSETRANGE.
%
%Example: for a 3 by 5 MATLAB matrix mydat
%   xclputdata('book1.xls','r2c2:r4c6',mydat)
%
%I/O: xclputdata(filename,datarange,xmat);
%
%See Also: AREADR1, XCLGETDATA

%Copyright Eigenvector Research, Inc. 1999
%nbg 1/99, 10/00 fixed help

chan  = ddeinit('excel',filename);
ddepoke(chan,datarange,xmat);
rc    = ddeterm(chan);
