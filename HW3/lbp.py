import cv2
import numpy as np
size = 30

img = cv2.imread('D:\photo\photohw3.jpg')
img = cv2.resize(img,(0,0),fx=0.5,fy=0.5)
img1h = [500,500+size]
img1w = [250,250+size]
img2h = [0,size]
img2w = [0,size]

img1 = cv2.resize(img[img1h[0]:img1h[1],img1w[0]:img1w[1]],(0,0),fx=1,fy=1)
def lbp_basic(img):
    basic_array = np.zeros(img.shape,np.uint8)
    total = 0
    for i in range(basic_array.shape[0]-1):
        for j in range(basic_array.shape[1]-1):
            basic_array[i,j] = bin_to_decimal(cal_basic_lbp(img,i,j))
            total += basic_array[i,j]
    ave = total / (basic_array.shape[0] * basic_array.shape[1])
    return basic_array, ave
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
def hsv_ave(hsv):
    hsv_value = np.array(hsv,np.uint32)
    hsv_total = 0
    for i in range(0,hsv.shape[0]-1):
        for j in range(0,hsv.shape[1]-1):
            hsv_total += hsv_value[i,j]
    ave = hsv_total/(hsv.shape[0] * hsv.shape[1])
    return ave

gray1 = cv2.cvtColor(img1,cv2.COLOR_BGR2GRAY)
hsv1 = cv2.cvtColor(img1,cv2.COLOR_BGR2HSV)
basic_array1,ave1 = lbp_basic(gray1)
for i in range(0,img.shape[0] - size):
    for j in range(0,img.shape[1] - size):
        img2h[0] = 600 - (i + size)
        img2h[1] = 600 - i
        img2w[0] = j
        img2w[1] = j + size
        img2 = cv2.resize(img[img2h[0]:img2h[1], img2w[0]:img2w[1]], (0, 0), fx=1, fy=1)
        gray2 = cv2.cvtColor(img2,cv2.COLOR_BGR2GRAY)
        hsv2 = cv2.cvtColor(img2, cv2.COLOR_BGR2HSV)
        basic_array2,ave2 = lbp_basic(gray2)
        if (ave1 - ave2 >= 10 or ave2 - ave1 >= 10)or((hsv_ave(hsv1)[0] - hsv_ave(hsv2)[0] >= 10 or hsv_ave(hsv2)[0] - hsv_ave(hsv1)[0] >= 10)or(hsv_ave(hsv1)[1] - hsv_ave(hsv2)[1] >= 50 or hsv_ave(hsv2)[1] - hsv_ave(hsv1)[1] >= 50)or(hsv_ave(hsv1)[2] - hsv_ave(hsv2)[2] >= 50 or hsv_ave(hsv2)[2] - hsv_ave(hsv1)[2] >= 50)):
            pass
        else:
            # img1 = cv2.resize(img2, (0, 0), fx=1, fy=1)
            cv2.rectangle(img, (img2w[0], img2h[0]), (img2w[1], img2h[1]), (0, 255, 0), cv2.FILLED)

cv2.imshow('img',img)
cv2.waitKey(0)