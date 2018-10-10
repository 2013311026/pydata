function [c,s] = mcr(x,c0,ccon,scon,ittol,cc,sc,sclc,scls,nnlstol);
%MCR Multivariate curve resolution with constraints
%  Inputs are (x) the matrix to be decomposed as X = CS, and (c0)
%  the initial guess for (c) or (s) depending on its size. For
%  X (m by n) then C is (m by k) and S is (k by n) where k is the
%  number of factors and is determined from the size of input (c0).
%  If c0 is size (m by k) it is the initial guess for c.
%  If c0 is size (k by n) it is the initial guess for s.
%
%  Outputs are the estimated concentrations (c) and pure
%  component spectra (s).
%
%  (ccon) is an optional switch describing constraints on (c): 
%    ccon = 0, no contraints on c {default},
%    ccon = 1, non-negative c [calls LSQNONNEG, or if not found NNLS], and
%    ccon = 2, non-negative c [calls FASTNNLS].
%
%  (scon) is an optional switch describing constraints on (s): 
%    scon = 0, no contraints on s {default},
%    scon = 1, non-negative s [calls LSQNONNEG, or if not found NNLS], and
%    scon = 2, non-negative s [calls FASTNNLS].
%
%  (ittol) is an optional convergance criteria,
%    ittol < 1, convergance tolerance [e.g. 1e-4], and
%    ittol >=1, max number of iterations {default = 100}.
%
%  Equality constraints on the concentrations and spectra are
%  input with the optional arguments (cc) and (sc) respectively.
%  (cc) is (m by k) and (sc) is (k by n). The elements of (cc)
%  and (sc) are all 'inf' or 'NaN' except in locations where
%  constraints are imposed (the ISFINITE command is used to find
%  the locations of the constraints). A matrix 'inf' or 'NaN'
%  can be constructed by
%    cc = ones(size(c0))/0;
%    cc = zeros(size(c0))/0;
%  Note: unconstrained factors have spectra scaled to unit length.
%  This can result in output spectra with different scales. 
%
%  (sclc) and (scls) are optional vectors to plot the concentration
%  and spectral profiles against.
%  (nnlstol) is an optional input for setting the convergence criteria
%  for LSQNONNEG (see help on OPTIMSET for the TolX field) and FASTNNLS
%  (see help on FASTNNLS). {default = 1e-5}
%
%Example: [c,s] = mcr(x,c0,0,0,20,[],sc);
%
%I/O: [c,s] = mcr(x,c0,ccon,scon,ittol,cc,sc,sclc,scls,tolx);
%
%See also: PCA, PARAFAC

%Copyright Eigenvector Research, Inc. 1997-2000
%nbg
%9/24/98 nbg (fixed case = 1 to case = 2 on line 337)
%10/22/98 nbg (changed how constraints are handled, and
%  modified call to fastnnls)
%2/99 nbg changed to allow initial estiamte of spectra
%11/00 nbg nnls ==> lsqnonneg

if nargin<3
  ccon  = 0;
elseif isempty(ccon)
  ccon  = 0; %non-negativity constraint flag for c
elseif ccon>2
  error('ccon must be < 3')
end
if nargin<4
  scon  = 0;
elseif isempty(scon)
  scon  = 0; %non-negativity constraint flag for s
elseif scon>2
  error('scon must be < 3')
end
if nargin<5
  itmax = 100; itmin = 1e-8; ittol = itmax;
elseif isempty(ittol)
  itmax = 100; itmin = 1e-8;
elseif ittol<1
  itmax = 1e6; itmin = ittol;
  if ittol<1e-8
    itmin = 1e-8;
  end
else
  itmax = ittol; itmin = 1e-8;
  if itmax>1e6
    itmax = 1e6;
  end
end
if nargin<6
  cc    = 0; cc1 = logical(0);
elseif isempty(cc)
  cc    = 0; cc1 = logical(0);
