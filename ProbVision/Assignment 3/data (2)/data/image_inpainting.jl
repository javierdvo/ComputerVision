using Images
using PyPlot

include("Common.jl")
include("mrf_prior.jl")
include("psnr.jl")


#Gradient ascent function
function gradientAscent(x,M,sigma,alpha,step,iter)
  newX=x
  for i=0:iter
    newX=newX+step*M.*mrf_grad_log_prior(newX,sigma,alpha)
  end
  return newX
end

#Img restore creates a mask, sets the image in those indices to 127 and calls the gradient ascent method
function imgRestore(x,percentage,sigma,alpha,step,iterations)
  indices=rand(1:length(x),Integer(length(x)*percentage)) #basically draws a sample of indices. It is not exactly the percentage because I forgot about shuffle() and numbers can repeat.
  maskedImg=copy(x)
  maskedImg[[indices]]=127
  mask=zeros(size(x))
  mask[[indices]]=1
  newImage=gradientAscent(maskedImg,mask,sigma,alpha,step,iterations)
  return newImage, maskedImg
end
#Init values
sigma=10
alpha=1
step=5
iterations=1000
x=PyPlot.imread("images\\castle.png")*255
percentage1=0.5
percentage2=0.8

#Gets image with oh surprise 50 and 80 percent and prints the psnr. Damn im also good at sarcasm
img50,mask50=imgRestore(x,percentage1,sigma,alpha,step,iterations)
img80,mask80=imgRestore(x,percentage2,sigma,alpha,step,iterations)
peak=psnr(x,img50)
print("The PSNR for 50% is : $peak \n\n")
peak=psnr(x,img80)
print("The PSNR for 80% is : $peak \n")
#The results were amazingly good, way better than we expected to be honest. The image can be seen in very good detail even if we have a huge amount of the pixels missing.
#This is mostly due to our prior from the original image and the posterior model. Seriously, restoring an image that has 80% missing is borderline magic. (Well, not quite, but you get the gist)
#As it was expected the PSNR of the 50% is higher than the 80%, due to the fact that it has to suppose less pixels.
#plotting
fig, ax = subplots(2,2)
ax[1,1][:imshow](img50,"gray")
ax[1,2][:imshow](mask50,"gray")
ax[2,1][:imshow](img80,"gray")
ax[2,2][:imshow](mask80,"gray")
