function pcagui(action,fighand)
%PCAGUI Principal Components Analysis with graphical user interface.
%  PCAGUI performs principal components analysis using a
%  graphical user interface. Data, variable and sample scales,
%  and variable and sample lables can be loaded from the workspace
%  into the tool by using the PCA_File menu. Scaling options can
%  be set using the PCA_Scale menu. Models can be calculated by
%  by pressing the calc button. Eigenvalues, scores, loadings, biplots
%  and raw data can be viewed by clicking on the appropriate buttons.
%  Models can be saved to the work space using the PCA_File menu,
%  Models can be reloaded and used with new data. Models are saved
%  as structured arrays with the following fields:
%
%     xname: name of the original workspace input variable
%      name: type of model, always 'PCA'
%      date: model creation date stamp
%      time: model creation time stamp
%    scores: PCA scores
%     loads: PCA loadings
%       ssq: sum of squares captured information
%     means: means of the original data
%      stds: variances of the original data
%     scale: scaling used, i.e. none, mncn or auto
%       res: Q residuals
%    reslim: 95% Q limit
%       tsq: T^2 values
%    tsqlim: 95% T^2 limit
%      irow: samples included in model
%      icol: variables included in model
%      drow: samples deleted from model
%      dcol: variables deleted from model
%      sscl: scale for plotting scores against
%      vscl: scale for plotting loadings against
%      slbl: sample labels
%     slbln: sample labels original workspace name
%      vlbl: variable labels
%     vlbln: variable labels original workspace name
%     samps: number of samples in original data
%
%I/O: pcagui
%
%See also: MODLGUI, MODLRDER, PCA, PCAPRO, XPLDST

%Copyright Eigenvector Research, Inc. 1996-98
%nbg 4,6,7,12/97,7/98,10/98,12/98
%nbg 11/00 changed table header and gui size

if nargin<1
  bgc0   = [0 0 0];
  bgc1   = [1 0 1]*0.6;
  bgc2   = [1 1 1]*0.85;
  bgc3   = [1 1 1];
  load pcaprefg
  p      = get(0,'ScreenSize'); 
  ww     = pcaprefg.pcauser.widthheight(1); %380;
  wh     = pcaprefg.pcauser.widthheight(2); %323;
  a = figure('Color',bgc0,'Resize','on', ...
    'Name','Principal Components Analysis', ...
    'HandleVisibility','off', ...
    'NumberTitle','Off','Position',[6 p(4)-wh-40 ww wh]);
  as     = int2str(a);
  
% Menus
  b      = zeros(4,1);
  bb     = zeros(17,1);
% I/O Menu
  b(1,1) = uimenu(a,'Label','&PCA_File');
  bb(1,1)= uimenu(b(1,1),'Label','&Load Data', ...
    'CallBack',['pcagui(''loaddata'',',as,');']);
  bb(2,1)= uimenu(b(1,1),'Label','&Load Model', ...
    'CallBack',['pcagui(''loadmodl'',',as,');']);
  b(3,1) = uimenu(b(1,1),'Label','&Load Scale','Enable','off');
  bb(3,1)= uimenu(b(3,1),'Label','&Sample','Enable','off', ...
    'CallBack',['pcagui(''loadsscl'',',as,');']);
  bb(4,1)= uimenu(b(3,1),'Label','&Variable','Enable','off', ...
    'CallBack',['pcagui(''loadvscl'',',as,');']);
  b(2,1) = uimenu(b(1,1),'Label','&Load Labels','Enable','off');
  bb(5,1)= uimenu(b(2,1),'Label','&Sample','Enable','off', ...
    'CallBack',['pcagui(''loadslbl'',',as,');']);
  bb(6,1)= uimenu(b(2,1),'Label','&Variable','Enable','off', ...
    'CallBack',['pcagui(''loadvlbl'',',as,');']);
  bb(7,1)= uimenu(b(1,1),'Label','&Save Data','Enable','off',  ...
    'CallBack',['pcagui(''savemat'',',as,');'],'Separator','on');
  bb(15,1)= uimenu(b(1,1),'Label','&Save Test','Enable','off',  ...
    'CallBack',['pcagui(''savetst'',',as,');']);
  bb(8,1)= uimenu(b(1,1),'Label','&Save Model','Enable','off',  ...
    'CallBack',['pcagui(''savemodl'',',as,');']);
  bb(17,1)= uimenu(b(1,1),'Label','&Print Info','Enable','off',  ...
    'CallBack',['pcagui(''printssqtable'',',as,');']);
  bb(16,1)= uimenu(b(1,1),'Label','&Preferences','Enable','on',  ...
    'CallBack',['prefpls(',as,');']);
  bb(9,1)= uimenu(b(1,1),'Label','&Clear Data','Enable','off',  ...
    'CallBack',['pcagui(''cleardata'',',as,');'],'Separator','on');
  bb(10,1)= uimenu(b(1,1),'Label','&Clear Model','Enable','off',  ...
    'CallBack',['pcagui(''clearmodl'',',as,');']);
  bb(11,1)= uimenu(b(1,1),'Label','&Exit PCA', ...
    'CallBack',['pcagui(''exitpca'',',as,');'],'Separator','on');    
