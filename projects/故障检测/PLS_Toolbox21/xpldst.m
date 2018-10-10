function xpldst(sdat,mod,txt,out)
%XPLDST extracts variables from a structure array
%  XPLDST writes the fields of the structure input
%  (sdat) to variables in the workspace with the same
%  variable names as the field names.
%
%  The optional input (mod) allows control over 
%  what is output to the workspace:
%    mod = 0; outputs all fields {default}, and
%    mod = 1; outputs the standard function outputs for
%      a PCA or regression model when the input (sdat)
%       is a structure output from PCAGUI or MODLGUI.
%  The optional string input (txt) appends a string
%    (txt) to the variable outputs.
%  The optional input (out) allows suppression of
%    model information:  
%   out = 1; echos model information back to the
%     command window (only used when mod =1), and
%   out = 0; suppresses information echo.
%
%I/O: xpldst(sdat,mod,txt,out)
%
%Example: xpldst(modl,1,'01',0)

%Copyright Eigenvector Research, Inc. 1997-98
%NBG 10/97,1/98

if nargin<2,     mod = 0;  end
if isempty(mod), mod = 0;  end
if nargin<3,     txt = []; end
if nargin<4,     out = 1;  end

fields = fieldnames(sdat);
if mod==0
  for ii=1:size(fields,1)
    s    = ['dat = sdat.',fields{ii,:},';'];
    eval(s)
    if isempty(txt)
      assignin('base',fields{ii,:},dat)
    else
      assignin('base',[fields{ii,:},txt],dat)
    end
  end
else
  ii   = 0;
  mod  = 0;
  while (mod==0)&(ii<size(fields,1)+1)
    ii = ii+1;
    if strcmp('name',fields(ii,:))
      mod = 1;
    end
  end
  if mod==0
    error('Input (sdat) not a model but (mod) set to 1')
  else
    assignin('base',['scores',txt],sdat.scores)
    assignin('base',['loads',txt],sdat.loads)
    assignin('base',['ssq',txt],sdat.ssq)
    assignin('base',['res',txt],sdat.res)
    assignin('base',['reslm',txt],sdat.reslim)
    assignin('base',['tsqlm',txt],sdat.tsqlim)
    assignin('base',['tsq',txt],sdat.tsq)
    if strcmp(sdat.name,'sim')|strcmp(sdat.name,'nip')
      assignin('base',['wts',txt],sdat.wts)
    end
    if out==1
      disp(' ')
      switch lower(sdat.name)
      case 'pca'
        disp('This is a PCA model')
      case 'sim'
        disp('This is a PLS (SIMPLS) regression model')
      case 'nip'
        disp('This is a PLS (NIPLS) regression model')
      case 'pcr'
        disp('This is a PCR regression model')
      end
      disp(['Created on ', sdat.date])
      disp(sprintf('at %2g:%2g:%2g',sdat.time(1,4:6)))
      disp(['using ',num2str(size(sdat.loads,2)),' LVs'])
      disp(['with X input variable "',sdat.xname,'"'])
      if strcmp(sdat.name,'sim')|strcmp(sdat.name,'nip')
        disp(['and Y input variable "',sdat.yname,'"'])
      end
      if sdat.drow|sdat.dcol
        disp('the input was edited')
      end
      if strcmp(sdat.scale,'auto')
        disp('the data were auto scaled')
      elseif strcmp(sdat.scale,'mean')
        disp('the data were mean centered')
      else
        disp('no scaling or centering was used')
      end
    end   
  end
end
