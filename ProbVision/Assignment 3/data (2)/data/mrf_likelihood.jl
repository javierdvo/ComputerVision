#log likelihood for denoising. I am really good at the whole self-descripting comments
function denoising_llh(x,y,sigmaN)
    llh=-((x-y).^2)/(2*(sigmaN^2))
  return sum(llh)
end

#Gradient of the log likelihood
function denoising_grad_llh(x,y,sigmaN)
    gradLlh=-(x-y)/sigmaN^2
  return gradLlh
end
