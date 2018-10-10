function [sspec] = stdfir(nspec,rspec,win,mc);
%STDFIR Standardization using FIR filtering.
%  Inputs are (nspec) a matrix of new spectra to be standardized,
%  (rspec) the vector of the standard spectra from the standard
%  instrument, and (win) is the window width (must be an odd number).
%  If the optional input (mc) is 1 {default} each window is mean
%  centered, if (mc) is set to 0 no mean centering is performed.
%  The output is (sspec) the matrix of standardized spectra.
%  This routine is based on the method discussed in
%
%  Blank, T.B., Sum, S.T., Brown, S.D., and Monfre, S.L., 
%  "Transfer of Near-Infrared Multivariate Calibrations 
%  without Standards", Anal. Chem., 68(17), 2987-2995, 1996.
%
%I/O: sspec = stdfir(nspec,rspec,win,mc);
%
%See also: MSCORR, STDGEN, STDGENDW, STDGENNS

%Copyright Eigenvector Research, Inc. 1998
%nbg

[ms,ns] = size(nspec);
[mr,nr] = size(rspec);
if mr>1&nr>1                   %rspec must be a vector
  error('(rspec) must be a vector')
elseif mr>nr                   %make rspec a row vector
  rspec = rspec';
end, clear mr nr
if ns~=length(rspec)           %make sure rspec is same size as nspec
  error('number of columns in (nspec) must equal length(rspec)')
end
if win/2==0|win<3              %win must be odd
  error('input (win) must be >2 and odd')
end
if nargin<4
  mc    = 1;
end
ps      = floor(win/2);
sspec   = zeros(ms,ns);
for ii=ps+1:ns-ps              %standardize middle of spectra
  if mc==0
    smean = zeros(ms,win);
    rmean = 0;
  else
    smean = mean(nspec(:,ii-ps:ii+ps)')';
    rmean = mean(rspec(1,ii-ps:ii+ps)');
  end
  scent = nspec(:,ii-ps:ii+ps)-smean(:,ones(1,win));
  rcent = rspec(1,ii-ps:ii+ps)-rmean;
  breg  = scent/rcent;
  sspec(:,ii) = scent(:,ps+1)./breg+rmean;
end
if mc==0 %standardize left end
  smean = zeros(ms,win);
  rmean = 0;
else
  smean = mean(nspec(:,1:win)')';
  rmean = mean(rspec(1,1:win)');
end
scent = nspec(:,1:win)-smean(:,ones(1,win));
rcent = rspec(1,1:win)-rmean;
breg  = scent/rcent;
sspec(:,1:ps) = scent(:,1:ps)./breg(:,ones(1,ps))+rmean;
if mc==0 %standardize right end
  smean = zeros(ms,win);
  rmean = 0;
else
  smean = mean(nspec(:,ns-win+1:ns)')';
  rmean = mean(rspec(1,ns-win+1:ns)');
end
scent = nspec(:,ns-win+1:ns)-smean(:,ones(1,win));
rcent = rspec(1,ns-win+1:ns)-rmean;
breg  = scent/rcent;
sspec(:,ns-ps+1:ns) = scent(:,ps+2:win)./breg(:,ones(1,ps))+rmean; 
