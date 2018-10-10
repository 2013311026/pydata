function [S,Q,B,evals,evecs]=ICA_normal(X)
[m,n]=size(X); %获取输入矩阵的行/列数，行数为观测数据的数目，列数为采样点数
%---------白化/球化------
Cx = cov(X',1);    %计算协方差矩阵Cx 
[evecs,evals,V] = svd(Cx); %计算Cx的特征值和特征向量

Q=evals^(-1/2)*evecs';   %白化矩阵
z=Q*X;   %正交矩阵

%---------正交矩阵B------
Bc=rand(m)-0.5;                    % intialized column of matrix, B=[b1  b2  ...   bd]
[B,Br]=qr(Bc);                       % QR decomposition
for r=1:m                            % 迭代求取每一个独立元
    i=1;maxIterationsNum=10000;j=1;  % set max number of iteration
    b=B(:,r);
    while i<=maxIterationsNum+1
        if i==maxIterationsNum       % end of the cycle processing
            fprintf('\n第%d分量在%d次迭代内并不收敛。',r,maxIterationsNum);
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

S=B'*z; % ICA分离的独立元
W=B'*Q;    % X=W*S