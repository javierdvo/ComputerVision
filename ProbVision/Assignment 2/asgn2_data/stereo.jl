include("mrf_grad_log_prior.jl")
include("mrf_grad_log_likelihood.jl")
include("mrf_grad_log_posterior.jl")
include("mrf_likelihood.jl")
using Optim
using Debug
 function funct(d)
  y=mrf_likelihood(d,I0,I1,sigma,alpha)*mrf_log_prior(d,sigma,alpha)
  return y
end

function g!(d,storage)
  storage[:,:,1]=mrf_grad_log_posterior(d,I0,I1,sigma,alpha)
end


function stereo(I0,I1,sigma,alpha)
  d=PyPlot.imread("gt.pgm")/16
  d=zeros(Float64,size(I0))
  #f=mrf_grad_log_posterior(d,I0,I1,sigma,alpha)
  res=optimize(funct,g!,d,method = GradientDescent(),
               grtol = 1e-3,
               iterations = 5,
               store_trace = true,
               show_trace = true)
  return d
end
