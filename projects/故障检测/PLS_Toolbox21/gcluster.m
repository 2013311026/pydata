function gcluster(dat,labels,action,fighand);
%GCLUSTER KNN and K-means cluster analysis with dendrograms.
%  GCLUSTER is a gui for CLUSTER. This function performs
%  a cluster analysis using either the K Nearest Neighbor
%  (KNN) or K-means clustering algorithm and plots a
%  dendrogram. Inputs are the data matrix (dat), and an
%  optional matrix of sample labels (labels). The output is
%  a dendrogram showing the distances between the samples.
%  If (labels) is not specifed the sample numbers will be 
%  used in the plots instead.
% 
%I/O: gcluster(dat,labels);
%
%See also: CLUSTER, CLSTRDMO for a demo of CLUSTER.

%Copyright Eigenvector Research, Inc. 1995-98
%nbg 9/98

if nargin<3
   action = 'initiate';
   if nargin<2
      labels = [];
   end
   if nargin<1
      dat = [];
   end
end

if strcmp(action,'initiate')
  handl   = zeros(8,8);
  bgc     = 'BackGroundColor';
  bgc1    = [0.8 0.8 0.8];
  bgc2    = [1 0 1]*0.6;

  fig00      = figure('Name','Cluster Analysis with Dendrograms','color',[0 0 0],...
               'Pos',[11 19 480 320],'Resize','Off','NumberTitle','Off', ...
			   'HandleVisibility','off');
  as         = num2str(fig00);
  frame1     = uicontrol(fig00,'Style','Frame',bgc,bgc2,'Pos',[11 131 220 110]);
  handl(2,1) = uicontrol(fig00,'Style','Text','Pos',[15 135 212 102],...
               'String','Clustering Algorithm','UserData',dat,bgc,[1 1 1]);       
  handl(3,1) = uicontrol(fig00,'Style','Radio','Pos',[50 197 150 20],...
 			   'String',' k nearest neighbor',bgc,[1 1 1],'Value',1,...
               'Userdata',labels,'CallBack',['gcluster(0,0,''act31'',',as,')']);
  handl(4,1) = uicontrol(fig00,'style','radio','Pos',[50 167 150 20],...
 			   'string',' k means',bgc,[1 1 1],'value',0,...
               'callback',['gcluster(0,0,''act41'',',as,')']);		  
  frame2     = uicontrol(fig00,'Style','Frame','Pos',[11 11 220 110],...
               bgc,bgc2);
  handl(1,2) = 1;
  handl(2,2) = uicontrol(fig00,'Style','Text','Pos',[15 15 212 102],...
               bgc,[1 1 1],'String','Scaling');	   
  handl(3,2) = uicontrol(fig00,'Style','Radio','Pos',[50 17 150 20],...
               'Value',0,bgc,[1 1 1],'String',' none',...
               'CallBack',['gcluster(0,0,''act32'',',as,')'],'Visible','Off');
  handl(4,2) = uicontrol(fig00,'Style','Radio','Pos',[50 77 150 20],...
               'Value',0,bgc,[1 1 1],'String',' mean center',...
               'CallBack',['gcluster(0,0,''act42'',',as,')']);
  handl(5,2) = uicontrol(fig00,'Style','Radio','Pos',[50 47 150 20],...
               'Value',1,bgc,[1 1 1],'String',' Autoscale',...
               'Callback',['gcluster(0,0,''act52'',',as,')']);
  frame3     = uicontrol(fig00,'Style','Frame','Pos',[11 251 460 60],bgc,bgc2);
  handl(2,3) = uicontrol(fig00,'style','text','Pos',[15 255 452 52],...
               bgc,[1 1 1],'String','Cluster Analysis with Dendrograms');
  frame4     = uicontrol(fig00,'Style','Frame','Pos',[251 156 220 85],bgc,bgc2);
  handl(1,4) = 0;
  handl(2,4) = uicontrol(fig00,'Style','Text','Pos',[255 160 212 77],...
               bgc,[1 1 1],'string','Use PCA?');	   
  handl(3,4) = uicontrol(fig00,'Style','Radio','Pos',[290 197 150 20],...
               'Value',1,bgc,[1 1 1],'String',' no',...
               'CallBack',['gcluster(0,0,''act34'',',as,')']);
  handl(4,4) = uicontrol(fig00,'Style','Radio','Pos',[290 167 150 20],...
               'Value',0,bgc,[1 1 1],'String',' yes',...
               'CallBack',['gcluster(0,0,''act44'',',as,')']);
  handl(1,8) = 0;
  handl(2,8) = uicontrol(fig00,'Style','Frame','Pos',[251 61 220 85],...
               bgc,bgc2,'Visible','Off');
  handl(3,8) = uicontrol(fig00,'Style','Text','Pos',[255 65 212 77],bgc,[1 1 1],...
               'String','Use Mahalanobis Distance Measure?','Visible','Off');
  handl(4,8) = uicontrol(fig00,'Style','Radio','Pos',[290 102 150 20],...
               'Value',1,bgc,[1 1 1],'String',' no',...
               'CallBack',['gcluster(0,0,''act48'',',as,')'],'Visible','Off');
  handl(5,8) = uicontrol(fig00,'Style','Radio','Pos',[290 72 150 20],...
               'Value',0,bgc,[1 1 1],'String',' yes',...
               'CallBack',['gcluster(0,0,''act58'',',as,')'],'Visible','Off');

  handl(2,5) = uicontrol(fig00,'Style','Push','Pos',[366 11 105 37],...
               'String','Quit','Callback',['gcluster(0,0,''act25'',',as,')'],...
			   bgc,bgc1);
  handl(2,7) = uicontrol(fig00,'Style','Push','Pos',[251 11 105 37],...
               'String','Execute','CallBack',['gcluster(0,0,''act27'',',as,')'],...
			   bgc,bgc1);
  set(fig00,'userdata',[handl]);
