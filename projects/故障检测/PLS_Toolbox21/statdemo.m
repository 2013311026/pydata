echo off, clc
%STATDEMO Elementary stats, t test, F test and AVOVA

%Copyright Eigenvector Research, Inc. 1994-99

load statdata
echo on

% This script demonstrates the elementary statistics
% functions in the PLS_Toolbox including the t test,
% F test and one and two way analysis of variance routines.
% The development in the script follows Chapter 2 of 
% "Chemometrics" by Sharaf, Illman and Kowalski, John Wiley
% & Sons, 1986.

% First lets consider the t test. A t test can be used to
% compare the means of two samples. For instance, suppose
% that we have tested the percent yield from a given
% chemical reaction using two different catalysts
% and would like to determine if the difference in yield
% is significant. A table of our data is below.
pause
echo off
disp('  ')
disp('Percent yield with A and B')
disp('    A      B')
disp(a1dat(:,1:2))
disp('   ')
disp('Mean yield with A and B')
disp(mean(a1dat(:,1:2)));
disp('  ')
disp('Yield variance with A and B')
disp(std(a1dat(:,1:2)).^2);
echo on
% For the moment, lets assume that we know that the 
% populations for each of the catalysts should have
% equal variances, even though it is apparent that
% our sample variances are not equal.
pause

% The t test statistic is defined as
%
%         [(x1bar-x2bar)-(mu1-mu2)][n1+n2-2]^0.5 
% t = -----------------------------------------------
%  v  [1/n1 + 1/n2]^0.5 [(n1-1)s1^2 + (n2-1)s2^2]^0.5
%
% where
% n1, n2     = size of first and second samples
% mu1, mu2   = true mean of first and second populations
% s1^2, s2^2 = variance of first and second samples
% v          = n1 + n2 - 2 is the degress of freedom
%
pause

% The quantity
%
%     (n1-1)s1^2 + (n2-1)s2^2
%     -----------------------
%           n1 + n2 - 2
% 
% is the pooled variance and is the best unbiased estimator
% of the population variance.

% If we assume that mu1 = mu2 then the t statistic can
% be calculated as follows
pause
echo off

t = abs(((mean(a1dat(:,1))-mean(a1dat(:,2)))*sqrt(14))/...
    (sqrt(1/4)*sqrt(7*std(a1dat(:,1)).^2 + 7*std...
	(a1dat(:,2)).^2)))
echo on
	
% We can now compare this value of t to the value from
% a t table calculated by the TTESTP function. The first
% input to the function is the probability point corresponding
% to our desired confidence level. If we want 95% confidence,
% we would choose .025 since 100(1-2*(.025)) = 95%. The second
% input is the degrees of freedom in the problem, which in
% this case is 14 (8 + 8 - 2). The final input is a flag
% which tells the function that we wish to input a probability
% point and have it return the value of the t statistic 
% instead of the other way around (which we will use shortly).

tt = ttestp(.025,14,2)
pause

% As you can see, the value of t is greater than the value
% expected from the t test function, telling us that the 
% means are significantly different at the 95% level. Note
% however, that if we had chosen 99% confidence levels, 
% the TTESTP function would yield

tt = ttestp(.005,14,2)

% and the difference between catalysts would not be significant
% at the 99% level. It is also possible to calculate
% the exact confidence level at which the test fails using
% the inverse test as follows:
pause

tt = ttestp(t,14,1)

% Thus, we see that the hypothesis of equal means fails
% at the 
disp(100*(1-2*tt))
% percent confidence level. Note that we input the t value
% calculated above with the correct number of degrees of
% freedom (14) and set the flag to 1 so that the function
% would know that we intend to input the t value and would
% like to have the probablility point.
pause

% Earlier in this example, it was assumed that the population
% variances were equal even though the samples variances
% were clearly unequal. It is easy to check the assumption
% of equal population variances using an F test. To do this,
% we simply calculate the ratio of the variances of
% the two samples, using the greater variance as the
% numerator

F = std(a1dat(:,1))^2/std(a1dat(:,2))^2

pause
% This value can be compared to the value from an F-table
% to determine its significance. In our case, we have 
% 7 degrees of freedom in each sample, using our F test
% function, FTEST, we obtain

ff = ftest(.05,7,7) 

