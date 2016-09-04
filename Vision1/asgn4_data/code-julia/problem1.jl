using Images
using PyPlot
using Clustering
using MultivariateStats
cd("C://Users//Javier//Desktop//Vision//asgn4_data//code-julia")
pwd()
include("Common.jl")

# typealiases for arrays of images and features
typealias ImageList Array{Array{Float64,2},1}
typealias FeatureList Array{Array{Float64,2},1}

# type to store the input images and their labels
type Dataset
  images::Array{Array{Float64,2},1}
  labels::Array{Float64,1}
  n::Int
end

# length method for type Dataset
import Base.length
function length(x::Dataset)
  @assert length(x.images) == length(x.labels) == x.n "The length of the dataset is inconsistent."
  return x.n
end

# type to store parameters
type Parameters
  fsize::Int
  sigma::Float64
  threshold::Float64
  boundary::Int
end

# Create input data by separating planes and bikes randomly into two equally sized sets.
function loadimages()
  bikeSize=106
  planeSize=134
  setSize=120
  arrayB=zeros(bikeSize)
  arrayP=zeros(planeSize)
  for i=1:bikeSize
    arrayB[i]=i
  end
  for i=1:planeSize
    arrayP[i]=i
  end
  shuffle(arrayP)
  shuffle(arrayB)

  trainingset=Dataset(Array{Float32} [],Array{Float32}[],0)
  testingset=Dataset(Array{Float32} [],Array{Float32}[],0)
  for i=1:planeSize/2
      if arrayP[i]<=99
        if arrayP[i]<=9
	        name=string("..\\data-julia\\planes\\00",integer(arrayP[i]),".png")
          push!(trainingset.images,PyPlot.imread(name))
          push!(trainingset.labels,0)
          trainingset.n=trainingset.n+1
        else
	        name=string("..\\data-julia\\planes\\0",integer(arrayP[i]),".png")
          push!(trainingset.images,PyPlot.imread(name))
          push!(trainingset.labels,0)
          trainingset.n=trainingset.n+1
        end
      else
        name=string("..\\data-julia\\planes\\",integer(arrayP[i]),".png")
        push!(trainingset.images,PyPlot.imread(name))
        push!(trainingset.labels,0)
        trainingset.n=trainingset.n+1
    end
  end
  for i=1:bikeSize/2
      if arrayB[i]<=99
        if arrayB[i]<=9
	        name=string("..\\data-julia\\bikes\\00",integer(arrayB[i]),".png")
          push!(trainingset.images,PyPlot.imread(name))
          push!(trainingset.labels,1)
          trainingset.n=trainingset.n+1
        else
	        name=string("..\\data-julia\\bikes\\0",integer(arrayB[i]),".png")
          push!(trainingset.images,PyPlot.imread(name))
          push!(trainingset.labels,1)
          trainingset.n=trainingset.n+1
        end
      else
        name=string("..\\data-julia\\bikes\\",integer(arrayB[i]),".png")
        push!(trainingset.images,PyPlot.imread(name))
        push!(trainingset.labels,1)
        trainingset.n=trainingset.n+1
    end
  end
  #test set
  for i=(1+planeSize/2):planeSize
      if arrayP[i]<=99
        if arrayP[i]<=9
	        name=string("..\\data-julia\\planes\\00",integer(arrayP[i]),".png")
          push!(testingset.images,PyPlot.imread(name))
          push!(testingset.labels,0)
          testingset.n=testingset.n+1
        else
	        name=string("..\\data-julia\\planes\\0",integer(arrayP[i]),".png")
          push!(testingset.images,PyPlot.imread(name))
          push!(testingset.labels,0)
          testingset.n=testingset.n+1
        end
      else
        name=string("..\\data-julia\\planes\\",integer(arrayP[i]),".png")
          push!(testingset.images,PyPlot.imread(name))
          push!(testingset.labels,0)
          testingset.n=testingset.n+1
    end
  end
  for i=(1+bikeSize/2):bikeSize
      if arrayB[i]<=99
        if arrayB[i]<=9
	        name=string("..\\data-julia\\bikes\\00",integer(arrayB[i]),".png")
          push!(testingset.images,PyPlot.imread(name))
          push!(testingset.labels,1)
          testingset.n=testingset.n+1
        else
	        name=string("..\\data-julia\\bikes\\0",integer(arrayB[i]),".png")
          push!(testingset.images,PyPlot.imread(name))
          push!(testingset.labels,1)
          testingset.n=testingset.n+1
        end
      else
        name=string("..\\data-julia\\bikes\\",integer(arrayB[i]),".png")
        push!(testingset.images,PyPlot.imread(name))
        push!(testingset.labels,1)
        testingset.n=testingset.n+1
    end
  end
  @assert length(trainingset) == 120
  @assert length(testingset) == 120
  return trainingset::Dataset, testingset::Dataset
