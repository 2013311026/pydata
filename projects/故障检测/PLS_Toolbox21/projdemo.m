%PROJDEMO demo of regression projections
%  The PROJDEMO shows an example of the differences
%  between MLR, PCR, and PLS.
%
%I/O: projdemo

%Copyright Eigenvector Research, Inc. 1996-2000
%nbg 12/98
%nbg 11/00 changed figure placement

echo off
home
units = get(0,'Units');
set(0,'Units','pixels')
s = str2mat('The PROJDEMO shows an example of the differences', ...
' between MLR, PCR, and PLS.',' ');
disp(s)
pause

s = str2mat('For this example the data consists of an X-block', ...
' (the regressor) with two variables X1 and X2, and', ...
' a Y-block (the regressand) with one variable.', ...
' Hit a return to see a plot of the data.',' ');
disp(s)
pause

a = get(0,'screensize');
load projdat

h1 = figure('position',[a(3)-440 a(4)-340 400 280]);
highcol = [1 0 0.8];
for ii=1:length(y)
  dlns(ii,1) = plot3([x1(ii,1) x1(ii,1)],[x2(ii,1) x2(ii,1)],[0 y(ii,1)],'-m');
  set(dlns(ii,1),'color',highcol)
  hold on
end
for ii=1:length(y)
  dys(ii,1) = plot3(x1(ii,1),x2(ii,1),y(ii,1),'or');
  set(dys(ii,1),'markerfacecolor',[1 0 0])
end
axis([-2 2 -2 2 0 5]), grid
xlabel('X1'), ylabel('X2'), zlabel('Y')

a = get(0,'screensize');

h2 = figure('position',[a(3)-440 a(2)+20 400 280]);
for ii=1:length(y)
  dxs(ii,1)  = plot(x1(ii,1),x2(ii,1),'or'); hold on
  set(dxs(ii,1),'markerfacecolor',[1 0 0])
end
axis([-2 2 -2 2]), axis('square')
title('X-block Variables')
xlabel('X1'), ylabel('X2')

s1 = ['Figure ',num2str(h1)];
s2 = ['Figure ',num2str(h2)];
home
s = str2mat([s2,' shows a plot of the X2 versus X1 and'], ...
[' ',s1,' shows a plot of the Y variable vs X1 and X2'],' ');
disp(s)
pause

%do pca of x-block
home
[mcx,mx] = mncn([x1,x2]);
[scores,loads,ssq] = pca(mcx,0,[],2);
figure(h2)
plot([-1 1]*loads(1,1)*sqrt(ssq(1,2))*1.96+mx(1,1), ...
     [-1 1]*loads(2,1)*sqrt(ssq(1,2))*1.96+mx(1,2),'-g')
plot([-1 1]*loads(1,2)*sqrt(ssq(2,2))*1.96+mx(1,1), ...
     [-1 1]*loads(2,2)*sqrt(ssq(2,2))*1.96+mx(1,2),'-g')
ang = atan(loads(2,1)/loads(1,1));
ellps(mx,sqrt(ssq(:,2))*1.96,'--b',ang)

figure(h1), hold on
plot3([-1 1]*loads(1,1)*sqrt(ssq(1,2))*1.96+mx(1,1), ...
  [-1 1]*loads(2,1)*sqrt(ssq(1,2))*1.96+mx(1,2),[0 0],'-g')
plot3([-1 1]*loads(1,2)*sqrt(ssq(2,2))*1.96+mx(1,1), ...
  [-1 1]*loads(2,2)*sqrt(ssq(2,2))*1.96+mx(1,2),[0 0],'-g')
ellps(mx,sqrt(ssq(:,2))*1.96,'--b',ang,3)
set(dlns,'color',highcol)

s = str2mat(' ','The solid green lines correspond to the 1st and 2nd', ...
' PCs for a PCA model of the X-block',' ');
disp(s)

s = str2mat('The ellips corresponds to the approximate', ...
' 95% confidence limit for T^2',' ');
disp(s)
pause

[mcy,my] = mncn(y);
bmlr = mcx\mcy;

figure(h2)
plot([0 bmlr(1,1)]+mx(1,1),[0 bmlr(2,1)]+mx(1,2),'-r', ...
  'linewidth',3)

figure(h1)
plot3([0 bmlr(1,1)]+mx(1,1),[0 bmlr(2,1)]+mx(1,2),[0 0],'-r', ...
  'linewidth',3)

home
s = str2mat(' ','The data are mean centered and a MLR regression', ...
' model is calculated.',' ');
disp(s)
s = str2mat('The MLR regression vector bmlr is plotted in', ...
[' ',s2,'. Projecting mean centered X1 and X2 onto bmlr'], ...
' defines a plane of predicted Y values, ymlr i.e.', ...
'    ymlr = X*bmlr + my       (1)', ...
' where my is the mean of the Y values and', ...
' the columns of X have zero mean.',' ');
disp(s)

xpred = [-1.5 -1.5; -1.5 1.5; 2 -1.5; 2 1.5];
ypred = xpred*bmlr+my;
mlrp(1,1) = plot3(xpred([1 2],1),xpred([1 2],2),ypred([1 2],1),'-g');
mlrp(2,1) = plot3(xpred([1 3],1),xpred([1 3],2),ypred([1 3],1),'-g');
mlrp(3,1) = plot3(xpred([2 4],1),xpred([2 4],2),ypred([2 4],1),'-g');
mlrp(4,1) = plot3(xpred([3 4],1),xpred([3 4],2),ypred([3 4],1),'-g');

ypred = mcx*bmlr+my;
for ii=1:length(y)
  set(dlns(ii,1),'zdata',[ypred(ii,1) y(ii,1)],'color',[1 0 1])
