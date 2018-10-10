function [ii] = sampidr(x,y)
%SAMPIDR Identifies a sample on a 2D plot
%  SAMPIDR identifies a sample on a plot of y vs x
%  such as "plot(x,y,'o'). Inputs are (x) the vector
%  for the abscissa and (y) the vector the ordinate.
%  The input vectors must be the same length. When run
%  SAMPIDR will identify the indice (ii) of the sample
%  closest to the point where the mouse is clicked on
%  the plot.
%
%I/O: ii = sampidr(x,y);

%Copyright Eigenvector Research, Inc. 1996-98
%nbg

[mx,nx] = size(x);
[my,ny] = size(y);
if (mx>1&nx>1)|(my>1&ny>1)
  error('Inputs must be vectors')
end
if nx>mx
  x     = x';
  mx    = nx;
end
if ny>my
  y     = y';
  my    = ny;
end
if (mx~=my)
  error('Inputs must be same length')
end

w       = ginput(1);
v       = axis;
xd      = (x - w(ones(mx,1),1))/(v(2)-v(1));
yd      = (y - w(ones(mx,1),2))/(v(4)-v(3));
d       = [xd.^2 yd.^2];
[d,ii]  = min(sum(d')');

