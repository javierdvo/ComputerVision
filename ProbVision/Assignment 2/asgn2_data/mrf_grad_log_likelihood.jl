include("mrf_grad_log_prior.jl")

function applyDisparity(I::Array{Float64,2},d::Array{Float64,2})
	#container for resulting image
  shiftedImg=zeros(size(I))
	#auxiliary array for columns [1 2 3 ... max(cols)]
  aux=collect(1:size(I,2))
	#iterate over rows
  for i=1:size(I,1)
		#new column value is [1-disparity[1] 2-disparity(2) ...]
    shiftedImg[i,:]=I[i,aux-reinterpret(Int64,vec(d[i,:]))]
  end
  return shiftedImg::Array{Float64,2}
end

function mrf_grad_log_likelihood(d,I0,I1,sigma,alpha)
  I1d=applyDisparity(I1,trunc(d))
  g=(1/(sigma^2)).*(I0-I1d).*dx_studentT(I1d,sigma,alpha)
  #g=sum(dx_studentT(I0-I1d,sigma,alpha))
  return g
end
