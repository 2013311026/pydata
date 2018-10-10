function scrpltr(scores,ssq,mo,label,action)
%SCRPLTR routine for plotting scores with confidence limits.
%  Inputs to SCRPLTR are (scores) the scores matrix and the
%  (ssq) matrix both returned by the PCA routine. (ssq) contains
%  variance information used to calculate confidence limits
%  [maximum = 99.9%].
%  Optional input (mo) is the number of samples (observations)
%  used to construct the PCA model [default = 100] and is used
%  to account for small sample statistics [e.g. mo < 30]. The
%  optional input (label) is a text matrix that allows sample
%  labelling. It must have the same number of rows as (scores).
%  Note: confidence limits are calculated assuming that
%  the scores are distributed normally. Although the limits
%  provide a statistical reference the assumption of a
%  normal distribution may not be valid.
%
%I/O: scrpltr(scores,ssq,mo,label);
%
%See also: DP, HIORB, HLINE, PCA, PLTLOADS, PLTSCRS, VLINE, ZOOMPLS

%Copyright Eigenvector Research, Inc. 1995-98
%Modified NBG 10/96

if nargin<5
  action  = 'initiate';
  fig2    = [];
  if nargin<4
    label = [];
	lflag = 0;
  else
    lflag = 1;
  end
  if nargin<3
    mo    = 100;
  end
  if nargin<2
    error('not enough input arguments')
  end
end

if strcmp(action,'initiate')
  bgc     = ['BackGroundColor'];
  bgc0    = [1 1 1];
  bgc1    = bgc0*0.7;
  bgc2    = [0.2 0.2 0.9];
  Pos     = ['Position'];
  ST      = ['Style'];            
  handl   = zeros(6,11);
  [ms,ns] = size(scores);
  [ml,nl] = size(label);
  if (ml~=ms)&(lflag==1)
    lflag = 0;
	disp(' ')
	disp('Input Error - size of SCORES and LABELS not compatible')
	disp('number of labels not equal to number of samples')
	disp(' ')
  end
%Set figure title
  fig     = figure('Name','Plot Scores','NumberTitle','Off',...
   'Position',[111 19 480 320],'Resize','off');
  axis off

%Define frame around select scores sliders
  uicontrol(fig,ST,'Frame',Pos,[11 161 220 150],bgc,bgc2);
  uicontrol(fig,ST,'Frame',Pos,[15 165 212 142],bgc,bgc1);
  uicontrol(fig,ST,'Text',Pos,[21 280 200 20],bgc,bgc1,...
   'String','PC Scores to Plot');
  handl(2,1) = uicontrol(fig,ST,'Slider',Pos,[51 251 140 20],...
   'Min',1,'Max',ns,'Value',1,'CallBack','scrpltr(0,0,0,0,''act21'')');
  handl(2,2) = uicontrol(fig,ST,'Text',Pos,[161 231 30 20],bgc,bgc1,...
   'String',num2str(get(handl(2,1),'Value')),'Horiz','right');
  uicontrol(fig,ST,'Text',Pos,[26 251 20 20],bgc,bgc1,...
   'String',num2str(get(handl(2,1),'Min')),'Horiz','left');
  uicontrol(fig,ST,'Text',Pos,[191 251 20 20],bgc,bgc1,...
   'String',num2str(get(handl(2,1),'Max')),'Horiz','right');
  uicontrol(fig,ST,'Text',Pos,[51 231 120 20],'String','PC 1',...
   bgc,bgc1,'Horiz','left');
  handl(2,3) = uicontrol(fig,ST,'Slider',Pos,[51 201 140 20],...
   'Min',1,'Max',ns,'Value',2,'CallBack','scrpltr(0,0,0,0,''act23'')');
  handl(2,4) = uicontrol(fig,ST,'Text',Pos,[161 181 30 20],bgc,bgc1,...
   'String',num2str(get(handl(2,3),'Value')),'Horiz','right');
  uicontrol(fig,ST,'Text',Pos,[26 201 20 20],bgc,bgc1,...
   'String',num2str(get(handl(2,3),'Min')),'Horiz','left');
  uicontrol(fig,ST,'Text',Pos,[191 201 20 20],bgc,bgc1,...
   'String',num2str(get(handl(2,3),'Max')),'Horiz','right');
  uicontrol(fig,ST,'Text',Pos,[51 181 120 20],bgc,bgc1,...
   'String','PC 2','Horiz','left');

