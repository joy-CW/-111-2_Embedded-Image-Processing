import cv2
import numpy as np
import time

kernel1 = cv2.getStructuringElement(cv2.MORPH_RECT, (3,3))

kernel2=np.array([
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1]])

fre = 100000

img = cv2.imread('D:\photo\photo.jfif')

gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)

ret,thresh = cv2.threshold(gray,100,255 ,cv2.THRESH_BINARY)


print("使用avx")
start = time.time()

for i in range(fre):
    img3Avx = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel1)

end = time.time()

time1 = end-start

print('3x3的kernel的時間是',time1,'秒')
start = time.time()

for i in range(fre):
    img9Avx = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel2)

end = time.time()

time1 = end-start

print('9x9的kernel的時間是',time1,'秒')


cv2.setUseOptimized(False)
print("\n關閉avx")

start = time.time()

for i in range(fre):
    img3 = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel1)

end = time.time()

time1 = end-start

print('3x3的kernel的時間是',time1,'秒')
start = time.time()

for i in range(fre):
    img9 = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel2)

end = time.time()

time1=end-start

print('9x9的kernel的時間是',time1,'秒')
cv2.imshow('img',img)
cv2.imshow('img3',img3)
cv2.imshow('img9',img9)
cv2.waitKey()