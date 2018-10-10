function data  = plttern(data,x1lab,x2lab,x3lab);
%PLTTERN Plots a 2D ternary diagram.
%  Given an input matrix (data) that is m by 3 PLTTERN plots the
%  corresponding ternary diagram. The three columns correspond
%  to three concentrations (>=0 and real). Concentrations are
%  normalized to 0 to 100 and are output in ternary coordinates
%  in the variable (tdata).
%
%  Optional text inputs (x1lab), (x2lab), and (x3lab) are used
%  to put text labels on the axes.
% 
%I/O: tdata = plttern(data,x1lab,x2lab,x3lab);
%
%See also: DP, ELLPS, HLINE, GLINE, VLINE, PLTTERNF, ZOOMPLS

%Copyright Eigenvector Research, Inc. 1998-2000
%nbg
%nbg 11/00 changed label options

cop= 1;             %column option
cl = 1;				%column width
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
  h = plot([ii (ii+(100-ii)*.5)],[0 (100-ii)*.866],gc);hold on
  gcol = get(h,'Color');
  set(h,'Color',gcol*gc2);
  h = plot([ii/2 (100-ii/2)],[ii ii]*.866,gc);
  gcol = get(h,'Color');
  set(h,'Color',gcol*gc2);
  h = plot([ii/2 ii],[ii*.866 0],gc);
  gcol = get(h,'Color');
  set(h,'Color',gcol*gc2);
end
% plot ternary axes
plot([0 100],[0 0],ac)
plot([0 50],[0 86.6],ac)
plot([50 100],[86.6 0],ac)
plot([0 100],[0 0],ac)
% plot ticks
for ii=20:20:80
  plot([ii ii+tl/2],[0 tl*.866],ac)                %x1 ticks
  plot([(100-ii/2-tl) (100-ii/2)],[ii ii]*.866,ac) %x2 ticks
  plot([ii/2 ii/2+tl/2],[ii (ii-tl)]*.866,ac)      %x3 ticks
end
% plot data
[m,n] = size(data);
for ii=1:m
  data(ii,1:3) = data(ii,1:3)/sum(data(ii,1:3)')*100; %normalize
  data(ii,1)   = data(ii,1)+data(ii,2)*.5;
  data(ii,2)   = data(ii,2)*.866;
end
plot(data(:,1),data(:,2),'or','markerfacecolor','r')
% tick labels
for ii=0:20:100
  s = num2str(ii);
  text(ii-1,-5,s,'fontname','times','fontsize',14)                  %x1 label
  text((100-ii/2+5),ii*.866,s,'fontname','times','fontsize',14)     %x2 label
  text((50-ii/2-8),86.6-ii*.866,s,'fontname','times','fontsize',14) %x3 label
end
% axis labels
if nargin>1
  text(50,-10,x1lab,'fontname','times','fontsize',14)
end
if nargin>2
  text(75+10,54*.866,x2lab,'fontname','times','fontsize',14)
end
if nargin>3
  text(25-18,90-50*.866,x3lab,'fontname','times','fontsize',14)
end

set(gca,'Visible','off')
axis([0 100 0 90])
hold off
data = data(:,1:2);
