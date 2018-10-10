function [ffit,gpop] = genalg(xdat,ydat,outfit,outpop,action);
%GENALG Genetic Algorithm for Variable Selection
%  This function can be used for predictive variable selection
%  with MLR or PLS regression models. The inputs are (xdat) a
%  matrix of of predictor variables and (ydat) a matrix of
%  predicted variables. (outfit) and (outpop) are text inputs
%  that contain the names of the output variables. The fitness
%  of the final members of the population are given in (outfit)
%  and (outpop) contains the final populations: a 1 means a
%  variable was included, and a 0 means that it was not included.
%
%I/O: genalg(xdat,ydat,outfit,outpop);
%
%Example: genalg(x,y,'fitness','selectedvariables');
%
%See also: GASELCTR

%Copyright Eigenvector Research, Inc. 1995-2000
%Modified 2/95, 1/97, 2/97 NBG
%Modified 4/30/98 BMW
% 10/27/00, nbg change in main loop to check if pop(i,:) is all zeros

if nargin<5&nargin>1,
   action = 'initiate';
end

if strcmp(action,'initiate')
  handl   = zeros(17,5);
  [mx,nx] = size(xdat);
  [my,ny] = size(ydat);
  bgc     = ['BackGroundColor'];
  bgc1    = [.8 .8 .8];
  bgc2    = [1 0 1]*0.6;

%Define default values for all variables
  ps = 64; mg  = 100; mr  = .005; ww  = 1; cc = 50; ft = 30;
  lvs = 10;  cvs = 5;    cvi = 1; %co = 1;
%Set figure title
  fig     = figure('Name','Genetic Algorithm for Variable Selection',...
   'NumberTitle','Off','Pos',[111 19 480 320],'Resize','Off','Color',[0 0 0]);
%Define frame around general ga control sliders
  uicontrol(fig,'Style','Frame','Pos',[11 11 220 300],bgc,bgc2);
  uicontrol(fig,'Style','Frame','Pos',[15 15 212 292],bgc,bgc1);
%Define frame around regression choice controls
  uicontrol(fig,'Style','Frame','Pos',[251 211 220 100],bgc,bgc2);
  uicontrol(fig,'Style','Frame','Pos',[255 215 212 92],bgc,bgc1);
%Define cross-validation choices frame
  uicontrol(fig,'Style','Frame','Position',[251 61 220 140],bgc,bgc2);
  uicontrol(fig,'Style','Frame','Position',[255 65 212 132],bgc,bgc1);
%Define text header for general ga controls
  uicontrol(fig,'Style','text','Pos',[21 281 200 20],'String',...
  'GA Parameters',bgc,bgc1);
%Define population size slider sli_ps
  handl(2,1) = uicontrol(fig,'Style','slider','Position',...
   [51 256 140 20],'Min',16,'Max',256,'Value',ps,...
   'CallBack','genalg(0,0,''w1'',''w2'',''act21'');');
  handl(2,2) = uicontrol(fig,'Style','text','Pos',[161 236 30 20],bgc,bgc1,...
   'String',num2str(get(handl(2,1),'Value')),'Horiz','right');
  handl(2,3) = uicontrol(fig,'Style','text','Pos',[21 256 30 20],bgc,bgc1,...
   'String',num2str(get(handl(2,1),'Min')),'Horiz','left');
  handl(2,4) = uicontrol(fig,'Style','text','Pos',[191 256 30 20],bgc,bgc1,...
   'String',num2str(get(handl(2,1),'Max')),'Horiz','right');
  handl(2,5) = uicontrol(fig,'Style','text','Pos',[51 236 120 20],bgc,bgc1,...
   'String','Population Size','Horiz','left');
%Define maximum generations slider sli_mg
  handl(3,1) = uicontrol(fig,'Style','slider','Position',...
   [51 136 140 20],'Min',25,'Max',500,'Value',mg,...
   'CallBack','genalg(0,0,''w1'',''w2'',''act31'');');
  handl(3,2) = uicontrol(fig,'Style','text','Pos',[161 116 30 20],bgc,bgc1,...
   'String',num2str(get(handl(3,1),'Value')),'Horiz','right');
  handl(3,3) = uicontrol(fig,'Style','text','Pos',[21 136 30 20],bgc,bgc1,...
   'String',num2str(get(handl(3,1),'Min')),'Horiz','left');
  handl(3,4) = uicontrol(fig,'Style','text','Pos',[191 136 30 20],bgc,bgc1,...
   'String',num2str(get(handl(3,1),'Max')),'Horiz','right');
  handl(3,5) = uicontrol(fig,'Style','text','Pos',[51 116 120 20],bgc,bgc1,...
   'String','Max Generations','Horiz','left');
