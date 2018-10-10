function b = cr(x,y,lv,powers);
%CR Continuum Regression for multivariate y
%  The inputs are the matrix of predictor variables (x), matrix
%  or vector of predicted variables (y), number of latent  
%  variables to consider (lv) and a vector of powers to consider
%  (powers). The output is a matrix of regression vectors or 
%  matrices (b) where each row, or block of ny rows (where ny is 
%  the number of predicted variables), of b correspond to a 
%  regression vector or matrix for a particular power and number
%  of latent variables. The regression vectors are grouped by power
%  and ordered by number of latent variables. For example, if there
%  are 2 y variables and 10 lvs considered, the first 20 rows of b
%  are the models for the first power considered, the first 2 rows
%  are the regression matrix for the first power and 1 latent variable.
%
%  This routine is based on one developed by Sijmen de Jong and uses
%  the continuum power method in canonical space. The routine was
%  tested and modifed by Barry M. Wise.
%  
%I/O: b = cr(x,y,lv,powers);
%
%Example: 
%  b = cr(x,y,10,[0 .25 .5 1 2 4 inf]);
%  finds the continuum regression vectors up to 10 LVs for powers of 0
%  (i.e. MLR), .25, .5, 1 (i.e. PLS), 2, 4, and inf (i.e. PCR).
%
%See also: CRCVRND, PLS

%Copyright Eigenvector Research, Inc. 1996-98
%Modified BMW 12/98 - Added support for powers 0 and inf

[mx,nx] = size(x);
[my,ny] = size(y);
if mx >= nx
  [u,s,v] = svd(x,0);  
else 
  [v,s,u] = svd(x',0);
end
s1 = s(1);
os = diag(s);
s = diag(s)/s1;
rnk = sum(s>1e-14);
s = s(1:rnk);
os = os(1:rnk);
u = u(:,1:rnk);
v = v(:,1:rnk);
if lv > rnk
 disp('Number of Latent Variables > Rank of x-block')
 disp(sprintf('Changing number of LVs to Rank x-block = %g',rnk))
 lv = rnk;
end
np = length(powers);
uty = u'*y;
b = zeros(rnk,np*lv*ny);
k = 0;
for j = 1:np
  if (powers(j) ~= inf & powers(j) ~= 0)
    sp2 = s.^(2*powers(j));
    f = uty;
    zz = zeros(rnk,lv);
    for a = 1:lv
      if ny == 1
        z = sp2.*f;
	  else
	    ss = diag(sp2)*f;
	    [qa,covsq] = eig(ss'*f);
	    z = ss*qa(:,find(diag(covsq)==max(diag(covsq))));
	  end
      z = z-zz(:,1:max(1,a-1))*(z'*zz(:,1:max(1,a-1)))';
      z = z/sqrt(z'*z);
      zz(:,a) = z;
      c = z'*f;
      f = f-z*c;
      k = k+1;
	  lastb = b(:,ny*(k-(a>1)-1)+1:ny*(k-(a>1)));
      b(:,ny*(k-1)+1:ny*k) = lastb + (z./s)*(c/s1);
    end
  elseif powers(j) == inf
    for a = 1:lv
      k = k+1;
      b(1:a,ny*(k-1)+1:ny*k) = (u(:,1:a)*diag(os(1:a)))\y; 
    end
  elseif powers(j) == 0
    bmlr = (u(:,1:rnk)*diag(os(1:rnk)))\y;
    for a = 1:lv
      k = k+1;
      b(:,ny*(k-1)+1:ny*k) = bmlr; 
    end
  end
end
b = (v*b)';                             

  
