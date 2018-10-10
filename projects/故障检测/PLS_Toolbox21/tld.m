function model = tld(x,ncomp,scl,plots)
%TLD Trilinear decomposition.
%  The Trilinear decomposition can be used to decompose
%  a 3-way array as the summation over the outer product
%  of triads of vectors. The inputs are the 3 way array
%  (x) and the number of components to estimate (ncomp),
%  Optional input variables include a 1 by 3 cell array 
%  containing scales for plotting the profiles in each
%  order (scl) and a flag which supresses the plots when
%  set to zero (plots). The output of TLD is a structured
%  array (model) containing all of the model elements
%  as follows:
%
%     xname: name of the original workspace input variable
%      name: type of model, always 'TLD'
%      date: model creation date stamp
%      time: model creation time stamp
%      size: size of the original input array
%    nocomp: number of components estimated
%     loads: 1 by 3 cell array of the loadings in each dimension
%       res: 1 by 3 cell array residuals summed over each dimension
%       scl: 1 by 3 cell array with scales for plotting loads
%
%  Note that the model loadings are presented as unit vectors
%  for the first two dimensions, remaining scale information is
%  incorporated into the final (third) dimension. 
%
%I/O: model = tld(x,ncomp,scl,plots);
%
%See also: GRAM, MWFIT, OUTER, OUTERM, PARAFAC

%Copyright Eigenvector Research, Inc. 1998
%By Barry M. Wise
%Modified April, 1998 BMW


dx = size(x);
if (nargin < 3 | ~strcmp(class(scl),'cell'))
  scl = cell(1,3);
end
if nargin < 4
  plots = 1;
end
xu = reshape(x,dx(1),dx(2)*dx(3));
if dx(1) > dx(2)*dx(3)
  [u,s,v] = svd(xu,0);
