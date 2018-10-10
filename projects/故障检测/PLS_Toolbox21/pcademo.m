echo off
%PCADEMO Demonstrates the PCA and PCAPRO functions
echo on
clc

% This is a demonstration of the 'pca' and 'pcapro' functions
% in the PLS_Toolbox.  Just follow along and hit the return
% key when when you are ready to go on.
echo off

%Copyright Eigenvector Research, Inc. 1991-2000
%Modified bmw 11/93
%Modified bmw 3/98
%nbg 11/00 changed lvs in crossval from 10 to 8

echo on

% For this demo to run correctly the data set 'pcadata'
% must be available, along with the functions 'pca', 'pcapro',
% 'pltloads', 'pltscrs', 'ftest' and 'crossval'.

% Now hit any key to continue (do this each time you are ready
% to go on).

pause 

% First we must load the data set PCADATA.

load pcadata

% To find out what we have just loaded, use the 'whos' function
pause

whos

% So we have two data sets of different sizes, part1 and part2.
% The first part has 300 samples and the second part
% has 200 samples.  Both of course have 10 variables.
% Lets take a look at part1 first. Hit a key when ready for a plot.
pause

echo off
plot(part1);
title('Data for PCA example, Part 1')
xlabel('Time')
ylabel('Variable Values')
pause
echo on

% This looks pretty messy, so lets use PCA to simplfy the
% picture.  The first thing we want to do is use the
% 'autoscale' function since the variables span such a large
% size range.

[apart1,meanpart1,stdspart1] = auto(part1);

% We can now plot the autoscaled data to see if that looks
% any better.  Hit any key when ready to plot.
pause

echo off
plot(apart1);
title('Autoscaled Data for PCA example, Part 1')
xlabel('Time')
ylabel('Variable Values')
pause
echo on

% If anything, this looks worse, so lets try out the pca modelling.
% I'm going to need your help once the 'pca' function starts.
% You will have to chose the number of principal components 
% to keep in the model. First lets take a look at the cross validation
% results from this data. We'll generate them using the crossval
% function. Hit a key when you are ready.
pause
[press,cumpress] = crossval(apart1,[],'pca','con',8,3);
echo off
semilogy(cumpress,'-ob')
title('PRESS Results for PCA Model')
xlabel('Number of PCs')
ylabel('Cumulative PRESS')
echo on

% In this data set 4 principal components is a good choice.
% The 'pca' function will make a lot of plots, just read the labels
% to find out what they are.  It will also print out a table of the 
% variance captured by the model.

% Hit any key when ready to go.
pause

[scores,loads,ssq,res,q,tsq] = pca(apart1,1);
pause

% We now have a PCA model with as many PCs as you chose.  We might
% also want to look at some of the scores vectors plotted against
% each other.  We can do this using the 'pltscrs' function.
% Try ploting the first vs. second PCs and some other combinations.
% You can also do 3-D plots using 3 of the PCs. The routine 
% will plot them with the sample number if you want, but it is 
% pretty messy!

pause
pltscrs(scores)

% These plots really aren't all that interesting, but I wanted you
% to know how to make scores plots.  We can also plot pairs of
% loadings (or triples) against each other using 'pltloads'.
% The 'pltloads' function can also utilize a "vector" of
% labels for the variables.  We can input these variable names
% by creating a new variable where each "row" is one of the
% variable names.  Note that all variables must have the same
% number of letters!
labels = ['plenum-1'; 'plenum-2'; 'plenum-3'; 'deepest '; 'deep-2  '; ...
 'deep-3  '; 'midlevel'; 'shallow '; 'surface '; 'coldcap '];
pause
pltloads(loads,labels)

% Now say that we'd like to compare the data from part2 to
% the data from part 1 using the PCA model from part1.
% The first step is to use the same scaling with the part 2 data.

spart2 = scale(part2,meanpart1,stdspart1);
pause

% Note how we have used the means and standard deviations from
% part1 to scale part2.  We can now use the 'pcapro' function
% to compare the data sets.

[newscores,resids,tsqs] = pcapro(spart2,loads,ssq,q,tsq,1);
pause

% As you can see, the scores from part2 don't fall between the
% limits calculated for part1 after about the first 100 samples.
% The residual is also much larger and the T^2 value is too.
% This indicates that a major change has taken place in the process.

% We might want to look at these together on the same scatter plot.
pause

echo off
plot(scores(:,1),scores(:,2),'og',newscores(:,1),newscores(:,2),'+r');
title('Scores on First Two PCs for Old (0) and New (+) Data');
xlabel('Score on First PC from Old Model');
ylabel('Score on Second PC from Old Model');
pause
echo on

% This plot makes it even more evident that the second 
% half of the part2 data is very different.
% We can see that only the data in the first half of
% part2 could be classed in part1. 
