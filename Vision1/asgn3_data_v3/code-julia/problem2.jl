using Images
using PyPlot
using Grid
using JLD     # Functions for loading and storing data in the ".jld" format

include("Common1.jl")
#Added due to import errors. "AbstractFloat not Defined"
function cart2hom(points)
  return [points; ones(1,size(points,2))]
end
#Added due to import errors. "AbstractFloat not Defined"
function hom2cart(points)
  res = points[1:end-1,:] ./ points[end,:]
  return res
end
# Load Harris interest points of both images
function loadkeypoints(path::ASCIIString)
  keypoints1=load(path,"keypoints1")
  keypoints2=load(path,"keypoints2")
  @assert size(keypoints1,2) == 2 # Nx2
  @assert size(keypoints2,2) == 2 # Kx2
  return keypoints1::Array{Int64,2}, keypoints2::Array{Int64,2}
end

# compute pairwise squared euclidean distances for given features
function euclideansquaredist(f1::Array{Float64,2},f2::Array{Float64,2})
  D=zeros(size(f1,2),size(f2,2))
  for i=1:size(f1,2)
    for j=1: size(f2,2)
      D[i,j]=sum((f1[:,i].-f2[:,j]).^2)
    end
  end
  @assert size(D) == (size(f1,2),size(f2,2))
  return D::Array{Float64,2}
end

# Find pairs of corresponding interest points based on the distance matrix D.
# p1 is a Nx2 and p2 a Mx2 vector describing the coordinates of the interest
# points in the two images.
# The output should be a min(N,M)x4 vector such that each row holds the coordinates of an
# interest point in p1 and p2.
function findmatches(p1::Array{Int,2},p2::Array{Int,2},D::Array{Float64,2})
  p1=keypoints1
  p2=keypoints2
  pairs=int(zeros(min(size(p1,1),size(p2,1)),4))
  for i=1:min(size(p1,1),size(p2,1))
    pairs[i,1:2]=p1[i,:]
    ix=findmin(D[i,:])[2]
    pairs[i,3:4]=p2[ix,:]
  end
  @assert size(pairs) == (min(size(p1,1),size(p2,1)),4)
  return pairs::Array{Int,2}
end

# Show given matches on top of the images in a single figure, in a single plot.
# Concatenate the images into a single array.
function showmatches(im1::Array{Float32,2},im2::Array{Float32,2},pairs::Array{Int,2})
  im3=hcat(im1, im2)
  figure()
  imshow(im3,"gray",interpolation="none")
  plot(pairs[:,1],pairs[:,2],"xy")
  plot(pairs[:,3].+400,pairs[:,2],"xy")
  axis("off")
  gcf()
  return nothing
end

# Compute the estimated number of iterations for RANSAC
function computeransaciterations(p::Float64,k::Int,z::Float64)
  n=int(ceil((log(1-z))/log(1-p^k)))
  return n::Int
end

# Randomly select k corresponding point pairs
function picksamples(points1::Array{Int,2},points2::Array{Int,2},k::Int)
  x=rand(1:123,k)
  sample1=points1[x,:]
  sample2=points2[x,:]
  @assert size(sample1) == (k,2)
  @assert size(sample2) == (k,2)
  return sample1::Array{Int,2},sample2::Array{Int,2}
end

# Apply conditioning.
# Return the conditioned points and the condition matrix.
function condition(points::Array{Float64,2})
  s=maximum(abs(points))/2
  ty=mean(points[2,:])
  tx=mean(points[1,:])
  T=[1/s 0 -tx/s;:0 1/s -ty/s; 0 0 1]
  U=T*points
  @assert size(U) == size(points)
  @assert size(T) == (3,3)
  return U::Array{Float64,2},T::Array{Float64,2}
end

# Estimate the homography from the given correspondences
function computehomography(points1::Array{Int,2}, points2::Array{Int,2})
  hom1=cart2hom(transpose(points1))
  hom2=cart2hom(transpose(points2))
  U1,T1=condition(hom1)
  U2,T2=condition(hom2)
  A=zeros(8,9)
  for i=1:4
    A[i*2-1,4:6,:]=U1[:,i]
    A[i*2-1,7:9,:]=U1[:,i].*-U2[2,i]
    A[i*2,1:3,:]=-U1[:,i]
    A[i*2,7:9,:]=U1[:,i].*U2[1,i]
  end
  U,S,V=svd(A,thin=false)
  H2=zeros(3,3)
  H2[1,:]=V[1:3,9]
  H2[2,:]=V[4:6,9]
  H2[3,:]=V[7:9,9]
  H=zeros(3,3)
  H=inv(T2)*H2*T1
  @assert size(H) == (3,3)
  return H::Array{Float64,2}
end

# Compute distances for keypoints after transformation with the given homography
function computehomographydistance(H::Array{Float64,2},points1::Array{Int,2},points2::Array{Int,2})
  d2=zeros(size(points1,1),1)
  ph1=cart2hom(transpose(points1))
  ph2=cart2hom(transpose(points2))
  Hx1=hom2cart(H*ph1)
  Hx2=hom2cart(pinv(H)*ph2)
  for i=1:size(points1,1)
  d2[i]=(norm(Hx1[:,i]-transpose(points2[i,:]))^2)+(norm(transpose(points1[i,:])-Hx2[:,i])^2)
  end

  @assert length(d2) == size(points1,1)
  return d2::Array{Float64,2}