else
  handl      = get(fighand,'userdata');
  bgc        = 'BackGroundColor';

  if strcmp(action,'act27')
	dat      = get(handl(2,1),'userdata');
    labels   = get(handl(3,1),'userdata');
    if isempty(dat)
	  handl(1,1) = 0;
	  set(handl(2,3),'string','ERROR - input data not found -')	
   	else
	  set(handl(2,3),'string','executing',bgc,[1 1 1]);
      handl(1,1) = figure('Pos',[201 190 480 320],...
                   'Name','Dendrogram','NumberTitle','Off','Resize','On');
	  set(fighand,'UserData',handl);
	  cluster(dat,labels,fighand);
    end
  elseif strcmp(action,'act31')
    set(handl(3,1),'value',1);
    set(handl(4,1),'value',0);
    set(handl(2,3),'string',' ',bgc,[1 1 1]);
  elseif strcmp(action,'act41')
    set(handl(3,1),'value',0);
    set(handl(4,1),'value',1);
    set(handl(2,3),'string',' ',bgc,[1 1 1]);
  elseif strcmp(action,'act32')
    set(handl(3,2),'value',1);
    set(handl(4:5,2),'value',0);
	handl(1,2)  = 0;
    set(handl(2,3),'string',' ',bgc,[1 1 1]);
  elseif strcmp(action,'act42')
    set(handl(3:5,2),'value',0);
    set(handl(4,2),'value',1);
	handl(1,2)  = 2;
    set(handl(2,3),'string',' ',bgc,[1 1 1]);
  elseif strcmp(action,'act52')
    set(handl(3:5,2),'value',0);
   	set(handl(5,2),'value',1);
   	handl(1,2)  = 1;
    set(handl(2,3),'string',' ',bgc,[1 1 1]);
  elseif strcmp(action,'act34')
    set(handl(3,4),'value',1);
    set(handl(4,4),'value',0);
   	set(handl(2:5,8),'visible','off');
    set(handl(2,3),'string',' ',bgc,[1 1 1]);
   	handl(1,4)  = 0;
    set(handl(4,8),'value',1);
    set(handl(5,8),'value',0);
    handl(1,8)  = 0;
  elseif strcmp(action,'act44')
    set(handl(3,4),'value',0);
    set(handl(4,4),'value',1);
   	set(handl(2:5,8),'visible','on');
   	set(handl(2,3),'string',['on execution the PCA routine will',...
        ' a)  list the PC variance statistics, and',...
        ' b)  prompt you for the appropriate number of PCs to use',...
        ' in the COMMAND WINDOW']);
   	handl(1,4)  = 1;
    set(handl(4,8),'value',1);
    set(handl(5,8),'value',0);
    handl(1,8)  = 0;
  elseif strcmp(action,'act48')
    set(handl(4,8),'value',1);
    set(handl(5,8),'value',0);
    handl(1,8)  = 0;
  elseif strcmp(action,'act58')
    set(handl(4,8),'value',0);
    set(handl(5,8),'value',1);
    handl(1,8)  = 1;
  end
	
  set(fighand,'userdata',[handl]);
  
  if strcmp(action,'act25')
    close(fighand);
  end
end