else
  [v,s,u] = svd(xu',0);
end
uu = u(:,1:ncomp);
xu = zeros(dx(2),dx(1)*dx(3));
for i = 1:dx(1)
  xu(:,(i-1)*dx(3)+1:i*dx(3)) = squeeze(x(i,:,:));
end
if dx(2) > dx(1)*dx(3)
  [u,s,v] = svd(xu,0);
else
  [v,s,u] = svd(xu',0);
end
vv = u(:,1:ncomp);

xu = zeros(dx(3),dx(1)*dx(2));
for i = 1:dx(2)
  xu(:,(i-1)*dx(1)+1:i*dx(1)) = squeeze(x(:,i,:))';
end
if dx(3) > dx(1)*dx(2)
  [u,s,v] = svd(xu,0);
else
  [v,s,u] = svd(xu',0);
end
ww = u(:,1:2);
clear u s v

g1 = zeros(ncomp,ncomp,dx(3));
for i = 1:dx(3)
  g1(:,:,i) = uu'*squeeze(x(:,:,i))*vv;
end
g2 = g1;
for i = 1:dx(3);
  g1(:,:,i) = g1(:,:,i)*ww(i,2);
  g2(:,:,i) = g2(:,:,i)*ww(i,1);
end
g1 = sum(g1,3);
g2 = sum(g2,3);
[aa,bb,qq,zz,ev] = qz(g1,g2);
if ~isreal(ev)
  disp('  ')
  disp('Imaginary solution detected')
  disp('Rotating Eigenvectors to nearest real solution')
  ev=simtrans(aa,bb,ev);
end
ord1 = uu*(g1)*ev;
ord2 = vv*pinv(ev');
norms1 = sqrt(sum(ord1.^2));
norms2 = sqrt(sum(ord2.^2));
ord1 = ord1*inv(diag(norms1));
ord2 = ord2*inv(diag(norms2));
ord1 = ord1*diag(sign(mean(ord1)));
ord2 = ord2*diag(sign(mean(ord2)));
ord3 = zeros(dx(3),ncomp);
xu = zeros(dx(1)*dx(2),ncomp);
for i = 1:ncomp
  xy = ord1(:,i)*ord2(:,i)';
  xu(:,i) = xy(:);
end
for i = 1:dx(3)
  y = squeeze(x(:,:,i));
  ord3(i,:) = (xu\y(:))';
end
if plots ~= 0
  h1 = figure('position',[170 130 512 384],'name','TLD Loadings');
  subplot(3,1,1)
  if ~isempty(scl{1})
    if dx(1) < 50
      plot(scl{1},ord1,'-+')
    else
      plot(scl{1},ord1,'-')
    end
  else
    if dx(1) < 50
      plot(ord1,'-+')
    else
      plot(ord1,'-')
    end
  end
  title('Profiles in First Order')
  subplot(3,1,2)
  if ~isempty(scl{2})
    if dx(2) < 50
      plot(scl{2},ord2,'-+')
    else
      plot(scl{2},ord2,'-')
    end
  else
    if dx(2) < 50
      plot(ord2,'-+')
    else
      plot(ord2,'-')
    end
  end
  title('Profiles in Second Order')
  subplot(3,1,3)
  if ~isempty(scl{3})
    if dx(3) < 50
      plot(scl{3},ord3,'-+')
    else
      plot(scl{3},ord3,'-')
    end
  else
    if dx(3) < 50
      plot(ord3,'-+')
    else
      plot(ord3,'-')
    end
  end
  title('Profiles in Third Order')
end
loads = cell(1,3);
loads{1} = ord1;
loads{2} = ord2;
loads{3} = ord3;
xhat = outerm(loads);
dif = (x-xhat).^2;
res = cell(1,3);
res{1} = sum(sum(dif,3),2);
res{2} = sum(sum(dif,3),1)';
res{3} = squeeze(sum(sum(dif,2),1));
if plots ~= 0
  figure('position',[145 166 512 384],'name','TLD Residuals')
  subplot(3,1,1)
  if ~isempty(scl{1})
    if dx(1) < 50
      plot(scl{1},res{1},'-+')
    else
      plot(scl{1},res{1},'-')
    end
  else
    if dx(1) < 50
      plot(res{1},'-+')
    else
      plot(res{1},'-')
    end
  end
  title('Residuals in First Order')
  subplot(3,1,2)
  if ~isempty(scl{2})
    if dx(2) < 50
      plot(scl{2},res{2},'-+')
    else
      plot(scl{2},res{2},'-')
    end
  else
    if dx(2) < 50
      plot(res{2},'-+')
    else
      plot(res{2},'-')
    end
  end
  title('Residuals in Second Order')
  subplot(3,1,3)
  if ~isempty(scl{3})
    if dx(3) < 50
      plot(scl{3},res{3},'-+')
    else
      plot(scl{3},res{3},'-')
    end
  else
    if dx(3) < 50
      plot(res{3},'-+')
    else
      plot(res{3},'-')
    end
  end
  title('Residuals in Third Order')
end

% Bring the loads back to the front
if plots ~= 0
  figure(h1)
end

model = struct('xname',inputname(1),'name','TLD','date',date,'time',clock,...
  'size',dx,'nocomp',ncomp);
model.loads = loads;
model.res = res;
model.scale = scl;


function Vdd=simtrans(aa,bb,ev);
%SIMTRANS Similarity transform to rotate eigenvectors to real solution
Lambda = diag(aa)./diag(bb);
n=length(Lambda);
[t,o]=sort(Lambda);
Lambda(n:-1:1)=Lambda(o);
ev(:,n:-1:1)=ev(:,o);

Theta = angle(ev);
Tdd = zeros(n);
Td = zeros(n);
ii = sqrt(-1);

k=1;
while k <= n
  if k == n
    Tdd(k,k)=1;
    Td(k,k)=(exp(ii*Theta(k,k)));
    k = k+1;
  elseif abs(Lambda(k))-abs(Lambda(k+1)) > (1e-10)*abs(Lambda(k)) 
    %Not a Conjugate Pair
    Tdd(k,k)=1;
    Td(k,k)=(exp(ii*Theta(k,k)));
    k = k+1;
  else 
    %Is a Conjugate Pair
    Tdd(k:k+1,k:k+1)=[1, 1; ii, -ii];
    Td(k,k)=(exp(ii*0));  
    Td(k+1,k+1)=(exp(ii*(Theta(k,k+1)+Theta(k,k))));
    k = k+2;
  end
end
Vd = ev*pinv(Td);
Vdd = Vd*pinv(Tdd);
if imag(Vdd) < 1e-3
   Vdd = real(Vdd);
end
