function hline(y,lc)
%HLINE adds horizontal lines to figure at specified locations
%  HLINE draws a horizontal line on an existing figure
%  from the left axis to the right axis at a height, or
%  heights, defined by (y) which can be a scalar or vector. 
%  The optional input variable (lc) can be used to define the 
%  line style and color as in normal plotting. Example:
%  hline(1.4,'--b'); plots a horizontal dashed
%  blue line at y = 1.4. If no input arguments are given,
%  hline will draw a horizontal green line at 0.
%
%I/O: hline(y,lc);
%
%See Also: DP, GLINE, VLINE, ELLPS, HIGHORB, PLOT, PLTTERN, ZOOMPLS

%Copyright Eigenvector Research, Inc. 1996-98
%Modified 2/97 NBG
%Modified 3/98 BMW
%nbg 11/00 modified see also

if nargin == 0
  y = 0;
end  
if nargin<2
  lc  = '-g';
end
[m,n] = size(y);
if m>1&n>1
  error('Error - input must be a scaler or vector')
elseif n>1
  y   = y';
  m   = n;
end

v     = axis;
axis  = v;
if ishold
  for ii=1:m
    plot(v(1:2),[1 1]*y(ii,1),lc);
  end
else
  hold on
  for ii=1:m
    plot(v(1:2),[1 1]*y(ii,1),lc);
  end
  hold off
end