%Define mutation rate slider sli_mr
  handl(4,1) = uicontrol(fig,'Style','slider','Position',...
   [51 56 140 20],'Min',.001,'Max',.01,'Value',mr,...
   'CallBack','genalg(0,0,''w1'',''w2'',''act41'');');
  handl(4,2) = uicontrol(fig,'Style','text','Pos',[146 36 45 20],bgc,bgc1,...
   'String',num2str(get(handl(4,1),'Value')),'Horiz','right');
  handl(4,3) = uicontrol(fig,'Style','text','Pos',[16 56 33 20],bgc,bgc1,...
   'String',num2str(get(handl(4,1),'Min')),'Horiz','left');
  handl(4,4) = uicontrol(fig,'Style','text','Pos',[191 56 30 20],bgc,bgc1,...
   'String',num2str(get(handl(4,1),'Max')),'Horiz','right');
  handl(4,5) = uicontrol(fig,'Style','text','Pos',[51 36 110 20],bgc,bgc1,...
   'String','Mutation Rate','Horiz','left');  
%Define window width slider sli_ww
  maxw       = round(min([nx/2,50]));
  handl(5,1) = uicontrol(fig,'Style','slider','Position',...
   [51 216 140 20],'Min',1,'Max',maxw,'Value',ww,...
   'CallBack','genalg(0,0,''w1'',''w2'',''act51'');');
  handl(5,2) = uicontrol(fig,'Style','text','Pos',[161 196 30 20],bgc,bgc1,...
    'String',num2str(get(handl(5,1),'Value')),'Horiz','right');
  handl(5,3) = uicontrol(fig,'Style','text','Pos',[21 216 30 20],bgc,bgc1,...
   'String',num2str(get(handl(5,1),'Min')),'Horiz','left');
  handl(5,4) = uicontrol(fig,'Style','text','Pos',[191 216 30 20],bgc,bgc1,...
   'String',num2str(get(handl(5,1),'Max')),'Horiz','right');
  handl(5,5) = uicontrol(fig,'Style','text','Pos',[51 196 120 20],...
   'String','Window Width','Horiz','left',bgc,bgc1);
%Define convergence criteria slider
  handl(6,1) = uicontrol(fig,'Style','slider','Position',...
   [51 96 140 20],'Min',1,'Max',100,'Value',cc,...
   'CallBack','genalg(0,0,''w1'',''w2'',''act61'');');
  handl(6,2) = uicontrol(fig,'Style','text','Pos',[161 76 30 20],bgc,bgc1,...
   'String',num2str(get(handl(6,1),'Value')),'Horiz','right');
  handl(6,3) = uicontrol(fig,'Style','text','Pos',[21 96 30 20],bgc,bgc1,...
   'String',num2str(get(handl(6,1),'Min')),'Horiz','left');
  handl(6,4) = uicontrol(fig,'Style','text','Pos',[191 96 30 20],bgc,bgc1,...
   'String',num2str(get(handl(6,1),'Max')),'Horiz','right');
  handl(6,5) = uicontrol(fig,'Style','text','Pos',[51 76 120 20],bgc,bgc1,...
    'String','% at Convergence','Horiz','left');
%Define fraction terms in initial population slider
  handl(7,1) = uicontrol(fig,'Style','slider','Position',...
   [51 176 140 20],'Min',10,'Max',50,'Value',ft,...
   'CallBack','genalg(0,0,''w1'',''w2'',''act71'');');
  handl(7,2) = uicontrol(fig,'Style','text','Pos',[161 156 30 20],bgc,bgc1,...
    'String',num2str(get(handl(7,1),'Value')),'Horiz','right');
  handl(7,3) = uicontrol(fig,'Style','text','Pos',[21 176 30 20],bgc,bgc1,...
    'String',num2str(get(handl(7,1),'Min')),'Horiz','left');
  handl(7,4) = uicontrol(fig,'Style','text','Pos',[191 176 30 20],bgc,bgc1,...
    'String',num2str(get(handl(7,1),'Max')),'Horiz','right');
  handl(7,5) = uicontrol(fig,'Style','text','Pos',[51 156 120 20],bgc,bgc1,...
    'String','% Initial Terms','Horiz','left');
