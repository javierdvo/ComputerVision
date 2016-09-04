include("mrf_log_prior.jl")

function mrf_grad_log_prior(x, sigma, alpha)

	# Compute the log of an unnormalized pairwise MRF prior
	# for disparity map x using t-distribution potentials with parameters sigma and alpha.
	# You can freely change the name/type/number of parameters of functions.
	# ----- your code here -----
	assistd=zeros(Float64, size(x,1)+2,size(x,2)+2)
	assistn=ones(Float64, size(x,1)+2,size(x,2)+2)
	assistd[2:size(x,1)+1,2:size(x,2)+1]=dx_studentT(x,sigma,alpha)
	assistn[2:size(x,1)+1,2:size(x,2)+1]=studentT(x,sigma,alpha)
	values=zeros(Float64,size(assistd))
	upper=assistd[1:size(assistd,1)-2,2:(size(assistd,2)-1)]./assistn[1:size(assistn,1)-2,2:(size(assistn,2)-1)]
	lower=assistd[3:size(assistd,1),2:(size(assistd,2)-1)]./assistn[3:size(assistn,1),2:(size(assistn,2)-1)]
	left=assistd[2:size(assistd,1)-1,1:(size(assistd,2)-2)]./assistn[2:size(assistn,1)-1,1:(size(assistn,2)-2)]
	right=assistd[2:size(assistd,1)-1,3:(size(assistd,2))]./assistn[2:size(assistn,1)-1,3:(size(assistn,2))]
	values=upper+lower+left+right

	return values;	# return your computed Log-prior here|

end


## studentT ---------------------------------------
function dx_studentT(d, sigma, alpha)

	# Calculates the potential based on Student-t distribution
	# You can freely change the name/type/number of parameters of functions.

	# ----- your code here -----
	val=-alpha*((1+d.^2/(2*sigma^2)).^(-alpha-1)).*(d./sigma^2)
	#val=-alpha.*x ./ (sigma^2 .+ x.^2 ./sigma^2)
	return val;	# return your value here

end
