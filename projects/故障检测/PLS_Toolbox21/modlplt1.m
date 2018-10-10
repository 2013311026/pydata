function modlplt1(action,fighand)
%MODLPLT1 Called by MODLGUI
%
%See instead: MODLGUI

%Copyright Eigenvector Research, Inc. 1997-98
%nbg 4/4/97,6/97,7/97,1/98,9/98,10/98

d       = get(fighand,'UserData');
b       = get(d(1,1),'UserData');
e       = get(d(2,1),'UserData');
f       = get(d(3,1),'UserData');
p       = get(0,'DefaultFigurePosition');
stat    = get(b(1,1),'UserData');
modl    = get(f(2,1),'UserData');
test    = get(f(5,1),'UserData');
datstat = strcmp(stat.data,'test');
as      = int2str(fighand);

switch lower(action)
case 'closebiplt'
  h = findobj('Name','Variable Info','Tag',int2str(gcf));
  close(h)
  h = findobj('Name','Sample Info','Tag',int2str(gcf));
  close(h)
  closereq
case 'plotscree'
  h     = findobj('Name','PRESS','Tag',as); close(h)
  h     = figure('Name','PRESS','Menubar','none', ...
    'NumberTitle','off','Tag',as,'BusyAction','cancel', ...
    'CloseRequestFcn',['modlplt1(''closepress'',',as,')']);
  set(h,'position',[p(1)-50 p(2) 474 331])
  as2    = int2str(h);
  ah    = axes('units','pixels', ...
   'position',[49.4+94 34.65 294.5 232.275+46]);
  set(ah,'units','normalized')
  g     = zeros(20,1);
  g(1,1) = uicontrol('Parent',h, ...
    'Style','frame', ...
    'Position',[2 2 94 327], ...
    'BackgroundColor',[0 0 0],'UserData',ah);  %black frame
  g(2,1) = uicontrol('Parent',h, ...
    'Style','frame', ...
    'Position',[4 193 90 134], ...
    'BackgroundColor',[0.6 0 0.6]);  %top frame
  g(3,1) = uicontrol('Parent',h, ...
    'Style','frame', ...
    'Position',[4 74 90 117], ...
    'BackgroundColor',[0.6 0 0.6]);  %middle frame
  g(4,1) = uicontrol('Parent',h, ...
    'Style','frame', ...
    'Position',[4 4 90 68], ...
    'BackgroundColor',[0.6 0 0.6]);  %bottom frame
  g(5,1) = uicontrol('Parent',h, ...
    'Style','text','String','plots', ...
    'FontName','geneva','FontSize',10, ...
    'Position',[7 308 84 16], ...
    'BackgroundColor',[0.6 0 0.6], ...
    'ForegroundColor',[1 1 1]);      %text
  g(6,1) = uicontrol('Parent',h, ...
    'Style','text','String','frist plot', ...
    'FontName','geneva','FontSize',10, ...
    'Position',[7 286 84 16], ...
    'BackgroundColor',[0.6 0 0.6], ...
    'ForegroundColor',[1 1 1]);      %text
  g(7,1) = uicontrol('Parent',h, ...
    'Style','text','String','second plot', ...
    'FontName','geneva','FontSize',10, ...
    'Position',[7 242 84 16], ...
    'BackgroundColor',[0.6 0 0.6], ...
    'ForegroundColor',[1 1 1]);    %text
  g(8,1) = uicontrol('Parent',h, ...
    'Style','text','String','zoom', ...
    'FontName','geneva','FontSize',10, ...
    'Position',[7 53 84 16], ...
    'BackgroundColor',[0.6 0 0.6], ...
    'ForegroundColor',[1 1 1]);    %text
  g(9,1) = uicontrol('Parent',h, ...
    'Position',[7 7 84 20], ...
    'BackgroundColor',[0.85 0.85 0.85], ...
    'CallBack',['modlpset(''home'',',as2,');'], ...
    'String','home', ...
    'TooltipString','original axes');
  g(10,1) = uicontrol('Parent',h, ...
    'Position',[7 30 41 20], ...
    'BackgroundColor',[0.85 0.85 0.85], ...
    'String','in', ...
    'CallBack',['modlpset(''into'',',as2,');'], ...
    'TooltipString','click opposite corners to zoom');
  g(11,1) = uicontrol('Parent',h, ...
    'Position',[50 30 41 20], ...
    'BackgroundColor',[0.85 0.85 0.85], ...
    'String','out', ...
    'CallBack',['modlpset(''outof'',',as2,');'], ...
    'TooltipString','zoom out one level');
  g(12,1) = uicontrol('Parent',h, ...
    'Position',[7 196 84 20], ...
    'BackgroundColor',[0.85 0.85 0.85], ...
    'String','plot', ...
    'CallBack',['modlplt1(''pressplotbutton'',',as,');'], ...
    'TooltipString','plot with current settings');
  g(13,1) = uicontrol('Parent',h, ...
    'Position',[7 77 84 20], ...
    'BackgroundColor',[0.85 0.85 0.85], ...
    'String','spawn', ...
    'CallBack',['modlplts(''spawn'',',as,');'], ...
    'TooltipString','create copy of original figure');
  g(14,1) =  uicontrol('Parent',h, ...
    'Position',[7 99 84 20], ...
    'BackgroundColor',[0.85 0.85 0.85], ...
    'String','lv info', ...
    'CallBack',['modlplt1(''lvinfo'',',as,');'], ...
    'TooltipString','click lv for detailed information');
  s = str2mat('none','rmsecv','rmsec','rmsecv/rmsec', ...
    'rmsecv(i)/rmsecv(i+1)');
  g(19,1) = uicontrol('Parent',h, ...
    'Style','popupmenu','String',s(2:end,:), ...
    'FontName','geneva','FontSize',10, ...
    'BackgroundColor',[1 1 1],'Value',1, ...
    'Position',[7 268 84 16]);
  g(20,1) = uicontrol('Parent',h, ...
    'Style','popupmenu','String',s, ...
    'FontName','geneva','FontSize',10, ...
    'BackgroundColor',[1 1 1],'Value',3, ...
    'Position',[7 224 84 16]);