%Define crossover choice radio buttons
  uicontrol(fig,'Style','text','String','Crossover:',bgc,bgc1,...
   'Horiz','left','Position',[21 20 75 15]);
  handl(8,1) = uicontrol(fig,'Style','radio','String',...
    'Single','Position',[80 19 60 20],'Value',0,bgc,bgc1,...
	'CallBack','genalg(0,0,''w1'',''w2'',''act81'');');
  handl(8,2) = uicontrol(fig,'Style','radio','String',...
    'Double','Position',[155 19 60 20],'Value',1,bgc,bgc1,...
	'CallBack','genalg(0,0,''w1'',''w2'',''act82'');');
  handl(8,3) = 1;	
%Define the regression choice radio buttons
  uicontrol(fig,'Style','text','String','Regression Choice',...
   'Position',[261 281 200 20],bgc,bgc1);
  handl(9,1) = uicontrol(fig,'Style','radio','String',...
   'MLR','Position',[281 261 50 20],'Value',0,bgc,bgc1,...
   'CallBack','genalg(0,0,''w1'',''w2'',''act91'');');
  handl(9,2) = uicontrol(fig,'Style','radio','String',...
   'PLS','Position',[371 261 50 20],'Value',1,bgc,bgc1,...
   'CallBack','genalg(0,0,''w1'',''w2'',''act92'');');
  handl(9,3) = 1;
%Define # of latent variables slider
  mlvs        = min([mx,nx,25]);
  lvs         = min([mlvs,lvs]);
  handl(10,1) = uicontrol(fig,'Style','slider','Pos',...
   [291 236 140 20],'Min',1,'Max',mlvs,'Value',lvs,...
   'CallBack','genalg(0,0,''w1'',''w2'',''act101'');');
  handl(10,2) = uicontrol(fig,'Style','text','Pos',[401 216 30 20],...
   'String',num2str(get(handl(10,1),'Value')),'Horiz','right',bgc,bgc1);
  handl(10,3) = uicontrol(fig,'Style','text','Pos',[261 236 30 20],...
   'String',num2str(get(handl(10,1),'Min')),'Horiz','left',bgc,bgc1);
  handl(10,4) = uicontrol(fig,'Style','text','Pos',[431 236 30 20],...
   'String',num2str(get(handl(10,1),'Max')),'Horiz','right',bgc,bgc1);
  handl(10,5) = uicontrol(fig,'Style','text','Pos',[291 216 110 20],...
   'String','# of LVs','Horiz','left',bgc,bgc1);
%Define cross validation choice
  uicontrol(fig,'Style','text','Position',[261 171 200 20],...
   'String','Cross-Validation Parameters',bgc,bgc1);
%Define cross-validation choice random radio button
  handl(11,1) = uicontrol(fig,'Style','radio','String',...
   'Random','Position',[281 156 58 20],'Value',1,bgc,bgc1,...
   'CallBack','genalg(0,0,''w1'',''w2'',''act111'');');
  handl(11,2) = uicontrol(fig,'Style','radio','String',...
   'Contiguous','Position',[371 156 80 20],'Value',0,bgc,bgc1,...
   'CallBack','genalg(0,0,''w1'',''w2'',''act112'');');
  handl(11,3) = 0;
%Define slider for cross-validation split
   maxs = min([20,mx]);
   vals = round(sqrt(mx));
   vals = min([cvs,vals]);
  handl(12,1) = uicontrol(fig,'Style','slider','Position',...
   [291 131 140 20],'Min',2,'Max',maxs,'Value',vals,...
   'CallBack','genalg(0,0,''w1'',''w2'',''act121'');');
  handl(12,2) = uicontrol(fig,'Style','text','Pos',[401 111 30 20],bgc,bgc1,...
   'String',num2str(get(handl(12,1),'Value')),'Horiz','right');
  handl(12,3) = uicontrol(fig,'Style','text','Pos',[261 131 30 20],bgc,bgc1,...
   'String',num2str(get(handl(12,1),'Min')),'Horiz','left');
  handl(12,4) = uicontrol(fig,'Style','text','Pos',[431 131 30 20],bgc,bgc1,...
   'String',num2str(get(handl(12,1),'Max')),'Horiz','right');
  handl(12,5) = uicontrol(fig,'Style','text','Pos',[291 111 120 20],bgc,bgc1,...
   'String','# of Subsets','Horiz','left');
   %Define slider for the cross-validation iterations
  handl(13,1) = uicontrol(fig,'Style','slider','Position',...
   [291 86 140 20],'Min',1,'Max',10,'Value',cvi,...
   'CallBack','genalg(0,0,''w1'',''w2'',''act131'');');
  handl(13,2) = uicontrol(fig,'Style','text','Pos',[401 66 30 20],bgc,bgc1,...
   'String',num2str(get(handl(13,1),'Value')),'Horiz','right');
  handl(13,3) = uicontrol(fig,'Style','text','Pos',[261 86 30 20],bgc,bgc1,...
   'String',num2str(get(handl(13,1),'Min')),'Horiz','left');
  handl(13,4) = uicontrol(fig,'Style','text','Pos',[431 86 30 20],bgc,bgc1,...
   'String',num2str(get(handl(13,1),'Max')),'Horiz','right');
  handl(13,5) = uicontrol(fig,'Style','text','Pos',[291 66 110 20],bgc,bgc1,...
   'String','# of Iterations','Horiz','left');
