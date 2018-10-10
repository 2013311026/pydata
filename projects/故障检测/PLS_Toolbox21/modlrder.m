function modlrder(modl)
%MODLRDER Prints model information for models saved in structure format
%  MODLRDER prints model information for models created by the
%  PLS_Toolbox functions:
%    MODLGUI, PCAGUI
%  Information printed to the screen includes date and time created,
%  and methods used to construct the model. Input to the function is
%  the PCA or regression model in structure form (modl).
%  There is no output. 
%
%I/O: modlrder(modl);
%
%See also: MODLGUI, PCAGUI

%Copyright Eigenvector Research, Inc. 1998
%nbg

disp(' ')
switch upper(modl.name)
case 'PCA'
  disp('This is a Principal Components Analysis Model')
  disptime(modl.date,modl.time)
  dispxblock(modl.xname,modl.samps,modl.means)
  dispscale(modl.scale)
case 'NIP'
  dispreg('NIP')
  dispxblock(modl.xname,modl.samps,modl.meanx)
  dispyblock(modl.yname,modl.samps,modl.meany)
  dispscale(modl.scale)
  dispcv(modl.cv,modl.split,modl.iter)
case 'SIM'
  dispreg('SIM')
  dispxblock(modl.xname,modl.samps,modl.meanx)
  dispyblock(modl.yname,modl.samps,modl.meany)
  dispscale(modl.scale)
  dispcv(modl.cv,modl.split,modl.iter)
case 'PCR'
  dispreg('PCR')
  dispxblock(modl.xname,modl.samps,modl.meanx)
  dispyblock(modl.yname,modl.samps,modl.meany)
  dispscale(modl.scale)
  dispcv(modl.cv,modl.split,modl.iter)
case 'PARAFAC'
  disp('This is a PARAFAC model')
  disptime(modl.date,modl.time)
  dispmblock(modl.xname,modl.size)
  disp(['Decomposed using ',num2str(modl.nocomp),' factors'])
case 'TLD'
  disp('This is a Trilinear Decomposition model')
  disptime(modl.date,modl.time)
  dispmblock(modl.xname,modl.size)
end
disp(' ')

function [] = disptime(date,time)
disp(['Developed ',date,' ',num2str(time(4),2), ...
  ':',num2str(time(5),2),':',num2str(time(6),3)])

function [] = dispxblock(name,samps,vars)
disp(['X-block: ',name,'  ',num2str(samps), ...
  ' by ',num2str(length(vars))])

function [] = dispmblock(name,size)
disp(['X-block: ',name,'  size ',num2str(size)])

function [] = dispyblock(name,samps,vars)
disp(['Y-block: ',name,'  ',num2str(samps), ...
  ' by ',num2str(length(vars))])

function [] = dispreg(name)
disp('This is a linear regression model using')
switch upper(name)
case 'NIP'
  disp('Partial Least Squares calcuated with the NIPLS algorithm')
case 'SIM'
  disp('Partial Least Squares calcuated with the SIMPLS algorithm')
case 'PCR'
  disp('Principal Components Regression')
end

function [] = dispscale(scaling)
switch lower(scaling)
case 'none'
  disp('Scaling: none')
case 'mean'
  disp('Scaling: mean centering')
case 'auto'
  disp('Scaling: auto scaling')
end

function [] = dispcv(cv,split,iter)
switch lower(cv)
case 'loo'
  disp('Cross validation: leave one out')
case 'vet'
  disp(['Cross validation: venetian blinds w/ ', ...
    num2str(split),' splits'])
case 'con'
  disp(['Cross validation: contiguous block w/ ', ...
    num2str(split),' splits'])
case 'rnd'
  disp(['Cross validation: random samples w/ ',num2str(split), ...
    ' splits and ',num2str(iter),'iterations'])
end