%g(1:4) frames
%g(5:8) text
%g(9:11) push, zoom
%g(12:14) push
%g(19:20) popup

  set(g([1:14,19:20],1),'Interruptible','off', ...
    'BusyAction','cancel','Units','normalized')
  set(g(14,1),'Interruptible','on')
  set(h,'UserData',g)
  modlplt1('pressplotbutton',fighand)
  v     = axis;
  set(g(20,1),'UserData',v)
case 'lvinfo'
  g     = get(gcf,'UserData');
  set(g([1:14,19:20],1),'Enable','off')
  [x,y] = ginput(1);
  x     = round(x);
  y     = axis;
  if ishold
    h   = plot([x x],[y(3) y(4)],'-r');
  else
    hold on
    h   = plot([x x],[y(3) y(4)],'-r');
    hold off
  end
  s     = ['modlplt1(''infolinedel'',',as,')'];
  y     = get(gcf,'position');
  y     = figure('NumberTitle','off', ...
    'Name','LV Info','Color',[0 0 0],'Menu','none', ...
    'Position',[y(1)+35 y(2)-40 220 150], ...
    'UserData',h,'CloseRequestFcn',s,'Tag',int2str(gcf));
  z     = uicontrol('Parent',y,'BackgroundColor',[1 1 1], ...
    'Style','text','Position',[3 3 214 144], ...
    'FontName','geneva','FontSize',10, ...
    'HorizontalAlignment','left');
  set(z,'Units','normalized')
  modl  = get(f(2,1),'UserData');
  s     = ['Latent Variable ',int2str(x)];
  s2    = cell(size(modl.press,1),1);
  s3    = s2;
  s4    = s2;
  if size(modl.press,1)>1
    for ii=1:size(modl.press,1)
      s2{ii} = ['RMSECV(',int2str(ii),') = ',num2str(modl.rmsecv(ii,x))];
      s3{ii} = ['RMSEC(',int2str(ii),')  = ',num2str(modl.rmsec(ii,x))];
      s4{ii} = ['RMSECV/RMSEC(',int2str(ii),') = ', ...
        num2str(modl.rmsecv(ii,x)/modl.rmsec(ii,x))];
    end
  else
      s2 = ['RMSECV = ',num2str(modl.rmsecv(1,x))];
      s3 = ['RMSEC  = ',num2str(modl.rmsec(1,x))];
      s4 = ['RMSECV/RMSEC = ', ...
        num2str(modl.rmsecv(1,x)/modl.rmsec(1,x))];
  end
  s2    = char(s2);
  s3    = char(s3);
  s4    = char(s4);
  set(z,'String',str2mat(s,' ',s2,s3,s4))
  set(g([1:14 19:20],1),'Enable','on')
