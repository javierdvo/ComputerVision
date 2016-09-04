include("mrf_grad_log_prior.jl")
include("mrf_grad_log_likelihood.jl")

function mrf_grad_log_posterior(d,I0,I1,sigma,alpha)
  g=mrf_grad_log_prior(d,sigma,alpha)+mrf_grad_log_likelihood(d,I0,I1,sigma,alpha)
  return g
end