%Define the push buttons for routine control
  handl(14,1) = uicontrol(fig,'Style','Push','Pos',[251 11 66 37],bgc,bgc1,...
   'String','Execute','CallBack','genalg(0,0,''w1'',''w2'',''garun'');',...
   'Interruptible','On');
  handl(15,1) = uicontrol(fig,'Style','push','Pos',[328 11 67 37],bgc,bgc1,...
   'String','Stop','CallBack','genalg(0,0,''w1'',''w2'',''stop'');',...
   'Visible','Off','UserData',0);
   s1         = ['[',outfit,',',outpop,']=genalg(0,0,''w1'',''w2'',''quit'');'];
  handl(16,1) = uicontrol(fig,'Style','push','Pos',[406 11 66 37],'String',...
   'Quit','CallBack',s1,'Visible','Off',bgc,bgc1);
  handl(17,1) = uicontrol(fig,'Style','Push','Pos',[251 11 66 37],bgc,bgc1,...
   'String','Resume','CallBack','genalg(0,0,''w1'',''w2'',''resum'');',...
   'Interruptible','On','Visible','Off');  
  set(handl(2,1),'UserData',xdat);
  set(handl(3,1),'UserData',ydat);
  set(handl(5,1),'UserData',outfit);
  set(handl(5,2),'UserData',outpop);
  set(fig,'UserData',handl);
