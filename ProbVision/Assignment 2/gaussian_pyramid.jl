using Images
using PyPlot

# Create a Gaussian filter
function makegaussianfilter(size, sigma)
  if length (size) == 1
    size = [size, size ]
  end
  rx = (size[2] -1) /2
  dx = (-rx:rx)'
  ry = (size[1] -1) /2
  dy = -ry:ry
  D = dy .^2 .+ dx .^2
  G = exp(-0.5.* D./ sigma ^2)
  return G./ sum(G)
end


# Downsample an image by a factor of 2
function downsample2(A)
  return A [1:2:end ,1:2:end ]
end

# Upsample an image by a factor of 2
function upsample2(A, fsize )
  res = zeros (2* size (A ,1) ,2* size (A ,2) )
  res [1:2: end ,1:2: end ] = A
  filt = makebinomialfilter ( fsize )
  return 4* imfilter (res ,filt, "symmetric")
end

# Build a Gaussian pyramid from an image
function makegaussianpyramid(im , nlevels ,fsize , sigma )
  filt = makegaussianfilter (fsize , sigma )
  G = Array (Array{ Float64,2}, nlevels )
  G[1] = im
  for i = 2:nlevels
    G[i] = downsample2(imfilter(G[i-1], filt ,"symmetric"))
  end
  return G
end

# Display a given image pyramid ( Laplacian or Gaussian )
function displaypyramid(P)
  function normalize(A)
    return (A .- minimum(A)) ./(maximum(A) .- minimum(A) )
  end
  im = normalize(P[1])
  for i = 2: length(P)
    im = [im [normalize(P[i]) ; zeros(size(im,1) - size(P[i],1), size(P[i],2))]]
  end
  figure()
  imshow(im, "gray", interpolation = "none")
  axis("off")
  return gcf()
end




function problem1 ()
return
end  # parameters
  fsize = [5 5]
  sigma = 1.5
  nlevels = 6

  # load image
  im = PyPlot . imread (" ./i0.ppm ")

  # create Gaussian pyramid
  G = makegaussianpyramid (im , nlevels ,fsize , sigma )

  # display Gaussian pyramid
  displaypyramid (G)
  title (" Gaussian Pyramid ")

  #gcf ()

#  return
#end
