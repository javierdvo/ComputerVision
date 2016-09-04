using Images
using PyPlot



# Create a gaussian filter
function makegaussianfilter(size::Array{Int,2},sigma::Float64)
    gH=zeros(Float64,1,size[1])
    gV=zeros(Float64,size[2],1)
    middle=floor(size[1]/2)
    for i=-middle:middle
        gH[1,i+middle+1]=exp((-i^2)/(2*sigma^2))/sqrt(2*pi)
    end
    gV=gH'
    g=gV*gH
    g=g./sum(g)
    return g
end

# Create a binomial filter
function makebinomialfilter(size::Array{Int,2})
  fH=zeros(Float64,1,size[1]+1)
  fV=fH'
  for i=0:size[1]
    fH[1,i+1]=factorial(size[1])/(factorial(i)*factorial(size[1]-i))
  end
  fV=fH'
  f=fV*fH
  f=f./sum(f)
    return f
end

# Downsample an image by a factor of 2
function downsample2(A::Array{Float64,2})
 (r,c)= Base.size(A)
  dimr=int(ceil(r/2))
  dimc=int(ceil(c/2))
  D=zeros(dimr,dimc)
  D=A[1:2:r;1:2:c]
  return D
end

# Upsample an image by a factor of 2
function upsample2(A::Array{Float64,2},fsize::Array{Int,2})
  (r,c)= Base.size(A)
  dimr=r*2
  dimc=c*2
  tmpU=zeros(dimr,dimc)
  tmpU[1:2:dimr;1:2:dimc]=A;
  filt=makebinomialfilter(fsize)
  U=conv2(tmpU,filt)
  U=U[3:dimr+2;3:dimc+2]
  U=U.*4
  return U::Array{Float64,2}
end

# Build a gaussian pyramid from an image.
# The output array should contain the pyramid levels in decreasing sizes.
function makegaussianpyramid(im::Array{Float32,2},nlevels::Int,fsize::Array{Int,2},sigma::Float64)
  (r,c)= Base.size(im)
  G= Array(Array{Float64,2},0)
  filt=makegaussianfilter(fsize,sigma)
  push!(G,im)
  for i=1:nlevels
    Gtmp=conv2(G[i],filt)
    Gtmp=Gtmp[3:r+2;3:c+2]
    Gtmp=downsample2(Gtmp)
    r=ceil(r/2)
    c=ceil(c/2)
    push!(G,Gtmp)
  end
  return G::Array{Array{Float64,2},1}
end



# Display a given image pyramid (laplacian or gaussian)
function displaypyramid(P::Array{Array{Float64,2},1})

  if size(P[1],1)==512
    index=[1 2 3 4 5 6 7]
  else
    index=[7 6 5 4 3 2 1]
  end
  figure()
  pic=zeros(512,1019)
  pic[1:512;1:512]=P[index[1]]
  pic[1:256;513:768]=P[index[2]]
  pic[1:128;769:896]=P[index[3]]
  pic[1:64;897:960]=P[index[4]]
  pic[1:32;964:995]=P[index[5]]
  pic[1:16;996:1011]=P[index[6]]
  pic[1:8;1012:1019]=P[index[7]]
  imshow(pic, "gray", interpolation="none")
  axis("off")
  show()
  return nothing
end

# Build a laplacian pyramid frsize(P[1],1)==512&&P[1]||size(P[7],1)==512&&(P[7]) gaussian pyramid.
# The output array should contain the pyramid levels in decreasing sizes.
function makelaplacianpyramid(G::Array{Array{Float64,2},1},nlevels::Int,fsize::Array{Int,2})
   L= Array(Array{Float64,2},0)
   push!(L,G[nlevels+1])
  for i=nlevels:-1:1
    Gtmp=upsample2(G[i+1],fsize)
    Gtmp=G[i].-Gtmp
    push!(L,Gtmp)
  end
  return L::Array{Array{Float64,2},1}
end

# Amplify frequencies of the first two layers of the laplacian pyramid
function amplifyhighfreq2(L::Array{Array{Float64,2},1})
  A= Array(Array{Float64,2},0)
  factor1=1.2
  factor2=1.1
  A=L
  A[6]=A[6]*factor1
  A[7]=A[7]*factor2
  return A::Array{Array{Float64,2},1}
end

# Reconstruct an image from the laplacian pyramid
function reconstructlaplacianpyramid(L::Array{Array{Float64,2},1},fsize::Array{Int,2})
  Ltemp=L
  im=upsample2(Ltemp[1],fsize)
  for i=2:size(Ltemp,1)-1
    imtmp=im+Ltemp[i]
    im=upsample2(imtmp,fsize)
  end
  im=im+L[7]
  return im::Array{Float64,2}
end


# Problem 1: Image Pyramids and Image Sharpening

function problem1()

  # parameters
  fsize = [5 5]
  sigma = 2.0
  nlevels = 6
  # load image
  im = PyPlot.imread("..\\data-julia\\a2p1.png")

  # create gaussian pyramid
  G = makegaussianpyramid(im,nlevels,fsize,sigma)
  # display gaussianpyramid
  displaypyramid(G)
 # title("Gaussian Pyramid")
  # create laplacian pyramid
  L = makelaplacianpyramid(G,nlevels,fsize)

  # dispaly laplacian pyramid
  displaypyramid(L)
  #title("Laplacian Pyramid")

  # amplify finest 2 subands
  L_amp = amplifyhighfreq2(L)

  # reconstruct image from laplacian pyramid
  im_rec = reconstructlaplacianpyramid(L_amp,fsize)

  # display original and reconstructed image
  figure()
  subplot(131)
  imshow(im,"gray",interpolation="none")
  axis("off")
  title("Original Image")
  subplot(132)
  imshow(im_rec,"gray",interpolation="none")
  axis("off")
  title("Reconstructed Image")
  subplot(133)
  imshow(im-im_rec,"gray",interpolation="none")
  axis("off")
  title("Difference")
  gcf()
  show()
    return size(im_rec,2)
end