case 'infolinedel'
  h     = findobj('Name','PRESS','Tag',as);
  if h
    h   = get(gcf,'UserData');
  end
  if ishandle(h)
    delete(h)
    closereq
  else
    closereq
  end
case 'pressplotbutton'
  g     = get(gcf,'UserData');
  modl  = get(f(2,1),'UserData');
  n     = size(modl.press,2); %number of latent variables
  switch get(g(19,1),'Value')
  case 1
    plot([1:n],modl.rmsecv,'o-')
    sx  = 'Latent Variable';
    sy  = 'RMSECV (o)';
    st  = 'RMSECV';
  case 2
    plot([1:n],modl.rmsec,'o-')
    sx  = 'Latent Variable';
    sy  = 'RMSEC (o)';
    st  = 'RMSEC';
  case 3
    plot([1:n],modl.rmsecv./modl.rmsec,'o-')
    sx  = 'Latent Variable';
    sy  = 'RMSECV/RMSEC (o)';
    st  = 'RMSECV/RMSEC';
  case 4
    plot([1:n-1],modl.rmsecv(:,1:n-1)./modl.rmsecv(:,2:n),'o-')
    sx  = 'Latent Variable (i)';
    sy  = 'RMSECV(i)/RMSECV(i+1) (o)';
    st  = 'RMSECV(i)/RMSECV(i+1)';
  end

  if size(modl.rmsecv,1)>1
    h1    = cell(size(modl.press,1),1);
    for jj=1:size(modl.rmsecv,1)
      h1{jj,1} = ['y',int2str(jj)];
    end
    legend(h1{:})
  end

  switch get(g(20,1),'Value')
  case 2
    hold on, plot([1:n],modl.rmsecv,'s-'), hold off
    sy  = [sy,' & RMSECV (s)'];
    st  = [st,' & RMSECV'];
  case 3
    hold on, plot([1:n],modl.rmsec,'s-'), hold off
    sy  = [sy,' & RMSEC (s)'];
    st  = [st,' & RMSEC'];
  case 4
    hold on, plot([1:n],modl.rmsecv./modl.rmsec,'s-'), hold off
    sx  = 'Latent Variable';
    sy  = [sy,' & RMSECV/RMSEC (s)'];
    st  = [st,' & RMSECV/RMSEC'];
  case 5
    hold on, plot([1:n-1],modl.rmsecv(:,1:n-1)./modl.rmsecv(:,2:n),'s-')
    hold off
    sx  = 'Latent Variable (i)';
    sy  = [sy,' & RMSECV(i)/RMSECV(i+1) (s)'];
    st  = [st,' & RMSECV(i)/RMSECV(i+1)'];
  end
  clear modl
  xlabel(sx)
  ylabel(sy)
  title([st,' vs. LV']);
  drawnow
  v     = axis;
  set(g(20,1),'UserData',v)
case 'closepress'
  h = findobj('Name','LV Info','Tag',int2str(gcf)); close(h)
  closereq
