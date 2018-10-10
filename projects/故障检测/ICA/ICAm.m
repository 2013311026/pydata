close all;
clc;
clear all;

load d00.mat
X=d00;
load d04_te.dat
X_te=d04_te;

X_te1=X_te;
[n,m]=size(X);
[n_te,m_te]=size(X_te);

mean0=mean(X);
s=std(X);
X=zscore(X);

X_te=(X_te-ones(length(X_te),1)*mean0)./(ones(length(X_te),1)*s);%测试数据标准化处理

figure(1)
NIC=50;
[winv,source,B,whiteningMatrix]=fastica(X','numOfIC',NIC);

W=source;
Wa=ones(1,NIC);
Waa=ones(1,NIC);
Ba=ones(52,52);
sourcea=ones(NIC,52);

for i=1:NIC
    Wa(i)=norm(W(i,:));
end
for i=1:NIC
    [mem,Pos]=max(Wa);
    [row,col,men]=find(Wa==max(Wa));
    Waa(i)=Wa(col);
    sourcea(i,:)=W(col,:);
    Ba(:,i)=B(:,col);
    Wa(col)=0;
end
bar(Waa)

figure(2)
source=sourcea;
B=Ba;
ICR=25;
xnew=ones(NIC,1);
for i=1:n_te
    DATA3=X_te(i,:)*source([1:ICR],:)';
     Isquare(i)=DATA3*DATA3';
     xnew = inv(whiteningMatrix)*B(:,[1:ICR])*source([1:ICR],:)*X_te(i,:)';
     DATA4=X_te(i,:)*source([ICR:NIC],:)';
     IE(i)=DATA4*DATA4';
     
Q2(i)=(X_te(i,:)'-xnew)'*(X_te(i,:)'-xnew);
    %Isquare(i)=X_te(i,:)*inv(winv*winv')*X_te(i,:)';
end
[f_ksl,xil,ul]=ksdensity(Isquare(1:160),'function','cdf');
%[f_ksl,xil,ul]=ksdensity(CV,'function','cdf');
CLP=0.975;
for i=1:100
    if f_ksl(i)>=CLP;
        CL1=xil(i);
        %CL=14.162;
        break
    end
end
[f_ksl,xil,ul]=ksdensity(IE(1:160),'function','cdf');
%[f_ksl,xil,ul]=ksdensity(CV,'function','cdf');
CLP=0.975;
for i=1:100
    if f_ksl(i)>=CLP;
        CL2=xil(i);
        %CL=14.162;
        break
    end
end
%WM=inv(whiteningMatrix);
%subplot(5,5,j)
[f_ksl,xil,ul]=ksdensity(Q2(1:160),'function','cdf');
%[f_ksl,xil,ul]=ksdensity(CV,'function','cdf');
CLP=0.975;
for i=1:100
    if f_ksl(i)>=CLP;
        CL3=xil(i);
        %CL=14.162;
        break
    end
end

subplot(3,1,1)
plot(Isquare)
hold on
plot(CL1*ones(1,n_te),'r')
hold off                                                                            
subplot(3,1,2)
plot(IE);
hold on
plot(CL2*ones(1,n_te),'r')
hold off
subplot(3,1,3)
plot(Q2)
hold on
plot(CL3*ones(1,n_te),'r')
hold off




