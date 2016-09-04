
include("a3p2.jl")
include("Common.jl")

function J(theta)
  return L(x_gt, f(y))
end

function f(x,theta)
  sigma,alpha = theta
  return x + eta * posterior(x,y,sigma,alpha)
end

function loss(x_gt,x)
  return -psnr(x_gt,x)
end

function grad_loss(x_gt,x)
  #return 20 ./ ((x_gt - x) * log(10))
  return 10*log10(2*sum(x_gt-x))
end

function dalpha_studentt(x,sigma,alpha)
  return -(1+x.^2 / (2*sigma^2)).^(-alpha) .* log(1 + x.^2 / (2* sigma^2))
end

function dsigma_studentt(x,sigma,alpha)
  return -(x.^2) ./ sigma^3 .* -alpha .* (1 + x.^2 ./ (2*sigma^2)).^(-alpha-1)
end

function grad_log_prior(derivative,x, sigma, alpha)
  rows, cols = size(x)

  # NOTE: reconsider margin treatment: same as row before!
  right = [x[:,1:cols-1] - x[:,2:cols] zeros(rows, 1)]
  left = [zeros(rows,1) x[:,2:cols] - x[:,1:cols-1]]
  below = [x[1:rows-1,:] - x[2:rows,:] ; zeros(1,cols)]
  above = [zeros(1,cols) ; x[2:rows,:] - x[1:rows-1,:]]

  right = derivative(right,sigma,alpha)./studentt(right,sigma,alpha)
  left = derivative(left,sigma,alpha)./studentt(left,sigma,alpha)
  below = derivative(below,sigma,alpha)./studentt(below,sigma,alpha)
  above = derivative(above,sigma,alpha)./studentt(above,sigma,alpha)

  return right + left + below + above

  return
end

function prediction(x,y,sigmaN,sigma,alpha)
  # f
  eta = 1
  f =  x + eta * denoising_grad_lposterior(x,y,sigmaN,sigma,alpha)

  # sigma NOTE: not so sure whether to use x or y
  dsigma = eta * grad_log_prior(dsigma_studentt,x, sigma,alpha)

  # alpha
  dalpha = eta * grad_log_prior(dalpha_studentt,x, sigma,alpha)

  return f, dsigma, dalpha
end


function learning_objective(x_gt,x,y,sigmaN,sigma,alpha)

  f,dsigma,dalpha = prediction(x,y,sigmaN,sigma,alpha)

  J = loss(x_gt, f)

  dsigma = grad_loss(x_gt,x+dsigma)
  dalpha = grad_loss(x_gt,x+dalpha)

  g = [dsigma,dalpha]

  return J, g
end


img = PyPlot.imread("./images/la.png")
img = 255*convert(Array{Float64}, img)
imgNoisy = PyPlot.imread("./images/la-noisy.png")
imgNoisy = 255*convert(Array{Float64},imgNoisy)
print(Common.testgrad(x->loss(img,x), x->grad_loss(img,x), imgNoisy, [50:80]))


using Optim


function learn(x::Vector)
  return learning_objective(img,imgNoisy,imgNoisy,sigmaN,x[1],x[2])[1]
end

function gradi(x::Vector,storage::Vector)
  J,dsigma,dalpha = learning_objective(img,imgNoisy,imgNoisy,sigmaN,x[1],x[2])[1]
  storage[1] = dsigma
  storage[2] = dalpha
end

optimize(learn,gradi,[10,1])
