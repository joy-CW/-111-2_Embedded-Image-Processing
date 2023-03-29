import cv2
import matplotlib.pyplot as plt
import numpy as np

img = cv2.imread('D:\photo\photo.jpg')
img1h = [500,550]
img1w = [250,300]
img2h = [500,550]
img2w = [400,450]

img1 = cv2.resize(img[img1h[0]:img1h[1],img1w[0]:img1w[1]],(0,0),fx=5,fy=5)
gray1 = cv2.cvtColor(img1,cv2.COLOR_BGR2GRAY)
img2 = cv2.resize(img[img2h[0]:img2h[1],img2w[0]:img2w[1]],(0,0),fx=5,fy=5)
gray2 = cv2.cvtColor(img2,cv2.COLOR_BGR2GRAY)
a = 0
def lbp_basic(img):
    basic_array = np.zeros(img.shape,np.uint8)
    total = 0
    x = a
    for i in range(basic_array.shape[0]-1):
        for j in range(basic_array.shape[1]-1):
            basic_array[i,j] = bin_to_decimal(cal_basic_lbp(img,i,j))
            total += basic_array[i,j]
    x += 1
    if(x<3):
        ave = total / (basic_array.shape[0] * basic_array.shape[1])
        return basic_array, ave
    else:
        return basic_array
def cal_basic_lbp(img,i,j):
    sum = []
    if img[i-1,j] > img[i,j]:
        sum.append(1)
    else:
        sum.append(0)
    if img[i-1,j+1] > img[i,j]:
        sum.append(1)
    else:
        sum.append(0)
    if img[i,j+1] > img[i,j]:
        sum.append(1)
    else:
        sum.append(0)
    if img[i+1,j+1] > img[i,j]:
        sum.append(1)
    else:
        sum.append(0)
    if img[i+1,j] > img[i,j]:
        sum.append(1)
    else:
        sum.append(0)
    if img[i+1,j-1] > img[i,j]:
        sum.append(1)
    else:
        sum.append(0)
    if img[i,j-1] > img[i,j]:
        sum.append(1)
    else:
        sum.append(0)
    if img[i-1,j-1] > img[i,j]:
        sum.append(1)
    else:
        sum.append(0)
    return sum
def bin_to_decimal(bin):
    res = 0
    bit_num = 0
    for i in bin[::-1]:
        res += i << bit_num
        bit_num += 1
    return res
def show_basic_hist(a):
    hist = cv2.calcHist([a],[0],None,[256],[0,256])
    plt.figure(figsize = (8,4))
    plt.plot(hist,color = 'r')
    plt.xlim([0,256])
    plt.show()
gray1 = cv2.cvtColor(img1,cv2.COLOR_BGR2GRAY)
gray2 = cv2.cvtColor(img2,cv2.COLOR_BGR2GRAY)
basic_array1,ave1 = lbp_basic(gray1)
a += 1
basic_array2,ave2 = lbp_basic(gray2)
a += 1
show_basic_hist(basic_array1)
show_basic_hist(basic_array2)

plt.imshow(gray1)

plt.imshow(gray2)

gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
basic_array = lbp_basic(gray)

print("img1平均值：" + str(ave1))
print("img2平均值：" + str(ave2))
if(ave1 - ave2 >= 10 or ave2 - ave1 >= 10):
    print("兩區域不相似")
else:
    print("兩區域相似")

cv2.rectangle(img,(img1w[0],img1h[0]),(img1w[1],img1h[1]),(0,255,0),1)
cv2.rectangle(img,(img2w[0],img2h[0]),(img2w[1],img2h[1]),(0,255,0),1)
cv2.imshow('basic_array',basic_array)
cv2.imshow('img',img)
cv2.imshow('gray1',gray1)
cv2.imshow('gray2',gray2)
cv2.waitKey(0)