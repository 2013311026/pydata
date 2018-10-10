function cndlgpls(jj,handl,object);
%CNDLGPLS - GUI dialog box for accepting/canceling a delete action.
%  The scalar input (jj) is a sample or variable number,
%  (handl) is a valid object handle, and (object) is a text 
%  variable with values 'variable' or 'sample'. Called by
%  PCAGUI and MODLGUI.
%
%I/O: cndlgpls(jj,handl,object);

%Copyright Eigenvector Research, Inc. 1997-8
%nbg 4/97 

if jj
  bgc0 = [1 1 1];
  p    = get(0,'ScreenSize'); 
  a    = dialog('Color',bgc0, ...
    'Position',[p(3)/2-100 p(4)/2 220 100], ...
    'Resize','off','UserData',handl);
  b    = zeros(3,1);  
  s    = ['delete ',object,' number ',int2str(jj),'?'];
  b(1,1) = uicontrol('Parent',a,'Style','text', ...
    'Position',[11 41 175 35], ...
    'String',s);
  b(2,1) = uicontrol('Parent',a, ...
    'Position',[107 11 75 25], ...
    'String','Cancel','FontWeight','bold', ...
    'CallBack',['cndlgpls([],[],','''cancel'');']);
  b(3,1) = uicontrol('Parent',a, ...
    'Position',[18 11 75 25], ...
    'String','Delete','FontWeight','bold', ...
    'CallBack',['cndlgpls([],[],','''delete'');']);
  for jj=1:3
    set(b(jj,1),'FontName','geneva','FontSize',12, ...
    'Units','points','BackgroundColor',bgc0, ...
    'HorizontalAlignment','center')
  end
  waitfor(a)
elseif strcmp(object,'delete')
  handl = get(gcf,'UserData');
  set(handl,'UserData','yes');
  close(gcf)
elseif strcmp(object,'cancel')
  handl = get(gcf,'UserData');
  set(handl,'UserData','no');
  close(gcf)
end
