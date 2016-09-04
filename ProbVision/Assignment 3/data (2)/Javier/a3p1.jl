using PyPlot
using Images
#using JDL

include("Common.jl")

#cd("C:/Users/Arbeit/OneDrive/Computer Vision/Assignment 3/data/data")

function dx_studentt(x, sigma, alpha)
  return -alpha*x./sigma^2 .*studentt(x,sigma,alpha+1)
end

function studentt(x, sigma, alpha)
  return (1 + x.^2 / (2*sigma^2)).^-alpha
end


function mrf_grad_log_prior(x, sigma, alpha)
  rows, cols = size(x)

  # NOTE: reconsider margin treatment: same as row before!
  right = [x[:,1:cols-1] - x[:,2:cols] zeros(rows, 1)]
  left = [zeros(rows,1) x[:,2:cols] - x[:,1:cols-1]]
  below = [x[1:rows-1,:] - x[2:rows,:] ; zeros(1,cols)]
  above = [zeros(1,cols) ; x[2:rows,:] - x[1:rows-1,:]]

  right = dx_studentt(right,sigma,alpha)./studentt(right,sigma,alpha)
  left = dx_studentt(left,sigma,alpha)./studentt(left,sigma,alpha)
  below = dx_studentt(below,sigma,alpha)./studentt(below,sigma,alpha)
  above = dx_studentt(above,sigma,alpha)./studentt(above,sigma,alpha)

  return right + left + below + above

  return
end

function mrf_log_prior(x, sigma, alpha)

	# Compute the log of an unnormalized pairwise MRF prior
	# for disparity map x using t-distribution potentials with parameters sigma and alpha.
	# You can freely change the name/type/number of parameters of functions.

	#store the size of the image
	rows, cols = size(x)

	#compute the disparity differences
	d_vert = [x[2:rows,:] - x[1:rows-1,:]; zeros(1, cols)]
	d_hori = [x[:,2:cols] - x[:,1:cols-1] zeros(rows, 1)]

	#compute the probabilities and their logarithm
	vert = log(studentt(d_vert, sigma, alpha))
	hori = log(studentt(d_hori, sigma, alpha))

	#sum it all up (summation due to the logarithm)
	lp = sum(vert) + sum(hori)

	return lp;	# return your computed Log-prior here

end

sigma = 10
alpha = 1


img = PyPlot.imread("./images/la.png")
img = convert(Array{Float64}, img)

#----------SUBTASK 1----------
grad = mrf_grad_log_prior(img, sigma, alpha)
figure("Subtask 1")
#NOTE: how to include title


imshow(grad, "gray")
print(Common.testgrad(x->mrf_log_prior(x,sigma,alpha),
      x->mrf_grad_log_prior(x,sigma,alpha), img, [34;27;344]))


#----------SUBTASK 2----------
ran = rand(0:255, size(img))
#imshow(ran, "gray")
gradRan = mrf_grad_log_prior(ran, sigma, alpha)
imshow(gradRan, "gray")

#----------SUBTASK 3----------
cons = ones(size(img))*127
imshow(cons,"gray")


# NOTE: How and where to use testgrad? Is the error yet corrected?

#----------SUBTASK 4----------
# In the first case the mrf-log-prior gradient shows an edge image, i.e. an image
# where only high gradients (= edges) are shown. Rising edges (say from dark to
# bright) have a positive (?) whereas falling edges (from bright to dark)
# have negative gradients. For homogeneous regions (where the intensitiy is
# rather constant) the gradients are zero (or at least close to zero). Hence,
# in the gradient image these homogeneous regions are show in an medium gray
# value (between the maximal positive and the maximal negative gradient).
#
# For the random case the gradient image rather reproduces the randomness of
# the input image. This is due to the fact that pixel intensities and edges
# occur randomly. However, the gradient image is somewhat smoothed compared to
# the input image. That is due to the use of the student t distribution and
# the fact edges occur rather unsystemtatic ???? NOTE: CONTINUE
#
# The constant image does not contain any gradients, hence returns a constant
# image as well. Furthermore, this image does only contain zeros since the
# there is no texture, no edges in the image at all. For homogeneous regions
# gradients are zero; consequently the gradient



# Präambel: testgrad(mrf_log_prior with studentt, mrf_grad_log_prior, img, k + l*width )
grad2 = dx_studentT2(img, sigma, alpha)

idxs = [3, 5]

res = Common.testgrad(x->mrf_log_prior(x,sigma,alpha),
      x->mrf_grad_log_prior(x,sigma,alpha), img, idxs)
#d = testgrad(x->mrflogprior(x, sigma, alpha), x->mrfgradlogprior(x, sigma, alpha), X, idxs)
print(res)
