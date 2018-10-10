function rescl = reslim(pc,s,cl)
%RESLIM confidence limits for Q residuals in X-block
%  Inputs are the number of PCs used (pc), the vector
%  of eigenvalues (s), and the confidence limit (cl)
%  in %. The output (rescl) is the confidence limit.
%  Jackson (1991).
%
%I/O: rescl = reslim(pc,s,cl);
%
%Example: rescl = reslim(2,ssq(:,2),95);
%
%See also: PCA, PCAGUI

%Copyright Eigenvector Research, Inc. 1997-98
%nbg 4/97,7/97
%bmw 12/99

if cl>=100|cl<=0
  error('confidence limit must be 0<cl<100')
end
[m,n] = size(s);
if m>1&n>1
  error('input s must be a vector')
end
if n>m
  s   = s';
  m   = n;
end
if pc>=length(s)
  rescl = 0;
else
  cl     = 2*cl-100;
  theta1 = sum(s(pc+1:m,1));
  theta2 = sum(s(pc+1:m,1).^2);
  theta3 = sum(s(pc+1:m,1).^3);
  h0     = 1-2*theta1*theta3/3/(theta2^2);
  if h0<0.001
    h0 = 0.001;
  end
  ca    = sqrt(2)*erfinv(cl/100);
  h1    = ca*sqrt(2*theta2*h0^2)/theta1;
  h2    = theta2*h0*(h0-1)/(theta1^2);
  rescl = theta1*(1+h1+h2)^(1/h0);
end
