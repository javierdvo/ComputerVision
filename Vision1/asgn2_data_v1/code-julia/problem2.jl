using Images
using PyPlot

# Load images from the yale_faces directory and return a MxN data matrix,
# where M is the number of pixels per face image and N is the number of images.
# Also return the dimensions of a single face image and the number of all face images
function loadfaces()
  n=0
  xsize=96
  face1=38
  face2=20
  ysize=84
  data= zeros(xsize*ysize,face1*face2)
  for i=1:face1
    for j=1:face2
      n=n+1
      if i<=9
        if j<=9
	      name=string("..\\data-julia\\yale_faces\\yaleBs0",i,"\\0",j,".pgm")
        data[:;n]=vec(PyPlot.imread(name)*1.0)
        else
	      name=string("..\\data-julia\\yale_faces\\yaleBs0",i,"\\",j,".pgm")
         data[:;n]=vec(PyPlot.imread(name)*1.0)
        end
      else
        if j<=9
	      name=string("..\\data-julia\\yale_faces\\yaleBs",i,"\\0",j,".pgm")
        data[:;n]=vec(PyPlot.imread(name)*1.0)
        else
	      name=string("..\\data-julia\\yale_faces\\yaleBs",i,"\\",j,".pgm")
         data[:;n]=vec(PyPlot.imread(name)*1.0)
        end
      end
    end
  end
  facedim=[xsize,ysize]
  return data::Array{Float64,2},facedim::Array{Int},n::Int
end

# Apply principal component analysis on the data matrix.
# Return the eigenvectors of covariance matrix of the data, the corresponding eigenvalues,
# the one-dimensional mean data matrix and a cumulated variance vector in increasing order.
function computepca(data::Array{Float64,2})
  mu=sum(data,2)/size(data,2)
  Xcap=data.-mu
  (U,lambda,V)= svd(Xcap)
  cumvar=cumsum(lambda,1)/sum(lambda)
  return U::Array{Float64,2},lambda::Array{Float64,1},mu::Array{Float64,2},cumvar::Array{Float64,1}
end

# Compute required number of components to account for (at least) 80/95 % of the variance
function computencomponents(cumvar::Array{Float64,1})
  n80=0
  n95=0
  for k=760:-1:1
    if cumvar[k]>=0.8
      n80=k
    end
    if cumvar[k]>=0.95
      n95=k
    end
  end
  return n80::Int,n95::Int
end

# Display the mean face and the first 10 Eigenfaces in a single figure
function showfaces(U::Array{Float64,2},mu::Array{Float64,2},facedim::Array{Int})
  figure()
  subplot(3,4,1)
  imshow(reshape(mu,facedim[1],facedim[2] ),"gray")
  axis("off")
  subplot(3,4,2)
  imshow(reshape(U[:;1],facedim[1],facedim[2] ),"gray")
  axis("off")
  subplot(3,4,3)
  imshow(reshape(U[:;2],facedim[1],facedim[2] ),"gray")
  axis("off")
  subplot(3,4,4)
  imshow(reshape(U[:;3],facedim[1],facedim[2] ),"gray")
  axis("off")
  subplot(3,4,5)
  imshow(reshape(U[:;4],facedim[1],facedim[2] ),"gray")
  axis("off")
  subplot(3,4,6)
  imshow(reshape(U[:;5],facedim[1],facedim[2] ),"gray")
  axis("off")
  subplot(3,4,7)
  imshow(reshape(U[:;6],facedim[1],facedim[2] ),"gray")
  axis("off")
  subplot(3,4,8)
  imshow(reshape(U[:;7],facedim[1],facedim[2] ),"gray")
  axis("off")
  subplot(3,4,9)
  imshow(reshape(U[:;8],facedim[1],facedim[2] ),"gray")
  axis("off")
  subplot(3,4,10)
  imshow(reshape(U[:;9],facedim[1],facedim[2] ),"gray")
  axis("off")
  subplot(3,4,11)
  imshow(reshape(U[:;10],facedim[1],facedim[2] ),"gray")
  axis("off")
  show()
  return nothing
end

# Fetch a single face with given index out of the data matrix. Returns the actual face image.
function takeface(data::Array{Float64,2},facedim::Array{Int},n::Int)
  tmpface=data[:;n]
  face=reshape(tmpface,facedim[1],facedim[2] )
  return face::Array{Float64,2}
end

# Project a given face into the low-dimensional space with a given number of principal
# components and reconstruct it afterwards
function computereconstruction(faceim::Array{Float64,2},U::Array{Float64,2},mu::Array{Float64,2},n::Int)
  tmp=zeros(8064)
  for i=1:n
    tmp=tmp+U[n]
  end
  recon=vec(faceim).*tmp + mu
  recon=reshape(recon,96,84)
  return recon::Array{Float64,2}
end



# Problem 2: Eigenfaces

function problem2()
  # load data
  data,facedim,N = loadfaces()

  # compute PCA
  U,lambda,mu,cumvar = computepca(data)
  # plot cumulative variance
  figure()
  plot(cumvar)
  grid("on")
  title("Cumulative Variance")
  gcf()

  # compute necessary components for 80% / 95% variance coverage
  n80,n95 = computencomponents(cumvar)
  # plot mean face and first 10 eigenfaces
  showfaces(U,mu,facedim)
  # get a random face
  faceim = takeface(data,facedim,rand(1:N))

  # reconstruct the face with 5,15,50,150 principal components
  f5 = computereconstruction(faceim,U,mu,5)
  f15 = computereconstruction(faceim,U,mu,15)
  f50 = computereconstruction(faceim,U,mu,50)
  f150 = computereconstruction(faceim,U,mu,150)
  f760 = computereconstruction(faceim,U,mu,760)


  # display the reconstructed faces
  figure()
  subplot(321)
  imshow(faceim,"gray",interpolation="none")
  axis("off")
  title("Original")
  subplot(322)
  imshow(f5,"gray",interpolation="none")
  axis("off")
  title("5 Principal Components")
  subplot(323)
  imshow(f15,"gray",interpolation="none")
  axis("off")
  title("15 Principal Components")
  subplot(324)
  imshow(f50,"gray",interpolation="none")
  axis("off")
  title("50 Principal Components")
  subplot(325)
  imshow(f150,"gray",interpolation="none")
  axis("off")
  title("150 Principal Components")
  subplot(326)
  imshow(f150,"gray",interpolation="none")
  axis("off")
  title("760 Principal Components")
  show()
  return
end
