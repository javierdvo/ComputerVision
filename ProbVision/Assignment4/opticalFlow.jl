using PyPlot
using Images

function endpoint(u,v,u_gt,v_gt)
    return sum(sqrt((u-u_gt).^2+(v-v_gt).^2))/length(u)
end

function sobelgrad(im)
    sobel=[-1 0 1
        -2 0 2
        -1 0 1]
    return     imfilter(im,sobel),imfilter(im,rotr90(sobel))
end

include("Common.jl")
include("readFlowFile.jl")
include("flowToColor.jl")



im1=Common.rgb2gray(PyPlot.imread("frame10.png")/1.0*255)
im2=Common.rgb2gray(PyPlot.imread("frame11.png")/1.0*255)
wsize=21
offset=round(wsize/2)
gt=readFlowFile("flow10.flo")
v=zeros(size(im1,1),size(im1,2),2)
window=zeros(wsize,wsize)
aux=zeros(Float64,size(im1,1)+wsize-1,size(im1,2)+wsize-1)
aux2=copy(aux)
aux[offset+1:end-offset,offset+1:end-offset]=im1
aux2[offset+1:end-offset,offset+1:end-offset]=im2
for i=1: size(im1,1)
  for j=1: size(im1,2)
    window=aux[i:i+wsize-1,j:j+wsize-1]
    window2=aux2[i:i+wsize-1,j:j+wsize-1]
      im1dx,im1dy=sobelgrad(window)
      #im1dx,im1dy=imgradients(window)
      im1dt=-window+window2
      A=[vec(im1dx) vec(im1dy)]
      b=-vec(im1dt)
      v[i,j,:]=pinv((transpose(A)*A))*transpose(A)*b
    end
  end
PyPlot.imshow(flowToColor(v))
print(endpoint(v[:,:,1],v[:,:,2],gt[:,:,1],gt[:,:,2]))
