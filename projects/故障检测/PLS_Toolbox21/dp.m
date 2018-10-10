function dp(lc)
%DP draws a diagonal line on an existing figure.
%  DP draws a diagonal line on an existing figure
%  from the bottom left axis to the upper right axis.
%  The optional input variable (lc) can be used to define
%  the line style and color as for normal plotting.
%  For example dp('--b') plots a 45 degree diagonal
%  dash blue line.
%
%I/O: dp(lc);
%
%See Also: PLOT, HLINE, VLINE, ELLPS, HIGHORB, ZOOMPLS

%Copyright Eigenvector Research, Inc. 1996-98

if nargin<1
  lc  = '-g';
end
v     = axis;
axis  = v;
ur = max([v(2) v(4)]);
ll = min([v(1) v(3)]);
if ishold
  plot([ll ur],[ll ur],lc)
else
  hold on, plot([ll ur],[ll ur],lc); hold off
end
