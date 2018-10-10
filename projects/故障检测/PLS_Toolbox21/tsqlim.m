function tsqcl = tsqlim(m,pc,cl)
%TSQLIM confidence limits for Hotelling's T^2
%  Inputs are the number of samples (m), the
%  number of PCs used (pc), and the confidence
%  limit (cl) in %. The output (tsqcl) is the 
%  confidence limit (tsqcl).
%
%I/O: tsqcl = tsqlim(m,pc,cl);
%
%Example: tsqcl = tsqlim(15,2,95);
%
%See also: MODLGUI, PCA, PCAGUI

%Copyright Eigenvector Research, Inc. 1997-98
%nbg 4/97

if cl>=100|cl<=0
  error('confidence limit must be 0<cl<100')
end
alpha = (100-cl)/100;
tsqcl = pc*(m-1)/(m-pc)*ftest(alpha,pc,m-pc);
