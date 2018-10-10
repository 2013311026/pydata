function cluster(dat,labels,fig00)
%CLUSTER KNN and K-means cluster analysis with dendrograms
%  This function performs a cluster analysis using either
%  the K Nearest Neighbor (KNN) or K-means clustering 
%  algorithm and plots a dendrogram. Inputs are the 
%  data matrix (dat), and an optional matrix of sample
%  labels (labels). The output of the function is a 
%  dendrogram showing the distances between the samples.
%  If labels is not specifed the sample numbers will be 
%  used in the plots instead. The function will prompt the
%  user to choose between KNN and K-means, data scaling 
%  options, and an option to do PCA on the data and base 
%  the distance measure on the raw scores or on a 
%  Mahalanobis distance measure.
% 
%I/O: cluster(dat,labels);
%
%See also: GCLUSTER, CLSTRDMO for a demo of CLUSTER.

%Copyright Eigenvector Research, Inc. 1993-99
%Modified BMW 5/94,2/95, NBG 10/96,4/99

if nargin<3
  fig00 = 0;
  disp('  ')
  disp('Would you like knn or k-means clustering?')
  copt = input('knn = 1, k-means = 2 ');
  if isempty(copt) %added 4/20/99
    copt = 1;
  end
  disp('  ')
  disp('Would you like to autoscale or mean center the data?')
  f1 = input('autoscale = 1, mean center = 2 ');
  if isempty(f1)  %added 4/20/99
    f1 = 1;
  end
  if nargin<2
    labels = [];
  end
else
  handl = get(fig00,'userdata');
  if get(handl(3,1),'Value')==1
    copt  = 1;
  else
    copt  = 2;
  end
  f1    = handl(1,2);
end
if f1 == 1
  dat = auto(dat);
elseif f1 == 2
  dat = mncn(dat);
end
if fig00==0
  disp('  ')
  f2 = input('Would you like to use PCA on the data? Yes = 1 ');
  if isempty(f2)
    f2 = 0;
  end
else
  f2  = handl(1,4);
end
if f2 == 1
  if fig00~=0
    figure(fig00);
	set(handl(2,3),'String',['Enter number of PCs to use at the command',...
	  ' line in the COMMAND window.']);
  end
  [scores,loads,ssq,res,q,tsq] = pca(dat,0);
  if fig00==0
    disp('  ')
    f3 = input('Would you like to use a Mahalanobis distance measure? Yes = 1 ');
    if isempty(f3)
	    f3 = 0;
	  end
  else
    f3 = handl(1,8);
  end
  if f3 == 1
    dat = auto(scores);
  else  
    dat = scores;
  end
