function data  = pltternf(data,x1lab,x2lab,x3lab);
%PLTTERNF Plots a 3D ternary diagram with frequency of occurrence.
%  Given an input matrix (data) that is m by 4 PLTTERNF plots the
%  corresponding ternary diagram. The first three columns
%  correspond to three concentrations, and the fourth column
%  is the frequency of occurrence of that concentration.
%  Concentrations are normalized to 0 to 100 and are output in
%  ternary coordinates in the variable (tdata).
%
%  Optional text inputs (x1lab), (x2lab), and (x3lab) are used
%  to put text labels on the axes.
% 
%I/O: tdata = pltternf(data,x1lab,x2lab,x3lab);
%
%See also: DP, ELLPS, HLINE, GLINE, VLINE, PLTTERN, ZOOMPLS

%Copyright Eigenvector Research, Inc. 1996-2000
%nbg
%nbg 11/00 changed label options

cop= 1;             %column option
cl = 1;				      %column width
ac = 'b';           %axis color
gc = 'c';           %grid color
gc2=  1;
bc = 'r';           %bar color
cc = 'or';
bw = 1;             %bar width
tl = 5;             %tick length
figure, set(gcf,'color',[1 1 1])
% plot grid
for ii=20:20:80
  h = plot3([ii (ii+(100-ii)*.5)],[0 (100-ii)*.866],[0 0],gc);hold on
  gcol = get(h,'Color');
  set(h,'Color',gcol*gc2);
  h = plot3([ii/2 (100-ii/2)],[ii ii]*.866,[0 0],gc);
  gcol = get(h,'Color');
  set(h,'Color',gcol*gc2);
  h = plot3([ii/2 ii],[ii*.866 0],[0 0],gc);
  gcol = get(h,'Color');
  set(h,'Color',gcol*gc2);
end
% plot ternary axes
plot3([0 100],[0 0],[0 0],ac)
plot3([0 50],[0 86.6],[0 0],ac)
plot3([50 100],[86.6 0],[0 0],ac)
plot3([0 100],[0 0],[0 0],ac)
% plot ticks
for ii=20:20:80
  plot3([ii ii+tl/2],[0 tl*.866],[0 0],ac)                %x1 ticks
  plot3([(100-ii/2-tl) (100-ii/2)],[ii ii]*.866,[0 0],ac) %x2 ticks
  plot3([ii/2 ii/2+tl/2],[ii (ii-tl)]*.866,[0 0],ac)      %x3 ticks
end
% plot frequency
[m,n] = size(data);
for ii=1:m
  data(ii,1:3) = data(ii,1:3)/sum(data(ii,1:3)')*100; %normalize
  data(ii,1)   = data(ii,1)+data(ii,2)*.5;
  data(ii,2)   = data(ii,2)*.866;
end
for ii=1:m
  if cop==1
    hxl = data(ii,1)-cl;
	hyu = data(ii,2)+cl;
	hyl = data(ii,2)-cl;
    hxr = data(ii,1)+cl;
    plot3([1 1]*hxl,[1 1]*hyl,[0 1]*data(ii,4),bc);
	plot3([1 1]*hxl,[1 1]*hyu,[0 1]*data(ii,4),bc);
	plot3([1 1]*hxr,[1 1]*hyl,[0 1]*data(ii,4),bc);
	plot3([1 1]*hxr,[1 1]*hyu,[0 1]*data(ii,4),bc);
	plot3([hxl hxl],[hyl hyu],[0 0],bc);
	plot3([hxl hxl],[hyl hyu],[1 1]*data(ii,4),bc);
    plot3([hxr hxr],[hyl hyu],[0 0],bc);
	plot3([hxr hxr],[hyl hyu],[1 1]*data(ii,4),bc);
	plot3([hxl hxr],[hyl hyl],[0 0],bc);
	plot3([hxl hxr],[hyl hyl],[1 1]*data(ii,4),bc);
	plot3([hxl hxr],[hyu hyu],[0 0],bc);
	plot3([hxl hxr],[hyu hyu],[1 1]*data(ii,4),bc);
  else
    plot3([1 1]*data(ii,1),[1 1]*data(ii,2),[1 1]*data(ii,4),cc);
    h = plot3([1 1]*data(ii,1),[1 1]*data(ii,2),[0 1]*data(ii,4),bc);
    set(h,'LineWidth',bw);
  end
end
% tick labels
for ii=0:20:100
  s = num2str(ii);
  text(ii,-5,0,s,'fontname','times','fontsize',14)                  %x1 label
  text((100-ii/2+5),ii*.866,0,s,'fontname','times','fontsize',14)   %x2 label
  text((50-ii/2-8),88-ii*.866,0,s,'fontname','times','fontsize',14) %x3 label
end
% axis labels
if nargin>1
  text(50,-10,0,x1lab,'fontname','times','fontsize',14)
end
if nargin>2
  text(75+10,54*.866,0,x2lab,'fontname','times','fontsize',14)
end
if nargin>3
  text(25-18,90-50*.866,0,x3lab,'fontname','times','fontsize',14)
end

set(gca,'Visible','off')
view(-20,50)
v  = axis;
axis([0 100 0 90 v(5:6)])
hold off
data = data(:,1:2);
