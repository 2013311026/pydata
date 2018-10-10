echo on, home
%MDDEMO Demonstrates MDPCA for PCA with missing data 

% This script demos the mdpca function.  It takes the pca data 
% from the PLS_Toolbox and leaves out 1% of the data at random.  
% Results can be compared to using pca on the original data 
% with nothing left out.

% The pcadata will be loaded and mean centered.
pause

echo off
%Copyright Eigenvector Research 1992-2000
%Modified May 1994
%Modified April 1997
%Modified BMW 3/98
%nbg 11/00 nbg flag ==> NaN

load pcadata
mpart1 = mncn(part1/10);
[m,n] = size(mpart1);
echo on

% Now we can use the pca function to do pca the usual 
% way on the original data.  The scores and loading will be 
% calculated but the plots will be supressed.
pause

[oscores,oloads,ssq,res,q,tsq] = pca(mpart1,0,1:m,4);
pause

% Now 1% of the data will be left out at random and replaced
% with NaN (alternative might use flag=9999).

echo off
x = rand(m,n);
missing = [];
for i = 1:m
  for j = 1:n
    if x(i,j) > 0.99
      mpart1(i,j) = NaN;
      %mpart1(i,j) = 9999;         %nbg 11/00
      missing = [missing; [i j]];
    end
  end
end
pause
echo on
% We'll now use the mdpca function on the data.  The function 
% will iterate until the estimated values of the missing data 
% converge.  We'll use a tolerance of 0.001 rather than the 
% default of 0.00001.
pause

%[scores,loads,estdata] = mdpca(mpart1,4,9999,0.001);   %use if flag==9999
[scores,loads,estdata] = mdpca(mpart1,4,[],0.001);      %flag = [] implies flag==NaN
pause

% We can compare the scores and loadings by plotting them on top
% of each other.
pause
echo off
 
for i = 1:4
  if oscores(:,i)'*scores(:,i) < 0
    scores(:,i) = -scores(:,i);
    loads(:,i) = -loads(:,i);
  end
end
  
plot(scores,'+'), hold on,
plot(oscores,'-'), hold off, shg
title('Original scores (solid) and estimated scores (+)')
xlabel('Sample Number')
ylabel('Score')
pause
echo on

% We can also compare the loadings vectors.
echo off
pause

plot(loads,'-'), hold on, plot(oloads,'--'), hold off, shg
title('Original loadings (dashed) and estimated loadings (solid)')
xlabel('Variable Number')
ylabel('Loading')