elseif sum(sum(isfinite(cc))')
  cc1   = logical(1); disp('Equality Constraints on C')
else
  cc    = 0; cc1   = logical(0);
end
if nargin<7
  sc    = 0; sc1 = logical(0);
elseif isempty(sc)
  sc    = 0; sc1 = logical(0);
elseif sum(sum(isfinite(sc))')
  sc1   = logical(1); disp('Equality Constraints on S')
else
  sc    = 0; sc1   = logical(0);
end

if size(c0,1)==size(x,1)
  if cc1&(size(cc,1)~=size(c0,1)|size(cc,2)~=size(c0,2))
    error('cc must be size(x,1) by #factors')
  end
  ka    = size(c0,2);  %initial guess for concentration
  s0    = zeros(ka,size(x,2));
  c0int = logical(1);
elseif size(c0,2)==size(x,2)
  if sc1&(size(sc,1)~=size(c0,1)|size(sc,2)~=size(c0,2))
    error('sc must be #factors by size(x,2)')
  end
  ka    = size(c0,1);  %initial guess for spectra
  s0    = c0;
  c0    = zeros(size(x,1),ka);
  c0int = logical(0);
else
  error('c0 must be size(x,1) by #factors or #factors by size(x,2)')
end
kac     = ones(1,ka); %keep a one for factors with no constraint
if cc1
  ii    = find(sum(isfinite(cc)));
  kac(1,ii) = zeros(1,length(ii));
end
if sc1
  ii    = find(sum(isfinite(sc')));
  kac(1,ii) = zeros(1,length(ii));
end
kac   = find(kac);    %factors without constraints
if nargin<8
  sclc  = [1:size(x,1)];
elseif isempty(sclc)|(length(sclc)~=size(x,1))
  sclc  = [1:size(x,1)];
end
if nargin<9
  scls  = [1:size(x,2)];
elseif isempty(scls)|(length(scls)~=size(x,2))
  scls  = [1:size(x,2)];
end
if ccon==1|scon==1                             %nbg 11/00
  if exist('lsqnonneg')==2
    opts  = optimset('lsqnonneg');
    opts  = optimset(opts,'Display','off');
    if nargin>9&~isemtpy(nnlstol)
      opts  = optimset(opts,'TolX',nnlstol);
    end
    lsqflag = 1;
  elseif exist('nnls')==2
    disp('LSQNONNEG not found. Using NNLS.')
    if nargin<10
      nnlstol = max(size(x))*norm(x,1)*eps;
    elseif isempty(nnlstol)
      nnlstol = max(size(x))*norm(x,1)*eps;
    end
    lsqflag = 2;
  else
    error('Can''t find LSQNONNEG or NNLS, try FASTNNLS.')
  end
end
if ccon==2|scon==2
  if nargin<10
    nnlstol = max(size(x))*norm(x,1)*eps;
  elseif isempty(nnlstol)
    nnlstol = max(size(x))*norm(x,1)*eps;
  end
end                                             %nbg 11/00

if c0int==1
  if cc1
    ii    = find(isfinite(cc));
    c0(ii) = cc(ii);
  end
  c       = c0;
  switch scon %initial guess for S
  case 0
    s0    = c\x;
  case 1
    if lsqflag==1                                %nbg 11/00
      for ii=1:length(scls)
        s0(:,ii) = lsqnonneg(c,x(:,ii),[],opts);  %nbg 11/00
      end
    else
      for ii=1:length(scls)
        s0(:,ii) = nnls(c,x(:,ii),nnlstol);      %nbg 11/00
      end
    end
  case 2
    for ii=1:length(scls)
      s0(:,ii) = fastnnls(c,x(:,ii),nnlstol);
    end
  end
  if sc1
    i2    = find(isfinite(sc));    
    s0(i2) = sc(i2);
  end
  s       = s0;
  if ~isempty(kac)
    s(kac,:) = normaliz(s(kac,:)); 
  end
else
  if sc1
    ii    = find(isfinite(sc));
    s0(ii) = sc(ii);
  end
  s       = s0;
  if ~isempty(kac)
    for i1=1:length(kac)
      s(kac(i1),:) = s(kac(i1),:)/norm(s(kac(i1),:)');
    end
  end
  switch ccon %initial guess for C
  case 0
    c0    = x/s;
  case 1
    if lsqflag==1
      for ii=1:length(sclc)
        c0(:,ii) = lsqnonneg(s',x(:,ii)',[],opts)';  %nbg 11/00
      end
    else
      for ii=1:length(sclc)
        c0(ii,:) = nnls(s',x(ii,:)',nnlstol)';     %nbg 11/00
      end
    end
  case 2
    for ii=1:length(sclc)
      c0(ii,:) = fastnnls(s',x(ii,:)',nnlstol)';
    end
  end
  if cc1
    i2  = find(isfinite(cc));    
    c0(i2) = cc(i2);
  end
  c       = c0;
end

it      = 0;
while it<itmax
  switch ccon %solve for concentration
  case 0
    c   = x/s;
  case 1
    if lsqflag==1
      if it>1
        for ii=1:length(sclc)
          c(ii,:) = lsqnonneg(s',x(ii,:)',c(ii,:)',opts)';  %nbg 11/00
          %c(ii,:) = nnls(s',x(ii,:)',nnlstol)';     %nbg 11/00
        end
      else
        for ii=1:length(sclc)
          c(ii,:) = lsqnonneg(s',x(ii,:)',[],opts)';  %nbg 11/00
        end
      end
    else
      for ii=1:length(sclc)
        c(ii,:) = nnls(s',x(ii,:)',nnlstol)';     %nbg 11/00
      end
    end
  case 2
    for ii=1:length(sclc)
      c(ii,:) = fastnnls(s',x(ii,:)',nnlstol,c(ii,:)')';
    end
  end
  if cc1
    i2 = find(isfinite(cc));
    c(i2) = cc(i2);
  end

  switch scon %solve for spectra
  case 0
    s = c\x;
  case 1
    if lsqflag==1
      for ii=1:length(scls)
        s(:,ii) = lsqnonneg(c,x(:,ii),s(:,ii),opts);  %nbg 11/00
      end
    else
      for ii=1:length(scls)
        s(:,ii) = nnls(c,x(:,ii),nnlstol);           %nbg 11/00
      end
    end
  case 2
    for ii=1:length(scls)
      s(:,ii) = fastnnls(c,x(:,ii),nnlstol,s(:,ii));
    end
  end
  if sc1
    i2  = find(isfinite(sc));    
    s(i2) = sc(i2);
  end
  if ~isempty(kac)
    s(kac,:) = normaliz(s(kac,:)); 
  end

  it     = it+1; garb = it;
  if (ittol<1)&((it/2-round(it/2))==0)
    resc = 0; ress = 0;
    for ii=1:ka
      resc = resc+norm(c0(:,ii));
      ress = ress+norm(s0(ii,:));
    end
    ress = sqrt(sum(sum((s'-s0').^2)')/ka/ress);
    resc = sqrt(sum(sum((c-c0).^2)')/ka/resc);
    if (ress<itmin)&(resc<itmin)
      it = itmax+1;
    else
      c0 = c;
      s0 = s;
    end
  end
end 

figure
subplot(2,1,1), plot(sclc,c)
xlabel('Concentration Profile')
ylabel('Concentration')
title(sprintf('MCR Results after %d iterations',garb))
subplot(2,1,2), plot(scls,s)
xlabel('Spectral Profile')
ylabel('Spectra')

%disp('  ')
%disp(' Sum of Squares for MCR Model')
%disp('  ')
%disp(' Factor        Sum of')
%disp(' Number        Squares')
%disp('---------     ----------')
%format = '   %3.0f         %3.2e';
%tab    = sprintf('   total       %3.2e',sum(sum(x.^2)')); disp(tab)
%for ii=1:ka
%  s0   = c(:,ii)*s(ii,:);
%  c0   = sum(sum(s0.^2)');
%  tab  = sprintf(format,ii,c0); disp(tab)
%end
s0     = x-c*s;
disp(sprintf('residual       %3.2e',sum(sum(s0.^2)')))