case 'biplot'
  h     = findobj('Name','Biplot','Tag',as);
  if isempty(h)
    h   = figure('Name','Biplot','NumberTitle','off', ...
      'Menu','none','Tag',as,'BusyAction','cancel', ...
      'CloseRequestFcn',['modlplt1(''closebiplt'',',as,')']);
  else
    figure(h), clf
  end
  set(h,'position',[p(1)-5 p(2)-30 380+94 285+46])
  
  n     = get(f(4,1),'UserData');
  g     = modlpset('plotopts2',h,n);
  s     = ['modlplt1(''plotbiplotbut'',',as,')'];
  set(g(3,1),'CallBack',s)
  
  s     = ['modlplts(''g3on'',',as,')'];
  for jj=4:2:10
    set(g(jj,1),'Callback',s);
  end

  if datstat
    if isempty(test.slbl)
      s  = str2mat('no label','numbers');
      s2 = 1;
    else
      s  = str2mat('no label','numbers','labels');
      s2 = 3;
    end
  else
    if isempty(modl.slbl)
      s  = str2mat('no label','numbers');
      s2 = 1;
    else
      s  = str2mat('no label','numbers','labels');
      s2 = 3;
    end
  end
  set(g(10,1),'String',s,'Value',s2)
  set(g(15,1),'CallBack',['modlplt1(''scrinfo'',',as,')'], ...
    'TooltipString','sample information');
  set(g(13,1),'CallBack',['modlplt1(''lodinfo'',',as,')'], ...
    'TooltipString','variable information');
  set(g(22,1),'CallBack',['modlplts(''spawn'',',as,')'], ...
    'TooltipString','create copy of present figure');
  modlplt1('plotbiplotbut',fighand)
