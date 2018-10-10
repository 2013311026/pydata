"""
python实时数据画图
"""


import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


fig, ax = plt.subplots()

df = np.array(pd.read_csv('D:/pydata/projects/d.csv'))[:,1]
y=[]
a = 0
b = 100

for i in range(len(df)):
    y.append(df[i])
    ax.cla()
    ax.plot(y, label='test')
    ax.legend()
    ax.set_xlim(a, b)
    if i > 100:
        a += 1
        b += 1
    plt.pause(0.1)
