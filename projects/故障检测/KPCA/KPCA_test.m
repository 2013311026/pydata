clear;
clc;

Xtrain=load('d00_te.dat');
Xtest=load('d01_te.dat');
Xtrain=double(Xtrain);
Xtest=double(Xtest);

% %% ����ѵ������
% num_sample=100;
% a=10*randn(num_sample,1);
% x1=a+randn(num_sample,1);
% x2=1*sin(a)+randn(num_sample,1);
% x3=5*cos(5*a)+randn(num_sample,1);
% x4=0.8*x2+0.1*x3+randn(num_sample,1);
% x=[x1,x2,x3,x4];
% xx_train=x;
% %% ������������
% a=10*randn(num_sample,1);
% x1=a+randn(num_sample,1);
% x2=1*sin(a)+randn(num_sample,1);
% x3=5*cos(5*a)+randn(num_sample,1);
% x4=0.8*x2+0.1*x3+randn(num_sample,1);
% xx_test=[x1,x2,x3,x4];
% xx_test(51:100,2)=xx_test(51:100,2)+15*ones(50,1);
% 
% Xtrain =xx_train;
% Xtest =xx_test;

%%
[n_ce,m_ce]=size(Xtest);
[Q,Qa99,Qa95,T2,t2a99,t2a95]=KPCA_model(Xtrain,Xtest);%������Ԫ����ģ��
 numgu=0;

if (Q>Qa95)                          %�ж��Ƿ񳬹�������
        asd='�й���';
        numgu=numgu+1;

    elseif (T2>t2a95)
         asd='�й���';
         numgu=numgu+1;

    else
       asd='�޹���';
end
shu=numgu;    

%% 
subplot(2,1,1)
plot(T2,'k')
hold on
plot(t2a99(ones(1,n_ce)),'r')
plot(t2a95(ones(1,n_ce)),'g')
title('��ͳ��Ԫ����T2ͳ��ͼ')
subplot(2,1,2)
plot(Q,'k')
hold on
plot(Qa99(ones(1,n_ce)),'r')
plot(Qa95(ones(1,n_ce)),'g')
title('��ͳ��Ԫ����Qͳ��ͼ')

i=(1:n_ce)*0.05;
figure,plot(i,T2,i,ones(1,960)*t2a99),xlabel('ʱ��(Сʱ)'),ylabel('T2ͳ����')
 hold on;
title('KPCA');
figure,plot(i,Q,i,ones(1,960)*Qa99),xlabel('ʱ��(Сʱ)'),ylabel('spEͳ����')
 hold on;
title('KPCA');
