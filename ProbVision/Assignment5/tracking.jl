using JLD
using PyPlot
using Images
using Colors
include("Common.jl")
include("draw_rectangle.jl")
include("kalman_filter.jl")
include("find_object_christian.jl")
include("find_object.jl")

images=zeros(243,360,160)
for i=1:160
  images[:,:,i]=Common.rgb2gray(PyPlot.imread(@sprintf("sequence\\%i.png",i)))
end

imagesrgb=zeros(243,360,3,160)
for i=1:160
  imagesrgb[:,:,:,i]=PyPlot.imread(@sprintf("sequence\\%i.png",i))
end

object=PyPlot.imread("ball.png")

# compute the A,W,H,Q parameter

# NOTE: the transposes are tricky; opposite to slides due to data storage
H=[1 0 0 0; 0 1 0 0]#Matrix according to our problem
Q=rand(2,2)/10
W=rand(4,4)/10#Randomized small error. A pain to test though.
A=[1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1] #A matrix
X_esti = kalman_motion(images,object,A,W,H,Q)
# plot the true and the kalman filtered measure-state pairs

for k=1:160
  sss=convert(Image{RGB},draw_rectangle(imagesrgb[:,:,:,k],round(Int,X_esti[1,k])-17,round(Int,X_esti[2,k])-17,round(Int,X_esti[1,k])+17,round(Int,X_esti[2,k])+17))
  save(@sprintf("sequenceannotated2\\%i.png",k),sss)
end

#The results given are good at the beginning, detecting the ball nicely, once the ball flips over and we have a lot of black areas due to the writing
# on the ball then it goes towards a blank area of paper, this could be solved by having two reference photos of the image for example
#Later it can be seen that the tracking is once again recovered and focusing on the ball. We selected a window size of 50 pixels for the SSD area and a good estimate of
#where the ball should be. Do notice that due to this being a bit inefficient in terms of runtime we did not pull off many tests.
