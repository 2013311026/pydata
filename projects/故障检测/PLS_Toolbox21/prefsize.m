function prefsize(hgui,hpass,action)
%PREFSIZE dialog for setting gui size preferences in the PLS_Toolbox.
%  Input (hgui) is a handle of a parent GUI indicating which
%  preference file is to be editted.
%    get(hgui,'Name') = 'Principal Components Analysis'
%      edits the pcaguipr.mat file, and
%    get(hgui,'Name') = 'Linear Regression'
%      edits the modguipr.mat file.
%  The output is (gs) which is 0 if the 'cancel' button is pressed
%  otherwise it is a 2 element vector with settings for width and
%  height in pixels. It is set as the user data of the valid handle
%  (hpass): set(hpass,'UserData',gs)
%
%I/O: prefsize(hgui,hpass);

%Copyright Eigenvector Research, Inc. 1998
%nbg

if nargin<3
  p    = get(0,'ScreenSize');          
  a    = figure('Color',[1 1 1],'NumberTitle','off', ...
        'Position',[p(3)/2-140 p(4)/2-10 300 170], ...
        'Name','Size Preferences', ...
        'Interruptible','off');
  as   = num2str(a);
  b    = zeros(6,1);
  p2   = get(hgui,'position');
  b(1,1) = uicontrol('Parent',a,'Style','edit', ...
        'Position',[21 111 50 30], ...
        'String',int2str(p2(3)), ...
        'CallBack',['prefsize(',as,',0,''edwidth'');']);
  b(2,1) = uicontrol('Parent',a,'Style','text', ...
        'Position',[81 111 210 30], ...
        'BackGroundColor',[1 1 1], ...
        'HorizontalAlignment','left', ...
        'String',['width (max = ', int2str(p(3)),' pixels)']);
  b(3,1) = uicontrol('Parent',a,'Style','edit', ...
        'Position',[21 61 50 30], ...
        'String',int2str(p2(4)), ...
        'CallBack',['prefsize(',as,',0,''edheight'');']);
  b(4,1) = uicontrol('Parent',a,'Style','text', ...
        'Position',[81 61 210 30], ...
        'BackGroundColor',[1 1 1], ...
        'HorizontalAlignment','left', ...
        'String',['height (max = ', int2str(p(4)),' pixels)']);
  b(5,1) = uicontrol('Parent',a,'Style','push', ...
        'Position',[121 11 80 30], ...
        'String','cancel', ...
        'CallBack',['prefsize(',as,',0,''cancel'');']);
  b(6,1) = uicontrol('Parent',a,'Style','push', ...
        'Position',[211 11 80 30], ...
        'String','ok', ...
        'CallBack',['prefsize(',as,',0,''ok'');']);
  set(b(1:6,1),'FontName','geneva','FontUnits','points', ...
    'FontSize',12,'FontWeight','bold','FontAngle','normal')
  adat.b = b;
  adat.p = p;
  adat.p2 = p2;
  adat.hpass = hpass;
  set(a,'UserData',adat)
  waitfor(a)
else
  adat   = get(hgui,'UserData');
  switch action
  case 'edwidth'
    s2   = round(str2num(get(adat.b(1,1),'String')));
    if s2<1|s2>adat.p(3)
      s2 = adat.p2(3);
    end
    set(adat.b(1,1),'String',num2str(s2))
  case 'edheight'
    s2   = round(str2num(get(adat.b(3,1),'String')));
    if s2<1|s2>adat.p(4)
      s2 = adat.p2(4);
    end
    set(adat.b(3,1),'String',num2str(s2))
  case 'cancel'
    gs   = 0;
    closereq
  case 'ok'
    gs(1,1) = round(str2num(get(adat.b(1,1),'String')));
    gs(1,2) = round(str2num(get(adat.b(3,1),'String')));
    set(adat.hpass,'UserData',gs)
    closereq
  end
end


