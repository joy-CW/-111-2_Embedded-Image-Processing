import cv2
import numpy as np

img = cv2.imread('D:\photo\photo1.jpg')
img = cv2.resize(img,(0,0),fx=0.5,fy=0.5)

gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
ret, thresh = cv2.threshold(gray,0,255,cv2.THRESH_BINARY_INV+cv2.THRESH_OTSU)

# 噪声去除
kernel = np.ones((3,3),np.uint8)
opening = cv2.morphologyEx(thresh,cv2.MORPH_OPEN,kernel, iterations = 2)
# 确定背景区域
sure_bg = cv2.dilate(opening,kernel,iterations=3)
# 寻找前景区域
dist_transform = cv2.distanceTransform(opening,cv2.DIST_L2,5)
ret, sure_fg = cv2.threshold(dist_transform,0,255,0)
# 找到未知区域
sure_fg = np.uint8(sure_fg)
unknown = cv2.subtract(sure_bg,sure_fg)

# 类别标记
ret, markers = cv2.connectedComponents(sure_fg)
# 为所有的标记加1，保证背景是0而不是1
markers = markers+1
# 现在让所有的未知区域为0
markers[unknown==255] = 0
markers = cv2.watershed(img,markers)
img[markers > 1] = [0,255,0]

cv2.imshow('img',img)
cv2.waitKey(0)