function qn=kpca1(dtrain,kernel,q,Fa,Ca);
% KPCA -�����ɷַ���
%
% ʹ�� [trainFeat,bj]=kpca(data,kernel,p1,p2)
% ���� data - ԭʼ�����ļ���
%      kernel - �˺���
%      p1 ,p2 - �˺�������
%      q - ͶӰ���ά��
% ���    trainFeat - ӳ�䵽�����ռ������

%ѵ������
% global pp1,Fa,Ca
global pp1
[m n]=size(dtrain);
k=zeros(m,m);
% ����˾���
 for i=1:m
       for j=1:m
          k(i,j) = svkernel(kernel,dtrain(i,:),dtrain(j,:));
       end
 end
D=mean(k,1);%�о�    ����ʱע��鿴һ��D��C�Ƿ���ԭ����J��J�����
% C=mean(k,2);%�о�
E=mean(D);
J=repmat(D,m,1);
% J'
% J1=repmat(D',1,m);
% J2=repmat(C',m,1);%�������ַ����õ��Ľ��������J��J'�õ��Ľ����һ����
k=k-J-J'+repmat(E,m,m); %���˾������Ļ�
[pcs,evalue]=eigs(k,q,'LM'); %�˾������������������ֵ;�����qֻ�Ǵ�ѡq����������ֵ������Ӧ�ÿ��Լ�С����ļ�����
%ע�⣺ʹ��eigs����ȡ������q������ֵ��matlab���Զ�����Щ����ֵ������һ��q�׾��������
%������ֵ��Ϊ�ˣ���������㹱����ʱ������q������ֵ�Ĺ����ʵ���Ϊ100%������ʵ�ʵ����������ʷ����ܴ�Ĳ��
% evoctor=pcs;%%%%%%%%%
%EIGS(A,K,SIGMA) and EIGS(A,B,K,SIGMA) return K eigenvalues based on SIGMA:
       %'LM' or 'SM' - Largest or Smallest Magnitude
%���������淶��
sqrtL=1./sqrt(diag(evalue));
invsqrtL=diag(sqrtL);
clear sqrtL
%sqrtL=diag(sqrt(evalue));
%invsqrtL=diag(1./diag(sqrtL));%ע�⣬�������õ���invsqrtL��������aiΪԪ�صĶԽǾ��󣡣���������������������
% pcs=invsqrtL*pcs';%�������Ǹ��ݹ�ʽ��a��ģֵ��������ֵ�ĸ��ŷ�֮һ
pcs=invsqrtL*pcs';


value=sum(evalue);
eev=value;
Tnew=pcs*k';%ӳ�䵽���ɷֿռ䣻ȡ��Ӧ��Ԫ������aiϵ��
Tnew=Tnew';%%������������ͶӰӳ���õ�����Ԫ����%Tnew��m1*pnumά��
es=inv(diag(eev));
for i=1:m
    T2(i)=Tnew(i,:)*es*Tnew(i,:)';
end
c1=ones(m,1);
ep=(1/(m^2))*sum(sum(k));
epp=repmat(ep,m,1);
SPE=c1-(2/m).*sum(k,2)+epp-diag(Tnew*Tnew');%����ÿһ����������SPEֵ�ǰ��ա�����������ݴ���ơ�PPT��140ҳ�Ĺ�ʽ2.64����ģ�
tts=length(SPE);
ttt=1:1:tts;
figure(2)
plot(ttt,SPE,'g-o');
num=ceil(0.08*m);%ȥ��������10%�����䵱�����
sortts1=sort(T2,'descend');
sortts2=sort(SPE,'descend');
ddt=sortts2(1:num);
tt=length(ddt);
qn=[];
for i=1:tt
    qn=[qn,find(ddt(i)==SPE)];
end
