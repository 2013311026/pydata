close all;
clc;
clear all;
% x1=rand(200,1);
% x2=2+2*rand(200,1);
% x3=2*x1;
% X=[x1,x2,x3];
 load d00.mat%����ѵ������
 X=d00;
% x4=2*rand(200,1);
% X_te(1:50,:)=[x1(1:50,:),x2(1:50,:),x3(1:50,:)];
% X_te(51:200,:)=[x1(51:200,:),x2(51:200,:),x4(51:200,:)];
 load d01_te.dat%�����������
 X_te=d01_te;
[n,m]=size(X);
[n_te,m_te]=size(X_te);
mean0=mean(X);%��¼������ֵ
s=std(X);%��¼��������
X=zscore(X);%ѵ�����ݷ�������׼��
[COEFF,SCORE,LATENT,TSQUARED]=princomp(X);%��Ԫ����
percent=0.85;%ѡȡ�������85%������Ԫ
k=0;%��Ԫ����
for i=1:size(LATENT,1)
    alpha(i)=sum(LATENT(1:i))/sum(LATENT);
    if alpha(i)>=percent
        k=i;
        break;
    end
end

ALPHA=0.95;   
%[ts_ctr,spe_ctr,score_ctr]=PCAThrd(X,LATENT,ALPHA,k);  %�����޵ļ���
[ts_ctr,spe_ctr]=PCAThrd(X,LATENT,ALPHA,k);  %�����޵ļ���
X_te=(X_te-ones(length(X_te),1)*mean0)./(ones(length(X_te),1)*s);%�������ݱ�׼������
for i=1:n_te%����SPEͳ����
    spe_te(i)=X_te(i,:)*(eye(m_te)-COEFF(:,1:k)*COEFF(:,1:k)')*X_te(i,:)';

end
for i=1:n_te;%����T2ͳ����
   xnew2=X_te(i,:)*COEFF(:,1:k);
    T2(i)=xnew2*diag(1./LATENT(1:k))*xnew2';
end
figure(1)%�������ͼ
subplot(2,1,1);
plot(T2);
title('T^2');
hold on;

plot(ts_ctr*ones(1,n_te),'r')
xlabel('������')
ylabel('T^2 Statistics')
legend('ͳ����','��ֵ')
hold off
subplot(2,1,2)
plot(spe_te);
title('SPE');
hold on;
plot(spe_ctr*ones(1,n_te),'r')
xlabel('������')
ylabel('SPE Statistics')
legend('ͳ����','��ֵ')
hold off


mn0=0;
for i=161:960
    if T2(i)>ts_ctr
        mn0=mn0+1;
    end
end
mnr0=mn0/800;
fprintf('%8.5f\n',mnr0);

mn0=0;
for i=161:960
    if spe_te(i)>spe_ctr
        mn0=mn0+1;
    end
end
mnr0=mn0/800;
fprintf('%8.5f\n',mnr0);

COEFF
SCORE

