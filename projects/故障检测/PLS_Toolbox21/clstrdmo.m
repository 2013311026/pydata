echo off, home
%CLSTRDMO Demonstrates the CLUSTER function for dendrograms

%Copyright Eigenvector Research 1993-2000
%Modified 5/94, 8/95
%Checked by BMW 3/98
%nbg 11/00 fixed spelling error

echo on

% This script demonstrates the PLS_Toolbox function CLUSTER
% for plotting dendrograms based on K-means or K-nearest
% neighbor (KNN) clustering. It uses data from a 
% Linear Solvation Energy Relationship (LSER) model published 
% by Jay W. Grate. The data consists of the 6 LSER model 
% coefficients for 14 polymers.

% The function will prompt you to choose between K-means
% and K-nearest neighbor (KNN), for scaling options and
% the option to use PCA scores with Mahalanobis distance
% measure. The dendrogram that will be plotted will show
% the distances between the samples (or their scores) and 
% between the means of the sample groups.  

% Let's load the data in and get going.
pause
echo off

poly = [-0.846 .177 1.287 0.556 0.44 .885
-0.391 -0.480 1.298 0.441 0.705 0.807
-1.63 0 2.283 3.032 0.516 0.773
-0.084 -0.417 .602 .698 4.25 0.718
-1.938 -0.189 2.425 6.780 0 1.016
-0.591 -0.016 0.736 2.436 0.224 0.919
-0.766 -0.077 0.366 0.18 0 1.016
-0.571 0.674 0.828 2.246 1.026 0.718
-0.749 0.096 1.628 1.45 0.707 0.831
-1.602 0.495 1.516 7.018 0 0.77
-1.653 -1.032 2.754 4.226 0 0.865
-1.329 -1.538 2.493 1.507 5.877 0.904
-0.486 -0.75 0.606 1.441 3.668 0.709
-1.207 -0.672 1.446 1.494 4.086 0.810];
name = ['SXPHB'
'OV202'
'SXCN '
'SXFA '
'SXPYR'
'PVTD '
'PIB  '
'PVPR '
'PECH '
'PEI  '
'PEM  '
'P4V  '
'ZDOL '
'FPOL '];
disp('This is the matrix of model coefficients'), disp('  ')
disp(poly), pause
disp('These are the names of the polymers'), disp('  ')
disp(name), pause
echo on

% Now that the data is loaded, we can use the CLUSTER function.  
% Note that we have also loaded in a vector containing the 
% names of the polymers.

% When the cluster function starts you will be presented with 
% several options. The first is whether you would like K-means
% or KNN. In K-means the distance between groups of samples is
% defined as the distance between the centroid (multivariate
% mean) of the group. In KNN, the distance between groups is
% defined as the distance between the two nearest neighbors
% of each group.

% The function will also prompt you for the data scaling desired, 
% if you want the distance to be based on PC scores 
% and whether you would like to use a Mahalanobis distance or 
% not.  For this application we like no scaling and no PCA, but 
% you can run it a few times and see what you like.

% As the function runs it displays how it is connecting the 
% samples together, although if you have a fast computer this 
% might go by sort of quick.

pause

cluster(poly,name)
pause

echo on

% You might want to try the function a few times using different
% options to see how the results differ.  

echo off