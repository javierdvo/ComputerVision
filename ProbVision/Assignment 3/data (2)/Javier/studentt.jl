function dx_studentt(x, sigma, alpha)
  return -alpha*x./sigma^2 .*studentt(x,sigma,alpha+1)
end

function studentt(x, sigma, alpha)
  return (1 + x.^2 / (2*sigma^2)).^-alpha
end