end
[m,n] = size(dat);
adat = [(1:m)' zeros(m,m) dat];
ins = zeros((m-1)*2,m+2);
for k = 1:m-1
  if copt == 2
    dist = ones(m-k,m-k)*inf;
    for i = 2:m-k+1
      for j = 1:i-1
        dist(i-1,j) = sqrt(sum((adat(i,m+2:m+n+1) - adat(j,m+2:m+n+1)).^2));
      end
    end
    [mind,yind] = min(dist);
    [mind,xind] = min(mind);
    yind = yind(xind);
    s = sprintf('Link %g connects the following samples',k);
    disp(s)
    [i1,i2] = size(find(adat(yind+1,1:m)));
    [i3,i4] = size(find(adat(xind,1:m)));
    disp(adat([xind yind+1]',1:max([i2 i4])))
    ins(k*2-1:k*2,1:m) = adat([xind yind+1]',1:m);
    ins(k*2-1:k*2,m+1) = [1 1]'*mind;
    nsamp = zeros(1,m+n+1);
    sampvect = [adat(xind,1:m) adat(yind+1,1:m)];
    samplocs = find(sampvect);
    sampnos = sampvect(samplocs);
    [d,ns] = size(sampnos);
    nsamp(1,m+2:m+n+1) = sum(dat(sampnos',:))/ns;
    nsamp(1,1:ns) = sampnos;
    nsamp(1,m+1) = mind;
    ins(k*2-1,m) = adat(xind,m+1);
    ins(k*2,m) = adat(yind+1,m+1);
    adat = delsamps(adat,[xind yind+1]);
    adat = [adat; nsamp];
  else
    if k == 1
      dist = zeros(m,m);
      for i = 1:m
        for j = 1:i
          if j == i
            dist(i,j) = inf;
          else
            dist(i,j) = sqrt(sum((dat(i,:)-dat(j,:)).^2));
            dist(j,i) = dist(i,j);
          end
        end
      end
    end
    [min1,ind1] = min(dist);
    [min2,ind2] = min(min1);
    r = ind1(ind2);
    c = ind2;
    s = sprintf('Link %g connects sample %g to sample %g',k,r,c);
    disp(s)
    ins(k*2-1:k*2,1) = [c r]';
    ins(k*2-1:k*2,m+1) = [1 1]'*min2;
    % Segment to order samples here
    if k == 1
      groups = zeros(round(m/2),m);
      groups(1,1:2) = [c r]; gi = 1;
    else
      % does r belong to an existing group?
      [zr1,zr2] = find(groups==r);
      % does c belong to an existing group?
      [zc1,zc2] = find(groups==c);
      % If neither c nor r belong to a group they form their own
      if isempty(zr1)   % == [];  %r doesn't belong to a group
        if isempty(zc1) % == [];  %c doesn't belong to a group
          gi = gi+1;
          groups(gi,1:2) = [c r];
        else   % r doesn't belong by c does, add r to group c
          sgc = size(find(groups(zc1(1),:)));   %how big is group c
          groups(zc1(1),sgc(2)+1) = r;
        end
      else   %r does belong to a group
        if isempty(zc1) % == [];  %c doesn't belong to a group, add c to group r
          sgr = size(find(groups(zr1(1),:)));   %how big is group r
          groups(zr1(1),sgr(2)+1) = c;
        else  %both c and r belong to groups, add group c to group r
          sgr = size(find(groups(zr1(1),:)));  %size of group r
          sgc = size(find(groups(zc1(1),:)));  %size of group c
          groups(zr1(1),sgr(2)+1:sgr(2)+sgc(2)) = groups(zc1,1:sgc(2));
          groups(zc1,:) = zeros(1,m);
        end
      end
    end
    dist(r,c) = inf;
    dist(c,r) = inf;
    z1 = find(dist(r,:)==inf);
    z2 = find(dist(c,:)==inf);
    z1n = z1(find(z1~=r));
    z1n = z1n(find(z1n~=c));
    z2n = z2(find(z2~=c));
    z2n = z2n(find(z2n~=r));
    ins(k*2-1,2:1+length(z2n)) = z2n; % ins(k*2-1,2:1+max(size(z2n))) = z2n;
    ins(k*2,2:1+length(z1n)) = z1n;   % ins(k*2,2:1+max(size(z1n))) = z1n;
    if length(z2n) >= 1               % if max(size(z2n)) >= 1
      [zbi,zbj] = find(ins(1:k*2-2,1:m-1)==ins(k*2-1,1));
      zb = max(zbi);
      ins(k*2-1,m) = ins(zb,m+1);
    end
    if length(z1n) >= 1               % if max(size(z1n)) >= 1
      [zbi,zbj] = find(ins(1:k*2-2,1:m-1)==ins(k*2,1));
      zb = max(zbi);
      ins(k*2,m) = ins(zb,m+1);
    end
    z = [z1 z2];
    sz = size(z);
    for j = 1:max(sz);
      for k = 1:max(sz);
        dist(z(j),z(k)) = inf;
      end  
    end
  end
end
if copt == 2
  order = adat(1,1:m);
else
  [z1,z2] = find(groups(:,1));
  order = groups(z1,:); clear groups
end
for i = 1:2*(m-1)
  ind = find(ins(i,1:m-1));  %Find non-zero elements of in
  [mi,ni] = size(ind);       %Determine the number of elements
  if ni == 1                 %   If the number = 0
    ins(i,m+2) = find(order==ins(i,1));   %set yval equal to its order
  else                       % Otherwise
    subords = zeros(1,ni);
    for j = 1:ni
      subords(j) = find(order==ins(i,j));
    end
    ins(i,m+2) = (min(subords)+max(subords))/2;
  end
end
maxdist = max(ins(:,m+1))*1.15;
if isempty(labels)
%if nargin == 1
  mindist = -maxdist*0.08;
else
  [mn,mm] = size(labels);
  mindist = -maxdist*0.03*mm;
end
if fig00~=0
  figure(handl(1,1));
else
  figure
end
for i = 1:m-1
  if ins(2*i-1,m) > ins(2*i-1,m+1);
    rind = find(ins(:,m) == ins(2*i-1,m+1));
    ins(2*i-1:2*i,m+1) = max([ins(2*i-1,m) ins(2*i,m)])*[1 1]';
    if rind > 0
      ins(rind,m) = max([ins(2*i-1,m) ins(2*i,m)]);
    end
  elseif ins(2*i,m) > ins(2*i,m+1)
    rind = find(ins(:,m) == ins(2*i,m+1));
    ins(2*i-1:2*i,m+1) = max([ins(2*i-1,m) ins(2*i,m)])*[1 1]';
    if rind > 0
      ins(rind,m) = max([ins(2*i-1,m) ins(2*i,m)]);
    end
  end
  plot([ins(2*i-1,m) ins(2*i-1,m+1)],ins(2*i-1,m+2)*[1 1],'-r')
  hold on
  plot([ins(2*i,m) ins(2*i,m+1)],ins(2*i,m+2)*[1 1],'-r')
  plot(ins(2*i-1,m+1)*[1 1],[ins(2*i,m+2) ins(2*i-1,m+2)],'-r')
end
grid off
if copt == 1
  xlabel('Distance to K-Nearest Neighbor')
else
  xlabel('Distance to K-Means Nearest Group')
end
for i = 1:m
  ind = find(order==i);
  if isempty(labels)
%  if nargin < 2
    s = int2str(i);
    text(mindist,ind,s)
  else
    text(mindist,ind,labels(i,:))
  end
end
axis([mindist maxdist 0 m+1]);
hold off
if f2 == 1
  if f3 == 1
    s = sprintf('Dendrogram Using Mahalanobis Distance on %g PCs',n);
    title(s)
  elseif f1 == 1
    s = sprintf('Dendrogram Using Autoscaling and Distance on %g PCs',n);
    title(s)
  elseif f1 == 2
    s = sprintf('Dendrogram Using Mean-Centering and Distance on %g PCs',n);
    title(s)
  else
    s = sprintf('Dendrogram Using No Scaling and Distance on %g PCs',n);
    title(s)
  end
else
  if f1 == 1
    title('Dendrogram Using Autoscaled Data')
  else
    title('Dendrogram Using Unscaled Data')
    if f1 == 2
      disp('Mean-centering is the same as no scaling if')
      disp('PCA is not used on the data.')
    end
  end
end
zc = get(gcf,'Color');
set(gca,'YColor',zc);
    
