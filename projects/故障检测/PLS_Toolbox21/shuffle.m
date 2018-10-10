function y = shuffle(x)
%SHUFFLE Randomly re-orders matrix rows.
%  This funtion shuffles samples in a data file so
%  that they can be used randomly for cross validations.
%
%I/O: y = shuffle(x);

%Copyright Eigenvector Research, Inc. 1991-98
%Modified 11/93

[m,n] = size(x);
y     = zeros(m,n);
ind   = rand(m,1);
[a,b] = sort(ind);
for i = 1:m
  y(i,:) = x(b(i,1),:);
end
