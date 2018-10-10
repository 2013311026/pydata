function acor = autocor(x,n,period,plots)
%AUTOCOR Autocorrelation of time series
%  Performs the autocorrelation function of a time series.
%  The inuputs are the time series vector (x),
%  the number of sample periods to consider (n),
%  and the optional variable of the sample time
%  (period) which is used to scale the output plot.
%  The output is the autocorrelation function (acor).
%  If optional input (plots) is set to zero no
%  plots are constructed.
%Example:
%     acor = autocor(x,20,[],0);
%
%I/O: acor = autocor(x,n,period,plots);
%
%See also: CORRMAP, CROSSCOR, CCORDEMO

%Copyright Eigenvector Research, Inc. 1992-99
%Modified BMW 11/93, nbg 3/99

[mp,np] = size(x);
if nargin<3
  period = 1;
elseif isempty(period)
  period = 1;
end
if nargin<4
  plots  = 1;
end
if np > mp
  x   = x';
  mp  = np;
end
acor  = zeros(2*n+1,1);
ax    = auto(x);
for i = 1:n
  ax1 = ax(1:mp-n-1+i,1);
  ax2 = ax(n+2-i:mp,1);
  acor(i,1) = ax1'*ax2/(mp-n+i-2);
end
acor(n+1,1) = ax'*ax/(mp-1);
for i = 1:n
  acor(n+i+1) = acor(n+1-i);
end
scl = period*(-n:1:n);
if logical(plots)
  plot(scl,acor)
  title('Autocorrelation Function')
  xlabel('Signal Time Shift (Tau)')
  ylabel('Correlation [ACF(Tau)]') 
  hold on
  plot(scl,zeros(size(scl)),'--g',[0 0],[-1 1],'--g')
  axis([scl(1,1) -scl(1,1) -1 1])
  hold off
end
