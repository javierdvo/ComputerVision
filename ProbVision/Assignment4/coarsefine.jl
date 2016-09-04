using PyPlot
using Images
include("Common.jl")
include("readFlowFile.jl")
include("flowToColor.jl")

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

# Create a Gaussian filter
function makegaussianfilter(size, sigma)
 if length(size) == 1
 size = [size, size ]
 end
 rx = (size[2] -1) /2
 dx = (-rx:rx)
 ry = (size[1] -1) /2
 dy = -ry:ry
 D = dy .^2 .+ dx .^2
 G = exp(-0.5.* D./ sigma ^2)
 return G./ sum(G)
end


# Downsample an image by a factor of 2
function downsample2(A)
 return A[1:2:end ,1:2:end ]
end

# Upsample an image by a factor of 2
#Shitty upsampling code. Should be a binomial filter but we screwed up that one.
function upsample2(A)
 res = zeros(2*size(A ,1), 2*size(A ,2))
 res[1:2:end, 1:2:end] = A
 filt = [0.25 0.5 0.25; 0.5 1 0.5; 0.25 0.5 0.25] #Average filter
 filtimg=imfilter(res ,filt)
 if size(A,1)%2==1 && size(A,1) !=97#Totally arbitrary condition.Mostly due to it not being a power of 2.
   filtimg=filtimg[1:end-1,:]#Ensures compatibility with the gaussian pyramid (Which eats columns and rows.)
 end
 if size(A,2)%2==1&& size(A,2) !=73
   filtimg=filtimg[:,1:end-1]
 end
 return filtimg
end

# Build a Gaussian pyramid from an image
function makegaussianpyramid(im , nlevels ,fsize , sigma )
 filt = makegaussianfilter(fsize , sigma )
 G = Array(Array{ Float64,2}, nlevels )
 G[1] = im
 for i = 2:nlevels
 G[i] = downsample2(imfilter(G[i-1], filt ,"symmetric"))
 end
 return G
end

# Display a given image pyramid ( Laplacian or Gaussian )
function displaypyramid(P)
 function normalize(A)
 return (A .- minimum(A)) ./(maximum(A) .- minimum(A) )
 end
 im = normalize(P[1])
 for i = 2: length(P)
 im = [im [normalize(P[i]) ; zeros(size(im,1) - size(P[i],1),
size(P[i],2))]]
 end
 figure()
 imshow(im, "gray", interpolation = "none")
 axis("off")
 return gcf()
end

function LucasKanadeOffset(img1,img2,winSize,offx,offy)
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
  #Does the image shifting. Basically computes the index difference and gets the new shifted map. Im sure this is partially wrong
  img2values=copy(img2)
  for k1=1:length(img2)
    indexi=round(Int,k1+round(offy[k1])+size(img2,1)*round(offx[k1]))#Linear index, with a 388* for the x value to shift a column
    if indexi>0 && indexi<length(img2)+1 #Make sure it does not crash
      img2values[indexi]=img2[k1]
    end
  end
  imGradT[(1+offset):rows+offset, (1+offset):cols+offset] = img1 - img2values

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

function problem1()
return
end # parameters
 fsize = [5 5]
 sigma = 1.5
 nlevels = 6
 winSize=15 #Gave a pretty nice value.
 # load image

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
 # create Gaussian pyramid
 G1 = makegaussianpyramid(img1, nlevels ,fsize , sigma )
 size(G1)
 G2 = makegaussianpyramid(img2, nlevels ,fsize , sigma )
 #initializes for t=1
flow = Array(Array{ Float64,3}, nlevels )
flow_intx = Array{Float64,2}
flow_inty = Array{Float64,2}
flow_intx= zeros(13,19)
flow_inty=zeros(13,19)
offset=zeros(winSize,winSize)
#cycles for all the pyramid
 for k=6:-1:1
   flow[k]=LucasKanadeOffset(G1[k],G2[k],winSize,flow_intx,flow_inty)#Does the LK offset method
   flow[k][:,:,1]=flow[k][:,:,1]+flow_intx
   flow[k][:,:,2]=flow[k][:,:,2]+flow_inty#Updates the U_0 flow plus the current obtained flow
   flow_intx=upsample2(flow[k][:,:,1])
   flow_inty=upsample2(flow[k][:,:,2])#Upsamples and scales by two on each dimension. We had a factor of two multiplying it but it gave way worse results.
end


#Everyone should start using the xkcd pyplot settings.
#If you dont know xkcd then here http://xkcd.com Now you have something to waste a lot of your time reading
#Either that or 8-bit Theather (http://www.nuklearpower.com/2001/03/02/episode-001-were-going-where/) are great time wasters.

xkcd(scale=1, length=100, randomness=2)



 # display Gaussian pyramid
 #Plotting stuff last two are reference flows
 flow_gt = readFlowFile("flow10.flo")
 fig, ax = subplots(4,2)
 ax[1,1][:imshow](flowToColor(flow[6]))
 ax[2,1][:imshow](flowToColor(flow[5]))
 ax[1,2][:imshow](flowToColor(flow[4]))
 ax[2,2][:imshow](flowToColor(flow[3]))
 ax[3,1][:imshow](flowToColor(flow[2]))
 ax[3,2][:imshow](flowToColor(flow[1]))
 ax[4,1][:imshow](flowToColor(LucasKanadeOffset(G1[1],G2[1],winSize,zeros(size(flow[1])),zeros(size(flow[1])))))
 ax[4,2][:imshow](flowToColor(flow_gt))
 print("avgEPerror = ",avgEPerror(flow[1],flow_gt))

# return




#end