end

# Extract features for all images using im2feat for each individual image
function extractfeatures(images::ImageList,params::Parameters)
  features=Array{Float64,2} []
  for i=1:length(images)
      push!(features,im2feat(images[i],params.fsize,params.sigma,params.threshold,params.boundary))
  end
  @assert length(features) == length(images)
  return features::FeatureList
end

# Extract features for a single image by applying Harris detection to find interest points
# and SIFT to compute the features at these points.
function im2feat(im::Array{Float64,2},fsize::Int,sigma::Float64,threshold::Float64,boundary::Int)
  px,py=harris(im,sigma,fsize,threshold)
  i=1
  while i!=length(px)+1
    if(px[i]<10||px[i]>(size(im,2)-10)||py[i]<10||py[i]>(size(im,1)-10))
      deleteat!(px,i)
      deleteat!(py,i)
      i=i-1
    end
    i=i+1
  end
  F=sift(px,py,im,sigma)
  @assert size(F,1) == 128
  return F::Array{Float64,2}
end

# Build a concatenated feature matrix from all given features
function concatenatefeatures(features::FeatureList)
  counter=0
  for i=1:size(features,1)
    counter=counter+size(features[i],2)
  end
  X=zeros(128,counter)
  z=1
  for i=1:size(features,1)
    for j=1:size(features[i],2)
      X[:,z]=features[i][:,j]
      z=z+1
    end
  end
  @assert size(X,1) == 128
  return X::Array{Float64,2}
end

# Build a codebook for a given feature matrix by k-means clustering with K clusters
function computecodebook(X::Array{Float64,2},K::Int)
  codebook=kmeans(X,K).centers
  @assert size(codebook) == (size(X,1),K)
  return codebook::Array{Float64,2}
end

# Compute a histogram over the codebook for all given features
function computehistogram(features::FeatureList,codebook::Array{Float64,2},K::Int)
  H=zeros(120,50)
  for i=1:size(features,1)
    for j=1:size(features[i],2)
      for k=1:K
        H[i,k]=H[i,k]+sum((codebook[:,k].-features[i][:,j]).*(codebook[:,k].-features[i][:,j]))
      end
    end
  end
  H=H'
  H=H./maximum(H)
  @assert size(H) == (K,length(features))
  return H::Array{Float64,2}
end

# Visualize a feature matrix by projection to the first two principal components.
# Points get colored according to class labels y
function visualizefeatures(X::Array{Float64,2}, y)
  vector=computepca(traininghistogram)[3]
  stem(vector)
  show()
  return nothing
end

 function computepca ( data )
   mu = mean (data ,2)
   Xh = data .-mu
   U,s,_ = svd (Xh)
   lambda = s.^2 / size (Xh ,2)
   cumvar = cumsum ( lambda )./ sum ( lambda )
 return U, lambda ,mu , cumvar
 end



function imfilter_ord{T<:AbstractFloat}(A::Array{T,2}, fsize::Int, rank::Int)
  r,c = size(A)
  res = similar(A)
  p = div(fsize,2)
  pad = padarray(A,[p,p],[p,p],"symmetric")
  for j = 1:c
    for i = 1:r
      @inbounds patch = pad[i:i+p+p,j:j+p+p]
      @inbounds res[i,j] = select(patch[:],rank)
    end
  end
  return res
end

function imfilter_ord{T<:AbstractFloat}(A::Array{T,3}, fsize::Int, rank::Int)
  res = similar(A)
  for c = 1:size(A,3)
    res[:,:,c] = imfilter_ord(A[:,:,c],fsize,rank)
  end
  return res
