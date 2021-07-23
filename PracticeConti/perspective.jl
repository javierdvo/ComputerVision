using LinearAlgebra

p=[10,20,30,1] #World Point
a=pi/2 # 90 deg. Z axis rotation
W_C=[cos(a) -sin(a) 0 2;sin(a) cos(a) 0 3;0 0 0 4;0 0 0 1] #rotation + 2,3,4 translation

p_x=512 #center Pixel in X
p_y=512 #center Pixel in Y
f=0.05 #focal length
pixel_size=2E-3
persp_matrix=[1 0 0 0; 0 1 0 0; 0 0 0 1] #  parallel projection
cal_matrix=[f 0 p_x; 0 f p_y; 0 0 1] #camera calibration matrix
cal_matrix=[pixel_size 0 0; 0 pixel_size 0; 0 0 1]*cal_matrix
p2d=cal_matrix*persp_matrix*W_C*p #2D Point
