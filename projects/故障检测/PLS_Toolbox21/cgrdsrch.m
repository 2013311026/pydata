function x=cgrdsrch(beta,kin,t,u)
%CGRDSRCH Conjugate gradient optimization for NNPLS
%  Routine to carry out optimization using a conjugate gradient approach
%  check is relative change in objective function. It must be < .00005
%  check1 is relative change in network parameters. It must be < .0001
%  Only 20 passes through algorithm are used (kount=20) .  Each pass
%  uses 10 conjugate gradient directions, unless line search fails. Setting
%  a different starting value for kount gives more passes.  A warning is printed
%  if algorithm fails to converge after 20 passes. If this warning appears
%  it is a good idea to run code so inner relationsships are plotted.
%  A quadratic line search, qlsearch.m, is used, and gradients are 
%  calculated analytically by gradnet.m.
%
%I/O: x = cgrdsrch(beta,kin,t,u);

%Copyright Thomas Mc Avoy 1994
%Distributed by Eigenvector Research, Inc.
%Modified by BMW 5-8-95
	
check=1.;
check1=1.;
kount=0;
% Save weights in case no improvement is achieved
xsave=[beta(:,1);(kin(1,:))';(kin(2,:))'];
flag=0; % flag=1 indicates a failure of line search
Lambda=.0002; % penalty on large weights
% flag=1 means that algorithm needs to be re-initialized
while (check>.00005 | check1>.0001) & kount<20;
  [upred,usig]=backprop(t,kin,beta);
  % backprop calculates net predictions, upred, and sigmoid outputs, usig
  x0=[beta(:,1);(kin(1,:))';(kin(2,:))'];
  n=length(kin(1,:));
  grd0=gradnet(t,u,beta,kin,Lambda);
  % gradnet analytically calculates gradients
  % grd0 is gradient at starting parameters
  f0=(norm(u-upred))^2+Lambda*(norm(x0))^2;
  % f0 is function to be minimized
  step0=.25*norm(grd0);
  % Step size = size of gradient/4
  dir=-grd0;
  count=0;
  ratio=1.;
  % count determines number of conjugate steps taken before algorithm 
  % is re-initialized to a gradient direction.
  [x,beta,kin,fopt,flag]=qlsearch(t,u,x0,f0,n,step0,dir,flag,Lambda);
  % qlsearch is a quadratic line search. flag=1 means that re-initialization
  % is necessary. If the ratio of successive gradients drops below .4 then
  % re-initialization also takes place.  qlsearch gives an estimate of the 
  % optimum x along the search direction.
  while (check>.00005 | check1>.0001) & count<10 & flag==0 & ratio>.4;
    [upred,usig]=backprop(t,kin,beta);
    f1=norm(u-upred)^2+Lambda*norm(x)^2;
    % check for convergence
    check=abs((f1-f0)/f1);
    check1=norm(x0-x)/norm(x);
    % update saved values
    x0=x;
    f0=f1;
    grd1=gradnet(t,u,beta,kin,Lambda);
    step=.25*norm(grd1);
    ratio=step/step0;
    dir1=-grd1+dir*ratio^2;
    dir=dir1;
    step0=step;
    % dir1 and dir are conjugate directions
    % continue line search starting at x.
    [x,beta,kin,fopt,flag]=qlsearch(t,u,x,f1,n,step,dir1,flag,Lambda);
    count=count+1;
  end;
  kount=kount+1;
  flag=0;
  % print warning if kount=20
  if kount==20;
    disp('20 conjugate gradient steps have been taken without convergence')
  end
end
% The following statements check if x=[].  If so the 
% conjugate gradient routine was unable
% to improve on the initial values of the network weights.  
% This condition could indicate that
% large weights are involved and Lambda needs to be increased.
if isempty(x)
  x=xsave;
  disp('The conjugate Gradient Routine could not improve the network weights')
  disp('It may be necessary to increase the size of Lambda to avoid large weights')
  disp('Lambda appears in the following routines: cgrdsrch, fun1, and gradnet1')
  disp('The last 2 routines are used with leastsq from the MATLAB optimization toolbox')
end
