#Peak Signal to Noise Ratio
function psnr(x_gt,x)
    MSE=sum((x_gt-x).^2)/(size(x,1)*size(x,2))
    peak=10*log10((maximum(x_gt)^2)/MSE)
  return peak
end

#Gradient
function grad_psnr(x_gt,x)
    res=20./(sum((x_gt-x))*log(10))
  return res
end


#These are direct learning function derivatives (Which sadly didnt work due to me being unable to initialize correctly), WolframAlpha sponsored. they take the whole Loss function extended with all subfunctions.
function grad_s_psnr(x_gt,d,s,a)
  res=-160*d*a*s./(log(10)*(d.^2+2s^2).*(d.^3-x_gt.*d.^2-2*d.*x+2*d*s^2-2*x_gt*s^2))
  return res
end

function grad_a_psnr(x_gt,d,s,a)
  res=-40*d./(log(10).*(d.^3-x_gt.*d.^2-2*d.*x+2*d*s^2-2*x_gt*s^2))
  return res
end
