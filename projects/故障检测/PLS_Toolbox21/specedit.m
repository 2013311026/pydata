function specedit(x,f,action)
%SPECEDIT GUI for selecting spectral regions on a plot.
%  If input variable (x) is a vector SPECEDIT plots 
%  (x) [e.g. spectra] versus an optional input (f)
%  [e.g. wavelengths]. If (x) is a matrix of spectra
%  then SPECEDIT plots the mean of (x) where the rows 
%  of (x) correspond to different sample spectra and 
%  the columns of (x) correspond to different wavelengths.
%  Regions of (x) can be selected using push buttons.
%  The edited matrix input and column indices can be 
%  saved to the workspace interactively.
%
%I/O:  specedit(x,f)
%
%See also: BASELINE, LAMSEL

%Copyright Eigenvector Research, Inc. 1997-98
%nbg 4/97,6/97

if nargin<3
  bgc0    = [0 0 0];
  bgc1    = [1 0 1]*0.6;
  bgc2    = [1 1 1]*0.85;
  fnam    = 'geneva';
  fsiz    = 9;

  [mx,nx] = size(x);
  if nargin<1
    error('Error - function requires input')
  end
  if mx==1|nx==1
    if mx>nx
      y   = x';
	    x   = x';
    else
      y   = x;
    end
  else
    y     = mean(x);
  end
  if nargin<2
    f     = [1:length(y)];
  elseif size(f,1)>size(f,2)
    f     = f';
  end
  if length(f)~=length(y)
    warning('Warning - length of f not compatible with x')
    f     = [1:length(y)];
  end
  ind0    = zeros(1,length(y)); %vector w/ 1 selected, 0 unselected

  a   = figure('NumberTitle','Off','Name','Spectra Edit');
  plot(f,y,'-b','LineWidth',[0.5],'MarkerSize',[6])
  hold on
  h1  = plot(f(1,1),y(1,1),'.r','Visible','Off');
  hold off
  p(1,1:4) = get(a,'position');
  p(1,1)   = p(1,3)-63;
  p(1,2)   = p(1,4)-114;
  p(1,3:4) = [0 0];
  b        = zeros(5,5);
  b(1,2:5) = [0 0  61 112];
  b(2,2:5) = [3 3  55 25];
  b(3,2:5) = [3 30 55 25];
  b(4,2:5) = [3 57 55 25];
  b(5,2:5) = [3 84 55 25];
  
  b(1,1) = uicontrol('Parent',a, ...
	  'BackgroundColor',bgc1, ...
	  'Units','pixels','position',p+b(1,2:5), ...
	  'Style','Frame','UserData',[f]);
  b(2,1) = uicontrol('Parent',a, ...
	  'CallBack','specedit([],[],''savespc'')', ...
	  'String','save spec','UserData',[x]);
  b(3,1) = uicontrol('Parent',a, ...
	  'CallBack','specedit([],[],''saveind'')', ...
	  'String','save inds','UserData',[y]);
  b(4,1) = uicontrol('Parent',a, ...
	  'CallBack','specedit([],[],''deselect'')', ...
	  'String','deselect','UserData',[h1,y]);
  b(5,1) = uicontrol('Parent',a, ...
	  'CallBack','specedit([],[],''select'')', ...
	  'String','select','UserData',[ind0]);
  for jj=2:5
    set(b(jj,1),'position',p+b(jj,2:5), ...
	    'BackgroundColor',bgc2,'Interruptible','off', ...
	    'BusyAction','cancel','Units','pixels', ...
	    'FontName',fnam,'Fontsize',fsiz);
  end
  set(a,'UserData',b)
  zoompls
  s        = ['specedit([],[],''SPECEDTsize'');', ...
    'zoompls(''ZOOMPLSsize'');'];
  set(a,'ResizeFcn',s)
else
  b        = get(gcf,'UserData');
  if strcmp(action,'savespc')|strcmp(action,'saveind')
    indedt = get(b(5,1),'UserData');
    indedt = find(indedt);
    if strcmp(action,'savespc')
      xedt = get(b(2,1),'UserData');
      xedt = xedt(:,indedt);
	    svdlgpls(xedt)
    else
	    svdlgpls(indedt)
    end
  elseif strcmp(action,'SPECEDTsize')
    p(1,1:4) = get(gcf,'position');
    p(1,1)   = p(1,3)-63;
    p(1,2)   = p(1,4)-114;
    p(1,3:4) = [0 0];
    for jj=1:5
      set(b(jj,1),'position',p+b(jj,2:5))
    end
  else
    if strcmp(action,'select')
	    set(b(:,1),'visible','off')
      v     = ginput(2);
      f     = get(b(1,1),'UserData');
      ii    = find(f>=min(v(:,1)) & f<=max(v(:,1)));
      ind2  = zeros(1,length(f));
      ind2(1,ii) = ones(1,length(ii));
      ind0  = get(b(5,1),'UserData');
      ind0  = ind0+ind2;
      ii    = find(ind0>0);
      ind0  = zeros(1,length(f));
      ind0(1,ii) = ones(1,length(ii));
    elseif strcmp(action,'deselect')
	    set(b(:,1),'visible','off')
      v     = ginput(2);
      f     = get(b(1,1),'UserData');
      ii    = find(f>=min(v(:,1)) & f<=max(v(:,1)));
      ind2  = zeros(1,length(f));
      ind2(1,ii) = ones(1,length(ii));
      ind0  = get(b(5,1),'UserData');
      ind0  = ind0-ind2;
      ii    = find(ind0>0);
      ind0  = zeros(1,length(f));
      ind0(1,ii) = ones(1,length(ii));
    end
    set(b(5,1),'UserData',ind0);
    h1      = get(b(4,1),'UserData');
    y       = h1(1,2:length(h1));
	  h1      = h1(1,1);
    ii      = find(ind0);
    if length(f)<=100
      msz   = 12;
    elseif length(f)<=1000
      msz   = 10;
    else
      msz   = 6;
    end
    set(h1,'Xdata',f(1,ii),'Ydata',y(1,ii),'Visible','On', ...
      'MarkerSize',msz)
  end
  set(b(:,1),'visible','on')
end
