using Images
using PyPlot
using ImageView

# Create 3x3 derivative filters in x and y direction
function createfilters()
  #Normalized Sobel filters. Includes gaussian according to slides.
#  fx=[1 0 -1; 2 0 -2; 1 0 -1]/8
#  fy=[ 1 2 1; 0 0 0; -1 -2 -1]/8
  dx = [ -0.5 0 0.5] # note : imfilter uses correlation
 gy = gaussian2d (1 ,[3 ,1])
 fx = gy*dx
 fy = fx'
  return fx::Array{Float64,2},fy::Array{Float64,2}
end

# Apply derivate filters to an image and return the derivative images
function filterimage(I::Array{Float32,2},fx::Array{Float64,2},fy::Array{Float64,2})

  Ix=imfilter(I,fx)
  Iy=imfilter(I,fy)
  return Ix::Array{Float64,2},Iy::Array{Float64,2}
end

# Apply thresholding on the gradient magnitudes to detect edges
function detectedges(Ix::Array{Float64,2}, Iy::Array{Float64,2}, thr::Float64)
  edges=sqrt(Ix.^2+Iy.^2)
#  for i=1:size(edges,1)
#    for j=1:size(edges,2)
#      if edges[i,j]<thr
#    edges[i,j]=0
#      end
#    end
#  end
  edges [ edges .< thr ] = 0
  return edges::Array{Float64,2}
end

# Apply non-maximum-suppression
function nonmaxsupp(edges::Array{Float64,2},Ix::Array{Float64,2},Iy::Array{Float64,2})
#  for i=2:size(edges,1)-1
#    for j=2:size(edges,2)-1
#      if(edges[i,j]!=0)
#        theta=rad2deg(atan2(Iy[i,j],Ix[i,j]))
#        if(abs(theta)<=22.5 || abs(theta)>=157.5)
#          if(edges[i,j+1]>edges[i,j]||edges[i,j-1]>edges[i,j])
#            edges[i,j]=0
#          end
#
#        elseif(22.5<theta<=67.5 || -112.5<=theta<157.5)
#          if(edges[i+1,j+1]>edges[i,j]||edges[i-1,j-1]>edges[i,j])
#            edges[i,j]=0
#          end
#
#        elseif(67.5<abs(theta)<112.5)
#          if(edges[i+1,j]>edges[i,j]||edges[i-1,j]>edges[i,j])
#            edges[i,j]=0
#          end
#
#        elseif(112.5<theta<=157.5 || -22.5<=theta<-67.5)
#          if(edges[i+1,j+1]>edges[i,j]||edges[i-1,j-1]>edges[i,j])
#            edges[i,j]=0
#          end
#        end
#      end
#    end
#  end
   pi8 = pi /8
   orientation = atan (iy ./ ix)
   edges2 = copy ( edges )
   r = 2: size (edges ,1) +1
   c = 2: size (edges ,2) +1

   padedges = padarray (edges ,[1 ,1] ,[1 ,1] ," value " ,0)

 # left -to - right edges
   xedges = ( orientation .<= pi8 ) & ( orientation .>- pi8 )
   xnonmax = padedges [r,c] .< max ( padedges [r,c -1] , padedges [r,c +1])
   edges2 [ xedges & xnonmax ] = 0

 # top -to - bottom edges
   yedges = ( orientation . >3* pi8 ) | ( orientation . <= -3* pi8 )
   ynonmax = padedges [r,c] .< max ( padedges [r -1,c], padedges [r+1,c])
   edges2 [ yedges & ynonmax ] = 0

 # bottomleft -to - topright edges
   xyedges = ( orientation . <=3* pi8 ) & ( orientation .> pi8)
   xynonmax = padedges [r,c] .< max ( padedges [r -1,c -1] , padedges [r+1,c +1])
   edges2 [ xyedges & xynonmax ] = 0

 # topleft -to - bottomright edges
   yxedges = ( orientation . > -3* pi8 ) & ( orientation .<=- pi8 )
   yxnonmax = padedges [r,c] .< max ( padedges [r+1,c -1] , padedges [r -1,c +1])
   edges2 [ yxedges & yxnonmax ] = 0
   return edges::Array{Float64,2}
end


#= Problem 3
Image Filtering and Edge Detection =#

function problem3()
cd("C:\\Users\\Javier\\Desktop\\Vision\\asgn1_data_v1")

  # load image
  img = PyPlot.imread("data-julia/a1p3.png")

  # create filters
  fx, fy = createfilters()
  # filter image
  Ix, Iy = filterimage(img, fx, fy)

  # show filter results
  figure()
  subplot(121)
  imshow(Ix, "gray", interpolation="none")
  title("x derivative")
  axis("off")
  subplot(122)
  imshow(Iy, "gray", interpolation="none")
  title("y derivative")
  axis("off")
  gcf()

  # show gradient magnitude
  figure()
  imshow(sqrt(Ix.^2 + Iy.^2),"gray", interpolation="none")
  axis("off")
  title("Derivative magnitude")
  gcf()

  # threshold derivative
  threshold = 0.05
  #We chose this treshold value because a value of 0.1 lost us a lot of information and was actually so fierce that the non-maximum suppresion didn't do anything.
  #A treshold value of 0.05 let us keep almost all of the edges while also allowing the non-maximum suppresion method to be effective. We found it by trial and error.
  edges = detectedges(Ix,Iy,threshold)
  figure()
  imshow(edges.>0, "gray", interpolation="none")
  axis("off")
  title("Binary edges")
  gcf()

  # non maximum suppression

  edges2 = nonmaxsupp(edges,Ix,Iy)
  figure()
  imshow(edges2.>0,"gray", interpolation="none")
  axis("off")
  title("Non-maximum suppression")
  gcf()
  return
end

