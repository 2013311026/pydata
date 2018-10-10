function g = pcapset(action,a,n);
%PCAPSET - called by PCAGUI
%
%See instead: PCAGUI

% a is figure handel
% n is number of PCs
%I/O: g = pcapset(action,a,n);

%Copyright Eigenvector Research, Inc. 1997-99
%nbg 4/7/97,7/97,9/98,10/98,3/99

bgc0        = [1 1 1];
bgc1        = [1 0 1]*0.6;
bgc2        = [1 1 1]*0.85;
bgc3        = [1 1 1]*0.95;
p1          = get(a,'position');
p1          = [0 p1(4) 0 0];

switch lower(action)
case 'plotopts1'
  %set up gui for selecting x y z
  g         = zeros(28,5);
  g(1,2:5)  = [4  -164 90 160];  % top frame   mauve
  g(2,2:5)  = [7   -23 84  16];  % top text    max PC
  g(3,2:5)  = [7  -161 84  20];  % top button  plot
  g(4,2:5)  = [19  -42 72  18];  % top popup   x
  g(5,2:5)  = [7   -43 12  16];  % top text    x
  g(6,2:5)  = [19  -65 72  18];  % top popup   y
  g(7,2:5)  = [7   -66 12  16];  % top text    y
  g(8,2:5)  = [19  -88 72  18];  % top popup   z
  g(9,2:5)  = [7   -89 12  16];  % top text    z
  g(10,2:5) = [7  -111 84  18];  % top popup menu lbl
  g(11,2:5) = [7  -112 12  16];  % top text lbl
  g(12,2:5) = [42 -138 35  20];  % top edit limit
  g(13,2:5) = [7  -135 35  16];  % top checkbox lbl
  g(14,2:5) = [79 -135 12  16];  % top text lbl %
  g(15,2:5) = [2  -329 94 327];  % black frame

  ah = axes('units','pixels', ...
    'position',[49.4+94 34.65 294.5 232.275+46]);
  set(ah,'units','normalized')	

  g(15,1) = uicontrol('Parent',a,'Style','frame', ...
    'BackgroundColor',[0 0 0],'Position',p1+g(15,2:5));
  g(1,1) = uicontrol('Parent',a,'Style','frame', ...
    'Position',p1+g(1,2:5),'BackgroundColor',bgc1, ...
    'UserData',ah);
  g(2,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc0,'Position',p1+g(2,2:5), ...
    'String',['max PC ',int2str(n)]);
  g(3,1) = uicontrol('Parent',a,'Style','PushButton', ...
    'BackgroundColor',bgc2,'Position',p1+g(3,2:5), ...
    'String','plot');
  g(4,1) = uicontrol('Parent',a,'Style','PopupMenu', ...
    'BackgroundColor',bgc0,'Position',p1+g(4,2:5), ...
    'String',' ');
  g(5,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc1,'Position',p1+g(5,2:5), ...
    'ForegroundColor',bgc0,'String','x');
  g(6,1) = uicontrol('Parent',a,'Style','PopupMenu', ...
    'BackgroundColor',bgc0,'Position',p1+g(6,2:5), ...
    'String',' ');
  s      = 'PC ';
  s      = [s(ones(n,1),:),int2str([1:n]')];
  s1     = str2mat('Q res','T^2',s);
  s      = str2mat('sample',s1);
  if n>1
    set(g(4,1),'String',s,'Value',4)
    set(g(6,1),'String',s,'Value',5)
  else
    set(g(4,1),'String',s,'Value',1)
    set(g(6,1),'String',s,'Value',4)
  end
  g(7,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc1,'Position',p1+g(7,2:5), ...
    'ForegroundColor',bgc0,'String','y');
  s      = str2mat('none',s1);
  g(8,1) = uicontrol('Parent',a,'Style','PopupMenu', ...
    'BackgroundColor',bgc0,'Position',p1+g(8,2:5), ...
    'String',s,'Value',1);
  g(9,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc1,'Position',p1+g(9,2:5), ...
    'ForegroundColor',bgc0,'String','z');
  g(10,1) = uicontrol('Parent',a,'Style','PopupMenu', ...
    'BackgroundColor',bgc0,'Position',p1+g(10,2:5), ...
    'String',' ');
  g(11,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc1,'Position',p1+g(11,2:5), ...
    'ForegroundColor',bgc0,'String','l','Visible','off');
  g(12,1) = uicontrol('Parent',a,'Style','edit', ...
    'BackgroundColor',bgc0,'Position',p1+g(12,2:5), ...
    'String','95','Enable','off',...
    'CallBack',['pcapset(''cledt'',',int2str(a),');']);
  g(13,1) = uicontrol('Parent',a,'Style','checkbox', ...
    'BackgroundColor',bgc1,'Position',p1+g(13,2:5), ...
    'ForegroundColor',bgc0,'String','lim','Value',0);
  g(14,1) = uicontrol('Parent',a,'Style','text', ...
    'BackgroundColor',bgc1,'Position',p1+g(14,2:5), ...
    'ForegroundColor',bgc0,'String','%');

  g(16,2:5) = [4  -257 90 91]; % frame middle
  g(17,2:5) = [7  -254 41 20]; % button data
  g(18,2:5) = [50 -254 41 20]; % button delete
  g(19,2:5) = [7  -231 41 20]; % button Q
  g(20,2:5) = [50 -231 41 20]; % button T^2  
  g(21,2:5) = [50 -208 41 20]; % button info
  g(22,2:5) = [7  -185 84 16]; % text
  g(28,2:5) = [7  -208 41 20]; % button spawn

  g(16,1) = uicontrol('Parent',a, ...
    'Position',p1+g(16,2:5), ...
    'BackgroundColor',bgc1, ...
    'Style','frame');
  g(17,1) = uicontrol('Parent',a, ...
    'Position',p1+g(17,2:5), ...
    'BackgroundColor',bgc2, ...
    'Enable','off');
  g(18,1) = uicontrol('Parent',a, ...
    'Position',p1+g(18,2:5), ...
    'BackgroundColor',bgc2, ...
    'Enable','off');
  g(19,1) = uicontrol('Parent',a, ...
    'Position',p1+g(19,2:5), ...
    'BackgroundColor',bgc2, ...
    'Enable','off');
  g(20,1) = uicontrol('Parent',a, ...
    'Position',p1+g(20,2:5), ...
    'BackgroundColor',bgc2, ...
    'Enable','off');
  g(21,1) = uicontrol('Parent',a, ...
    'Position',p1+g(21,2:5), ...
    'BackgroundColor',bgc2, ...
    'Enable','off');
  g(28,1) = uicontrol('Parent',a, ...
    'Position',p1+g(28,2:5), ...
    'BackgroundColor',bgc2, ...
    'Enable','off');
  g(22,1) = uicontrol('Parent',a, ...
    'Position',p1+g(22,2:5), ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0, ...
    'Style','text');

  g(23,2:5) = [4  -327 90 68]; % frame bottom
  g(24,2:5) = [7  -324 84 20]; % button home
  g(25,2:5) = [7  -301 41 20]; % button in
  g(26,2:5) = [50 -301 41 20]; % button out
  g(27,2:5) = [7  -278 84 16]; % text

  g(23,1) = uicontrol('Parent',a, ...
    'Position',p1+g(23,2:5), ...
    'BackgroundColor',bgc1, ...
    'Style','frame', ...
    'Tag',['PCAZoomFrame',int2str(a)]);
  g(24,1) = uicontrol('Parent',a, ...
    'Position',p1+g(24,2:5), ...
    'BackgroundColor',bgc2, ...
    'CallBack',['pcapset(''home'',',int2str(a),');'], ...
    'String','home', ...
    'Enable','off', ...
    'TooltipString','original axes');
  g(25,1) = uicontrol('Parent',a, ...
    'Position',p1+g(25,2:5), ...
    'BackgroundColor',bgc2, ...
    'String','in', ...
    'CallBack',['pcapset(''into'',',int2str(a),');'], ...
    'Enable','off', ...
    'TooltipString','click opposite corners to zoom');
  g(26,1) = uicontrol('Parent',a, ...
    'Position',p1+g(26,2:5), ...
    'BackgroundColor',bgc2, ...
    'String','out', ...
    'CallBack',['pcapset(''outof'',',int2str(a),');'], ...
    'Enable','off', ...
    'TooltipString','zoom out one level');
  g(27,1) = uicontrol('Parent',a, ...
    'Position',p1+g(27,2:5), ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0, ...
    'Style','text','String','zoom');
  set(g(1:28,1),'Interruptible','off', ...
    'BusyAction','cancel','Units','normalized', ...
    'FontName','geneva','FontSize',9)
  set(g([17:21 28],1),'Interruptible','on')
  if strcmp(lower(computer),'mac2')
    set(g(1:28,1),'FontSize',10)
  end
  set(a,'UserData',g)
case 'plotopts2'
  %set up gui for selecting x y z
  g         = zeros(22,5);
  g(1,2:5)  = [4  -164 90 160];  % top frame   mauve
  g(2,2:5)  = [7   -23 84  16];  % top text    max PC
  g(3,2:5)  = [7  -161 84  20];  % top button  plot
  g(4,2:5)  = [19  -42 72  18];  % top popup   x
  g(5,2:5)  = [7   -43 12  16];  % top text    x
  g(6,2:5)  = [19  -65 72  18];  % top popup   y
  g(7,2:5)  = [7   -66 12  16];  % top text    y
  g(8,2:5)  = [19  -88 72  18];  % top popup   z
  g(9,2:5)  = [7   -89 12  16];  % top text    z
  g(10,2:5) = [7  -111 84  18];  % top popup menu lbl
  g(11,2:5) = [7  -112 12  16];  % top text lbl
  g(12,2:5) = [2  -329 94 327];  % black frame

  ah = axes('Units','pixels', ...
   'Position',[49.4+94 34.65 294.5 232.275+46]);
  set(ah,'Units','normalized')
  ai = num2str(ah);	

  g(12,1) = uicontrol('Parent',a, ...
    'Style','frame', ...
    'BackgroundColor',[0 0 0], ...
    'Position',p1+g(12,2:5));
  set(g(12,1),'Units','normalized')
  g(1,1) = uicontrol('Parent',a, ...
    'Style','frame', ...
    'Position',p1+g(1,2:5), ...
    'BackgroundColor',bgc1,'UserData',ah);
  g(2,1) = uicontrol('Parent',a, ...
    'Style','text', ...
    'Position',p1+g(2,2:5), ...
    'BackgroundColor',bgc0, ...
    'String',['max PC ',int2str(n)]);
  g(3,1) = uicontrol('Parent',a, ...
    'Style','PushButton', ...
    'Position',p1+g(3,2:5), ...
    'BackgroundColor',bgc2,'String','plot');
  g(4,1) = uicontrol('Parent',a, ...
    'Position',p1+g(4,2:5), ...
    'BackgroundColor',bgc0,...
    'Style','PopupMenu','String',' ');
  g(5,1) = uicontrol('Parent',a, ...
    'Position',p1+g(5,2:5), ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0, ...	
    'Style','text','String','x');
  g(6,1) = uicontrol('Parent',a, ...
    'Position',p1+g(6,2:5), ...
    'BackgroundColor',bgc0,...
    'Style','PopupMenu','String',' ');
  s      = 'PC ';
  s      = [s(ones(n,1),:),int2str([1:n]')];
  set(g(4,1),'String',s,'Value',1)
  set(g(6,1),'String',s,'Value',2)
  g(7,1) = uicontrol('Parent',a, ...
    'Position',p1+g(7,2:5), ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0, ...
    'Style','text','String','y');
  s      = str2mat('none',s);
  g(8,1) = uicontrol('Parent',a, ...
    'Position',p1+g(8,2:5), ...
    'BackgroundColor',bgc0,...
    'Style','PopupMenu','String',s, ...
    'Value',1);
  g(9,1) = uicontrol('Parent',a, ...
    'Position',p1+g(9,2:5), ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0, ...
    'Style','text','String','z');
  g(10,1) = uicontrol('Parent',a, ...
    'Position',p1+g(10,2:5), ...
    'BackgroundColor',bgc0,...
    'Style','PopupMenu','String',' ');
  g(11,1) = uicontrol('Parent',a, ...
    'Position',p1+g(11,2:5), ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0, ...
    'Style','text','String','l','Visible','off');

  g(12,2:5) = [4  -257 90 91]; % frame middle
  g(13,2:5) = [7  -254 84 20]; % button info variables
  g(14,2:5) = [7  -231 84 16]; % text variables
  g(15,2:5) = [50 -208 41 20]; % button info samples
  g(22,2:5) = [7  -208 41 20]; % button spawn
  g(16,2:5) = [7  -185 84 16]; % text samples

  g(12,1) = uicontrol('Parent',a, ...
    'Position',p1+g(12,2:5), ...
    'BackgroundColor',bgc1, ...
    'Style','frame');
  g(13,1) = uicontrol('Parent',a, ...
    'Position',p1+g(13,2:5), ...
    'BackgroundColor',bgc2, ...
    'String','info','Enable','off');
  g(14,1) = uicontrol('Parent',a, ...
    'Position',p1+g(14,2:5),'Style','text', ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0, ...
    'String','variables');
  g(15,1) = uicontrol('Parent',a, ...
    'Position',p1+g(15,2:5),'String','info', ...
    'BackgroundColor',bgc2,'Enable','off');
    s   = ['copyobj(',ai,',figure); '];
    s   = [s,' set(',ai,',''position'',[0.13 0.11 0.775 0.815])'];
  g(22,1) = uicontrol('Parent',a,'CallBack',s, ...
    'Position',p1+g(22,2:5),'String','spawn', ...
    'BackgroundColor',bgc2,'Enable','off');
  g(16,1) = uicontrol('Parent',a,'String','samples', ...
    'Position',p1+g(16,2:5),'Style','text', ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0);

  g(17,2:5) = [4  -327 90 68]; % frame bottom
  g(18,2:5) = [7  -324 84 20]; % button home
  g(19,2:5) = [7  -301 41 20]; % button in
  g(20,2:5) = [50 -301 41 20]; % button out
  g(21,2:5) = [7  -278 84 16]; % text

  g(17,1) = uicontrol('Parent',a, ...
    'Position',p1+g(17,2:5), ...
    'BackgroundColor',bgc1, ...
    'Style','frame','Tag',['PCAZoomFrame',int2str(a)]);
  g(18,1) = uicontrol('Parent',a, ...
    'Position',p1+g(18,2:5), ...
    'BackgroundColor',bgc2, ...
    'CallBack',['pcapset(''home'',',int2str(a),');'], ...
    'String','home','Enable','off', ...
    'TooltipString','original axes');
  g(19,1) = uicontrol('Parent',a, ...
    'Position',p1+g(19,2:5), ...
    'BackgroundColor',bgc2, ...
    'String','in','Enable','off', ...
    'CallBack',['pcapset(''into'',',int2str(a),');'], ...
    'TooltipString','click opposite corners to zoom');
  g(20,1) = uicontrol('Parent',a, ...
    'Position',p1+g(20,2:5), ...
    'BackgroundColor',bgc2, ...
    'String','out','Enable','off', ...
    'CallBack',['pcapset(''outof'',',int2str(a),');'], ...
    'TooltipString','zoom out one level');
  g(21,1) = uicontrol('Parent',a, ...
    'Position',p1+g(21,2:5), ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0, ...
    'Style','text','String','zoom');
  set(g(1:size(g,1),1),'Interruptible','off', ...
    'BusyAction','cancel','Units','normalized', ...
    'FontName','geneva','FontSize',9)
  set(g([13 15 22],1),'Interruptible','on')
  if strcmp(lower(computer),'mac2')
    set(g(1:size(g,1),1),'FontSize',10)
  end
  set(a,'UserData',g)
case 'plotopts3'
  %set up gui for selecting x y
  g         = zeros(22,5);
  g(1,2:5)  = [4  -164 90 160];  % top frame   mauve
  g(2,2:5)  = [7   -23 84  16];  % top text    max PC
  g(3,2:5)  = [7  -161 84  20];  % top button  plot
  g(4,2:5)  = [19  -42 72  18];  % top popup   x
  g(5,2:5)  = [7   -43 12  16];  % top text    x
  g(6,2:5)  = [19  -65 72  18];  % top popup   y
  g(7,2:5)  = [7   -66 12  16];  % top text    y
  g(8,2:5)  = [19  -88 72  18];  % top popup   z
  g(9,2:5)  = [7   -89 12  16];  % top text    z
  g(10,2:5) = [7  -111 84  18];  % top popup menu lbl
  g(11,2:5) = [7  -112 12  16];  % top text lbl
  g(12,2:5) = [2  -329 94 327];  % black frame

  ah = axes('units','pixels', ...
   'position',[49.4+94 34.65 294.5 232.275+46]);
  set(ah,'units','normalized')
  ai = num2str(ah);

  g(12,1) = uicontrol('Parent',a, ...
    'Style','frame', ...
    'BackgroundColor',[0 0 0], ...
    'Position',p1+g(12,2:5));
  set(g(12,1),'Units','normalized')
  g(1,1) = uicontrol('Parent',a, ...
    'Style','frame', ...
    'Position',p1+g(1,2:5), ...
    'BackgroundColor',bgc1,'UserData',ah);
  g(2,1) = uicontrol('Parent',a, ...
    'Style','text', ...
    'Position',p1+g(2,2:5), ...
    'BackgroundColor',bgc0);
  g(3,1) = uicontrol('Parent',a, ...
    'Style','PushButton', ...
    'Position',p1+g(3,2:5), ...
    'BackgroundColor',bgc2, ...
    'String','plot');
  s      = str2mat('sample','variable');
  g(4,1) = uicontrol('Parent',a, ...
    'Position',p1+g(4,2:5), ...
    'BackgroundColor',bgc0,'Value',2, ...
    'Style','PopupMenu','String',s);
  g(5,1) = uicontrol('Parent',a, ...
    'Position',p1+g(5,2:5), ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0, ...	
    'Style','text','String','x');
  s      = str2mat('data','mean','std');
  g(6,1) = uicontrol('Parent',a, ...
    'Position',p1+g(6,2:5), ...
    'BackgroundColor',bgc0,'Value',2, ...
    'Style','PopupMenu','String',s);
  g(7,1) = uicontrol('Parent',a, ...
    'Position',p1+g(7,2:5), ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0, ...
    'Style','text','String','y');
  g(8,1) = uicontrol('Parent',a, ...
    'Position',p1+g(8,2:5), ...
    'BackgroundColor',bgc0,'Visible','off');
  g(9,1) = uicontrol('Parent',a, ...
    'Position',p1+g(9,2:5), ...
    'BackgroundColor',bgc1,'Visible','off');
  g(10,1) = uicontrol('Parent',a, ...
    'Position',p1+g(10,2:5), ...
    'BackgroundColor',bgc0,'Visible','off');
  g(11,1) = uicontrol('Parent',a, ...
    'Position',p1+g(11,2:5), ...
    'BackgroundColor',bgc1,'Visible','off');

  g(12,2:5) = [4  -257 90 91]; % frame middle
  g(13,2:5) = [7  -254 84 20]; % button info variables
  g(14,2:5) = [7  -231 84 16]; % text variables
  g(15,2:5) = [50 -208 41 20]; % button info samples
  g(22,2:5) = [7  -208 41 20]; % button spawn
  g(16,2:5) = [7  -185 84 16]; % text samples

  g(12,1) = uicontrol('Parent',a, ...
    'Position',p1+g(12,2:5), ...
    'BackgroundColor',bgc1, ...
    'Style','frame');
  g(13,1) = uicontrol('Parent',a, ...
    'Position',p1+g(13,2:5), ...
    'BackgroundColor',bgc2,'Visible','off', ...
    'String','info','Enable','off');
  g(14,1) = uicontrol('Parent',a, ...
    'Position',p1+g(14,2:5),'Style','text', ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0, ...
    'String','variables','Visible','off');
  g(15,1) = uicontrol('Parent',a, ...
    'Position',p1+g(15,2:5),'visible','off', ...
    'BackgroundColor',bgc2, ...
    'String','info','Enable','off');
    s   = ['copyobj(',ai,',figure);'];
    s   = [s,' set(',ai,',''position'',[0.13 0.11 0.775 0.815])'];
  g(22,1) = uicontrol('Parent',a, ...
    'Position',p1+g(22,2:5),'Callback',s, ...
    'BackgroundColor',bgc2, ...
    'String','spawn','Enable','off');
  g(16,1) = uicontrol('Parent',a, ...
    'Position',p1+g(16,2:5),'Style','text', ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0, ...
    'String','samples','Visible','off');

  g(17,2:5) = [4  -327 90 68]; % frame bottom
  g(18,2:5) = [7  -324 84 20]; % button home
  g(19,2:5) = [7  -301 41 20]; % button in
  g(20,2:5) = [50 -301 41 20]; % button out
  g(21,2:5) = [7  -278 84 16]; % text

  g(17,1) = uicontrol('Parent',a, ...
    'Position',p1+g(17,2:5), ...
    'BackgroundColor',bgc1, ...
    'Style','frame','Tag',['PCAZoomFrame',int2str(a)]);
  g(18,1) = uicontrol('Parent',a, ...
    'Position',p1+g(18,2:5), ...
    'BackgroundColor',bgc2, ...
    'CallBack',['pcapset(''home'',',int2str(a),');'], ...
    'String','home','Enable','off', ...
    'TooltipString','original axes');
  g(19,1) = uicontrol('Parent',a, ...
    'Position',p1+g(19,2:5), ...
    'BackgroundColor',bgc2, ...
    'String','in','Enable','off', ...
    'CallBack',['pcapset(''into'',',int2str(a),');'], ...
    'TooltipString','click opposite corners to zoom');
  g(20,1) = uicontrol('Parent',a, ...
    'Position',p1+g(20,2:5), ...
    'BackgroundColor',bgc2, ...
    'String','out','Enable','off', ...
    'CallBack',['pcapset(''outof'',',int2str(a),');'], ...
    'TooltipString','zoom out one level');
  g(21,1) = uicontrol('Parent',a, ...
    'Position',p1+g(21,2:5), ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc0, ...
    'Style','text','String','zoom');
  set(g(1:22,1),'Interruptible','off', ...
    'BusyAction','cancel','Units','normalized', ...
    'FontName','geneva','FontSize',9)
  set(g([13 15 22],1),'Interruptible','on')
  if strcmp(lower(computer),'mac2')
    set(g(1:size(g,1),1),'FontSize',10)
  end
  set(a,'UserData',g)
case 'cledt'
  g     = get(a,'UserData');
  n     = str2num(get(g(12,1),'String'));
  if (n>99.9)|(n<=0)
    set(g(12,1),'String','95')
  else
    n   = round(n*10)/10;
    set(g(12,1),'String',num2str(n))
  end
  set(g(3,1),'Enable','on')
otherwise
  g     = get(a,'UserData'); 
  x     = get(g(20,1),'UserData');
  switch lower(action)
  case 'home'
    x   = x(1,:);
    axis(x)
  case 'into'
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
  case 'outof'
    m        = size(x,1);
    if m>1
      x      = x(1:m-1,:);
      axis(x(m-1,:))
    else
      x      = x(1,:);
      axis(x)
     end
  end
  set(g(20,1),'UserData',x)
end
