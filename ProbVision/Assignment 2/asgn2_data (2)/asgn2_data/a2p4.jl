# COMPUTER VISION 2
# Assignment 2
# Problem 4
# Javier De Velasco Oriol - javo10portero@hotmail.com
# Christian Benz - christian.benz@stud.tu-darmstadt.de


using Images
using PyPlot

include("a2p3.jl")

sigma = 1
alpha = 1

#computes the derivative of the student-t distribution
function dx_studentT(x, sigma, alpha)

  #elegant enough with log(...) or better summation of something??
  #-> no use "trick" on slide 19
  # old = x./sigma^2 * (-alpha) .* studentT(x, sigma, alpha+1)

  grad = -alpha.*x ./ (sigma^2 .+ x.^2 ./sigma^2)

  return grad
end


# cf. slide 18
function mrf_grad_log_prior(d, sigma, alpha)

  rows, cols = size(d)

  #compute the disparity differences
  # zeros appended since they produce a derivative of zero
  d_right = [d[:,1:cols-1] - d[:,2:cols] zeros(rows, 1)]
  d_left = [zeros(rows, 1) d[:,1:cols-1] - d[:,2:cols]]
********  d_below = [d[1:rows-1,:] - d[2:rows,:] ; zeros(1, cols)]
  d_above = [zeros(1, cols); d[1:rows-1,:] - d[2:rows,:]]

  d_right = dx_studentT(d_right, sigma, alpha)
  d_left = dx_studentT(d_left, sigma, alpha)
  d_below = dx_studentT(d_below, sigma, alpha)
  d_above = dx_studentT(d_above, sigma, alpha)

  g = d_right + d_left + d_below + d_above

  return g
end

include("Common.jl")

i0 = PyPlot.imread("i0.ppm")
i0 = convert(Array{Float64}, i0)
i0 = Common.rgb2gray(i0)

i1 = PyPlot.imread("i1.ppm")
i1 = convert(Array{Float64}, i1)
i1 = Common.rgb2gray(i1)

gt = PyPlot.imread("gt.pgm")
gt = convert(Array{Float64}, gt)
gt = gt./16

grad_like = mrf_grad_log_likelihood(gt, i0, i1, sigma, alpha)

grad_post =mrf_grad_log_posterior(gt, i0, i1, sigma, alpha)
