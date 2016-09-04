using Images
using PyPlot

include("Common.jl")
include("mrf_posterior.jl")
include("psnr.jl")
#Gradient ascent formulation as seen in slides
function gradientAscent(y,sigmaN,sigma,alpha,step,iter)
  newX=y
  for (i=0:iter)
    newX=newX+step.*grad_posterior(newX,y,sigmaN,sigma,alpha)
    #every 100 iterations
    if i%100==0
      print(sum(log_posterior(newX,y,sigmaN,sigma,alpha)))
      print("\n")
    end
  end
  print(sum(log_posterior(newX,y,sigmaN,sigma,alpha)))
  print("\n")
  return newX
end


#init
sigmaN=15
sigmaGrad=297
alphaGrad=297
sigma=6
alpha=1
step=0.1
#Sigma above 10 makes the log posterior decrease(as does the speed as it lowers), but it does give worse results and the PSNR is lower(Which is bad)
#Sigma below 10 has a worse log posterior but it does decrease faster, the PSNR is higher(Which is good) and the image looks better, granted it does lose some features so too low smooths it out too much
#Alpha above 1 increases the log posterior but the same goes, it will decrease faster. PSNR is around the same value but the image gets smoothed.
#alpha below 1 makes the log posterior decrease (same goes for speed), the PSNR sucks balls and the image keeps a lot of noise still.
#A sigma of around 5 and an alpha of 1 give a good result both in looks and in PSNR
iterations=1000 #Because why not
x=255*PyPlot.imread("images\\la.png")/1.0

#Generates image with sigmaN noise
noise=randn(size(x))*sigmaN
y=x+noise
#adding 60 makes the image brighter and oh so smooth after the gradient descent.Detail is lost quite nicely
#noise=randn(size(x))+60
#y=x+noise

#They differ in the fact that in the last one it oversmooths thanks to the added brightness all around, while in the first it does a better job due to how it will even out the errors.
#None are perfect due to the fact that we either get precision or smoothness. We cannot have both and thus errors in either group will get bigger if we move towards fixing the other side.
#Thus we should try and see what feature we want to supress and design the denoising accordingly.

#random indices for the testing
indices=rand(1:length(x),50)
print("Testing the gradient(mean of 50 pixels):\n")
print(mean(Common.testgrad(x->denoising_llh(x,y,sigmaN),x->denoising_grad_llh(x,y,sigmaN),x,indices)))
#Calls gradient ascent
print("\nThe log posterior:\n")
xnew=gradientAscent(y,sigmaN,sigma,alpha,step,iterations)


#Gets the PSNR and prints it
#ALSO NOTe TO SELF: HIGHER PSNR IS WHAT WE WANT!!!!
peak=psnr(x,y)
print("The PSNR for noisy image is : $peak \n")
peak=psnr(x,xnew)
print("The PSNR for the denoised image is : $peak \n")

#plottingg
fig, ax = subplots(4,1, sharey = true)

ax[1,1][:imshow](x,"gray")
ax[2,1][:imshow](y,"gray")
ax[3,1][:imshow](xnew,"gray")
ax[4,1][:imshow](xnew-y,"gray")

#The PSNR is higher which means that the noise affects it less (or the signal is stronger), either way it just means that the model is less susceptible to noise and thus the image is also less "noisy"
#Altough this also depends in our perception and some images with higher PSNR might look weird to our eyes due to how we take into consideration extra information like fading, borders, occlusion etc.



|
