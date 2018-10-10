function[Q,Qa99,Qa95,T2,t2a99,t2a95]=KPCA_model(Xtrain,Xtest)
XX_mean=mean(Xtrain);%求训练数据阵的均值
XX_std=std(Xtrain);%求训练数据阵的标准差


[XX_row,XX_col]=size(Xtrain);%取训练数据阵的行和列数
[XC_row,XC_col]=size(Xtest);%取测试数据阵的行和列数

%mean1=mean(K); std1=std(K);
%sr=(K-repmat(mean1,480,1))./repmat(std1,480,1);%对训练集标准化

for i=1:XX_col
Xtrain(:,i)=(Xtrain(:,i)-XX_mean(i))./XX_std(i);
end %对训练集标准化
for i=1:XC_col
Xtest(:,i)=(Xtest(:,i)-XX_mean(i))./XX_std(i);
end %对测试集标准化


%for i=1:480
 % for j=1:480
  %     k(i,j)=exp(-sum((sr(i,:)-sr(j,:)).^2)/400);%利用2范数的定义来求
  %end
%end%计算核矩阵K kX1=zeros(XX_row,XX_row); for i=1:XX_row
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
end%计算训练数据的核矩阵K
for i=1:XC_row
  for j=1:XC_row
       kC(i,j)=exp(-(norm(Xtest(i,:)-Xtest(j,:))).^2/400);
  end
end%计算测试数据的核矩阵K

%lm=1/480*ones(480);%定义IN

lmX=1/XX_row*ones(XX_row);%定义训练数据的IN
lmC=1/XC_row*ones(XC_row);%定义测试数据的IN

%kl=k-lm*k-k*lm+lm*k*lm;%对核矩阵K均值中心化处理

klX=kX-lmX*kX-kX*lmX+lmX*kX*lmX;%对训练数据的核矩阵K均值中心化处理
klC=kC-lmC*kC-kC*lmC+lmC*kC*lmC;%对测试数据的核矩阵K均值中心化处理
%[p,v]=pcacov(cov(kl));%此函数是利用协方差矩阵对其进行主元分析。

[pkX,lamdX,baifenX]=pcacov(cov(klX)); %此函数是利用协方差矩阵对其进行主元分析。
%pk是主成分（特征向量构成的矩阵），lamd是核矩阵的协方差矩阵的特征值（特征值构成的向量。列向量），
%baifen是每个特征向量表征在观测量总方差中所占的百分数（向量。列向量）。
%[pkC,lamdC,baifenC]=pcacov(cov(klC));

%对特征向量进行归一化 for i=1:480
%      ps(:,i)=p(:,i)/sqrt(v(i));
%end

%对训练数据的特征向量进行归一化
for i=1:XX_row
      psX(:,i)=pkX(:,i)/sqrt(lamdX(i));
end
%对测试数据的特征向量进行归一化 for i=1:XC_row
 %     psC(:,i)=pkC(:,i)/sqrt(lamdC(i));
%end


tX=klX*psX;%计算SPE时要用到
tC=klC*psX;


num_pc=1;%主元个数的初值为1
while sum(lamdX(1:num_pc))/sum(lamdX)<0.85
num_pc=num_pc+1;
end %若累积贡献率小于85%则增加主元个数
num_pc
%建立模型，计算出重构的原始数据
PX=psX(:,1:num_pc);
%PC=psC(:,1:num_pc);


TX=klX*PX;%核主元模型


%求置信度分别在99%，95%的T2统计量的控制限
t2a99=num_pc*(XX_row-1)*(XX_row+1)*icdf('f',0.99,num_pc,XX_row-num_pc)/(XX_row*(XX_row-num_pc));
t2a95=num_pc*(XX_row-1)*(XX_row+1)*icdf('f',0.95,num_pc,XX_row-num_pc)/(XX_row*(XX_row-num_pc));
%TL=16*479*481/(480*464)*finv(0.99,16,464);

%求Q控制限

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
T2(i)=klC(i,:)*PX*inv(D(1:num_pc,1:num_pc))*PX'*klC(i,:)';%求T2统计量。T2是一向量
end

%for j=1:XC_row Q(j)=(norm(e(j,:)))^2;%计算SPE
%Q(j)=Xtest(j,:)*(I-P*P')*(Xtest(j,:)');%此公式与Q(j)=(norm(e(j,:)))^2是一样的;%计算SPE。Q是一向量
%end
for i=1:XC_row
       Q(i)=sum(tC(i,num_pc+1:XC_col).^2);
end

