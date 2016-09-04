using Images
using PyPlot

rgb2gray(im)
include("Common.jl")
cd("C://Users//Javier//Desktop//Vision//asgn3_data_v3//code-julia")


#Added due to import errors. "AbstractFloat not Defined"
function rgb2gray{T<:AbstractFloat}(A::Array{T,3})
  r,c,d = size(A)
  if d != 3
    throw(DimensionMismatch("Input array must be of size NxMx3."))
  end
  gray = similar(A,r,c)
  for j = 1:c
    for i = 1:r
      @inbounds gray[i,j] = 0.299*A[i,j,1] + 0.587*A[i,j,2] + 0.114 *A[i,j,3]
    end
  end
  return gray
end


# Load the rgb image from a2p3.png and convert it to a normalized floating point image.
# Then convert it to a grayscale image.
function loadimage()
  rgb = PyPlot.imread("..\\data-julia\\a2p3.png")
  im=rgb2gray(rgb)
  return im::Array{Float32,2},rgb::Array{Float32,3}
end




# Calculate the structure tensor for the Harris detector.
# Replicate boundaries for filtering.
function computetensor(im::Array{Float32,2},sigma::Float64,fsize::Int)
  flt=gaussian2d(sigma,[fsize fsize])
  im=imfilter(im,flt)

  dx=hcat(im[:,end],im[:,1:end-1])-im
  dy=vcat(im[end,:],im[1:end-1,:])-im



  dx2=hcat(dx[:,end],dx[:,1:end-1])-dx
  dy2=vcat(dy[end,:],dy[1:end-1,:])-dy

  dxdy=hcat(dy[:,end],dy[:,1:end-1])-dy

  flt2=gaussian2d(1.6*sigma,[fsize fsize])
  dx2=imfilter(dx2,flt2)
  dy2=imfilter(dy2,flt2)
  dxdy=imfilter(dxdy,flt2)

  return dx2::Array{Float64,2},dy2::Array{Float64,2},dxdy::Array{Float64,2}
end

# Compute Harris function values from the structure tensor
function computeharris(dx2::Array{Float64,2},dy2::Array{Float64,2},dxdy::Array{Float64,2},sigma::Float64)
  alfa=0.06
  harris=sigma^4*(dx2.*dy2-dxdy.*dxdy)-alfa*sigma^4*(dx2+dy2).^2
  return harris::Array{Float64,2}
end

# Apply non-maximum suppression on the harris function result to extract local maxima
# with a 5x5 window. Allow multiple points with equal values within the same window
# and apply thresholding with the given threshold value.
function nonmaxsupp(harris::Array{Float64,2}, thresh::Float64)
for i=3:size(harris,1)-2
    for j=3:size(harris,2)-2
      matriz=harris[i-2:i+2,j-2:j+2]
      if(harris[i,j]!=findmax(matriz)[1] || harris[i,j]<thresh)
        harris[i,j]=0
      end
    end
  end
  py,px = findn(harris[3:end-2,3:end-2])
  return px::Array{Int,1},py::Array{Int,1}
end


# Problem 1: Harris Detector

function problem1()
  # parameters
  sigma = 2.4
  threshold = 1e-6
  fsize = 25

  # load image as color and grayscale images
  im,rgb = loadimage()

  # calculate structure tensor
  dx2,dy2,dxdy = computetensor(im,sigma,fsize)

  # compute harris function
  harris = computeharris(dx2,dy2,dxdy,sigma)

  # display harris images
  figure()
  imshow(harris,"jet",interpolation="none")
  axis("off")
  title("Harris function values")
  gcf()

  # threshold harris function values
  mask = harris .> threshold
  y,x = findn(mask)
  figure()
  imshow(rgb)
  plot(x,y,"xy")
  axis("off")
  title("Harris Interest Points without Non-maximum Suppression")
  gcf()

  # apply non-maxumum suppression
  x,y = nonmaxsupp(harris,threshold)

  # display points ontop of rgb image
  figure()
  imshow(rgb)
  plot(x,y,"xy")
  axis("off")
  title("Harris Interest Points after non-maximum suppression")
  gcf()

  return
end
