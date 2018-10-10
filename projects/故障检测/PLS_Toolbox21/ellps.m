function ellps(cnt,a,lc,ang,pax,zh)
%ELLPS plots an ellipse on an existing figure
%  The center of the ellipse is plotted at (cnt) 
%  [1 by 2] and the ellipse size is given by (a), 
%  with the x-range [a(1,1)] and y-range [a(1,2)]. The 
%  optional input variable (lc) defines the line style 
%  and color as in normal plotting. An additional optional 
%  input (ang) allows rotation of the ellips by an angle 
%  (ang) [default: ang = 0 radians].
%
%  Example: ellps([2 3],[4 1.5],':r');
%  plots a dotted ellipse with center (2,3), semimajor
%  axis 4 parallel to the x-axis and semiminor 1.5
%  parallel to the y-axis.
%
%  Inputs (pax) and (zh) are optional inputs used
%  when plotting in a 3D figure. (pax) defines the
%  axis perpindicular to the plane of the ellipse
%  [1 = x axis, 2 = y axis, 3 = z axis], and (zh)
%  defines the distance along the (pax) axis to
%  plot the ellipse.
%
%  Example: ellps([2 3],[4 1.5],'-b',pi/4,3,2);
%  plots an ellipse in a plane perpindicular to the
%  z axis at a high of z = 2.
%
%I/O: ellps(cnt,a,lc,ang,pax,zh);
%
%See Also: PLOT, DP, HLINE, VLINE

%Copyright Eigenvector Research, Inc. 1996-98
%Modified NBG 2/96, 11/96

if nargin<3,  lc  = '-g'; end
if nargin<4,  ang = 0;    end
if nargin<5,  pax = 0;    end
if nargin<6,  zh  = 0;    end
z     = [0:0.1:2*3.15]';
x     = a(1)*cos(z)+cnt(1)*ones(size(z));
y     = a(2)*sin(z)+cnt(2)*ones(size(z));
if ang~=0
  ang = ang*ones(size(z));
  x   = a(1)*cos(z-ang).*cos(ang)-a(2)*sin(z-ang).*sin(ang);
  x   = x+cnt(1)*ones(size(z));
  y   = a(1)*cos(z-ang).*sin(ang)+a(2)*sin(z-ang).*cos(ang);
  y   = y+cnt(2)*ones(size(z));
end
if ishold
  plot(x,y,lc);
  if pax~=0
    zax = zeros(size(x));
	if pax==3
	  plot3(x,y,zax,lc)
	elseif pax==2
	  plot3(x,zax,y,lc)
	elseif pax==1
	  plot3(zax,x,y,lc)
	end
  end
else
  if pax~=0
      zax = ones(size(x))*zh;
	if pax==3
	  hold on, plot3(x,y,zax,lc), hold off
	elseif pax==2
	  hold on, plot3(x,zax,y,lc), hold off
	elseif pax==1
	  hold on, plot3(zax,x,y,lc), hold off
	end
  else
    hold on, plot(x,y,lc), hold off
  end
end
