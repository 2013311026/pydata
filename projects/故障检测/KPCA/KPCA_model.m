function[Q,Qa99,Qa95,T2,t2a99,t2a95]=KPCA_model(Xtrain,Xtest)
XX_mean=mean(Xtrain);%��ѵ��������ľ�ֵ
XX_std=std(Xtrain);%��ѵ��������ı�׼��


[XX_row,XX_col]=size(Xtrain);%ȡѵ����������к�����
[XC_row,XC_col]=size(Xtest);%ȡ������������к�����

%mean1=mean(K); std1=std(K);
%sr=(K-repmat(mean1,480,1))./repmat(std1,480,1);%��ѵ������׼��

for i=1:XX_col
Xtrain(:,i)=(Xtrain(:,i)-XX_mean(i))./XX_std(i);
end %��ѵ������׼��
for i=1:XC_col
Xtest(:,i)=(Xtest(:,i)-XX_mean(i))./XX_std(i);
end %�Բ��Լ���׼��


%for i=1:480
 % for j=1:480
  %     k(i,j)=exp(-sum((sr(i,:)-sr(j,:)).^2)/400);%����2�����Ķ�������
  %end
%end%����˾���K kX1=zeros(XX_row,XX_row); for i=1:XX_row
  %  for j=1:i
  %      kX(i,j)=exp(-(norm(Xtrain(i,:)-Xtrain(j,:))).^2/400);
  %  end
%end kX2=zeros(XX_row,XX_row); kX2=kX1'; kX=kX1; for i=1:XX_row
 %   for j=i+1:XC_row
  %      kX(i,j)=kX2(i,j);
 %   end
%end

for i=1:XX_row
 for j=1:XX_row
    kX(i,j)=exp(-(norm(Xtrain(i,:)-Xtrain(j,:))).^2/400);
 end
end%����ѵ�����ݵĺ˾���K
for i=1:XC_row
  for j=1:XC_row
       kC(i,j)=exp(-(norm(Xtest(i,:)-Xtest(j,:))).^2/400);
  end
end%����������ݵĺ˾���K

%lm=1/480*ones(480);%����IN

lmX=1/XX_row*ones(XX_row);%����ѵ�����ݵ�IN
lmC=1/XC_row*ones(XC_row);%����������ݵ�IN

%kl=k-lm*k-k*lm+lm*k*lm;%�Ժ˾���K��ֵ���Ļ�����

klX=kX-lmX*kX-kX*lmX+lmX*kX*lmX;%��ѵ�����ݵĺ˾���K��ֵ���Ļ�����
klC=kC-lmC*kC-kC*lmC+lmC*kC*lmC;%�Բ������ݵĺ˾���K��ֵ���Ļ�����
%[p,v]=pcacov(cov(kl));%�˺���������Э���������������Ԫ������

[pkX,lamdX,baifenX]=pcacov(cov(klX)); %�˺���������Э���������������Ԫ������
%pk�����ɷ֣������������ɵľ��󣩣�lamd�Ǻ˾����Э������������ֵ������ֵ���ɵ�����������������
%baifen��ÿ���������������ڹ۲����ܷ�������ռ�İٷ���������������������
%[pkC,lamdC,baifenC]=pcacov(cov(klC));

%�������������й�һ�� for i=1:480
%      ps(:,i)=p(:,i)/sqrt(v(i));
%end

%��ѵ�����ݵ������������й�һ��
for i=1:XX_row
      psX(:,i)=pkX(:,i)/sqrt(lamdX(i));
end
%�Բ������ݵ������������й�һ�� for i=1:XC_row
 %     psC(:,i)=pkC(:,i)/sqrt(lamdC(i));
%end


tX=klX*psX;%����SPEʱҪ�õ�
tC=klC*psX;


num_pc=1;%��Ԫ�����ĳ�ֵΪ1
while sum(lamdX(1:num_pc))/sum(lamdX)<0.85
num_pc=num_pc+1;
end %���ۻ�������С��85%��������Ԫ����
num_pc
%����ģ�ͣ�������ع���ԭʼ����
PX=psX(:,1:num_pc);
%PC=psC(:,1:num_pc);


TX=klX*PX;%����Ԫģ��


%�����Ŷȷֱ���99%��95%��T2ͳ�����Ŀ�����
t2a99=num_pc*(XX_row-1)*(XX_row+1)*icdf('f',0.99,num_pc,XX_row-num_pc)/(XX_row*(XX_row-num_pc));
t2a95=num_pc*(XX_row-1)*(XX_row+1)*icdf('f',0.95,num_pc,XX_row-num_pc)/(XX_row*(XX_row-num_pc));
%TL=16*479*481/(480*464)*finv(0.99,16,464);

%��Q������

%for i=1:52
%       spe(i)=sum(t(i,17:52).^2);
%end a=mean(spe); b=var(spe); QL=b/(2*a)*chi2inv(0.999,2*a^2/b);


for i=1:XX_row
       spe(i)=sum(tX(i,num_pc+1:XX_col).^2);
end
a=mean(spe);
b=var(spe);
%QL=b/(2*a)*chi2inv(0.999,2*a^2/b);

Qa99=b/(2*a)*chi2inv(0.999,2*a^2/b);
Qa95=b/(2*a)*chi2inv(0.95,2*a^2/b);


D=diag(lamdX);
for i=1:XC_row
T2(i)=klC(i,:)*PX*inv(D(1:num_pc,1:num_pc))*PX'*klC(i,:)';%��T2ͳ������T2��һ����
end

%for j=1:XC_row Q(j)=(norm(e(j,:)))^2;%����SPE
%Q(j)=Xtest(j,:)*(I-P*P')*(Xtest(j,:)');%�˹�ʽ��Q(j)=(norm(e(j,:)))^2��һ����;%����SPE��Q��һ����
%end
for i=1:XC_row
       Q(i)=sum(tC(i,num_pc+1:XC_col).^2);
end

