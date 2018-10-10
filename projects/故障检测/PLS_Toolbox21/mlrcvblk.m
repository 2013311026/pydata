function [press,b] = mlrcvblk(x,y,split)
%MLRCVBLK Fast Cross validation for MLR using contiguous data blocks
%  Inputs are the matrix of predictor variables (x), matrix
%  of predicted variables (y), and number of divisions of the data
%  (split). Outputs are the sum of the prediction residual error
%  sum of squares for all the test sets (press),
%  and the final regression vector (b).  
%  
%  This cross validation routine forms the test sets out of 
%  contiguous blocks of data. No mean centering of subsets is
%  used. This function is used primarily as a subroutine of GENALG. 
%
%I/O: [press,b] = mlrcvblk(x,y,split);

%Copyright Eigenvector Research, Inc. 1995-98

[mx,nx] = size(x);
[my,ny] = size(y);
if mx ~= my
  error('Number of samples must be the same in both blocks')
end
press = 0;
ind = ones(split,2);
for i = 1:split
  ind(i,2) = round(i*mx/split);
end 
for i = 1:split-1
  ind(i+1,1) = ind(i,2) +1;
end
for i = 1:split
  calx = [x(1:ind(i,1)-1,:); x(ind(i,2)+1:mx,:)];
  testx = x(ind(i,1):ind(i,2),:);
  caly = [y(1:ind(i,1)-1,:); y(ind(i,2)+1:mx,:)];
  testy = y(ind(i,1):ind(i,2),:);
  [mcx,ncx] = size(calx);
  if mcx >= ncx
    bbr = calx\caly;
  else
    [u,s,v] = svd(calx);
    s(1:mx:1:mx) = inv(s(1:mx:1:mx));
    bbr = v*s'*u'*y;
  end
  ypred = testx*bbr;
  press = press + sum((ypred-testy).^2);
end
if nargout > 1
  if mx >= nx
    b = calx\caly;
  else
    [u,s,v] = svd(calx);
    s(1:mx:1:mx) = inv(s(1:mx:1:mx));
    b = v*s'*u'*y;
  end
end