else
  fig     = gcf;
  handl   = get(fig,'UserData');
  xdat    = get(handl(2,1),'UserData');
  ydat    = get(handl(3,1),'UserData');
  [mx,nx] = size(xdat);
  [my,ny] = size(ydat);
  outfit  = get(handl(5,1),'UserData');
  outpop  = get(handl(5,2),'UserData');
  
  if strcmp(action,'act21')
    ps  = 4*round(get(handl(2,1),'Val')/4);
    set(handl(2,2),'String',num2str(ps));
  elseif strcmp(action,'act31')
    mg  = round(get(handl(3,1),'Val'));
    set(handl(3,2),'String',num2str(mg));
  elseif strcmp(action,'act41')
    mr = 1e-3*round(get(handl(4,1),'Val')/1e-3);
    set(handl(4,2),'String',num2str(mr));
  elseif strcmp(action,'act51')
    ww = round(get(handl(5,1),'Val'));
    set(handl(5,2),'String',num2str(ww));
  elseif strcmp(action,'act61')
    cc = round(get(handl(6,1),'Val'));
    set(handl(6,2),'String',num2str(cc));
  elseif strcmp(action,'act71')
    ft = round(get(handl(7,1),'Val'));
    set(handl(7,2),'String',num2str(ft));
  elseif strcmp(action,'act81')
    set(handl(8,1),'Value',1);
	set(handl(8,2),'Value',0);
	handl(8,3) = 1;
  elseif strcmp(action,'act82')
    set(handl(8,1),'Value',0);
	set(handl(8,2),'Value',1);
	handl(8,3) = 2;
  elseif strcmp(action,'act91')
    set(handl(9,1),'Value',1);
	set(handl(9,2),'Value',0);
	set(handl(10,1:5),'Visible','off');
	handl(9,3) = 0;
  elseif strcmp(action,'act92')
    set(handl(9,1),'Value',0);
	set(handl(9,2),'Value',1);
	set(handl(10,1:5),'Visible','on');
	handl(9,3) = 1;
  elseif strcmp(action,'act101')
  	lvs = round(get(handl(10,1),'Val'));
    set(handl(10,2),'String',num2str(lvs));
  elseif strcmp(action,'act111')
    set(handl(11,1),'Value',1);
	set(handl(11,2),'Value',0);
	handl(11,3) = 0;
  elseif strcmp(action,'act112')
    set(handl(11,1),'Value',0);
	set(handl(11,2),'Value',1);
	handl(11,3) = 1;
  elseif strcmp(action,'act121')
  	cvs = round(get(handl(12,1),'Val'));
    set(handl(12,2),'String',num2str(cvs));
  elseif strcmp(action,'act131')
  	cvi = round(get(handl(13,1),'Val'));
    set(handl(13,2),'String',num2str(cvi));
  elseif strcmp(action,'garun')
    set(handl([2:7 10 12 13],[1 3 4]),'Visible','Off');
    for i = 1:2
	  if get(handl(8,i),'Value') == 0
	    set(handl(8,i),'Visible','Off');
	  end
	  if get(handl(9,i),'Value') == 0
	    set(handl(9,i),'Visible','Off');
	  end
	  if get(handl(11,i),'Value') == 0
	    set(handl(11,i),'Visible','Off');
	  end
	end
	set(handl(14,1),'Visible','Off');
    handl(1,1) = figure('Name','GA for Variable Selection Results','Pos',...
	  [401 169 480 320],'Resize','On','NumberTitle','Off');
	set(handl(15,1),'Visible','On','UserData',0);
	set(fig,'UserData',[handl]);
    drawnow
	gaselect(fig,'gogas');
  elseif strcmp(action,'stop')
    set(handl(15,1),'Visible','Off','UserData',1);
  elseif strcmp(action,'resum')
    set(handl(17,1),'Visible','Off');
	set(handl([3 4 6 10 12 13],[1 3 4]),'Visible','Off');
	set(handl(15,1),'Visible','On','UserData',0);
	gaselect(fig,'resum');
  end  
  set(fig,'UserData',[handl]);
  if strcmp(action,'quit')
    ffit = get(handl(4,2),'UserData');
	gpop = get(handl(4,5),'UserData');
    close;
  end
end

function gaselect(fig,action)
%GASELECT Subroutine of GENALG for Variable Selection
%  Please see GENALG

%Copyright Eigenvector Research, Inc. 1995-98
%Modified 2/9/97,2/10/98 NBG

