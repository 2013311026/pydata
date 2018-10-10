function prefpls(hgui,action)
%PREFPLS dialog for setting gui preferences in the PLS_Toolbox.
%  Input (hgui) is a handle of a parent GUI indicating which
%  preference file is to be editted.
%    get(hgui,'Name') = 'Principal Components Analysis'
%      edits the pcaprefg.mat file for PCAGUI, and
%    get(hgui,'Name') = 'Linear Regression'
%      edits the pcaprefg.mat file for MODLGUI.
%
%I/O: prefpls(hgui);

%Copyright Eigenvector Research, Inc. 1998
%nbg 10/98,1/99

if nargin<2
  p    = get(0,'ScreenSize');          
  a    = figure('Color',[1 1 1],'NumberTitle','off', ...
        'Position',[p(3)/2-150 p(4)/2 300 170], ...
        'HandleVisibility','callback','Interruptible','off');
  as   = num2str(a);
  b    = zeros(8,1);
  b(1,1) = uicontrol('Parent',a,'Style','push', ...
        'Position',[11 131 135 30]);
  b(2,1) = uicontrol('Parent',a,'Style','push', ...
        'Position',[11 91 135 30]);
  b(3,1) = uicontrol('Parent',a,'Style','push', ...
        'Position',[11 51 135 30]);
  b(4,1) = uicontrol('Parent',a,'Style','push', ...
        'Position',[11 11 135 30]);
  b(5,1) = uicontrol('Parent',a,'Style','push', ...
        'Position',[156 131 135 30]);
  b(6,1) = uicontrol('Parent',a,'Style','push', ...
        'Position',[156 91 135 30]);
  b(7,1) = uicontrol('Parent',a,'Style','push', ...
        'Position',[156 51 135 30]);
  b(8,1) = uicontrol('Parent',a,'Style','push', ...
        'Position',[156 11 135 30]);
  set(b,'FontName','geneva','FontUnits','points', ...
    'FontSize',12,'FontWeight','bold','FontAngle','normal')
  

  if strcmp(get(hgui,'Name'),'Principal Components Analysis')
    sgui = 'pca';
  elseif strcmp(get(hgui,'Name'),'Linear Regression')
    sgui = 'mod';
  else
    error('ERROR - Input to PREFPLS.M not recognized')
  end

  switch sgui
  case 'pca'
    set(a,'Name','PCAGUI Preferences')
    set(b(1,1),'String','table header', ...
      'CallBack',['prefpls(',as,',''tableheader'')'])
    set(b(2,1),'String','table body', ...
      'CallBack',['prefpls(',as,',''tablebody'')'])
    set(b(3,1),'String','status windows', ...
      'CallBack',['prefpls(',as,',''statwindow'')'])
    set(b(4,1),'String','buttons', ...
      'CallBack',['prefpls(',as,',''buttons'')'])
    set(b(5,1),'String','GUI size', ...
      'CallBack',['prefpls(',as,',''size'')'])
    set(b(6,1),'Visible','off')
    set(b(7,1),'String','default settings', ...
      'CallBack',['prefpls(',as,',''defaults'')'])
    set(b(8,1),'String','close','CallBack','close(gcf)')
  case 'mod'
    set(a,'Name','MODLGUI Preferences')
    set(b(1,1),'String','table header', ...
      'CallBack',['prefpls(',as,',''tableheader'')'])
    set(b(2,1),'String','table body', ...
      'CallBack',['prefpls(',as,',''tablebody'')'])
    set(b(3,1),'String','status windows', ...
      'CallBack',['prefpls(',as,',''statwindow'')'])
    set(b(4,1),'String','buttons', ...
      'CallBack',['prefpls(',as,',''buttons'')'])
    set(b(5,1),'String','GUI size', ...
      'CallBack',['prefpls(',as,',''size'')'])
    set(b(6,1),'Visible','off')
    set(b(7,1),'String','default settings', ...
      'CallBack',['prefpls(',as,',''defaults'')'])
    set(b(8,1),'String','close','CallBack','close(gcf)')
  end
  adata.sgui = sgui;
  adata.ghan = get(hgui,'Children');
  adata.b    = b;
  set(a,'UserData',adata)
  uiwait(a)
