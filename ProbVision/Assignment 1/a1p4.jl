# COMPUTER VISION 2
# Assignment 1
# Problem 4
# Javier De Velasco Oriol - javo10portero@hotmail.com
# Christian Benz - christian.benz@stud.tu-darmstadt.de

using FileIO
using Distributions
using Images
using PyPlot
#using ImageView
#using ImageMagick
#using FixedPointNumbers

include("Common.jl")
using Common


#----------------APPLY DISPARITY----------------
function applyDisparity(I::Array{Float64,2},d::Array{Float64,2})
	#container for resulting image
  shiftedImg=zeros(size(I))
	#auxiliary array for columns [1 2 3 ... max(cols)]
  aux=[1:size(I,2)]
	#iterate over rows
  for i=1:size(I,1)
		#new column value is [1-disparity[1] 2-disparity(2) ...]
    shiftedImg[i,:]=I[i,aux-vec(d[i,:])]
  end
  return shiftedImg::Array{Float64,2}
end

#----------------GAUSSIAN LIKELIHOOD----------------
#we have the same result here, checked with [0 1 1; -1 0 1], [0 0 1; 0 1 1], 0, 1
function gaussian_likelihood(I0::Array{Float64,2},I1d::Array{Float64,2},mu::Int64,sigma::Int64)
	#product of the elements of the matrix of the probabilities (according
	#to the normal distribution) of the differenced image
	likelihood=prod(pdf(Normal(mu,sigma),I0-I1d)) #Simple implementation of the formula given in the slides using the probability density function from Dist. package and the gaussian distribution
  return likelihood::Float64
end


#----------------GAUSSIAN NEG LOG LIKELIHOOD----------------
function gaussian_neg_log_likelihood(I0, I1d, mu, sigma)


  #(cf. slide 31 of "From Robust Statistics to Graphical Models")
  if mu == 0
    cons = size(I0,1)*size(I0,2)*log(sqrt(2*pi*sigma)) #Gets the constant value for the second part of the equation
    result = 1/(2*sigma)*sum((I0-I1d).^2) + cons #adds it to the first part of the equation in the slides
  else#Implementation for the case sigma !=0, not really used in this lab though. Uses the gaussian and probability density funcion from dist and adds the result of all probabilities
    dist = Normal(mu, sigma)
    probs = -log(pdf(dist, I0-I1d))
    result = sum(probs)
  end

	return result
end


#----------------LAPLACIAN NEG LOG LIKELIHOOD----------------

function laplacian_neg_log_likelihood(I0, I1d, mu, s)

	#Alternate implementations:

  #Get the Laplace distribution from the Dist. package,do the NEG LOG probability density estimation, add all the estimations.
	#dist = Laplace(mu, s)
	#probs = -log(pdf(dist, I0-I1d))#
  #probs = sum(probs) #

	#Non pointwise implementation of the one below.
	exponent = -abs(I0-I1d-mu)/s
	res = -(size(exponent,1)*size(exponent,2)*log(1/(2*s)))-sum(exponent)

  #Formula from the HW implemented with the negative log in a simmilar fashion as the neglog slides implementation, gets the exponent value and sums all the values from the (-exp-log ) equation
	#exponent = -abs(I0-I1d-mu)/s
	#res2 = sum(-log(1/(2*s)).-exponent)

	return res
end




#----------------SUBTASK 1----------------
#load I0 and convert to grayscale
I0 = PyPlot.imread("i0.ppm")
i0 = Common.rgb2gray(I0)
i0 = convert(Array{Float64}, i0)

#load I1 and convert to double
I1 = PyPlot.imread("i1.ppm")
i1 = Common.rgb2gray(I1)
i1 = convert(Array{Float64}, i1)

#load ground truth and convert to double
GT = PyPlot.imread("gt.pgm")
gt = convert(Array{Float64,2}, GT)
gt = gt./16




#----------------SUBTASK 2----------------
println("----------SUBTASK 2-----------")


#compute disparity image according to ground truth
i1d = applyDisparity(i1,gt)
imshow(i1d, "gray")
sleep(10)
println("gaussian_likelihood= ", gaussian_likelihood(i0, i1d, 0, 1))
#RESULT = 0.0
sleep(5)



