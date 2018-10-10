function y = ttestp(x,a,z) 
%TTESTP Evaluates t-distribution and its inverse
%  Evaluates a t-distribution with input flag (z).
%  For z = 1 the output (y) is the probability for given
%  t-statistic (x) with (a) degrees of freedom.
%Example: y = ttestp(1.9606,5000,1).
%  y  = 0.025;
%
%  For z = 2 the output (y) is the t-statistic for given
%  probability (x) with (a) degrees of freedom.
%Example: y = ttestp(0.005,5000,2).
%  y  = 2.533;
% 
%I/O: y = ttestp(x,a,z) 
%
%See also: FTEST, STATDEMO

%Based on a public domain stats toolbox
%Modified 12/94 BMW, 10/96 NBG

aa = a * 0.5;
if z == 1
  xx = a / (a + x^2);
  bb = 0.50;
  tmp = betainc(xx,aa,bb);
  y = tmp * 0.50;
elseif z == 2
  ic = 1;
  xl = 0.0;
  xr = 1.0;
  fxl = -x*2;
  fxr = 1.0 - (x*2);
  if fxl * fxr > 0
    error('probability not in the range(0,1) ')
  else
    while ic < 30
	  xx = (xl + xr) * 0.5;
   	  p1 = betainc(xx,aa,0.5);
	  fcs = p1 - (x*2);
	  if fcs * fxl > 0
	    xl = xx;
	    fxl = fcs;
	  else
	    xr = xx;
	    fxr = fcs;
	  end
	  xrmxl = xr - xl;
	  if xrmxl <= 0.0001 | abs(fcs) <= 1E-4
	    break
	  else
	    ic = ic + 1;
   	  end
    end
  end
  if ic == 30
    error(' failed to converge ')
  end
  tmp = xx;
  y = sqrt((a - a * tmp) / tmp);
else
  error('z must be 1 or 2')
end

