function pcaplots(action,fighand)
%PCAPLOTS - Called by PCAGUI
%
%See instead: PCAGUI

%Copyright Eigenvector Research, Inc. 1997-2000
%nbg 4/96,6/97,7/97,12/97,9/98,10/98,2/00
%nbg 3/00 (fixed labels for 2d), 11/00 (fixed labels for 3d)
%         (fixed varcap call)

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
case 'spawn'
  g     = get(gcf,'UserData');
  if isempty(get(get(g(1,1),'userdata'),'ztick'))
    copyobj(get(g(1,1),'UserData'),figure);
  else  
    [az,el] = view;
    copyobj(get(g(1,1),'UserData'),figure);
    view(az,el);
  end
  set(gca,'position',[0.13 0.11 0.775 0.815]);
case 'closescrs'
  h = findobj('Name','Sample Info','Tag',int2str(gcf)); close(h)
  h = findobj('Name','Q Residual Contributions','Tag',int2str(gcf));
  close(h)
  h = findobj('Name','Hotelling T^2 Contributions','Tag',int2str(gcf));
  close(h)
  h = findobj('Name','Plot of Raw Data','Tag',int2str(gcf)); close(h)
  closereq
case 'closelods'
  h = findobj('Name','Variable Info','Tag',int2str(gcf)); close(h)
  h = findobj('Name','Plot of Raw Data','Tag',int2str(gcf)); close(h)
  closereq
case 'plotscores'
  h     = findobj('Name','Plot Scores','Tag',as); close(h)
  h     = figure('Name','Plot Scores','NumberTitle','off', ...
    'Tag',as,'Menu','none','BusyAction','cancel', ...
    'CloseRequestFcn',['pcaplots(''closescrs'',',as,')']);
  set(h,'position',[p(1)-35 p(2)-10 380+94 285+46])
  n     = get(f(4,1),'UserData');
  g     = pcapset('plotopts1',h,n);
  ai    = num2str(get(g(1,1),'UserData'));
  s     = ['pcaplots(''plotscoresbut'',',as,')'];
  set(g(3,1),'CallBack',s, ...
    'TooltipString','plot with current settings')
  s     = ['pcaplots(''g3on'',',as,')'];
  set(g([4:2:10],1),'Callback',s);
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
  set(g(13,1),'Callback', ...
    ['pcaplots(''limitchk'',',as,')']);
  set(g(17,1),'String','data','CallBack', ...
    ['pcaplots(''scrraw'',',as,')'], ...
    'TooltipString','plot raw data for a sample')
  set(g(18,1),'String','delete','CallBack', ...
    ['pcaplots(''scrdel'',',as,')'], ...
    'TooltipString','delete samples')
  if datstat
    set(g(18,1),'Enable','off')
  end
  set(g(19,1),'String','Q con','CallBack', ...
    ['pcaplots(''scrqcon'',',as,')'], ...
    'TooltipString','Q residual contribution plot')
  set(g(20,1),'String','T con','CallBack', ...
    ['pcaplots(''scrtcon'',',as,')'], ...
    'TooltipString','T^2 contribution plot')
  set(g(21,1),'String','info','CallBack', ...
    ['pcaplots(''scrinfo'',',as,')'], ...
    'TooltipString','sample information')
  set(g(22,1),'String','samples')
  set(g(28,1),'String','spawn','CallBack', ...
    ['pcaplots(''spawn'',',as,')'], ...
    'TooltipString','create copy of present figure')
  pcaplots('plotscoresbut',fighand)
