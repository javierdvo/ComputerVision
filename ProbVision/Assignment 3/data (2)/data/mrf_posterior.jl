include("mrf_prior.jl")
include("mrf_likelihood.jl")
#Posterior and gradient of log posterior. Self explanatory.
function log_posterior(x,y,sigmaN,sigma,alpha)
    logPost= mrf_log_prior(x,sigma,alpha)+denoising_llh(x,y,sigmaN)
  return logPost
end

function grad_posterior(x,y,sigmaN,sigma,alpha)
    gradPost= mrf_grad_log_prior(x,sigma,alpha)+denoising_grad_llh(x,y,sigmaN)
  return gradPost
end