#----------------SUBTASK 3----------------
println("----------SUBTASK 3-----------")
println("gaussian_neg_log_likelihood = ", gaussian_neg_log_likelihood(i0, i1d, 0, 1))
#RESULT = (Inf,1.5543394750264172e7,1.54417675e7)
sleep(5)



#ANSWER: The negative log has some computational advantages. It transforms
#products into sums and increases close-to-zero values overproportionally.
#In therefore can better handle (small) probabilities which lead to hier
#numerical stability. Meanwhile the logarithm does not change the location
#of the extrema since it is a monotonous function.


#----------------SUBTASK 4----------------
println("----------SUBTASK 4-----------")

#Alternative to the pixel random intensities. This modifies exactly 1/3 of the pixels with a random value and random position
#randX=randperm(size(image1,1))[1:floor(size(image0,1)/3)]
#randY=randperm(size(image1,2))[1:floor(size(image0,2)/3)]
#i1out=image1
#i1out[randX,randY]=rand(1:255,size(randX,1),size(randY,1))
#imshow(i1out)

#inserts pixels of random intensities in random rows and columns, This modifies each pixel with probability p to a random variable. So each pixel has approximately, say 30% chance to get modified
#This case was selected because the above implementation would sometimes give a structured noise.
function insertOutliers(I, p)
	Ires = copy(I)
	#store image size
	rows, cols = size(I)
	#number of pixels to insert
	n = floor(Int, p*rows*cols)

  #set pixels to random values at amount p
	for i = 1:rows
    for j = 1:cols
      if rand() <= p
        Ires[i,j] = rand(0:255)
      end
    end
  end

	return Ires
end

println("--10% Outliers--")
i1out = insertOutliers(i1, 0.1)
imshow(i1out, "gray")
sleep(10)
i1o10D = applyDisparity(i1out, gt)
println("gaussian_likelihood = ", gaussian_likelihood(i0,i1o10D,0,1))
#RESULT = 0.0
println("gaussian_neg_log_likelihood = ", gaussian_neg_log_likelihood(i0,i1o10D,0,1))
#RESULT = (Inf,7.991059375026417e7,7.98089665e7)
sleep(5)



println("--30% Outliers--")
i1out = insertOutliers(i1, 0.3)
sleep(10)
imshow(i1out, "gray")
i1o30D = applyDisparity(i1out, gt)
println("gaussian_likelihood = ", gaussian_likelihood(i0,i1o30D,0,1))
#RESULT = 0.0
println("gaussian_neg_log_likelihood = ", gaussian_neg_log_likelihood(i0,i1o30D,0,1))
#RESULT = (Inf,2.0685143875026417e8,2.067498115e8)
sleep(5)

#----------------SUBTASK 5----------------
println("----------SUBTASK 5-----------")

println("laplacian_neg_log_likelihood = ", laplacian_neg_log_likelihood(i0, i1d, 0, 1))
# RESULT = (777939.5329924831,777939.5329924854,777939.5329924831)
println("--10% Outliers--: laplacian_neg_log_likelihood = ", laplacian_neg_log_likelihood(i0,i1o10D,0,1))
#RESULT = (1.6930035329924887e6,1.6930035329924854e6,1.6930035329924887e6)
println("--30% Outliers--: laplacian_neg_log_likelihood = ", laplacian_neg_log_likelihood(i0,i1o30D,0,1))
#RESULT = (3.5178445329924966e6,3.5178445329924854e6,3.5178445329924966e6)
sleep(10)
#----------------SUBTASK 6----------------
# ANSWER: It salient that the gaussian_likelihood is zero for the various images. The problem is that the values
# are actually not zero, but so close to zero, that machine precision does not suffice to display the
# differences. Hence, the neg-log-likelihood is numerically more stable. As far as the noisy images are
# concerned, they increase the neg-log-likelihood with increasing amount of noise. That conforms with a
# decrease in the likelihood which is expected for such cases. However, the Laplacian neg-log-likelihood
# is less sensitive for outliers with repect to the step from 0% to 10% outliers than the Gaussian: The
# Laplacian roughly increase by the factor of 2 whereas the Gaussian increases by the factor of 5 (see table
# below). For the latter steps from 10% to 30% outliers the difference is not noticable.
#
# Outliers    0%            10%         30%
# Gaussian:   1.6*10^7 --   8*10^7 --   2*10^8
# Laplace:    8*10^5 --     1.7*10^6 -- 3.5*10^6
