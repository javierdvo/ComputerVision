using PyPlot
using Images
include("Common.jl")
include("flowToColor.jl")
include("readFlowFile.jl")

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
function LucasKanade(img1,img2,winSize = 21)
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
  flow = zeros(size(img1)[1], size(img1)[2],2)

  # iterate over all pixels
  for i = (1+offset):rows+offset
    for j = (1+offset):cols+offset

        # get the gradients for current sliding window
        I_x = im1Gradx[i-offset:i+offset, j-offset:j+offset]
        I_y = im1Grady[i-offset:i+offset, j-offset:j+offset]
        I_t = imGradT[i-offset:i+offset, j-offset:j+offset]

        # compute the structure tensor
        struc_tens = [  sum(I_x.^2) sum(I_x.*I_y)
                        sum(I_x.*I_y) sum(I_y.^2)]

        # invert structure tensor
        inv_struc_tens = pinv(struc_tens)

        # compute optical flow in x and y direction
        u,v = -inv_struc_tens * -[sum(I_x.*I_t) ; sum(I_y.*I_t)]

        # store the values for optical flow
        flow[i-offset,j-offset,1] = u
        flow[i-offset,j-offset,2] = v
    end
  end
  return flow
end

# TODO: ONE element too much!!!
# computes the average endpoint error
function avgEPerror(flow, flow_gt)
  # get the flow components
  u_gt = flow_gt[:,:,1]
  v_gt = flow_gt[:,:,2]

  # the value 1.666666752e9 denotes invalid ground truth values
  mask_u = u_gt .!= 1.666666752e9
  mask_v = v_gt .!= 1.666666752e9

  # mask eliminates all invalid ground truths values (resulting e.g. from occludions)
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

# figure()
title("Lucas-Kanade, window size = 21 and Ground Truth")
fig, ax = subplots(1,2)
flow = LucasKanade(img1,img2)
ax[1,1][:imshow](flowToColor(flow))
ax[2,1][:imshow](flowToColor(flow_gt))
print("avgEPerror = ",avgEPerror(flow,flow_gt))



print("EVALUATE with 5 different values")

#plottingg
fig, ax = subplots(4,2)#, sharey = true)

#ax[1,1][:imshow](x)
#ax[2,1][:imshow](y,"gray")
#ax[3,1][:imshow](xnew,"gray")
#ax[4,1][:imshow](xnew-y,"gray")

#print("\n Window Size & Average EP Error")
#wSize=[1;5;9;13;17;21;25;29]#;33]
#for i = 1:4
#   for j = 1:2#
#      flow = LucasKanade(img1,img2,wSize[(i-1)*2+j])
#      print("\n",wSize[(i-1)*2+j], " & ", avgEPerror(flow,flow_gt), "\\\\")
#      ax[i,j][:imshow](flowToColor(flow))
#    end
#end
