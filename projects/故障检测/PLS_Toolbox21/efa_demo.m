echo on
%EFA_DEMO Demonstrates EVOLVFA evolving factor analysis function.
% 
%  This demonstration illustrates the use of the EVOLVFA
%  function in the PLS_Toolbox for evolving factor analysis.
% 
echo off

%Copyright Eigenvector Research, Inc. 1995-98
% Checked by BMW 3/98

echo on

% To start the demonstration of EVOLVFA we must first load
% some data.

pause

load nir_data
purespec = conc\spec1;
clear spec1 spec2
purespec = purespec(1:3,90:150);
lamda    = lamda(1,90:150);
tdat     = [0:.1:1];
conc     = [1 0 0; 1 0.001 0; .9 .4 0; .8 .85 0; .5 .95 0; .3 .7 0;
            .1 .4 .1; 0 .3 .25; 0 .2 .4; 0 0 .5; 0 0 .7];
obspec   = conc*purespec;
noise    = randn(size(obspec))*1e-5;
obspec   = obspec+noise;

pause

% Suppose we have a chemical reaction that is being monitored
% using near infra-red spectroscopy. We would expect the measured
% spectra to evolve with time as the constituents react. Some
% chemical species disappear as they are consumed and others
% appear in the reactor as they are produced resulting in different
% observed spectra with time.

echo off
pause
fig = figure;
plot(lamda,obspec,'-')
xlabel('Wavelength')
ylabel('Absorbance')
title('Near IR Spectra')
axis([980 1100 0 0.006])
drawnow

echo on

% The plot shows NIR spectra taken at 11 different time points as
% the reaction has proceeded. How many species are present in the
% reactor as the reaction proceeds? It's pretty difficult to tell
% just by examining the plot.

% Evolving factor analysis can be used to get information about how
% many independent factors are in the data set at each time step.
% Let's run EVOLVFA and examine it's output. The input variable
% is 'obspec'. The second input ensures that the results are
% plotted and the third, 'tdat', is time data to plot results against.

pause

[egf,egr] = evolvfa(obspec,1,tdat);


% The first step in the forward analysis calculates the eigen
% value of the first measured spectra. Then eigen values are
% calculated of matrices as new measured spectra are appended.

% The forward analysis suggests that 3 independent factors have
% "evolved into" the data set. One factor appears at the onset,
% a second factor rises out of the background noise at time 0.2,
% and a third factor appears at time 0.6.

pause

% Now let's examine results of the reverse analysis. The reverse
% analysis is similar to the forward analysis except that eigen
% values are calculated for the last spectra first, and subsequent
% eigen values are calculated as spectra are appended in a 
% reverse fashion.

% The reverse analysis gives results of when factors
% "evolved out of" the data set, or when factors disappeared 
% from the data set. The results suggest that there is one
% factor remaining at the end of the process, a second factor
% disappeared at time 0.9, and a third factor disappears at
% time 0.7.

pause

% The times for factors appearing and disappearing identified 
% in the evolving factor analysis give hints about when different
% chemical species are present in the process. This is helpful
% when that information is not available at the onset. However, 
% In this example the 'measured' spectra were created from known
% concentrations. Let's plot the original concentration profiles
% and compare our results.

pause
echo off
figure(fig)
plot(tdat,conc,'-')
xlabel('Time')
ylabel('Concentration')
drawnow
echo on

% For this example there are three contituents. The first is
% present at the onset of the reaction decreases and disappears 
% at about time 0.7. A second constituent first appears at time 0.2 
% reaches a maximum and disappears at time 0.9. A third constituent 
% first appears at time 0.6 and persisted to the end of the reaction.

% Results from the evolving factor analysis clearly identified the
% existence of three independent factors. These results can also be
% used to estimate the window of existence for each reactant. If we
% assume that the first reactant to appear was also the first to leave
% we can get a pretty good estimate of the time window of existence 
% for the first reactant. Good estimates for the other two constituents
% could also be gotten under this assumption. A word of caution is
% appropriate. The assumption that first to appear is the first to
% disappear can not always be made. In addition, evolving factor
% analysis identifies independent factors not constituents. Reactants
% that co-vary would not be split out as a separate factor.

echo off
