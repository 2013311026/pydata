function [ord1,ord2,ssq,aeigs,beigs] = gram(a,b,tol,scl1,scl2,out)
%GRAM Generalized rank anihilation method 
%  GRAM can be used to determine the response in both of the
%  orders in a pair of matrices that are bilinear, i.e. are
%  the summation over outer products. GRAM finds the joint
%  invariant subspaces that are common to the two input matrices
%  and the ratio of their magnitudes. The inputs are the two
%  response matrices (a) and (b), the number of factors to calculate
%  or tolerance on the ratio of smallest to largest singular
%  value (tol), and the optional inputs of scales for each order
%  (scl1) and (scl2) for producing the plots of the reponse in each
%  of the orders. The outputs are the pure component responses in
%  each of the orders (ord1) and (ord2), the table of eigenvalues
%  and their ratios (ssq), and the eigenvalues for each of the
%  matrices (aeigs) and (beigs). The optional input (out) suppresses
%  output when set to 0 {default=1}.
%
%Example:
%     [ord1,ord2,ssq,aeigs,beigs] = gram(a,b,1,[],[],0);
%
%I/O: [ord1,ord2,ssq,aeigs,beigs] = gram(a,b,tol,scl1,scl2,out);
%
%See also: MWFIT, MPCA, PARAFAC, TLD

%Copyright Eigenvector Research Inc., 1997-2000
%bmw 11/20/97 
%nbg 6/00 (added out)
%nbg 11/00 (added warning on)

[ma,na] = size(a);
[mb,nb] = size(b);
if (ma ~= mb | na ~= nb)
  error('Input matrices must have the same dimension')
end
if nargin<6
  out  = 1;
end
if nargin<5
  scl2 = 1:na;
elseif isempty(scl2)
  scl2 = 1:na;
elseif scl2==0
  scl2 = 1:na;
end
if nargin<4
  scl1 = 1:ma;
elseif isempty(scl1)
  scl1 = 1:ma;
elseif scl1==0
  scl1 = 1:ma;
end
ab = a + b;
if ma > na
  [u,s,v] = svd(ab,0);
else
  [v,s,u] = svd(ab',0);
end
if tol < 1
  tol = length(find(diag(s)/s(1,1) > tol));
end
absq = u(:,1:tol)'*ab*v(:,1:tol);
asq = u(:,1:tol)'*a*v(:,1:tol);
[aa,bb,qq,zz,vv] = qz(asq,absq);
if ~isreal(vv)
  disp('  ')
  disp('Imaginary solution detected')
  disp('Rotating Eigenvectors to nearest real solution')
  vv=simtrans(aa,bb,vv);
end
ord1 = u(:,1:tol)*absq*vv;
ord2 = v(:,1:tol)*pinv(vv');
norms1 = sqrt(sum(ord1.^2));
norms2 = sqrt(sum(ord2.^2));
ord1 = ord1*inv(diag(norms1));
ord2 = ord2*inv(diag(norms2));
ord1 = ord1*diag(sign(mean(ord1)));
ord2 = (ord2*diag(sign(mean(ord2))))';
if out~=0
  subplot(2,1,1)
  plot(scl1,ord1)
  title('Profiles in First Order')
  subplot(2,1,2)
  plot(scl2,ord2)
  title('Profiles in Second Order')
end
ssq = zeros(tol,6);
ssq(:,1) = [1:tol]';

x = zeros(ma*na,tol);
for i = 1:tol
  xy = ord1(:,i)*ord2(i,:);
  x(:,i) = xy(:);
end
aeigs = x\a(:);
beigs = x\b(:);
tssqa = sum(a(:).^2);
tssqb = sum(b(:).^2);
ssq(:,2) = abs(aeigs); 
ssq(:,4) = abs(beigs);
ssq(:,6) = ssq(:,2)./ssq(:,4);
ssq(:,3) = 100*ssq(:,2)/sum(ssq(:,2));
ssq(:,5) = 100*ssq(:,4)/sum(ssq(:,4));
if out~=0
  disp(' ')
  disp('      Results from GRAM: Eigenvalues of A and B Matrices')
  disp(' --------------------------------------------------------------')
  disp('  Comp     ____Matrix__A____       ____Matrix__B____      Ratio')
  disp(' Number    Eigenval      %         Eigenval      %         A/B')
  format = '  %3.0f      %3.2e   %5.2f      %3.2e   %5.2f    %6.2f';
  for i = 1:tol
    tab = sprintf(format,ssq(i,:)); disp(tab)
  end
  disp(' ')
  fraca = sum(sum(((ord1*diag(aeigs)*ord2)-a).^2))/tssqa;
  fracb = sum(sum(((ord1*diag(beigs)*ord2)-b).^2))/tssqb;
  disp(sprintf('Unmodelled Variance in A is %g Percent',(fraca)*100));
  disp(sprintf('Unmodelled Variance in B is %g Percent',(fracb)*100));
  disp('  ')
end

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