end
ii    = find(y<ypred);
lowcol = [0.4 0 .2];
for jj=1:length(ii)
  set(dys(ii,1),'color',lowcol,'markerfacecolor',lowcol)
  set(dxs(ii,1),'color',lowcol,'markerfacecolor',lowcol)
  set(dlns(ii,1),'color',highcol*.5)
end
text(2,-1,7,'RMSEC','fontsize',12)
rmsecmlr = sqrt(sum((y-ypred).^2)/length(y));
s     = sprintf('MLR %3.2f',rmsecmlr);
text(2,-1,6.5,s,'fontsize',12)

pause
home
s = str2mat(' ','The data mean centered are now used to calculate', ...
' a PCR regression model.',' ');
disp(s)
s = str2mat('The PCR regression vector bpcr is now plotted in', ...
[' ',s2,'. Note that bpcr is the 1st PC of a PCA'], ...
' model of X. Projecting mean centered X1 and X2 onto bpcr', ...
' defines a plane of predicted Y values, ypcr i.e.', ...
'    ypcr = X*bpcr + my       (2).', ...
' Note that this plane is different from that defined by', ...
' Equation 1.',' ');
disp(s)

[bpcr,ssqpcr,t,p,eigs] = pcr(mcx,mcy,1,1); bpcr = bpcr';
figure(h2)
plot([0 bpcr(1,1)]+mx(1,1),[0 bpcr(2,1)]+mx(1,2),'-r', ...
  'linewidth',3)

figure(h1)
plot3([0 bpcr(1,1)]+mx(1,1),[0 bpcr(2,1)]+mx(1,2),[0 0],'-r', ...
  'linewidth',3)
temp = get(mlrp(1,1),'color');
set(mlrp,'color',temp*.3)
hold on
ypred = xpred*bpcr+my;
mlrp(1,1) = plot3(xpred([1 2],1),xpred([1 2],2),ypred([1 2],1),'-g');
mlrp(2,1) = plot3(xpred([1 3],1),xpred([1 3],2),ypred([1 3],1),'-g');
mlrp(3,1) = plot3(xpred([2 4],1),xpred([2 4],2),ypred([2 4],1),'-g');
mlrp(4,1) = plot3(xpred([3 4],1),xpred([3 4],2),ypred([3 4],1),'-g');

ypred = mcx*bpcr+my;
for ii=1:length(y)
  set(dlns(ii,1),'zdata',[ypred(ii,1) y(ii,1)],'color',highcol)
  set(dys(ii,1),'color',[1 0 0])
  set(dxs(ii,1),'color',[1 0 0])
end
ii    = find(y<ypred);
for jj=1:length(ii)
  set(dys(ii,1),'color',lowcol,'markerfacecolor',lowcol)
  set(dxs(ii,1),'color',lowcol,'markerfacecolor',lowcol)
  set(dlns(ii,1),'color',highcol*.5)
end
rmsecpcr = sqrt(sum((y-ypred).^2)/length(y));
s     = sprintf('PCR %3.2f',rmsecpcr);
text(2,-1,6,s,'fontsize',12)
pause

home
s = str2mat(' ','The data mean centered are now used to calculate', ...
' a PLS regression model.',' ');
disp(s)
s = str2mat('The PLS regression vector bpls is now plotted in', ...
[' ',s2,'. Note that bpls is between bmlr and bpcr.'], ...
' Projecting mean centered X1 and X2 onto bpls', ...
' defines a plane of predicted Y values, ypls i.e.', ...
'    ypls = X*bpls + my       (3).', ...
' This plane is different from that defined by', ...
' Equations 1 and 2.',' ');
disp(s)

[bpls,ssq,p,q,w,t,u,bin] = pls(mcx,mcy,1,1);
bpls = bpls(1,:)';
figure(h2)
plot([0 bpls(1,1)]+mx(1,1),[0 bpls(2,1)]+mx(1,2),'-r', ...
  'linewidth',3)

figure(h1)
plot3([0 bpls(1,1)]+mx(1,1),[0 bpls(2,1)]+mx(1,2),[0 0],'-r', ...
  'linewidth',3)
temp = get(mlrp(1,1),'color');
set(mlrp,'color',temp*.3)
hold on
ypred = xpred*bpls+my;
mlrp(1,1) = plot3(xpred([1 2],1),xpred([1 2],2),ypred([1 2],1),'-g');
mlrp(2,1) = plot3(xpred([1 3],1),xpred([1 3],2),ypred([1 3],1),'-g');
mlrp(3,1) = plot3(xpred([2 4],1),xpred([2 4],2),ypred([2 4],1),'-g');
mlrp(4,1) = plot3(xpred([3 4],1),xpred([3 4],2),ypred([3 4],1),'-g');

ypred = mcx*bpls+my;
for ii=1:length(y)
  set(dlns(ii,1),'zdata',[ypred(ii,1) y(ii,1)],'color',highcol)
  set(dys(ii,1),'color',[1 0 0])
  set(dxs(ii,1),'color',[1 0 0])
end
ii    = find(y<ypred);
for jj=1:length(ii)
  set(dys(ii,1),'color',lowcol,'markerfacecolor',lowcol)
  set(dxs(ii,1),'color',lowcol,'markerfacecolor',lowcol)
  set(dlns(ii,1),'color',highcol*.5)
end
rmsecpls = sqrt(sum((y-ypred).^2)/length(y));
s     = sprintf('PLS %3.2f',rmsecpls);
text(2,-1,5.5,s,'fontsize',12)

set(0,'Units',units)
clear a ang b bmlr bpcr bpls dlns dxs dys eigs h h1 h2 highcol
clear ii jj loads lowcol mcx mcy mlrp mx my p q s s1 s2 scores
clear ssq ssqdif ssqpcr t temp tsq tsqs u w xpred yold ypred z
