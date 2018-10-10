%KPCA
%% 产生训练数据
num_sample=100;
a=10*randn(num_sample,1);
x1=a+randn(num_sample,1);
x2=1*sin(a)+randn(num_sample,1);
x3=5*cos(5*a)+randn(num_sample,1);
x4=0.8*x2+0.1*x3+randn(num_sample,1);
x=[x1,x2,x3,x4];
xx_train=x;
%% 产生测试数据
a=10*randn(num_sample,1);
x1=a+randn(num_sample,1);
x2=1*sin(a)+randn(num_sample,1);
x3=5*cos(5*a)+randn(num_sample,1);
x4=0.8*x2+0.1*x3+randn(num_sample,1);
xx_test=[x1,x2,x3,x4];
xx_test(51:100,2)=xx_test(51:100,2)+15*ones(50,1);

Xtrain =xx_train;
Xtest =xx_test;

%% 
Xtrain=load('d00_te.dat');
Xtest=load('d01_te.dat');
Xtrain=double(Xtrain);
Xtest=double(Xtest);

%% 
X=Xtrain;                %输入原始矩阵X；
[n,m]=size(X);  %原始矩阵大小；
c=mean(X);e=std(X); %均值和方差；
X0=(X-ones(n,1)*c)./(ones(n,1)*e);%标准阵X0,标准化为均值0，方差1;
for i=1:n
       z=X0(i,:);
   for j=1:n
       y=X0(j,:);
       k(i,j)=exp(-norm(z-y)*norm(z-y)/(m*sqrt(e*e'))); %核矩阵k；
   end
end
ln=ones(n,n)/n;
K=(k-ln*k-k*ln+ln*k*ln);   %均值化处理,得核矩阵K；
[u,d,v]=svd(K); %u,v为特征向量；d=n*d1为特征值，由大到小排列；
a=diag(d/n);    %特征值向量
for i=1:n       %标准化特征向量u,使norm(ui)*norm(ui)*n*ai=1;
    h=u(1:n,i:i);
    b=a(i,1);
    if b>0.0001
     U(1:n,i)=h/sqrt(b);%标准化后的特征矩阵U，每列满足norm(ui)*norm(ui)*n*ai=1;
    end     %特征值接近为0的，没有标准化对应的特征向量;
end
[N,M]=size(U);  % 标准化的特征向量的大小； 
for i=1:n
   s=a(1:i,1:1);
   cpv=sum(s)/sum(a); %cpv为累积贡献百分率>85%；
   if cpv>0.85
      zhu=i;          %主元个数
      break;
   end
end
for i=1:n
      z=K(i,:);
      for j=1:M
      y=U(:,j);
      t(i,j)=z*y;  %计算正常样本的核主元；
      end
end
d1=d(1:zhu,1:zhu)/n; %取前zhu个主元对角阵；
for i=1:n
    z=t(i,1:zhu);
    T(i,1)=z*inv(d1)*z';%计算正常样本的T2统计量；
    Q(i,1)=t(i,:)*t(i,:)'-z*z';%计算正常样本的Q统计量；
end
Ta=zhu*(n*n-1)*finv(0.99,zhu,(n-zhu))/(n*(n-zhu));%计算T2统计量控制限；
g=std(Q)*std(Q)/(2*mean(Q)); % Q服从gX2(h)分布，g*h为均值，2*g*g*h为方差；
h=2*mean(Q)*mean(Q)/(std(Q)*std(Q));
Qa=g*chi2inv(0.99,h);%计算Q统计量控制限；

%% 输入待检测样本矩阵D；
D=Xtest;
[r1,r2]=size(D);
D0=(D-ones(r1,1)*c)./(ones(r1,1)*e);%标准阵D0,标准化
in=ones(1,n)/n;
for i=1:r1
       z=D0(i,:);
   for j=1:n
       y=X0(j,:);
       k1(i,j)=exp(-norm(z-y)*norm(z-y)/(3*m)); %新核矩阵k1；
   end
end
for i=1:r1
       y=k1(i,:);
       K1(i,:)=y-in*K-y*ln+in*K*ln; %均值化新核矩阵K1；
end
for i=1:r1
      z=K1(i,:);
      for j=1:M
      y=U(:,j);
      t1(i,j)=z*y;  %计算待检测样本的核主元；
      end
end
for i=1:r1
    z=t1(i,1:zhu);
    T1(i,1)=z*inv(d1)*z';%计算待检测样本的T2统计量
    Q1(i,1)=t1(i,:)*t1(i,:)'-z*z';%计算待检测样本的Q统计量
end

%% 
i=(1:r1);
figure,plot(i,T1,i,ones(1,960)*Ta),xlabel('时间(小时)'),ylabel('T2统计量')
 hold on;
title('KPCA');
figure,plot(i,Q1,i,ones(1,960)*Qa),xlabel('时间(小时)'),ylabel('spE统计量')
 hold on;
title('KPCA');