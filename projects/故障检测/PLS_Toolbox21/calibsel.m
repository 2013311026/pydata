function channel = calibsel(y,x,alpha,flag);
%CALIBSEL variable selection
%  CALIBSEL function performs the procedure described in 
%  Chemometrics and spectral frequency selection
%    P.J. Brown, C.H. Spiegelman, and M.C. Denham
%    Phil. Trans. R. Soc. Land. A (1991) 337, 311-322
%  and was developed by:
%       Texas Environmental Software Solutions, Inc.
%		3006 Bluestem
%		College Station, TX 77845-5709
%  Note that the convention between the help file here and
%  the above reference are opposite i.e. x is the predictor
%  block and y is the predicted block here.
%  Please address any comments to the above address.
%  INPUTS:
%	x		Calibration spectral frequencies. This is a matrix
%			of size (n,p) where typically p is on the order 
%			of 10^3 and n is on the order of 10^1.  
%	y		Calibration input concentration. This is a matrix
%			of size (n,1).
%	So, we have that a measurement device such as a 
%	chemical spectrometer measures a concentration and
%	records the energy in many different spectral levels:
%
%			X(i,j) = MEASURE( Y(i) )
%
%	and we want to know which of the channels (which j's)
%	are most important in the calibration of the 
%	instrument (the return value, calibsel).
%
%   alpha	Significance level for the chi-square quantiles. Should
%			be for example, .10, .05, .01.
%	flag	flag = 1 says to use the matrix calculations to solve
%			for the estimates.  Use this if you have lots of 
%			memory and p is not too large. flag <> 1 says to loop
%			over the p values that you actually need.  Use this
%			if you have less memory or if p is large.
%
% OUTPUT:
%	channel	This is a vector of the indices of the x matrix that
%			are used in the estimation of the unknown 
%			concentrations.  The length of this interval is the 
%			value of q' described in the paper.  The vector of
%			indices corresponds to the channels (columns) of x
%			that should be used in the calibration.
%
%I/O: channel = calibsel(x,y,alpha,flag);
%
%See also: gaselctr, genalg

% Check the input arguments.
if nargin == 2
	alpha = .95 ;
	flag = 1 ;
end
if nargin == 3
	flag = 1 ;
end
if nargin <= 1
	error('Y (matrix) spectral response and X (Col vector) required args') ;
end

% Get sizes of input matrices and check conformability
[n,p] = size(y) ;
[nx,px] = size(x) ;

if n ~= nx
	error('No. of samples not the same for X and Y (conformability)') ;
end

if px ~= 1
	error('Input concentrations must be univariate (X is column vector)') ;
end

if alpha >=1.0 | alpha <= 0
	error('Significance level alpha must be in (0,1)') ;
end

% Get estimates of alpha, beta, and sigma^2.  Note that the method used 
% to get the estimates might actually run faster in a loop since the 
% calculation of y*y' in the ehat line creates a very large matrix that 
% might cause the computer to access virtual memory.  Even without 
% accessing virtual memory, the code might still run faster in that it 
% may be faster to loop over p values than it is to calculate p*p values 
% internally when p is very large.  Flag for looping is determined from 
% an input variable.

mx   = [ones(n,1) x] ;
if flag == 1
	bx   = mx\y ;
	ahat = bx(1,:)' ;
	bhat = bx(2,:)' ;
	ehat = diag(y'*y-y'*mx*bx)/(n-2) ;
else
	ahat = zeros(p,1) ;
	bhat = zeros(p,1) ;
	ehat = zeros(p,1) ;
	for i = 1:p
		bx = mx\y(:,i) ;
		ahat(i,1) = bx(1,1) ;
		bhat(i,1) = bx(2,1) ;
		ehat(i,1) = (y(:,i)'*y(:,i) - y(:,i)'*mx*bx)/(n-2) ;
	end
end

% Form numerator and denominator of theta
num = bhat./ehat ;
den = (bhat.^2)./ehat ;

% Obtain the chi-square quantiles for calculation of the half width.
%chi = chi2inv(1-alpha,(1:p)') ;	% load matrix (limited size)
%chi = gaminv(1-alpha,(1:p)'/2,2);	% gaminv moved to stat toolbox

% Replacement code for chi-squared quantiles (gaminv) starts here

u = 1-alpha ;
v = (1:p)'./2 ;
b = 2 ;

%    Ref: Johnson and Kotz, Distributions in Statistics, 1994.

a = v./2 ;

% Get starting values and optimize using Newton's method

ab = a.*b ;
kk = ab.*b ;
mm = log(kk + ab.^2) ;
mu = 2.*log(ab) - 0.5*mm ;
s  = -2*log(ab) + mm ;
q  = min(exp(sqrt(2.*s.^2) .* erfinv(2.*u-1) + mu),1e006) ;

% Get epsilon for machine and set up for optimization

myeps    = sqrt(eps) ;
i        = 0 ;
infinite = 50 ;
ndig     = 1e-6 ;	% Get quantile to within 6 places.

% Perform optimization.

while i<infinite
	code = 1 ;

	pdf = exp((a-1).*log(q./b) - q./b - log(b) - gammaln(a)) ;
	cdf = gammainc(q ./ b, a) ;

	pdf(find(pdf<myeps)) = myeps ;
	delta = (cdf-u) ./ pdf ;
	delta(find(abs(q./max(delta,1e-10))<2)) = ...
		q(find(abs(q./max(delta,1e-10))<2))./2 ;
	if max(abs(cdf-u)) < ndig
		code = 0 ;
		break ;
	end
	q = q-delta ;
	i = i+1 ;
end

% Could look at code

chi = q - delta ;

% Replacement code for chi-squared quantiles (gaminv) ends here


%x = gaminv(p,v/2,2);
%x = chi2inv(p,v);

% Sort the denominator from largest to smallest and get the 
% cumulative sum.
[d,di]  = sort(abs(bhat./sqrt(ehat))) ;
d       = d(p:-1:1,1) ;
di      = di(p:-1:1,1) ;
d       = cumsum(den(di)) ;

%
% Get the ratio and find the minimum. qp is q' = number nonzero theta.
%
f     = (2*sqrt(chi(1:p)))./sqrt(d(1:p)) ;
qp    = find(f==min(f)) ;

%
% Set the output value
%
channel = di(1:qp) ;


