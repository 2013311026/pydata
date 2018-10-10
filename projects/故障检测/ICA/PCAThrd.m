%PCA的T方控制限和SPE控制限求算函数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%输入X为标准化后的样本矩阵（行向量样本），latent为主元分析的，alpha为检验水平，k为主元个数
%输出ts_ctrl为T方控制限，spe_ctrl为SPE控制限
function [ts_ctrl,spe_ctrl]=PCAThrd(X,latent,alpha,k)
[n,m]=size(X);

%利用F分布求T方控制限
ts_ctrl=k*(n-1)*n/((n+1)*(n-k))*finv(alpha,k,n-k);

% 利用正态分布求SPE控制限
theta=zeros(3,1);
for i=1:3
    for j=k+1:m
        theta(i)=theta(i)+latent(j)^(i);
    end
end
h0=1-2*theta(1)*theta(3)/(3*theta(2)^2);
spe_ctrl=1.2*theta(1)*(norminv(alpha)*(2*theta(2)*h0^2)^0.5/theta(1)+1+theta(2)*h0*(h0-1)/theta(1)^2)^(1/h0);
