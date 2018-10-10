function gline(lc)
%GLINE adds a line to a plot with ends at locations specified by clicks
%  GLINE draws a line to an existing plot with ends 
%  at locations specified by mouse clicks. When run
%  the routine waits for 2 mouse clicks on a plot which
%  define the ends of the line to be drawn.
%  The optional input variable (lc) can be used to
%  define the line style and color as in normal plotting.
%  Example: gline('-r'); plots a solid red line after the
%  mouse has been clicked on a plot twice. If no input
%  arguments are given, gline will draw a green line.  
%
%I/O: gline(lc);
%
%See Also: DP, HLINE, ELLPS, HIGHORB, VLINE, PLOT, PLTTERN, ZOOMPLS

%Copyright Eigenvector Research, Inc. 1998-2000
%nbg
%11/00 nbg changed see also

if nargin == 0
  lc  = '-g';
end
[x(1),y(1)] = ginput(1);
[x(2),y(2)] = ginput(1);
[m,n] = size(x);
v     = axis;
axis  = v;
if ishold
    plot(x,y,lc);
else
  hold on
  for ii=1:m
    plot(x,y,lc);
  end
  hold off
end
