## mrf_log_prior ----------------------------------

function mrf_log_prior(x, sigma, alpha)

	# Compute the log of an unnormalized pairwise MRF prior
	# for disparity map x using t-distribution potentials with parameters sigma and alpha.
	# You can freely change the name/type/number of parameters of functions.

	rows, cols = size(x)

	#compute the disparity differences
	d_vert = x[2:rows,:] - x[1:rows-1,:]
	d_hori = x[:,2:cols] - x[:,1:cols-1]
	#NOTE: how about the points at the margin?

	#compute the probabilities and their logarithm
	vert = log(studentT(d_vert, sigma, alpha))
	hori = log(studentT(d_hori, sigma, alpha))

	#sum it all up (summation due to the logarithm)
	lp = sum(vert) + sum(hori)

	return lp;	# return your computed Log-prior here

end


## studentT ---------------------------------------

function studentT(d, sigma, alpha)

	# Calculates the potential based on Student-t distribution
	# You can freely change the name/type/number of parameters of functions.

	# ----- your code here -----

	val = (1 + d.^2 / (2*sigma^2))

	val = val.^(-alpha)

	return val;	# return your value here

end
