function vline(x,lc)
%VLINE adds vertical lines to figure at specified locations
%  VLINE draws a vertical line on an existing figure
%  from the bottom axis to the top axis at position 
%  or positions defined by (x) which can be a scalar or 
%  vector. The optional input variable (lc) can be used to
%  define the line style and color as in normal plotting.
%  Example vline(2.5,'-r'); plots a vertical solid
%  red line at x = 2.5. If no input arguments are given,
%  vline will draw a vertical green line at 0.  
%
%I/O: vline(x,lc);
%
%See Also: DP, HLINE, GLINE, ELLPS, HIGHORB, PLOT, PLTTERN, ZOOMPLS

%Copyright Eigenvector Research, Inc. 1996-2000
%Modified 2/97 NBG
%Modified 3/98 BMW
%11/00 nbg changed see also

if nargin == 0
  x = 0;
end
if nargin<2
  lc  = '-g';
end
[m,n] = size(x);
if m>1&n>1
  error('Error - input must be a scaler or vector')
elseif n>1
  x   = x';
  m   = n;
end

v     = axis;
axis  = v;
if ishold
  for ii=1:m
    plot([1 1]*x(ii,1),v(3:4),lc);
  end
else
  hold on
  for ii=1:m
    plot([1 1]*x(ii,1),v(3:4),lc);
  end
  hold off
end
