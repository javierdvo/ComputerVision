using PyPlot
using Images
include("Common.jl")
include("flowToColor.jl")
include("readFlowFile.jl")
#include("a4p1.jl")


# load and convert 1st frame
img1 = PyPlot.imread("frame10.png")
img1 = convert(Array{Float64},img1)
img1 = Common.rgb2gray(img1)
imshow(img1,"gray")

# load and convert 2nd frame
img2 = PyPlot.imread("frame11.png")
img2 = convert(Array{Float64},img2)
img2 = Common.rgb2gray(img2)
imshow(img2,"gray")


# computes the lucas-Kanade optical flow approach
function LKAffineOpt(img1,img2,winSize = 21)
  # get the image sizes
  rows, cols = size(img1)

  # compute offset for border padding
  offset = convert(Integer,floor(winSize/2))

  # compute x-y-gradient
  im1Grad = imgradients(img1)

  # store x gradient
  im1Gradx = zeros(rows+winSize, cols+winSize)
  im1Gradx[(1+offset):rows+offset, (1+offset):cols+offset] = im1Grad[1]

  # store y gradient
  im1Grady = zeros(rows+winSize, cols+winSize)
  im1Grady[(1+offset):rows+offset, (1+offset):cols+offset] = im1Grad[2]

  # compute t gradient
  imGradT = zeros(rows+winSize, cols+winSize)
  imGradT[(1+offset):rows+offset, (1+offset):cols+offset] = img1 - img2


  # compute matrix of x indices
  x = ones(winSize, winSize)
  for i = 1:winSize
    x[i,:] = [-offset:offset]
  end

  # compute matrix of y indices
  y = ones(winSize, winSize)
  for i = 1:winSize
    y[:,i] = [-offset:offset]
  end

  # container for flow
  flow = zeros(size(img1)[1], size(img1)[2],2)

  # iterate over all pixels
  for i = (1+offset):rows+offset
    for j = (1+offset):cols+offset

        # get the gradients for current sliding window
        I_x = im1Gradx[i-offset:i+offset, j-offset:j+offset]
        I_y = im1Grady[i-offset:i+offset, j-offset:j+offset]
        I_t = imGradT[i-offset:i+offset, j-offset:j+offset]

        # compute the structure tensor
        struc_tens = [  sum(I_x.^2)       sum(I_x.^2.*x)      sum(I_x.^2.*y)      sum(I_x.*I_y)     sum(I_x.*I_y.*x)    sum(I_x.*I_y.*y)
                        sum(I_x.^2.*x)    sum(I_x.^2.*x^2)    sum(I_x.^2.*x.*y)   sum(I_x.*I_y.*x)  sum(I_x.*I_y.*x^2)  sum(I_x.*I_y.*x.*y)
                        sum(I_x.^2.*y)    sum(I_x.^2.*x.*y)   sum(I_x.^2.*y^2)    sum(I_x.*I_y.*y)  sum(I_x.*I_y.*x.*y) sum(I_x.*I_y.*y^2)
                        sum(I_x.*I_y)     sum(I_x.*I_y.*x)    sum(I_x.*I_y.*y)    sum(I_y.^2)       sum(I_y.^2.*x)      sum(I_y.^2.*y)
                        sum(I_x.*I_y.*x)  sum(I_x.*I_y.*x.^2) sum(I_x.*I_y.*x.*y) sum(I_y.^2.*x)    sum(I_y.^2.*x^2)    sum(I_y.^2.*x.*y)
                        sum(I_x.*I_y.*y)  sum(I_x.*I_y.*x.*y) sum(I_x.*I_y.*y^2)  sum(I_y.^2.*y)    sum(I_y.^2.*x.*y) 	sum(I_y.^2.*y^2)
                        ]

        # invert structure tensor
        inv_struc_tens = pinv(struc_tens)

        # compute optical flow in x and y direction
        a = -inv_struc_tens * -[ sum(I_x.*I_t)
                                  sum(I_x.*I_t.*x)
                                  sum(I_x.*I_t.*y)
                                  sum(I_y.*I_t)
                                  sum(I_y.*I_t.*x)
                                  sum(I_y.*I_t.*y)
                                  ]

        # set the indices
        x = j
        y = i

        # store the values for optical flow
        flow[i-offset,j-offset,1] = a[1]+ a[2]*x + a[3]*y
        flow[i-offset,j-offset,2] = a[4]+ a[5]*x + a[6]*y
    end
  end
  return flow
end


# load the ground truth optical flow
flow_gt = readFlowFile("flow10.flo")
flow_gt_col = flowToColor(flow_gt)

# compute and display affine flow for window size 21
figure()
title("Affine-Flow, window size = 21 and Ground Truth")
fig, ax = subplots(1,2)
flow = LKAffineOpt(img1,img2)
ax[1,1][:imshow](flowToColor(flow))
title("Ground Truth")
ax[2,1][:imshow](flowToColor(flow_gt))

# compute the endpoint error
print("---------EP Error -- Affine Flow-----------")
print("avgEPerror = ",avgEPerror(flow,flow_gt))


# evaluate against different window sizes
print("---------EVALUATE against different window sizes-----------")

#plotting
fig, ax = subplots(3,2)#, sharey = true)

print("\n Window Size & Average EP Error")
winSize = 17
flow = LKAffineOpt(img1,img2,winSize)
print("\n",winSize, " & ", avgEPerror(flow,flow_gt), "\\\\")
imshow(flowToColor(flow))
