% PARAFAC Demo

%Copyright Eigenvector Research, Inc. 1998
%bmw

echo on
% This script demonstrates the PARAFAC routine for
% modelling multiway data. 

% An interesting aspect of PARAFAC is that, under
% fairly general conditions, it is possible to recover
% the "true" underlying factors in a data set. This is
% in contrast to two-way techniques like PCA, where this
% cannot, in general, be done without some additional
% information, such as constraints used in curve resolution
% like non-negativity and unimodality.
pause

% To demonstrate this property of PARAFAC, lets build a
% data set with known factors. We'll use the OUTER function
% to take the outer product of a set of 4 vectors. Lets
% let the vectors be:

a = 1:10;
b = 1:6;
c = 1:3;
d = 1:2;

% Now we'll use OUTER to multiply them together to form a
% 4-D array:
pause

mwa = outer(a,b,c,d)

% Of course, a data set with only one factor isn't all that
% interesting, so lets create another one

a = [1 10 2 9 3 8 4 7 5 6];
b = [1 6 2 5 3 4];
c = [1 3 2];
d = [2 1];
pause

mwa = mwa + outer(a,b,c,d);

% So now we have a 4-way array that should be modelable
% as the sum of the outer product of 2 sets of vectors.
% Lets turn PARAFAC loose on this and see what we get.
% Note that we have to tell the routine how many factors
% to estimate. 
pause

mod = parafac(mwa,2,0,[1e-8 1e-8 1000]);

% From looking at the loadings plots, it looks like we have
% captured the right factors, except for the scale of the 
% factors. Note that the PARAFAC routine puts all the variance
% information into the last set of loadings, all the other
% loadings are unit vectors. So, just to be sure, lets take
% each of the factors and normalize it so that the first element
% is 1, just like all our input factors, then print them out.
pause
echo off

dimension1 = mod.loads{1}*inv(diag(mod.loads{1}(1,:)))
dimension2 = mod.loads{2}*inv(diag(mod.loads{2}(1,:)))
dimension3 = mod.loads{3}*inv(diag(mod.loads{3}(1,:)))
fac = mod.loads{1}(1,:).*mod.loads{2}(1,:).*mod.loads{3}(1,:);
dimension4 = mod.loads{4}*diag(fac)
echo on
pause

% Thus, we can see that, to 5 digits at least, we have
% recovered our original data. Now lets see what happens
% when we have some noise in the data.

mwa = mwa + randn(size(mwa));

% Now we'll make a new PARAFAC model on this data.
pause

mod = parafac(mwa,2,0,[1e-8 1e-8 1000]);
pause

% Once again, lets compare our factors to the one
% we started with.
pause
echo off
dimension1 = mod.loads{1}*inv(diag(mod.loads{1}(1,:)))
dimension2 = mod.loads{2}*inv(diag(mod.loads{2}(1,:)))
dimension3 = mod.loads{3}*inv(diag(mod.loads{3}(1,:)))
fac = mod.loads{1}(1,:).*mod.loads{2}(1,:).*mod.loads{3}(1,:);
dimension4 = mod.loads{4}*diag(fac)
echo on
pause

% So we see that we still reasonably well, even in the
% presence of noise.