% Scaling Menu
  b(4,1) = uimenu(a,'Label','&PCA_Scale');
  bb(12,1)= uimenu(b(4,1),'Label','&no scaling','Enable','off', ...
    'CallBack',['pcagui(''actnoscale'',',as,');']);
  bb(13,1)= uimenu(b(4,1),'Label','&mean center','Enable','off', ...
    'CallBack',['pcagui(''actmncn'',',as,');']);
  bb(14,1)= uimenu(b(4,1),'Label','&autoscaling','Enable','off', ...
    'CallBack',['pcagui(''actauto'',',as,');'],'Checked','on');
% Internal StatusBar
  d      = zeros(4,1);
  e      = zeros(6,1);
  d(1,1) = uicontrol('Parent',a,'Style','frame', ...
    'Units','normalized','Position', ...
    [0.0263158 0.736842 0.947368 0.250774]);
% Variance Captured List/text
  d(2,1) = uicontrol('Parent',a,'Style','frame', ...
    'Units','normalized','Position', ...
    [0.0263158 0.0309598 0.778947 0.696594]);
  s = str2mat(...
    '         Percent Variance Captured by PCA Model', ...
    ' ', ...
    '  Principal      Eigenvalue        % Variance    % Variance', ...
    'Component     of Cov(X)          This  PC       Cumulative ');
  e(1,1) = uicontrol('Parent',a, ...
    'Units','normalized','Position', ...
    [0.0342105 0.482972 0.763158 0.170279], ...
    'HorizontalAlignment','left', ...
    'String',s,'Style','text', ...
    'FontName',pcaprefg.pcauser.tableheader.FontName, ...
    'FontUnits',pcaprefg.pcauser.tableheader.FontUnits, ...
    'FontSize',pcaprefg.pcauser.tableheader.FontSize, ...
    'FontWeight',pcaprefg.pcauser.tableheader.FontWeight, ...
    'FontAngle',pcaprefg.pcauser.tableheader.FontAngle, ...
    'UserData','%3.0f       %4.2e   %6.2f    %6.2f');
  e(2,1) = uicontrol('Parent',a, ...
    'Units','normalized','Position', ...
    [0.0342105 0.662539 0.460526 0.0557276], ...
    'String','Number of PCs Selected:', ...
    'HorizontalAlignment','left','FontWeight','bold', ...
    'Style','text','FontName','geneva','Fontsize',10);
  e(3,1) = uicontrol('Parent',a, ...
    'Units','normalized','Position', ...
    [0.502632 0.659443 0.131579 0.0619195],'Fontsize',10, ...
    'String',' ','Style','edit','FontWeight','bold', ...
    'Callback',['pcagui(''actssq2'',',as,');']);
  e(4,1) = uicontrol('Parent',a,'BackgroundColor',bgc3, ...
    'Units','normalized','Position', ...
    [0.0342105 0.0402477 0.763158 0.433437],'Style','listbox', ...
    'FontName',pcaprefg.pcauser.tablebody.FontName, ...
    'FontUnits',pcaprefg.pcauser.tablebody.FontUnits, ...
    'FontSize',pcaprefg.pcauser.tablebody.FontSize, ...
    'FontWeight',pcaprefg.pcauser.tablebody.FontWeight, ...
    'FontAngle',pcaprefg.pcauser.tablebody.FontAngle, ...
    'Value',1,'String',[], ...
    'Callback',['pcagui(''actssq'',',as,');']);
  %Text for internal status bar
  s = str2mat('Data: none loaded');
  e(5,1) =  uicontrol('Parent',a,'BackgroundColor',bgc3, ...
    'Units','normalized','Position', ...
    [0.0342105 0.74613 0.461842 0.232198], ...
    'HorizontalAlignment','left', ...
    'Style','text','String',s, ...
    'FontName',pcaprefg.pcauser.statwindow.FontName, ...
    'FontUnits',pcaprefg.pcauser.statwindow.FontUnits, ...
    'FontSize',pcaprefg.pcauser.statwindow.FontSize, ...
    'FontWeight',pcaprefg.pcauser.statwindow.FontWeight, ...
    'FontAngle',pcaprefg.pcauser.statwindow.FontAngle);
  s = ['Model: none loaded'];
  e(6,1) =  uicontrol('Parent',a,'BackgroundColor',bgc3, ...
    'Units','normalized','Position', ...
    [0.503947 0.74613 0.461842 0.232198], ...
    'HorizontalAlignment','left', ...
    'Style','text','String',s, ...
    'FontName',pcaprefg.pcauser.statwindow.FontName, ...
    'FontUnits',pcaprefg.pcauser.statwindow.FontUnits, ...
    'FontSize',pcaprefg.pcauser.statwindow.FontSize, ...
    'FontWeight',pcaprefg.pcauser.statwindow.FontWeight, ...
    'FontAngle',pcaprefg.pcauser.statwindow.FontAngle);
  if strcmp(lower(computer),'mac2')
    s = str2mat(...
      '         Percent Variance Captured by PCA Model', ...
      ' ', ...
      'Principal      Eigenvalue       % Variance     % Variance', ...
      'Component     of Cov(X)          This  PC        Cumulative ');
    set(e(1,1),'String',s, ...
      'UserData',' %3.0f       %4.2e     %6.2f      %6.2f')
  end
