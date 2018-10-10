function modlgui(action,fighand)
%MODLGUI linear regression with graphical user interface.
%  MODLGUI constructs linear regression models using a graphical
%  user interface. Data, variable and sample scales, and variable
%  and sample lables can be loaded from the workspace into the
%  tool by using the MODL_File menu. Choice of regression method
%  (PCR or PLS), scaling, and cross validation options can selected
%  using the REGRESSION PARAMETERS window. Models can be calculated by
%  by pressing the calc button. PRESS, scores, loadings, biplots
%  and raw data can be viewed by clicking on the appropriate buttons.
%  Models can be saved to the work space using the MODL_File menu,
%  Models can be reloaded and used with new data. Models are saved
%  as structured arrays with the following fields:
%
%     xname: name of the original workspace input predictor block
%     yname: name of the original workspace input predicted block
%      date: model creation date stamp
%      time: model creation time stamp
%       reg: regresion vector(s)
%     ypred: fits for the calibration Y-block
%       wts: for NIP it is the X-block weights
%    scores: X-block scores
%     loads: X-block loadings
%       ssq: sum of squares captured information
%     rmsec: root mean squared error of calibration (fit error)
%    rmsecv: root mean squared error of cross validation (cv error)
%     meanx: means of the X-block
%     meany: mean(s) of the Y-block
%      stdx: standard deviations of the X-block
%      stdy: standard deviation(s) of the Y-block
%     press: cumulative prediction error sum of squares
%       res: Q residuals
%    reslim: 95% Q limit
%    reseig: Eigenvalues of X-residuals
%      yres: studentized residuals for the Y-block (fit error)
%       tsq: T^2 values
%    tsqlim: 95% T^2 limit
%       lev: sample leverages
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
%     scale: scaling used (e.g. 'auto')
%      name: type of model, 'NIP, 'PCR', 'SIM'
%        cv: cross validation method used
%     split: number of times the data was split for cross validation
%      iter: number of iterations for random cross validation
%     samps: number of samples in original data
%
%I/O: modlgui
%
%See also: CROSSVAL, MODLRDER, MODLPRED, PCAGUI, PCR, PLS, SIMPLS, XPLDST

%Copyright Eigenvector Research, Inc. 1997-99
%nbg 6/97,7/97,12/97,1/98,5/98,9/98,10/98,12/98
%bmw 1/00
%nbg 10/00 changed table header and guisize, added ";" on line 920

if nargin<1
  bgc0   = [0 0 0];
  bgc1   = [1 0 1]*0.6;
  bgc2   = [1 1 1]*0.85;
  bgc3   = [1 1 1];
  load pcaprefg
  p      = get(0,'ScreenSize'); 
  ww     = pcaprefg.moduser.widthheight(1); %380;
  wh     = pcaprefg.moduser.widthheight(2); %323;
  a = figure('Color',bgc0,'Resize','on', ...
    'Name','Linear Regression', ...
    'HandleVisibility','off', ...
    'NumberTitle','Off','Position',[6 p(4)-wh-40 ww wh]);
  as     = int2str(a);
  
  % I/O Menu
  b      = zeros(3,1);
  bb     = zeros(14,1);
  b(1,1) = uimenu(a,'Label','&MODL_File');
  bb(1,1)= uimenu(b(1,1),'Label','&Load Data', ...
    'CallBack',['modlgui(''loaddata'',',as,');']);
  bb(2,1)= uimenu(b(1,1),'Label','&Load Model', ...
    'CallBack',['modlgui(''loadmodl'',',as,');']);
  b(3,1) = uimenu(b(1,1),'Label','&Load Scale','Enable','off');
  bb(3,1)= uimenu(b(3,1),'Label','&Sample','Enable','off', ...
    'CallBack',['modlgui(''loadsscl'',',as,');']);
  bb(4,1)=uimenu(b(3,1),'Label','&Variable','Enable','off', ...
    'CallBack',['modlgui(''loadvscl'',',as,');']);
  b(2,1) = uimenu(b(1,1),'Label','&Load Labels','Enable','off');
  bb(5,1)= uimenu(b(2,1),'Label','&Sample','Enable','off', ...
    'CallBack',['modlgui(''loadslbl'',',as,');']);
  bb(6,1)= uimenu(b(2,1),'Label','&Variable','Enable','off', ...
    'CallBack',['modlgui(''loadvlbl'',',as,');']);
  bb(7,1)= uimenu(b(1,1),'Label','&Save Data','Enable','off',  ...
    'CallBack',['modlgui(''savemat'',',as,');'],'Separator','on');
  bb(12,1)= uimenu(b(1,1),'Label','&Save Test','Enable','off',  ...
    'CallBack',['modlgui(''savetst'',',as,');']);
  bb(8,1)= uimenu(b(1,1),'Label','&Save Model','Enable','off',  ...
    'CallBack',['modlgui(''savemodl'',',as,');']);
  bb(14,1)= uimenu(b(1,1),'Label','&Print Info','Enable','off',  ...
    'CallBack',['modlgui(''printssqtable'',',as,');']);
  bb(13,1)= uimenu(b(1,1),'Label','&Preferences','Enable','on',  ...
    'CallBack',['prefpls(',as,');']);
  bb(9,1)= uimenu(b(1,1),'Label','&Clear Data','Enable','off',  ...
    'CallBack',['modlgui(''cleardata'',',as,');'],'Separator','on');
  bb(10,1)= uimenu(b(1,1),'Label','&Clear Model','Enable','off',  ...
    'CallBack',['modlgui(''clearmodl'',',as,');']);
  bb(11,1)=uimenu(b(1,1),'Label','&Exit MODLGUI', ...
    'CallBack',['modlgui(''exitmodl'',',as,');'],'Separator','on');

% Internal StatusBar
  d      = zeros(4,1);
  e      = zeros(8,1);
  d(1,1) = uicontrol('Parent',a,'Style','frame', ...
    'Units','normalized','Position', ...
    [0.0263158 0.736842 0.947368 0.250774]);
