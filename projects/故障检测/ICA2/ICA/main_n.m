clear all
clc
cont=0.9;
alpha=0.99;
c_aphla=2.32;    %��Ӧ��0.99������ˮƽΪ95%��Ӧ��λ��Ϊ1.645
%��ģ
xn=textread('d10.dat');
x=zscore(xn);
x=x';
[m,n]=size(x);
[S,Q,B,evals,evecs]=ICA_normal(x)
[ICn,Bn,d,ICa]=sort_IC(S,Q,B,cont);
[I2,SPE]=variable_c(x,ICn,Q,Bn);
[f1,x1,u1]=ksdensity(I2);%I2���������ܶȹ���
ConInt1=ComCon(f1,x1,alpha);
I2_limit=ConInt1(2);
SPE_limit=ksdensity(SPE,alpha,'function','icdf');

%���߼��
Xn=textread('d10_te.dat');
X=zscore(Xn);
X=X';
fault_I2_num=[];
fault_SPE_num=[];
[S_new,Q_new,B_new]=ICA_monitor(X,evals,evecs);
[ICn_new,Bn_new,d_new,ICa_new]=sort_IC(S_new,Q_new,B_new,cont);
[I2_new,SPE_new]=variable_c(X,ICn_new,Q_new,Bn_new);
for i=1:n
    if I2_new(i)>I2_limit
        fault_I2_num=[fault_I2_num,i];
    end;
    if SPE_new(i)>SPE_limit
        fault_SPE_num=[fault_SPE_num,i];
    end;
end;
fault_I2_num
fault_SPE_num

figure(1)
plot(1:length(I2_new),I2_new,'b');
hold on
plot(1:length(I2_new),ones(length(I2_new),1)*I2_limit,'r-');
xlabel('����');ylabel('�������I2����ֵ');
legend('I2ͳ��������','I2ͳ����������');
figure(2)
plot(1:length(SPE_new),SPE_new,'b');
hold on
plot(1:length(SPE_new),ones(length(SPE_new),1)*SPE_limit,'r-');
legend('SPEͳ��������','SPEͳ����������');
xlabel('����');ylabel('�������SPE����ֵ');

%�������
new1=fault_I2_num(1);
new2=fault_SPE_num(1);
Xc_new=inv(Q_new)*Bn_new*ICn_new;
cont_I2=Xc_new(:,new1)*norm(S_new(:,new1))/norm(Xc_new(:,new1));
cont_SPE=(X(:,new2)-Xc_new(:,new2)).^2;
figure(3)
bar(cont_I2);
xlabel('����');ylabel('������I2����');
figure(4)
bar(cont_SPE);
xlabel('����');ylabel('������SPE����');