% Buttons
  d(3,1) = uicontrol('Parent',a,'Style','frame', ...
    'Units','normalized','Position', ...
  [0.810526 0.544892 0.160526 0.182663]);
  d(4,1) = uicontrol('Parent',a,'Style','frame', ...
    'Units','normalized','Position', ...
  [0.810526 0.0309598 0.160526 0.50774]);
  c = uicontrol('Parent',a, ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc3, ...
    'Style','text', ...
    'Units','normalized','Position', ...
    [0.818421 0.464396 0.144737 0.0619195],'String','plots', ...
    'FontName',pcaprefg.pcauser.buttons.FontName, ...
    'FontUnits',pcaprefg.pcauser.buttons.FontUnits, ...
    'FontSize',pcaprefg.pcauser.buttons.FontSize, ...
    'FontWeight',pcaprefg.pcauser.buttons.FontWeight, ...
    'FontAngle',pcaprefg.pcauser.buttons.FontAngle);
  f      = zeros(7,1);
  f(1,1) = uicontrol('Parent',a, ...
    'CallBack',['pcagui(''calculate'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.640867 0.144737 0.0773994],'String','calc', ...
    'TooltipString','calculate PCA model');
  f(2,1) = uicontrol('Parent',a, ...
    'CallBack',['pcagui(''apply'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.55418 0.144737 0.0773994],'String','apply', ...
    'TooltipString','apply PCA model');
  f(3,1) = uicontrol('Parent',a, ...
    'CallBack',['pcaplot1(''plotscree'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.386997 0.144737 0.0773994],'String','eigen', ...
    'TooltipString','plot eigenvalues');
  f(4,1) = uicontrol('Parent',a, ...
    'CallBack',['pcaplots(''plotscores'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.30031 0.144737 0.0773994],'String','scores', ...
    'TooltipString','plot scores and sample statistics');
  f(5,1) = uicontrol('Parent',a, ...
    'CallBack',['pcaplots(''plotloads'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.213622 0.144737 0.0773994],'String','loads', ...
    'TooltipString','plot loads and variable statistics');
  f(6,1) = uicontrol('Parent',a, ...
    'CallBack',['pcaplot1(''biplot'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.126935 0.144737 0.0773994],'String','biplot', ...
    'TooltipString','plot scores and loadings biplots');
  f(7,1) = uicontrol('Parent',a, ...
    'CallBack',['pcaplot1(''rawplot'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.0402477 0.144737 0.0773994],'String','data', ...
    'TooltipString','plot raw data');

  %Set common properties
  set(d(1:length(d),1),'BackgroundColor',bgc1)
  set(e(1:length(e),1),'BackgroundColor',bgc3)
  set(f(1:length(f),1),'BackgroundColor',bgc2,'Enable','off', ...
    'FontName',pcaprefg.pcauser.buttons.FontName, ...
    'FontUnits',pcaprefg.pcauser.buttons.FontUnits, ...
    'FontSize',pcaprefg.pcauser.buttons.FontSize, ...
    'FontWeight',pcaprefg.pcauser.buttons.FontWeight, ...
    'FontAngle',pcaprefg.pcauser.buttons.FontAngle);

  set(a,'CloseRequestfcn',['pcagui(''exitpca'',',as,');'])
  %Assign Handles
  set(a,'UserData',d)         %Frame Handles
  set(d(1,1),'UserData',b)    %UIMenu Handles
  set(d(2,1),'UserData',e)    %Text Handles
  set(d(3,1),'UserData',f)    %Button Handles
  set(b(3,1),'UserData',bb)
  stat.data  = 'none';
  stat.modl  = 'none';
  modl       = [];
  test       = [];
  set(b(1,1),'UserData',stat)
  set(f(2,1),'UserData',modl)
  set(f(5,1),'UserData',test)
  pcagui('cleardata',a);
  pcagui('clearmodl',a);