%Define frame around confidence limits choices
  cl1  = 95; cl2  = 99;
  uicontrol(fig,ST,'Frame',Pos,[11 11 220 140],bgc,bgc2);
  uicontrol(fig,ST,'Frame',Pos,[15 15 212 132],bgc,bgc1);
  uicontrol(fig,ST,'Text','String','Confidence Limits',...
   Pos,[61 121 120 20],bgc,bgc1);
  handl(3,1) = uicontrol(fig,ST,'Radio','String','One',Pos,[95 100 60 20],...
   bgc,bgc1,'Value',1,'CallBack','scrpltr(0,0,0,0,''act31'')');
  handl(3,2) = uicontrol(fig,ST,'Radio','String','Two',Pos,[160 100 60 20],...
   bgc,bgc1,'Value',0,'CallBack','scrpltr(0,0,0,0,''act32'')');
  handl(3,3) = uicontrol(fig,ST,'Radio','String','None',Pos,[30 100 60 20],...
   bgc,bgc1,'Value',0,'CallBack','scrpltr(0,0,0,0,''act33'')');
  uicontrol(fig,ST,'Text',Pos,[38 67 90 20],bgc,bgc1,'Horiz','Left','String',...
   'First Limit');
  uicontrol(fig,ST,'Text',Pos,[38 37 90 20],bgc,bgc1,'Horiz','Left','String',...
   'Second Limit');
  handl(3,4) = uicontrol(fig,ST,'Edit',Pos,[136 70 40 20],bgc,bgc0,...
   'String',num2str(cl1),'CallBack','scrpltr(0,0,0,0,''act34'')');
  handl(3,5) = uicontrol(fig,ST,'Edit',Pos,[136 40 40 20],bgc,bgc0,...
   'CallBack','scrpltr(0,0,0,0,''act35'')');	
  uicontrol(fig,ST,'Text',Pos,[180 67 20 20],bgc,bgc1,'Horiz','Right',...
   'String','%');
  uicontrol(fig,ST,'Text',Pos,[180 37 20 20],bgc,bgc1,'Horiz','Right',...
   'String','%');

%Define axis frame
  uicontrol(fig,ST,'Frame',Pos,[251 61 220 250],bgc,bgc2);
  uicontrol(fig,ST,'Frame',Pos,[255 188 212 119],bgc,bgc1);
  uicontrol(fig,ST,'Frame',Pos,[255 65 212 119],bgc,bgc1);
  uicontrol(fig,ST,'Text',Pos,[261 280 200 20],bgc,bgc1,...
   'String','Axis Scale');
  uicontrol(fig,ST,'Text',Pos,[261 157 200 20],bgc,bgc1,...
   'String','Options');
  handl(4,1) = uicontrol(fig,ST,'Radio','String','Default','Value',1,...
   Pos,[296 265 80 20],'CallBack','scrpltr(0,0,0,0,''act41'')',bgc,bgc1);
  handl(4,2) = uicontrol(fig,ST,'Radio','String','Manual','Value',0,...
   Pos,[381 265 80 20],'CallBack','scrpltr(0,0,0,0,''act42'')',bgc,bgc1);
  handl(4,7) = uicontrol(fig,ST,'Radio','String','X-axis','Value',1,...
   Pos,[296 142 80 20],bgc,bgc1);
  handl(4,8) = uicontrol(fig,ST,'radio','String','Y-axis','Value',1,...
   Pos,[381 142 80 20],bgc,bgc1);
  uicontrol(fig,ST,'Text',Pos,[266 245 40 20],bgc,bgc1,'Horiz','Left',...
   'String','X-Axis');
  uicontrol(fig,ST,'Text',Pos,[280 230 30 20],bgc,bgc1,'Horiz','Right',...
   'String','min');
  uicontrol(fig,ST,'Text',Pos,[365 230 30 20],bgc,bgc1,'Horiz','Right',...
   'String','max');
  handl(4,3) = uicontrol(fig,ST,'Edit',Pos,[320 233 40 20],bgc,bgc0);
  handl(4,4) = uicontrol(fig,ST,'Edit',Pos,[402 233 40 20],bgc,bgc0);	
  uicontrol(fig,ST,'Text',Pos,[266 210 40 20],bgc,bgc1,'Horiz','Left',...
   'String','Y-Axis');
  uicontrol(fig,ST,'Text',Pos,[280 195 30 20],bgc,bgc1,'Horiz','Right',...
   'String','min');
  uicontrol(fig,ST,'Text',Pos,[365 195 30 20],bgc,bgc1,'Horiz','Right',...
   'String','max');
  handl(4,5) = uicontrol(fig,ST,'Edit',Pos,[320 198 40 20],bgc,bgc0);
  handl(4,6) = uicontrol(fig,ST,'Edit',Pos,[402 198 40 20],bgc,bgc0);
  uicontrol(fig,ST,'Text',Pos,[261 110 200 20],bgc,bgc1,...
   'String','Data Labels');  	
  handl(4,10) = uicontrol(fig,ST,'Radio','String','Number','Value',0,...
   Pos,[331 80 60 20],'CallBack','scrpltr(0,0,0,0,''act410'')',bgc,bgc1);
  if lflag > 0.5
    handl(4,9) = uicontrol(fig,ST,'Radio','String','None','Value',0,...
     Pos,[266 80 60 20],'CallBack','scrpltr(0,0,0,0,''act49'')',bgc,bgc1);
    handl(4,11) = uicontrol(fig,ST,'Radio','String','Label','Value',1,...
     Pos,[396 80 60 20],'CallBack','scrpltr(0,0,0,0,''act411'')',bgc,bgc1);
  else
    handl(4,9) = uicontrol(fig,ST,'Radio','String','None','Value',1,...
     Pos,[266 80 60 20],'CallBack','scrpltr(0,0,0,0,''act49'')',bgc,bgc1);
    handl(4,11) = uicontrol(fig,ST,'Radio','String','Label','Value',0,...
	 'Visible','Off',...
     Pos,[396 80 60 20],'CallBack','scrpltr(0,0,0,0,''act411'')',bgc,bgc1);
  end
 	

