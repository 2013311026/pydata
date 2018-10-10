function modl = updatemod(xdat,modl);
%UPDATEMOD Updates MODLGUI model to be PLS_Toolbox 2.0.1d compatible
%  Adds the residual eigenvalues field and corrects the residual Q
%  limit field to models created by PLS_Toolbox 2.0.1c and earlier.
%  The inputs are the original X data used to create the model (xdat)
%  and the model to be updated (modl). The output is an updated model
%  (umodl).
%
%I/O: umodl = updatemod(xdat,modl);
%
%See also: MODLGUI

%Copyright Eigenvector Research 2000
%BMW

% Check to see that number of samples is consistent
[m,nx] = size(xdat);
if m ~= (modl.samps + length(modl.drow));
  error('Number of samples in original model ~= number of samples in xdat')
end
% Check to see that number of variables is consistent
[ml,nl] = size(modl.loads);
if nx ~= ml
  error('Number of variables in original model ~= number of variables in xdat')
end
% Delete samples if need be
if ~isempty(modl.drow)
  xdat = delsamps(xdat,modl.drow);
end
% Scale data
if strcmp(modl.scale,'auto')
  xdat = scale(xdat,modl.meanx,modl.stdx);
elseif strcmp(modl.scale,'mean')
  xdat = scale(xdat,modl.meanx);
elseif strcmp(modl.scale,'none')
  % Don't need to do anything
else
  error('Scaling not of known type!')
end
% Calculate the residuals matrix
resmat = xdat - modl.scores*modl.loads';
if m > nx
  covr = (resmat'*resmat)/(m-length(modl.drow)-1);
else
  covr = (resmat*resmat')/(m-length(modl.drow)-1);
end
emod = svd(covr);
emod = emod(1:length(emod)-nl);
modl.reslim = reslim(0,emod,95);
modl.reseig = emod;
