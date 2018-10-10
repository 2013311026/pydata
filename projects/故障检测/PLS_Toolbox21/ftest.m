function fstat = ftest(p,n,d,flag)
%FTEST Inverse F test and F test
%  For (flag) set to 1 {default} FTEST calculates the
%  F statistic (fstat) given the probability point (p)
%  and the numerator (n) and denominator (d) degrees
%  of freedom. (flag is an optional input {default = 1}.
%  For (flag) set to 2 FTEST calculates the probability
%  point (fstat) given the F statistic (p) and the
%  numerator (n) and denominator (d) degrees of freedom.
%
%Example:
%  a = ftest(0.05,5,8);
%  a = 3.685;
%  a = ftest(3.685,5,8,2);
%  a = 0.050;
%  
%I/O: fstat = ftest(p,n,d,flag);
%
%See also: TTESTP, STATDEMO

%Based on a public domain stats toolbox
%Modified 11/93,12/94 BMW, 10/96,12/97 NBG

n    = n/2;
d    = d/2;
if nargin<4
  flag = 1;
end
if flag==1
  p    = 1-p;
  ic   = 1;
  xl   = 0.0;
  xr   = 1.0;
  fxl  = -p;
  fxr  = 1.0 - p;
  if fxl*fxr>0
    error('probability not in the range(0,1) ')
  else
    while ic<30
      x   = (xl+xr)*0.5;
      p1  = betainc(x,n,d);
      fcs = p1-p;
      if fcs*fxl>0
        xl  = x;
        fxl = fcs;
      else
        xr  = x;
        fxr = fcs;
      end
      xrmxl = xr-xl;
      if xrmxl<=0.0001 | abs(fcs)<=1E-4
        break
      else
        ic  = ic+1;
      end
    end
  end
  if ic == 30
    error(' failed to converge ')
  end
  % Inverted numerator and denominator 12-26-94
  fstat = (d * x) / (n - n * x);
else
  fstat = betainc(2*d/(2*d+2*n*p),d,n);
end