end
function imfilter_max{T<:AbstractFloat}(A::Array{T}, fsize::Int)
  fsize = div(fsize,2)*2+1
  rank = fsize*fsize
  res = imfilter_ord(A,fsize,rank)
  return res
end

function harris(im, sigma, fsize, thresh)
  g = gaussian2d(sigma,[fsize,fsize])
  g2 = gaussian2d(sigma*1.6,[fsize,fsize])
  d = [0.5 0 -0.5]
  smoothed = imfilter(im,g)
  dx = imfilter(smoothed,d)
  dy = imfilter(smoothed,d')
  dxdx = imfilter(dx.^2,g2)
  dydy = imfilter(dy.^2,g2)
  dxdy = imfilter(dx.*dy,g2)
  h_det = dxdx.*dydy - dxdy.^2
  h_trace = dxdx .+ dydy
  h = sigma^4 * (h_det .- 0.06 * sigma^4 * h_trace.^2)
  h_max = imfilter_max(h,3)
  #h_max = padarray(h_max[3:end-2,3:end-2],[2,2],[2,2],"value",Inf)
  mask = (h .>= h_max) & (h .> thresh)
  py,px = findn(mask)
  return  px::Array{Int,1},py::Array{Int,1}
end

function sift(px,py,im,sigma)
  n = length(px)
  res = zeros(128,n)
  d = [0.5 0 -0.5]
  g = gaussian2d(sigma,[25 25])
  smoothed = imfilter(im,g)
  dx = imfilter(smoothed,d)
  dy = imfilter(smoothed,d')
  for i = 1:n
    # get patch
    dxp = dx[py[i]-7:py[i]+8,px[i]-7:px[i]+8]
    dyp = dy[py[i]-7:py[i]+8,px[i]-7:px[i]+8]
    # im2col adaption
    dxc = zeros(16,16)
    dyc = zeros(16,16)
    for c = 1:4
      for r = 1:4
        dxc[:,r+4*(c-1)] = dxp[1+4*(c-1):4*c,1+4*(r-1):4*r][:]
        dyc[:,r+4*(c-1)] = dyp[1+4*(c-1):4*c,1+4*(r-1):4*r][:]
      end
    end
    # compute histogram
    hist8 = zeros(8,16)
    hist8[1,:] = sum(dxc.*(dxc.>0),1) # 0°
    hist8[3,:] = sum(dyc.*(dyc.>0),1) # 90°
    hist8[5,:] = sum(-dxc.*(dxc.<0),1) # 180°
    hist8[7,:] = sum(-dyc.*(dyc.<0),1) # 270°
    idx = dyc .> -dxc
    hist8[2,:] = sum((dyc.*idx .+ dxc.*idx) ./sqrt(2),1) # 45°
    idx = dyc .> dxc
    hist8[4,:] = sum((dyc.*idx .- dxc.*idx) ./sqrt(2),1) # 135°
    idx = dyc .< -dxc
    hist8[6,:] = sum((-dyc.*idx .- dxc.*idx) ./sqrt(2),1) # 225°
    idx = dyc .< dxc
    hist8[8,:] = sum((-dyc.*idx .+ dxc.*idx) ./sqrt(2),1) # 315°
    res[:,i] = hist8[:]
  end
  # normalization
  res = res ./ sqrt(sum(res.^2,1))
  return res
end

# Problem 1: Bag of Words Model: Codebook

function problem1()
  # parameters
  params = Parameters(15,1.4,1e-7,10)
  K = 50

  # load trainging and testing data
  traininginputs,testinginputs = loadimages()

  # extract features from images\

  trainingfeatures = extractfeatures(traininginputs.images,params)
  testingfeatures = extractfeatures(testinginputs.images,params)

  # construct feature matrix from the training features
  X = concatenatefeatures(trainingfeatures)
  # write codebook
  codebook = computecodebook(X,K)

  # compute histogram
  traininghistogram = computehistogram(trainingfeatures,codebook,K)
  testinghistogram = computehistogram(testingfeatures,codebook,K)
  # visualize training features
  visualizefeatures(traininghistogram, traininginputs.labels)
  return
end