%Define the push buttons for routine control
  handl(6,2) = uicontrol(fig,ST,'push',Pos,[251 11 100 37],...
   'String','Plot','CallBack','scrpltr(0,0,0,0,''plot'')');
  handl(6,3) = uicontrol(fig,ST,'push',Pos,[371 11 100 37],...
   'String','Quit','CallBack','scrpltr(0,0,0,0,''quit'')');

  set(fig,'UserData',handl);
  set(handl(2,2),'UserData',scores);
  set(handl(2,3),'UserData',fig2);
  set(handl(2,4),'UserData',label);
  set(handl(3,2),'UserData',ssq);
  set(handl(3,3),'UserData',mo);
  set(handl(3,4),'UserData',cl1);
  set(handl(3,5),'UserData',cl2);
else
  fig     = gcf;
  handl   = get(fig,'UserData');
  scors   = get(handl(2,2),'UserData');
  ssq     = get(handl(3,2),'UserData');
  mo      = get(handl(3,3),'UserData');
  clmax   = 99.9;
  if strcmp(action,'plot')
    fig2  = get(handl(2,3),'UserData');
    PC1   = round(get(handl(2,1),'Value'));
	PC2   = round(get(handl(2,3),'Value'));
    cpt   = [0:0.1:2*3.15];
	if isempty(fig2)
	  fig2  = figure('Name','2D Scores Plot','NumberTitle','Off');
	  set(handl(2,3),'UserData',fig2);
	  set(handl(4,1),'Value',1);
	else
	  figure(fig2);
	end
	s1    = sprintf('Scores on PC %g',PC1);
	s2    = sprintf('Scores on PC %g',PC2);
	plot(scors(:,PC1),scors(:,PC2),'or'), hold on
	xlabel(s1), ylabel(s2)
	%calculate limits and plot them
	if get(handl(3,3),'Value') ~= 1
	  %plot first conf limit
	  cl1   = round(10*str2num(get(handl(3,4),'String')))/10;
	  alpha = (1-cl1/100)/2;
	  al1   = sqrt(ssq(PC1,2))*ttestp(alpha,mo-PC1,2);
	  al2   = sqrt(ssq(PC2,2))*ttestp(alpha,mo-PC2,2);
%	  al1   = sqrt(2*(ssq(PC1,2)))*erfinv(cl1/100);
%	  al2   = sqrt(2*(ssq(PC2,2)))*erfinv(cl1/100);
      x     = al1*cos(cpt);
      y     = al2*sin(cpt);
      plot(x,y,'--b')
	  if get(handl(3,2),'Value') == 1
	    %plot 2nd conf limit
	    cl2   = round(10*str2num(get(handl(3,5),'String')))/10;
	    alpha = (1-cl2/100)/2;
	    al1   = sqrt(ssq(PC1,2))*ttestp(alpha,mo-PC1,2);
        al2   = sqrt(ssq(PC2,2))*ttestp(alpha,mo-PC2,2);
