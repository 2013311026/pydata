function [stdmat,stdvect] = stdgen(spec1,spec2,window,tol,maxpc)
%STDGEN Instrument standardization transform generator
%  Generates direct or piecewise direct standardization matrix
%  with or without additive background correction based on
%  spectra from two instruments, or original calibration spectra
%  and drifted spectra from a single instrument. The inputs are
%  the original standard spectra (spec1), the spectra from the
%  instrument to be standarized (spec2) and the number of channels
%  to be used for each transform (window). If window is set to
%  0, direct standardization is used, otherwise, piecewise
%  direct standardization is used. An optional input variable,
%  (tol) adjusts the tolerance to be used in forming the local 
%  models used in piecewise direct standardization, and is equal
%  to the minimum relative size of singular values to include in
%  each model (default is 1e-2). A second optional variable (maxpc) 
%  specifies the maximum number of PCs to be retained for each
%  model. The outputs are the transform matrix (stdmat) and 
%  an optional output with the additive background correction 
%  (stdvect). If only one output argument is given, no background 
%  correction is used. See STDSSLCT for selection of
%  standardization subsets and STDIZE for standardizing new
%  spectra using an existing model.
%
%I/O: [stdmat,stdvect] = stdgen(spec1,spec2,window,tol,maxpc);
%
%See also: STDSSLCT, STDDEMO, STDFIR, STDIZE, STDGENNS, STDGENDW, MSCORR

%Copyright Eigenvector Research, Inc. 1994-98
%Modified BMW 10/95
%Modified BMW 3/98
%Modified BMW 1/99 - tolerance check

[ms,ns] = size(spec1);
[ms2,ns2] = size(spec2);
if ms ~= ms2
  error('Both spectra must have the same number of samples')
end
if ns ~= ns2
  error('Both spectra must have the same number of channels')
end
if nargin > 2
  if window ~= 0
    if floor(window/2) == window/2
      disp('  ')
      disp('The number of channels in the window should really be') 
      disp('an odd number for the channels to be properly centered')
	  disp('in the intervals.')
	  disp('  ')
	end
  end
end
if nargout == 2
  [mspec1,mns1] = mncn(spec1);
  [mspec2,mns2] = mncn(spec2);
else
  mspec1 = spec1;
  mspec2 = spec2;
end
if window == 0
  if ms <= ns
    [u,s,v] = svd(mspec2',0);
    if nargout == 2
      s = inv(s(1:ms-1,1:ms-1));
	  invs = zeros(ms,ms);
	  invs(1:ms-1,1:ms-1) = s;  
    else
      invs = inv(s);
    end
    spec2inv = u*invs*v';
  else
    spec2inv = pinv(mspec2);
  end	
  stdmat = spec2inv*mspec1;
else
  %stdmat = zeros(ns,ns);
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
  if (nargin < 4 | isempty(tol))
    tol = 1e-2;
	maxpc = ms;
  elseif (nargin < 5 | isempty(maxpc))
    if tol > 1
	  disp('Error in specification of tol')
	  error('Tolerance must be <= 1')
	end
    maxpc = ms;
  else	
    if maxpc > ms
	  disp('Error in specification of maxpc')
	  error('Number of PCs must be <= number of samples')
	end
  end
  for i = 1:ns
	if round(i/100) == (i/100)
      s = sprintf('Now working on channel %g out of %g.',i,ns');
      disp(s)
	end 
    if i <= ind1
      xspec2 = mspec2(:,1:i+ind2);
      wind = i+ind2;
    elseif i >= ns-ind2+1
      xspec2 = mspec2(:,i-ind1:ns);
      wind = ns-i+ind1+1;
    else
      xspec2 = mspec2(:,i-ind1:i+ind2);
      wind = window;
    end
    [u,s,v] = svd(xspec2'*xspec2);
    % For a relative tolerence use this:
    %sinds = size(find((s(1,1)*ones(wind,1))./diag(s) < (1/tol))); BMW 1/99
	sinds = size(find( diag(s)./(s(1,1)*ones(wind,1)) > tol ));
    sinds = sinds(1);
    % For an absolute tolerance use this:
    %sinds = size(find(diag(s)>tol));   
    %sinds = max([sinds(1) 1]);
	if sinds > maxpc
	  sinds = maxpc;
	end
    sinv = zeros(size(s));
    sinv(1:sinds,1:sinds) = inv(s(1:sinds,1:sinds));
    %disp(i)
    %disp([xspec2 spec1(:,i)])
    mod = u*sinv*v'*xspec2'*spec1(:,i);
    if i <= ind1
      stdmat(1:i+ind2,i) = mod;
    elseif i >= ns-ind2+1
      stdmat(i-ind1:ns,i) = mod;
    else
      stdmat(i-ind1:i+ind2,i) = mod;
    end
  end
end
if nargout == 2
  stdvect = (mns1' - stdmat'*mns2')';
end