case 'plotbiplotbut'
  if datstat
    scr = test.scores;
    if isempty(test.slbl)
      lbl = int2str([1:size(scr,1)]');
    else
      lbl = test.slbl;
    end
  else
    scr = modl.scores;
    if isempty(modl.slbl)
      lbl = int2str(modl.irow');
    else
      lbl = modl.slbl;
    end
  end
  for ii=1:size(scr,2)
    scr(:,ii) = scr(:,ii)/norm(scr(:,ii));
  end
  lod   = modl.loads;
  if isempty(modl.vlbl)
    vbl = int2str([1:size(lod,1)]');
  else
    vbl = modl.vlbl;
  end
  g     = get(gcf,'UserData');
  %x axis
  pc    = get(g(4,1),'Value');
  x     = scr(:,pc);
  x2    = lod(:,pc);
  sx    = sprintf('%5.2f',modl.ssq(pc,2));
  sx    = [' (',sx,'%)'];
  sx    = ['LV ',int2str(pc),sx];
  %y axis
  pc    = get(g(6,1),'Value');
  y     = scr(:,pc);
  y2    = lod(:,pc);
  sy    = sprintf('%5.2f',modl.ssq(pc,2));
  sy    = [' (',sy,'%)'];
  sy    = ['LV ',int2str(pc),sy];
  %z axis
  pc    = get(g(8,1),'Value');
  switch pc
  case 1 %none
    z   = [];
  otherwise
    pc  = pc-1;
    z   = scr(:,pc);
    z2  = lod(:,pc);
    sz  = sprintf('%5.2f',modl.ssq(pc,2));
    sz  = [' (',sz,'%)'];
    sz  = ['LV ',int2str(pc),sz];
  end

  if isempty(z)
    h     = findobj('Tag',['HighOrb',int2str(gcf)]);
    if h
      h   = get(h,'UserData');
      delete(h(:,1));
    end
    set(g(13:size(g,1),1),'Enable','on')

    %make 2D plot
    plot(x,y,'or'), hold on
    plot(x2,y2,'+b'), hold off
    set(g(20,1),'UserData',h) %set 1st axis for zoom
    s     = ' ';
    n     = length(modl.irow);
    n2    = length(modl.icol);
    v     = size(scr,1);
    if get(g(10,1),'Value')==2 %put numbers on
      if datstat
        s = [s(ones(v,1)),int2str([1:v]')];
      else
        s = [s(ones(n,1)),int2str((modl.irow)')];
      end
      s2  = [s(ones(n2,1)),int2str((modl.icol)')];
     elseif (get(g(10,1),'Value')==3)&~isempty(lbl)
      if datstat
        s = [s(ones(v,1)),lbl];
      else
        s = [s(ones(n,1)),lbl];
      end
      s2  = [s(ones(n2,1)),vbl];  
    end
    if get(g(10,1),'Value')>1
      text(x,y,s,'Fontname','geneva','Fontsize',10);
      text(x2,y2,s2,'Fontname','geneva','Fontsize',10);
    end

    h     = axis;
    if h(1)*h(2)<-0.000001
       vline(0);
    end
    if h(3)*h(4)<-0.000001
      hline(0)
    end
  else
    set(g(12:21,1),'Enable','off')
    plot3(x,y,z,'or'), hold on
    plot3(x2,y2,z2,'+b'), hold off
    s     = ' ';
    n     = length(modl.irow);
    n2    = length(modl.icol);
    v     = size(scr,1);
    if get(g(10,1),'Value')==2 %put numbers on
      if datstat
        s = [s(ones(v,1)),int2str([1:v]')];
      else
        s = [s(ones(n,1)),int2str((modl.irow)')];
      end
      s2  = [s(ones(n2,1)),int2str((modl.icol)')];
     elseif (get(g(10,1),'Value')==3)&~isempty(lbl)
      if datstat
        s = [s(ones(v,1)),lbl];
      else
        s = [s(ones(n,1)),lbl(modl.irow,:)];
      end
      s2  = [s(ones(n2,1)),vbl(modl.icol,:)];  
    end
    if get(g(10,1),'Value')>1
      text(x,y,z,s,'Fontname','geneva','Fontsize',10);
      text(x2,y2,z2,s2,'Fontname','geneva','Fontsize',10);
    end

    drop  = 1;
    if drop==1
      h   = axis; axis(h)
      if ishold
        for jj=1:length(z)
          plot3([1 1]*x(jj),[1 1]*y(jj),[h(5) z(jj)],'-g')
        end
        for jj=1:length(z2)
          plot3([1 1]*x2(jj),[1 1]*y2(jj),[h(5) z2(jj)],'-c')
        end
      else
        hold on
        for jj=1:length(z)
          plot3([1 1]*x(jj),[1 1]*y(jj),[h(5) z(jj)],'-g')
        end
        for jj=1:length(z2)
          plot3([1 1]*x2(jj),[1 1]*y2(jj),[h(5) z2(jj)],'-c')
        end 
        hold off
      end
    end
    grid on
    highorb
  end
  xlabel(sx)
  ylabel(sy)
  title('Biplot: (o) normalized scores, (+) loads')
  if z
    zlabel(sz)
  end
  v     = axis;
  set(g(20,1),'UserData',v)
  set(g(3,1),'Enable','off')
case 'scrinfo'
  g      = get(gcf,'UserData');
  set(g(1:size(g,1),1),'Enable','off')
  z      = get(gca,'children');
  x      = get(z(length(z)),'xdata');
  y      = get(z(length(z)),'ydata');
  jj     = sampidr(x,y);
  if ishold
    h    = plot(x(jj),y(jj),'db','MarkerSize',10);
  else
    hold on
    h    = plot(x(jj),y(jj),'db','MarkerSize',10);
    hold off
  end
  s      = ['modlplt1(''scrmarkdel'',',as,')'];
  z      = get(gcf,'position');
  y      = figure('NumberTitle','off', ...
    'Name','Sample Info','Color',[0 0 0],'Menu','none', ...
    'Position',[z(1)+35 z(2)-40 220 150],'Tag',int2str(gcf), ...
    'UserData',h,'CloseRequestFcn',s);
  x      = uicontrol('Parent',y,'BackgroundColor',[1 1 1], ...
    'Style','text','Position',[3 3 214 144], ...
    'FontName','geneva','FontSize',10, ...
    'HorizontalAlignment','left');
  set(x,'Units','normalized')
  if datstat
    if isempty(test.slbl)
      s  = ' ';
    else
      s  = test.slbl(jj,:);
    end
    y    = ['Q Residual    = ',num2str(test.res(jj))];
    z    = ['Hotelling T^2 = ',num2str(test.tsq(jj))];
  else
    if isempty(modl.slbl)
      s  = ' ';
    else
      s  = modl.slbl(jj,:);
    end
    y    = ['Q Residual    = ',num2str(modl.res(jj))];
    z    = ['Hotelling T^2 = ',num2str(modl.tsq(jj))];
    jj   = modl.irow(1,jj);
  end
  if ~get(g(13,1),'value')
    y2     = [' (95% limit   = ',num2str(modl.reslim),')'];
    z2     = [' (95% limit   = ',num2str(modl.tsqlim),')'];
  else
    s2     = get(g(12,1),'string');
    s3     = str2num(s2);
    m      = size(modl.loads,2);
    nx     = length(modl.icol);
    mx     = length(modl.irow);
    if m<nx
      df   = (mx-1)*nx-m*max([mx,nx]');
      s4   = sum(modl.res)/mx*ftest((100-s3)/100,df/mx,df);
    else
      s4   = 0;
    end
    s3     = tsqlim(mx,m,s3);
    y2     = [' (',s2,'% limit   = ',num2str(s4),')'];
    z2     = [' (',s2,'% limit   = ',num2str(s3),')']; 
  end
  z      = str2mat(['Sample ',int2str(jj)],s,y,y2,z,z2);
  set(x,'String',z)
  set(g(1:size(g,1),1),'Enable','on')
case 'lodinfo'
  g      = get(gcf,'UserData');
  set(g(1:size(g,1),1),'Enable','off')
  z      = get(gca,'children');
  x      = get(z(length(z)-1),'xdata');
  y      = get(z(length(z)-1),'ydata');
  jj     = sampidr(x,y);
  if ishold
    h    = plot(x(jj),y(jj),'sr','MarkerSize',10);
  else
    hold on
    h    = plot(x(jj),y(jj),'sr','MarkerSize',10);
    hold off
  end
  s      = ['modlplt1(''scrmarkdel'',',as,')'];
  z      = get(gcf,'position');
  y      = figure('NumberTitle','off', ...
    'Name','Variable Info','Color',[0 0 0], ...
    'Position',[z(1)+55 z(2)-40 220 150], ...
    'Menu','none','Tag',int2str(gcf), ...
    'UserData',h,'CloseRequestFcn',s);
  x = uicontrol('Parent',y,'BackgroundColor',[1 1 1], ...
    'Style','text','Position',[3 3 214 144], ...
    'FontName','geneva','FontSize',10, ...
    'HorizontalAlignment','left');
  set(x,'Units','normalized')
  if isempty(modl.vlbl)
    s    = ' ';
  else
    s    = modl.vlbl(jj,:);
  end
  jj     = modl.icol(1,jj);
  z = str2mat(['Variable ',int2str(jj)],s);
  y      = get(f(1,1),'UserData');
  y      = y(:,jj);
  s1     = sprintf('mean = %g',mean(y));
  s2     = sprintf('std  = %g',std(y));
  z = str2mat(z,s1,s2); 
  set(x,'String',z)
  set(g(1:size(g,1),1),'Enable','on')
case 'scrmarkdel'
  h      = findobj('Name','Biplot','Tag',as);
  if h
    h    = get(gcf,'UserData');
  end
  if ishandle(h)
    delete(h)
    closereq
  else
    closereq
  end
case 'rawplot'
  h     = findobj('Name','Plot Data','Tag',as);
  if isempty(h)
    h   = figure('Name','Plot Data','NumberTitle','off', ...
      'Tag',as,'Menu','none');
  else
    figure(h), clf
  end
  set(h,'position',[p(1)+10 p(2)-40 380+94 285+46])
  n     = get(f(4,1),'UserData');
  g     = modlpset('plotopts3',h,n);
  [mx,nx] = size(get(f(1,1),'UserData'));
  s     = [int2str(mx),' by ',int2str(nx)];
  set(g(2,1),'String',s)
  s     = ['modlplt1(''rawplotbutton'',',as,')'];
  set(g(3,1),'CallBack',s,'TooltipString', ...
    'plot with current settings')
  s     = ['modlplts(''g3on'',',as,')'];
  for jj=4:2:10
    set(g(jj,1),'Callback',s);
  end
  modlplt1('rawplotbutton',fighand)
  set(g(22,1),'CallBack',['modlplts(''spawn'',',as,')'], ...
    'TooltipString','create copy of present figure')
case 'rawplotbutton'
  dat     = get(f(1,1),'UserData');
  [mx,nx] = size(dat);
  datstata = strcmp(stat.data,'new')|strcmp(stat.data,'test');
  if datstata
    sax   = [1:mx];
    vax   = [1:nx];
  %--the following will be used to put labels on
  %if datstata
  %  if isempty(test.slbl)
  %    lbl = int2str([1:mx]');
  %  else
  %    lbl = test.slbl;
  %  end
  %else
  %  if isempty(modl.slbl)
  %    lbl = int2str([1:size(scr,1)]');
  %  else
  %    lbl = modl.slbl;
  %  end
  %end
  %if isempty(modl.vlbl)
  %  vbl = int2str([1:size(lod,1)]');
  %else
  %  vbl = modl.vlbl;
  %end
  else
    if isempty(modl.sscl)
      sax = [1:mx];
    else
      sax = modl.sscl;
    end
    if isempty(modl.vscl)
      vax = [1:nx];
    else
      vax = modl.vscl;
    end
  end
  %---labelling
  g     = get(gcf,'UserData');
  %x & y axes
  xax   = get(g(4,1),'Value');
  yax   = get(g(6,1),'Value');
  switch xax
  case 1
    if datstata
      x = sax;
    else
      x = sax(modl.irow);
    end
    sx  = 'Sample';
    st  = 'Variable Value versus Sample';
    c2  = '+';
    tc  = mx;
    switch yax
    case 1
      if datstata
        y = dat';
      else
        y = dat(modl.irow,modl.icol)';
      end
      sy= 'Value of Variable';
    case 2
      if datstata
        y = mean(dat');
      else
        y = mean(dat(modl.irow,modl.icol)');
      end
      sy= 'Mean of Variables';
    case 3
      if datstata
        y = std(dat');
      else
        y = std(dat(modl.irow,modl.icol)');
      end
      sy= 'Standard Deviation of Variables';
    end
  case 2
    if datstata
      x = vax;
    else
      x = vax(modl.icol);
    end
    sx  = 'Variable';
    st  = 'Sample Values versus Variable';
    c2  = 'o';
    tc  = nx;
    switch yax
    case 1
      if datstata
        y = dat;
      else
        y = dat(modl.irow,modl.icol);
      end
      sy= 'Value of Sample';
    case 2
      if datstata
        y = mean(dat);
      else
        y = mean(dat(modl.irow,modl.icol));
      end
      sy= 'Mean of Samples';
    case 3
      if datstata
        y = std(dat);
      else
        y = std(dat(modl.irow,modl.icol));
      end
      sy= 'Standard Deviation of Samples';
    end
  end

  h     = findobj('Tag',['HighOrb',int2str(gcf)]);
  if h
    h   = get(h,'UserData');
    delete(h(:,1));
  end
  set(g(13:size(g,1),1),'Enable','on')

  %make 2D plot
  plot(x,y)
  if tc<25
    if ishold
      plot(x,y,c2)
    else
      hold on, plot(x,y,c2), hold off
    end
  end
  set(g(20,1),'UserData',h) %set 1st axis for zoom

  h     = axis;
  if h(1)*h(2)<-0.000001
    vline(0);
  end
  if h(3)*h(4)<-0.000001
    hline(0)
  end
  xlabel(sx)
  ylabel(sy)
  title(st)
  v     = axis;
  set(g(20,1),'UserData',v)
  set(g(3,1),'Enable','off')
end
