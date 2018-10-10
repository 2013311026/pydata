from scipy import stats
import numpy as np
import math
import matplotlib.pyplot as plt
def PCA(NewXtran):
    size = np.shape(NewXtran)
    U,S,V=np.linalg.svd(NewXtran/math.sqrt(size[0]-1))   
    eigVals=S**2
    arraySum=sum(eigVals)  
    tmpSum=0  
    n=0  
    for i in eigVals:
        tmpSum+=i    
        if tmpSum/arraySum<0.85:
            n+=1              
    lamda=eigVals[0:n+1]            
    n_eigVect=V[:,0:n+1]
    f_eigVect=V[:,n+1:size[1]]
    return n,lamda,n_eigVect,f_eigVect

#离线训练
Xtran = np.genfromtxt("d00_te.dat")#导入训练数据
size = np.shape(Xtran)#读取数据尺寸
mean = np.mean(Xtran,axis=0)#平均值
std = np.std(Xtran,axis=0)#方差
NewXtran = np.zeros((size[0],size[1]))#数据标准化
for i in range(size[1]):
    NewXtran[:,i] = (Xtran[:,i]-mean[i])/std[i]
n,lamda,n_eigVect,f_eigVect = PCA(NewXtran)#PCA处理
#计算T2控制线
T2UCL = n*(size[0]-1)*(size[0]+1)*stats.f.ppf(0.95,n,size[0]-n)/(size[0]*(size[0]-n))  
#计算SPE控制线
theta = np.zeros((3,1))
for i in range (3):
    theta[i,0] = sum(lamda**(2*i));
h0 = 1-(2*theta[0,0]*theta[2,0])/(3*theta[1,0]**2)
ca = stats.norm.ppf(0.95)
QUCL = theta[0,0]*(h0*ca*np.sqrt(2*theta[1,0])/theta[0,0]+1+theta[1,0]*h0*(h0-1)/(theta[0,0]**2))**(1/h0)    
#在线检测
Xte = np.genfromtxt("d01_te.dat")#导入测试数据
Sz = np.shape(Xte)#读取测试数据尺寸
Xtest = np.zeros((Sz[0],Sz[1]))#测试数据标准化
for i in range(Sz[1]):
    Xtest[:,i] = (Xte[:,i]-mean[i])/std[i]
n,lamda,n_eigVect,f_eigVect = PCA(Xtest)#PCA处理  
#计算T2统计量
T = np.zeros((Sz[0],1))
for l in range(Sz[0]):
    T[l,0] = np.dot(np.dot(np.dot(np.dot(Xtest[l,:],n_eigVect),np.diag(lamda)),n_eigVect.T), Xtest.T[:,l])
#计算SPE统计量
Q = np.zeros((Sz[0],1))
for s in range(Sz[0]):
    r = np.dot(Xtest[s,:],(np.identity(Sz[1])-np.dot(f_eigVect,f_eigVect.T)))
    Q[s,0] = np.dot(r,r.T)

#绘图
t = np.arange(0,960)
T2A = np.ones((960,1))*T2UCL
QA = np.ones((960,1))*QUCL
plt.plot(t,T)
plt.ylabel('T2')
plt.xlabel('Time (hr)')
plt.title('Fault 1 based on T2')
lineB = plt.plot(t,T2A,'r--')
plt.figure(2)
plt.plot(t,Q)
plt.ylabel('Q')
plt.xlabel('Time (hr)')
plt.title('Fault 1 based on SPE')
lineB = plt.plot(t,QA,'r--')