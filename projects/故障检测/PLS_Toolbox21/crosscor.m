function crcor = crosscor(x,y,n,period,flag,plots)
%CROSSCOR Cross correlation of time series
%  Performs the crosscorrelation function of two time series.
%  The inputs are the two time series (x), and (y) and the
%  number of sample periods (n) to consider. The sample period
%  (period) is an optional input variable used to scale the 
%  output plot and (flag) in an optional input variable which 
%  changes the routine from cross correlation to cross covariance 
%  when set to 1. If optional input (plots) is set to zero no
%  plots are constructed.
%Example:
%     crcor = crosscor(x,y,20,[],0,0);
%
%I/O: crcor = crosscor(x,y,n,period,flag,plots);
%
%See also: AUTOCOR, CCORDEMO

%Copyright Eigenvector Research, Inc. 1991-99
%Modified BMW 11/93, nbg 3/99

[mp,np]   = size(x);
[mpy,npy] = size(y);
if np > mp
  x  = x';
  mp = np;
end
if npy > mpy
  y   = y';
  mpy = npy;
end
if mpy ~= mp
  error('The x and y vectors must be the same length')
end
crcor = zeros(2*n+1,1);
if nargin < 4
  period = 1;
elseif isempty(period)
  period = 1;
end
if nargin < 5
  flag = 0;
elseif isempty(flag)
  flag = 0;
end
if nargin < 6
  plots = 1;
end
if flag == 1
  ax = mncn(x);
  ay = mncn(y);
else
  ax = auto(x);
  ay = auto(y);
end
for i = 1:n
  ax1 = ay(1:mp-n-1+i,1);
  ax2 = ax(n+2-i:mp,1);
  crcor(i,1) = ax1'*ax2/(mp-n+i-2);
  ax1 = ax(1:mp-n-1+i,1);
  ax2 = ay(n+2-i:mp,1);
  crcor(2*n+2-i,1) = ax1'*ax2/(mp-n+i-2);
end
crcor(n+1,1) = ax'*ay/(mp-1);
scl = period*(-n:1:n);
if logical(plots)
  plot(scl,crcor)
  f = axis;
  hold on
  plot([f(1) f(2)],[0 0],'--g',[0 0],[f(3) f(4)],'--g')
  if flag == 1
    title('Crosscovariance Function')
    ylabel('Covariance [CCF(Tau)]')
  else
    title('Crosscorrelation Function')
    ylabel('Correlation [CCF(Tau)]') 
  end
  xlabel('Signal Time Shift (Tau)')
  hold off
end