else
  %Get handles
  d    = get(fighand,'UserData'); %Frame Handles
  a    = get(d(1,1),'Parent');
  as   = int2str(a);
  b    = get(d(1,1),'UserData');  %UIMenu Handles
  e    = get(d(2,1),'UserData');  %Text Handles
  f    = get(d(3,1),'UserData');  %Button Handles
  x    = get(f(1,1),'UserData');  %Data Matrix
  bb   = get(b(3,1),'UserData');  %UIsubmenu handles
  stat = get(b(1,1),'UserData');  %Data/Model Status
  modl = get(f(2,1),'UserData');  %Model
  test = get(f(5,1),'UserData');  %Test Data
  
  switch lower(action)
  case 'loaddata'
    lddlgpls(f(1,1),d(4,1),'double')
    x             = get(f(1,1),'UserData');
    if isempty(x)
      pcagui('cleardata',a);
    elseif class(x)~='double'
      erdlgpls('variable not double array','Error on Load Data!')
      pcagui('cleardata',a);
    elseif size(x,1)==1|size(x,2)==1
      erdlgpls('variable must be a matrix','Error on Load Data!')
      pcagui('cleardata',a);
    else
      stat.data   = 'new';
      if strcmp(stat.modl,'none')
        modl      = get(f(2,1),'UserData');
        modl.irow = 1:size(x,1);
        modl.icol = 1:size(x,2);
      else
        stat.modl = 'loaded';
      end
      set(f(2,1),'UserData',modl)
    end
  case 'loadslbl'
    if strcmp(stat.data,'test')
      s1          = test.slbl;
      s2          = test.slbln;
    else
      s1          = modl.slbl;
      s2          = modl.slbln;
    end 
    lddlgpls(b(2,1),e(4,1),'char')
    s             = get(b(2,1),'UserData');
    s0            = get(e(4,1),'UserData');
    if (~isempty(s0))&(~strcmp(s2,s0))
      if size(s,1)==size(x,1)
        if strcmp(stat.data,'test')|strcmp(stat.modl,'loaded')
          test.slbl  = s;
          test.slbln = s0;
        elseif strcmp(stat.data,'new')|strcmp(stat.data,'cal')
          modl.slbl  = s;
          modl.slbln = s0;
        end
      elseif ~isempty(s)
        if strcmp(stat.data,'test')|strcmp(stat.modl,'loaded')
          test.slbl  = [];
          test.slbln = [];
        elseif strcmp(stat.data,'new')|strcmp(stat.data,'cal')
          modl.slbl  = [];
          modl.slbln = [];
        end
        s = 'number of rows must equal number of ';
        s = [s,'rows of loaded data - no labels loaded'];
        erdlgpls(s,'Error on Load!')
      end
    end
  case 'loadvlbl'
    if strcmp(stat.data,'test')
      s1          = test.vlbl;
      s2          = test.vlbln;
    else
      s1          = modl.vlbl;
      s2          = modl.vlbln;
    end
    lddlgpls(b(2,1),e(4,1),'char')
    s             = get(b(2,1),'UserData');
    s0            = get(e(4,1),'UserData');
    if (~isempty(s0))&(~strcmp(s2,s0))
      if size(s,1)==size(x,2)
        if strcmp(stat.data,'test')|strcmp(stat.modl,'loaded')
          test.vlbl  = s;
          test.vlbln = s0;
        elseif strcmp(stat.data,'new')|strcmp(stat.data,'cal')
          modl.vlbl  = s;
          modl.vlbln = s0;
        end
      elseif ~isempty(s)
        if strcmp(stat.data,'test')|strcmp(stat.modl,'loaded')
          test.vlbl  = [];
          test.vlbln = [];
        elseif strcmp(stat.data,'new')|strcmp(stat.data,'cal')
          modl.vlbl  = [];
          modl.vlbln = [];
        end
        s = 'number of rows must equal number of ';
        s = [s,'columns of loaded data - no labels loaded'];
        erdlgpls(s,'Error on Load!')
      end
    end
  case 'loadsscl'
    if strcmp(stat.data,'test')
      s1         = test.sscl;
    else
      s1         = modl.sscl;
    end 
    lddlgpls(b(2,1),e(4,1),'double')
    s            = get(b(2,1),'UserData');
    [ms,ns]      = size(s);
    if ms>ns
      s          = s';
      [ms,ns]    = size(s);
    end
    if ms>1
      s = 'scale variable must be a vector';
      s = [s,' - no scale loaded'];
      erdlgpls(s,'Error on Load!')
    else
      if length(s1)==length(s)
        s2       = sum(s'-s1');
      else
        s2       = 1;
      end
      if s2
        if length(s)==size(x,1)
          if strcmp(stat.data,'test')|strcmp(stat.modl,'loaded')
            test.sscl  = s;
          elseif strcmp(stat.data,'new')|strcmp(stat.data,'cal')
            modl.sscl  = s;
          end
        elseif ~isempty(s)
          if strcmp(stat.data,'test')|strcmp(stat.modl,'loaded')
            test.sscl  = [];
          elseif strcmp(stat.data,'new')|strcmp(stat.data,'cal')
            modl.sscl  = [];
          end
          s = 'number of elements must equal number of ';
          s = [s,'rows of loaded data - no labels loaded'];
          erdlgpls(s,'Error on Load!')
        end
      end
    end
  case 'loadvscl'
    s1           = modl.vscl;
    lddlgpls(b(2,1),e(4,1),'double')
    s            = get(b(2,1),'UserData');
    [ms,ns]      = size(s);
    if ms>ns
      s          = s';
      [ms,ns]    = size(s);
    end
    if ms>1
      s = 'scale variable must be a vector';
      s = [s,' - no scale loaded'];
      erdlgpls(s,'Error on Load!')
    else
      if length(s1)==length(s)
        s2       = sum(s'-s1');
      else
        s2       = 1;
      end
      if s2
        if length(s)==size(x,2)
          modl.vscl  = s;
        elseif ~isempty(s)
          modl.vscl  = [];
          s = 'number of elements must equal to number of ';
          s = [s,'columns of loaded data - no labels loaded'];
          erdlgpls(s,'Error on Load!')
        end
      end
    end
  case 'loadmodl'
    lddlgpls(f(2,1),d(4,1),'struct')
    modl   = get(f(2,1),'UserData');
    if ~isempty(modl)
      s    = char(fieldnames(modl));
      s1   = 'no';
      for jj=1:size(s,1)
        if strncmp(s(jj,:),'name',4)
          s1 = 'yes';
        end
      end
      if strcmp(s1,'no')|size(modl,1)>1|size(modl,2)>1
        erdlgpls('variable not a PCA model','Error on Load Model!')
        pcagui('clearmodl',a)
      elseif strcmp(s1,'yes')
        if strcmp(modl.name,'PCA')
          stat.modl = 'loaded';
          if ~strcmp(stat.data,'none')
            stat.data = 'new';
          end
          x      = size(modl.loads,2);
          format = get(e(1,1),'UserData');
          s      = [];
          for jj=1:size(modl.ssq,1)
            s    = [s;sprintf(format,modl.ssq(jj,:))];
          end
          set(e(4,1),'String',s,'Value',x)
          set(e(3,1),'String',int2str(x))
          set(f(4,1),'UserData',x)  
          set(f(3,1),'UserData',[])
        elseif isempty(modl.name)
        else
          erdlgpls('variable not a PCA model','Error on Load Model!')
          pcagui('clearmodl',a)
        end
      else
        erdlgpls('variable not a PCA model','Error on Load Model!')
        pcagui('clearmodl',a)
      end
    end
  case 'savemat'
    x    = x(modl.irow,modl.icol);
    if isempty(x)
      erdlgpls('no data loaded to be saved','Error on Save!')
    else
      svdlgpls(x,'X-block');
    end
  case 'savetst'
    if isempty(test)|isempty(test.xname)
      erdlgpls('no test data to be saved','Error on Save!')
    else
      svdlgpls(test,'PCA test');
    end     
  case 'savemodl'
    if isempty(modl)|isempty(modl.name)
      erdlgpls('no model to be saved','Error on Save!')
    else
      svdlgpls(modl,'PCA model');
    end
  case 'cleardata'
    stat.data   = 'none';      %'new', 'cal', 'test'
    set(d(4,1),'UserData',[])  %clear x-block name
    modl.xname  = [];
    set(f(1,1),'UserData',[])  %clear x-block data
    set(f(7,1),'UserData',[])  %clear y-block data
    test.scores = [];          %Scores for test data
    test.res    = [];          %Sample Q residuals for test data
    test.tsq    = [];          %Sample Hotelling T^2 for tst data
    test.sscl   = [];          %Sample scale
    test.slbl   = [];          %Sample labels for test data
    test.slbln  = [];          %Sample label name for test data
    test.xname  = [];          %Name of loaded X-block variable
    delfigs(as)
    h = findobj('Name','Plot Data','Tag',as);   close(h)    
    if ~strcmp(stat.modl,'none')
      stat.modl = 'loaded';
    end
    set(bb(15,1),'Enable','off')
  case 'clearmodl'
    stat.modl   = 'none';      %'calold', 'calnew', 'loaded'
    modl.name   = [];          %PLS, SIM, PCR
    modl.date   = [];          %Date model was created
    modl.time   = [];          %Time model was created
    modl.scores = [];          %X-block scores for cal data
    modl.loads  = [];          %X-block loadings
    modl.ssq    = [];          %Variance information
    modl.means  = [];          %Centering vector
    modl.stds   = [];          %Scaling vector
    modl.scale  = 'auto';      %Scale Status
    modl.res    = [];          %Sample Q residuals    
    modl.reslim = [];          %95% conf limit for Q
    modl.tsq    = [];          %Sample Hotelling T^2
    modl.tsqlim = [];          %95% conf limit for T^2
    modl.irow   = [];          %Indices of samples used
    modl.icol   = [];          %Indices of variables used
    modl.drow   = [];          %Indices of samples deleted
    modl.dcol   = [];          %Indices of variables deleted
    modl.sscl   = [];          %Sample scale
    modl.vscl   = [];          %Variable scale
    modl.slbl   = [];          %Sample labels
    modl.slbln  = [];          %Sample label name
    modl.vlbl   = [];          %Variable labels
    modl.vlbln  = [];          %Variable label name
    modl.xname  = [];          %Name of loaded X-block variable
    if ~strcmp(stat.data,'none')
      stat.data = 'new';
      [m,n]     = size(get(f(1,1),'UserData'));
      modl.irow = [1:m];
      modl.icol = [1:n];
    end
    delfigs(as)
    pcagui('actauto',a);
  case 'exitpca'
    %check to see if data edited, if so ask if save
    %check to see if model changed, if so ask if save
    delfigs(as)
    h = findobj('Name','Plot Data','Tag',as);   close(h)
    closereq
  %Scaling Options
  case 'actnoscale'
    set(bb(13:14,1),'Checked','off')
    set(bb(12,1),'Checked','on')
    modl.scale = 'no';
    stat.modl  = 'none';
    if ~strcmp(stat.data,'none')
      stat.data= 'new';
    end
  case 'actmncn'
    set(bb([12 14],1),'Checked','off')
    set(bb(13,1),'Checked','on')
    modl.scale = 'mean';
    stat.modl  = 'none';
    if ~strcmp(stat.data,'none')
      stat.data= 'new';
    end
  case 'actauto'
    set(bb(12:13,1),'Checked','off')
    set(bb(14,1),'Checked','on')
    modl.scale = 'auto';
    stat.modl  = 'none';
    if ~strcmp(stat.data,'none')
      stat.data= 'new';
    end
  %Button Callbacks
  case 'calculate'
    delfigs(as)
    x          = get(f(1,1),'UserData');
    if ~isempty(x)
      if ~isempty(modl)
        if ~isempty(modl.drow)
          jk   = [];
          for jj=1:length(modl.drow)
            jk = [jk,find(modl.irow==modl.drow(jj))];
          end
          modl.irow = delsamps(modl.irow',jk)';
        end
        x      = x(modl.irow,modl.icol);
        set(bb(8,1),'Enable','on');
        [m,n]  = size(x);
        %Scaling
        switch modl.scale
        case 'mean'                               %mean center
          [x,modl.means] = mncn(x);
          modl.stds      = std(x);
        case 'auto'                               %autoscale
          [x,modl.means,modl.stds] = auto(x);
        otherwise                                 %no scaling
          modl.means     = mean(x);
          modl.stds      = std(x);
        end
        %SVD
        if n<m
          cx  = (x'*x)/(m-1);
          [u,s,v] = svd(cx);
          pcs = (1:n)';
        else
          cx  = (x*x')/(m-1);
          [u,s,v] = svd(cx);
          v   = x'*v;
          for i=1:m
            v(:,i) = v(:,i)/norm(v(:,i));
          end
          pcs = (1:m)';
        end
        s     = diag(s);
        cap   = s*100/(sum(s));
        pc    = 1;                   %default model
        modl.name   = 'PCA';
        modl.date   = date;          %date model was created
        modl.time   = clock;         %time model was created
        modl.scores = x*v(:,1:pc);   %PCA scores
        modl.samps  = m;             %Number of samples in (data)
        modl.loads  = v(:,1:pc);     %PCA loadings
        modl.ssq    = [pcs s cap cumsum(cap)]; %Variance information
        modl.xname  = get(d(4,1),'UserData');
    
        res   = (x - modl.scores*modl.loads')';
        res   = sum(res.^2)';
        %Q Residuals and Limit
        modl.res    = res;           %Sample residuals Q    
        modl.reslim = reslim(pc,s,95); %95% conf limit for Q
        %T^2 and Limit
        cap   = 1./sqrt(s(1:pc,1));
        cap   = modl.scores*diag(cap);
        if pc>1
          tsqs  = sum((cap.^2)')';
        else
          tsqs  = (cap.^2);
        end
        modl.tsq    = tsqs;            %Sample Hotelling T^2
        modl.tsqlim = tsqlim(m,pc,95); %95% confidence limit for T^2

        format= get(e(1,1),'UserData');
        s     = [];
        for jj=1:min([size(modl.ssq,1); 25]) %max PCs listed = 25
          s   = [s;sprintf(format,modl.ssq(jj,:))];
        end
        set(f(3,1),'UserData',v)
        set(f(4,1),'UserData',pc);
        set(e(3,1),'String',int2str(pc))
        set(e(4,1),'String',s,'Value',pc)
        stat.data = 'cal';
        stat.modl = 'calold';
      else
        stat.modl = 'none';
      end
    else
      stat.data   = 'none';
    end
    set(bb(15,1),'Enable','off')
  case 'apply'
    delfigs(as)
    if strcmp(stat.modl,'calnew')
      if ~isempty(modl.drow)
        jk   = [];
        for jj=1:length(modl.drow)
          jk = [jk,find(modl.irow==modl.drow(jj))];
        end
        modl.irow = delsamps(modl.irow',jk)';
      end
      x     = x(modl.irow,modl.icol);
    end
    n       = size(x,2);
    m       = size(modl.loads,1);
    if size(x,2)~=m
      erdlgpls('Error- num vars in x ~= num rows of loads', ...
        'Error on Apply');
    else
      switch modl.scale
      case 'mean'
        x  = scale(x,modl.means);
      case 'auto'
        x  = scale(x,modl.means,modl.stds);
      end
      m    = get(f(4,1),'UserData');
      if ~strcmp(stat.modl,'loaded')
        v    = get(f(3,1),'UserData');
        if ~isempty(v)
          modl.loads = v(:,1:m);
        end
        clear v
        modl.reslim = reslim(m,modl.ssq(:,2),95);
        modl.tsqlim = tsqlim(length(modl.irow),m,95);
        modl.scores = x*modl.loads;
        modl.res    = (x - modl.scores*modl.loads')';
        modl.res    = sum((modl.res).^2)';
        modl.tsq    = 1./sqrt(modl.ssq(1:m,2));
        modl.tsq    = modl.scores*diag(modl.tsq);
        if m>1
          modl.tsq  = sum(((modl.tsq).^2)')';
        else
          modl.tsq  = (modl.tsq).^2;
        end
        set(bb(15,1),'Enable','off')
      else
        test.scores = x*modl.loads;
        test.res    = (x - (test.scores)*(modl.loads)')';
        test.res    = sum((test.res).^2)';
        test.tsq    = 1./sqrt(modl.ssq(1:m,2));
        test.tsq    = test.scores*diag(test.tsq);
        test.xname  = get(d(4,1),'UserData');
        if m>1
          test.tsq  = sum(((test.tsq).^2)')';
        else
          test.tsq  = (test.tsq).^2;
        end
        set(bb(15,1),'Enable','on')
      end
      if strcmp(stat.data,'new')
        stat.data = 'test';
        stat.modl = 'loaded';
      end
      if strcmp(stat.data,'cal')
        stat.modl = 'calold';
      end
    end  
  case 'actssq'
    if strcmp(stat.modl,'loaded')
      n      = get(f(4,1),'UserData');
      set(e(3,1),'String',int2str(n))
      set(e(4,1),'Value',n)    
    elseif ~strcmp(stat.data,'none')
      n      = get(e(4,1),'Value');
      set(e(3,1),'String',int2str(n))
      set(f(4,1),'UserData',n);
      stat.modl = 'calnew';
    end
  case 'actssq2'
    if strcmp(stat.modl,'loaded')
      n      = get(f(4,1),'UserData');
      set(e(3,1),'String',int2str(n))
      set(e(4,1),'Value',n)    
    elseif ~strcmp(stat.data,'none')&~strcmp(stat.modl,'none')
      n      = str2num(get(e(3,1),'String'));
      n      = round(n);
      if (n<1)|(n>max(modl.ssq(:,1)))
        n    = 1;
      end
      set(e(4,1),'Value',n);
      set(e(3,1),'String',int2str(n))
      set(f(4,1),'UserData',n);
      stat.modl = 'calnew';
    end
  case 'printssqtable'
    ssqtable(modl,size(modl.loads,2));
  end

%button status
  if ~strcmp(lower(action),'exitpca')
    set(b(1,1),'UserData',stat)
    set(f(2,1),'UserData',modl)
    set(f(5,1),'UserData',test)
    if strcmp(stat.data,'none')&strcmp(stat.modl,'none')
      %no data, no model
      set(f(1:7,1),'Enable','off')
    elseif ~strcmp(stat.modl,'none')&strcmp(stat.data,'none')
      %no data, a model
      set(f([1:2 4:7],1),'Enable','off')
      set(f(3,1),'Enable','on')
    elseif ~strcmp(stat.data,'none')&strcmp(stat.modl,'none')
      %new data, no model
      set(f([1 7],1),'Enable','on')
      set(f(2:6,1),'Enable','off')
    elseif ~strcmp(stat.data,'none')&(~strcmp(stat.modl,'none'))
      %data and model
      if strcmp(stat.modl,'calold')
        set(f(1:2,1),'Enable','off')
        set(f(3:7,1),'Enable','on')
      elseif strcmp(stat.modl,'calnew')
        set(f([1 4:6],1),'Enable','off')
        set(f([2:3 7],1),'Enable','on')
      elseif strcmp(stat.modl,'loaded')
        if strcmp(stat.data,'test')
          set(f(1:2,1),'Enable','off')
          set(f(3:7,1),'Enable','on')
        else
          set(f([1 3:6],1),'Enable','off')
          set(f([2 7],1),'Enable','on')
        end
      end
    end
    if get(f(4,1),'UserData')<2
      set(f(6,1),'Enable','off') %biplot button
      h = findobj('Name','Biplot','Tag',as); close(h)
    end

    %scaling menu
    if strcmp(stat.modl,'loaded')|strcmp(stat.data,'none')
      set(bb(12:14,1),'Enable','off')
    else
      set(bb(12:14,1),'Enable','on')
    end
    
    %status strings and file menu
    if strcmp(stat.modl,'none')
      set(f(3:4,1),'UserData',[])
      set(e(3,1),'String',' ')
      set(e(4,1),'String',' ','Value',1)
      if strcmp(stat.data,'none')
        s  = ['Model: none loaded'];
      else
        s  = ['Model: not calculated'];
      end
      set(e(6,1),'String',s)
      set(bb([8:10 17],1),'Enable','off');
    else
      set(bb([8:10 17],1),'Enable','on');
      switch stat.modl  
      case 'loaded'
        if strcmp(stat.data,'none')
          s  = ['Model: loaded'];
        elseif strcmp(stat.data,'new')
          s  = ['Model: loaded but not applied'];
        elseif strcmp(stat.data,'test')
          s  = ['Model: loaded and applied'];
        end
      case 'calnew'
        s  = ['Model: not applied'];
      case 'calold'
        s  = ['Model: calibrated on loaded data'];
      end
      modl = get(f(2,1),'UserData');
      pc   = size(modl.loads,2);
      if strcmp(modl.scale,'auto')
        sc = 'autoscaled';
      elseif strcmp(modl.scale,'mean')
        sc = 'mean centered';
      else
        sc = 'not scaled';
      end
      s1   = ['PC(s): ',int2str(pc)];
      s2   = ['Scaling: ',sc];
      s3   = ['Data: ',int2str(length(modl.irow)),' sams x '];
      s3   = [s3,[int2str(length(modl.icol)),' vars']];
      set(e(6,1),'String',str2mat(s,s1,s3,s2))
    end
    if strcmp(stat.data,'none')
      set(f(1,1),'UserData',[])
      set(e(5,1),'String','Data: none loaded')
      set(bb([3:7 9],1),'Enable','off');
    else
      set(b(2:3,1),'Enable','on')
      set(bb([3:6 9],1),'Enable','on')
      if modl.drow|modl.dcol
        set(bb(7,1),'Enable','on');
      end
      if ~strcmp(stat.modl,'loaded')
        set(bb([4 6],1),'Enable','on');
      else
        set(bb([4 6],1),'Enable','off');
      end
      if strcmp(stat.data,'new')
        s   = ['Data: loaded but not analyzed'];
        s4  = ['Samp Lbls: ',modl.slbln];
      elseif strcmp(stat.data,'cal')
        s   = ['Data: modeled (calibration set)'];
        s4  = ['Samp Lbls: ',modl.slbln];
      elseif strcmp(stat.data,'test')
        s   = ['Data: modeled (test set)'];
        s4  = ['Samp Lbls: ',test.slbln];
      end
      [m,n] = size(get(f(1,1),'UserData'));
      s3    = ['Var: ',get(d(4,1),'UserData')];
      s2    = ['Size: ',int2str(m),' rows x ',int2str(n),' cols'];
      s5    = ['Var Lbls: ',modl.vlbln];
      set(e(5,1),'String',str2mat(s3,s,s2,s4,s5))
    end
  end
end

function [] = delfigs(as)
h = findobj('Name','Eigenvalues','Tag',as); close(h)
h = findobj('Name','Plot Scores','Tag',as); close(h)
h = findobj('Name','Plot Loads','Tag',as);  close(h)
h = findobj('Name','Biplot','Tag',as);      close(h)
