function [eigs,skl] = ewfa(dat,window,plots,scl)
%EWFA Evolving Window factor Analysis
%  Inputs are the data matrix (dat), and the desired window
%  width (window). Optional inputs are (plots) which 
%  suppresses plotting when set to 0, (scl) is a scale to
%  plot the results against. Outputs are the singular values
%  (square roots of the eigenvalues of the covariance matrix)
%  for each window (eigs) and (skl) a scale to plot eigs against.
%  When plots = 1 [default] a plot of the windowed singular
%  values vs. sample number (or scale) is constructed. Note
%  that the singular values near the end of the record (less
%  than the half width of the window) are plotted as dashed lines.
%
%I/O: [eigs,skl] = ewfa(dat,window,plots,scl);
%
%See also: EVOLVFA, EFA_DEMO, PCA, WTTFA

% Copyright Eigenvector Research, Inc., 1997-9
% Modified BMW 4/98
% nbg 2/99

[m,n] = size(dat);
me = min([window n]);
eigs = zeros(me,m+window-1);
for i = 1:m+window-1
  if i < window
    eigs(1:min([i n]),i) = svd(dat(1:i,:));
  elseif i > m
    eigs(1:min([m-i+window n]),i) = svd(dat(i-window+1:m,:));
  else
    eigs(:,i) = svd(dat(i-window+1:i,:));
  end
end
%eigs = eigs.^2;
%scl = [1:.5:window/2+.5 [window/2 + 1.5:m-window/2+.5] m-window/2 + 1:.5:m];
if nargin<3
  plots = 1;
end
if nargin<4              %set up scale to plot against
  skl = [[1:.5:window/2+.5] [window/2 + 1.5:m-window/2+.5] [m-window/2 + 1:.5:m]]';
elseif length(scl)~=m
  warning(['scl must be = number of rows in dat [length(size(dat,1))]', ...
    'input scl not used'])
  skl = [[1:.5:window/2+.5] [window/2 + 1.5:m-window/2+.5] [m-window/2 + 1:.5:m]]';
else
  if window==1
    skl  = scl;
  else
    skl      = zeros(1,m+window-1);
    for ii=1:window
      skl(ii) = mean(scl(1:ii));
    end
	for ii=window+1:m
      skl(ii) = mean(scl(ii-window+1:ii));
	end
    for ii=m+1:m+window-1
      skl(ii) = mean(scl(ii-window+1:m));
    end
  end
end
if mean(eigs(me,:))/mean(eigs(me-1,:)) < 1e-6
  me = me-1;
end
if plots~=0
  semilogy(skl(1:window),eigs(1:me,1:window)','--'), hold on
  semilogy(skl(window:m),eigs(1:me,window:m)')
  semilogy(skl(m:m+window-1),eigs(1:me,m:m+window-1)','--'), hold off
  vline([skl(window) skl(m)])
  %vline(window/2 + .5), vline(m-window/2 + .5)
  title(sprintf('EWFA with Window Width = %g',window))
  xlabel('Sample Number of Window Center')
  ylabel('Singular Values')
end
