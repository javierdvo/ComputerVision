using Images
using PyPlot
using JLD

include("Common.jl")


function cart2hom(points)
  return [points; ones(1,size(points,2))]
end

function hom2cart(points)
  res = points[1:end-1,:] ./ points[end,:]
  return res
end

# Compute fundamental matrix from homogenous coordinates
function eightpoint(x1::Array{Float64,2},x2::Array{Float64,2})
  U1,T1=condition(x1)
  U2,T2=condition(x2)
  Fdot=computefundamental(transpose(U1),transpose(U2))
  F=transpose(T2)*Fdot*T1
  @assert size(F) == (3,3)
  return F::Array{Float64,2}
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

# Compute the fundamental matrix for given conditioned points
function computefundamental(p1::Array{Float64,2},p2::Array{Float64,2})
  points=zeros(8,9)
  for i=1:8
  points[1,i]=p1[i,2]*p2[i,1]
  points[2,i]=p1[i,1]*p2[i,1]
  points[3,i]=p2[i,1]
  points[4,i]=p1[i,1]*p2[i,2]
  points[5,i]=p1[i,2]*p2[i,2]
  points[6,i]=p2[i,2]
  points[7,i]=p1[i,1]
  points[8,i]=p1[i,2]
  end
  points[:,9]=1
  U,S,V=svd(points,thin=false)
  H2=zeros(3,3)
  H2[1,:]=V[1:3,9]
  H2[2,:]=V[4:6,9]
  H2[3,:]=V[7:9,9]
  F=enforcerank2(H2)
  @assert size(F) == (3,3)
  return F::Array{Float64,2}
end

# Enforce that the given matrix has rank 2
function enforcerank2(Ft::Array{Float64,2})
  Ftemp=[Ft[1,1] Ft[1,2] Ft[1,3] ; Ft[2,1] Ft[2,2] Ft[2,3] ; Ft[3,1] Ft[3,2] Ft[3,3]]
  U,S,V=svd(Ftemp,thin=false)
  F=zeros(3,3)
  F=U*diagm(S)*V'
  F[3,3]=0

  @assert size(F) == (3,3)
  return F::Array{Float64,2}
end

# Draw epipolar lines through given points on top of an image
function showepipolar(F::Array{Float64,2},points::Array{Float64,2},im::Array{Float32,2})
  phom=cart2hom(transpose(points))
  figure()
  imshow(im,"gray",interpolation="none")
  ep=hom2cart(F'*phom)
  plot(ep[1,:],ep[2,:],"xy")
  axis("off")
  show()
  gcf()
  return nothing
end

# Compute the reprojection error of the fundamental matrix F
function computeresidual(p1::Array{Float64,2},p2::Array{Float64,2},F::Array{Float64,2})

  return residual::Array{Float64,2}
end


# Problem 3: Fundamental Matrix

function problem3()
  # load images and data
  im1 = PyPlot.imread("../data-julia/a3p2a.png")
  im2 = PyPlot.imread("../data-julia/a3p2b.png")

  points1 = load("../data-julia/points.jld", "points1")
  points2 = load("../data-julia/points.jld", "points2")

  # display images and correspondences
  figure()
  subplot(121)
  imshow(im1,"gray",interpolation="none")
  axis("off")
  scatter(points1[:,1],points1[:,2])
  subplot(122)
  imshow(im2,"gray",interpolation="none")
  axis("off")
  scatter(points2[:,1],points2[:,2])
  gcf()

  # compute fundamental matrix with homogenous coordinates
  x1 = cart2hom(points1')
  x2 = cart2hom(points2')
  F = eightpoint(x1,x2)

  # draw epipolar lines
  figure()
  subplot(121)
  showepipolar(F',points2,im1)
  scatter(points1[:,1],points1[:,2])
  subplot(122)
  showepipolar(F,points1,im2)
  scatter(points2[:,1],points2[:,2])
  gcf()

  # check epipolar constraint by computing the reprojection error
  residual = computeresidual(x1, x2, F)
  println("Reprojection Error:")
  println(residual)

  # compute epipoles
  U,_,V = svd(F)
  e1 = V[1:2,3]./V[3,3]
  println("Epipole 1: $(e1)")
  e2 = U[1:2,3]./U[3,3]
  println("Epipole 2: $(e2)")

  return
end
