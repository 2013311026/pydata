#-*- coding: utf-8 -*-    

import matplotlib.pyplot as plt
import pandas as pd


fig, ax=plt.subplots()
y=[]
df = pd.read_csv('/Users/jing/pydata/datasets/plantiq/广西卷烟厂/m114_m.csv')
df = df[:125]['重量']

for i in range(125):
    y.append(df[i])
    ax.cla()
    ax.plot(y, label='test')
    ax.legend()
    plt.pause(0.1)
#其中y是数据的Y值，只要不停地更y的数组内容，就可以0.3S刷新一次


# from matplotlib import pyplot as plt
# from matplotlib import animation
# import numpy as np
# fig, ax = plt.subplots()
# #我们的数据是一个0~2π内的正弦曲线
# x = np.arange(0, 2*np.pi, 0.01)
# line, = ax.plot(x, np.sin(x))

# #接着，构造自定义动画函数animate，用来更新每一帧上各个x对应的y坐标值，参数表示第i帧
# def animate(i):
#     line.set_ydata(np.sin(x + i/10.0))
#     return line,
# #然后，构造开始帧函数init
# def init():
#     line.set_ydata(np.sin(x))
#     return line,
# #接下来，我们调用FuncAnimation函数生成动画。参数说明：
# #fig 进行动画绘制的figure
# #func 自定义动画函数，即传入刚定义的函数animate
# #frames 动画长度，一次循环包含的帧数
# #init_func 自定义开始帧，即传入刚定义的函数init
# #interval 更新频率，以ms计
# #blit 选择更新所有点，还是仅更新产生变化的点。应选择True，但mac用户请选择False，否则无法显示动画

# ani = animation.FuncAnimation(fig=fig,
#                               func=animate,
#                               frames=100,
#                               init_func=init,
#                               interval=100,
#                               blit=True)
# plt.show()


# import matplotlib.pyplot as plt    
# import numpy as np    
# import matplotlib.animation as animation    
    
# pause = False    
# def simData():    
#     t_max = 10.0    
#     dt = 0.05    
#     x = 0.0    
#     t = 0.0    
#     while t < t_max:    
#         if not pause:    
#             x = np.sin(np.pi*t)    
#             t = t + dt    
#         yield t, x    
    
# def onClick(event):    
#     global pause    
#     pause ^= True    
    
# def simPoints(simData):    
#     t, x = simData[0], simData[1]    
#     time_text.set_text(time_template%(t))    
#     line.set_data(t, x)    
#     return line, time_text    
    
# fig = plt.figure()    
# ax = fig.add_subplot(111)    
# line, = ax.plot([], [], 'bo', ms=10) # I'm still not clear on this stucture...    
# ax.set_ylim(-1, 1)    
# ax.set_xlim(0, 10)    
    
# time_template = 'Time = %.1f s'    # prints running simulation time    
# time_text = ax.text(0.05, 0.9, '', transform=ax.transAxes)    
# fig.canvas.mpl_connect('button_press_event', onClick)    
# ani = animation.FuncAnimation(fig, simPoints, simData, blit=False, interval=10,    
#     repeat=True)    
# plt.show()   