% Variance Captured List/text
  d(2,1) = uicontrol('Parent',a,'Style','frame', ...
   'Units','normalized','Position', ...
    [0.0263158 0.0309598 0.778947 0.696594]);
  s = str2mat(...
    '     Percent Variance Captured by Model', ...
    '             X-Block          Y-Block', ...
    ' Latent    This             This', ...
    'Variable    LV    Cum        LV     Cum');
  e(1,1) = uicontrol('Parent',a, ...
    'Units','normalized','Position', ...
    [0.0342105 0.482972 0.763158 0.170279], ...
    'HorizontalAlignment','left', ...
    'String',s,'Style','text', ...
    'FontName',pcaprefg.moduser.tableheader.FontName, ...
    'FontUnits',pcaprefg.moduser.tableheader.FontUnits, ...
    'FontSize',pcaprefg.moduser.tableheader.FontSize, ...
    'FontWeight',pcaprefg.moduser.tableheader.FontWeight, ...
    'FontAngle',pcaprefg.moduser.tableheader.FontAngle, ...
    'UserData','%3.0f     %6.2f  %6.2f   %6.2f   %6.2f');
  e(2,1) = uicontrol('Parent',a, ...
    'Units','normalized','Position', ...
    [0.0342105 0.659443 0.271053 0.055728], ...
    'String','No. LVs Selected:', ...
    'HorizontalAlignment','center','FontWeight','bold', ...
    'Style','text','FontName','geneva','Fontsize',10);
  e(3,1) = uicontrol('Parent',a, ...
    'Units','normalized','Position', ...
    [0.313158 0.659443 0.131579 0.061920], ...
    'FontSize',10,'FontName','geneva','FontWeight','bold', ...
    'String',' ','Style','edit', ...
    'Callback',['modlgui(''actssq2'',',as,');'], ...
    'TooltipString','edit to select number of latent variables');
  e(4,1) = uicontrol('Parent',a,'BackgroundColor',bgc3, ...
    'Units','normalized','Style','listbox','String',[], ...
    'Position',[0.034211 0.040248 0.76315 0.433437], ...
    'FontName',pcaprefg.moduser.tablebody.FontName, ...
    'FontUnits',pcaprefg.moduser.tablebody.FontUnits, ...
    'FontSize',pcaprefg.moduser.tablebody.FontSize, ...
    'FontWeight',pcaprefg.moduser.tablebody.FontWeight, ...
    'FontAngle',pcaprefg.moduser.tablebody.FontAngle, ...
    'HorizontalAlignment','left', ...
    'SelectionHighlight','off','Value',1, ...
    'Callback',['modlgui(''actssq'',',as,');']);% , ...
    %'TooltipString','click to select number of latent variables');
  %Text for internal status bar
  s = str2mat('Data: none loaded');
  e(5,1) =  uicontrol('Parent',a,'BackgroundColor',bgc3, ...
    'Units','normalized','Position', ...
    [0.034211 0.746130 0.461842 0.232198], ...
    'HorizontalAlignment','left', ...
    'Style','text','String',s, ...
    'FontName',pcaprefg.moduser.statwindow.FontName, ...
    'FontUnits',pcaprefg.moduser.statwindow.FontUnits, ...
    'FontSize',pcaprefg.moduser.statwindow.FontSize, ...
    'FontWeight',pcaprefg.moduser.statwindow.FontWeight, ...
    'FontAngle',pcaprefg.moduser.statwindow.FontAngle);
  s = ['Model: none loaded'];
  e(6,1) =  uicontrol('Parent',a,'BackgroundColor',bgc3, ...
    'Units','normalized','Position', ...
    [0.503947 0.746130 0.461842 0.232198], ...
    'HorizontalAlignment','left', ...
    'Style','text','String',s, ...
    'FontName',pcaprefg.moduser.statwindow.FontName, ...
    'FontUnits',pcaprefg.moduser.statwindow.FontUnits, ...
    'FontSize',pcaprefg.moduser.statwindow.FontSize, ...
    'FontWeight',pcaprefg.moduser.statwindow.FontWeight, ...
    'FontAngle',pcaprefg.moduser.statwindow.FontAngle);
  if strcmp(lower(computer),'mac2')
    s = str2mat(...
      '        Percent Variance Captured by Model', ...
      '           X-Block              Y-Block', ...
      '        This                 This', ...
      '  LV     LV       Cum         LV       Cum');
    set(e(1,1),'String',s, ...
      'UserData',' %3.0f    %6.2f     %6.2f        %6.2f     %6.2f')
  end
  e(7,1) = uicontrol('Parent',a,'BackgroundColor',bgc3, ...
    'Units','normalized','Position', ...
    [0.503947 0.659443 0.293421 0.055728], ...
    'String','show parameters', ...
    'HorizontalAlignment','center','FontWeight','bold', ...
    'Style','text','FontName','geneva','Fontsize',10);
  e(8,1) = uicontrol('Parent',a,'Style','checkbox', ...
    'Value',1,'Units','normalized','Position', ...
    [0.453947 0.662539 0.042105 0.049536], ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc3, ...
    'Callback',['modlgui(''showp'',',as,');']);