else
  adata = get(hgui,'UserData');
  load pcaprefg
  switch adata.sgui
  case 'pca'
    switch action
    case 'tableheader'
      s2  = uisetfont(adata.ghan(16),'Table Header');
      if isstruct(s2)
        pcaprefg.pcauser.tableheader = s2;
        spath = savit(adata.sgui);
        eval(spath)
      end
    case 'tablebody'
      s2  = uisetfont(adata.ghan(13),'Table Body');
      if isstruct(s2)
        pcaprefg.pcauser.tablebody = s2;
        spath = savit(adata.sgui);
        eval(spath)
      end
    case 'statwindow'
      s2  = uisetfont(adata.ghan(11),'Status Windows');
      if isstruct(s2)
        pcaprefg.pcauser.statwindow = s2;
        set(adata.ghan(12),'FontName',s2.FontName, ...
         'FontUnits',s2.FontUnits,'FontSize',s2.FontSize, ...
         'FontWeight',s2.FontWeight,'FontAngle',s2.FontAngle)
        spath = savit(adata.sgui);
        eval(spath)
      end
    case 'buttons'
      s2  = uisetfont(adata.ghan(8),'Push Buttons');
      if isstruct(s2)
        pcaprefg.pcauser.buttons = s2;
        set(adata.ghan(1:7),'FontName',s2.FontName, ...
         'FontUnits',s2.FontUnits,'FontSize',s2.FontSize, ...
         'FontWeight',s2.FontWeight,'FontAngle',s2.FontAngle)
        spath = savit(adata.sgui);
        eval(spath)
      end
    case 'size'
      s1  = get(adata.ghan(1),'Parent');
      p   = get(s1,'Position');
      prefsize(s1,adata.b(5,1));
      s2  = get(adata.b(5,1),'UserData');
      if length(s2)>1
        set(s1,'Position',[p(1) p(2) s2(1) s2(2)])
        pcaprefg.pcauser.widthheight = [s2(1) s2(2)];
        spath = savit(adata.sgui);
        eval(spath)
      end
    case 'defaults'
      s2  = pcaprefg.pcadefault.tableheader;
      set(adata.ghan(16),'FontName',s2.FontName, ...
         'FontUnits',s2.FontUnits,'FontSize',s2.FontSize, ...
         'FontWeight',s2.FontWeight,'FontAngle',s2.FontAngle)
      s2  = pcaprefg.pcadefault.tablebody;
      set(adata.ghan(13),'FontName',s2.FontName, ...
         'FontUnits',s2.FontUnits,'FontSize',s2.FontSize, ...
         'FontWeight',s2.FontWeight,'FontAngle',s2.FontAngle)
      s2  = pcaprefg.pcadefault.statwindow;
      set(adata.ghan(11:12),'FontName',s2.FontName, ...
         'FontUnits',s2.FontUnits,'FontSize',s2.FontSize, ...
         'FontWeight',s2.FontWeight,'FontAngle',s2.FontAngle)
      s2  = pcaprefg.pcadefault.buttons;
      set(adata.ghan(1:8),'FontName',s2.FontName, ...
         'FontUnits',s2.FontUnits,'FontSize',s2.FontSize, ...
         'FontWeight',s2.FontWeight,'FontAngle',s2.FontAngle)
      s1  = get(adata.ghan(1),'Parent');
      p   = get(s1,'Position');
      s2  =  pcaprefg.pcadefault.widthheight;
      set(s1,'Position',[p(1) p(2) s2(1) s2(2)])
      pcaprefg.pcauser = pcaprefg.pcadefault;
      spath = savit(adata.sgui);
      eval(spath)
    end
  case 'mod'
    switch action
    case 'tableheader'
      s2  = uisetfont(adata.ghan(18),'Table Header');
      if isstruct(s2)
        pcaprefg.moduser.tableheader = s2;
        spath = savit(adata.sgui);
        eval(spath)
      end
    case 'tablebody'
      s2  = uisetfont(adata.ghan(15),'Table Body');
      if isstruct(s2)
        pcaprefg.moduser.tablebody = s2;
        spath = savit(adata.sgui);
        eval(spath)
      end
    case 'statwindow'
      s2  = uisetfont(adata.ghan(13),'Status Windows');
      if isstruct(s2)
        pcaprefg.moduser.statwindow = s2;
        set(adata.ghan(14),'FontName',s2.FontName, ...
         'FontUnits',s2.FontUnits,'FontSize',s2.FontSize, ...
         'FontWeight',s2.FontWeight,'FontAngle',s2.FontAngle)
        spath = savit(adata.sgui);
        eval(spath)
      end
    case 'buttons'
      s2  = uisetfont(adata.ghan(8),'Push Buttons');
      if isstruct(s2)
        pcaprefg.moduser.buttons = s2;
        set(adata.ghan(1:7),'FontName',s2.FontName, ...
         'FontUnits',s2.FontUnits,'FontSize',s2.FontSize, ...
         'FontWeight',s2.FontWeight,'FontAngle',s2.FontAngle)
        spath = savit(adata.sgui);
        eval(spath)
      end
    case 'size'
      s1  = get(adata.ghan(1),'Parent');
      p   = get(s1,'Position');
      prefsize(s1,adata.b(5,1));
      s2  = get(adata.b(5,1),'UserData');
      if length(s2)>1
        set(s1,'Position',[p(1) p(2) s2(1) s2(2)])
        pcaprefg.moduser.widthheight = [s2(1) s2(2)];
        spath = savit(adata.sgui);
        eval(spath)
      end
    case 'defaults'
      s2  = pcaprefg.moddefault.tableheader;
      set(adata.ghan(18),'FontName',s2.FontName, ...
         'FontUnits',s2.FontUnits,'FontSize',s2.FontSize, ...
         'FontWeight',s2.FontWeight,'FontAngle',s2.FontAngle)
      s2  = pcaprefg.moddefault.tablebody;
      set(adata.ghan(15),'FontName',s2.FontName, ...
         'FontUnits',s2.FontUnits,'FontSize',s2.FontSize, ...
         'FontWeight',s2.FontWeight,'FontAngle',s2.FontAngle)
      s2  = pcaprefg.moddefault.statwindow;
      set(adata.ghan(13:14),'FontName',s2.FontName, ...
         'FontUnits',s2.FontUnits,'FontSize',s2.FontSize, ...
         'FontWeight',s2.FontWeight,'FontAngle',s2.FontAngle)
      s2  = pcaprefg.moddefault.buttons;
      set(adata.ghan(1:8),'FontName',s2.FontName, ...
         'FontUnits',s2.FontUnits,'FontSize',s2.FontSize, ...
         'FontWeight',s2.FontWeight,'FontAngle',s2.FontAngle)
      s1  = get(adata.ghan(1),'Parent');
      p   = get(s1,'Position');
      s2  =  pcaprefg.moddefault.widthheight;
      set(s1,'Position',[p(1) p(2) s2(1) s2(2)])
      pcaprefg.moduser = pcaprefg.moddefault;
      spath = savit(adata.sgui);
      eval(spath)
    end
  end
end

function spath = savit(sgui)
switch sgui
case 'pca'
  p     = which('pcagui');
  p   = p(1:length(p)-8);
case 'mod'
  p   = which('modlgui');
  p   = p(1:length(p)-9);
end
p     = ['''',p,'pcaprefg'''];
spath =  ['save ',p,' pcaprefg'];

