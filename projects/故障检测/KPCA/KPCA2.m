%KPCA
%% ����ѵ������
num_sample=100;
a=10*randn(num_sample,1);
x1=a+randn(num_sample,1);
x2=1*sin(a)+randn(num_sample,1);
x3=5*cos(5*a)+randn(num_sample,1);
x4=0.8*x2+0.1*x3+randn(num_sample,1);
x=[x1,x2,x3,x4];
xx_train=x;
%% ������������
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
X=Xtrain;                %����ԭʼ����X��
[n,m]=size(X);  %ԭʼ�����С��
c=mean(X);e=std(X); %��ֵ�ͷ��
X0=(X-ones(n,1)*c)./(ones(n,1)*e);%��׼��X0,��׼��Ϊ��ֵ0������1;
for i=1:n
       z=X0(i,:);
   for j=1:n
       y=X0(j,:);
       k(i,j)=exp(-norm(z-y)*norm(z-y)/(m*sqrt(e*e'))); %�˾���k��
   end
end
ln=ones(n,n)/n;
K=(k-ln*k-k*ln+ln*k*ln);   %��ֵ������,�ú˾���K��
[u,d,v]=svd(K); %u,vΪ����������d=n*d1Ϊ����ֵ���ɴ�С���У�
a=diag(d/n);    %����ֵ����
for i=1:n       %��׼����������u,ʹnorm(ui)*norm(ui)*n*ai=1;
    h=u(1:n,i:i);
    b=a(i,1);
    if b>0.0001
     U(1:n,i)=h/sqrt(b);%��׼�������������U��ÿ������norm(ui)*norm(ui)*n*ai=1;
    end     %����ֵ�ӽ�Ϊ0�ģ�û�б�׼����Ӧ����������;
end
[N,M]=size(U);  % ��׼�������������Ĵ�С�� 
for i=1:n
   s=a(1:i,1:1);
   cpv=sum(s)/sum(a); %cpvΪ�ۻ����װٷ���>85%��
   if cpv>0.85
      zhu=i;          %��Ԫ����
      break;
   end
end
for i=1:n
      z=K(i,:);
      for j=1:M
      y=U(:,j);
      t(i,j)=z*y;  %�������������ĺ���Ԫ��
      end
end
d1=d(1:zhu,1:zhu)/n; %ȡǰzhu����Ԫ�Խ���
for i=1:n
    z=t(i,1:zhu);
    T(i,1)=z*inv(d1)*z';%��������������T2ͳ������
    Q(i,1)=t(i,:)*t(i,:)'-z*z';%��������������Qͳ������
end
Ta=zhu*(n*n-1)*finv(0.99,zhu,(n-zhu))/(n*(n-zhu));%����T2ͳ���������ޣ�
g=std(Q)*std(Q)/(2*mean(Q)); % Q����gX2(h)�ֲ���g*hΪ��ֵ��2*g*g*hΪ���
h=2*mean(Q)*mean(Q)/(std(Q)*std(Q));
Qa=g*chi2inv(0.99,h);%����Qͳ���������ޣ�

%% ����������������D��
D=Xtest;
[r1,r2]=size(D);
D0=(D-ones(r1,1)*c)./(ones(r1,1)*e);%��׼��D0,��׼��
in=ones(1,n)/n;
for i=1:r1
       z=D0(i,:);
   for j=1:n
       y=X0(j,:);
       k1(i,j)=exp(-norm(z-y)*norm(z-y)/(3*m)); %�º˾���k1��
   end
end
for i=1:r1
       y=k1(i,:);
       K1(i,:)=y-in*K-y*ln+in*K*ln; %��ֵ���º˾���K1��
end
for i=1:r1
      z=K1(i,:);
      for j=1:M
      y=U(:,j);
      t1(i,j)=z*y;  %�������������ĺ���Ԫ��
      end
end
for i=1:r1
    z=t1(i,1:zhu);
    T1(i,1)=z*inv(d1)*z';%��������������T2ͳ����
    Q1(i,1)=t1(i,:)*t1(i,:)'-z*z';%��������������Qͳ����
end

%% 
i=(1:r1);
figure,plot(i,T1,i,ones(1,960)*Ta),xlabel('ʱ��(Сʱ)'),ylabel('T2ͳ����')
 hold on;
title('KPCA');
figure,plot(i,Q1,i,ones(1,960)*Qa),xlabel('ʱ��(Сʱ)'),ylabel('spEͳ����')
 hold on;
title('KPCA');