% Buttons
  d(3,1) = uicontrol('Parent',a, ...
    'Units','normalized','Position', ...
    [0.810526 0.544892 0.160526 0.1826623],'Style','frame');
  d(4,1) = uicontrol('Parent',a, ...
    'Units','normalized','Position', ...
    [0.810526 0.030960 0.160526 0.507740],'Style','frame');
  c = uicontrol('Parent',a, ...
    'BackgroundColor',bgc1,'ForegroundColor',bgc3, ...
    'Style','text','Units','normalized','Position', ...
    [0.818421 0.464396 0.144737 0.061920], ...
    'FontName',pcaprefg.moduser.buttons.FontName, ...
    'FontUnits',pcaprefg.moduser.buttons.FontUnits, ...
    'FontSize',pcaprefg.moduser.buttons.FontSize, ...
    'FontWeight',pcaprefg.moduser.buttons.FontWeight, ...
    'FontAngle',pcaprefg.moduser.buttons.FontAngle, ...
    'String','plots');
  f      = zeros(7,1);
  f(1,1) = uicontrol('Parent',a, ...
    'CallBack',['modlgui(''calculate'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.640867 0.1447368 0.077399],'String','calc', ...
    'TooltipString','calculate regression model');
  f(2,1) = uicontrol('Parent',a, ...
    'CallBack',['modlgui(''apply'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.554180 0.1447368 0.077399],'String','apply', ...
    'TooltipString','apply regression model');
  f(3,1) = uicontrol('Parent',a, ...
    'CallBack',['modlplt1(''plotscree'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.386997 0.1447368 0.077399],'String','press', ...
    'TooltipString','plot cross-validation results');
  f(4,1) = uicontrol('Parent',a, ...
    'CallBack',['modlplts(''plotscores'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.300310 0.1447368 0.077399],'String','scores', ...
    'TooltipString','plot scores, predictions and sample statistics');
  f(5,1) = uicontrol('Parent',a, ...
    'CallBack',['modlplts(''plotloads'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.21362 0.1447368 0.077399],'String','loads', ...
    'TooltipString','plot loads, regression coef and variable statistics');
  f(6,1) = uicontrol('Parent',a, ...
    'CallBack',['modlplt1(''biplot'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.126935 0.1447368 0.077399],'String','biplot', ...
    'TooltipString','plot scores and loadings biplots');
  f(7,1) = uicontrol('Parent',a, ...
    'CallBack',['modlplt1(''rawplot'',',as,');'], ...
    'Units','normalized','Position', ...
    [0.818421 0.040248 0.1447368 0.077399],'String','data', ...
    'TooltipString','plot raw data');

  %Set common properties
  set(d(1:length(d),1),'BackgroundColor',bgc1)
  set(e(1:length(e),1),'BackgroundColor',bgc3)
  set(f(1:length(f),1),'BackgroundColor',bgc2, ...
    'FontName',pcaprefg.moduser.buttons.FontName, ...
    'FontUnits',pcaprefg.moduser.buttons.FontUnits, ...
    'FontSize',pcaprefg.moduser.buttons.FontSize, ...
    'FontWeight',pcaprefg.moduser.buttons.FontWeight, ...
    'FontAngle',pcaprefg.moduser.buttons.FontAngle, ...
    'Enable','off')

  [p2,e2,f2] = regset(a);
  set(a,'CloseRequestFcn',['modlgui(''exitmodl'',',as,');'])

  %Assign Handles
  stat.data  = 'none';
  stat.modl  = 'none';
  modl       = [];
  test       = [];
  set(a,'UserData',d)         %Frame Handles
  set(d(1,1),'UserData',b)    %UIMenu Handles
  set(d(2,1),'UserData',e)    %Text Handles
  set(d(3,1),'UserData',f)    %Button Handles
  set(e(7,1),'UserData',e2)   %Params Slider/Popups
  set(e(8,1),'UserData',p2)   %Params Window
  set(p2,'UserData',f2)       %Slider Text Values
  set(b(3,1),'UserData',bb)   %SubMenu Handles
  set(b(1,1),'UserData',stat)
  set(f(2,1),'UserData',modl)
  set(f(5,1),'UserData',test)
  modlgui('cleardata',a);
  modlgui('clearmodl',a);
  figure(a)
