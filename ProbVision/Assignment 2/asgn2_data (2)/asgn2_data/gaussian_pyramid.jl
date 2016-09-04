#taken from CV1 solutions

function makegaussianpyramid(im,nlevels, fsize, sigma)
  filt = makegaussianfilter(fsize,sigma)
  G = Array(Array{Float64,2}, nlevels)
  G[1] = im
  for i = 2:nlevels
    G[i] = downsample2(imfilter(G[i-1], filt, "symmetric"))
  end
  return G
end

function makegaussianfilter(size,sigma)
  if length(size) == 1
    size = [size,size]
  end
  rx = (size[2]-1)/2
  dx = (-rx:rx)´
  ry = (size[1]-1/2)
  #TO BE CONTINUED
