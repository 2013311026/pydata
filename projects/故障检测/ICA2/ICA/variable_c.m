function [I2,SPE]=variable_c(X,ICn,Q,Bn)
n=size(ICn,2);
for i=1:n
    I2(i)=ICn(:,i)'*ICn(:,i);%�������I2����ֵ
    SPE(i)=(X(:,i)-inv(Q)*Bn*ICn(:,i))'*(X(:,i)-inv(Q)*Bn*ICn(:,i));
end;