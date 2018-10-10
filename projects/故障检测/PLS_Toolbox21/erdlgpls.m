function erdlgpls(txtstring,namestring)
%ERDLGPLS error dialog
%  ERDLGPLS creates an error dialog box with the
%  name (namestring) and an error message provided
%  by (txtstring). ERDLGPLS is called by PCAGUI and MODLGUI.
%
%I/O: erdlgpls(txtstring,namestring);

%Copyright Eigenvector Research, Inc. 1997-98
%nbg 4/97 

bgc0   = [1 1 1];
bgc1   = [1 1 1]*.85;
fsiz   = 12;
fnam   = 'geneva';
fwt    = 'bold';
p      = get(0,'ScreenSize');          
a = dialog('Color',bgc0,'Name',namestring, ...
    'NumberTitle','off','Resize','off', ...
    'Position',[p(3)/2-150 p(4)/2 200 120], ...
    'Interruptible','off');
b      = zeros(2,1);
b(1,1) = uicontrol('Parent',a, ...
    'Style','text','BackgroundColor',bgc0, ...
  'Position',[11 18 178 98], ...
  'HorizontalAlignment','center', ...
  'String',txtstring,'ForegroundColor',[0 0 0]);
b(2,1) = uicontrol('Parent',a, ...
  'Position',[71 16 55 25],'BackgroundColor',bgc1, ...
  'String','OK','CallBack','close(gcf)');
for jj=1:2
    set(b(jj,1),'FontName',fnam,'FontSize',fsiz, ...
    'FontWeight',fwt,'Units','points')
end
