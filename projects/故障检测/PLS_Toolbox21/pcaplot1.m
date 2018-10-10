function pcaplot1(action,fighand)
%PCAPLOT1 called by PCAGUI
%
%See instead: PCAGUI

%Copyright Eigenvector Research, Inc. 1997-8
%nbg 4/4/97,6/97,7/97,10/98

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
  if strcmp(modl.name,'PCA')
    h     = findobj('Name','Eigenvalues','Tag',as); close(h)
    h     = figure('Name','Eigenvalues','Menubar','none', ...
      'NumberTitle','off','Tag',as,'BusyAction','cancel');
    set(h,'position',[p(1)-50 p(2) 400 305])
    modl  = get(f(2,1),'UserData');
    v     = modl.ssq(:,2); clear modl
    n     = length(v);
    plot([1:n],v,'-r',[1:n],v,'ob')
    xlabel('Principal Component')
    ylabel('Eigenvalue')
    title('Eigenvalue vs. Principal Component')
  else
    h     = findobj('Name','Press','Tag',as); close(h)
    h     = figure('Name','Press','Menubar','none', ...
      'NumberTitle','off','Tag',as,'BusyAction','cancel');
    set(h,'position',[p(1)-50 p(2) 400 305])
    modl  = get(f(2,1),'UserData');
    v     = modl.press; clear modl
    n     = length(v);
    plot([1:n],v,'-r',[1:n],v,'ob')
    xlabel('Latent Variable')
    ylabel('PRESS')
    title('PRESS vs. Latent Variable')
  end
  drawnow
  zoompls
case 'biplot'
  h     = findobj('Name','Biplot','Tag',as);
  if isempty(h)
    h   = figure('Name','Biplot','NumberTitle','off', ...
      'Menu','none','Tag',as,'BusyAction','cancel', ...
      'CloseRequestFcn',['pcaplot1(''closebiplt'',',as,')']);
  else
    figure(h), clf
  end
  set(h,'position',[p(1)-5 p(2)-30 380+94 285+46])
  
  n     = get(f(4,1),'UserData');
  g     = pcapset('plotopts2',h,n);
  s     = ['pcaplot1(''plotbiplotbut'',',as,')'];
  set(g(3,1),'CallBack',s, ...
    'TooltipString','plot with current settings')
  s     = ['pcaplots(''g3on'',',as,')'];
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
  set(g(15,1),'CallBack',['pcaplot1(''scrinfo'',',as,')'], ...
    'TooltipString','sample information');
  set(g(13,1),'CallBack',['pcaplot1(''lodinfo'',',as,')'], ...
    'TooltipString','variable information');
  set(g(22,1),'CallBack',['pcaplots(''spawn'',',as,')'], ...
    'TooltipString','create copy of present figure');
  pcaplot1('plotbiplotbut',fighand)
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
      lbl = int2str([1:size(scr,1)]');
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
  if strcmp(modl.name,'PCA')
    sx    = sprintf('%5.2f',modl.ssq(pc,3));
    sx    = [' (',sx,'%)'];
    sx    = ['PC ',int2str(pc),sx];
  else
    sx    = sprintf('%5.2f',modl.ssq(pc,1));
    sx    = [' (',sx,'%)'];
    sx    = ['LV ',int2str(pc),sx];
  end
  %y axis
  pc    = get(g(6,1),'Value');
  y     = scr(:,pc);
  y2    = lod(:,pc);
  if strcmp(modl.name,'PCA')
    sy    = sprintf('%5.2f',modl.ssq(pc,3));
    sy    = [' (',sy,'%)'];
    sy    = ['PC ',int2str(pc),sy];
  else
    sy    = sprintf('%5.2f',modl.ssq(pc,1));
    sy    = [' (',sy,'%)'];
    sy    = ['LV ',int2str(pc),sy];
  end
  %z axis
  pc    = get(g(8,1),'Value');
  switch pc
  case 1 %none
    z   = [];
  otherwise
    pc  = pc-1;
    z   = scr(:,pc);
    z2  = lod(:,pc);
    if strcmp(modl.name,'PCA')
      sz  = sprintf('%5.2f',modl.ssq(pc,3));
      sz  = [' (',sz,'%)'];
      sz  = ['PC ',int2str(pc),sz];
    else
      sz  = sprintf('%5.2f',modl.ssq(pc,1));
      sz  = [' (',sz,'%)'];
      sz  = ['LV ',int2str(pc),sz];
    end
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
  s      = ['pcaplot1(''scrmarkdel'',',as,')'];
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
    s4     = reslim(get(f(4,1),'UserData'),modl.ssq(:,2),s3);
    s3     = tsqlim(length(modl.irow),get(f(4,1),'UserData'),s3);
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
  s      = ['pcaplot1(''scrmarkdel'',',as,')'];
  z      = get(gcf,'position');
  y      = figure('NumberTitle','off', ...
    'Name','Variable Info','Color',[0 0 0], ...
    'Position',[z(1)+55 z(2)-40 220 150], ...
    'Menu','none','Tag',int2str(gcf), ...
    'UserData',h,'CloseRequestFcn',s);
  x = uicontrol('Parent',y,'BackgroundColor',[1 1 1], ...
    'Style','text','Position',[3 3 214 144], ...
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
  g     = pcapset('plotopts3',h,n);

  [mx,nx] = size(get(f(1,1),'UserData'));
  s     = [int2str(mx),' by ',int2str(nx)];
  set(g(2,1),'String',s)
  s     = ['pcaplot1(''rawplotbutton'',',as,')'];
  set(g(3,1),'CallBack',s, ...
    'TooltipString','plot with current settings')
  
  s     = ['pcaplots(''g3on'',',as,')'];
  for jj=4:2:10
    set(g(jj,1),'Callback',s);
  end
  set(g(22,1),'CallBack',['pcaplots(''spawn'',',as,')'], ...
    'TooltipString','create copy of present figure');
  pcaplot1('rawplotbutton',fighand)
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
