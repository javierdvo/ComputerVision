## mrf_log_prior ----------------------------------

function mrf_log_prior(x, sigma, alpha)

	# Compute the log of an unnormalized pairwise MRF prior
	# for disparity map x using t-distribution potentials with parameters sigma and alpha.
	# You can freely change the name/type/number of parameters of functions.


	rows, cols = size(x)

#compute the disparity differences
d_vert = [x[2:rows,:] - x[1:rows-1,:]; zeros(1, cols)]
d_hori = [x[:,2:cols] - x[:,1:cols-1] zeros(rows, 1)]

#compute the probabilities and their logarithm
vert = log(studentT(d_vert, sigma, alpha))
hori = log(studentT(d_hori, sigma, alpha))

#sum it all up (summation due to the logarithm)
lp = sum(vert +hori)
	return lp;	# return your computed Log-prior here

end


## studentT ---------------------------------------
function studentT(d, sigma, alpha)

	# Calculates the potential based on Student-t distribution
	# You can freely change the name/type/number of parameters of functions.

	# ----- your code here -----
	val=(1+d.^2/(2*sigma^2)).^(-alpha)

	return val;	# return your value here

end

#Grad log prior function
function mrf_grad_log_prior(d,sigma,alpha)
	rows, cols = size(x)

  right = [x[:,1:cols-1] - x[:,2:cols] zeros(rows, 1)]
  left = [zeros(rows,1) x[:,2:cols] - x[:,1:cols-1]]
  below = [x[1:rows-1,:] - x[2:rows,:] ; zeros(1,cols)]
  above = [zeros(1,cols) ; x[2:rows,:] - x[1:rows-1,:]]

  right = dx_studentT(right,sigma,alpha)./studentT(right,sigma,alpha)
  left = dx_studentT(left,sigma,alpha)./studentT(left,sigma,alpha)
  below = dx_studentT(below,sigma,alpha)./studentT(below,sigma,alpha)
  above = dx_studentT(above,sigma,alpha)./studentT(above,sigma,alpha)

  return right + left + below + above
end

#Same thing as above but for dsigma and dalpha with their respective functions which already take the division into consideration (Damn I'm good at getting WolframAlpha to calculate derivatives)
function mrf_grad_log_prior_loss(d, sigma, alpha)
  rows, cols = size(d)
	s_right = [d[:,1:cols-1] - d[:,2:cols] zeros(rows, 1)]
	s_left = [zeros(rows, 1) d[:,2:cols] - d[:,1:cols-1]]
	s_below = [d[1:rows-1,:] - d[2:rows,:] ; zeros(1, cols)]
	s_above = [zeros(1, cols); d[2:rows,:] - d[1:rows-1,:]]

	#cf. slide 19
	#s_right = ds_studentT(s_right, sigma, alpha)./s_studentT(s_right, sigma, alpha)
	s_right = grad_s_studentT(s_right,sigma,alpha)
	s_left = grad_s_studentT(s_left,sigma,alpha)
	s_below = grad_s_studentT(s_below,sigma,alpha)
	s_above = grad_s_studentT(s_above,sigma,alpha)

	s = s_right + s_left + s_below + s_above

	#a_right = [d[:,1:cols-1] - d[:,2:cols] zeros(rows, 1)]
	a_right = [d[:,1:cols-1] - d[:,2:cols] zeros(rows, 1)]
	a_left = [zeros(rows, 1) d[:,2:cols] - d[:,1:cols-1]]
	a_below = [d[1:rows-1,:] - d[2:rows,:] ; zeros(1, cols)]
	a_above = [zeros(1, cols); d[2:rows,:] - d[1:rows-1,:]]

	#cf. slide 19
	a_right = grad_a_studentT(a_right,sigma,alpha)
	a_left = grad_a_studentT(a_right,sigma,alpha)
	a_below = grad_a_studentT(a_right,sigma,alpha)
	a_above = grad_a_studentT(a_right,sigma,alpha)

	a = a_right + a_left + a_below + a_above

	return s,a;

end


## studentT derivative---------------------------------------
function dx_studentT(d, sigma, alpha)

	val=-alpha*((1+d.^2/(2*sigma^2)).^(-alpha-1)).*(d/sigma^2)

	return val;

end


#deprecated function because I suck at simplifying functions before taking derivates, should still be good.
function ds_studentT(d, s, a)

	val= (2 * a * d .*(d.^2/(2 *s^2)+1).^(-a-1))/s^3+(a*(-a-1) *(d.^3) .*(d.^2/(2 *s^2)+1).^(-a-2))/s^5

	return val;

end
#deprecated function because I suck at simplifying functions before taking derivates, should still be good.
function da_studentT(d, s, a)

	val= (2 *d .*(d^2/(2 *s^2)+1).^(-a) *(a *log(d^.2/(2 *s^2)+1)-1))./(d.^2+2* s^2)

	return val;

end
#Function for the whole dstudent/student derivated wrt sigma.
function grad_s_studentT(d, s, a)

	val=  (8 *d *s *a)./(d.^2+2*s^2).^2

	return val;

end

#Function for the whole dstudent/student derivated wrt alpha.
function grad_a_studentT(d, s, a)


	val=  -2*a*d./(d.^2+2*s^2)

	return val;

end