%	    al1   = sqrt(2*(ssq(PC1,2)))*erfinv(cl2/100);
%	    al2   = sqrt(2*(ssq(PC2,2)))*erfinv(cl2/100);
        x     = al1*cos(cpt);
        y     = al2*sin(cpt);
        plot(x,y,'--b')
	  end
	end
	%perform axis manipulations
	figure(fig2)
	if get(handl(4,1),'Value')>0
	  axis auto
	  v     = axis;
	  for jj=1:4
	    set(handl(4,jj+2),'String',num2str(v(jj)))
	  end
	else
	  v     = zeros(1,4);
	  for jj=1:4
	    v(jj) = str2num(get(handl(4,jj+2),'String'));
	  end
      axis(v)
	end
	if get(handl(4,7),'Value')>0
	  plot([v(1:2)],[0 0],'-g')
	end
	if get(handl(4,8),'Value')>0
	  plot([0 0],[v(3:4)],'-g')
	end
	%put labels on
	if get(handl(4,11),'Value') > 0.5
	  label = get(handl(2,4),'UserData');
	  [mlabel,nlabel] = size(label);
	  space = [' '];
	  label = [space(ones(mlabel,1)) label];
      text(scors(:,PC1),scors(:,PC2),label);
    elseif get(handl(4,10),'Value') > 0.5
	  [mscors,nscors] = size(scors);
      for js = 1:mscors
	    s = [' ', int2str(js)];
		text(scors(js,PC1),scors(js,PC2),s);
	  end
    end	
  elseif strcmp(action,'act21')
    s     = round(get(handl(2,1),'Val'));
    set(handl(2,2),'String',num2str(s));
  elseif strcmp(action,'act23')
    s     = round(get(handl(2,3),'Val'));
    set(handl(2,4),'String',num2str(s));
  elseif strcmp(action,'act31')
    set(handl(3,1),'Value',1);
	set(handl(3,2:3),'Value',0);
	cl1   = get(handl(3,4),'UserData');
	set(handl(3,4),'String',num2str(cl1));
	set(handl(3,5),'String','');
  elseif strcmp(action,'act32')
    set(handl(3,[1 3]),'Value',0);
	set(handl(3,2),'Value',1);
	cl1   = get(handl(3,4),'UserData');
	set(handl(3,4),'String',num2str(cl1));
	cl2   = get(handl(3,5),'UserData');
	set(handl(3,5),'String',num2str(cl2));
  elseif strcmp(action,'act33')
    set(handl(3,1:2),'Value',0);
	set(handl(3,3),'Value',1);
	set(handl(3,4:5),'String','');
  elseif strcmp(action,'act34')	
    if get(handl(3,3),'Value') == 1
	  set(handl(3,4),'String','');
	else
	  cl1   = round(10*str2num(get(handl(3,4),'String')))/10;
	  if cl1<=clmax
	    set(handl(3,4),'String',num2str(cl1),'UserData',cl1);
	  else 
	    cl1 = get(handl(3,4),'UserData');
		set(handl(3,4),'String',num2str(cl1));
      end
	end
  elseif strcmp(action,'act35')
    if get(handl(3,2),'Value') ~=1
	  set(handl(3,5),'String','');
	else
	  cl2   = round(10*str2num(get(handl(3,5),'String')))/10;
	  if cl2<=clmax
	    set(handl(3,5),'String',num2str(cl2),'UserData',cl2);
	  else 
	    cl2 = get(handl(3,5),'UserData');
		set(handl(3,5),'String',num2str(cl2));
      end
	end
  elseif strcmp(action,'act41')
    set(handl(4,1),'Value',1);
	set(handl(4,2),'Value',0);
  elseif strcmp(action,'act42')
    fig2  = get(handl(2,3),'UserData');
    if fig2 > 0
      set(handl(4,1),'Value',0);
	  set(handl(4,2),'Value',1);
	else
      set(handl(4,1),'Value',1);
	  set(handl(4,2),'Value',0);
	end
  elseif strcmp(action,'act49')
    set(handl(4,9),'Value',1);
	set(handl(4,10:11),'Value',0);
  elseif strcmp(action,'act410')
    set(handl(4,10),'Value',1);
	set(handl(4,[9 11]),'Value',0);
  elseif strcmp(action,'act411')
    set(handl(4,11),'Value',1);
	set(handl(4,9:10),'Value',0);
  end
  hold off
%  set(fig,'UserData',[handl]);
  if strcmp(action,'quit')
    close;
  end
end
