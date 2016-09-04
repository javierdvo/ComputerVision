module Common

using Images
using PyPlot

export
  rgb2gray,
  im2double

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

end # module
