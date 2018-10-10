function model = simca(data,class,labels)
%SIMCA Soft independent method of class analogy model maker.
%  Develops a SIMCA model, which is really a collection of PCA
%  models, one for each class of data in the data set. The inputs
%  are the data (data) and a vector of class identifiers (class)
%  where each element of class is an integer identifying the
%  class number of the corresponding sample. An optional input,
%  (labels) can be used to label samples on the Q vs. T^2 plots
%  instead of using the class identifiers. SIMCA cross validates
%  the PCA model of each class using leave-one-out cross validation
%  if the number of samples in the class is <= 20. If there are
%  more than 20 samples, the data is split into 10 contiguous
%  blocks. The function SIMCAPRD can be used to make class 
%  predictions for new data using an existing SIMCA model. The 
%  data file SIMCADAT.mat can be used to demonstrate the SIMCA 
%  function.
%
%I/O: model = simca(data,class,labels);
%
%See also: PCA, SIMCAPRD, CROSSVAL

%Copyright Eigenvector Research 1996-2000
%Modified NBG 10/96
%Checked by BMW 1/11/97
%Modified BMW 3/27/98
%Modified BMW 5/16/98
%nbg 11/00 put out=0 in crossval to limit ssqtable prints

[m,n] = size(data);
% Sort the data by class
[class,ind] = sort(class);
data = data(ind,:);
if nargin == 3
  labels = labels(ind,:);
  s = ' ';
  labels = [s(ones(m,1),:) labels];
end
% Determine the number of classes
z = find(diff(class));
[mz,nz] = size(z);
z = [1; z + ones(mz,nz); m+1];
noclass = mz+1;
s = sprintf('There are %g classes in this data set.',noclass);
disp(s), disp('  ')
sflag = 1;
while sflag == 1
  disp('How would you like to scale the data for each class?')
  as = input('Autoscaling (A) or Mean-Centering (M)?  ','s');
  if isempty(as), as = 0; end
  if (as(1) == 'A'|as(1) == 'a')
    sflag = 0; sopt = 3;
  elseif (as(1) == 'M'|as(1) == 'm')
    sflag = 0; sopt = 2;
  else
    disp('  '), disp('Please input either A or M'), disp('  ')
  end
end
sm = max([16 n noclass]);
model = zeros(2,sm);
model(1,1:12) = [clock m n -1 noclass 0 sopt];
% Create a window for cross validation and one for PCA plots
cvwin = figure;
set(cvwin,'Position',[190 190 400 300])
pcwin = figure;
set(pcwin,'Position',[230 150 400 300])
for i = 1:noclass
  disp('  ')
  s = sprintf('Now developing model on class %g',class(z(i)));
  disp(s)
  if nargin == 3
    disp(['First sample in class is ' labels(z(i),:)])
  end
  cinds = z(i):z(i+1)-1;
  cdata = data(cinds,:);
  if (as(1) == 'A'|as(1) == 'a')
    [acdata,mx,sx] = auto(cdata);
  elseif (as(1) == 'M'|as(1) == 'm')
    [acdata,mx] = mncn(cdata);
	sx = ones(1,n);
  end
  disp('Performing cross validation')
  [mac,nac] = size(acdata);
  if min([mac nac])-1 < 2
    disp(sprintf('Not enough data to cross validate Class %g',class(z(i))))
  else
    if mac < 21
      [press,cumpress] = crossval(acdata,[],'pca','loo',min([mac nac])-1,[],[],[],0);
    else
      [press,cumpress] = crossval(acdata,[],'pca','con',min([mac nac])-1,10,[],[],0);
    end
    figure(cvwin)
    semilogy(cumpress,'-or')
    title(sprintf('PRESS Plot for Class %g',class(z(i))));
    ylabel('PRESS')
    xlabel('Number of PCs')
  end
  flag = 'n';
  [smx,snx] = size(acdata);
  while (flag(1) == 'n'|flag(1) == 'N')
    figure(pcwin)
    [scores,loads,ssq,res,q,tsq] = pca(acdata,-1);
	ndata = scale(data,mx,sx);
    nscores = ndata*loads;
    [ms,ns] = size(nscores);
    nresids = sum((ndata-nscores*loads').^2,2);
    if ns > 1
      ntsqs = sum((nscores.^2*inv(diag(ssq(1:ns,2))))')';
    else
      ntsqs = (nscores.^2*inv(diag(ssq(1:ns,2))));
    end
    size(ntsqs);
    figure(pcwin)
    for ii = 1:ns
      plot(1:ms,nscores(:,ii),'+b',cinds,nscores(cinds,ii),'*m');
      pclim = sqrt(ssq(ii,2))*ttestp(.025,smx-ii,2);
      hline(pclim,'--b'), hline(-pclim,'--b')
      ts = sprintf('Scores of all Data on PC %g of Class %g',ii,class(z(i)));
      title(ts)
      pause
    end
	loglog(ntsqs,nresids,'+b',ntsqs(cinds),nresids(cinds),'*m'), grid off
	if nargin == 3
	  text(ntsqs,nresids,labels)
	else
	  for k = 1:m
	    text(ntsqs(k),nresids(k),[' ' int2str(class(k))])
	  end
	end
	s = sprintf('Q vs. T^2 for all Data Projected on Model of Class %g',class(z(i)));
	title(s)
	xlabel('Value of T^2')
	ylabel('Value of Q')
	hline(q), vline(tsq)
	hflag = 1;
	while hflag == 1
	  flag = input('Are you happy with this model? Yes or No?  ','s');
	  if isempty(flag), flag = 0; end
	  if (flag(1) == 'Y'|flag(1) == 'y')
	    hflag = 0;
	  elseif (flag(1) == 'N'|flag(1) == 'n')
	    hflag = 0;
	  else
	    disp('  '), disp('Please input either Y or N'), disp('  ')
	  end
	end
  end
  % Create the model for the class, submod
  submod = zeros(1,sm);
  [smx,spca] = size(scores);
  submod(1,1:16) = [clock smx snx 0 class(z(i)) 0 sopt 0 spca q tsq];
  submod = [submod; zeros(1,sm)];
  submod(2,1:snx) = mx;
  if sopt == 3
    submod = [submod; zeros(1,sm)];
    submod(3,1:snx) = sx;
  end
  reg = zeros(1,sm);
  reg(1,1:spca) = ssq(1:spca,2)';
  submod = [submod; reg];
  reg = zeros(spca,sm);
  reg(1:spca,1:snx) = loads';
  submod = [submod; reg]; 
  % Get the submod stored in the right place
  [ssmx,ssmy] = size(model);
  model(2,i) = ssmx+1;
  model = [model; submod];
end







