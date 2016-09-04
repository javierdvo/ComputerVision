using Images
using PyPlot

include("Common.jl")
include("mrf_prior.jl")
#init
sigma=10
alpha=1
x=255*PyPlot.imread("images\\la.png")/1.0

#Test Gradient
indices=rand(1:length(x),50)
print("Testing the gradient(mean of 50 pixels):\n")
print(mean(Common.testgrad(x->mrf_log_prior(x,sigma,alpha),x->mrf_grad_log_prior(x,sigma,alpha),x,indices)))
#generates random and constant image
im1=rand(0:255,size(x))
im2=ones(size(x))*127

#plotting
fig, ax = subplots(3,1, sharey = true)
mrf_grad_log_prior(x,sigma,alpha)
#calls the grad log prior
ax[1,1][:imshow](mrf_grad_log_prior(x,sigma,alpha),"gray")
ax[2,1][:imshow](mrf_grad_log_prior(im1,sigma,alpha),"gray")
ax[3,1][:imshow](mrf_grad_log_prior(im2,sigma,alpha),"gray")


#= As it can be seen the constant image gives us a stable likelihood(Which means all the pixels surrounding it are the same) and there is no gradient due to the fact that nothing changes!
The random image does not give us any information about the continuity of the image and the gradient log prior is equally random
And as expected there are some patterns present in the given image's grad prior. A similarity to the image can be seen. Thus we do have a useful representative prior of the image which we can later use
=#
