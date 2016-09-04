using Images
using PyPlot
using JLD
using Base.Test


# Transfrom from Cartesian to homogeneous coordinates
function cart2hom(points::Array{Float64,2})
  points_hom=ones(size(points,1)+1,size(points,2))
  points_hom[1:size(points,1),:]=points
  return points_hom::Array{Float64,2}
end

# Transfrom from homogeneous to Cartesian coordinates
function hom2cart(points::Array{Float64,2})
  z=size(points,1)-1
  points_cart=(z,size(points,2))
  points_cart=points[1:z;:]./points[z+1,:]
  return points_cart::Array{Float64,2}
end

# Translation by v
function gettranslation(v::Array{Float64,1})
  t=ones(size(v,1)+1)
  T=diagm(t)
  T[1:size(v,1),4]=v
  return T::Array{Float64,2}
end

# Rotation of d degrees around x axis
function getxrotation(d::Int)
  d=deg2rad(d)
  rx=ones(4)
  Rx=diagm(rx)
  Rx[2,2]=cos(d)
  Rx[2,3]=-sin(d)
  Rx[3,2]=sin(d)
  Rx[3,3]=cos(d)
  return Rx::Array{Float64,2}
end

# Rotation of d degrees around y axis
function getyrotation(d::Int)
  d=deg2rad(d)
  ry=ones(4)
  Ry=diagm(ry)
  Ry[1,1]=cos(d)
  Ry[1,3]=sin(d)
  Ry[3,1]=-sin(d)
  Ry[3,3]=cos(d)
  return Ry::Array{Float64,2}
end

# Rotation of d degrees around z axis
function getzrotation(d::Int)
  d=deg2rad(d)
  rz=ones(4)
  Rz=diagm(rz)
  Rz[1,1]=cos(d)
  Rz[1,2]=-sin(d)
  Rz[2,1]=sin(d)
  Rz[2,2]=cos(d)
  return Rz::Array{Float64,2}
end

# Central projection matrix
function getprojection(principal::Array{Int,1}, focal::Int)
  vector=[focal, focal, 1.]
  P=zeros(3,4)
  P[:;1:3]=diagm(vector)
  P[1:2,3]=principal
  return P::Array{Float64,2}
end

# Return full projection matrix C and full model transformation matrix M
function getfull(T::Array{Float64,2},Rx::Array{Float64,2},Ry::Array{Float64,2},Rz::Array{Float64,2},V::Array{Float64,2})
  C=V*T*Rx*Ry*Rz
  M=Rx*Ry*Rz*T
  return C::Array{Float64,2},M::Array{Float64,2}
end

function getfullcommutative(T::Array{Float64,2},Rx::Array{Float64,2},Ry::Array{Float64,2},Rz::Array{Float64,2},V::Array{Float64,2})
  C=V*Rx*Rz*Ry*T
  M=Rx*Rz*Ry*T
  return C::Array{Float64,2},M::Array{Float64,2}
end


# Load 2D points
function loadpoints()
  points=load("../data-julia/obj_2d.jld","x")
  return points::Array{Float64,2}
end

# Load z-coordintes
function loadz()
  z=load("../data-julia/zs.jld","Z")
  return z::Array{Float64,2}
end

# Invert just the central projection P of 2d points *P2d* with z-coordinates *z*
function invertprojection(P::Array{Float64,2}, P2d::Array{Float64,2}, z::Array{Float64,2})
  #P3d=pinv(P)*cart2hom(points)
  #P3d[3:4;:]=cart2hom(z)
  P3d=P[:,1:3]\(cart2hom(points).*z)
  return P3d::Array{Float64,2}
end

# Invert just the model transformation of the 3D points *P3d*
function inverttransformation(A::Array{Float64,2}, P3d::Array{Float64,2})
  X=pinv(M)*P3d
  #X=M \ cart2hom ( points )
  return X::Array{Float64,2}
end

# Plot 2D points
function displaypoints2d(points::Array{Float64,2})
  x=vec(points[1;:])
  y=vec(points[2;:])
  PyPlot.plot(x, y)
  return gcf()::Figure
end

# Plot 3D points
function displaypoints3d(points::Array{Float64,2})
  scatter3D(points[1;:],points[2;:],points[3;:],)
  show()
  return gcf()::Figure
end

# Apply full projection matrix *C* to 3D points *X*
function projectpoints(C::Array{Float64,2}, X::Array{Float64,2})
  P2d=hom2cart(C*cart2hom(X))
  return P2d:: Array{Float64,2}
end


#= Problem 2
Projective Transformation =#

function problem2()
  # parameters
  t               = [-27.1; -2.9; -3.2]
  principal_point = [8; -10]
  focal_length    = 8

  # model transformations
  T = gettranslation(t)
  Ry = getyrotation(135)
  Rx = getxrotation(-30)
  Rz = getzrotation(90)
 camera= P*T*Rx*Ry*Rz

  # central projection
  P = getprojection(principal_point,focal_length)

  # full projection and model matrix
  C,M = getfull(T,Rx,Ry,Rz,P)

  points = loadpoints()
  displaypoints2d(points)

  z = loadz()
  Xt = invertprojection(P,points,z)
  Xh = inverttransformation(M,Xt)
  worldpoints = hom2cart(Xh)
  displaypoints3d(worldpoints)

  points2 = projectpoints(C,worldpoints)
  displaypoints2d(points2)
  #No, we don't get the same result as without the z values.
  #They are important because when we go back from the x and y values we don't have the z information.
  #We could have infinite solutions and knowing the z values enables us to know exactly in which spot the objects are
  #This also enables us to reconstructa 3 dimensional model instead of having a flat 2D model
  #Finally this gives us a better visual representation in 2D that shows the angle the picture was taken from. It gives perspective

  Ccom,Mcom = getfullcommutative(T,Rx,Ry,Rz,P)

  points = loadpoints()
  displaypoints2d(points)

  z = loadz()
  Xt = invertprojection(P,points,z)
  Xh = inverttransformation(Mcom,Xt)
  worldpoints = hom2cart(Xh)
  displaypoints3d(worldpoints)

  points2 = projectpoints(Ccom,worldpoints)
  displaypoints2d(points2)

  #When changing the order of the rotation and translation the view position in 3D changes.
  #In 2D we don't see a change because we do the inverse operation on the way back, so the order will be respected.
  @test_approx_eq points points2
  return
end

