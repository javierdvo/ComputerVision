using PyPlot
using Images
#using JDL

include("Common.jl")
include("a3p1.jl")

sigmaN = 15
sigma = 10
alpha = 1


function denoising_llh(x, y, sigmaN)
  return sum(-1/(2*sigmaN^2) .* (x-y).^2)
end


function denoising_grad_llh(x, y, sigmaN)
  return -1/sigmaN^2 .* (x-y)
end


# sanity check for derivative
img = PyPlot.imread("./images/la.png")
img = 255*convert(Array{Float64}, img)
imgNoisy = PyPlot.imread("./images/la-noisy.png")
imgNoisy = 255*convert(Array{Float64}, imgNoisy)
y = imgNoisy
res = Common.testgrad(x->denoising_llh(x, y, sigmaN), x->denoising_grad_llh(x, y, sigmaN), img, [100;230;573;293])
print(res)
# RESULT: [0.0003834422756037961,0.000627450943486405,0.00024400869970502134,0.000766884552595371]
# is approved from my point of view

function denoising_grad_lposterior(x,y,sigmaN, sigma, alpha)
  grad = denoising_grad_llh(x, y, sigmaN) + mrf_grad_log_prior(x,sigma,alpha)
  return grad
end

function denoising_lposterior(x,y,sigmaN, sigma, alpha)
  val = denoising_llh(x, y, sigmaN) + mrf_log_prior(x,sigma,alpha)
  return val
end

#sanity check derivative posterior
res = Common.testgrad(x->denoising_lposterior(x,y,sigmaN,sigma,alpha), x->denoising_grad_lposterior(x,y,sigmaN,sigma,alpha), img, [100;230;573;293])
print(res)



function gradientascent(x, sigmaN, sigma, alpha)
  eta = 0.1
  iters = 1000

  x_fix = copy(x)
  # initialize
  x_next = x

  for i = 1:iters
    if i%10 == 0
      println(i, ". Log-Likelihood: NEXT = ", denoising_lposterior(x_next,x_fix,sigmaN,sigma,alpha),
        "  delta = ", abs(denoising_lposterior(x_next,x_fix,sigmaN,sigma,alpha) - denoising_lposterior(x,x_fix,sigmaN,sigma,alpha)))
    end
    x = x_next
    x_next = x + eta * denoising_grad_lposterior(x,x_fix,sigmaN,sigma,alpha)
  end

  # return the best x
  return x_next
end

test = gradientascent(imgNoisy,sigmaN,sigma,alpha)
imshow(test, "gray")


using Distributions
# input image in the range of [0;1]! * 15
function addNoise(x, sigmaNoise)
  # randn is useless since you cannot change the sigma value
  # randn(size(x))
  # use distributions package
  dist = Normal(0,sigmaNoise)
  x_noisy = x*255 + rand(dist, size(x))
  return x_noisy/255
end

# NOTE: alpha and sigma are definitely related: alpha/2 = sigma*2? CHECK THIS

# sigma
# 10 blurry
# 5 much more blurry
# 15 less blurry more noise

# alpha
# 1
# 2 very blurry
# 0.5 not so blurry but more noise
# negative useless

# peak signal to noise ratio
# the better the higher
function psnr(x_gt, x)
  # maximal value of ground truth
  v_max = extrema(x_gt)[2]
  # mean squared error
  MSE = sum((x - x_gt).^2) / prod(size(x))

  psnr = 10 * log10( v_max^2 / MSE )
  return psnr
end
