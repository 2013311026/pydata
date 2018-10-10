function [press,fiterr,minlvp,b] = crcvrnd(x,y,split,iter,lv,powers,ss,mc)
%CRCVRND Cross validation for CR models using SDEP
%  Inputs are the matrix of predictor variables (x), matrix
%  of predicted variables (y), number of divisions of the data
%  (split), number of iterations of the cross validation to
%  perform (iter), maximum number of latent variables to calculate (lv),
%  the vector of continuum parameters to be considered (powers),
%  an optional variable (ss) which can be used to make the
%  routine use contiguous blocks of data when set to 1. Outputs are 
%  the prediction residual error sum of squares matrix (press),
%  the calibration fit error sum of squares matrix (fiterr), 
%  number of latent variables and power at minimum PRESS (minlvp),
%  and the final regression vector (b) at minimum PRESS. 
%  
%Note: This cross validation routine is based on the SDEP 
%  or Standard Deviation of Error of Prediction method.
%  The cross validation procedure is repeated after re-ordering
%  the data and the final cumulative PRESS is reported.
%
%I/O: [press,fiterr,minlvp,b] = crcvrnd(x,y,split,iter,lv,powers,ss,mc);
%
%See also: CR, PLS

%Copyright Eigenvector Research, Inc. 1991-98
%Modified BMW 2/94
%Modified BMW 12/98 added inf and 0 support

[mx,nx] = size(x);
[my,ny] = size(y);
if mx ~= my
  error('Number of samples must be the same in both blocks')
end
if nargin < 7
  ss = 0;
end
if nargin < 8
  mc = 1;
end
[mp,np] = size(powers);
press = zeros(np,lv);
clc
ind = ones(split,2);
for i = 1:split
  ind(i,2) = round(i*mx/split);
end 
for i = 1:split-1
  ind(i+1,1) = ind(i,2) +1;
end
xscl = powers;
if any(xscl==inf)
  z = find(xscl==inf);
  xscl(z) = 10^(ceil(log10(max(powers(isfinite(powers)))+.1)));
end
if any(xscl==0)
  z = find(xscl==0);
  xscl(z) = 10^(floor(log10(min(powers(find(powers)))-.00001)));
end
for kk = 1:iter
  if ss == 0
    [garb,inds] = sort(randn(1,mx));
	x = x(inds,:);
	y = y(inds,:);
  else
	if kk ~= 1
	  [garb,inds] = max(randn(1,mx));
	  x = [x(inds+1:mx,:); x(1:inds,:)];
	  y = [y(inds+1:mx,:); y(1:inds,:)];
	end
  end
  for i = 1:split
    home
    s = sprintf('Now working on test set %g of %g for iteration %g',i,split,kk);
    disp(s)

    if mc ~= 0
      [calx,mnsx] = mncn([x(1:ind(i,1)-1,:); x(ind(i,2)+1:mx,:)]);
      testx = scale(x(ind(i,1):ind(i,2),:),mnsx);
      [caly,mnsy] = mncn([y(1:ind(i,1)-1,:); y(ind(i,2)+1:mx,:)]);
      testy = scale(y(ind(i,1):ind(i,2),:),mnsy);
    else
      calx = [x(1:ind(i,1)-1,:); x(ind(i,2)+1:mx,:)];
      testx = x(ind(i,1):ind(i,2),:);
      caly = [y(1:ind(i,1)-1,:); y(ind(i,2)+1:mx,:)];
      testy = y(ind(i,1):ind(i,2),:);
    end
    bbr = cr(calx,caly,lv,powers);
	c = 0;
    for j = 1:np
      for k = 1:lv
	    c = c + 1;
        ypred = testx*bbr((c-1)*ny+1:c*ny,:)';
        press(j,k) = press(j,k) + sum(sum((ypred-testy).^2));
	  end
    end
  end
  surf(xscl,1:lv,press')
  set(gca,'Xdir','reverse')
  set(gca,'Xscale','log')
  set(gca,'Ydir','reverse')
  title('Cumulative PRESS vs. Number of LVs and Power')
  ylabel('Number of Latent Variables')
  zlabel('PRESS')
  if any(powers==inf | powers==0) | (max(powers) > 1 & min(powers) < 1)
    zx = axis;
    axis([min(xscl) max(xscl) zx(3:6)])
    if (max(powers) > 1 & min(powers) < 1)
      set(gca,'Xtick',[min(xscl) 1 max(xscl)])
    else
      set(gca,'Xtick',[min(xscl) max(xscl)])
    end
    xtl = get(gca,'Xticklabel');
    [mxtl,nxtl] = size(xtl);
    space = ' ';
    xtl = [xtl space(ones(mxtl,1),[1 1])];
    if any(powers==inf)
      xtl(mxtl,1:3) = 'PCR';
    end
    if any(powers==0)
      xtl(1,1:3) = 'MLR';
    end
    if (max(powers) > 1 & min(powers) < 1)
      ind0 = find(xtl(:,1)=='0');
      xtl(ind0,1:3) = 'PLS'
    end
    set(gca,'Xticklabel',xtl)
  end
  drawnow
end
[m1,i1] = find(press==min(min(press)));
minlvp = [i1 powers(m1)];
t = sprintf('Minimum PRESS is at %g LVs and Power %g',minlvp(1),minlvp(2));
disp(t)
disp('  ')
disp('Now working on final CR model')
b = cr(x,y,lv,powers);
c = 0;
for j = 1:np
  for k = 1:lv
    c = c + 1;
    ypred = x*b((c-1)*ny+1:c*ny,:)';
    fiterr(j,k) = sum(sum((ypred-y).^2));
  end
end
c = (m1-1)*lv + i1;
b = b((c-1)*ny+1:c*ny,:)';
figure
plot(b), hold on, plot(b,'o'), plot(zeros(nx,1),'-g'), hold off
s = sprintf('Regression Coefficients Best PRESS Model %g LVs Power %g',...
minlvp(1), minlvp(2));
title(s)
xlabel('Variable Number')
ylabel('Regression Coefficient')


