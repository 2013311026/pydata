function zoompls(action)
%ZOOMPLS GUI for zooming in plots
%  Places a graphical user interface for zooming in
%  2D plots on an existing figure.
%
%  Note that the function attaches the gui to the lower
%  right hand corner of the figure window and is not
%  resized when the plot is resized.
%
%I/O: zoompls
%
%See also: DP, ELLPS, HIORB, HLINE, GLINE, VLINE

%Copyright Eigenvector Research, Inc. 1996-98
%nbg 5/17/97,6/97,10/98

if nargin<1
  bgc0       = [0 0 0];
  bgc1       = [1 0 1]*0.6;
  bgc2       = [1 1 1]*0.85;
  a          = gcf;
  if isempty(findobj('Tag',['ZoomFrame',int2str(a)]));
    s        = get(a,'ResizeFcn');
    s1       = 'zoompls(''ZOOMPLSsize'');';
    set(a,'ResizeFcn',[s,s1]);
    p(1,1:4) = get(a,'position');
    p(1,1)   = p(1,3)-74;
    p(1,2)   = 3;
    p(1,3:4) = [0 0];
    b        = zeros(6,5);
    b(1,2:5) = [ 0  0 74 56+14];
    b(2,2:5) = [ 2  2 34 25];
    b(3,2:5) = [ 2 29 34 25];
    b(4,2:5) = [38 29 34 25];
    b(5,2:5) = [ 2 56 70 14];
    b(6,2:5) = [38  2 34 25];
    x        = axis;
    s        = ['ZoomFrame',int2str(a)];
 
    b(1,1) = uicontrol('Parent',a, ...
	     'BackgroundColor',bgc1,'Tag',s, ...
	     'Style','Frame','position',p+b(1,2:5));
    b(2,1) = uicontrol('Parent',a, ...
	     'CallBack','zoompls(''viewdefault'')', ...
	     'String','home','UserData',x, ...
     'TooltipString','original axes');
    b(3,1) = uicontrol('Parent',a, ...
      'CallBack','zoompls(''into'')', ...
	     'String','in', ...
	     'Tag','PushOrbit2', ...
     'TooltipString','click opposite corners to zoom');
    b(4,1) = uicontrol('Parent',a, ...
	     'CallBack','zoompls(''outof'')', ...
	     'String','out', ...
     'TooltipString','zoom out one level');
    b(5,1) = uicontrol('Parent',a, ...
     'Style','Text', ...
	     'FontWeight','bold','ForegroundColor',[1 1 1], ...
	     'String','zoom','HorizontalAlignment','center');
    b(6,1) = uicontrol('Parent',a, ...
	     'CallBack','zoompls(''exitzoom'')', ...
	     'String','quit', ...
     'TooltipString','quit zoompls');

    for jj=2:6
      set(b(jj,1),'position',p+b(jj,2:5), ...
	        'BackgroundColor',bgc2,'Interruptible','off', ...
	        'BusyAction','cancel', ...
	        'FontName','Geneva','Fontsize',9)
    end
    set(b(5,1),'BackgroundColor',bgc1)
    set(b(1,1),'UserData',b)
  end
else
  s      = ['ZoomFrame',int2str(gcf)];
  b      = get(findobj('Tag',s),'UserData');
  if ~isempty(b)
    x    = get(b(2,1),'UserData');
    if strcmp(action,'viewdefault')
      x  = x(1,:);
	    axis(x)
    elseif strcmp(action,'ZOOMPLSsize')
      p(1,1:4) = get(gcf,'position');
      p(1,1)   = p(1,3)-74;
      p(1,2)   = 3;
      p(1,3:4) = [0 0];
      for jj=1:6
        set(b(jj,1),'position',p+b(jj,2:5))
      end
    elseif strcmp(action,'into')
      set(b(:,1),'Visible','Off')
      v(1:2,1) = ginput(1)';
	      v(1:2,2) = ginput(1)';
      if (v(1,1)~=v(1,2))&(v(2,1)~=v(2,2))
	        if v(1,2)<v(1,1)
	          m      = v(1,2);
	          v(1,2) = v(1,1);
	          v(1,1) = m;
	        end
	        if v(2,2)<v(2,1)
	          m      = v(2,2);
	          v(2,2) = v(2,1);
	          v(2,1) = m;
	        end
	        v        = [v(1,:), v(2,:)];
	        axis(v)
	        x        = [x;v];
      end
    elseif strcmp(action,'outof')
      m       = size(x,1);
	      if m>1
	        x     = x(1:m-1,:);
	        axis(x(m-1,:))
	      else
	        x     = x(1,:);
	        axis(x)
	      end
    end
    if strcmp(action,'exitzoom')
      for i1=1:6
        delete(b(i1,1))
      end
    else
      set(b(2,1),'UserData',x)
      set(b(:,1),'Visible','On')
    end
  end
end