% and we can see that F calculated above is much less
% than the value for 95% confidence, thus, the assumption
% that the populations have equal variances is valid.
pause

% It is also possible to use the t-test when observations
% are paired. For example, imagine a series of observations
% were made on soil samples before and after treatment
% to remove some noxious metal, say Hg. Suppose the
% following data results
echo off
disp('  ')
disp('Concentration of Cr Before and After Treatment')
disp('   Before    After      Difference')
disp([tdat2 tdat2(:,1)-tdat2(:,2)])
echo on
pause
% In this case, the important variable is the difference
% between the observations before and after treatment.
% Thus, we must test to see if the difference is
% significantly different from zero to see if the
% treatment is effective. The relevant t statistic can
% be calculated from
%
%       dbar - mu
%  t  = --------- sqrt(n)
%   v      sd
%
% where dbar is the mean difference between the samples,
% mu is the true mean difference, n is the sumber of
% samples, v = n-1 is the degrees of freedom and sd is
% the standard deviation of the differences.
pause

% Applying this we obtain
echo off
t = mean(tdat2(:,1)-tdat2(:,2))*sqrt(10)/...
std(tdat2(:,1)-tdat2(:,2))
echo on
% Checking the t from the tables we get

tt = ttestp(.05,9,2)

% and we can see that the treatment does have a significant
% effect at the 95% confidence level. We can also use
% the inverse t test to determine the level at which 
% the significance test would fail as follows
pause

tt = ttestp(t,9,1)

% And we see that the it would fail at the

100*(1-tt)

% percent confidence level.
pause

% Now suppose that we have added an additional treatment
% to our first data set, e.g. we are now looking at 
% three catalysts instead of two. The percent yields
% for catalysts A, B and C are now
pause
echo off
disp('  ')
disp('Percent yield with Catalysts A, B and C')
disp('    A     B     C')
disp(a1dat)
disp('   ')
disp('Mean yield with A, B and C')
disp(mean(a1dat));
disp('  ')
disp('Yield variance with A, B and C')
disp(std(a1dat).^2);
echo on
pause

% In order to see if the treatments are having an effect,
% we can use analysis of variance or ANOVA. In this case,
% we are only looking for the effect of one factor, so
% we will perform one-way ANOVA with the ANOVA1W function
% as shown below. We need only input the data and the 
% desired confidence level.
pause

anova1w(a1dat,.95)

% From this we can see that the effect of the factor is
% significant at the 95% confidence level, that is, we
% are 95% certain the catalysts are having a significant
% effect on the yield.
pause

% Now suppose we have a situation where there are two 
% factors which could affect the outcome of the experiment.
% Typically, we would call the first one a factor and 
% arrange our data into "blocks" where the second
% factor is constant. Consider the following data where
% the concentration of Cr is measured at different
% soil depths and different distances from a hazardous
% waste site:
pause
echo off
disp('  ')
disp('    Concentration of Cr near waste disposal site')
disp('  ')
disp('                     Distance from Site (km)')
disp('             -------------------------------------')
disp('   Depth (m)    1         2         3         4 ')
disp([[0 0.5 1]' a2dat1])
echo on

pause
% Are both the distance and depth significant in determining
% the concentration of Cr? We can find out using a two way
% analysis of variance with AVOVA2W as follows by simply
% inputing the data matrix and the desired confidence level.  
pause

anova2w(a2dat1,.95)

pause
% From this we can see that the effect of the factors (the
% distance from the site) and the blocks (the depth) are
% significant at the 95% level.

% Finally, suppose that we would like to determine if there
% is a significant difference between the concentration of
% some analyte in some samples and simultaneously determine
% if there is a difference among methods used to analyze 
% them. We start with the following data:
pause

echo off
disp('   ')
disp('               Measured concentration of Analyte')
disp('                         Sample Number')
disp('             -------------------------------------')
disp('    Method      1         2         3         4         5         6')
disp([[1:5]' a2dat2])
echo on
pause

% Once again, we can use ANOVA2W to determine if the effects
% of the Samples (factors) and method (blocks) are significant
pause

anova2w(a2dat2,.95)

% And once again, we see that at the 95% level both of the
% factors are significant.

% For more information on TTESTP, FTEST, ANOVA1W and ANOVA2W,
% please see their respective help files.
