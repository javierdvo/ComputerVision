using PyPlot
using Images
include("Common.jl")
include("flowToColor.jl")
include("readFlowFile.jl")
#include("a4p1.jl")



xkcd(scale=1, length=100, randomness=2)

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


 # container for flow
    flow   = zeros(rows+winSize, cols+winSize,2)
 # iterate over all pixels
    for i = (1+offset):rows+offset#rows+offset
        for j = (1+offset):cols+offset#cols+offset

 # get the gradients for current sliding window
          I_x = im1Gradx[i-offset:i+offset, j-offset:j+offset]
          I_y = im1Grady[i-offset:i+offset, j-offset:j+offset]
          I_t = imGradT[i-offset:i+offset, j-offset:j+offset]

          tmp = [1:winSize^2;]
          tmp = tmp-median(tmp)
          tmp = reshape(tmp,(winSize,winSize))


          x = ones(winSize, winSize)
        #  for k = 1:winSize
        #    x[k,:] = [-offset:offset;]/10
        #  end


          y = ones(winSize, winSize)
          #for k = 1:winSize
        #    y[:,k] = [-offset:offset;]/10
        #  end
 #x = j*ones(offset*2+1,offset*2+1)
 #y = i*ones(offset*2+1,offset*2+1)

 # compute the structure tensor
# struc_tens = [ sum(I_x.^2) sum(I_x.^2.*x)
#sum(I_x.^2.*y) sum(I_x.*I_y) sum(I_x.*I_y.*x) sum(I_x.*I_y.*y)
# sum(I_x.^2.*x) sum(I_x.^2.*x^2)
#sum(I_x.^2.*x.*y) sum(I_x.*I_y.*x) sum(I_x.*I_y.*x^2) sum(I_x.*I_y.*x.*y)
# sum(I_x.^2.*y) sum(I_x.^2.*x.*y)
#sum(I_x.^2.*y^2) sum(I_x.*I_y.*y) sum(I_x.*I_y.*x.*y) sum(I_x.*I_y.*y^2)
# sum(I_x.*I_y) sum(I_x.*I_y.*x)
#sum(I_x.*I_y.*y) sum(I_y.^2) sum(I_y.^2.*x) sum(I_y.^2.*y)
# sum(I_x.*I_y.*x) sum(I_x.*I_y.*x.^2)
#sum(I_x.*I_y.*x.*y) sum(I_y.^2.*x) sum(I_y.^2.*x^2) sum(I_y.^2.*x.*y)
# sum(I_x.*I_y.*y) sum(I_x.*I_y.*x.*y)
#sum(I_x.*I_y.*y^2) sum(I_y.^2.*y) sum(I_y.^2.*x.*y) sum(I_y.^2.*y^2)
# ]
struc_tens=[sum(I_x.^2) sum(I_x.^2 .*x) sum(I_x.^2 .*y) sum(I_x.*I_y) sum(I_x.*I_y.*x) sum(I_x.*I_y.*y);
sum(I_x.^2 .*x) sum(I_x.^2 .*x.^2) sum(I_x.^2 .*y.*x) sum(I_x.*I_y.*x) sum(I_x.*I_y.*x.^2) sum(I_x.*I_y.*y.*x);
sum(I_x.^2 .*y) sum(I_x.^2 .*x.*y) sum(I_x.^2 .*y.^2) sum(I_x.*I_y.*y) sum(I_x.*I_y.*x.*y) sum(I_x.*I_y.*y.^2);
sum(I_x.*I_y) sum(I_x.*I_y.*x) sum(I_x.*I_y.*y) sum(I_y.^2) sum(I_y.^2 .*x) sum(I_y.^2 .*y);
sum(I_x.*I_y.*x) sum(I_x.*I_y.*x.^2) sum(I_x.*I_y.*y.*x) sum(I_y.^2 .*x) sum(I_y.^2 .*x.^2) sum(I_y.^2 .*y.*x);
sum(I_x.*I_y.*y) sum(I_x.*I_y.*x.*y) sum(I_x.*I_y.*y.^2) sum(I_y.^2 .*y) sum(I_y.^2 .*x.*y) sum(I_y.^2 .*y.^2)
    ]

 # invert structure tensor
          inv_struc_tens = pinv(struc_tens)

 # compute optical flow in x and y direction
          alphas = -inv_struc_tens * -[ sum(I_x.*I_t)
          sum(I_x.*I_t.*x)
          sum(I_x.*I_t.*y)
          sum(I_y.*I_t)
          sum(I_y.*I_t.*x)
          sum(I_y.*I_t.*y)
          ]
          u=alphas[1]+alphas[2].*x+alphas[3].*y
          v=alphas[4]+alphas[5].*x+alphas[6].*y
 # store the values f1or optical flow

          flow[i-offset:i+offset,j-offset:j+offset,1] = flow[i-offset:i+offset,j-offset:j+offset,1] +u
          flow[i-offset:i+offset,j-offset:j+offset,2] = flow[i-offset:i+offset,j-offset:j+offset,2]+ v
        end
      end
 return flow[(1+offset):rows+offset, (1+offset):cols+offset,:]
end





# computes the average endpoint error
function avgEPerror(flow, flow_gt)
 # get the flow components
 u_gt = flow_gt[:,:,1]
 v_gt = flow_gt[:,:,2]

 # the value 1.666666752e9 denotes invalid ground truth values
 mask_u = u_gt .!= 1.666666752e9
 mask_v = v_gt .!= 1.666666752e9

 # mask eliminates all invalid ground truths values (resulting e.g.from occludions)
 u = flow[:,:,1] .* mask_u
 v = flow[:,:,2] .* mask_v
 u_gt = u_gt .* mask_u
 v_gt = v_gt .* mask_v

 # computes the sum of squared differences
 SSD = (u-u_gt).^2 + (v-v_gt).^2

 # takes square root and averages
 avgErr = mean(sqrt(SSD))

 return avgErr
end



flow_gt = readFlowFile("flow10.flo")
flow_gt_col = flowToColor(flow_gt)
imshow(flow_gt_col[1:10, 60:70])

figure()
title("Lucas-Kanade, window size = 21 and Ground Truth")
fig, ax = subplots(1,2)
flow = LKAffineOpt(img1,img2)
imshow(flowToColor(flow))
title("WinSize = 21")
ax[1,1][:imshow](flowToColor(flow))
title("Ground Truth")
ax[2,1][:imshow](flowToColor(flow_gt))

print("avgEPerror = ",avgEPerror(flow,flow_gt))



#print("---------EVALUATE with 5 different values-----------")

#plottingg
#fig, ax = subplots(4,2)#, sharey = true)

#print("\n Window Size & Average EP Error")
#wSize=[1;5;9;13;17;21;25;29]#;33]
#for i = 1:4
# for j = 1:2
# flow = LKAffineOpt(img1,img2,wSize[(i-1)*2+j])
# print("\n",wSize[(i-1)*2+j], " & ", avgEPerror(flow,flow_gt), "\\\\")
# # plot
# ax[i,j][:imshow](flowToColor(flow))
# end
#end