% Variables set by GUI
handl     = get(fig,'userdata'); 
nopop     = 4*round(get(handl(2,1),'Value')/4);       %Size of population
maxgen    = round(get(handl(3,1),'value'));           %Max number of generations
mut       = 1e-3*round(get(handl(4,1),'value')/1e-3); %Mutation Rate
window    = round(get(handl(5,1),'value'));           %Window width for spectral channels
converge  = round(get(handl(6,1),'value'));           % % of pop the same at convergence
begfrac   = round(get(handl(7,1),'value'))/100;       %Fraction of terms included in beginning
cross     = handl(8,3);                               %Double or single cross over, 1 = single
reg       = handl(9,3);                               %Regression method, 0 = MLR, 1 = PLS
maxlv     = round(get(handl(10,1),'value'));          %No. LVs, only needed with reg = 1
cvopt     = handl(11,3);                              %CV option, 0 = random, 1 = contiguous
split     = round(get(handl(12,1),'value'));          %No. subsets to divide data into
iter      = round(get(handl(13,1),'value'));          %No. iterations of CV at each generation
x         = get(handl(2,1),'UserData');               % x-block data
y         = get(handl(3,1),'UserData');               % y-block data
[m,n]     = size(x);
if strcmp(action,'gogas')
  gcount    = 1;
  specsplit = ceil(n/window);
  set(handl(2,2),'UserData',specsplit);
  %Check to see that nopop is divisible by 4
  dp        = nopop/4;
  if ceil(dp) ~= dp
    nopop   = ceil(dp)*4;
    disp('Population size not divisible by 4')
    s       = sprintf('Resizing to a population of %g',nopop);
    disp(s)
  end
  %Generate initial population
  pop     = rand(nopop,specsplit);
  for i = 1:nopop
    for j = 1:specsplit
      if pop(i,j) < begfrac
        pop(i,j) = 1;
      else
        pop(i,j) = 0;
      end
    end
	if sum(pop(i,:)')<0.5
	  colm        = round(rand(1)*specsplit);
	  if colm <0.5
	    colm      = 1;
	  end
	  pop(i,colm) = 1;
	end
  end
end

%Set limit on number of duplicates in population
maxdups = ceil(nopop*converge/100);
%Iterate until dups > maxdups
dat = [x y];
if strcmp(action,'gogas')
  dups     = 0;
  cavterms = zeros(1,maxgen);
  cavfit   = zeros(1,maxgen);
  cbfit    = zeros(1,maxgen);
end
if strcmp(action,'resum')
  specsplit= get(handl(2,2),'UserData');
  fit      = get(handl(2,3),'UserData');
  pop      = get(handl(2,4),'UserData');
  gcount   = get(handl(2,5),'UserData');
  dups     = get(handl(3,2),'UserData');
  cavfit   = get(handl(3,3),'UserData');
  cbfit    = get(handl(3,4),'UserData');
  cavterms = get(handl(3,5),'UserData');
end
% Main Loop
if strcmp(action,'gogas')|strcmp(action,'resum')
  while dups < maxdups
    drawnow
    if get(handl(15,1),'UserData') == 1
      set(handl(2,3),'UserData',fit);
      set(handl(2,4),'UserData',pop);
	  set(handl(2,5),'UserData',gcount);
	  set(handl(3,2),'UserData',dups);
      set(handl(3,3),'UserData',cavfit);
      set(handl(3,4),'UserData',cbfit);
      set(handl(3,5),'UserData',cavterms);
      set(handl(17,1),'Visible','On');
	  set(handl([3 4 6 12 13],[1 3 4]),'Visible','On');
	  if get(handl(9,2),'Value')
	    set(handl(10,[1 3 4]),'Visible','On')
	  end
	  break
    end
    %Shuffle data and form calibration and test sets
    s        = sprintf('At generation %g the number of duplicates is %g',gcount,dups);
    disp(s)
    avterms  = mean(sum(pop'));
    cavterms(gcount) = avterms;
    s        = sprintf('The average number of terms is %g',avterms);
    disp(s)
    dups     = 0; 
    if reg == 1
      fit    = zeros(maxlv,nopop); 
    else
      fit    = zeros(1,nopop);
    end
    %Test each model in population
	drawnow
    for kk = 1:iter       %Number of iterations
      if cvopt == 0
        dat  = shuffle(dat);
      else
        di   = shuffle([2:m]');
        dat  = [dat(di(1):m,:); dat(1:di(1)-1,:)];
      end
      for i = 1:nopop
	    drawnow
      %Check to see that model isn't a repeat
        dflag = 0;
        if i > 1
          for ii = 1:i-1
	           dif = sum(abs(pop(i,:) - pop(ii,:)));
            if dif == 0
              dflag = 1;
              fit(:,i) = fit(:,ii);
            end
          end
        end
        if dflag == 1;
          if kk == 1
            dups = dups + 1;
          end
        else
          %Select the proper columns for use in modeling
          inds = find(pop(i,:))*window;
          [smi,sni] = size(inds);
          if inds(1) <= n
            ninds = [inds(1)-window+1:inds(1)];
          else
            ninds = [inds(1)-window+1:n];
          end
          for aaa = 2:sni
            if inds(aaa) <= n
              ninds = [ninds [inds(aaa)-window+1:inds(aaa)]];
            else
              ninds = [ninds [inds(aaa)-window+1:n]];
            end
          end
          xx = dat(:,ninds);
          [mxx,nxx] = size(xx);
          yy = dat(:,n+1);
          if reg == 1
	  	    lvs = min([nxx,maxlv]);
            %[press,cumpress,minlv] = plscvbkf(xx,yy,split,lvs); 
            [press,cumpress] = crossval(xx,yy,'sim','con',lvs,split,[],1,0);   
            fit(1:lvs,i) = fit(1:lvs,i) + (sqrt(cumpress/m)/iter)';
		    if lvs < maxlv
		      fit(lvs+1:maxlv,i) = Inf*ones(maxlv-lvs,1);
		    end
          else
            press  = mlrcvblk(xx,yy,split);
			fit(i) = fit(i) + sqrt(press/m)/iter;  
          end
        end
      end
    end
    %Sort models based on fitness
	drawnow
	if reg == 1
	  if maxlv ==1
	    mfit       = fit;
	  else
        mfit       = min(fit);
	  end
	else
      mfit         = fit;
	end
    [mfit,ind]     = sort(mfit);
    s              = sprintf('The best fitness is %g',mfit(1));
    disp(s)
    cbfit(gcount)  = mfit(1);
    s              = sprintf('The average fitness is %g',mean(mfit));
    disp(s)
    cavfit(gcount) = mean(mfit);
    pop            = pop(ind,:);
    figure(handl(1,1))
    subplot(2,2,1)
    sumpop         = sum(pop');
    plot(sumpop,mfit,'og'), mnfit = min(mfit); mxfit = max(mfit);
    dfit           = mxfit - mnfit; if dfit == 0, dfit=1; end
    axis([min(sumpop)-1 max(sumpop)+1 mnfit-dfit/10 mxfit+dfit/10])
    if window > 1
      xlabel('Number of Windows')
      s = sprintf('Fitness vs. # of Windows at Generation %g',gcount);
    else
      xlabel('Number of Variables')
	  s = sprintf('Fitness vs. # of Variables at Generation %g',gcount);
    end  
    title(s)
    ylabel('Fitness')
	set(gca,'FontSize',9)
    set(get(gca,'Ylabel'),'FontSize',9)
    set(get(gca,'Title'),'FontSize',9)
    set(get(gca,'Xlabel'),'FontSize',9)
    subplot(2,2,2)
    plot(1:gcount,cavfit(1:gcount),1:gcount,cbfit(1:gcount))
    xlabel('Generation')
    ylabel('Average and Best Fitness')
    title('Evolution of Average and Best Fitness')
	set(gca,'FontSize',9)
    set(get(gca,'Ylabel'),'FontSize',9)
    set(get(gca,'Title'),'FontSize',9)
    set(get(gca,'Xlabel'),'FontSize',9)
    subplot(2,2,3)
    plot(cavterms(1:gcount))
    xlabel('Generation')
    if window > 1
      ylabel('Average Windows Used')
	  title('Evolution of Number of Windows')
    else
      ylabel('Average Variables Used')
	  title('Evolution of Number of Variables')	
    end
	set(gca,'FontSize',9)
    set(get(gca,'Ylabel'),'FontSize',9)
    set(get(gca,'Title'),'FontSize',9)
    set(get(gca,'Xlabel'),'FontSize',9)
    subplot(2,2,4)
    bar(sum(pop))
    if window > 1
      xlabel('Window Number')
      ylabel('Models Including Window')
	  s = sprintf('Models with Window at Generation %g',gcount);
    else
      xlabel('Variable Number')
      ylabel('Models Including Variable')
      s = sprintf('Models with Variable at Generation %g',gcount);
    end
    title(s)
    axis([0 ceil(n/window)+1 0 nopop+2])
	set(gca,'FontSize',9)
    set(get(gca,'Ylabel'),'FontSize',9)
    set(get(gca,'Title'),'FontSize',9)
    set(get(gca,'Xlabel'),'FontSize',9)
    drawnow
    % Check to see if maxgen has been met
    if gcount >= maxgen
      dups = maxdups;
    end
    % Breed best half of population and replace worst half
    pop(1:nopop/2,:) = shuffle(pop(1:nopop/2,:));
    pop((nopop/2)+1:nopop,:) = pop(1:nopop/2,:);
    for i = 1:nopop/4
      for j = 1:cross
        %Select twist point at random
        tp = ceil(rand(1)*(specsplit-1));
        %Twist pairs and replace
	    p1 = (nopop/2)+(i*2)-1;
	    p2 = (nopop/2)+(i*2);
	    p1rep = [pop(p1,1:tp) pop(p2,tp+1:specsplit)];
	    p2rep = [pop(p2,1:tp) pop(p1,tp+1:specsplit)];
        pop(p1,:) = p1rep;
        pop(p2,:) = p2rep;
      end
    end
    %Mutate the population if dups < maxdups
    if dups < maxdups
      [mi,mj] = find(rand(nopop,specsplit)<mut);
      [ms,ns] = size(mi);
      for i = 1:ms
        if pop(mi(i),mj(i)) == 1
          pop(mi(i),mj(i)) = 0;
        else
          pop(mi(i),mj(i)) = 1;
        end
      end
      for i=1:nopop                %nbg 10/27/00, start, check if any row of pop all zero, 
        if isempty(find(pop(i,:)))
          pop(i,1+round(rand(1)*(size(pop,2)-1))) = 1;
        end
      end                          %nbg 10/27/00, end
    end 
    gcount = gcount + 1;
  end
end
%End of Main Loop

if dups >= maxdups
  set(handl([15 17],1),'Visible','Off');
  drawnow
  %Extract unique models from final population
  fpop = zeros(nopop-dups,specsplit);
  unique = 0; dups = 0;
  for i = 1:nopop
    dflag = 0;
    if i > 1
      for ii = 1:i-1
        dif = sum(abs(pop(i,:) - pop(ii,:)));
        if dif == 0
          dflag = 1;
        end
      end 
    end
    if dflag == 1
      dups = dups + 1;
    else
	  unique = unique + 1;
	  fpop(unique,:) = pop(i,:);
    end
  end
  s = sprintf('There are %g unique models in final population',unique);
  disp(s)
  %Testing final population
  if reg == 1
    fit = zeros(maxlv,unique); 
  else
    fit = zeros(1,unique);
  end
  disp('Now testing models in final population')
  for kk = 1:3*iter       %Number of iterations 
    if cvopt == 0
      dat = shuffle(dat);
    else
      di = shuffle([2:m]');
      dat = [dat(di(1):m,:); dat(1:di(1)-1,:)];
    end
    for i = 1:unique
      %Select the proper columns for use in modeling
      inds = find(fpop(i,:))*window;
      [smi,sni] = size(inds);
      if inds(1) <= n
        ninds = [inds(1)-window+1:inds(1)];
      else
        ninds = [inds(1)-window+1:n];
      end
      for aaa = 2:sni
        if inds(aaa) <= n
          ninds = [ninds [inds(aaa)-window+1:inds(aaa)]];
        else
          ninds = [ninds [inds(aaa)-window+1:n]];
        end
      end
      xx = dat(:,ninds);
      [mxx,nxx] = size(xx);
      yy = dat(:,n+1);
      if reg == 1
        lvs = min([nxx,maxlv]);
        %[press,cumpress,minlv] = plscvbkf(xx,yy,split,lvs); 
        [press,cumpress] = crossval(xx,yy,'sim','con',lvs,split,[],1,0);   
        fit(1:lvs,i) = fit(1:lvs,i) + (sqrt(cumpress/m)/(iter*3))';
	    if lvs < maxlv
	  	 fit(lvs+1:maxlv,i) = Inf*ones(maxlv-lvs,1);
        end
      else
        press = mlrcvblk(xx,yy,split);
        fit(i) = fit(i) + sqrt(min(press)/m)/(iter*3);
      end
	  if kk == iter*3
        if reg == 1
          [mf,ind] = min(fit(:,i));
          s = sprintf('Number %g fitness is %g at %g LVs',i,mf,ind);
          %s = sprintf('Number %g fitness is %g at %g LVs',i,min(fit(:,i)),minlv);
        else
          s = sprintf('Number %g fitness is %g',i,min(fit(:,i)));	  
	    end
	    disp(s)
      end
    end
  end
  if reg == 1
    if size(fit,1)==1 %modified 2/10/98
      mfit = fit;
    else
      mfit = min(fit,[],1);
    end %end modification 2/10/98
  else
    mfit = fit;
  end
  [mfit,ind] = sort(mfit);
  s          = sprintf('The best fitness is %g',mfit(1));
  disp(s)
  s          = sprintf('The average fitness is %g',mean(mfit));
  disp(s)
  fpop       = fpop(ind,:);
  ffit       = mfit;
  % Translate the population (in terms of windows) into the
  % actual variables used in the final population.
  if window == 1
    gpop = fpop;
  else
    gpop = zeros(unique,n);
    for jk = 1:unique
      inds = find(fpop(jk,:))*window;
      [smi,sni] = size(inds);
      if inds(1) <= n
        ninds = [inds(1)-window+1:inds(1)];
      else
        ninds = [inds(1)-window+1:n];
      end
      for aaa = 2:sni
        if inds(aaa) <= n
          ninds = [ninds [inds(aaa)-window+1:inds(aaa)]];
        else
          ninds = [ninds [inds(aaa)-window+1:n]];
        end
	  end
      [snmi,snni] = size(ninds);
	  gpop(jk,ninds) = ones(1,snni);
	end
  end  
  set(handl(4,2),'UserData',ffit)
  set(handl(4,5),'UserData',gpop)  
  set(handl(16,1),'Visible','On','String','Save & Quit');
end
