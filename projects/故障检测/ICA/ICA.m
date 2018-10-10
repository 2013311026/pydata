close all;
clc;
clear all;
%load('simout0.mat');

%X(:,1:41)=simout0(1:6000,1:41);
%load xmv0.mat
%X(:,42:45)=xmv0(1:6000,1:4);
%X(:,46:48)=xmv0(1:6000,6:8);
%X(:,49:50)=xmv0(1:6000,10:11);
%load('simout5.mat');
%X_te=simout5(1:6500,1:41);
%load xmv5.mat
%X_te(:,42:45)=xmv5(1:6500,1:4);
%X_te(:,46:48)=xmv5(1:6500,6:8);
%X_te(:,49:50)=xmv5(1:6500,10:11);
load d00.mat
X=d00;%(1:100,:);
load d04_te.dat
X_te=d04_te;
%X_te(161:960,51)=0.86*X_te(161:960,51);
%X_te=x(:,1:200)';
%X_te1=X_te;
%[n,m]=size(X);
%Xb = XStd(X,'级差标准化');
%X = Xb - ones(n,1)*mean(Xb);
%mean0=mean(X);
%s=std(X);
%s=std(X);

%X=(X-ones(length(X),1)*mean(X))./(ones(length(X),1)*std(X));


X_te1=X_te;
[n,m]=size(X);
[n_te,m_te]=size(X_te);
%a=1;
%X=XStd(X,'中心标准化');
%X=XStd(X,'标准差标准化');
mean0=mean(X);
%s=std(X);
s=std(X);
%X=(X-ones(length(X),1)*mean(X))./(ones(length(X),1)*std(X));
X=zscore(X);
%[COEFF,SCORE,LATENT,TSQUARED]=princomp(X);%主元分析
%mm=50;
%X_te(201:300,mm)=1.2*X_te(201:300,mm);

%percent=0.85;
%k=0;
%for i=1:size(LATENT,1)
%    alpha(i)=sum(LATENT(1:i))/sum(LATENT);
 %   if alpha(i)>=percent
%        k=i;
%        break;
%    end
%end

%ALPHA=0.99;   
%[ts_ctr,spe_ctr,score_ctr]=PCAThrd(X,LATENT,ALPHA,k);  %控制限的计算
%[ts_ctr,spe_ctr]=PCAThrd(X,LATENT,ALPHA,1);  %控制限的计算
%mean0_te=mean(X_te);%对测试数据进行标准化
%s_te=std(X_te);
% X_te=XStd(X_te,'中心标准化');
% X_te=XStd(X_te,'标准差标准化');
%count0=0;
%figure(1);%SPE统计图（测试）
%X_te=(X_te-ones(length(X_te),1)*mean(X_te))./(ones(length(X_te),1)*std(X));
X_te=(X_te-ones(length(X_te),1)*mean0)./(ones(length(X_te),1)*s);
% mm=42;
% xmin=min(X(:,mm));
% xmax=max(X(:,mm));
% sst=(xmax-xmin)/s(mm);
% ss=mean0(mm);
% X_te(201:300,mm)=X_te(201:300,mm)+sst*ones(100,1);
%for i=1:n_te
 %   spe_te(i)=X_te(i,:)*(eye(m_te)-COEFF(:,1:k)*COEFF(:,1:k)')*X_te(i,:)';
%    if spe_te(i)>=spe_ctr
      %  count0+count0+1;
    %end
%end


%plot(spe_ctr(ones(1,n_te)),'r');
%hold off;



%X_tran=X*COEFF;%T方统计量（测试）
%X_tran=X_te*COEFF(:,[43:47]);
%PCC=p(:,3);
%X_tran=X*PCC;
%%[winv,source]=fastica(X','firstEig',20,'lastEig',30, 'numOfIC',8);
%[winv,source] = sobi(mX');
%load winv1.mat;
%W=inv(winv);
%X_te=(X_te-ones(length(X_te),1)*mean0)./(ones(length(X_te),1)*s);
%X_tran_te=X_te*COEFF(:,[43:48]);
%for j=1:24
figure(1)
NIC=50;
%[winv,source,B,whiteningMatrix]=fastica(X','firstEig',1,'lastEig',5, 'numOfIC',5);
[winv,source,B,whiteningMatrix]=fastica(X','numOfIC',NIC);
%whiteningMatrix=whiteningMatrix0(:,1:30);
%load source.mat
%load winvTE.mat
%load whiteningMatrixTE.mat
%load B.mat
%load sourceTE.mat
%load BTE.mat
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


