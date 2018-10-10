function lddlgpls(callhand,callhand2,klass,message,action)
%LDDLPLS load variable from workspace dialog.
%  Input (callhand) is a handle of an object 
%  in a gui to set the passed workspace
%  variable to as userdata.
%  Input (callhand2) is a handle of an object
%  in a gui to set the passed workspace
%  variable name to as userdata.
%  The optional variable (klass) allows the
%  user to select the workspace variable of
%  class 'klass' to load.
%  klass = 'double', 'cell', 'char', or 'struct'.
%
%I/O: lddlgpls(callhand,callhand2,klass,message);

%Copyright Eigenvector Research, Inc. 1997-2000
%nbg 4/97,6/97,3/99,11/99

if nargin<5
  if nargin<4
    message = [];
  end
  if nargin<3
    klass = 'double';   %set default class
  end
  if nargin<2
    callhand2 = [];
  end
  evalin('base','assignin(''caller'',''s'',whos)')
  if isempty(s)
    s1    = 'Error on Load!';
    erdlgpls('No variables in workspace',s1)
  else
    s2    = char({s.class});
    switch klass
    case 'double'
      jj  = find(s2(:,1)=='d');
      s3  = {s.size};
      s3  = s3(jj);
    case 'struct'
      jj  = find(s2(:,1)=='s');
    case 'char'
      jj  = find(s2(:,2)=='h');
      s3  = {s.size};
      s3  = s3(jj);
    case 'cell'
      jj  = find(s2(:,2)=='e');
    otherwise
      s3  = [klass,' not a valid class'];
      erdlgpls(s3,'Error on Load!')
      error
    end
    s     = char({s.name});
    s     = s(jj,:);
    if isempty(s)
      s   = 'Error on Load!';
      if klass
        s2 = ['No ',klass,' in workspace'];
        erdlgpls(s2,s)
      else
        erdlgpls('No data in workspace',s)
      end
    else
      bgc0 = [1 1 1];
      fsiz = 10;
      switch lower(computer)
      case 'pcwin'
        fnam = 'arial';
      case 'mac2'
        fnam = 'geneva';
      otherwise
        fnam = 'geneva';
      end
      fwt  = 'bold';
      units0   = get(0,'Units');
      set(0,'Units','pixels')
      p    = get(0,'ScreenSize');          
      a    = dialog('Color',bgc0, ...
        'Name','Load','Resize','off', ...
        'Position',[p(3)/2-150 p(4)/2 300 170]);
      b    = zeros(6,1);

      if strcmp(klass,'double')|strcmp(klass,'char')
        %ssiz = '';
        ssiz = [' ',num2str(s3{1}(1)),'x',num2str(s3{1}(2))];
        for ii=2:length(s3)
          ssiz = str2mat(ssiz, ...
            [' ',num2str(s3{ii}(1)),'x',num2str(s3{ii}(2))]);
        end
        ssiz = cellstr([s,ssiz]);
      else
        ssiz = cellstr(s);
      end

      s    = cellstr(s);
      b(1,1) = uicontrol('Parent',a, ...
        'Position',[3 58 201 109], ...
        'String',ssiz,'UserData',callhand, ...
        'CallBack',['lddlgpls([],[],''',klass,''',[],''listact'')'], ...
        'Style','listbox','Value',[1]);
      b(2,1) = uicontrol('Parent',a, ...
        'Position',[3 3 201 25], ...
        'HorizontalAlignment','left', ...
        'Style','edit','String',s{1}, ...
        'UserData',callhand2, ...
        'FontWeight',fwt);
      b(3,1) = uicontrol('Parent',a, ...
        'Position',[5 30 199 20], ...
        'HorizontalAlignment','left', ...
        'String',['Load ',klass,' Variable:'], ...
        'FontWeight',fwt,'Style','text', ...
        'UserData',s);
      b(4,1) = uicontrol('Parent',a, ...
        'Position',[215 33 75 25], ...
        'String','Cancel','FontWeight',fwt, ...
        'CallBack','close(gcf)');
      b(5,1) = uicontrol('Parent',a, ...
        'Position',[215 3 75 25], ...
        'Interruptible','off', ...
        'String','Load','FontWeight',fwt, ...
        'CallBack',['lddlgpls([],[],''',klass,''',[],''actload'');'], ...  
        'Tag','PushLOADLDDLG');
      if ~isempty(message)
        message = ['load: ',message];
      end
      b(6,1) = uicontrol('Parent',a,'Style','text', ...
        'Position',[215 71 75 96], ...
        'HorizontalAlignment','left', ...
        'String',message,'FontWeight',fwt);
      set(a,'UserData',b)
      for jj=1:length(b)
        set(b(jj,1),'FontName',fnam,'FontSize',fsiz, ...
          'Units','points','BackgroundColor',bgc0)
      end
      set(0,'Units',units0)
      waitfor(a)
    end
  end
else
  b = get(gcf,'UserData');
  if strcmp(action,'actload')
    c = get(b(2,1),'string');
    s = ['exist(''',c,''')'];
    s1= ['assignin(''caller'',''d'',',s,')'];
    evalin('base',s1)
    s = ['isempty(',c,')'];
    s1= ['assignin(''caller'',''e'',',s,')'];
    evalin('base',s1)
    if isempty(c)|(d~=1)|(e==1)
      s = ['variable empty or does not exist in workspace'];
      erdlgpls(s,'Error on Load!');
    else  
      s = ['assignin(''caller'',''d'',',c,')'];
       evalin('base',s)
      set(get(b(1,1),'UserData'),'UserData',d)
      set(get(b(2,1),'UserData'),'UserData',c)
      close(gcf)
    end  
  elseif strcmp(action,'listact')
    c = get(b(1,1),'Value');
    %s = get(b(1,1),'String');
    s = get(b(3,1),'UserData');
    c = s{c};
    set(b(2,1),'string',c);
  end
end