end

# Compute the inliers for a given homography distance and threshold
function findinliers(distance::Array{Float64,2},thresh::Float64)
  n=0
  indices=[1 ;1]
    for i=1:length(distance)
    if(sqrt(distance[i,1])<thresh)
      n=n+1
      push!(indices,i)
  end
  end
  shift!(indices)
  shift!(indices)
  return n::Int,indices::Array{Int,1}
end

# RANSAC algorithm
function ransac(pairs::Array{Int,2},thresh::Float64,n::Int)
  distances=zeros(123)
  bestinliers=int(zeros(123))
  maxinliers=0
  bestH=zeros(3,3)
  bestpairs=int(zeros(4,4))
  for i=1:n
    points1,points2=picksamples(pairs[:,1:2],pairs[:,3:4],4)
    H= computehomography(points1, points2)
    distances=computehomographydistance(H,pairs[:,1:2],pairs[:,3:4])
    inliers,index=findinliers(distances,tresh)
    if inliers>maxinliers
      maxinliers=inliers
      bestinliers=index
      bestpairs[:,1:2]=points1
      bestpairs[:,3:4]=points2
      bestH=H
    end
  end
  #
  @assert size(bestinliers,2) == 1
  @assert size(bestpairs) == (4,4)
  @assert size(bestH) == (3,3)
  return bestinliers::Array{Int,1},bestpairs::Array{Int,2},bestH::Array{Float64,2}
end

# Recompute the homography based on all inliers
function refithomography(pairs::Array{Int64,2}, inliers::Array{Int64,1})
  newpairs=zeros(size(inliers,1),4)
  k=1
  for i=1:size(pairs,1)
    if(findfirst(bestinliers,5)!=0)
      newpairs[k,:]=pairs[i,:]
      k=k+1
    end
  end
  bestinliers,bestpairs,H=ransac(newpairs,50.0,72)
  @assert size(H) == (3,3)
  return H::Array{Float64,2}
end

# Show panorama stitch of both images using the given homography.
function showstitch(im1::Array{Float32,2},im2::Array{Float32,2},H::Array{Float64,2})
  sdf=CoordInterpGrid((1:299,1:400),im2,BCreflect,InterpLinear)
  float64(im2)
  sdf=filt(,H)
  figure()
  imshow(sdf,"gray",interpolation="none")
  show()
  return nothing::Void
end
#Added due to import errors. "AbstractFloat not Defined"
function sift(points,im,sigma)
  px = points[:,1]
  py = points[:,2]
  n = length(px)
  res = zeros(128,n)
  d = [0.5 0 -0.5]
  g = gaussian2d(sigma,[25 25])
  smoothed = imfilter(im,g)
  dx = imfilter(smoothed,d)
  dy = imfilter(smoothed,d')
  for i = 1:n
    # get patch
    r1 = [x for x = (py[i]-7):(py[i]+8)]
    r2 = [x for x = (px[i]-7):(px[i]+8)]
    dxp = dx[r1,r2]
    dyp = dy[r1,r2]
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

# Problem 2: Image Stitching

function problem2()
  #SIFT Parameters
  sigma = 1.4              # standard deviation
  # RANSAC Parameters
  ransac_threshold = 50.0   # inlier threshold
  p = 0.5                 # probability that any given correspondence is valid
  k = 4                   # number of samples drawn per iteration
  z = 0.99                # total probability of success after all iterations

  # load images
  im1 = PyPlot.imread("../data-julia/a3p1a.png") # left image
  im2 = PyPlot.imread("../data-julia/a3p1b.png") # right image

  # load keypoints
  cd("C://Users//Javier//Desktop//Vision//asgn3_data_v3//code-julia")

  keypoints1, keypoints2 = loadkeypoints("../data-julia/keypoints.jld")
  load("../data-julia/H.jld")

  # extract SIFT features for the keypoints
  features1 =sift(keypoints1,im1,sigma)
  features2 = sift(keypoints2,im2,sigma)

  # compute squared euclidean distance matirx
  D = euclideansquaredist(features1,features2)

  # find matching pairs
  pairs = findmatches(keypoints1,keypoints2,D)

  # show matches
  showmatches(im1,im2,pairs)
  title("Putative Matching Pairs")
  show()

  # compute number of iterations for the RANSAC algorithm
  niterations = computeransaciterations(p,k,z)

  # apply RANSAC
  bestinliers,bestpairs,bestH = ransac(pairs,ransac_threshold,niterations)

  # show best matches
  showmatches(im1,im2,bestpairs)
  title("Best 4 Matches")
  show()
  # show all inliers
  showmatches(im1,im2,pairs[bestinliers,:])
  title("All Inliers")
  show()
  # stitch images and show the result
  showstitch(im1,im2,bestH)

  # recompute homography with all inliers
  H = refithomography(pairs,bestinliers)
  showstitch(im1,im2,H)

  return
end
