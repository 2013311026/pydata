function coeff = plsrsgn(data,lv,out)
%PLSRSGN Generates a matrix of PLS models for MSPC
%  This function constructs a matrix of PLS models that
%  can be used like a PCA model for multivariate statistical
%  process control (MSPC) purposes. Given a data matrix (data)
%  a PLS model is formed using (lv) latent variables that
%  relates each variable to all the others. An optional
%  variable (out) allows the user to suppress intermediate
%  output [out=0 suppresses output]. The PLS model regression
%  vectors are collected in an output matrix (coeff) which
%  can be used like the I=PP' matrix in PCA.
%
%I/O: coeff = plsrsgn(data,lv,out);
%
%See also: PLSRSGCV, REPLACE, RPLCDEMO, RSGNDEMO

%Copyright Eigenvector Research, Inc. 1991-2000
%Modified NBG 10/96, 3/98
%nbg 11/00 removed missdat from see also

if nargin<3, out = 1; end
[m,n] = size(data);
if lv >= n
  error('Number of latent variables must be < number of variables.')
end
coeff = -eye(n);
for i = 1:n
  if out ~= 0
    s = sprintf('The PLS model results follow for variable number %g',i);
    disp(s)
  end
  m  = pls([data(:,1:i-1) data(:,i+1:n)],data(:,i),lv,out);
  m  = m(lv,:)';
  for j = 1:n-1
    if i>j
      coeff(j,i)   = m(j,1);
    end
    if i<=j
      coeff(j+1,i) = m(j,1);
    end
  end
end
coeff = -1*coeff;
