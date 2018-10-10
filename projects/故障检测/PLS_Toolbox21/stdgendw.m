function [stdmat,stdvect] = stdgendw(spec1,spec2,window,window2,tol,maxpc)
%STDGENDW Double window piecewise direct standardization generator
%  Generates piecewise direct standardization matrix with or
%  without additive background correction using the "double window"
%  method based on spectra from two instruments, or original calibration 
%  spectra and drifted spectra from a single instrument. The inputs are
%  the original standard spectra (spec1), the spectra from the
%  instrument to be standarized (spec2) and the number of channels
%  to be used for each transform (win) and the number of channels to
%  base the transform on (win2). An optional input variable,
%  (tol) adjusts the tolerance to be used in forming the local 
%  models and is equal to the minimum relative size of singular values 
%  to include in each model (default is 1e-2). A second optional variable 
%  (maxpc) specifies the maximum number of PCs to be retained for each
%  model. The outputs are the transform matrix (stdmat) and 
%  an optional output with the additive background correction 
%  (stdvect). If only one output argument is given, no background 
%  correction is used.
%
%I/O: [stdmat,stdvect] = stdgendw(spec1,spec2,win,win2,tol,maxpc);
%
%See also: STDSSLCT, STDGEN, STDDEMO, STDIZE, STDGENNS, MSCORR

%Copyright Eigenvector Research, Inc. 1994-98
%bmw
%Modified BMW 10/98,3/98

[ms,ns] = size(spec1);
[ms2,ns2] = size(spec2);
if ms ~= ms2
  error('Both spectra must have the same number of samples')
end
if ns ~= ns2
  error('Both spectra must have the same number of channels')
end
if (floor(window/2) == window/2 | floor(window2/2) == window2/2)
  error('Window widths must be an odd number')
end
if nargout >= 2
  [mspec1,mns1] = mncn(spec1);
  [mspec2,mns2] = mncn(spec2);
else
  mspec1 = spec1;
  mspec2 = spec2;
end
winm = floor(window/2)+1;
% Diagonal index numbers
rin = 1:ns; cin = 1:ns;
for i = 2:winm
  % below diagonal
  rin = [rin i:ns];
  cin = [cin 1:ns-i+1];
  % above diagonal
  rin = [rin 1:ns-i+1];
  cin = [cin i:ns];
end
stdmat = sparse(rin,cin,zeros(size(rin)),ns,ns);
ind1 = floor(window/2);
ind2 = window-ind1-1;
if (nargin < 5 | isempty(tol))
  tol = 1e-2;
  maxpc = ms;
else
  if tol > 1
	disp('Error in specification of tol')
	error('Tolerance must be <= 1')
  end
end
if (nargin < 6 | isempty(maxpc))
  maxpc = ms;
else	
  if maxpc > ms
    disp('Error in specification of maxpc')
	error('Number of PCs must be <= number of samples')
  end
end
a = window;
b = window2;
for i = 1:ns
  if floor(i/1000) == i/1000
    home
    s = sprintf('Now working on channel %g out of %g.',i,ns');
    disp(s)
  end 
  if i + (a + b)/2 -1 > ns
    if ns-i + 1 < a/2
	  % Change widow width
	  x = zeros(ms*ceil(b/2),floor(a/2)+ns-i+1);
	  y = zeros(ms*ceil(b/2),1);
      for j = 1:ceil(b/2)
	    x(ms*(j-1)+1:ms*j,:) = mspec2(:,j+i-((a+b)/2):j-((a+b)/2)+floor(a/2)+ns);
	    y(ms*(j-1)+1:ms*j,:) = mspec1(:,j-floor(b/2)-1+i);
	  end
	else
      x = zeros(ms*(b-(a + b)/2 + ns-i+1),a);
	  y = zeros(ms*(b-(a + b)/2 + ns-i+1),1);
	  li = i - (a + b)/2 + 1;
      for j = 1:(b-(a + b)/2 + ns-i+1)
	    x(ms*(j-1)+1:ms*j,:) = mspec2(:,li+j-1:li+j+a-2);
	    y(ms*(j-1)+1:ms*j,:) = mspec1(:,li+j-1 + floor(a/2));
	  end
	end
  elseif i - (a + b)/2 + 1 < 1	
	if i < a/2
	  % Change the window width
      x = zeros(ms*ceil(b/2),floor(a/2)+i);
	  y = zeros(ms*ceil(b/2),1);
      for j = 1:ceil(b/2)
	    x(ms*(j-1)+1:ms*j,:) = mspec2(:,j:j+floor(a/2)+i-1);
	    y(ms*(j-1)+1:ms*j,:) = mspec1(:,j+i-1);
	  end		
	else
      x = zeros(ms*(b-(a + b)/2 + i),a);
	  y = zeros(ms*(b-(a + b)/2 + i),1);
      for j = 1:(b-(a + b)/2 + i)
	    x(ms*(j-1)+1:ms*j,:) = mspec2(:,j:j+a-1);
	    y(ms*(j-1)+1:ms*j,:) = mspec1(:,j+floor(a/2));
	  end
	end	  
  else
    x = zeros(ms*b,a);
	y = zeros(ms*b,1);
	li = i - (a + b)/2 + 1;
    for j = 1:b
	  x(ms*(j-1)+1:ms*j,:) = mspec2(:,li+j-1:li+j+a-2);
	  y(ms*(j-1)+1:ms*j,:) = mspec1(:,li+j-1 + floor(a/2));
	end
  end
  [nw,mw] = size(x);
  [u,s,v] = svd(x'*x);
  [mss,nss] = size(diag(s));
  % For a relative tolerence use this:
  sinds = size(find((s(1,1)*ones(mw,1))./diag(s) < (1/tol)));
  sinds = sinds(1);
  % For an absolute tolerance use this:
  %sinds = size(find(diag(s) > tol));
  %sinds = max([sinds(1) 1]);
  if sinds > maxpc
	sinds = maxpc;
  end
  sinv = zeros(size(s));
  sinv(1:sinds,1:sinds) = inv(s(1:sinds,1:sinds));
  mod = u*sinv*v'*x'*y;
  if i <= ind1
    stdmat(1:i+ind2,i) = mod;
  elseif i >= ns-ind2+1
    stdmat(i-ind1:ns,i) = mod;
  else
    stdmat(i-ind1:i+ind2,i) = mod;
  end
end
if nargout >= 2
  stdvect = (mns1' - stdmat'*mns2')';
end
