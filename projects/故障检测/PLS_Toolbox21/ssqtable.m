function [] = ssqtable(ssq,lv)
%SSQTABLE print variance captured table to command window.
%  SSQTABLE prints the variance captured table (ssq) from
%  regression models (e.g. MODLGUI) or pca models (e.g.
%  (PCAGUI) to the command window. The optional input (lv)
%  is the number of latent variables or principal components
%  to print in the table. If (lv) is not included the
%  routine will print the entire table to the command
%  window.
%
%  Example, for a regression model from MODLGUI called (modl)
%    ssqtable(modl.ssq,5)
%  will print the variance captured table for the first 5
%  latent variables to the command window.
%
%I/O: ssqtable(ssq,lv)
%
%See also: MODLGUI, PCA, PCAGUI, PCR, PLS, SIMPLS

%Copyright Eigenvector Research, Inc. 1998
%nbg

if isa(ssq,'struct')
  if nargin<2
    lv = size(ssq.ssq,1);
  end
  disp(' ')
  if strcmp(lower(ssq.name),'pca')
    disp('    Principal Components Analysis Model')
    t = ssq.time;
    s = datestr(datenum(t(1),t(2),t(3),t(4),t(5),t(6)));
    disp(['    Date:    ',s])
    s = sprintf('%g by %g',ssq.samps,size(ssq.loads,1));
    disp(['    X-block: ',ssq.xname,' ',s])
    disp(sprintf('    No. PCs: %g',size(ssq.loads,2)))
    switch lower(ssq.scale)
    case 'mean'
      disp('    Scaling: mean centering')
    case 'auto'
      disp('    Scaling: auto scaling')
    case 'none'
      disp('    Scaling: none')
    end
  else
    if strcmp(lower(ssq.name),'sim')|strcmp(lower(ssq.name),'nip')
      disp('    Partial Least Squares Regression Model')
    elseif strcmp(lower(ssq.name),'pcr')
      disp('    Principal Components Regression Model')
    else
      error('Error - Structure not of known type')
    end
    t = ssq.time;
    s = datestr(datenum(t(1),t(2),t(3),t(4),t(5),t(6)));
    disp(['    Date:    ',s])
    s1= length(ssq.xname);
    s2= length(ssq.yname);
    sp= ' ';
    if s1>s2
      sx = sp;
      sy = sp(1,ones(1,s1-s2+1));
    elseif s1<s2
      sx = sp(1,ones(1,s2-s1+1));
      sy = sp;
    else
      sx = sp;
      sy = sp;
    end
    s = sprintf('%g by %g',ssq.samps,size(ssq.loads,1));
    disp(['    X-block: ',ssq.xname,sx,s])
    s = sprintf('%g by %g',ssq.samps,length(ssq.meany));
    disp(['    Y-block: ',ssq.yname,sy,s])
    if strcmp(lower(ssq.name),'sim')|strcmp(lower(ssq.name),'nip')
      disp(sprintf('    No. LVs: %g',size(ssq.loads,2)))
    elseif strcmp(lower(ssq.name),'pcr')
      disp(sprintf('    No. PCs: %g',size(ssq.loads,2)))
    end
    disp(sprintf('    RMSEC:   %g',ssq.rmsec(size(ssq.loads,2))))
    disp(sprintf('    RMSECV:  %g',ssq.rmsecv(size(ssq.loads,2))))
    switch lower(ssq.scale)
    case 'mean'
      disp('    Scaling: mean centering')
    case 'auto'
      disp('    Scaling: auto scaling')
    case 'none'
      disp('    Scaling: none')
    end
    switch lower(ssq.cv)
    case 'con'
      disp('    Cross-validation: contiguous block')
      disp(sprintf('      with %g splits',ssq.split))
    case 'vet'
      disp('    Cross-validation: venetian blinds')
      disp(sprintf('      with %g splits',ssq.split))
    case 'loo'
      disp('    Cross-validation: leave one out')
    case 'rnd'
      disp('    Cross-validation: random subsets')
      disp(sprintf('      with %g splits',ssq.split))
      disp(sprintf('      and  %g iterations',ssq.iter)) 
    end
  end
  ssq = ssq.ssq;
else
  if nargin<2
    lv = size(ssq,1);
  end
end

switch size(ssq,2)
case 5
  disp('  ')
  disp('    Percent Variance Captured by Regression Model')
  disp('  ')
  disp('           -----X-Block-----    -----Y-Block-----')
  disp('   LV #    This LV    Total     This LV    Total ')
  disp('   ----    -------   -------    -------   -------')
  format = '   %3.0f     %6.2f    %6.2f     %6.2f    %6.2f';
  for ii=1:lv
    tab = sprintf(format,ssq(ii,:)); disp(tab)
  end
  disp('  ')
case 4
  disp('   ')
  disp('        Percent Variance Captured by PCA Model')
  disp('  ')
  disp('Principal     Eigenvalue     % Variance     % Variance')
  disp('Component         of          Captured       Captured')
  disp(' Number         Cov(X)        This  PC        Total')
  disp('---------     ----------     ----------     ----------')
  format = '   %3.0f         %3.2e        %6.2f         %6.2f';
  for ii=1:lv
    tab = sprintf(format,ssq(ii,:)); disp(tab)
  end
otherwise
  disp('Error - ssq not of proper format')
  error(' e.g. see outputs from MODLGUI or PCAGUI')
end
