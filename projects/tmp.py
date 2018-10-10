import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn import datasets

# iris = datasets.load_iris()
# X = iris.data[:, 2:4] ##表示我们只取特征空间中的后两个维度
data = pd.read_csv('D:/pydata/datasets/plantiq/广西卷烟厂/m114_m_all.csv')
X = data[['WEIGHT_VALUE','CIRCLE_VALUE','LENGTH_VALUE','PD_VALUE']]
X = np.array(X)
print(X.shape)
#绘制数据分布图
plt.scatter(X[:, 0], X[:, 2], c = "red", marker='o', label='see')
plt.xlabel('petal length')
plt.ylabel('petal width')
plt.legend(loc=2)
plt.show()

estimator = KMeans(n_clusters=2)#构造聚类器
estimator.fit(X)#聚类
label_pred = estimator.labels_ #获取聚类标签
#绘制k-means结果
x0 = X[label_pred == 0]
x1 = X[label_pred == 1]
# x2 = X[label_pred == 2]
plt.scatter(x0[:, 0], x0[:, 2], c = "red", marker='o', label='label0')
plt.scatter(x1[:, 0], x1[:, 2], c = "green", marker='*', label='label1')
# plt.scatter(x2[:, 0], x2[:, 2], c = "blue", marker='+', label='label2')
plt.xlabel('petal length')
plt.ylabel('petal width')
plt.legend(loc=2)
plt.show()