else
  %Get handles
  d    = get(fighand,'UserData'); %Frame Handles
  a    = get(d(1,1),'Parent');
  as   = int2str(a);
  b    = get(d(1,1),'UserData');  %UIMenu Handles
  e    = get(d(2,1),'UserData');  %Text Handles
  f    = get(d(3,1),'UserData');  %Button Handles
  x    = get(f(1,1),'UserData');  %X-block data
  y    = get(f(7,1),'UserData');  %Y-block data
  stat = get(b(1,1),'UserData');  %Data/Model Status
  modl = get(f(2,1),'UserData');  %Model
  test = get(f(5,1),'UserData');  %Test Data
  p2   = get(e(8,1),'UserData');  %Params Widow
  e2   = get(e(7,1),'UserData');  %Params Slider/Popups
  f2   = get(p2,'UserData');      %Slider Text Values
  bb   = get(b(3,1),'UserData');  %SubMenu Handles
  %CallBacks
  switch lower(action)
  case 'loaddata'
    if strcmp(stat.modl,'none')
      lddlgpls(f(1,1),d(4,1),'double','cal X-block')
      x             = get(f(1,1),'UserData');
      if size(x,1)>0&size(x,2)>0
        lddlgpls(f(7,1),f(6,1),'double','cal Y-block')
        y           = get(f(7,1),'UserData');
      end
      if isempty(x)|isempty(y)
        modlgui('cleardata',a);
      elseif size(x,1)~=size(y,1)
        erdlgpls('number of samples in X and Y must be equal', ...
          'Error on Load Data!')
        modlgui('cleardata',a);
      elseif size(x,1)==1|size(x,2)==1
        erdlgpls('X-block must be a matrix','Error on Load Data!')
        modlgui('cleardata',a);
      elseif ~isempty(find(isinf(x)))|~isempty(find(isnan(x)))
        erdlgpls('X-block contains "inf" or "NaN" please see mdpca', ...
          'Error on Load Data!')
        modlgui('cleardata',a);
      elseif ~isempty(find(isinf(y)))|~isempty(find(isnan(y)))
        erdlgpls('Y-block contains "inf" or "NaN" please see mdpca', ...
          'Error on Load Data!')
        modlgui('cleardata',a);
      else
        stat.data    = 'new';
        if strcmp(stat.modl,'none')
          modl.xname = get(d(4,1),'UserData');
          modl.yname = get(f(6,1),'UserData');
          modl.irow  = 1:size(x,1);
          modl.icol  = 1:size(x,2);
          s          = min(size(x)');
          s          = min([size(x) 40 rank(x)]');
          set(f2(4,1),'String',int2str(s))
          set(f2(1,1),'String',int2str(min([40 s]')))
          set(e2(1,1),'Max',s,'Value',min([40 s]'), ...
            'SliderStep',[1/s 2/s])     %set max lvs

          s          = min([size(x,1)/2 40]');
          set(e2(2,1),'Max',s,'SliderStep',[1/s 2/s])
          modl.split = min([round(sqrt(size(x,1))) 10]');
          modl.split = max([modl.split 2]');
          set(e2(2,1),'Value',modl.split);   %set splits
          set(f2(2,1),'String',int2str(modl.split))
          modl.iter  = get(e2(3,1),'Value'); %set iter
        else
          stat.modl  = 'loaded';
        end
        set(f(2,1),'UserData',modl)
      end
    elseif strcmp(stat.modl,'calold')|strcmp(stat.modl,'loaded')
      lddlgpls(f(1,1),d(4,1),'double','test X-block')
      x             = get(f(1,1),'UserData');
      if isempty(x)
        modlgui('cleardata',a);
      elseif size(x,2)~=size(modl.reg,1)
        erdlgpls('number of vars in X ~= number of regression coef', ...
          'Error on Load Data!')
        modlgui('cleardata',a);
      elseif size(x,1)==1|size(x,2)==1
        erdlgpls('X-block must be a matrix','Error on Load Data!')
        modlgui('cleardata',a);    
      else
        stat.data   = 'new';
        stat.modl   = 'loaded';
        test.xname  = get(d(4,1),'UserData');
        set(f(5,1),'UserData',test)
      end
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
    lddlgpls(f(2,1),bb(1,1),'struct')
    modl   = get(f(2,1),'UserData');
    if isempty(modl)
      modlgui('clearmodl',a)
    else
      s    = char(fieldnames(modl));
      s1   = 'no';
      for jj=1:size(s,1)
        if strncmp(s(jj,:),'name',4)
          s1 = 'yes';
        end
      end
      if strcmp(s1,'no')|size(modl,1)>1|size(modl,2)>1
        erdlgpls('variable not a regression model', ...
          'Error on Load Model!')
        modlgui('clearmodl',a)
      elseif strcmp(s1,'yes')
        s  = strcmp(lower(modl.name),'nip');
        s  = strcmp(lower(modl.name),'sim')+s;
        s  = strcmp(lower(modl.name),'pcr')+s;
        if s
          if isempty(modl.xname)
            modlgui('clearmodl',a)
          else
            stat.modl = 'loaded';
            if ~strcmp(stat.data,'none')
              stat.data = 'new';
            end
            x      = size(modl.loads,2);
            format= get(e(1,1),'UserData');
            s      = [];
            for jj=1:size(modl.ssq,1)
              s    = [s;sprintf(format,modl.ssq(jj,:))];
            end
            set(e(4,1),'String',s,'Value',x)
            set(e(3,1),'String',int2str(x))
            set(f(4,1),'UserData',x)
          end
        else
          erdlgpls('variable not a regression model', ...
            'Error on Load Model!')
          modlgui('clearmodl',a)
        end
      else
        erdlgpls('variable not a regression model','Error on Load Model!')
        modlgui('clearmodl',a)
      end
    end
  case 'savemat'
    x    = x(modl.irow,modl.icol);
    y    = y(modl.irow,:);
    if isempty(x)
      erdlgpls('no data loaded to be saved','Error on Save!')
    else
      svdlgpls(x,'X-block');
      svdlgpls(y,'Y-block');
    end
  case 'savetst'
    if isempty(test)|isempty(test.xname)
      erdlgpls('no test data to be saved','Error on Save!')
    else
      svdlgpls(test,[upper(modl.name), ' test']);
    end     
  case 'savemodl'
    if isempty(modl)|isempty(modl.name)
      erdlgpls('no model to be saved','Error on Save!')
    else
      svdlgpls(modl,[upper(modl.name),' model']);
    end
  case 'cleardata'
    stat.data   = 'none';      %'new', 'cal', 'test'
    set(d(4,1),'UserData',[])  %clear x-block name
    modl.xname  = [];
    set(f(1,1),'UserData',[])  %clear x-block data
    set(f(6,1),'UserData',[])  %clear y-block name
    modl.yname  = [];
    set(f(7,1),'UserData',[])  %clear y-block data
    test.date   = [];          %
    test.time   = [];          %
    test.scores = [];          %Scores for test data
    test.res    = [];          %Sample Q residuals for test data
    test.tsq    = [];          %Sample Hotelling T^2 for tst data
    test.sscl   = [];          %Sample scale
    test.slbl   = [];          %Sample labels for test data
    test.slbln  = [];          %Sample label name for test data
    test.xname  = [];          %Name of loaded X-block variable
    test.ypred  = [];          %Predicted Y-block
    if ~strcmp(stat.modl,'none')
      stat.modl = 'loaded';
    end
    set(bb(12,1),'Enable','off')
    set(bb(1,1),'Enable','on')
  case 'clearmodl'
    stat.modl   = 'none';      %'calold', 'calnew', 'loaded'
    modl.date   = [];          %Date model was created
    modl.time   = [];          %Time model was created
    modl.reg    = [];          %Regression vector(s)
    modl.xname  = [];          %Name of loaded X-block variable
    modl.yname  = [];          %Name of loaded Y-block variable
    modl.ypred  = [];          %Y-block predictions
    modl.wts    = [];          %PLS weights w in NIPLS, r in SIMPLS
    modl.scores = [];          %X-block scores for cal data
    modl.loads  = [];          %X-block loadings
    modl.ssq    = [];          %Variance information
    modl.rmsec  = [];          %RMSEC
    modl.rmsecv = [];          %RMSECV
    modl.meanx  = [];          %Centering vectors
    modl.meany  = [];
    modl.stdx   = [];          %Scaling vectors
    modl.stdy   = [];
    modl.press  = [];          %Cross validation cumpress
    modl.res    = [];          %Sample Q residuals    
    modl.reslim = [];          %95% conf limit for Q
    modl.reseig = [];          %Residual Eigenvalues
    modl.yres   = [];          %Studentized y residuals
    modl.tsq    = [];          %Sample Hotelling T^2
    modl.tsqlim = [];          %95% conf limit for T^2
    modl.lev    = [];          %Leverage
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
    %need to check if data loaded, if so give it those names
    switch get(e2(4,1),'value') %Scaling
    case 1
      modl.scale = 'none';
    case 2
      modl.scale = 'mean';
    case 3
      modl.scale = 'auto';
    end
    switch get(e2(5,1),'value') %Regression Method
    case 1
      modl.name  = 'nip';
    case 2
      modl.name  = 'sim';
    case 3
      modl.name  = 'pcr';
    end
    switch get(e2(6,1),'value') %Cross Validation Method
    case 1
      modl.cv    = 'loo';
    case 2
      modl.cv    = 'vet';
    case 3
      modl.cv    = 'con';
    case 4
      modl.cv    = 'rnd';
    end
    if ~strcmp(stat.data,'none')
      stat.data = 'new';
      [m,n]     = size(get(f(1,1),'UserData'));
      modl.irow = [1:m];
      modl.icol = [1:n];
      s         = min([m n 40]');
      set(e2(1,1),'Value',1,'Max',s)           %set max lvs
      set(f2([2 4],1),'String',int2str(s))
      set(f2(1,1),'String','1')
      modl.split = min([round(sqrt(m)) 10]');  %set splits
      modl.split = max([modl.split 2]');
    else
      set(e2(1,1),'Value',1,'Max',2)           %set max lvs
      set(f2(4,1),'String','2')
      set(f2(1,1),'String','1')
      modl.split  = 2;                         %set splits      
    end
    set(e2(2,1),'Value',modl.split);
    set(f2(2,1),'String',int2str(modl.split))
    modl.iter   = 5;                           %set iter
    set(e2(3,1),'Value',modl.iter)
    set(f2(3,1),'String',int2str(modl.iter))
  case 'exitmodl'
    %check to see if data edited, if so ask if save
    %check to see if model changed, if so ask if save
    delfigs(as)
    figure(p2),closereq
    figure(a), closereq
  %Button Callbacks
  case 'calculate'
    delfigs(as)
    x          = get(f(1,1),'UserData');
    y          = get(f(7,1),'UserData');
    if ~isempty(x)&~isempty(y)
      if ~isempty(modl)
        if ~isempty(modl.drow)
          jk   = [];
          for jj=1:length(modl.drow)
            jk = [jk,find(modl.irow==modl.drow(jj))];
          end
          modl.irow = delsamps(modl.irow',jk)';
        end
        x      = x(modl.irow,modl.icol);
        y      = y(modl.irow,:);
        set(bb(8,1),'Enable','on');               %save model menu
        [m,nx] = size(x);
        ny     = size(y,2);
        modl.meanx       = mean(x);
        modl.meany       = mean(y);
        modl.stdx        = std(x);
        modl.stdy        = std(y);
        switch modl.scale                         %Scaling
        case 'mean'                               %mean center
          x    = mncn(x);
          y    = mncn(y);
          mc   = 1;
        case 'auto'                               %autoscale
          x    = auto(x);
          y    = auto(y);
          mc   = 1;
        otherwise                                 %no scaling
          mc   = 0;
        end
        maxlv            = round(get(e2(1,1),'Value'));
        [ps,modl.press,modl.rmsecv,modl.rmsec]  = crossval(x,y, ...
          modl.name,modl.cv,maxlv,modl.split,modl.iter,mc,0);
        if strcmp(modl.scale,'auto')              %Scaling
          modl.press     = modl.press.*(modl.stdy(ones(maxlv,1),:).^2)'*m;
          modl.rmsecv    = modl.rmsecv.*(modl.stdy(ones(maxlv,1),:))';
          modl.rmsec     = modl.rmsec.*(modl.stdy(ones(maxlv,1),:))';
        end
 
        if size(y,2)>1
          [ps,minlv]     = min(sum(modl.press)');
        else
          [ps,minlv]     = min(modl.press');
        end
        switch modl.name
        case 'nip'
          [modl.reg,modl.ssq,p,q,w,t] = pls(x,y,maxlv,0);
          set(e(2,1),'UserData',w)
          set(e(3,1),'UserData',modl.reg)
          set(e(6,1),'UserData',q)
          modl.wts  = w(:,1:minlv);
          set(f(3,1),'UserData',p)
        case 'sim'
          [modl.reg,modl.ssq,p,q,r,t] = simpls(x,y,maxlv,[],0);
          set(e(2,1),'UserData',r)
          set(e(3,1),'UserData',modl.reg)
          set(e(6,1),'UserData',q)
          modl.wts  = r(:,1:minlv);
          set(f(3,1),'UserData',p)
          for ii=1:minlv
            t(:,ii) = t(:,ii)*norm(p(:,ii));
            p(:,ii) = p(:,ii)/norm(p(:,ii));
          end
        case 'pcr'
          [modl.reg,modl.ssq,t,p] = pcr(x,y,maxlv,0);
          set(e(2,1),'UserData',[])
          set(e(3,1),'UserData',modl.reg)
          set(e(6,1),'UserData',[])
          modl.wts  = [];
          set(f(3,1),'UserData',p)
        end
        s           = (minlv-1)*ny;
        set(e2(1,1),'UserData',modl.reg)
        modl.reg    = modl.reg(s+1:s+ny,:)';  %Regression vector(s)
        switch modl.scale
        case 'mean'
          modl.ypred  = rescale(x*modl.reg,modl.meany);
          modl.yres   = modl.ypred-rescale(y,modl.meany);
        case 'auto'
          modl.ypred  = rescale(x*modl.reg,modl.meany,modl.stdy);
          modl.yres   = modl.ypred-rescale(y,modl.meany,modl.stdy);
        otherwise
          modl.ypred  = x*modl.reg;
          modl.yres   = modl.ypred-y;
        end
        t           = t(:,1:minlv);
        p           = p(:,1:minlv);
        %Sample residuals Q
        if minlv<min([m nx])
          resmat = x - t*p';
          modl.res    = sum(resmat.^2,2);
          if m > nx
            covr = (resmat'*resmat)/(m-1);
          else
            covr = (resmat*resmat')/(m-1);
          end
          emod = svd(covr);
          emod = emod(1:length(emod)-minlv);
		  modl.reseig = emod;
          modl.reslim = reslim(0,emod,95);
        else
          modl.res = zeros(m,1);
          modl.reslim = 0;
		  modl.reseig = [];
        end
        %T^2 and Limit
        ps          = 1./sqrt(diag(t'*t)/(m-1));
        modl.tsq    = t*diag(ps);
        if minlv>1
          modl.tsq  = sum((modl.tsq.^2)')';
        else
          modl.tsq  = modl.tsq.^2;
        end
        modl.tsqlim = tsqlim(m,minlv,95); %95% confidence limit for T^2
        modl.date   = date;               %date model was created
        modl.time   = clock;              %time model was created
        modl.xname  = get(d(4,1),'UserData');
        modl.yname  = get(f(6,1),'UserData');
        modl.scores = t;                  %Scores
        modl.samps  = m;                  %Number of samples in (data)
        modl.loads  = p;                  %Loadings
        %modl.lev    = diag(t*diag(1./diag(t'*t))*t'); %Leverage
        modl.lev    = sum(t'.*(diag(1./diag(t'*t))*t'),1)';
        p           = ones(m,1)-modl.lev;
        p           = p(:,ones(1,ny));
        ps          = sqrt(diag(modl.yres'*(modl.yres./(p.^2)))/(m-1))';
        modl.yres   = modl.yres./(ps(ones(m,1),:).*sqrt(p));
        set(e(5,1),'UserData',modl.yres)
        clear x y t m p w maxlv ps
        format = get(e(1,1),'UserData');
        s      = [];
        ps     = str2num(get(f2(1,1),'String'));
        for jj=1:min([size(modl.ssq,1); 40])
          s    = [s;sprintf(format,modl.ssq(jj,:))];
        end
        set(f(4,1),'UserData',minlv);
        set(e(3,1),'String',int2str(minlv))
        set(e(4,1),'String',s,'Value',minlv)
        stat.data = 'cal';
        stat.modl = 'calold';
      else
        stat.modl = 'none';
      end
    else
      stat.data   = 'none';
    end
    set(bb(12,1),'Enable','off')
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
      y     = y(modl.irow,:);
    end
    [mx,nx] = size(x);
    ny      = size(y,2);
    m       = size(modl.loads,1);
    if nx~=m
      erdlgpls('Error- num vars in x ~= num rows of loads ', ...
        'Error on Apply');
    else
      switch modl.scale                         %scale x but not y
      case 'mean'
        x     = scale(x,modl.meanx);
      case 'auto'
        x     = scale(x,modl.meanx,modl.stdx);
      end
      m     = get(f(4,1),'UserData');           %number of LVs
      if ~strcmp(stat.modl,'loaded')
        p           = get(f(3,1),'UserData');
        modl.loads  = p(:,1:m);                 %Loadings
        switch lower(modl.name)
        case 'nip'
          w         = get(e(2,1),'UserData');
          modl.wts  = w(:,1:m);
          xhat      = x;
          modl.scores = zeros(mx,m);
          for ii=1:m
            modl.scores(:,ii) = xhat*modl.wts(:,ii);
            xhat    = xhat - modl.scores(:,ii)*modl.loads(:,ii)';
          end
        case 'sim'
          r         = get(e(2,1),'UserData');
		      modl.wts = r(:,1:m);
          modl.scores = x*r;
          for ii=1:m
            modl.scores(:,ii) = modl.scores(:,ii)*norm(p(:,ii));
            modl.loads(:,ii)  = p(:,ii)/norm(p(:,ii));
          end
          modl.scores = modl.scores(:,1:m);
        case 'pcr'
          modl.scores = x*modl.loads;
        end
        modl.reg    = get(e2(1,1),'UserData');
        modl.reg    = modl.reg(ny*(m-1)+1:ny*m,:)';  %Regression vector(s)
        switch modl.scale
        case 'mean'
          modl.ypred  = rescale(x*modl.reg,modl.meany);
        case 'auto'
          modl.ypred  = rescale(x*modl.reg,modl.meany,modl.stdy);
        otherwise
          modl.ypred  = x*modl.reg;
        end
        %Sample residuals Q
        if size(modl.loads,2)<min(size(x))
          resmat = x - modl.scores*modl.loads';
          if size(resmat,1) > size(resmat,2)
            covr = (resmat'*resmat)/(size(resmat,1)-1);
          else
            covr = (resmat*resmat')/(size(resmat,1)-1);
          end
          modl.res    = sum(resmat.^2,2);
          emod = svd(covr);
          emod = emod(1:length(emod)-m);
          modl.reseig = emod;
          modl.reslim = reslim(0,emod,95);
        else
          modl.res = zeros(m,1);
          modl.reslim = 0;
        end
        %T^2 and Limit
        ps          = 1./sqrt(diag(modl.scores'*modl.scores)/(modl.samps-1));
        modl.tsq    = modl.scores*diag(ps);
        if m>1
          modl.tsq  = sum((modl.tsq.^2)')';
        else
          modl.tsq  = modl.tsq.^2;
        end
        modl.tsqlim = tsqlim(mx,m,95);    %95% conf limit for T^2
        modl.lev    = diag(1./diag(modl.scores'*modl.scores));
        modl.lev    = diag(modl.scores*modl.lev*modl.scores'); %Leverage
        modl.yres   = modl.ypred-y;  %y in original units
        p           = ones(mx,1)-modl.lev;
        p           = p(:,ones(1,ny));
        ps          = sqrt(diag(modl.yres'*(modl.yres./(p.^2)))/(mx-1))';
        modl.yres   = modl.yres./(ps(ones(mx,1),:).*sqrt(p));
        set(e(5,1),'UserData',modl.yres)
        set(bb(12,1),'Enable','off')
      else                                %apply to test data
        switch lower(modl.name)
        case 'nip'
          xhat      = x;
          test.scores = zeros(mx,m);
          for ii=1:m
            test.scores(:,ii) = xhat*modl.wts(:,ii);
            xhat    = xhat-test.scores(:,ii)*modl.loads(:,ii)';
          end
          test.ypred  = x*modl.reg;
        case 'sim'
          test.scores = x*modl.wts(:,1:m);
          for ii=1:m
            test.scores(:,ii) = test.scores(:,ii)* ...
              norm(modl.scores(:,ii));
          end
          test.ypred  = x*modl.reg;
        case 'pcr'
          test.ypred  = x*modl.reg;
          test.scores = x*modl.loads;
        end
        test.date   = date;               %date test performed
        test.time   = clock;              %time test performed
        switch modl.scale
        case 'mean'
          test.ypred  = rescale(test.ypred,modl.meany);
        case 'auto'
          test.ypred  = rescale(test.ypred,modl.meany,modl.stdy);
        end
        %Sample residuals Q
        test.res    = (x - test.scores*modl.loads').^2;
        test.res    = sum(test.res')';
        %Sample T^2
        test.tsq    = 1./sqrt(diag(modl.scores'*modl.scores)/(modl.samps-1));
        test.tsq    = test.scores*diag(test.tsq);
        if m>1
          test.tsq  = sum((test.tsq.^2)')';
        else
          test.tsq  = test.tsq.^2;
        end
        set(bb(12,1),'Enable','on')
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
      set(f(4,1),'UserData',n)
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
      set(f(4,1),'UserData',n)
      stat.modl = 'calnew';
    end
  case 'showp'
    if get(e(8,1),'Value')
      set(p2,'Visible','on')
    else
      set(p2,'Visible','off')
    end
  case 'showp2'
    set(e(8,1),'Value',0)
    set(p2,'Visible','off')
  case 'printssqtable'
    ssqtable(modl,size(modl.loads,2));
  case 'maxlvs'
    s        = round(get(e2(1,1),'Value'));
    set(f2(1,1),'String',int2str(s))
    if strcmp(stat.modl,'calold')&s<=size(modl.loads,2)
      stat.modl  = 'calnew';
    elseif strcmp(stat.modl,'calnew')&s<=size(modl.loads,2)
      stat.modl  = 'calnew';
    else
      stat.modl  = 'none';
    end
  case 'splits'
    s        = round(get(e2(2,1),'value'));
    set(e2(2,1),'Value',s), set(f2(2,1),'String',int2str(s))
    modl.split   = s;
    stat.modl    = 'none';
  case 'iterations'
    s        = round(get(e2(3,1),'value'));
    set(e2(3,1),'Value',s), set(f2(3,1),'String',int2str(s))
    modl.iter    = s;
    stat.modl    = 'none';
  case 'scaling'
    switch get(e2(4,1),'value')
    case 1
      modl.scale = 'none';
    case 2
      modl.scale = 'mean';
    case 3
      modl.scale = 'auto';
    end
    stat.modl    = 'none';
  case 'regression'
    switch get(e2(5,1),'value')
    case 1
      modl.name  = 'nip';
    case 2
      modl.name  = 'sim';
    case 3
      modl.name  = 'pcr';
    end
    stat.modl    = 'none';
  case 'crossval'
    switch get(e2(6,1),'value')
    case 1
      modl.cv    = 'loo';
    case 2
      modl.cv    = 'vet';
    case 3
      modl.cv    = 'con';
    case 4
      modl.cv    = 'rnd';
    end
    stat.modl    = 'none';
  end

  %button/slider/popup status
  if ~strcmp(lower(action),'exitmodl')
    set(b(1,1),'UserData',stat)
    set(f(2,1),'UserData',modl)
    set(f(5,1),'UserData',test)
    if strcmp(stat.data,'none')
      %no data, w/ and w/o model
      set(f(1:7,1),'Enable','off')
      set(e2(1:6,1),'Enable','off')
    elseif ~strcmp(stat.data,'none')&strcmp(stat.modl,'none')
      %new data, no model
      set(f([1 7],1),'Enable','on')
      set(f(2:6,1),'Enable','off')
      set(e2([1:6],1),'Enable','on')
    elseif ~strcmp(stat.data,'none')&(~strcmp(stat.modl,'none'))
      %data and model
      if strcmp(stat.modl,'calold')
        set(f(1:2,1),'Enable','off')
        set(f(3:7,1),'Enable','on')
        set(e2(1:6,1),'Enable','on')
      elseif strcmp(stat.modl,'calnew')
        set(f([1 4:6],1),'Enable','off')
        set(f([2:3 7],1),'Enable','on')
        set(e2(1:6,1),'Enable','on')
      elseif strcmp(stat.modl,'loaded')
        set(e2(1:6,1),'Enable','off')
        if strcmp(stat.data,'test')
          set(f(1:2,1),'Enable','off')
          set(f(3:7,1),'Enable','on')
        else
          set(f([1 3:6],1),'Enable','off')
          set(f([2 7],1),'Enable','on')
        end
      end
    end
    if strcmp(get(e2(1,1),'Enable'),'on')
      switch get(e2(6,1),'value')
      case 1
        modl.cv    = 'loo';
        set(e2(2:3,1),'Enable','off')
        set(e2([2:3 9:12],1),'Visible','off') %iterations/splits
        set(f2([2 3 5 6],1),'Visible','off')
      case 2
        modl.cv    = 'vet';
        set(e2(3,1),'Enable','off')
        set(e2(2,1),'Enable','on')
        set(e2([3 11 12],1),'Visible','off')  %iterations
        set(f2([3 6],1),'Visible','off')
        set(e2([2 9 10],1),'Visible','on')    %splits
        set(f2([2 5],1),'Visible','on')
      case 3
        modl.cv    = 'con';
        set(e2(3,1),'Enable','off')
        set(e2(2,1),'Enable','on')
        set(e2([3 11 12],1),'Visible','off')  %iterations
        set(f2([3 6],1),'Visible','off')
        set(e2([2 9 10],1),'Visible','on')    %splits
        set(f2([2 5],1),'Visible','on')
      case 4
        modl.cv    = 'rnd';
        set(e2(2:3,1),'Enable','on')
        set(e2([2:3 9:12],1),'Visible','on') %iterations/splits
        set(f2([2 3 5 6],1),'Visible','on')
      end
    end
    if ~strcmp(stat.data,'none')
      if ~isempty(modl.drow)
        modl.irow      = delsamps([1:size(get(f(1,1),'UserData'),1)]',modl.drow);
      end
      s = min([length(modl.irow) length(modl.icol) 40 rank(get(f(1,1),'UserData'))]');
      set(f2(4,1),'String',int2str(s))
      if get(e2(1,1),'Value')>s
        set(e2(1,1),'Value',s)
        set(f2(1,1),'String',int2str(s))
      end
      set(e2(1,1),'Max',s)
    end
    if get(f(4,1),'UserData')<2
      set(f(6,1),'Enable','off') %biplot button
      h = findobj('Name','Biplot ','Tag',as); close(h)
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
      set(bb([8 10 14],1),'Enable','off');
    else
      set(bb([8 10 14],1),'Enable','on');
      switch stat.modl  
      case 'loaded'
        if strcmp(stat.data,'none')
          s  = ['Model: loaded'];
          set(bb(1,1),'Enable','on')  %load data
        elseif strcmp(stat.data,'new')
          s  = ['Model: loaded but not applied'];
          set(bb(1,1),'Enable','off')  %load data
        elseif strcmp(stat.data,'test')
          s  = ['Model: loaded and applied'];
          set(bb(1,1),'Enable','off')  %load data
        end
      case 'calnew'
        s  = ['Model: not applied'];
        set(bb([1 12],1),'Enable','off')
      case 'calold'
        s  = ['Model: calibrated on loaded data'];
          set(bb(1,1),'Enable','off')  %load data
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
      switch lower(modl.name)
      case 'nip'
        s0 = 'NIPLS';
      case 'sim'
        s0 = 'SIMPLS';
      case 'pcr'
        s0 = 'PCR';
      end
      s0   = ['Method: ',s0];
      s1   = ['LV(s): ',int2str(pc)];
      s2   = ['Scaling: ',sc];
      s3   = ['Data: ',int2str(length(modl.irow)),' by ', ...
        int2str(length(modl.icol)),', ', ...
        int2str(length(modl.irow)),' by ', ...
        int2str(length(modl.meany))];
      set(e(6,1),'String',str2mat(s,s0,s1,s3,s2))
    end
    if strcmp(stat.data,'none')
      set(f(1,1),'UserData',[])
      set(e(5,1),'String','Data: none loaded')
      set(b(2:3,1),'Enable','off');
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
      if ~strcmp(stat.data,'cal')
        s3    = ['Var: ',get(d(4,1),'UserData'),', ',get(f(6,1),'UserData')];
        s2    = ['Size: ',int2str(m),' by ',int2str(n),', ',int2str(m), ...
          ' by ',int2str(size(y,2))];
      else
        s3    = ['Var: ',get(d(4,1),'UserData'),',', ...
          get(f(6,1),'UserData')];
        s2    = ['Size: ',int2str(m),' by ',int2str(n), ...
          ', ',int2str(m),' by ', ...
          int2str(size(get(f(7,1),'UserData'),2))];
      end
      s5    = ['Var Lbls: ',modl.vlbln];
      set(e(5,1),'String',str2mat(s3,s,s2,s4,s5))
    end
  end
end

function delfigs(as)
h = findobj('Name','PRESS','Tag',as);       close(h)
h = findobj('Name','Plot Scores','Tag',as); close(h)
h = findobj('Name','Plot Loads','Tag',as);  close(h)
h = findobj('Name','Biplot','Tag',as);      close(h)
h = findobj('Name','Data Plot','Tag',as);   close(h)

function [p,e,f] = regset(a)
bgc0    = [0 0 0];
bgc1    = [1 0 1]*0.6;
bgc2    = [1 1 1]*0.85;
bgc3    = [1 1 1];
fsiz    = 12;
fnam    = 'geneva';
as      = int2str(a);
p       = get(a,'Position');
p       = figure('Color',bgc0,'Resize','on', ...
  'Name','Regression Parameters','Tag',as, ...
  'NumberTitle','Off','Position',[p(1)+200 p(2)-20 380 239], ...
  'HandleVisibility','off', ...
  'CloseRequestFcn',['modlgui(''showp2'',',as,');']);
e       = zeros(15,1);
%Frames
d(1,1)  = uicontrol('Parent',p,'Style','frame', ...
  'Position',[11 11 144 225]);
d(2,1)  = uicontrol('Parent',p,'Style','frame', ...
  'Position',[157 11 214 225]);
d(3,1)  = uicontrol('Parent',p,'Style','frame', ...
  'Position',[14 14 138 219]);
d(4,1)  = uicontrol('Parent',p,'Style','frame', ...
  'Position',[160 14 208 219]);
%Max LV slider
e(1,1)  = uicontrol('Parent',p,'Style','slider', ...
  'Position',[194 180 140 18],'Min',1,'Max',2,'Value',1, ...
  'CallBack',['modlgui(''maxlvs'',',as,');'], ...
  'SliderStep',[0.03 0.06]);
e(7,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[194 160 110 18], ...
  'String','Max LVs','HorizontalAlignment','left');
e(8,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[164 180 30 20], ...
  'String',num2str(get(e(1,1),'Min')));
f(4,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[334 180 30 20], ...
  'String',num2str(get(e(1,1),'Max')));
f(1,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[304 160 30 20], ...
  'String',num2str(get(e(1,1),'Value')));
%Splits slider
e(2,1)  = uicontrol('Parent',p,'Style','slider', ...
  'Position',[194 130 140 18],'Min',2,'Max',20,'Value',2, ...
  'CallBack',['modlgui(''splits'',',as,');'], ...
  'SliderStep',[0.05 0.1]);
e(9,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[194 110 110 18], ...
  'String','# Splits','HorizontalAlignment','left');
e(10,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[164 130 30 20], ...
  'String',num2str(get(e(2,1),'Min')));
f(5,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[334 130 30 20], ...
  'String',num2str(get(e(2,1),'Max')));
f(2,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[304 110 30 20], ...
  'String',num2str(get(e(2,1),'Value')));
%Iterations slider
e(3,1)  = uicontrol('Parent',p,'Style','slider', ...
  'Position',[194 80 140 18],'Min',1,'Max',30,'Value',5, ...
  'CallBack',['modlgui(''iterations'',',as,');'], ...
  'SliderStep',[0.034 0.08]);
e(11,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[194 60 110 18], ...
  'String','# Iterations','HorizontalAlignment','left');
e(12,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[164 80 30 20], ...
  'String',num2str(get(e(3,1),'Min')));
f(6,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[334 80 30 20], ...
  'String',num2str(get(e(3,1),'Max')));
f(3,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[304 60 30 20], ...
  'String',num2str(get(e(3,1),'Value')));
%Scaling Popup
s       = str2mat('none','mean center','autoscale');
e(4,1)  = uicontrol('Parent',p,'Style','popupmenu', ...
  'Position',[24 180 118 18],'String',s,'Value',3, ...
  'CallBack',['modlgui(''scaling'',',as,');']);
e(13,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[24 160 118 18],'String','Scaling', ...
  'HorizontalAlignment','left');
%Regression Popup
s       = str2mat('NIPLS','SIMPLS','PCR');
e(5,1)  = uicontrol('Parent',p,'Style','popupmenu', ...
  'Position',[24 130 118 18],'String',s,'Value',2, ...
  'CallBack',['modlgui(''regression'',',as,');']);
e(14,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[24 110 118 18],'String','Regression', ...
  'HorizontalAlignment','left');
%Cross Validation Popup
s       = str2mat('leave one out','venetian blinds', ...
  'contiguous block','random subsets');
e(6,1)  = uicontrol('Parent',p,'Style','popupmenu', ...
  'Position',[24 80 118 18],'String',s,'Value',2, ...
  'CallBack',['modlgui(''crossval'',',as,');']);
e(15,1)  = uicontrol('Parent',p,'Style','text', ...
  'Position',[24 60-18 118 36],'String','Cross Validation', ...
  'HorizontalAlignment','left');
%set common properties
set(d(1:2,1),'BackgroundColor',bgc1,'Units','normalized')
set(d(3:4,1),'BackgroundColor',bgc3,'Units','normalized')
set(e(1:6,1),'BackgroundColor',bgc2,'Units','normalized', ...
  'Enable','off')
set(e(4:6,1),'FontName',fnam,'FontSize',fsiz-1)
set(e(7:15,1),'BackgroundColor',bgc3,'Units','normalized', ...
  'FontName',fnam,'FontSize',fsiz,'FontWeight','bold')
set(f(1:6,1),'BackgroundColor',bgc3,'Units','normalized', ...
  'FontName',fnam,'FontSize',fsiz,'FontWeight','bold')
