
include("Common.jl")

#reused from a1p4.jl
function applyDisparity(I::Array{Float64,2},d::Array{Float64,2})
	#container for resulting image
  shiftedImg=zeros(size(I))
	#auxiliary array for columns [1 2 3 ... max(cols)]
  aux=[1:size(I,2)]
	#iterate over rows
  for i=1:size(I,1)
		#new column value is [1-disparity[1] 2-disparity(2) ...]
    shiftedImg[i,:]=I[i,aux-vec(d[i,:])]
  end
  return shiftedImg::Array{Float64,2}
end

function mrf_grad_log_likelihood(d, I0, I1, sigma, alpha)

  I0 = Common.rgb2gray(I0)
  I1 = Common.rgb2gray(I1)

  I1d = applyDisparity(I1, d)
  Id = I0 - I1d

  #left of sum(...)
  g = (dx_studentT(Id, sigma, alpha))

  return g
end
