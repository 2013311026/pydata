function xmat = xclgetdata(filename,datarange)
%XCLGETDATA extracts a matrix from an Excel spreadsheet
%  Inputs are (filename) a text string containing the
%  file name of the OPEN Excel spreadsheet and (datarange)
%  a text string containing the range in the spreadsheet
%  that contains the data matrix in row/column format. 
%  The output (xmat) is the MATLAB matrix.
%
%Note: This function only works on a PC and the spreadsheet
%  must be open in Office 97 or higher. For Mac see XLGETRANGE.
%
%Example: to get a table of data from the range C2 to T25
%         from the open workbook 'book1.xls':
%     data = xclgetdata('book1.xls','r2c3:r25c20')
%
%I/O: xmat = xclgetdata(filename,datarange);
%
%See Also: AREADR1, XCLPUTDATA, XCLREADR

%Copyright Eigenvector Research, Inc. 1999 - 2000
%nbg 1/99
%nbg 11/00 added XCLREADR

chan  = ddeinit('excel',filename);
xmat  = ddereq(chan,datarange);
rc    = ddeterm(chan);
