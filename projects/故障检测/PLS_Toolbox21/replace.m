function rm = replace(r,vars)
%REPLACE Replaces variables based on PCA or PLS models
%  This function generates a matrix that can be used to 
%  replace "bad" variables from data matrices with the values
%  that are most consistent with the given PCA or PLS model.
%  The model (model) can be either a set of PCA loadings (column) 
%  vectors, the residuals generating matrix I-PP', or a PLS model
%  like the ones generated by the function plsrsgn or plsrsgcv. 
%  The variables to be replaced (vars) is a row vector containing 
%  the (column) indices  of the variables to be replaced. The
%  output matrix (rm) will replace variables with the values
%  which are most consistent with the given PCA or PLS model
%  right multiplied by a data matrix.
%
%I/O: rm = replace(model,vars);
%
%See also: MDPCA, PLSRSGN, RPLCDEMO

%Copyright Eigenvector Research, Inc. 1991-2000
%nbg 11/00 removed missdat from see also

[mr,nr] = size(r);
[mv,nv] = size(vars);
vars = sort(vars);
%  Check to see that information in vars is consistent with r
if max(vars) > mr
  error('Variable number specified is > total number of variables')
elseif min(vars) <= 0.0
  error('Variable number can not be negative')
end
for i = 1:nv-1
  if vars(1,i) == vars(1,i+1)
    error('Each variabe must only be specified once')
  end
end
dif = vars - round(vars);
for i = 1:nv
  if dif(1,i) ~= 0.0
    error('Variable indices must be integers')
  end
end
%  Check for model type--if PCA loadings convert to I-PP' form
if mr ~= nr
  r = eye(mr) - r*r';
end
%  Extract the r11 matrix from r using vars
r11 = zeros(nv);
for i = 1:nv
  for j = 1:nv
    r11(i,j) = r(vars(1,i),vars(1,j));
  end
end
%  Extract the r12 and r21 matrix from r using vars
for k = 1:2
  temp = zeros(nv,mr);
  for i = 1:nv
    temp(i,:) = r(vars(1,i),:);
  end
  c = 0;
  for i = 1:nv
    temp(:,vars(1,i)-c:mr-1) = temp(:,(vars(1,i)+1-c):mr);
    c = c+1;
  end
  if k == 1
    r12 = temp(:,1:mr-nv);
    r = r';
  else
    r21 = temp(:,1:mr-nv);
  end
end
%  Calculate the regression matrix rr
rave = (r12+r21)./2;
rr = -rave'*inv(r11);
%  Map rr into the replacement matrix rm
rm = eye(mr);
temp = [rr; zeros(nv)];
for i = 1:nv
  temp(vars(1,i)+1:mr,:) = temp(vars(1,i):mr-1,:);
end
for i = 1:nv
  temp(vars(1,i),:) = zeros(1,nv);
end
for i = 1:nv
  rm(:,vars(1,i)) = temp(:,i);
end
