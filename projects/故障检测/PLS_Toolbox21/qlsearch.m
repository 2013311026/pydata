function [x,beta,kin,fopt,flag]=qlsearch(t,u,x0,f0,n,step,dir,flag,Lambda)
%QLSEARCH Function to carry out a quadratic line search for NNPLS
%  Function to carry out a quadratic line search. If line search
%  fails flag=1. A failure occurs if after 10 steps an optimum is
%  not found along search direction.
%
%I/O: [x,beta,kin,fopt,flag] = qlsearch(t,u,x0,f0,n,step,dir,flag,Lam)

%Copyright Thomas Mc Avoy 1994
%Distributed by Eigenvector Research, Inc.
%Modified by BMW 5-9-84

% normalize search direction
% save x0 for restoration if no solution is found
xsave=x0;
dir=dir/norm(dir);
flag1=0;
% flag1 used if line search goes past 2*step, so size of step has to be
% increased. flag1=1 means that optimum is in 2*step range. Initially
% flag1 assumes optimum is out of range.
while flag1==0;
  % Begin line search. If too much backtracking occurs algorithm is reinitialized
  counter=0;
  while counter < 11;
    x1=x0+dir*step;
    beta=x1(1:n+1);
    kin=[x1(n+2:2*n+1)';x1(2*n+2:3*n+1)'];
    [upred,usig]=backprop(t,kin,beta);
    f1=norm(u-upred)^2+Lambda*norm(x1)^2;
    % f1>=f0 means too large a step was taken
    if f1>=f0;
      % Divide step by 2^counter and try again, i.e. backtrack.
      step=step/(2^counter);
      counter=counter+1;
    else
      % go on with optimization. Backtracking has been successful.
      counter=100;    %  100 is a dummy value to stop backtracking
    end
  end
  if counter==100
    flag=0;
  else % only if counter==100 has a lower second point been found
    flag=1; x = 0; fopt = 0;
  end
  % take a second step
  if flag==0;
    x2=x1+dir*step;
    beta=x2(1:n+1);
    kin=[x2(n+2:2*n+1)';x2(2*n+2:3*n+1)'];
    [upred,usig]=backprop(t,kin,beta);
    f2=norm(u-upred)^2+Lambda*norm(x2)^2;
    % calculate optimal step size by fitting a quadratic to 3 points.
    lopt=.5*((-3*step^2)*f0+4*step^2*f1-step^2*f2);
    lopt=lopt/((-step)*f0+2*step*f1-step*f2);
    if (lopt/step)>2;
      step=lopt;
      flag1=0;
      % flag1=0 means optimum is outside range. Increase step.
    else
      % optimum is within range used, i.e. 2*step
      x=x0+lopt*dir;
      beta=x(1:n+1);
      kin=[x(n+2:2*n+1)';x(2*n+2:3*n+1)'];
      [upred,usig]=backprop(t,kin,beta);
      fopt=norm(u-upred)^2+Lambda*norm(x)^2;
      flag1=1; % terminate since optimum has been estimated.
    end
  else
  % terminate since flag=1. Algorithm needs resetting.
  % Perturb original weights for resetting
    beta=xsave(1:n+1);
    kin=[xsave(n+2:2*n+1)';xsave(2*n+2:3*n+1)'];
    beta=.02*randn(1,1)*beta+beta;
    kin=.02*randn(1,1)*kin+kin;
    flag1=1;
  end
end
