import numpy as np
import pandas as pd
from scipy import linalg,stats
import matplotlib.pyplot as plt
import seaborn as sns
sns.set()


# # 产生训练数据
# num_sample = 100
# a = 10*np.random.randn(num_sample,1)
# x1 = a+np.random.randn(num_sample,1)
# x2 = 1*np.sin(a)+np.random.randn(num_sample,1)
# x3 = 5*np.cos(5*a)+np.random.randn(num_sample,1)
# x4 = 0.8*x2+0.1*x3+np.random.randn(num_sample,1)
# x = np.hstack((x1,x2,x3,x4))
# xx_train = x
#
# # 产生测试数据
# a = 10*np.random.randn(num_sample,1)
# x1 = a+np.random.randn(num_sample,1)
# x2 = 1*np.sin(a)+np.random.randn(num_sample,1)
# x3 = 5*np.cos(5*a)+np.random.randn(num_sample,1)
# x4 = 0.8*x2+0.1*x3+np.random.randn(num_sample,1)
# xx_test = np.hstack((x1,x2,x3,x4))
# xx_test[50:,1] = xx_test[50:,1]+15*np.ones(50)
#
# Xtrain = xx_train
# Xtest = xx_test

data = pd.read_csv('/Users/jing/pydata/datasets/plantiq/广西卷烟厂/m114_p.csv')
data = data.drop(['采集时间','生产日期','班次','设备ID','产品ID'], axis=1)
Xtrain = np.array(data[:500])
Xtest = np.array(data[500:])

# 标准化处理
X_mean = np.mean(Xtrain, axis=0)  #按列求Xtrain平均值
X_std = np.std(Xtrain, axis=0)  #求标准差
X_row,X_col = Xtrain.shape  #求Xtrain行、列数

Xtrain = (Xtrain-np.tile(X_mean,(X_row,1)))/np.tile(X_std,(X_row,1))

# 求协方差矩阵
sigmaXtrain = np.cov(Xtrain, rowvar=False)
#对协方差矩阵进行特征分解，lamda为特征值构成的对角阵，T的列为单位特征向量，且与lamda中的特征值一一对应：
lamda,T = linalg.eig(sigmaXtrain)

#取对角元素(结果为一列向量)，即lamda值，并上下反转使其从大到小排列，主元个数初值为1，若累计贡献率小于90%则增加主元个数
# D = flipud(diag(lamda))
T = T[:,lamda.argsort()]  #将T的列按照lamda升序排列
lamda.sort()  #将lamda按升序排列
D = -np.sort(-np.real(lamda))  #提取实数部分，按降序排列
num_pc = 1
while sum(D[0:num_pc])/sum(D) < 0.9:
    num_pc += 1

#取与lamda相对应的特征向量
P = T[:,X_col-num_pc:X_col]
TT = Xtrain.dot(T)
TT1 = Xtrain.dot(P)

# 求置信度为95%时的T2统计控制限
T2UCL1 = num_pc*(X_row-1)*(X_row+1)*stats.f.ppf(0.95,num_pc,X_row-num_pc)/(X_row*(X_row-num_pc))

# 置信度为95%的Q统计控制限
theta = []
for i in range(1, num_pc+1):
    theta.append(sum((D[num_pc:])**i))
h0 = 1 - 2*theta[0]*theta[2]/(3*theta[1]**2)
ca = stats.norm.ppf(0.95,0,1)
QUCL = theta[0]*(h0*ca*np.sqrt(2*theta[1])/theta[0] + 1 + theta[1]*h0*(h0 - 1)/theta[0]**2)**(1/h0)


# 在线监测：
# 标准化处理
# X_mean = np.mean(Xtest, axis=0)  #按列求Xtest平均值
# X_std = np.std(Xtest, axis=0)  #求标准差
n = Xtest.shape[0]  #求Xtest行数

Xtest = (Xtest-np.tile(X_mean,(n,1)))/np.tile(X_std,(n,1))

# 求T2统计量，Q统计量
r,y = (P.dot(P.T)).shape
I = np.eye(r,y)

T2 = np.zeros(n)
Q = np.zeros(n)
for i in range(n):
    T2[i] = Xtest[i,:].dot(P).dot(linalg.pinv(np.diag(lamda.real)[X_col-num_pc:,X_col-num_pc:])).dot(P.T).dot(Xtest[i,:].T)
    Q[i] = Xtest[i,:].dot((I-P.dot(P.T))).dot((I-P.dot(P.T)).T).dot(Xtest[i,:].T)

# 绘图
plt.subplot(2,1,1)
plt.plot(np.r_[1:n+1],T2,'k')
plt.title('主元分析统计量变化图')
plt.xlabel('采样数')
plt.ylabel('T^2')
plt.plot(np.r_[1:n+1],T2UCL1*np.ones(n),'r--')

plt.subplot(2,1,2)
plt.plot(np.r_[1:n+1],Q,'k')
plt.xlabel('采样数')
plt.ylabel('SPE')
plt.plot(np.linspace(1, n, n),QUCL*np.ones(n),'r--')
plt.show()

# 贡献图
#1.确定造成失控状态的得分
S = Xtest[51,:].dot(P[:,:num_pc])
r = []
for i in range(0,num_pc):
    if S[i]**2/lamda[i].real > T2UCL1/num_pc:
        r = np.r_[r,i]

#2.计算每个变量相对于上述失控得分的贡献
cont = np.zeros((len(r),X_col))
i = len(r)-1
for j in range(0,X_col):
    cont[i,j] = abs(S[i]/D[i]*P[j,i]*Xtest[51,j])

#3.计算每个变量的总贡献
contj = np.zeros((X_col))
for j in range(0,X_col):
    contj[j] = sum(cont[:,j])

#4.计算每个变量对Q的贡献
e = Xtest[51,:].dot((I - P.dot(P.T)))
contq = e**2

#5. 绘制贡献图
plt.subplot(2,1,1)
plt.bar(np.r_[1:X_col+1],contj)
plt.xlabel('变量号')
plt.ylabel('T^2贡献率 %')

plt.subplot(2,1,2)
plt.bar(np.r_[1:X_col+1],contq)
plt.xlabel('变量号')
plt.ylabel('Q贡献率 %')
plt.show()

# 计算控制限
alpha = 0.9
S = np.diag(lamda.real)[X_col-num_pc:,X_col-num_pc:]
FAI = P.dot(linalg.pinv(S)).dot(P.T)/T2UCL1+(np.eye(X_col)-P.dot(P.T))/QUCL
S = np.cov(Xtrain, rowvar=False)
g = np.trace((S.dot(FAI))**2)/np.trace(S.dot(FAI))
h = (np.trace(S.dot(FAI)))**2/np.trace((S.dot(FAI))**2)
kesi = g*stats.chi2.ppf(alpha,h)
# 综合指标
fai = (Q/QUCL)+(T2/T2UCL1)
plt.plot(np.r_[1:n+1],fai)
plt.title('混合指标')
plt.plot(np.linspace(1, n, n),kesi*np.ones(n),'r--')
plt.show()
