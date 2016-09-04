include("mrf_grad_log_prior.jl")

function applyDisparity(I::Array{Float64,2},d::Array{Float64,2})
	#container for resulting image
  shiftedImg=zeros(size(I))
	#auxiliary array for columns [1 2 3 ... max(cols)]
	#iterate over rows
  for i=1:size(I,1)
		#new column value is [1-disparity[1] 2-disparity(2) ...]
    for j=1:size(I,2)
      if (((j-d[i,j]) > 0) && ((j-d[i,j]) < size(I,2)+1))
        shiftedImg[i,j]=I[i,j-d[i,j]]
      else
        shiftedImg[i,j]=I[i,j]
      end
      end
    end
  return shiftedImg::Array{Float64,2}
end

function mrf_likelihood(d,I0,I1,sigma,alpha)
  I1d=applyDisparity(I1,round(d))
  g=sum(1/(2*sigma^2)*(I0=I1d).^2)
  #g=sum(dx_studentT(I0-I1d,sigma,alpha))
  return g
end