case 'plotloads'
  h     = findobj('Name','Plot Loads','Tag',as); close(h)
  h     = figure('Name','Plot Loads','NumberTitle','off',  ...
    'Tag',as,'Menu','none','BusyAction','cancel', ...
    'CloseRequestFcn',['pcaplots(''closelods'',',as,')']);
  set(h,'position',[p(1)-20 p(2)-20 380+94 285+46])
  n     = get(f(4,1),'UserData');
  g     = pcapset('plotopts1',h,n);
  ai    = num2str(get(g(1,1),'UserData'));
  s     = ['pcaplots(''plotloadsbut'',',as,')'];
  set(g(3,1),'CallBack',s, ...
    'TooltipString','plot with current settings')
  s     = 'PC ';
  s     = [s(ones(n,1),:),int2str([1:n]')];
  s1    = str2mat('variable',s);
  set(g(4,1),'String',s1,'Value',1) %set default x for loads
  set(g(6,1),'String',s1,'Value',2) %set default y for loads
  s     = str2mat('none',s);
  set(g(8,1),'String',s,'Value',1)
  s     = ['pcaplots(''g3on'',',as,')'];
  set(g([4:2:10],1),'Callback',s);

  s     = str2mat('no label','numbers');
  s2    = 1;
  if (~isempty(modl.vlbl))&(size(modl.vlbl,1)==size(modl.loads,1))
    s   = str2mat('no label','numbers','labels');
    s2  = 3;
  end
  set(g(10,1),'String',s,'Value',s2)
  set(g(12:14,1),'Visible','off')
  set(g(17,1),'String','data','CallBack', ...
    ['pcaplots(''lodraw'',',as,')'], ...
    'TooltipString','plot raw data for a variable')
  set(g(18,1),'String','delete','CallBack', ...
    ['pcaplots(''loddel'',',as,')'], ...
    'Visible','off')
  if datstat
    set(g(18,1),'Enable','off')
  end
  set(g(19,1),'String',' ','CallBack', ...
    ['pcaplots(''lodqcon'',',as,')'], ...
    'Visible','off')
  set(g(20,1),'String','','CallBack', ...
    ['pcaplots(''lodtcon'',',as,')'], ...
    'String','varcap', ...
    'Visible','on')
  set(g(21,1),'String','info','CallBack', ...
    ['pcaplots(''lodinfo'',',as,')'], ...
    'TooltipString','variable information')
  set(g(22,1),'String','variables')
  set(g(28,1),'String','spawn','CallBack', ...
    ['pcaplots(''spawn'',',as,')'], ...
    'TooltipString','copy of present figure')
  pcaplots('plotloadsbut',fighand)
case 'plotscoresbut'
  if datstat
    if isempty(test.sscl)
      n   = size(test.scores,1);
      sam = [1:n]';
    else
      sam = test.sscl';
    end
    res = test.res;
    tsq = test.tsq;
    scr = test.scores;
    lbl = test.slbl;
  else
    if isempty(modl.sscl)
      sam = modl.irow;
    else
      sam = modl.sscl(modl.irow);
    end
    res = modl.res;
    tsq = modl.tsq;
    scr = modl.scores;
    lbl = modl.slbl;
  end
  g     = get(gcf,'UserData');
  son   = 0;
  pc    = get(g(4,1),'Value');
  switch pc
  case 1 %sample
    x   = sam;
    sx  = 'Sample Number';
    son = 1;
  case 2 %Q
    x   = res;
    sx  = 'Q Residual';
  case 3 %T
    x   = tsq;
    sx  = 'Hotelling T^2';
  otherwise
    pc  = pc-3;
    x   = scr(:,pc);
    if strcmp(modl.name,'PCA')
      sx  = sprintf('%5.2f',modl.ssq(pc,3));
      sx  = [' (',sx,'%)'];
      sx  = ['PC ',int2str(pc),sx];
    else
      sx  = sprintf('%5.2f',modl.ssq(pc,1));
      sx  = [' (',sx,'%)'];
      sx  = ['LV ',int2str(pc),sx];
    end
  end
  pc    = get(g(6,1),'Value');
  switch pc
  case 1 %sample
    y   = sam;
    sy  = 'Sample Number';
    son = 1;
  case 2 %Q
    y   = res;
    sy  = 'Q Residual';
  case 3 %T
    y   = tsq;
    sy  = 'Hotelling T^2';
  otherwise
    pc  = pc-3;
    y   = scr(:,pc);
    if strcmp(modl.name,'PCA')
      sy  = sprintf('%5.2f',modl.ssq(pc,3));
      sy  = [' (',sy,'%)'];
      sy  = ['PC ',int2str(pc),sy];
    else
      sy  = sprintf('%5.2f',modl.ssq(pc,1));
      sy  = [' (',sy,'%)'];
      sy  = ['LV ',int2str(pc),sy];
    end
  end
  pc    = get(g(8,1),'Value');
  switch pc
  case 1 %none
    z   = [];
  case 2 %Q
    z   = res;
    sz  = 'Q Residual';
  case 3 %T
    z   = tsq;
    sz  = 'Hotelling T^2';
  otherwise
    pc  = pc-3;
    z   = scr(:,pc);
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
    set(g(16:size(g,1),1),'Enable','on')
    if datstat
      set(g(18,1),'Enable','off')
    end
    plot(x,y,'or')       %make 2D plot
    if son
      if ishold
        plot(x,y,'-g')
      else
        hold on, plot(x,y,'-g'), hold off
      end
    end
    set(g(20,1),'UserData',h) %set 1st axis for zoom
  
    if get(g(10,1),'Value')==2 %put numbers on
      s   = ' ';
      if datstat
        v = size(scr,1);
        s = [s(ones(v,1)),int2str([1:v]')];
      else
        n = length(modl.irow);
        s = [s(ones(n,1)),int2str((modl.irow)')];
      end
      text(x,y,s,'Fontname','geneva','Fontsize',10);
    elseif (get(g(10,1),'Value')==3)&~isempty(lbl)
      s   = ' ';
      if datstat
        v = size(scr,1);
        s = [s(ones(v,1)),lbl];
      else
        n = length(modl.irow);
        s = [s(ones(n,1)),lbl];
      end
      text(x,y,s,'Fontname','geneva','Fontsize',10);    
    end

    if get(g(13,1),'Value')         %put limit lines on
      modl = get(f(2,1),'UserData');
      lm1 = 0;
      lm2 = 0;
      if isempty(get(f(4,1),'UserData'))
        n = size(modl.scores,2);
      else
        n = get(f(4,1),'UserData'); %PCs kept
      end
      m   = length(modl.irow);      %number of samples
      pc  = get(g(4,1),'Value');    %x axis
      pc2 = get(g(6,1),'Value');    %y axis
      alp = str2num(get(g(12,1),'String'));
      alq = (100-alp)/200;
      h   = axis;

     if pc==1                      % x = sample lm1    
       if pc2==2                   % y = Q lm2
         h(3) = 0;
         lm2  = reslim(n,modl.ssq(:,2),alp);
         h1   = max([lm2; max(y)]);
         h(4) = 1.05*h1;
       elseif pc2==3               % y = T^2 lm2
         h(3) = 0;
         lm2  = tsqlim(m,n,alp);
         h1   = max([lm2; max(y)]);
         h(4) = 1.05*h1;
       elseif pc2>3                % y = pc2-3
         mn2  = mean(modl.scores(:,pc2-3));
         lm2  = sqrt(modl.ssq(pc2-3,2))*ttestp(alq,m-pc2+3,2);
         h0   = min([mn2-lm2; min(y)]);
         h1   = max([mn2+lm2; max(y)]);
         dh   = 0.05*(h1-h0);
         h(3) = h0-dh;
         h(4) = h1+dh;
       end
       axis(h)
       if pc2>3
         hline(mn2+lm2,'--g'), hline(mn2-lm2,'--g')
       else
         hline(lm2,'--g')
       end                         % end of x = sample

     elseif pc==2                  % x = Q lm1
       lm1    = reslim(n,modl.ssq(:,2),alp);
       h(1)   = 0;
       h1     = max([lm1; max(x)]);
       h(2)   = 1.05*h1;
       if pc2==2                   % y = Q lm2
         h(3) = 0;
         lm2  = lm1;
         h1   = max([lm2; max(y)]);
         h(4) = 1.05*h1;
       elseif pc2==3               % y = T^2 lm2
         h(3) = 0;
         lm2  = tsqlim(m,n,alp);
         h1   = max([lm2; max(y)]);
         h(4) = 1.05*h1;
       elseif pc2>3                % y = pc2-3
         mn2  = mean(modl.scores(:,pc2-3));
         lm2  = sqrt(modl.ssq(pc2-3,2))*ttestp(alq,m-pc2+3,2);
         h0   = min([mn2-lm2; min(y)]);
         h1   = max([mn2+lm2; max(y)]);
         dh   = 0.05*(h1-h0);
         h(3) = h0-dh;
         h(4) = h1+dh;
       end
       axis(h)
       vline(lm1,'--g')
       if pc2>3
         hline(mn2+lm2,'--g'), hline(mn2-lm2,'--g')
       else
         hline(lm2,'--g')
       end                         % end of x = Q

     elseif pc==3                  % x = T^2 lm1
       lm1    = tsqlim(m,n,alp);
       h(1)   = 0;
       h1     = max([lm1; max(x)]);
       h(2)   = 1.05*h1;
       if pc2==2                   % y = Q lm2
         h(3) = 0;
         lm2  = reslim(n,modl.ssq(:,2),alp);
         h1   = max([lm2; max(y)]);
         h(4) = 1.05*h1;
       elseif pc2==3               % y = T^2 lm2
         h(3) = 0;
         lm2  = lm1;
         h1   = max([lm2; max(y)]);
         h(4) = 1.05*h1;
       elseif pc2>3                % y = pc
         mn2  = mean(modl.scores(:,pc2-3));
         lm2  = sqrt(modl.ssq(pc2-3,2))*ttestp(alq,m-pc2+3,2);
         h0   = min([mn2-lm2; min(y)]);
         h1   = max([mn2+lm2; max(y)]);
         dh   = 0.05*(h1-h0);
         h(3) = h0-dh;
         h(4) = h1+dh;
       end
       axis(h)
       vline(lm1,'--g')
       if pc2>3
         hline(mn2+lm2,'--g'), hline(mn2-lm2,'--g')
       else
         hline(lm2,'--g')
       end                         % end of x = T^2

     elseif pc>3                   % x = pc-3 lm1
      mn1    = mean(modl.scores(:,pc-3));
      lm1    = sqrt(modl.ssq(pc-3,2))*ttestp(alq,m-pc+3,2);
      h0     = min([mn1-lm1; min(x)]);
      h1     = max([mn1+lm1; max(x)]);
      dh     = 0.05*(h1-h0);
      h(1)   = h0-dh;
      h(2)   = h1+dh;
      if pc2==2                   % Q
        h(3) = 0;
        lm2  = reslim(n,modl.ssq(:,2),alp);
        h1   = max([lm2; max(y)]);
        h(4) = 1.05*h1;
      elseif pc2==3               % T
        h(3) = 0;
        lm2  = tsqlim(m,n,alp);
        h1   = max([lm2; max(y)]);
        h(4) = 1.05*h1;
      elseif pc2>3
        mn2  = mean(modl.scores(:,pc2-3));
        lm2  = sqrt(modl.ssq(pc2-3,2))*ttestp(alq,m-pc2+3,2);
        h0   = min([mn2-lm2; min(y)]);
        h1   = max([mn2+lm2; max(y)]);
        dh   = 0.05*(h1-h0);
        h(3) = h0-dh;
        h(4) = h1+dh;
      end
      axis(h)
      if pc2>3
        ellps([mn1 mn2],[lm1 lm2],'--g')
      else
        vline(mn1+lm1,'--g'), vline(mn1-lm1,'--g')
        hline(lm2,'--g')
      end                         % end of x = pc-3
    end
  end
  h     = axis;
  if h(1)*h(2)<-0.000001
     vline(0);
  end
  if h(3)*h(4)<-0.000001
    hline(0)
  end
else
  set(g(16:size(g,1)-1,1),'Enable','off')
  plot3(x,y,z,'or')
  s     = ' ';
  n     = length(modl.irow);
  v     = size(scr,1);
  if get(g(10,1),'Value')==2 %put numbers on
    if datstat
      s = [s(ones(v,1)),int2str([1:v]')];
    else
      s = [s(ones(n,1)),int2str((modl.irow)')];
    end
   elseif (get(g(10,1),'Value')==3)&~isempty(lbl)
    if datstat
      s = [s(ones(v,1)),lbl];
    else
      s = [s(ones(n,1)),lbl];
    end
  end
  if get(g(10,1),'Value')>1
    text(x,y,z,s,'Fontname','geneva','Fontsize',10);
  end

  drop  = 1;
  if drop==1
    h   = axis; axis(h)
    if ishold
      for jj=1:length(z)
        plot3([1 1]*x(jj),[1 1]*y(jj),[h(5) z(jj)],'-g')
      end
    else
      hold on
      for jj=1:length(z)
        plot3([1 1]*x(jj),[1 1]*y(jj),[h(5) z(jj)],'-g')
      end    
      hold off
    end
  end
  grid on
  %highorb
  end
  xlabel(sx)
  ylabel(sy)
  title('Scores Plot')
  if z
    zlabel(sz)
  end
  v     = axis;
  set(g(20,1),'UserData',v)
  set(g(3,1),'Enable','off')
case 'plotloadsbut'
  if isempty(modl.vscl)
    var = modl.icol';
  else
    var = modl.vscl(modl.icol);
  end
  g     = get(gcf,'UserData');
  pc    = get(g(4,1),'Value');
  son   = 0;
  switch pc
  case 1 %variable
    x   = var;
    sx  = 'Variable Number';
    son = 1;
  otherwise
    x   = modl.loads(:,pc-1);
    if strcmp(modl.name,'PCA')
      sx  = sprintf('%5.2f',modl.ssq(pc-1,3));
      sx  = [' (',sx,'%)'];
      sx  = ['PC ',int2str(pc-1),sx];
    else
      sx  = sprintf('%5.2f',modl.ssq(pc-1,1));
      sx  = [' (',sx,'%)'];
      sx  = ['LV ',int2str(pc-1),sx];
    end
  end
  pc    = get(g(6,1),'Value');
  switch pc
  case 1 %variable
    y   = var;
    sy  = 'Variable Number';
    son = 1;
  otherwise
    y   = modl.loads(:,pc-1);
    if strcmp(modl.name,'PCA')
      sy  = sprintf('%5.2f',modl.ssq(pc-1,3));
      sy  = [' (',sy,'%)'];
      sy  = ['PC ',int2str(pc-1),sy];
    else
      sy  = sprintf('%5.2f',modl.ssq(pc-1,1));
      sy  = [' (',sy,'%)'];
      sy  = ['LV ',int2str(pc-1),sy];
    end
  end
  pc    = get(g(8,1),'Value');
  switch pc
  case 1 %none
    z   = [];
  otherwise
    z   = modl.loads(:,pc-1);
    if strcmp(modl.name,'PCA')
      sz  = sprintf('%5.2f',modl.ssq(pc-1,3));
      sz  = [' (',sz,'%)'];
      sz  = ['PC ',int2str(pc-1),sz];
    else
      sz  = sprintf('%5.2f',modl.ssq(pc-1,1));
      sz  = [' (',sz,'%)'];
      sz  = ['LV ',int2str(pc-1),sz];
    end
  end 

  if isempty(z)
    h     = findobj('Tag',['HighOrb',int2str(gcf)]);
    if h
      h   = get(h,'UserData');
      delete(h(:,1));
    end
    set(g(12:size(g,1),1),'Enable','on')
    if datstat
      set(g(18,1),'Enable','off')
    end
    plot(x,y,'+b')
    if son
      if ishold
        plot(x,y,'-g')
      else
        hold on, plot(x,y,'-g'), hold off
      end
    end
    h     = axis;
    if h(1)*h(2)<-0.000001
      vline(0);
    end
    if h(3)*h(4)<-0.000001
      hline(0)
    end
    s       = ' ';
    n       = length(modl.icol);
    if get(g(10,1),'Value')==2 %put numbers on
      s     = [s(ones(n,1)),int2str((modl.icol)')];
    elseif (get(g(10,1),'Value')==3)&~isempty(modl.vlbl)
      s     = [s(ones(n,1)),modl.vlbl(modl.icol,:)];
    end
    if get(g(10,1),'Value')>1
      text(x,y,s,'Fontname','geneva','Fontsize',10);
    end
    set(g(20,1),'UserData',h) %set 1st axis for zoom
  else
    set(g(12:size(g,1)-1,1),'Enable','off')
    plot3(x,y,z,'+b')
    s       = ' ';
    n       = length(modl.icol);
    if get(g(10,1),'Value')==2 %put numbers on
      s     = [s(ones(n,1)),int2str((modl.icol)')];
    elseif (get(g(10,1),'Value')==3)&~isempty(modl.vlbl)
      s     = [s(ones(n,1)),modl.vlbl(modl.icol,:)];    
    end
    if get(g(10,1),'Value')>1
      text(x,y,z,s,'Fontname','geneva','Fontsize',10);
    end

    drop  = 1;
    if drop==1
      h   = axis; axis(h)
      if ishold
        for jj=1:length(z)
          plot3([1 1]*x(jj),[1 1]*y(jj),[h(5) z(jj)],'-c')
        end
      else
        hold on
        for jj=1:length(z)
          plot3([1 1]*x(jj),[1 1]*y(jj),[h(5) z(jj)],'-c')
        end    
        hold off
      end
    end
    grid on
    %highorb
  end
  xlabel(sx)
  ylabel(sy)
  title('Loads Plot')
  if z
    zlabel(sz)
  end
  v     = axis;
  set(g(20,1),'UserData',v)
  set(g(3,1),'Enable','off')
case 'scrraw'
  g      = get(gcf,'UserData');
  set(g(1:size(g,1),1),'Enable','off')
  z      = get(gca,'children');
  x      = get(z(length(z)),'xdata');
  y      = get(z(length(z)),'ydata');
  jj     = sampidr(x,y);
  if ishold
    h    = plot(x(jj),y(jj),'xb','MarkerSize',10);
  else
    hold on
    h    = plot(x(jj),y(jj),'xb','MarkerSize',10);
    hold off
  end
  s      = ['pcaplots(''scrmarkdel'',',as,')'];
  z      = get(gcf,'position');
  y      = figure('NumberTitle','off', ...
    'Name','Plot of Raw Data','Menu','none', ...
    'Position',[z(1) z(2)-10 380 285], ...
    'UserData',h,'CloseRequestFcn',s,'Tag',int2str(gcf));
  x      = get(f(1,1),'UserData');
  x      = x(modl.irow(1,jj),:);
  plot([1:length(x)],x,'+b',[1:length(x)],x,'-c')
  xlabel('Variable Number')
  ylabel('Measured Value')
  title(['Raw Data for Sample ',int2str(modl.irow(1,jj))])
  h      = axis;
  if h(1)*h(2)<-0.000001
    vline(0);
  end
  if h(3)*h(4)<-0.000001
    hline(0)
  end
  zoompls
  set(g(1:size(g,1),1),'Enable','on')
  if datstat
    set(g(18,1),'Enable','off')
  end
case 'lodraw'
  g      = get(gcf,'UserData');
  set(g(1:size(g,1),1),'Enable','off')
  z      = get(gca,'children');
  x      = get(z(length(z)),'xdata');
  y      = get(z(length(z)),'ydata');
  jj     = sampidr(x,y);
  if ishold
    h    = plot(x(jj),y(jj),'xb','MarkerSize',10);
  else
    hold on
    h    = plot(x(jj),y(jj),'xb','MarkerSize',10);
    hold off
  end
  s      = ['pcaplots(''lodmarkdel'',',as,')'];
  z      = get(gcf,'position');
  y      = figure('NumberTitle','off', ...
    'Name','Plot of Raw Data','Menu','none', ...
    'Position',[z(1) z(2)-10 380 285], ...
    'UserData',h,'CloseRequestFcn',s,'Tag',int2str(gcf));
  x      = get(f(1,1),'UserData');
  x      = x(:,jj);
  plot([1:length(x)],x,'+b',[1:length(x)],x,'-c')
  xlabel('Sample Number')
  ylabel('Measured Value')
  title(['Raw Data for Variable ',int2str(jj)])
  h     = axis;
  if h(1)*h(2)<-0.000001
    vline(0);
  end
  if h(3)*h(4)<-0.000001
    hline(0)
  end
  zoompls
  set(g(1:size(g,1),1),'Enable','on')
  if datstat
    set(g(18,1),'Enable','off')
  end
case 'scrdel'
  g      = get(findobj('Name','Plot Scores','Tag',as),'UserData');
  set(g(1:size(g,1),1),'Enable','off')
  z      = get(gca,'children');
  z      = z(length(z));
  x      = get(z,'xdata');
  y      = get(z,'ydata');
  jj     = sampidr(x,y);     %indice in plot
  if ishold
    h    = plot(x(jj),y(jj),'*k','MarkerSize',10);
  else
    hold on
    h    = plot(x(jj),y(jj),'*k','MarkerSize',10);
    hold off
  end
  cndlgpls(modl.irow(1,jj),g(18,1),'sample')
  if strcmp(get(g(18,1),'Userdata'),'yes')
    jk          = modl.irow(1,jj);
    modl.irow   = delsamps(modl.irow',jj)';
    modl.scores = delsamps(modl.scores,jj);
    modl.tsq    = delsamps(modl.tsq,jj);
    modl.res    = delsamps(modl.res,jj);
    modl.slbl   = delsamps(modl.slbl,jj);
    if size(x,2)>size(x,1)
      set(z,'xdata',delsamps(x',jj)','ydata',delsamps(y',jj)')
    else
      set(z,'xdata',delsamps(x,jj),'ydata',delsamps(y,jj))
    end
    if ~isempty(modl.drow)
      if isempty(find(modl.drow==jk))
        modl.drow = [modl.drow, jk];
        stat.modl = 'none';
        set(b(1,1),'UserData',stat)
        pcagui('nothing',fighand)
      end
    else
      modl.drow = jk;
      stat.modl = 'none';
      set(b(1,1),'UserData',stat)
      pcagui('nothing',fighand)
    end
  else
    delete(h)
  end
  set(g(1:size(g,1),1),'Enable','on')
  if datstat
    set(g(18,1),'Enable','off')
  end
case 'scrqcon'
  g      = get(gcf,'UserData');
  set(g(1:size(g,1),1),'Enable','off')
  z      = get(gca,'children');
  x      = get(z(length(z)),'xdata');
  y      = get(z(length(z)),'ydata');
  jj     = sampidr(x,y);
  if ishold
    h    = plot(x(jj),y(jj),'sb','MarkerSize',10);
  else
    hold on
    h    = plot(x(jj),y(jj),'sb','MarkerSize',10);
    hold off
  end
  s      = ['pcaplots(''scrmarkdel'',',as,')'];
  z      = get(gcf,'position');
  y      = figure('NumberTitle','off', ...
    'Name','Q Residual Contributions','Menu','none', ...
    'Position',[z(1)+5 z(2)-15 380 285], ...
    'UserData',h,'CloseRequestFcn',s,'Tag',int2str(gcf));
  x      = get(f(1,1),'UserData'); %raw
  x      = x(modl.irow(jj),:);
  z      = get(f(2,1),'UserData'); %modl
  switch z.scale
  case 'auto'
    x    = scale(x,z.means,z.stds);
  case 'mean'
    x    = scale(x,z.means);
  end
  z      = z.loads;
  [x,z]  = resmtx(x,z);
  bar([1:length(x)],x,'b')
  xlabel('Variable Number')
  ylabel('Q Residual Contribution')
  if ~datstat
    jj   = modl.irow(1,jj);
  end
  title(['Sample ',int2str(jj),' Q Residual = ',num2str(z)])
  if modl.vlbl
    y    = find(x<0);
    z    = axis;
    z2   = z(4)-max(x);
    z2   = min([z2 z(4)]');
    z3   = size(modl.vlbl,2)*0.04*(z(4)-z(3));
    if z3>z2
      z(4) = z3-z2+z(4);
      axis(z)
    end
    x(y) = zeros(1,length(y));
    x    = x+0.01*z(4)*ones(1,length(x));
    text([1:length(x)],x,modl.vlbl,'rotation',90);
  end
  hline(0)
  zoompls
  set(g(1:size(g,1),1),'Enable','on')
  if datstat
    set(g(18,1),'Enable','off')
  end
case 'lodtcon' %varcap
  x      = get(f(1,1),'UserData'); %raw data
  x      = x(modl.irow,modl.icol);
  switch modl.scale
  case 'auto'
    x    = scale(x,modl.means,modl.stds);
  case 'mean'
    x    = scale(x,modl.means);
  end
  figure
  if isempty(modl.vlbl)
    varcap(x,modl.loads);
  else
    varcap(x,modl.loads,[],modl.vlbl);
  end
case 'scrtcon'
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
  s      = ['pcaplots(''scrmarkdel'',',as,')'];
  z      = get(gcf,'position');
  y      = figure('NumberTitle','off', ...
    'Name','Hotelling T^2 Contributions','Menu','none', ...
    'Position',[z(1)+5 z(2)-15 380 285], ...
    'UserData',h,'CloseRequestFcn',s,'Tag',int2str(gcf));
  x      = get(f(1,1),'UserData'); %raw
  x      = x(modl.irow(jj),:);
  z      = get(f(2,1),'UserData'); %modl
  switch z.scale
  case 'auto'
    x    = scale(x,z.means,z.stds);
  case 'mean'
    x    = scale(x,z.means);
  end
  y      = z.ssq;
  z      = z.loads;
  [x,z]  = tsqmtx(x,z,y);
  bar([1:length(x)],x,'b')
  xlabel('Variable Number')
  ylabel('Hotelling T^2 Contribution')
  if ~datstat
    jj   = modl.irow(1,jj);
  end
  title(['Sample ',int2str(jj),' Hotelling T^2 = ',num2str(z)])
  if modl.vlbl
    y    = find(x<0);
    z    = axis;
    z2   = z(4)-max(x);
    z2   = min([z2 z(4)]');
    z3   = size(modl.vlbl,2)*0.04*(z(4)-z(3));
    if z3>z2
      z(4) = z3-z2+z(4);
      axis(z)
    end
    x(y) = zeros(1,length(y));
    x    = x+0.01*z(4)*ones(1,length(x));
    text([1:length(x)],x,modl.vlbl,'rotation',90);
  end
  hline(0)
  zoompls
  set(g(1:size(g,1),1),'Enable','on')
  if datstat
    set(g(18,1),'Enable','off')
  end
case 'scrinfo'
  g      = get(gcf,'UserData');
  set(g(1:size(g,1),1),'Enable','off')
  z      = get(gca,'children');
  z      = z(length(z));
  x      = get(z,'xdata');
  y      = get(z,'ydata');
  jj     = sampidr(x,y);
  if ishold
    h    = plot(x(jj),y(jj),'xb','MarkerSize',10);
  else
    hold on
    h    = plot(x(jj),y(jj),'xb','MarkerSize',10);
    hold off
  end
  s      = ['pcaplots(''scrmarkdel'',',as,')'];
  z      = get(gcf,'position');
  y      = figure('NumberTitle','off', ...
    'Name','Sample Info','Color',[0 0 0],'Menu','none', ...
    'Position',[z(1)+35 z(2)-40 220 150], ...
    'UserData',h,'CloseRequestFcn',s,'Tag',int2str(gcf));
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
    y1   = ['Q Residual    = ',num2str(test.res(jj))];
    z    = ['Hotelling T^2 = ',num2str(test.tsq(jj))];
  else
    if isempty(modl.slbl)
      s  = ' ';
    else
      s  = modl.slbl(jj,:);
    end
    y1   = ['Q Residual    = ',num2str(modl.res(jj))];
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
  z      = str2mat(['Sample ',int2str(jj)],s,y1,y2,z,z2);
  set(x,'String',z)
  set(g(1:size(g,1),1),'Enable','on')
  if datstat
    set(g(18,1),'Enable','off')
  end
case 'scrmarkdel'
  h    = findobj('Name','Plot Scores','Tag',as);  
  if h
    h    = get(gcf,'UserData');
  end
  if ishandle(h)
    delete(h)
    closereq
  else
    closereq
  end
case 'lodmarkdel'
  h    = findobj('Name','Plot Loads','Tag',as);
  if h
    h    = get(gcf,'UserData'); delete(h)
  end
  if ishandle(h)
    delete(h)
    closereq
  else
    closereq
  end
case 'lodinfo'
  g      = get(gcf,'UserData');
  set(g(1:size(g,1),1),'Enable','off')
  z      = get(gca,'children');
  x      = get(z(length(z)),'xdata');
  y      = get(z(length(z)),'ydata');
  jj     = sampidr(x,y);
  if ishold
    h    = plot(x(jj),y(jj),'xb','MarkerSize',10);
  else
    hold on
    h    = plot(x(jj),y(jj),'xb','MarkerSize',10);
    hold off
  end
  s      = ['pcaplots(''lodmarkdel'',',as,')'];
  z      = get(gcf,'position');
  y      = figure('NumberTitle','off', ...
    'Name','Variable Info','Color',[0 0 0], ...
    'Position',[z(1)+35 z(2)-40 220 150], ...
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
  if datstat
    set(g(18,1),'Enable','off')
  end
case 'loddel'
%not tested
  g      = get(gcf,'UserData');
  set(g(1:size(g,1),1),'Enable','off')
  z      = get(gca,'children');
  x      = get(z(length(z)),'xdata');
  y      = get(z(length(z)),'ydata');
  jj     = sampidr(x,y);     %indice in plot
  if ishold
    h    = plot(x(jj),y(jj),'*k','MarkerSize',10);
  else
    hold on
    h    = plot(x(jj),y(jj),'*k','MarkerSize',10);
    hold off
  end
  jj     = modl.icol(1,jj);  %variable number
  cndlgpls(jj,g(18,1),'variable')
  if strcmp(get(g(18,1),'Userdata'),'yes')
    modl.dcol = [modl.dcol, jj];
    stat.modl = 'none';
    pcagui('nothing',fighand)
  else
    delete(h)
  end
  set(g(1:size(g,1),1),'Enable','on')
  if datstat
    set(g(18,1),'Enable','off')
  end
case 'limitchk'
  g = get(gcf,'UserData');
  set(g(3,1),'Enable','on')
  if get(g(13,1),'Value')
    set(g(12,1),'Enable','on')
  else
    set(g(12,1),'Enable','off')
  end
case 'g3on'
  g = get(gcf,'UserData');
  set(g(3,1),'Enable','on')
end

set(f(2,1),'UserData',modl)
set(b(1,1),'UserData',stat)
