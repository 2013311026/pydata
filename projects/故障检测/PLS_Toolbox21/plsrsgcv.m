function coeff = plsrsgcv(data,lv,cvit,cvnum,out)
%PLSRSGCV Generates PLS models for MSPC with cross-validation
%  This function constructs a matrix of PLS models that
%  can be used like a PCA model for multivariate statistical
%  process control (MSPC) purposes. Given a data matrix (data)
%  a PLS model is formed using a maximum of (lv) latent variables
%  that relates each variable to all the others. The actual 
%  number of latent variables used is determined through cross
%  validation using (cvit) test sets with (cvnum) number of
%  samples chosen randomly. Optional variable (out) allows the
%  user to suppress intermediate output [out=0 suppresses output].
%  The PLS model regression vectors are collected in an output
%  matrix (coeff) which can be used like the I=PP' matrix in PCA.
%
%  Warning: This function can take a long time to execute
%  if you choose to do many cross-validations! Execution can
%  be speeded up by setting optional variable out=0.
%
%I/O: coeff = plsrsgcv(data,lv,cvit,cvnum,out);
%  
%See also: PLSRSGN, REPLACE, RPLCDEMO

%Copyright Eigenvector Research, Inc. 1991-97
%Modified BMW 4/94, NBG 10/96, 3/8
%Modified BMW 3/98

if nargin < 5, out = 1; end
[m,n] = size(data);
if lv >= n
  error('Number of lvs must be <= number of variables - 1')
end
if cvnum >= m
  error('Number of samples in test set must be < total samples')
end
coeff = -eye(n);
if out ~= 0, disp('  '), end
for i = 1:n
  x = [data(:,1:i-1) data(:,i+1:n) data(:,i)];
  press = zeros(lv,1);
  for j = 1:cvit
    if out ~= 0
      s = sprintf('Working on variable number %g, iteration %g',i,j);
      disp(s)
	end
    x = shuffle(x);  
    %[P,Q,W,T,U,b,ss] = pls(x(1:m-cvnum,1:n-1),x(1:m-cvnum,n),lv,out);
    %mm = conpred(b,W,P,Q,lv);
    %cm = cumsum(mm);
    cm = pls(x(1:m-cvnum,1:n-1),x(1:m-cvnum,n),lv,out);
    for k = 1:lv
      ypred = x(m-cvnum+1:m,1:n-1)*cm(k,:)';
      press(k,1) = sum((ypred-x(m-cvnum+1:m,n)).^2) + press(k,1);
    end
  end
  [a,bb] = min(press);
  if out ~= 0
    plot(press)
    s = sprintf('Cumulative PRESS versus Number of Latent Variables for Variable %g',i); 
    title(s)
    xlabel('Number of Latent Variables')
    ylabel('Cumulative PRESS')
    drawnow
    s = sprintf('Minimum PRESS for variable %g is at %g',i,bb);
    disp(s)
    s = sprintf('Now forming final PLS model for variable %g',i);
    disp(s)
  end
  %[P,Q,W,T,U,b,ss] = pls(x(:,1:n-1),x(:,n),bb,out);
  %mm = conpred(b,W,P,Q,bb);
  %if bb > 1
  %  cm = (sum(mm))';
  %else
  %  cm = mm';
  %end
  cm = pls(x(:,1:n-1),x(:,n),bb,out)';
  for j = 1:n-1
    if i>j
      coeff(j,i)   = cm(j,1);
    end
    if i<=j
      coeff(j+1,i) = cm(j,1);
    end
  end
end
coeff = -1*(coeff);
