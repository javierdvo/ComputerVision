using Images
using PyPlot
using Optim

include("Common.jl")
include("mrf_prior.jl")
include("psnr.jl")
include("mrf_posterior.jl")


#prediction function for 1 step and which also gets the sigma/alpha partial derivatives
function prediction(x,y,sigmaN,sigma,alpha,step)
  newX=y
  dsigma,dalpha=mrf_grad_log_prior_loss(newX,sigma,alpha)
  newX=newX+step*grad_posterior(newX,y,sigmaN,sigma,alpha)
  return newX,dsigma*step,dalpha*step
end

#Learning function
function lo(params)
  #f,dsigma,dalpha=prediction(x,y,sigmaN,params[1],params[2],step)
  f,dsigma,dalpha=prediction(x,y,sigmaN,params[1],params[2],step)
  J=-psnr(x_gt,f)
  return J
end

#Gradient of the learning function
function lg!(params,storage)
  f,dsigma,dalpha=prediction(x,y,sigmaN,params[1],params[2],step)
  storage[1]=-grad_psnr(x_gt,f)
  storage[2]=-grad_psnr(x_gt,f)
  #storage[1]=-sum(grad_s_psnr(x_gt,y,params[1],params[2]))
  #storage[2]=-sum(grad_a_psnr(x_gt,y,params[1],params[2]))
end
#=Gradient of the J function is the only thing missing in this program, we are still unsure of how to incorporate the dsigma and the dalpha matrixes to obtain the gradient
Everything else is up and running, and if we had a working gradient it would all work like a charm.=#
#If you plug in here the good version of the gradient everything should work. In theory. It should. Hopefully.
#Startup data:
x_gt=PyPlot.imread("images\\la.png")/1.0*255
y=PyPlot.imread("images\\la-noisy.png")/1.0*255
x=copy(y)
yOriginal=copy(y)
step=1
sigma=10
alpha=1
sigmaN=1 #because image is noisy already
paramsInit=[10.0,1.0]
T=10
images=zeros(T,size(x_gt,1),size(x_gt,2))



#print(Common.testgrad(x->-psnr(x_gt,y),x->grad_psnr(x_gt,y),x_gt,[1;2;3;4;5;6]))
#res=optimize(lo,lg!,paramsInit,GradientDescent())
#print(res)
#paramsInit=Optim.minimizer(res)


#Yes we can expect similar results with those parameters IF the noise/errors correspond somewhat to the noise/error of the noisy function.
#If the image has a completely different arrangement of noise it will screw it up (But noise tends to behave equally in most cases)
#As a rule of thumb the closer the new noise is to the original noisy image noise the better the improvements these parameters will work.

peak=psnr(x_gt,y)
print("\nThe PSNR for noisy image is : $peak \n")
#Iteration cycle for t=10 which does the optimization of the parameters then gets the new image with the adjusted parameters. And repeats the process
for i=1:T
  res=optimize(lo,lg!,paramsInit,GradientDescent()) #optimizes
  print(res)
  paramsInit=Optim.minimizer(res) #saves params
  y,dsigmas,dalphas=prediction(x_gt,y,sigmaN,paramsInit[1],paramsInit[2],step)#Updates the image
  peak=psnr(x_gt,y)
  print("\nThe PSNR for denoised image $i is : $peak \n")
  images[i,:,:]=y
end
#It has a very high proability of being better than the problem 2, due to the fact that it will constantly try to update the params to the image accordingly to the best fit.
#So each update improves the image and the parameters especifically for that image. Due to that reason it is not a fair comparison, it cherry picks the ideal params in every iteration
#instead of getting general parameters that work for any case. Thus parameters midway might be useless in another image for example.

#Nope. They are ideal because they are cherry picked and we are getting the maximum. In the case that we consider that the noise follows the model we designed (ie gaussian random noise)
#If the noise follows another pattern then some other parameters might be able to get a better PSNR value than the optimum ones. Thus our optimality depends mostly on the model!


#Plotting
fig, ax = subplots(4,3)
ax[1,1][:imshow](x_gt,"gray")
ax[2,1][:imshow](yOriginal,"gray")
ax[3,1][:imshow](reshape(images[1,:,:],size(x_gt,1),size(x_gt,2)),"gray")
ax[4,1][:imshow](reshape(images[2,:,:],size(x_gt,1),size(x_gt,2)),"gray")
ax[1,2][:imshow](reshape(images[3,:,:],size(x_gt,1),size(x_gt,2)),"gray")
ax[2,2][:imshow](reshape(images[4,:,:],size(x_gt,1),size(x_gt,2)),"gray")
ax[3,2][:imshow](reshape(images[5,:,:],size(x_gt,1),size(x_gt,2)),"gray")
ax[4,2][:imshow](reshape(images[6,:,:],size(x_gt,1),size(x_gt,2)),"gray")
ax[1,3][:imshow](reshape(images[7,:,:],size(x_gt,1),size(x_gt,2)),"gray")
ax[2,3][:imshow](reshape(images[8,:,:],size(x_gt,1),size(x_gt,2)),"gray")
ax[3,3][:imshow](reshape(images[9,:,:],size(x_gt,1),size(x_gt,2)),"gray")
ax[4,3][:imshow](reshape(images[10,:,:],size(x_gt,1),size(x_gt,2)),"gray")
