function qn=kpca1(dtrain,kernel,q,Fa,Ca);
% KPCA -核主成分分析
%
% 使用 [trainFeat,bj]=kpca(data,kernel,p1,p2)
% 输入 data - 原始数据文件名
%      kernel - 核函数
%      p1 ,p2 - 核函数参数
%      q - 投影后的维数
% 输出    trainFeat - 映射到特征空间的样本

%训练样本
% global pp1,Fa,Ca
global pp1
[m n]=size(dtrain);
k=zeros(m,m);
% 计算核矩阵
 for i=1:m
       for j=1:m
          k(i,j) = svkernel(kernel,dtrain(i,:),dtrain(j,:));
       end
 end
D=mean(k,1);%列均    运行时注意查看一下D和C是否与原来的J和J’相等
% C=mean(k,2);%行均
E=mean(D);
J=repmat(D,m,1);
% J'
% J1=repmat(D',1,m);
% J2=repmat(C',m,1);%利用这种方法得到的结果和利用J和J'得到的结果是一样的
k=k-J-J'+repmat(E,m,m); %将核矩阵中心化
[pcs,evalue]=eigs(k,q,'LM'); %核矩阵的特征向量和特征值;这里的q只是粗选q个最大的特征值，这样应该可以减小后面的计算量
%注意：使用eigs函数取的最大的q个特征值后，matlab将自动将这些特征值当做是一个q阶矩阵产生的
%的特征值。为此，在下面计算贡献率时，它将q个特征值的贡献率当做为100%，将和实际的样本贡献率发生很大的差别
% evoctor=pcs;%%%%%%%%%
%EIGS(A,K,SIGMA) and EIGS(A,B,K,SIGMA) return K eigenvalues based on SIGMA:
       %'LM' or 'SM' - Largest or Smallest Magnitude
%特征向量规范化
sqrtL=1./sqrt(diag(evalue));
invsqrtL=diag(sqrtL);
clear sqrtL
%sqrtL=diag(sqrt(evalue));
%invsqrtL=diag(1./diag(sqrtL));%注意，这里最后得到的invsqrtL变量是以ai为元素的对角矩阵！！！！！！！！！！！！
% pcs=invsqrtL*pcs';%这里是是根据公式将a的模值等于特征值的根号分之一
pcs=invsqrtL*pcs';


value=sum(evalue);
eev=value;
Tnew=pcs*k';%映射到主成分空间；取对应主元个数个ai系数
Tnew=Tnew';%%测试样本经过投影映射后得到的主元矩阵%Tnew是m1*pnum维的
es=inv(diag(eev));
for i=1:m
    T2(i)=Tnew(i,:)*es*Tnew(i,:)';
end
c1=ones(m,1);
ep=(1/(m^2))*sum(sum(k));
epp=repmat(ep,m,1);
SPE=c1-(2/m).*sum(k,2)+epp-diag(Tnew*Tnew');%对于每一个新样本的SPE值是按照《故障诊断与容错控制》PPT上140页的公式2.64计算的，
tts=length(SPE);
ttt=1:1:tts;
figure(2)
plot(ttt,SPE,'g-o');
num=ceil(0.08*m);%去掉总数的10%，将其当作误差
sortts1=sort(T2,'descend');
sortts2=sort(SPE,'descend');
ddt=sortts2(1:num);
tt=length(ddt);
qn=[];
for i=1:tt
    qn=[qn,find(ddt(i)==SPE)];
end
