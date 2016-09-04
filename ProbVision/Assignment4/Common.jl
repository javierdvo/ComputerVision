module Common

using Images
using PyPlot

export
  testgrad,
  rgb2gray,
  im2double,
  imresize


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

function rgb2gray{T<:Integer}(A::Array{T,3})
  r,c,d = size(A)
  if d != 3
    throw(DimensionMismatch("Input array must be of size NxMx3."))
  end
  gray = similar(A,r,c)
  for j = 1:c
    for i = 1:r
      @inbounds gray[i,j] = round(T, 0.299*A[i,j,1] + 0.587*A[i,j,2] + 0.114 *A[i,j,3])
    end
  end
  return gray
end

function im2double{T<:Integer}(A::Array{T})
  return A ./ typemax(T)
end

function imresize{T<:AbstractFloat}(A::Array{T,2}, s::Tuple{Int,Int})
  h,w = size(A)
  res = similar(A,s)
  Ai = InterpGrid(A, BCnearest, InterpLinear)
  for c = 1:s[2]
    for r = 1:s[1]
      y = r*h / s[1]
      x = c*w / s[2]
      res[r,c] = Ai[y,x]
    end
  end
  return res
end

function imresize{T<:AbstractFloat}(A::Array{T,3}, s::Tuple{Int,Int})
  dims = size(A,3)
  res = similar(A, s..., dims)
  for d = 1:dims
    res[:,:,d] = imresize(A[:,:,d], s)
  end
  return res
end

end # module
