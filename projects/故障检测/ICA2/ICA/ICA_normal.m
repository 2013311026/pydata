function [S,Q,B,evals,evecs]=ICA_normal(X)
[m,n]=size(X); %��ȡ����������/����������Ϊ�۲����ݵ���Ŀ������Ϊ��������
%---------�׻�/��------
Cx = cov(X',1);    %����Э�������Cx 
[evecs,evals,V] = svd(Cx); %����Cx������ֵ����������

Q=evals^(-1/2)*evecs';   %�׻�����
z=Q*X;   %��������

%---------��������B------
Bc=rand(m)-0.5;                    % intialized column of matrix, B=[b1  b2  ...   bd]
[B,Br]=qr(Bc);                       % QR decomposition
for r=1:m                            % ������ȡÿһ������Ԫ
    i=1;maxIterationsNum=10000;j=1;  % set max number of iteration
    b=B(:,r);
    while i<=maxIterationsNum+1
        if i==maxIterationsNum       % end of the cycle processing
            fprintf('\n��%d������%d�ε����ڲ���������',r,maxIterationsNum);
            break;
        end
        b0=b;                     
        t=z'*b;
        g=tanh(t);
        dg=1-tanh(t).^2;
        b=z*g/n-mean(dg)*b;         % key equation
        %%%%%%%%%%%% standardization of b
        ssum=zeros(m,1);
        for counter=1:r-1
            ssum=ssum+(b'*B(:,counter))*B(:,counter);   
        end
        b=b-ssum;                 
        b=b/norm(b);
        %%%%%%%%%%%  convergence judgment
        if abs(abs(b'*b0)-1)<1e-9         % if convergence,save b 
               B(:,r)=b; 
             break;
        end
        i=i+1;        
    end 
end

S=B'*z; % ICA����Ķ���Ԫ
W=B'*Q;    % X=W*S