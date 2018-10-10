function highorb(fig,action)
%HIGHORB GUI for rotating 3D plots
%  Places a graphical user interface for ratating 3D
%  plots on an existing figure. If no input is
%  supplied the gui is placed on the most current
%  figure. The optional input (fig) is the handle
%  of an existing figure in which to place the gui.
%  The default is 'highorb(gcf)'.
%
%  Note that the function attaches the gui in the upper
%  right hand corner of the figure window. Resizing the
%  figure does not resize the gui.
%
%I/O: highorb(fig)
%
%See also: ZOOMPLS

% Copyright Eigenvector Research, Inc. 1996-98
%nbg 4/97

if nargin<2
  bgc0     = [0 0 0];
  bgc1     = [1 0 1]*0.6;
  bgc2     = [1 1 1]*0.85;

  if nargin<1
    a      = gcf;
  end
  if isempty(findobj('Tag',['HighOrb',int2str(a)]));
    s        = get(a,'ResizeFcn');
    s1       = 'highorb([],''HIGHORBITsize'');';
    set(a,'ResizeFcn',[s,s1]);
    [c1,c2]  = view;
    c        = [c1,c2];
    p(1,1:4) = get(a,'position');
    p(1,1)   = p(1,3)-53;
    p(1,2)   = p(1,4)-73;
    p(1,3:4) = [0 0];
    b        = zeros(6,5);
    b(1,2:5) = [0   0  51 72];
    b(2,2:5) = [3   3  45 20];
    b(3,2:5) = [3  26  21 20];
    b(4,2:5) = [27 26  21 20];
    b(5,2:5) = [3  49  21 20];
    b(6,2:5) = [27 49  21 20];  
 
    b(1,1) = uicontrol('Parent',a, ...
	'BackgroundColor',bgc1, ...
	'Style','Frame','position',p+b(1,2:5), ...
	'Tag',['HighOrb',num2str(a)]);
    b(2,1) = uicontrol('Parent',a, ...
	'CallBack','highorb([],''viewdefault'')', ...
	'String','home','UserData',c);
    b(4,1) = uicontrol('Parent',a, ...
	'CallBack','highorb([],''viewfro'')', ...
	'String','D');
    b(3,1) = uicontrol('Parent',a, ...
	'CallBack','highorb([],''viewto'')', ...
	'String','U');
    b(6,1) = uicontrol('Parent',a, ...
	'CallBack','highorb([],''viewleft'')', ...
	'String','>');
    b(5,1) = uicontrol('Parent',a, ...
	'CallBack','highorb([],''viewright'')', ...
	'String','<');
    for jj=2:6
      set(b(jj,1),'position',p+b(jj,2:5), ...
      'BackgroundColor',bgc2, ...
	  'FontName','Geneva','Fontsize',10)
    end
    set(b(1,1),'UserData',b)
  end
else
  b          = findobj('Tag',['HighOrb',int2str(gcf)]);
  b          = get(b,'UserData');
  if strcmp(action,'viewdefault')
    %set(gca,'CameraPosition',[-203.2855 -327.0090 4.3301])
    %set(gca,'CameraUpVector',[0 0 1])
	c        = get(b(2,1),'UserData');
    view(c(1,1),c(1,2))
  elseif strcmp(action,'HIGHORBITsize')
    p(1,1:4) = get(gcf,'position');
    p(1,1)   = p(1,3)-53;
    p(1,2)   = p(1,4)-73;
    p(1,3:4) = [0 0];
    for jj=1:6
      set(b(jj,1),'position',p+b(jj,2:5))
    end
  else
    %set(gca,'stretch','off')
    z     = 5;
    [x,y] = view;  
    if strcmp(action,'viewright')|strcmp(action,'viewleft')
      if strcmp(action,'viewright')
        view(x+z,y)
      else
        view(x-z,y)
	  end
    elseif strcmp(action,'viewto')|strcmp(action,'viewfro')
      if strcmp(action,'viewto')
	    view(x,y+z)
      else
	    view(x,y-z)
	  end
    end
  end
end
