function [stdmat,stdvect] = stdgenns(spec1,spec2,window,tol,maxpc)
%STDGENNS Standardization transform generator for non-square systems
%  Generates direct or piecewise direct standardization matrix
%  with or without additive background correction based on
%  spectra from two instruments, or original calibration spectra
%  and drifted spectra from a single instrument. The inputs are
%  the original standard spectra (spec1), the spectra from the
%  instrument to be standarized (spec2) and the number of channels
%  to be used for each transform (window). Note that the number of
%  channels in each spectra need not be the same. If window is set to
%  0, direct standardization is used, otherwise, piecewise
%  direct standardization is used. An optional input variable,
%  (tol) adjusts the tolerance to be used in forming the local 
%  models used in piecewise direct standardization, and is
%  equal to the minimum size eigenvalue to include in 
%  each model (default is 1e-4). A second optional variable (maxpc) 
%  specifies the maximum number of PCs to be retained for each
%  model. The outputs are the transform matrix (stdmat), and an 
%  optional output with the additive background correction 
%  (stdvect). If only two output arguments are given, no background 
%  correction is used. 
%
%I/O: [stdmat,stdvect] = stdgenns(spec1,spec2,window,tol,maxpc);
%
%See also:  MSCORR, STDFIR, STDSSLCT, STDDEMO, STDGEN, STDGENDW, STDIZE

%Copyright Eigenvector Research, Inc. 1994-98
%bmw
%Modified BMW 10/95, 7/96, 3/98

[ms,ns] = size(spec1);
[ms2,ns2] = size(spec2);
if ms ~= ms2
  error('Both spectra must have the same number of samples')
end
if ns ~= ns2
  disp('Spectra do not have the same number of channels')
  disp('Developing non-square tranfer matrix')
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
  [spec1,mns1] = mncn(spec1);
  [spec2,mns2] = mncn(spec2);
end
if window == 0
  [u,s,v] = svd(spec2',0);
  if nargout == 2
    s = inv(s(1:ms-1,1:ms-1));
	invs = zeros(ms,ms);
	invs(1:ms-1,1:ms-1) = s;  
  else
    invs = inv(s);
  end
  spec2inv = u*invs*v';
  stdmat = spec2inv*spec1;
else
  %stdmat = zeros(ns,ns);
  winm = floor(window/2)+1;
  % Diagonal index numbers
  if ns2 == ns
    rin = 1:ns; cin = 1:ns; 
	for i = 2:winm
      % below diagonal
      rin = [rin i:ns];
      cin = [cin 1:ns-i+1];
	  % above diagonal
	  rin = [rin 1:ns-i+1];
	  cin = [cin i:ns];
    end 
  else
    cin = 1:ns; rin = round(rescale([0:ns-1]',1,(ns2-1)/(ns-1))');
	for i = 2:winm
	  % Add elements below diagonal
	  z = find(rin(1:ns)<ns2+2-i);
	  cin = [cin z];
	  rin = [rin rin(z)+(i-1)];
	  % Add elements above diagonal
	  z = find(rin(1:ns)>i-1);
	  cin = [cin z];
	  rin = [rin rin(z)-(i-1)];
	end
  end
  stdmat = sparse(rin,cin,ones(size(rin)),ns2,ns);
  ind1 = floor(window/2);
  ind2 = window-ind1-1;
  if nargin < 4
    tol = 1e-4;
	maxpc = ms;
  elseif nargin < 5
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
	if floor(i/100) == i/100
	  home
      s = sprintf('Now working on channel %g out of %g.',i,ns');
      disp(s) 
	end
	spec2inds = find(stdmat(:,i));
	[wind,z] = size(spec2inds);
    xspec2 = spec2(:,spec2inds);
    [u,s,v] = svd(xspec2'*xspec2);
	[mzns,nzns] = size(find(diag(s)));
	sinds = size(find(diag(s) > tol));
    sinds = max([sinds(1) 1]);
	if sinds > maxpc
	  sinds = maxpc;
	end
	npcs(i) = sinds;
    sinv = zeros(size(s));
    sinv(1:sinds,1:sinds) = inv(s(1:sinds,1:sinds));
    mod = u*sinv*v'*xspec2'*spec1(:,i);
    stdmat(spec2inds,i) = mod;
  end
end
if nargout == 2
  stdvect = (mns1' - stdmat'*mns2')';
end
